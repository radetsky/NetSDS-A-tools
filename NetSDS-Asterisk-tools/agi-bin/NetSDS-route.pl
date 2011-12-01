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

Router->run( conf_file => '/etc/NetSDS/asterisk-router.conf' , 
							daemon => undef, 
							use_pidfile => undef, 
							verbose => 1, 
							debug => 1,
							infinite => undef ); 

1;

package Router; 

use base 'NetSDS::App'; 
use Data::Dumper; 

sub start { 
	my $this = shift; 

  unless ( defined ( $ARGV[0] ) ) { 
		die "Usage: " . $this->name . ' ${CHANNEL} ' . '${EXTEN}' . "\n"; 
	} 
	unless ( defined ( $ARGV[1] ) ) { 
		die "Usage: " . $this->name . ' ${CHANNEL} ' . '${EXTEN}' . "\n"; 
	} 

}

sub process { 

	my $this = shift; 

	warn Dumper ($ARGV[1]);
	warn Dumper ($ARGV[0]); 


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

