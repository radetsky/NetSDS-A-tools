#!/usr/bin/env perl

use 5.8.0;
use strict;
use warnings;

use lib '/opt/nibelite/lib/perl';

PeerMod->run( conf_file => '/etc/NetSDS/asterisk-router.conf' );

1;

package PeerMod;

=head1 NAME

peermod - peers and routing management tool

=head1 SYNOPSIS

	peermod.pl <ACTION> [options]
	
=head1 DESCRIPTION

An action must be specified when calling the tool. Each action has its own parameters set.
The parameters, if named, have the form of --parameter=value (use shell quoting if needed).
There can be also unnamed parameters, especially if they are mandatory for an action.

=head1 REFERENCE

=cut

use IO::Prompt;
use Nibelite::SQL;
use base 'Nibelite::App::CLI';

use constant peer_schema => {
	name           => 80,
	accountcode    => 20,
	amaflags       => 7,
	callgroup      => 10,
	callerid       => 80,
	canreinvite    => [ '', 'yes', 'no' ],    # yes/no
	directmedia    => [ '', 'yes', 'no' ],    # yes/no
	context        => 80,
	defaultip      => 15,
	dtmfmode       => 7,
	fromuser       => 80,
	fromdomain     => 80,
	host           => 31,                     # not null
	insecure       => 1048576,
	language       => 2,
	mailbox        => 50,
	md5secret      => 80,
	nat            => 5,
	permit         => 95,
	deny           => 95,
	mask           => 95,
	pickupgroup    => 10,
	port           => 5,
	qualify        => [ '', 'yes', 'no' ],    # yes/no
	restrictcid    => 1,
	rtptimeout     => 3,
	rtpholdtimeout => 3,
	secret         => 80,
	type           => 1048576,
	username       => 80,
	disallow       => 100,
	allow          => 100,
	musiconhold    => 100,
	regseconds     => 'bigint',
	ipaddr         => 15,
	regexten       => 80,
	cancallforward => [ '', 'yes', 'no' ],    # yes/no
	comment        => 80,
	"call-limit"   => 'smallint',
	lastms         => 5,
	regserver      => 100,
	fullcontact    => 80,
	useragent      => 20,
	defaultuser    => 10,
};

=head2 list - list peers

This action lists peer names, sorted alphabetically. Options can be specified
to narrow search if there are many of them:

=over

=item --name

Specify a name fragment to search against. Note that grep can be used too for this
kind of search.

=item --accountcode

=item --amaflags

=item --callgroup

=item --callerid

=item --context

=item --defaultip

=item --dtmfmode

=item --fromuser

=item --fromdomain

=item --host

=item --insecure

=item --language

=item --mailbox

=item --nat

=item --permit

=item --deny

=item --pickupgroup

=item --port

=item --restrictcid

=item --rtptimeout

=item --rtpholdtimeout 

=item --type

=item --username

=item --disallow

=item --allow

=item --musiconhold

=item --ipaddr

=item --regexten

=item --comment

=item --lastms

=item --regserver

=item --fullcontact

=item --useragent

=item --defaultuser

These are all character fields. They accept value fragments and are compared with LIKE
operator, e. g. "callerid LIKE '%value%'".

=item --canreinvite

=item --directmedia

=item --qualify

=item --cancallforward

These are yes/no/unspecified fields. The default value is "yes" (--cancallforward is the same
as --cancallforward=yes). "null" means search for records with the value explicitly not specified.

=item --regseconds

=item --call-limit

These fields are numeric. Exact search (--call-limit=10) and range search (--call-limit=10:30)
can be performed on them. --call-limit=10: means search all records with call-limit >= 10,
--call-limit=:10 means search all records with call-limit <= 10.

=item --direction

Show only peers who have permission to use this particular direction (routing.directions_list).

=item --trunkgroup

Show only peers assigned to this particular trunk group (routing.trunkgroups).

=back

=cut

sub list_query {
	my ( $this, $schema, $sql, %params ) = @_;
	foreach my $param ( sort ( keys(%params) ) ) {
		next unless exists( $schema->{$param} );
		my $norm_param = $param;
		$norm_param =~ s/-/_/g;
		my $cmp   = $schema->{$param};
		my $value = undef;
		if ( ref($cmp) eq 'ARRAY' ) {
			$value = $cmp->[0];
			if ( lc( $params{$param} ) eq 'null' ) {
				$sql->where( ["\"$param\" IS NULL"] );
			} else {
				my $v = $this->validate_enum( $param, $cmp, $params{$param} );
				if ( $v->{valid} ) {
					$sql->where( ["\"$param\" = :$norm_param"] );
					$sql->params( { $norm_param => $params{$param} } );
				}
			}
		} elsif ( ( $cmp eq "smallint" ) || ( $cmp eq "bigint" ) ) {
			my $cv         = $params{$param};
			my $validators = {
				smallint => 'validate_smallint',
				bigint   => 'validate_int',
			};
			my $validator = $validators->{$cmp};
			if ( $cv =~ /^(?:\d+|\d+:|\d+:\d+|:\d+)$/ ) {
				if ( $cv =~ /:/ ) {
					my @range = split /:/, $cv;
					my ( $from, $to );
					if ( scalar(@range) > 1 ) {
						$from = $range[0];
						$to   = $range[1];
					} else {
						$from = $range[0];
					}
					my $r = $this->$validator( $param, $cmp, $from );
					if ( $r->{valid} ) {
						$sql->where( ["\"$param\" >= :from_$norm_param"] );
						$sql->params( { "from_$norm_param" => $from } );
					}
					$r = $this->$validator( $param, $cmp, $to );
					if ( $r->{valid} ) {
						$sql->where( ["\"$param\" <= :to_$norm_param"] );
						$sql->params( { "to_$norm_param" => $to } );
					}
				} else {
					my $r = $this->$validator($cv);
					if ( $r->{valid} ) {
						$sql->where( ["\"$param\" = :$norm_param"] );
						$sql->params( { $norm_param => $cv } );
					}
				}
			} ## end if ( $cv =~ /^(?:\d+|\d+:|\d+:\d+|:\d+)$/)
		} ## end elsif ( ( $cmp eq "smallint"...))
		else {
			my $cv = "%" . $params{$param} . "%";
			$sql->where( ["\"$param\" ILIKE :$norm_param"] );
			$sql->params( { $norm_param => $cv } );
		}
	} ## end foreach my $param ( sort ( ...))
	return $sql;
} ## end sub list_query

sub action_list {
	my ( $this, %params ) = @_;
	my $sql = Nibelite::SQL->select(
		fields => {
			id   => 'sip_peers.id',
			name => 'sip_peers.name',
		},
		tables => { sip_peers => 'sip_peers' },
		order => [ [ 'name', 'ASC' ] ]
	);
	$sql = $this->list_query( $this->peer_schema, $sql, %params );
	if ( $params{direction} ) {
		$sql->joins(
			[
				"JOIN routing.permissions rp ON (rp.peer_id = sip_peers.id)",
				"JOIN routing.directions_list rdl ON (rdl.dlist_id = rp.direction_id)"
			]
		);
		$sql->where( ["rdl.dlist_name = :dlist_name"] );
		$sql->params( { dlist_name => $params{direction} } );
	}
	if ( $params{trunkgroup} ) {
		$sql->joins(
			[
				"JOIN routing.trunkgroup_items rti ON (rti.peer_id = sip_peers.id)",
				"JOIN routing.trunkgroups rt ON (rt.tgrp_id = rti.tgrp_item_group_id)"
			]
		);
		$sql->where( ["rt.tgrp_name = :tgrp_name"] );
		$sql->params( { tgrp_name => $params{trunkgroup} } );
	}
	my $result = $sql->find( $this->dbh );
	while ( my $row = $result->fetchrow_hashref() ) {
		print STDOUT join( "\t", $row->{id}, $row->{name} ), "\n";
	}
} ## end sub action_list

=head2 showpeer - show peer configuration

List peer's configuration in key = value pairs.
Note that secrets are also listed in their clear form.

Options:

=over

=item --permissions

List routing permissions for this peer, one direction per line.

=item --trunkgroups

List trunk groups for this peer, one group per line.

=item --callerid

List caller ID overrides, one item per line.

=back

=cut

sub get_peer_permissions {
	my ( $this, $peer_id ) = @_;
	my $sql    = "SELECT dl.dlist_id, dl.dlist_name FROM routing.directions_list dl JOIN routing.permissions rp ON (rp.direction_id = dl.dlist_id) WHERE rp.peer_id = ? ORDER BY dlist_name";
	my $result = $this->dbh->fetch_call( $sql, $peer_id );
	my $ret    = [];
	foreach my $row (@$result) {
		push @$ret, $row->{dlist_id} . "\t'" . $row->{dlist_name} . "'";
	}
	return $ret;
}

sub get_peer_trunkgroups {
	my ( $this, $peer_id ) = @_;
	my $sql    = "SELECT tg.tgrp_id, tg.tgrp_name FROM routing.trunkgroups tg JOIN routing.trunkgroup_items ti ON (ti.tgrp_item_group_id = tg.tgrp_id) WHERE ti.tgrp_item_peer_id = ? ORDER BY tgrp_name";
	my $result = $this->dbh->fetch_call( $sql, $peer_id );
	my $ret    = [];
	foreach my $row (@$result) {
		push @$ret, $row->{tgrp_id} . "\t'" . $row->{tgrp_name} . "'";
	}
	return $ret;
}

sub get_peer_callerids {
	my ( $this, $peer_id ) = @_;
	my $sql    = "SELECT ci.id, dl.dlist_name, ci.set_callerid FROM routing.callerid ci JOIN routing.directions_list dl ON (ci.direction_id = dl.dlist_id) WHERE ci.sip_id = ? ORDER BY set_callerid";
	my $result = $this->dbh->fetch_call( $sql, $peer_id );
	my $ret    = [];
	foreach my $row (@$result) {
		push @$ret, $row->{id} . "\t'" . $row->{dlist_name} . "'\t'" . $row->{set_callerid} . "'";
	}
	return $ret;
}

sub get_direction_id_by_name {
	my ($this, $dirname) = @_;
	my $sql = "SELECT dlist_id FROM routing.directions_list WHERE dlist_name = ?";
	my $res = $this->dbh->fetch_call($sql, $dirname);
	unless((ref($res) eq 'ARRAY') && ($res->[0])) {
		return undef;
	}
	return $res->[0]->{dlist_id};
}

=head2 add-permission <PEER-ID> <DIRECTION-NAME> - add a routing permission
=cut
sub action_add_permission {
	my ( $this, %params ) = @_;
	my $peer_id = ( defined( $params{__non_options__} ) and $params{__non_options__}->[0] ) || '';
	my $dirname = ( defined( $params{__non_options__} ) and $params{__non_options__}->[1] ) || '';
	unless ($peer_id) {
		$this->stderr("FATAL: peer ID not specified\n");
		$this->exitcode(1);
		return undef;
	}
	unless ($dirname) {
		$this->stderr("FATAL: direction not specified\n");
		$this->exitcode(1);
		return undef;
	}
	my $dir_id = $this->get_direction_id_by_name($dirname);
	unless ($dir_id) {
		$this->stderr("FATAL: direction $dirname not found\n");
		$this->exitcode(1);
		return undef;
	}
	my $sql = "INSERT INTO routing.permissions (peer_id, direction_id) VALUES (?, ?) RETURNING id";
	my $res = $this->dbh->fetch_call($sql, $peer_id, $dir_id);
	unless((ref($res) eq 'ARRAY') && ($res->[0])) {
		$this->exitcode(1);
		$this->stderr("ERROR: %s\n", $this->dbh->dbh->errstr);
		return undef;
	}
}

=head2 del-permission <PEER-ID> <DIRECTION-NAME> - delete a routing permission
=cut
sub action_del_permission {
	my ( $this, %params ) = @_;
	my $peer_id = ( defined( $params{__non_options__} ) and $params{__non_options__}->[0] ) || '';
	my $dirname = ( defined( $params{__non_options__} ) and $params{__non_options__}->[1] ) || '';
	unless ($peer_id) {
		$this->stderr("FATAL: peer ID not specified\n");
		$this->exitcode(1);
		return undef;
	}
	unless ($dirname) {
		$this->stderr("FATAL: direction not specified\n");
		$this->exitcode(1);
		return undef;
	}
	my $dir_id = $this->get_direction_id_by_name($dirname);
	unless ($dir_id) {
		$this->stderr("FATAL: direction $dirname not found\n");
		$this->exitcode(1);
		return undef;
	}
	my $sql = "DELETE FROM routing.permissions WHERE peer_id = ? AND direction_id = ? RETURNING id";
	my $res = $this->dbh->fetch_call($sql, $peer_id, $dir_id);
	unless((ref($res) eq 'ARRAY') && ($res->[0])) {
		$this->exitcode(1);
		$this->stderr("ERROR: %s\n", $this->dbh->dbh->errstr);
		return undef;
	}
}

sub get_trunkgroup_id_by_name {
	my ($this, $tgrp_name) = @_;
	my $sql = "SELECT tgrp_id FROM routing.trunkgroups WHERE tgrp_name = ?";
	my $res = $this->dbh->fetch_call($sql, $tgrp_name);
	unless((ref($res) eq 'ARRAY') && ($res->[0])) {
		return undef;
	}
	return $res->[0]->{tgrp_id};
}

=head2 assign-trunkgroup <PEER-ID> <trunkgroup-name>
=cut
sub action_assign_trunkgroup {
	my ($this, %params) = @_;
	my $peer_id = ( defined( $params{__non_options__} ) and $params{__non_options__}->[0] ) || '';
	my $tgname = ( defined( $params{__non_options__} ) and $params{__non_options__}->[1] ) || '';
	my $last = 0;
	$last = 1 if $params{'last'};
	unless ($peer_id) {
		$this->stderr("FATAL: peer ID not specified\n");
		$this->exitcode(1);
		return undef;
	}
	unless ($tgname) {
		$this->stderr("FATAL: trunkgroup not specified\n");
		$this->exitcode(1);
		return undef;
	}
	my $tg_id = $this->get_trunkgroup_id_by_name($tgname);
	unless ($tg_id) {
		$this->stderr("FATAL: trunkgroup $tgname not found\n");
		$this->exitcode(1);
		return undef;
	}
	my $sql = "INSERT INTO routing.trunkgroup_items (tgrp_item_peer_id, tgrp_item_group_id) VALUES (?, ?) RETURNING tgrp_item_id";
	my $res = $this->dbh->fetch_call($sql, $peer_id, $tg_id);
	unless((ref($res) eq 'ARRAY') && ($res->[0])) {
		$this->exitcode(1);
		$this->stderr("ERROR: %s\n", $this->dbh->dbh->errstr);
		return undef;
	}
}

=head2 unassign-trunkgroup <PEER-ID> <trunkgroup-name>
=cut
sub action_unassign_trunkgroup {
	my ($this, %params) = @_;
	my $peer_id = ( defined( $params{__non_options__} ) and $params{__non_options__}->[0] ) || '';
	my $tgname = ( defined( $params{__non_options__} ) and $params{__non_options__}->[1] ) || '';
	my $last = 0;
	$last = 1 if $params{'last'};
	unless ($peer_id) {
		$this->stderr("FATAL: peer ID not specified\n");
		$this->exitcode(1);
		return undef;
	}
	unless ($tgname) {
		$this->stderr("FATAL: trunkgroup not specified\n");
		$this->exitcode(1);
		return undef;
	}
	my $tg_id = $this->get_trunkgroup_id_by_name($tgname);
	unless ($tg_id) {
		$this->stderr("FATAL: trunkgroup $tgname not found\n");
		$this->exitcode(1);
		return undef;
	}
	my $sql = "DELETE FROM routing.trunkgroup_items WHERE tgrp_item_peer_id = ? AND tgrp_item_group_id = ? RETURNING tgrp_item_id";
	my $res = $this->dbh->fetch_call($sql, $peer_id, $tg_id);
	unless((ref($res) eq 'ARRAY') && ($res->[0])) {
		$this->exitcode(1);
		$this->stderr("ERROR: %s\n", $this->dbh->dbh->errstr);
		return undef;
	}
}

=head2 add-callerid <PEER-ID> <DIRECTION-NAME> <CALLERID> - add a caller ID override
=cut
sub action_add_callerid {
	my ( $this, %params ) = @_;
	my $peer_id = ( defined( $params{__non_options__} ) and $params{__non_options__}->[0] ) || '';
	my $dirname = ( defined( $params{__non_options__} ) and $params{__non_options__}->[1] ) || '';
	my $callerid = ( defined( $params{__non_options__} ) and $params{__non_options__}->[2] ) || '';
	unless ($peer_id) {
		$this->stderr("FATAL: peer ID not specified\n");
		$this->exitcode(1);
		return undef;
	}
	unless ($dirname) {
		$this->stderr("FATAL: direction not specified\n");
		$this->exitcode(1);
		return undef;
	}
	unless ($callerid) {
		$this->stderr("FATAL: caller ID not specified\n");
		$this->exitcode(1);
		return undef;
	}
	my $dir_id = $this->get_direction_id_by_name($dirname);
	unless ($dir_id) {
		$this->stderr("FATAL: direction $dirname not found\n");
		$this->exitcode(1);
		return undef;
	}
	my $sql = "INSERT INTO routing.callerid (sip_id, direction_id, callerid) VALUES (?, ?, ?) RETURNING id";
	my $res = $this->dbh->fetch_call($sql, $peer_id, $dir_id, $callerid);
	unless((ref($res) eq 'ARRAY') && ($res->[0])) {
		$this->exitcode(1);
		$this->stderr("ERROR: %s\n", $this->dbh->dbh->errstr);
		return undef;
	}
}

=head2 del-callerid <PEER-ID> <DIRECTION-NAME> - delete a caller ID override
=cut
sub action_del_callerid {
	my ( $this, %params ) = @_;
	my $peer_id = ( defined( $params{__non_options__} ) and $params{__non_options__}->[0] ) || '';
	my $dirname = ( defined( $params{__non_options__} ) and $params{__non_options__}->[1] ) || '';
	unless ($peer_id) {
		$this->stderr("FATAL: peer ID not specified\n");
		$this->exitcode(1);
		return undef;
	}
	unless ($dirname) {
		$this->stderr("FATAL: direction not specified\n");
		$this->exitcode(1);
		return undef;
	}
	my $dir_id = $this->get_direction_id_by_name($dirname);
	unless ($dir_id) {
		$this->stderr("FATAL: direction $dirname not found\n");
		$this->exitcode(1);
		return undef;
	}
	my $sql = "DELETE FROM routing.callerid WHERE sip_id = ? AND direction_id = ? RETURNING id";
	my $res = $this->dbh->fetch_call($sql, $peer_id, $dir_id);
	unless((ref($res) eq 'ARRAY') && ($res->[0])) {
		$this->exitcode(1);
		$this->stderr("ERROR: %s\n", $this->dbh->dbh->errstr);
		return undef;
	}
}

sub action_showpeer {
	my ( $this, %params ) = @_;
	my $peer_id = ( defined( $params{__non_options__} ) and $params{__non_options__}->[0] ) || '';
	unless ($peer_id) {
		$this->stderr("FATAL: peer ID not specified\n");
		$this->exitcode(1);
		return undef;
	}
	my $peer = $this->get_peer($peer_id);
	unless ( $peer || $peer->{old} || $peer->{old}->{id} ) {
		$this->stderr( "The record with id = %d was not found.\n", $peer_id );
		$this->exitcode(1);
		return undef;
	}
	unless ( $params{"permissions"} || $params{"trunkgroups"} || $params{"callerid"} ) {
		foreach my $field ( sort( keys( %{ $peer->{old} } ) ) ) {
			my $value = ( $peer->{old}->{$field} or "" );
			printf( "%s = %s\n", $field, $value );
		}
	}
	if ( $params{"permissions"} ) {
		my $permissions = $this->get_peer_permissions($peer_id);
		printf( "%s\n", join( "\n", @$permissions ) );
	} elsif ( $params{"trunkgroups"} ) {
		my $trunkgroups = $this->get_peer_trunkgroups($peer_id);
		printf( "%s\n", join( "\n", @$trunkgroups ) );
	} elsif ( $params{"callerid"} ) {
		my $callerids = $this->get_peer_callerids($peer_id);
		printf( "%s\n", join( "\n", @$callerids ) );
	}
} ## end sub action_showpeer

sub get_direction {
	my ( $this, $dirname ) = @_;
	my $sql = "SELECT dr.dr_id, dr.dr_prefix, dr.dr_prio FROM routing.directions dr JOIN routing.directions_list dl ON (dl.dlist_id = dr.dr_list_item) WHERE dl.dlist_name = ? ORDER BY dr_prio ASC";
	my $results = $this->dbh->fetch_call( $sql, $dirname );
	return $results;
}

=head2 showdir - show direction's properties (defined prefixes and priorities)

The properties are tabulated, one record per line:

	id	prefix	priority


=cut

sub action_showdir {
	my ( $this, %params ) = @_;
	my $dirname = ( defined( $params{__non_options__} ) and $params{__non_options__}->[0] ) || '';
	unless ($dirname) {
		$this->stderr("FATAL: direction not specified\n");
		$this->exitcode(1);
		return undef;
	}
	my $direction = $this->get_direction($dirname) || [];
	foreach my $row (@$direction) {
		printf( "%s\n", join( "\t", $row->{dr_id}, $row->{dr_prefix}, $row->{dr_prio} ) );
	}
}

=head2 adddir - add a prefix-priority pair to a direction

=head3 Synopsis

	peermod.pl adddir [--create] <direction> <prefix> <priority>
	
If --create is specified, nonexistent direction will be created.

=cut

sub action_adddir {
	my ( $this, %params ) = @_;
	my $dirname = ( defined( $params{__non_options__} ) and $params{__non_options__}->[0] ) || '';
	my $prefix  = ( defined( $params{__non_options__} ) and $params{__non_options__}->[1] ) || '';
	my $prio    = ( defined( $params{__non_options__} ) and $params{__non_options__}->[2] ) || '';
	unless ($dirname) {
		$this->stderr("FATAL: direction not specified\n");
		$this->exitcode(1);
		return undef;
	}
	unless ($prefix) {
		$this->stderr("FATAL: prefix not specified\n");
		$this->exitcode(1);
		return undef;
	}
	unless ($prio) {
		$this->stderr("FATAL: priority not specified\n");
		$this->exitcode(1);
		return undef;
	}
	my $dir = $this->dbh->fetch_call( "SELECT dl.dlist_id FROM routing.directions_list dl WHERE dlist_name = ?", $dirname );
	my $dir_id;
	unless ( ref($dir) && scalar(@$dir) ) {
		unless ( $params{'create'} ) {
			$this->stderr( "'%s' is not in the directions list. Use --create to create missing items.\n", $dirname );
			$this->exitcode(1);
			return undef;
		}
		$dir = $this->dbh->fetch_call( "INSERT INTO routing.directions_list (dlist_name) VALUES (?) RETURNING dlist_id", $dirname );
	}
	$dir_id = $dir->[0]->{dlist_id};
	my $tmp = $this->dbh->fetch_call( "SELECT COUNT(*) AS c FROM routing.directions WHERE dr_list_item = ? AND dr_prefix = ? AND dr_prio = ?", $dir_id, $prefix, $prio );
	if ( ( ref($tmp) eq 'ARRAY' ) && scalar($tmp) && $tmp->[0]->{c} ) {
		$this->stderr( "A record with direction '%s', prefix '%s' and priority '%s' already exists.\n", $dirname, $prefix, $prio );
		$this->exitcode(1);
		return undef;
	}
	$this->dbh->call( "INSERT INTO routing.directions (dr_list_item, dr_prefix, dr_prio) VALUES (?, ?, ?)", $dir_id, $prefix, $prio );
} ## end sub action_adddir

=head2 deldir - remove a prefix-priority pair from a direction

=head3 Synopsis

	peermod.pl adddir [--create] <direction> <prefix> <priority>
	
=cut

sub action_deldir {
	my ( $this, %params ) = @_;
	my $dirname = ( defined( $params{__non_options__} ) and $params{__non_options__}->[0] ) || '';
	my $prefix  = ( defined( $params{__non_options__} ) and $params{__non_options__}->[1] ) || '';
	my $prio    = ( defined( $params{__non_options__} ) and $params{__non_options__}->[2] ) || '';
	unless ($dirname) {
		$this->stderr("FATAL: direction not specified\n");
		$this->exitcode(1);
		return undef;
	}
	unless ($prefix) {
		$this->stderr("FATAL: prefix not specified\n");
		$this->exitcode(1);
		return undef;
	}
	unless ($prio) {
		$this->stderr("FATAL: priority not specified\n");
		$this->exitcode(1);
		return undef;
	}
	my $dir = $this->dbh->fetch_call( "SELECT dl.dlist_id FROM routing.directions_list dl WHERE dlist_name = ?", $dirname );
	my $dir_id;
	unless ( ref($dir) && scalar(@$dir) ) {
		$this->stderr( "'%s' is not in the directions list.\n", $dirname );
		$this->exitcode(1);
		return undef;
	}
	$dir_id = $dir->[0]->{dlist_id};
	my $tmp = $this->dbh->fetch_call( "SELECT COUNT(*) AS c FROM routing.directions WHERE dr_list_item = ? AND dr_prefix = ? AND dr_prio = ?", $dir_id, $prefix, $prio );
	if ( ( ref($tmp) eq 'ARRAY' ) && scalar($tmp) && !$tmp->[0]->{c} ) {
		$this->stderr( "A record with direction '%s', prefix '%s' and priority '%s' does not exist.\n", $dirname, $prefix, $prio );
		$this->exitcode(1);
		return undef;
	}
	$this->dbh->call( "DELETE FROM routing.directions WHERE dr_list_item=? AND dr_prefix=? AND dr_prio=?", $dir_id, $prefix, $prio );
} ## end sub action_deldir

sub peer_validate {
	my ( $this, $peer, $params ) = @_;
	my $errors = {};
	my $fields = $this->peer_schema();
	foreach my $param ( keys %$params ) {
		if ( exists( $fields->{$param} ) ) {
			my $validation_result;
			if ( ref( $fields->{$param} ) eq 'ARRAY' ) {
				$validation_result = $this->validate_enum( $param, $fields->{$param}, $params->{$param} );
			} elsif ( $fields->{$param} eq 'bigint' ) {
				$validation_result = $this->validate_int( $param, $fields->{$param}, $params->{$param} );
			} elsif ( $fields->{$param} eq 'smallint' ) {
				$validation_result = $this->validate_smallint( $param, $fields->{$param}, $params->{$param} );
			} else {
				$validation_result = $this->validate_varchar( $param, $fields->{$param}, $params->{$param} );
			}
			unless ( $validation_result->{valid} ) {
				$errors->{$param} = $validation_result;
			}
			if ( ( !$validation_result->{severity} ) || ( $validation_result->{severity} ne 'fatal' ) ) {
				$peer->{'new'}->{$param} = $validation_result->{transformed};
			}
		}
	} ## end foreach my $param ( keys %$params)
	return $peer, $errors;
} ## end sub peer_validate

=head2 mod - modify peer's record

=head3 Synopsis

	peermod.pl mod <ID> [options]
	
=head3 Description

The ID is the numeric ID of a peer. It can be obtained by first issuing the I<list>
action. It is a mandatory parameter.

All other parameters correspond to the fields of the I<sip_peers> table, and are
specified as in the I<list> command, except that instead of value fragments, full
values need to be specified.

There are limits on some character fields, and values longer than that limit would
be clipped. Unless --force parameter is specified, the action will not execute and
a warning will be issued.

A summary of changes will be presented.

=cut

sub action_mod {
	my ( $this, %params ) = @_;
	my $peer_id = ( defined( $params{__non_options__} ) and $params{__non_options__}->[0] ) || '';
	unless ($peer_id) {
		$this->stderr("FATAL: peer ID not specified\n");
		$this->exitcode(1);
		return undef;
	}
	my $peer = $this->get_peer($peer_id);
	unless ( $peer || $peer->{old} || $peer->{old}->{id} ) {
		$this->stderr( "The record with id = %d was not found.\n", $peer_id );
		$this->exitcode(1);
		return undef;
	}
	my $errors;
	( $peer, $errors ) = $this->peer_validate( $peer, \%params );
	foreach my $res ( keys %$errors ) {
		if ( ( $errors->{$res}->{severity} eq 'fatal' ) || ( !$errors->{$res}->{valid} && !$params{force} ) ) {
			$this->dump_errors($errors);
			$this->stderr("Fatal errors encountered, cannot continue.\n");
			$this->exitcode(1);
			return undef;
		}
	}
	$this->dump_peer_changes($peer);
	my $id = $this->save_peer($peer);
	unless ($id) {
		my $err = $this->dbh->dbh->errstr;
		if ($err) {
			$this->stderr( "An error occured while saving peer (%s)\n", $err );
		}
		$this->stderr("There was nothing to modify\n");
		$this->exitcode(1);
	}
} ## end sub action_mod

=head2 create - create a peer's record

=head3 Synopsis

	peermod.pl create [options]
	peermod.pl add [options]
	
=head3 Description

All parameters correspond to the fields of the I<sip_peers> table, and are
specified as in the I<list> command, except that instead of value fragments, full
values need to be specified.

The --name parameter is mandatory.

There are limits on some character fields, and values longer than that limit would
be clipped. Unless --force parameter is specified, the action will not execute and
a warning will be issued.

The id of a newly-created record will be returned if everything is okay.

=cut

sub action_create {
	my ( $this, %params ) = @_;
	my $peer = { old => {}, 'new' => {} };
	my $errors;
	( $peer, $errors ) = $this->peer_validate( $peer, \%params );
	foreach my $res ( keys %$errors ) {
		if ( ( $errors->{$res}->{severity} eq 'fatal' ) || ( !$errors->{$res}->{valid} && !$params{force} ) ) {
			$this->dump_errors($errors);
			$this->stderr("Fatal errors encountered, cannot continue.\n");
			$this->exitcode(1);
			return undef;
		}
	}
	my $id = $this->save_peer($peer);
	$this->stderr( "Created record, id=%d\n", $id );
	unless ($id) {
		my $err = $this->dbh->dbh->errstr;
		if ($err) {
			$this->stderr( "An error occured while saving peer (%s)\n", $err );
		}
		$this->stderr("There was nothing to modify\n");
		$this->exitcode(1);
	}
} ## end sub action_create

sub dump_errors {
	my ( $this, $errors ) = @_;
	foreach my $error ( keys %$errors ) {
		$this->stderr( "%s (%s): %s\n", $error, $errors->{$error}->{severity}, $errors->{$error}->{message} );
	}
}

sub dump_peer_changes {
	my ( $this, $peer ) = @_;
	foreach my $field ( keys %{ $peer->{'new'} } ) {
		if ( !defined( $peer->{old}->{$field} ) || ( $peer->{old}->{$field} ne $peer->{'new'}->{$field} ) ) {
			if ( ( $field eq 'md5secret' ) || ( $field eq 'secret' ) ) {
				$this->stderr("$field: ***** -> ***** ;-)\n");
			} else {
				$this->stderr( "%s: %s -> %s\n", $field, $peer->{old}->{$field}, $peer->{'new'}->{$field} );
			}
		}
	}
}

#
# Validators
#

sub stderr {
	my ( $this, $fmt, @params ) = @_;
	unless (@params) {
		@params = ( '', );
	}
	$this->speak( sprintf( $fmt, @params ) );
}

sub validate_varchar {
	my ( $this, $fieldname, $param, $value ) = @_;
	unless ( length($value) <= $param ) {
		my $transformed = substr( $value, 0, $param );
		return {
			valid       => 0,
			severity    => 'forceable',
			transformed => $transformed,
			message     => "The value of parameter '$fieldname' is too long. It would be clipped to '$transformed' if --force was used."
		};
	}
	return {
		valid       => 1,
		transformed => $value,
		message     => "The parameter '$fieldname' validates OK."
	};
}

sub validate_smallint {
	my ( $this, $fieldname, $param, $value ) = @_;
	my $r = $this->validate_int( $fieldname, $param, $value + 0 );
	if ( $r->{valid} ) {
		if ( ( $r->{transformed} < -32768 ) || ( $r->{transformed} > 32767 ) ) {
			return {
				valid       => 0,
				severity    => 'fatal',
				transformed => '0',
				message     => "The value of '$fieldname', '$value', does not fit the SMALLINT range."
			};
		} else {
			return {
				valid       => 1,
				severity    => 'ok',
				transformed => $value,
				message     => "The parameter '$fieldname' validates OK."
			};
		}
	} else {
		return $r;
	}
} ## end sub validate_smallint

sub validate_int {
	my ( $this, $fieldname, $param, $value ) = @_;
	unless ( defined($value) && ( $value =~ /^[+-]?\d+$/ ) ) {
		$value = 'undef' if !defined($value);
		return {
			valid       => 0,
			severity    => 'fatal',
			transformed => '0',
			message     => "The value of parameter '$fieldname', '$value', does not validate as integer."
		};
	}
	return {
		valid       => 1,
		severity    => 'ok',
		transformed => $value,
		message     => "The parameter '$fieldname' validates OK."
	};
}

sub validate_enum {
	my ( $this, $fieldname, $param, $value ) = @_;
	my $check = lc($value);
	my %enum = map { lc($_) => 1 } @$param;
	unless ( exists( $enum{ lc($value) } ) ) {
		return {
			valid       => 0,
			severity    => 'fatal',
			transformed => '',
			message     => "The value of parameter '$fieldname' must be one of: " . join( ', ', @$param )
		};
	}
	return {
		valid       => 1,
		severity    => 'ok',
		transformed => $value,
		message     => "The parameter '$fieldname' validates OK."
	};
}

#
# Get peer and save peer
#

sub get_peer {
	my ( $this, $key ) = @_;
	my $sql = "SELECT * FROM public.sip_peers WHERE id = ?";
	my $res = $this->dbh->fetch_call( $sql, $key );
	unless ( ( ref($res) eq 'ARRAY' ) && ( scalar(@$res) ) ) {
		return undef;
	}
	return { 'old' => $res->[0], 'new' => {} };
}

sub get_peer_update_query {
	my ( $this, $peer ) = @_;
	if ( !scalar( keys %{ $peer->{'new'} } ) ) {
		return '';
	} elsif ( !$peer->{old}->{id} ) {
		return '';
	}
	my @bind      = ();
	my @fieldsbuf = ();
	my $field_map = {
		md5secret => 'MD5(?)',
	};
	foreach my $field ( sort( keys %{ $peer->{'new'} } ) ) {
		my $expr = '?';
		if ( exists( $field_map->{$field} ) ) {
			$expr = $field_map->{$field};
		}
		push @fieldsbuf, "\"$field\" = $expr";
		push @bind,      $peer->{'new'}->{$field};
	}
	push @bind, $peer->{old}->{id};
	my $up = "UPDATE public.sip_peers SET " . join( ', ', @fieldsbuf ) . " WHERE id = ? RETURNING id";
	return $up, @bind;
} ## end sub get_peer_update_query

sub get_peer_insert_query {
	my ( $this, $peer ) = @_;
	my @bind      = ();
	my @fieldsbuf = ();
	my @valuesbuf = ();
	my $field_map = {
		md5secret => 'MD5(?)',
	};
	if ( !scalar( keys %{ $peer->{'new'} } ) ) {
		return '';
	}
	foreach my $field ( sort( keys %{ $peer->{'new'} } ) ) {
		my $expr = '?';
		if ( exists( $field_map->{$field} ) ) {
			$expr = $field_map->{$field};
		}
		push @fieldsbuf, "\"$field\"";
		push @valuesbuf, $expr;
		push @bind,      $peer->{'new'}->{$field};
	}
	my $up = "INSERT INTO public.sip_peers (" . join( ', ', @fieldsbuf ) . ") VALUES (" . join( ', ', @valuesbuf ) . ") RETURNING id";
	return $up, @bind;
} ## end sub get_peer_insert_query

sub save_peer {
	my ( $this, $peer ) = @_;
	my ( $query, @bind );
	if ( exists( $peer->{old}->{id} ) && ( $peer->{old}->{id} ) ) {
		# update
		( $query, @bind ) = $this->get_peer_update_query($peer);
	} else {
		# create
		( $query, @bind ) = $this->get_peer_insert_query($peer);
	}
	unless ($query) {
		return undef;
	}
	my $row = $this->dbh->fetch_call( $query, @bind );
	return $row->[0]->{id};
}

=head2 passwd - interactively change peer's password

=head3 Synopsis

	peermod.pl passwd <ID>

=head3 Description

The ID is the numeric ID of the peer. You will be asked to enter and re-enter the
password. The contents of the password is not shown.

If you need to set a password in a batch job, use

	peermod.pl mod <ID> --secret='New secret'

=cut

sub action_passwd {
	my ( $this, %params ) = @_;
	my $peer_id = ( defined( $params{__non_options__} ) and $params{__non_options__}->[0] ) || '';
	unless ($peer_id) {
		$this->stderr("FATAL: peer ID not specified\n");
		$this->exitcode(1);
		return undef;
	}
	my $peer = $this->get_peer($peer_id);
	unless ( $peer || $peer->{old} || $peer->{old}->{id} ) {
		$this->stderr( "The record with id = %d was not found.\n", $peer_id );
		$this->exitcode(1);
		return undef;
	}
	my ( $pw0, $pw1 );
	while ( !( $pw0 && $pw1 ) || ( $pw0 ne $pw1 ) ) {
		$pw0 = prompt( "Enter password: ", -e => "*" );
		if ( $pw0 eq '' ) {
			$this->speak("The password cannot be empty.");
			next;
		}
		$pw1 = prompt( "Retype password: ", -e => "*" );
		unless ( $pw0 eq $pw1 ) {
			$this->speak("The passwords do not match.");
			$this->exitcode(1);
			return undef;
		}
	}
	return $this->action_mod( __non_options__ => [$peer_id], secret => $pw0 );
} ## end sub action_passwd

sub action_add {
	my ( $this, %params ) = @_;
	return $this->action_create(%params);
}

=head2 del - delete a peer record

=head3 Synopsis

	peermod.pl del <ID>

=head3 Description

The ID is the numeric ID of the peer.

=cut

sub action_del {
	my ( $this, %params ) = @_;
	my $peer_id = ( defined( $params{__non_options__} ) and $params{__non_options__}->[0] ) || '';
	unless ($peer_id) {
		$this->stderr("FATAL: peer ID not specified\n");
		$this->exitcode(1);
		return undef;
	}
	my $peer = $this->get_peer($peer_id);
	unless ( $peer || $peer->{old} || $peer->{old}->{id} ) {
		$this->stderr( "The record with id = %d was not found.\n", $peer_id );
		$this->exitcode(1);
		return undef;
	}
	unless ( $params{force} ) {
		my $p = 'x';
		while ( $p !~ /^(?:[yn]|)$/i ) {
			$p = prompt("Really delete record (ID=$peer_id)? [y/N] ");
		}
		if ( $p !~ /^y/i ) {
			$this->exitcode(2);
			$this->stderr("Cancelled on user request.\n");
			return undef;
		}
	}
	$this->dbh->call( "DELETE FROM public.sip_peers WHERE id = ?", $peer_id );
} ## end sub action_del

#
# Testing
#

=head2 selftest - run a self-test

=head3 Description

Normally, you won't ever need to call this.

=cut

sub action_selftest {
	my ( $this, %params ) = @_;
	no strict 'refs';
	my $p = "PeerMod::";
	foreach my $sub_name ( keys %{$p} ) {
		if ( $sub_name =~ /^test_/ ) {
			$this->$sub_name();
		}
	}
}

sub ok {
	my ( $this, $expr, $diag, $message ) = @_;
	if ($expr) {
		$this->stderr( "%s: OK\n", $diag );
	} else {
		$this->stderr( "%s: FAIL (%s)\n", $diag, $message );
	}
}

sub test_validate_integer {
	my ($this) = @_;
	my $r;
	$r = $this->validate_int( 'testfield', 'bigint', -48000 );
	$this->ok( $r->{valid}, 'Testing int (-48000)', 'must pass but fails' );
	$r = $this->validate_int( 'testfield', 'bigint', '+4868756437865783465874365784367856438756348765873465236875628736587234' );
	$this->ok( $r->{valid}, 'Testing int (+4868756437865783465874365784367856438756348765873465236875628736587234)', 'must pass but fails' );
	$r = $this->validate_int( 'testfield', 'bigint', -22 );
	$this->ok( $r->{valid}, 'Testing int (-22)', 'must pass but fails' );
	$this->ok( $r->{transformed} eq -22, 'Testing valid value for int', 'transformed must be filled for valid values' );
	$r = $this->validate_int( 'testfield', 'bigint', 48000 );
	$this->ok( $r->{valid}, 'Testing int (48000)', 'must pass but fails' );
	$r = $this->validate_int( 'testfield', 'bigint', 480.01 );
	$this->ok( !$r->{valid}, 'Testing invalid value for int', 'must fail but passes' );
	$this->ok( $r->{severity} eq 'fatal', 'Testing invalid value for smallint', 'severity must be fatal' );
	$r = $this->validate_int( 'testfield', 'bigint', '480.01ekrhkjqhrukeh' );
	$this->ok( !$r->{valid}, 'Testing invalid value for int', 'must fail but passes' );
	$this->ok( $r->{severity} eq 'fatal', 'Testing invalid value for smallint', 'severity must be fatal' );
}

sub test_validate_smallint {
	my ($this) = @_;
	my $r;
	$r = $this->validate_smallint( 'testfield', 'smallint', -48000 );
	$this->ok( !$r->{valid}, 'Testing too small value for smallint', 'must fail but passes' );
	$this->ok( $r->{severity} eq 'fatal', 'Testing too small value for smallint', 'severity must be fatal' );
	$r = $this->validate_smallint( 'testfield', 'smallint', -22 );
	$this->ok( $r->{valid}, 'Testing valid value for smallint', 'must pass but fails' );
	$this->ok( $r->{transformed} eq -22, 'Testing valid value for smallint', 'transformed must be filled for valid values' );
	$r = $this->validate_smallint( 'testfield', 'smallint', 48000 );
	$this->ok( !$r->{valid}, 'Testing too large value for smallint', 'must fail but passes' );
	$this->ok( $r->{severity} eq 'fatal', 'Testing too large value for smallint', 'severity must be fatal' );
	$r = $this->validate_smallint( 'testfield', 'smallint', 480.01 );
	$this->ok( !$r->{valid}, 'Testing invalid value for smallint', 'must fail but passes' );
	$this->ok( $r->{severity} eq 'fatal', 'Testing invalid value for smallint', 'severity must be fatal' );
}

sub test_validate_enum {
	my ($this) = @_;
	my $r;
	$r = $this->validate_enum( 'testfield', [ 'foo', 'bar' ], 'baz' );
	$this->ok( !$r->{valid}, 'Testing enum (out of range)', 'must fail but passes' );
	$r = $this->validate_enum( 'testfield', [ 'foo', 'bar' ], 'Bar' );
	$this->ok( $r->{valid}, 'Testing enum (case sensitivity)', 'must pass but fails' );
	$r = $this->validate_enum( 'testfield', [ 'foo', 'bar' ], 'bar' );
	$this->ok( $r->{valid}, 'Testing enum (exact match)', 'must pass but fails' );
}

sub test_validate_char {
	my ($this) = @_;
	my $r;
	$r = $this->validate_varchar( 'testfield', '10', 'baz' );
	$this->ok( $r->{valid}, 'Testing varchar (in range)', 'must pass but fails' );
	$this->ok( $r->{transformed} eq 'baz', 'Testing varchar (clipping)', 'clips' );
	$r = $this->validate_varchar( 'testfield', '5', 'blablablabla' );
	$this->ok( !$r->{valid}, 'Testing varchar (out of range)', 'must fail but passes' );
	$this->ok( $r->{transformed} eq 'blabl', 'Testing varchar (clipping)', 'does not clip' );
}

sub test_update_peer {
	my ($this) = @_;
	my $peer = {
		old => {

		},
		'new' => {

		}
	};
	$this->ok( $this->get_peer_update_query($peer) eq '', 'Testing update query, empty record', 'must be empty' );
	$peer->{old}->{id} = 10;
	$this->ok( $this->get_peer_update_query($peer) eq '', 'Testing update query, empty record', 'must be empty' );
	$peer->{old}->{username} = 'foobar';
	$this->ok( $this->get_peer_update_query($peer) eq '', 'Testing update query, empty new record', 'must be empty' );
	$peer->{'new'}->{username}  = 'johnsmith';
	$peer->{'new'}->{md5secret} = 'johnsmith:asterisk:d4rks3cr3t';
	my ( $r, @bind ) = $this->get_peer_update_query($peer);
	$this->ok( $r       eq 'UPDATE public.sip_peers SET "md5secret" = MD5(?), "username" = ? WHERE id = ? RETURNING id', 'Update query: single field',         $r );
	$this->ok( $bind[0] eq 'johnsmith:asterisk:d4rks3cr3t',                                                              'Update query: bind params',          $bind[0] );
	$this->ok( $bind[1] eq 'johnsmith',                                                                                  'Update query: bind params',          $bind[1] );
	$this->ok( $bind[2] eq '10',                                                                                         'Update query: ID as last parameter', $bind[2] );
} ## end sub test_update_peer

sub test_insert_peer {
	my ($this) = @_;
	my $peer = {
		old => {

		},
		'new' => {

		}
	};
	$this->ok( $this->get_peer_insert_query($peer) eq '', 'Testing insert query, empty record', 'must be empty' );
	$peer->{old}->{id} = 10;
	$this->ok( $this->get_peer_insert_query($peer) eq '', 'Testing insert query, empty record', 'must be empty' );
	$peer->{old}->{username} = 'foobar';
	$this->ok( $this->get_peer_insert_query($peer) eq '', 'Testing insert query, empty new record', 'must be empty' );
	$peer->{'new'}->{username}  = 'johnsmith';
	$peer->{'new'}->{md5secret} = 'johnsmith:asterisk:d4rks3cr3t';
	my ( $r, @bind ) = $this->get_peer_insert_query($peer);
	$this->ok( $r       eq 'INSERT INTO public.sip_peers ("md5secret", "username") VALUES (MD5(?), ?) RETURNING id', 'Insert query: single field', $r );
	$this->ok( $bind[0] eq 'johnsmith:asterisk:d4rks3cr3t',                                                          'Update query: bind params',  $bind[0] );
	$this->ok( $bind[1] eq 'johnsmith',                                                                              'Update query: bind params',  $bind[1] );
} ## end sub test_insert_peer
1;
