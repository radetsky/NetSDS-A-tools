#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  NetSDS-route.pl
#
#        USAGE:  ./NetSDS-route.pl
#
#  DESCRIPTION:
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  11/30/11 21:22:55 EET
#     REVISION:  ---
#===============================================================================

use 5.8.0;
use strict;
use warnings;

Router->run(
    conf_file   => '/etc/NetSDS/asterisk-router.conf',
    daemon      => undef,
    use_pidfile => undef,
    verbose     => 1,
    debug       => 1,
    infinite    => undef
);

1;

package Router;

use base 'NetSDS::App';
use Data::Dumper;
use Asterisk::AGI; 


sub start {
    my $this = shift;

    unless ( defined( $ARGV[0] ) ) {
        $this->speak(
            "Usage: " . $this->name . ' ${CHANNEL} ' . '${EXTEN}' . "\n" );
        exit(-1);
    }
    unless ( defined( $ARGV[1] ) ) {
        $this->speak(
            "Usage: " . $this->name . ' ${CHANNEL} ' . '${EXTEN}' . "\n" );
        exit(-1);
    }

    $this->mk_accessors('dbh');
	$this->mk_accessors('agi'); 

	$this->agi(new Asterisk::AGI); 

}

sub _cutoff_channel {
    my $this    = shift;
    my $channel = shift;
    my ( $proto, $a ) = split( '/', $channel );
    my ( $peername, $channel_number ) = split( '-', $a );

    unless ( defined($proto) ) {
        $this->speak("Can't recognize protocol of this channel.");
        exit(-1);
    }

    unless ( defined($peername) ) {
        $this->speak("Can't recognize peername of this channel.");
        exit(-1);
    }

    unless ( defined($channel_number) ) {
        $this->speak("Can't recognize channel_number of this channel.");
        exit(-1);
    }

    return ( $proto, $peername, $channel_number );
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
        $this->agi->verbose("Database connected.",3);
    }
    return 1;
}

sub _get_permissions {
    my $this     = shift;
    my $peername = shift;
    my $exten    = shift;

    $this->dbh->begin_work or die $this->dbh->errstr;
    my $sth = $this->dbh->prepare("select * from routing.get_permission (?,?)");

    eval { my $rv = $sth->execute( $peername, $exten ); };
    if ($@) {
		# raised exception
        $this->log( "warning", $this->dbh->errstr );
        $this->agi->verbose( $this->dbh->errstr , 3 );
		$this->agi->exec("Hangup","17");
        exit(-1);
    }
    my $result = $sth->fetchrow_hashref;
    my $perm   = $result->{'get_permission'};
    if ( $perm > 0 ) {
        $this->agi->verbose("$peername has permissions to $exten",3);
        $this->log( "info", "$peername has permissions to $exten" );
    }
    else {
        $this->agi->verbose("$peername does not have the rights to $exten !",3);
        $this->log( "warning",
            "$peername does not have the rights to $exten !" );
        $this->dbh->rollback();
		$this->agi->exec("Hangup","17");
        exit(-1);
    }

    $this->dbh->commit();
    return;

}

sub _get_dial_route {
    my $this  = shift;
    my $exten = shift;
    my $try   = shift;

    $this->dbh->begin_work or die $this->dbh->errstr;
    my $sth =
      $this->dbh->prepare("select * from routing.get_dial_route3 (?,?)");
    eval { my $rv = $sth->execute( $exten, $try ); };
    if ($@) {
        $this->log( "warning", $this->dbh->errstr );
        $this->agi->verbose( $this->dbh->errstr,3 );
		$this->agi->exec("Hangup","17");
        exit(-1);
    }
    my $result = $sth->fetchrow_hashref;
    $this->dbh->commit();
    return $result;

}

sub process {
    my $this = shift;

    my $channel   = $ARGV[0];
    my $extension = $ARGV[1];

    # split the channel name

    ( $this->{proto}, $this->{peername}, $this->{channel_number} ) =
      $this->_cutoff_channel($channel);

    $this->{channel}   = $channel;
    $this->{extension} = $extension;

    # Connect to the database
    $this->_db_connect();

    # Get permission

    $this->_get_permissions( $this->{peername}, $this->{extension} );

    my $tgrp_first;

    # Get dial route
    for ( my $current_try = 1 ; $current_try <= 5 ; $current_try++ ) {

        my $result = $this->_get_dial_route( $this->{extension}, $current_try );
        unless ( defined($result) ) {
            $this->log( "warning",
                "SOMETHING WRONG. _get_dial_route returns undefined value." );
			$this->agi->verbose("SOMETHING WRONG!  _get_dial_route returns undefined value.",3); 
            die "SOMETHING WRONG!  _get_dial_route returns undefined value.";
        }

        my $dst_str  = $result->{'dst_str'};
        my $dst_type = $result->{'dst_type'};
        $current_try = $result->{'try'};
		$this->agi->verbose("dst_str=$dst_str,dst_type=$dst_type,try=$current_try",3);
		my $res = undef; 

		if ($dst_type eq "user") { 
			$this->agi->verbose("Dial SIP/$dst_str",3);
			$res = $this->agi->exec("Dial","SIP/$dst_str|120|rtT");
			$this->agi->verbose(Dumper($res),3); 
            $this->agi->verbose("DIALSTATUS=".$this->agi->get_variable("DIALSTATUS"),3);
		}
		if ($dst_type eq "peer") { 
			$this->agi->verbose("Dial SIP/$dst_str/$extension",3);
			$res = $this->agi->exec("Dial","SIP/$dst_str/$extension|120|rtT");
			$this->agi->verbose(Dumper($res),3);
			$this->agi->verbose("DIALSTATUS=".$this->agi->get_variable("DIALSTATUS"),3); 
		}

		if ($dst_type eq 'context') { 
			$this->agi->verbose("Goto context $dst_str/$extension");
			$res = $this->agi->exec("Goto","$dst_str|$extension|1");
			exit(0); 
		}

        if ( $dst_type eq 'tgrp' ) {
            unless ( defined($tgrp_first) ) {
                $tgrp_first = $dst_str;
				$this->agi->verbose("EXEC DIAL SIP/$dst_str/$extension");
				$res = $this->agi->exec("Dial","SIP/$dst_str/$extension|120|rtT");
                $this->agi->verbose(Dumper($res),3);
            	$this->agi->verbose("DIALSTATUS=".$this->agi->get_variable("DIALSTATUS"),3);
				next;
            }
			if ( $dst_str eq $tgrp_first ) {
            	$current_try = $current_try + 1;
				next;
       	 	}
			$res = $this->agi->exec("Dial","SIP/$dst_str/$extension|120|rtT");
			$this->agi->verbose(Dumper($res),3);
            $this->agi->verbose("DIALSTATUS=".$this->agi->get_variable("DIALSTATUS"),3);
		}
    }

    # dial
    # check for congestion
    # epic fail

}

#===============================================================================

__END__

=head1 NAME

NetSDS-route.pl

=head1 SYNOPSIS

NetSDS-route.pl

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

