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
my $account_number_end   = 500;
my $type                 = 'friend';
my $username             = undef;                         # Default: set username same as $account_num
my $secret               = 'random';
my $context              = 'LocalOffice';
my $host                 = 'dynamic';
my $deny                 = '0.0.0.0/0.0.0.0';
my $permit               = '192.168.0.0/255.255.255.0';
my $insecure             = 'no';
my $qualify              = 'yes';
my $canreinvite          = 'no';
my $disallow             = 'all';
my $allow                = 'g729,ulaw,alaw';

############
# Main ()
# ##########
#

GetOpts();

#############
# GetOpts
#############
sub GetOpts {

	Getopt::Mixed::init("debug help begin=i end=i type=s username=s secret=s context=s host=s deny=s permit=s insecure=s qualify=s canreinvite=s disallow=s allow=s");
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
		} elsif ( $option eq 'username' ) {
			$username = $value;
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
	--username = \'same\' or nothing 
	--secret =   \'random\' or nothing 
	--context =  outbound context to the users that generates this script 
	--host = dynamic or FQDN 
	--deny = default value 0.0.0.0/0.0.0.0 
	--permit = defaut value 192.168.0.0/255.255.255.0 
	--insecure = default value \'no\' may be \'invite,port\' 
	--qualify = default yes, may be no 
	--canreinvite 
	--disallow=all
	--allow=g729,ulaw,alaw \n\n"
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

