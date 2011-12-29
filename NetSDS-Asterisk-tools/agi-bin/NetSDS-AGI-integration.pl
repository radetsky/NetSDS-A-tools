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
    debug       => undef,
    infinite    => undef
);

1;

package Integration;

use base qw(NetSDS::App);
use Data::Dumper; 
use Asterisk::AGI; 

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
	my $this = shift; 
	my $errstr = shift; 
	
	$this->log("warning",$errstr);
	$this->agi->verbose($errstr,3); 
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
	my $this = shift; 
	my $sip_name = shift; 

	$this->_begin; 

	my $sth = $this->dbh->prepare ("select id,ipaddr from public.sip_peers where name=? order by id asc limit 1");
    eval { 
		my $rv = $sth->execute ($sip_name); 
	}; 
	if ($@) { 
		$this->_exit ( $this->dbh->errstr); 
	} 
	my $result = $sth->fetchrow_hashref; 
	unless ( defined ( $result ) ) { 
		$this->_exit("CAN'T FIND SIP/$sip_name");
	}

	my $id = $result->{'id'}; 
	my $ipaddr = $result->{'ipaddr'}; 
	
	$this->dbh->commit; 
	return ($id, $ipaddr); 

}

sub process { 
	my $this = shift; 

# Get member interface 

	my $memberinterface = $this->_get_memberinterface; 
	unless ( defined ( $memberinterface ) ) { 
		$this->_exit("CAN'T FIND MEMBERINTERFACE VALUE");
	}
	$this->log("info","Member interface: $memberinterface");
	$this->agi->verbose("Member interface: $memberinterface",3);

	$memberinterface =~ /^SIP\/(.*)$/; 
	my $sip_name = $1; 

# Get SIP ID + addr

	my ($sip_id, $sip_addr) = $this->_find_sipid_by_name ($sip_name); 
	
# GET Computer integration info 


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

