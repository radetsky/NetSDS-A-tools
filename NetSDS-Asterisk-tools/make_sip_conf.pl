#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  generate_sip_users.pl
#
#        USAGE:  ./generate_sip_users.pl
#
#  DESCRIPTION:  Generating SIP accounts to STDOUT from <a> to <b> with parameters
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  23.11.2009 13:20:39 EET
#     REVISION:  ---
#===============================================================================

use 5.8.0;
use strict;
use warnings;

use Getopt::Mixed "nextOption";

my $debug                = 0;
my $account_number_begin = 200;                           # Default values
my $account_number_end   = 299;
my $type                 = 'friend';
my $secret               = 'random';
my $context              = 'office';
my $host                 = 'dynamic';
my $deny                 = '0.0.0.0/0.0.0.0';
my $permit               = '192.168.0.0/255.255.255.0';
my $insecure             = 'no';
my $qualify              = 'yes';
my $canreinvite          = 'no';
my $disallow             = 'all';
my $allow                = 'ulaw,alaw';
my $call_limit           = 1;
my $nat                  = 'no';
my $storage              = 'sip.conf';                    # or 'sql'

############
# Main ()
# ##########
#

GetOpts();

for ( my $account_number = $account_number_begin ; $account_number <= $account_number_end ; $account_number = $account_number + 1 ) {

	if ( $storage eq 'sip.conf' ) {

		printf(
			"[%s]\ntype=%s\nsecret=%s\ncallerid=%s\ncontext=%s\nhost=%s\ndeny=%s\npermit=%s\ninsecure=%s\nqualify=%s\nnat=%s\ncall-limit=%s\ncanreinvite=%s\ndisallow=%s\n%s\n\n",
			$account_number,
			$type,
			make_password(),
			sprintf("\"%s\"<%s>",$account_number,$account_number),
			$context,
			$host,
			$deny,
			$permit,
			$insecure,
			$qualify,
			$nat,
			$call_limit,
			$canreinvite,
			$disallow,
			allow_codecs_strings($allow)
		);
	} ## end if ( $storage eq 'sip.conf')

	if ( $storage eq 'sql' ) {

		printf(
			'insert into sip_conf (name,callgroup,callerid,context,host,nat,deny,permit,pickupgroup,qualify,type,username,disallow,allow,secret ) values (\'%s\',%d,\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',%d,\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\' );',
			$account_number,1, sprintf("\"%s\"<%s>",$account_number,$account_number),
			$context, $host,           $nat,      $deny, $permit, 1,
			$qualify, $type, $account_number, $disallow, $allow, make_password()
		);
		printf("\n"); 

	}

} ## end for ( my $account_number...

sub make_password {
	my $password = `/usr/bin/pwgen 8 1`;
	chomp($password);
	return $password;
}

sub allow_codecs_strings {
	my $allowstr = shift;
	my (@a) = split( /,/, $allowstr );
	my $result = undef;
	foreach my $i (@a) {
		$result = $result . "allow=$i\n";
	}
	return $result;
}

#############
# GetOpts
#############
sub GetOpts {

	Getopt::Mixed::init("debug help begin=i end=i type=s secret=s context=s host=s deny=s permit=s insecure=s qualify=s nat=s call-limit=i canreinvite=s disallow=s allow=s storage=s");
	while ( my ( $option, $value, $pretty ) = nextOption() ) {
		if ( $option eq 'debug' ) {
			$debug++;
		} elsif ( $option eq 'help' ) {
			return Usage();
		} elsif ( $option eq 'begin' ) {
			$account_number_begin = $value;
		} elsif ( $option eq 'end' ) {
			$account_number_end = $value;
		} elsif ( $option eq 'type' ) {
			$type = $value;
		} elsif ( $option eq 'secret' ) {
			$secret = $value;
		} elsif ( $option eq 'context' ) {
			$context = $value;
		} elsif ( $option eq 'host' ) {
			$host = $value;
		} elsif ( $option eq 'deny' ) {
			$deny = $value;
		} elsif ( $option eq 'permit' ) {
			$permit = $value;
		} elsif ( $option eq 'insecure' ) {
			$insecure = $value;
		} elsif ( $option eq 'qualify' ) {
			$qualify = $value;
		} elsif ( $option eq 'canreinvite' ) {
			$canreinvite = $value;
		} elsif ( $option eq 'disallow' ) {
			$disallow = $value;
		} elsif ( $option eq 'allow' ) {
			$allow = $value;
		} elsif ( $option eq 'nat' ) {
			$nat = $value;
		} elsif ( $option eq 'call-limit' ) {
			$call_limit = $value;
		} elsif ( $option eq 'storage' ) {
			$storage = $value;
		}
	} ## end while ( my ( $option, $value...
	Getopt::Mixed::cleanup();
} ## end sub GetOpts

sub Usage {

	printf(
		" Usage with parameters: 
	--debug = to debug this script 
	--help  = to show this page 
	--begin = number that begins your accounts e.g. 200
	--end   = number that finish your accounts e.g. 299 
	--type  = type of SIP peer : friend or peer 
	--secret =   \'random\' or nothing 
	--context =  outbound context to the users that generates this script 
	--host = dynamic or FQDN 
	--deny = default value 0.0.0.0/0.0.0.0 
	--permit = defaut value 192.168.0.0/255.255.255.0 
	--insecure = default value \'no\' may be \'invite,port\' 
	--qualify = default yes, may be no 
	--nat = yes/no 
	--call-limit = 1..6
	--canreinvite 
	--disallow=all
	--allow=g729,ulaw,alaw
	--storage=sql ( default sip.conf ) 
	\n\n"
	);

	exit(0);

} ## end sub Usage

1;
#===============================================================================

__END__

=head1 NAME

generate_sip_users.pl

=head1 SYNOPSIS

generate_sip_users.pl

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

