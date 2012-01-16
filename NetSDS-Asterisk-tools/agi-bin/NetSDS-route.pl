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

$| = 1;

Router->run(
    conf_file   => '/etc/NetSDS/asterisk-router.conf',
    daemon      => undef,
    use_pidfile => undef,
    verbose     => undef,
    debug       => 1,
    infinite    => undef
);

1;

package Router;

use base 'NetSDS::App';
use Data::Dumper;
use Asterisk::AGI;
use File::Path;
use NetSDS::Asterisk::Manager;

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

    $this->agi( new Asterisk::AGI );
    $this->agi->ReadParse();
    $this->agi->_debug(10);

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
        $this->agi->verbose( "Database connected.", 3 );
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
        $this->agi->verbose( $this->dbh->errstr, 3 );
        $this->agi->exec( "Hangup", "17" );
        exit(-1);
    }
    my $result = $sth->fetchrow_hashref;
    my $perm   = $result->{'get_permission'};
    if ( $perm > 0 ) {
        $this->agi->verbose( "$peername has permissions to $exten", 3 );
        $this->log( "info", "$peername has permissions to $exten" );
    }
    else {
        $this->agi->verbose( "$peername does not have the rights to $exten !",
            3 );
        $this->log( "warning",
            "$peername does not have the rights to $exten !" );
        $this->dbh->rollback();
        $this->agi->exec( "Hangup", "17" );
        exit(-1);
    }

    $this->dbh->commit();
    return;

}

sub _get_callerid {

    my $this     = shift;
    my $peername = shift;
    my $exten    = shift;

    $this->dbh->begin_work or die $this->dbh->errstr;
    my $sth = $this->dbh->prepare("select * from routing.get_callerid (?,?)");

    eval { my $rv = $sth->execute( $peername, $exten ); };
    if ($@) {

        # raised exception
        $this->log( "warning", $this->dbh->errstr );
        $this->agi->verbose( $this->dbh->errstr, 3 );
        $this->agi->exec( "Hangup", "17" );
        exit(-1);
    }
    my $result   = $sth->fetchrow_hashref;
    my $callerid = $result->{'get_callerid'};
    if ( $callerid ne '' ) {

        if ( $callerid =~ /^NAME$/i ) {
            $this->agi->verbose( "CHANGING NUM TO NAME.", 3 );
            $this->log( "info", "CHANGING NUM TO NAME." );
            $callerid = $this->agi->get_variable("CALLERID(name)");
        }

        $this->agi->verbose(
"$peername have to set CallerID to \'$callerid\' while calling to $exten",
            3
        );
        $this->log( "info",
"$peername have to set CallerID to \'$callerid\' while calling to $exten"
        );
        $this->agi->exec( "Set", "CALLERID(num)=$callerid" );
    }
    else {
        $this->agi->verbose( "$peername does not change own CallerID", 3 );
        $this->log( "info", "$peername does not change own CallerID" );
    }

    $this->dbh->commit();
    return;

}

sub _get_dial_route {
    my $this  = shift;
    my $peername = shift; 
	my $exten = shift;
    my $try   = shift;

    $this->dbh->begin_work or die $this->dbh->errstr;
    my $sth =
      $this->dbh->prepare("select * from routing.get_dial_route4 (?,?,?)");
    eval { my $rv = $sth->execute( $peername, $exten, $try ); };
    if ($@) {
        $this->log( "warning", $this->dbh->errstr );
        $this->agi->verbose( $this->dbh->errstr, 3 );
        $this->agi->exec( "Hangup", "17" );
        exit(-1);
    }
    my $result = $sth->fetchrow_hashref;
    $this->dbh->commit();
    return $result;

}

sub _mixmonitor_filename {
    my $this         = shift;
    my $cdr_start    = shift;
    my $callerid_num = shift;

    $cdr_start =~ /(\d{4})-(\d{1,2})-(\d{1,2}) (\d{1,2}):(\d{1,2}):(\d{1,2})/;

    my $year = $1;
    my $mon  = $2;
    my $day  = $3;
    my $hour = $4;
    my $min  = $5;
    my $sec  = $6;

    my $directory =
      sprintf( "/var/spool/asterisk/monitor/%s/%s/%s", $year, $mon, $day );

    my $filename = sprintf( "%s/%s/%s/%s%s%s-%s.wav",
        $year, $mon, $day, $hour, $min, $sec, $callerid_num );

    return ( $directory, $filename );

}

sub _init_mixmonitor {
    my $this = shift;

    my $cdr_start    = $this->agi->get_variable('CDR(start)');
    my $callerid_num = $this->agi->get_variable('CALLERID(num)');
    my ( $directory, $filename ) =
      $this->_mixmonitor_filename( $cdr_start, $callerid_num );

    mkpath($directory);

    if ( $this->{'exten'} > 0 ) {
        $this->agi->exec( "MixMonitor", "$filename" );
    }
    else {
        $this->agi->verbose(
            "This channel going to park. We do not Monitor it.");
    }

    $this->agi->verbose("CallerID(num)+CDR(start)=$callerid_num $cdr_start");
    $this->_init_uline( $callerid_num, $cdr_start );
    if ( ( $this->{'exten'} > 0 ) and ( $this->{'exten'} < 200 ) ) {
        $this->_add_next_recording( $callerid_num, $cdr_start,
            $this->{'exten'} );
    }

}

sub _begin {
    my $this = shift;

    eval { $this->dbh->begin_work; };

    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
}

sub _exit {
    my $this   = shift;
    my $errstr = shift;

    $this->log( "warning", $errstr );
    $this->agi->verbose( $errstr, 3 );
    $this->agi->exec( "Hangup", "17" );
    exit(-1);
}

sub _uline_by_channel {
    my $this    = shift;
    my $channel = shift;

    $this->_begin;

    my $sth = $this->dbh->prepare(
"select id from integration.ulines where channel_name = ? and status = 'busy'"
    );
    eval { my $rc = $sth->execute($channel); };

    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }

    my $result = $sth->fetchrow_hashref;
    if ( defined($result) ) {

        # There will be a dragons
        my $uline = $result->{'id'};
        $this->agi->verbose( "EXIST ULINE=$uline", 3 );
        $this->agi->set_variable( 'PARKINGEXTEN', "$uline" );
        eval { $this->dbh->commit; };
        if ($@) {
            $this->_exit( $this->dbh->errstr );
        }

        return $uline;
    }

    $this->dbh->rollback;
    return undef;
}

sub _uline_by_userfield_and_start {
    my $this      = shift;
    my $userfield = shift;
    my $cdr_start = shift;

    $this->_begin;
    my $sth = $this->dbh->prepare(
"select id from integration.ulines where id = ? and cdr_start = ? and status = 'busy'"
    );
    eval { my $rv = $sth->execute( $userfield, $cdr_start ); };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    my $result = $sth->fetchrow_hashref;
    unless ( defined($result) ) {
        $this->dbh->rollback;
        return undef;
    }
    my $uline = $result->{'id'};
    $this->agi->verbose( "EXIST USERFIELD ULINE=$uline", 3 );
    $this->agi->set_variable( 'PARKINGEXTEN', "$uline" );
    eval { $this->dbh->commit; };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    return $uline;
}

sub _add_new_recording {
    my $this         = shift;
    my $callerid_num = shift;
    my $cdr_start    = shift;
    my $uline        = shift;

    $this->_begin;
    my $sth = $this->dbh->prepare(
"insert into integration.recordings (uline_id,original_file) values (?,?) returning id"
    );
    my ( $directory, $original_file ) =
      $this->_mixmonitor_filename( $cdr_start, $callerid_num );
    eval { my $rv = $sth->execute( $uline, $original_file ); };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    my $result = $sth->fetchrow_hashref;
    my $new_id = $result->{'id'};
    $this->dbh->commit;

	$this->agi->verbose("Added new recording to uline $uline with $cdr_start and $callerid_num",3); 
	$this->log("info","Added new recording to uline $uline with $cdr_start and $callerid_num"); 

}

sub _add_next_recording {
    my $this         = shift;
    my $callerid_num = shift;
    my $cdr_start    = shift;
    my $uline        = shift;

    $this->agi->verbose(
        "Add next recording: '$callerid_num' '$cdr_start' '$uline'", 3 );
    $this->_begin;
    my $sth = $this->dbh->prepare(
"select id from integration.recordings where uline_id=? and next_record is NULL order by id desc limit 1"
    );
    eval { my $rv = $sth->execute($uline); };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    my $result = $sth->fetchrow_hashref;
    unless ( defined($result) ) {
        $this->_exit(
            "EXCEPTION: ADDING NEXT RECORD TO NULL. CALL THE LOCKSMAN.");
    }
    my $id = $result->{'id'};

    $sth = $this->dbh->prepare(
"insert into integration.recordings (uline_id,original_file,previous_record) values (?,?,?) returning id"
    );
    my ( $directory, $original_file ) =
      $this->_mixmonitor_filename( $cdr_start, $callerid_num );
    eval { my $rv = $sth->execute( $uline, $original_file, $id ); };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    $result = $sth->fetchrow_hashref;
    my $new_id = $result->{'id'};

    eval {
        $this->dbh->do(
            "update integration.recordings set next_record=$new_id where id=$id"
        );
    };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    $this->dbh->commit;
}

sub _update_uline_by_new_channel {
    my $this    = shift;
    my $uline   = shift;
    my $channel = shift;

    $this->_begin;

    my $sth = $this->dbh->prepare(
        "update integration.ulines set channel_name=? where id=?");
    eval { my $rv = $sth->execute( $channel, $uline ); };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    $this->dbh->commit;
    $this->agi->verbose( "ULINE $uline updated with $channel", 3 );
    $this->log( "info", "ULINE $uline updated with $channel" );
}

sub _init_uline {
    my $this         = shift;
    my $callerid_num = shift;
    my $cdr_start    = shift;
    my $uniqueid     = $this->agi->get_variable('CDR(uniqueid)');
    my $channel      = $this->{'channel'};

    if ( $this->{debug} ) {
        $this->log( "info", "_init_uline: $callerid_num $cdr_start" );
		$this->agi->verbose("_init_uline: $callerid_num $cdr_start", 3);  
    }

    # Try to find existing channel
    my $uline = $this->_uline_by_channel($channel);
    if ( defined ( $uline ) ) { 
		if ($this->{'exten'} > 0) { 
        	$this->_add_next_recording( $callerid_num, $cdr_start, $uline );
		} 
        return;
    }

    # Try to find by ULINE (userfield)
    my $userfield = $this->agi->get_variable("CDR(userfield)");
    $this->log( "info", "CDR(userfield)=" . $userfield );
    $uline = $this->_uline_by_userfield_and_start( $userfield, $cdr_start );
	if ( defined ( $uline ) ) { 
		$this->_update_uline_by_new_channel( $uline, $channel );
		if ( $this->{'exten'} > 0 ) { 
			$this->_add_next_recording( $callerid_num, $cdr_start, $uline );
		} 
		return; 
	} 

    # Create new uline
	$this->agi->verbose("Create new ULINE",3); 
	
	$this->_begin;

    my $sth =
      $this->dbh->prepare("select * from integration.get_free_uline();");

    eval { my $rv = $sth->execute; };
    if ($@) {

        # raised exception
        $this->log( "warning", $this->dbh->errstr );
        $this->agi->verbose( $this->dbh->errstr, 3 );
        $this->agi->exec( "Hangup", "17" );
        exit(-1);
    }

    my $result = $sth->fetchrow_hashref;
    $uline = $result->{'get_free_uline'};

    $this->agi->verbose( "ULINE=$uline", 3 );
    $this->agi->set_variable( "PARKINGEXTEN",   "$uline" );
    $this->agi->set_variable( "CDR(userfield)", "$uline" );
    $this->agi->set_variable( "ULINE",          "$uline" );
    $this->agi->exec( "Set", "CALLERID(name)=LINE $uline" );

    $sth = $this->dbh->prepare(
"update integration.ulines set status='busy',callerid_num=?,cdr_start=?,channel_name=?,uniqueid=? where id=?"
    );
    eval {
        my $rv =
          $sth->execute( $callerid_num, $cdr_start, $channel, $uniqueid,
            $uline );
    };

    if ($@) {
        $this->log( "warning", $this->dbh->errstr );
        $this->agi->verbose( $this->dbh->errstr, 3 );
        $this->agi->exec( "Hangup", "17" );
        exit(-1);
    }
    $this->dbh->commit;

    $this->_add_new_recording( $callerid_num, $cdr_start, $uline );

}

sub _manager_connect {
    my $this = shift;

    # connect
    unless ( defined( $this->conf->{'el'}->{'host'} ) ) {
        $this->_exit("Can't file el->host in configuration.");
    }
    unless ( defined( $this->conf->{'el'}->{'port'} ) ) {
        $this->_exit("Can't file el->port in configuration.");
    }
    unless ( defined( $this->conf->{'el'}->{'username'} ) ) {
        $this->_exit("Can't file el->username in configuration.");
    }
    unless ( defined( $this->conf->{'el'}->{'secret'} ) ) {
        $this->_exit("Can't file el->secret in configuration.");
    }

    my $el_host     = $this->conf->{'el'}->{'host'};
    my $el_port     = $this->conf->{'el'}->{'port'};
    my $el_username = $this->conf->{'el'}->{'username'};
    my $el_secret   = $this->conf->{'el'}->{'secret'};

    my $manager = NetSDS::Asterisk::Manager->new(
        host     => $el_host,
        port     => $el_port,
        username => $el_username,
        secret   => $el_secret,
        events   => 'Off'
    );

    my $connected = $manager->connect;
    unless ( defined($connected) ) {
        $this->_exit("Can't connect to the asterisk manager interface.");
    }
    return $manager;

}

sub _get_status {
    my $this    = shift;
    my $manager = shift;

    my $sent = $manager->sendcommand( 'Action' => 'Status' );
    unless ( defined($sent) ) {
        return undef;
    }
    my $reply = $manager->receive_answer();
    unless ( defined($reply) ) {
        return undef;
    }
    my $status = $reply->{'Response'};
    unless ( defined($status) ) {
        return undef;
    }
    if ( $status ne 'Success' ) {
        $this->seterror('Status: Response not success');
        return undef;
    }

    # reading from spcket while did not receive Event: StatusComplete
    my @replies;
    while (1) {
        $reply  = $manager->receive_answer();
        $status = $reply->{'Event'};
        if ( $status eq 'StatusComplete' ) {
            last;
        }
        push @replies, $reply;
    }
    return @replies;
}

sub process {
    my $this = shift;

    my $channel   = $ARGV[0];
    my $extension = $ARGV[1];

    $this->{'channel'} = $channel;
    $this->{'exten'}   = $extension;

    # split the channel name

    ( $this->{proto}, $this->{peername}, $this->{channel_number} ) =
      $this->_cutoff_channel($channel);

    $this->{channel}   = $channel;
    $this->{extension} = $extension;

		# Set timeout(absolute)
		$this->agi->set_variable("TIMEOUT(absolute)","3600"); 

    # Connect to the database
    $this->_db_connect();

    # Init MixMonitor
    $this->_init_mixmonitor();

    # Get permission
    $this->_get_permissions( $this->{peername}, $this->{extension} );

    # CallerID
    $this->_get_callerid( $this->{peername}, $this->{extension} );

    my $tgrp_first;

    # Get dial route
    for ( my $current_try = 1 ; $current_try <= 5 ; $current_try++ ) {

        my $result = $this->_get_dial_route( $this->{peername}, $this->{extension}, $current_try );
        unless ( defined($result) ) {
            $this->log( "warning",
                "SOMETHING WRONG. _get_dial_route returns undefined value." );
            $this->agi->verbose(
                "SOMETHING WRONG!  _get_dial_route returns undefined value.",
                3 );
            die "SOMETHING WRONG!  _get_dial_route returns undefined value.";
        }

        my $dst_str  = $result->{'dst_str'};
        my $dst_type = $result->{'dst_type'};
        $current_try = $result->{'try'};
        $this->agi->verbose(
            "dst_str=$dst_str,dst_type=$dst_type,try=$current_try", 3 );
        my $res = undef;

        if ( ( $dst_type eq "user" ) or ( $dst_type eq "lmask" ) )  {
            $this->agi->verbose( "Dial SIP/$dst_str", 3 );
            $res = $this->agi->exec( "Dial", "SIP/$dst_str|120|tT" );
            $this->agi->verbose( Dumper($res), 3 );
            $this->agi->verbose(
                "DIALSTATUS=" . $this->agi->get_variable("DIALSTATUS"), 3 );
        }
        if ( $dst_type eq "trunk" ) {
            $this->agi->verbose( "Dial SIP/$dst_str/$extension", 3 );
            $res =
              $this->agi->exec( "Dial", "SIP/$dst_str/$extension|120|tTg" );
            $this->agi->verbose( "result = $res", 3 );
            $this->agi->verbose(
                "DIALSTATUS=" . $this->agi->get_variable("DIALSTATUS"), 3 );
        }

        if ( $dst_type eq 'context' ) {
            $this->agi->verbose("Goto context $dst_str/$extension");
            $res = $this->agi->exec( "Goto", "$dst_str|$extension|1" );
            exit(0);
        }

        if ( $dst_type eq 'tgrp' ) {
            unless ( defined($tgrp_first) ) {
                $tgrp_first = $dst_str;
                $this->agi->verbose("EXEC DIAL SIP/$dst_str/$extension");
                $res =
                  $this->agi->exec( "Dial", "SIP/$dst_str/$extension|120|tT" );
                $this->agi->verbose( Dumper($res), 3 );
                $this->agi->verbose(
                    "DIALSTATUS=" . $this->agi->get_variable("DIALSTATUS"), 3 );
                next;
            }
            if ( $dst_str eq $tgrp_first ) {
                $current_try = $current_try + 1;
                next;
            }
            $res =
              $this->agi->exec( "Dial", "SIP/$dst_str/$extension|120|tT" );
            $this->agi->verbose( Dumper($res), 3 );
            $this->agi->verbose(
                "DIALSTATUS=" . $this->agi->get_variable("DIALSTATUS"), 3 );
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

