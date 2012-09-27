#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  shortnumber2dial.pl
#
#        USAGE:  ./shortnumber2dial.pl 
#
#  DESCRIPTION: Читает указанный в параметрах файл. Пытается найти там информацию вида 
#               XX:SIP/blablabla/0504139380 
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  27.09.2012 10:36:24 EEST
#     REVISION:  ---
#===============================================================================

use 5.8.0;
use strict;
use warnings;

$| = 1;
use Asterisk::AGI;

my $config = $ARGV[0]; 
unless ( defined ( $config ) ) {
	warn "Undefined config"; 
	exit (-1); 
}

my $sn = $ARGV[1]; 
unless ( defined ( $sn ) ) { 
	warn "Undefined short number"; 
	exit(-1); 
}

if ($sn > 100) { 
	warn "Short number must have two digits!"; 
	exit(-1);
} 

open (CONFIG,$config) or die "Can't open $config: $!";
my @cfg = <CONFIG>; 
close CONFIG;

my $agi = new Asterisk::AGI; 
$agi->ReadParse();

foreach my $line ( @cfg ) { 
	chomp $line; 
	my ($shortnumber,$dialstring) = split (':',$line); 
	if ($shortnumber eq $sn ) { 
		$agi->set_variable("DIALSTRING",$dialstring);
		$agi->verbose ($dialstring,3);
		exit(0);
	}
}

$agi->set_variable("DIALSTRING","undefined"); 
$agi->verbose("undefined",3); 
exit(0);


1;
#===============================================================================

__END__

=head1 NAME

shortnumber2dial.pl

=head1 SYNOPSIS

shortnumber2dial.pl

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

