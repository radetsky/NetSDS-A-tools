#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  bootstrap.pl
#
#        USAGE:  ./bootstrap.pl 
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
#      CREATED:  12/16/11 11:36:45 EET
#     REVISION:  ---
#===============================================================================

use 5.8.0;
use strict;
use warnings;

for (my $id = 1; $id <= 200; $id++ ) { 
	print "insert into integration.ULines (id) values ($id);\n";  
} 

1;
#===============================================================================

__END__

=head1 NAME

bootstrap.pl

=head1 SYNOPSIS

bootstrap.pl

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

