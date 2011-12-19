#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  NetSDS-hangupd.pl
#
#        USAGE:  ./NetSDS-hangupd.pl
#
#  DESCRIPTION:  Hangup daemon. Listens AMI for hangup events and clears the integration.ulines table.
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  12/19/11 11:24:06 EET
#     REVISION:  ---
#===============================================================================

use 5.8.0;
use strict;
use warnings;

NetSDSHangupD->run(
    daemon      => undef,
    verbose     => 1,
    use_pidfile => 1,
    has_conf    => 1,
    conf_file   => "/etc/NetSDS/asterisk-router.conf",
    infinite    => undef
);

1;

package NetSDSHangupD;

use 5.8.0;
use strict;
use warnings;

use base qw(NetSDS::App);
use NetSDS::Asterisk::EventListener;

sub start {
    my $this = shift;

    $this->mk_accessors('el');
    $this->mk_accessors('dbh');

    $this->_db_connect();
    $this->_el_connect();

    $this->_clear_ulines();

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

    return 1;
}

sub _el_connect {
    my $this = shift;

    unless ( defined( $this->conf->{'el'}->{'host'} ) ) {
        $this->speak("Can't file el->host in configuration.");
        exit(-1);
    }
    unless ( defined( $this->conf->{'el'}->{'port'} ) ) {
        $this->speak("Can't file el->port in configuration.");
        exit(-1);
    }
    unless ( defined( $this->conf->{'el'}->{'username'} ) ) {
        $this->speak("Can't file el->username in configuration.");
        exit(-1);
    }
    unless ( defined( $this->conf->{'el'}->{'secret'} ) ) {
        $this->speak("Can't file el->secret in configuration.");
        exit(-1);
    }

    my $el_host     = $this->conf->{'el'}->{'host'};
    my $el_port     = $this->conf->{'el'}->{'port'};
    my $el_username = $this->conf->{'el'}->{'username'};
    my $el_secret   = $this->conf->{'el'}->{'secret'};

    my $event_listener = NetSDS::Asterisk::EventListener->new(
        host     => $el_host,
        port     => $el_port,
        username => $el_username,
        secret   => $el_secret
    );

    $event_listener->_connect();

    $this->el($event_listener);
}

sub _clear_ulines {
    my $this = shift;

}

sub _free_uline {
    my $this    = shift;
    my $channel = shift;

    $this->_begin;

    my $sth = $this->dbh->prepare(
        "select id from integration.ulines where channel=? for update");
    eval { my $rv = $sth->execute($channel); }
      if ($@)
    {
        $this->_exit( $this->dbh->errstr );
    }
    my $result = $sth->fetchrow_hashref;
    unless ( defined($result) ) {
        $this->log( "warning",
"XZ. Got hangup for channel $channel, but integration.ulines does not has it."
        );
        $this->dbh->rollback;
        return undef;
    }
    my $id = $result->{'id'};

    $sth = $this->dbh->prepare(
        "update integration.ulines set status='free' where id=?");
    eval { my $rv = $sth->execute($channel); }
    if ($@)
    {
        $this->_exit( $this->dbh->errstr );
    }
	$this->dbh->commit; 
	$this->log("info","$channel hangup witn intergration.ulines done");
	return 1; 
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

    $this->log( "error", $errstr );
    exit(-1);
}

sub process {
    my $this = shift;

    my $event   = undef;
    my $channel = undef;

    while (1) {
        $event = $this->el->_getEvent();
        unless ( defined( $event->{'Event'} ) ) {
            warn Dumper($event);
            next;
        }
        if ( $event->{'Event'} =~ /Hangup/i ) {
            $channel = $event->{'Channel'};
            $this->_free_uline($channel);
        }
    }

}

#===============================================================================

__END__

=head1 NAME

NetSDS-hangupd.pl

=head1 SYNOPSIS

NetSDS-hangupd.pl

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

