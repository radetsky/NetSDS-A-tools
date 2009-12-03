#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  officepark.pl
#
#        USAGE:  ./officepark.pl
#
#  DESCRIPTION:
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  0.7
#      CREATED:  03.12.2009 17:00:41 EET
#     REVISION:  ---
#===============================================================================

use 5.8.0;
use strict;
use warnings;

$| = 1;

# Setup some variables
my %AGI;
my $tests = 0;
my $fail  = 0;
my $pass  = 0;

while (<STDIN>) {
	chomp;
	last unless length($_);
	if (/^agi_(\w+)\:\s+(.*)$/) {
		$AGI{$1} = $2;
	}
}

sub checkresult {
	my ($res) = @_;
	my $retval;
	$tests++;
	chomp $res;
	if ( $res =~ /^200/ ) {
		$res =~ /result=(-?\d+)/;
		if ( !length($1) ) {
			print STDERR "FAIL ($res)\n";
			$fail++;
		} else {
			print STDERR "PASS ($1)\n";
			$pass++;
		}
	} else {
		print STDERR "FAIL (unexpected result '$res')\n";
		$fail++;
	}
}

my $cmd = 'wget -O /dev/null "http://perlapps/fcgi-bin/asterisk.fcgi?find_n_park=' . $AGI{'callerid'} . '"';
my $res = `$cmd`;

1;
#===============================================================================

__END__

=head1 NAME

officepark.pl

=head1 SYNOPSIS

officepark.pl

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

