#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  NetSDS-AGI-integration.pl
#
#        USAGE:  ./NetSDS-AGI-integration.pl
#
#  DESCRIPTION:  Integration scripts. Call it in Queue parameters.
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  12/21/11 18:41:52 EET
#     REVISION:  ---
#===============================================================================

use 5.8.0;
use strict;
use warnings;

$| = 1;

Integration->run(
    conf_file   => '/etc/NetSDS/asterisk-router.conf',
    daemon      => undef,
    use_pidfile => undef,
    verbose     => undef,
    debug       => 1,
    infinite    => undef
);

1;

package Integration;

use base qw(NetSDS::App);
use Data::Dumper;
use Asterisk::AGI;
use IO::Socket::INET; 

sub start {
    my $this = shift;

    $this->mk_accessors('dbh');
    $this->mk_accessors('agi');

    $this->agi( new Asterisk::AGI );
    $this->agi->ReadParse();

    $this->_db_connect;
}

sub _db_connect {
    my $this = shift;

    unless ( defined( $this->{conf}->{'db'}->{'main'}->{'dsn'} ) ) {
        $this->speak("Can't find \"db main->dsn\" in configuration.");
        exit(-1);
    }

    unless ( defined( $this->{conf}->{'db'}->{'main'}->{'login'} ) ) {
        $this->speak("Can't find \"db main->login\" in configuraion.");
        exit(-1);
    }

    unless ( defined( $this->{conf}->{'db'}->{'main'}->{'password'} ) ) {
        $this->speak("Can't find \"db main->password\" in configuraion.");
        exit(-1);
    }

    my $dsn    = $this->conf->{'db'}->{'main'}->{'dsn'};
    my $user   = $this->conf->{'db'}->{'main'}->{'login'};
    my $passwd = $this->conf->{'db'}->{'main'}->{'password'};

    # If DBMS isn' t accessible - try reconnect
    if ( !$this->dbh or !$this->dbh->ping ) {
        $this->dbh(
            DBI->connect_cached( $dsn, $user, $passwd, { RaiseError => 1 } ) );
    }

    if ( !$this->dbh ) {
        $this->speak("Cant connect to DBMS!");
        $this->log( "error", "Cant connect to DBMS!" );
        exit(-1);
    }

    if ( $this->{verbose} ) {
        $this->agi->verbose( "Database connected.", 3 );
    }
    return 1;
}

sub _exit {
    my $this   = shift;
    my $errstr = shift;

    $this->log( "warning", $errstr );
    $this->agi->verbose( $errstr, 3 );
    exit(-1);
}

sub _get_memberinterface {
    my $this = shift;

    my $memberinterface = $this->agi->get_variable('MEMBERINTERFACE');
    return $memberinterface;

}

sub _begin {
    my $this = shift;

    eval { $this->dbh->begin_work; };

    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
}

sub _find_sipid_by_name {
    my $this     = shift;
    my $sip_name = shift;

    $this->_begin;

    my $sth = $this->dbh->prepare(
"select id,ipaddr from public.sip_peers where name=? order by id asc limit 1"
    );
    eval { my $rv = $sth->execute($sip_name); };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    my $result = $sth->fetchrow_hashref;
    unless ( defined($result) ) {
        $this->_exit("CAN'T FIND SIP/$sip_name");
    }

    my $id     = $result->{'id'};
    my $ipaddr = $result->{'ipaddr'};

    $this->dbh->commit;
    return ( $id, $ipaddr );

}

sub _get_iinfo {
    my $this     = shift;
    my $sip_id   = shift;
    my $sip_addr = shift;

    $this->_begin;

    my $sth = $this->dbh->prepare(
"select * from integration.workplaces where sip_id=? and ip_addr_tel=? order by id asc limit 1"
    );
    my $sth2 = $this->dbh->prepare(
"select * from integration.workplaces where sip_id=? order by id asc limit 1"
    );

    eval { my $rv = $sth->execute( $sip_id, $sip_addr ); };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    my $result = $sth->fetchrow_hashref;
    unless ( defined($result) ) {
        $this->agi->verbose(
"CAN'T FIND INTEGRATION INFO FOR SIP ID=$sip_id AND IP ADDR='$sip_addr'. TRYING WITHOUT IP",
            3
        );
        $this->log( "warning",
"CAN'T FIND INTEGRATION INFO FOR SIP ID=$sip_id AND IP ADDR='$sip_addr'. TRYING WITHOUT IP"
        );

        eval { my $rv = $sth2->execute($sip_id); };
        if ($@) {
            $this->_exit( $this->dbh->errstr );
        }
        $result = $sth->fetchrow_hashref;
        unless ( defined($result) ) {
            $this->_exit("CAN'T FIND INTEGRATION INFO FOR SIP ID=$sip_id");
        }
        $this->dbh->commit;
        return $result;
    }
    $this->dbh->commit;
    return $result;

}
sub _open_blank_taxi_navigator {
    my $this  = shift;
    my $iinfo = shift;
    my $sip_name = shift; 

    my $socket = IO::Socket::INET->new (
        PeerAddr => $iinfo->{'ip_addr_pc'},
        PeerPort => $iinfo->{'tcp_port'},
        Proto    => "tcp",
        Timeout  => 1
    );

    unless ($socket) {
        $this->_exit( "CAN'T CONNECT TO "
              . $iinfo->{'ip_addr_pc'} . ":"
              . $iinfo->{'tcp_port'} );
    }

    my $callerid = $this->agi->get_variable("CALLERID(num)");
    my $calleridlen = length($callerid);
    $callerid = substr($callerid,$calleridlen-10,10); 
    my $uline    = $this->agi->get_variable("PARKINGEXTEN");

    my $command = sprintf( "Message: ActivateCard. Operator: %s CallerID: %s \n\n", $sip_name, $callerid );

    if ( $socket->print($command) ) {
        $socket->flush;
	my @result = $socket->getlines; 
	$this->agi->verbose ( Dumper (\@result), 3); 
    }
    else {
        $this->_exit( "CAN'T WRITE TO THE SOCKET "
              . $iinfo->{'ip_addr_pc'} . ":"
              . $iinfo->{'port'} );
    }
    $this->log("info","Sent ($command) to ".$iinfo->{'ip_addr_pc'}.":".$iinfo->{'tcp_port'});
    undef $socket;

}


sub _open_blank_taxi_office {
    my $this  = shift;
    my $iinfo = shift;

    my $socket = IO::Socket::INET->new (
        PeerAddr => $iinfo->{'ip_addr_pc'},
        PeerPort => $iinfo->{'tcp_port'},
        Proto    => "tcp",
        Timeout  => 1
    );

    unless ($socket) {
        $this->_exit( "CAN'T CONNECT TO "
              . $iinfo->{'ip_addr_pc'} . ":"
              . $iinfo->{'tcp_port'} );
    }

    my $callerid = $this->agi->get_variable("CALLERID(num)");
    my $calleridlen = length($callerid);
    $callerid = substr($callerid,$calleridlen-10,10); 
    my $uline    = $this->agi->get_variable("PARKINGEXTEN");

    my $command = sprintf( "COF\r\n%s\r\n-\r\n%s", $callerid, $uline );

    if ( $socket->print($command) ) {
        $socket->flush;
    }
    else {
        $this->_exit( "CAN'T WRITE TO THE SOCKET "
              . $iinfo->{'ip_addr_pc'} . ":"
              . $iinfo->{'tcp_port'} );
    }
	$this->log("info","Sent ($command) to ".$iinfo->{'ip_addr_pc'}.":".$iinfo->{'tcp_port'});
    undef $socket;

}

sub process {
    my $this = shift;

    # Get member interface

    my $memberinterface = $this->_get_memberinterface;
    unless ( defined($memberinterface) ) {
        $this->_exit("CAN'T FIND MEMBERINTERFACE VALUE");
    }
    $this->log( "info", "Member interface: $memberinterface" );
    $this->agi->verbose( "Member interface: $memberinterface", 3 );

    $memberinterface =~ /^SIP\/(.*)$/;
    my $sip_name = $1;

	if ($this->{debug}) { 
		$this->log("info","sip_name=$sip_name");
	}

    # Get SIP ID + addr

    my ( $sip_id, $sip_addr ) = $this->_find_sipid_by_name($sip_name);
	if ($this->{debug}) {
		$this->log("info","sip_id=$sip_id, sip_addr = $sip_addr"); 
	}

    # GET Computer integration info
    my $iinfo = $this->_get_iinfo( $sip_id, $sip_addr );
	if ($this->{debug}){ 
		 $this->log("info",Dumper($iinfo)); 
	}

    # Check the type of integration and execute it to Computer .

    my $itype = $iinfo->{'integration_type'};

    # Currently we support only TaxiOffice mode.

    if ( $itype =~ /^TaxiOffice$/i ) {
	$this->log("info","Calling TaxiOffice open blank");
        $this->_open_blank_taxi_office($iinfo);
    }

    if ( $itype =~ /^TaxiNavigator$/i ) {
	$this->log("info","Calling TaxiNavigator open blank");
        $this->_open_blank_taxi_navigator($iinfo, $sip_name);
    }


}

1;

#===============================================================================

__END__

=head1 NAME

NetSDS-AGI-integration.pl

=head1 SYNOPSIS

NetSDS-AGI-integration.pl

=head1 DESCRIPTION

FIXME

=head1 EXAMPLES

FIXME

=head1 BUGS

Unknown.

=head1 TODO

Empty.

=head1 AUTHOR

Alex Radetsky <rad@rad.kiev.ua>

=cut

