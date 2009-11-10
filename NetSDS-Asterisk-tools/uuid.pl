#!/usr/bin/perl 

use warnings;
use strict;

use Data::UUID;

$|=1;

# Setup some variables
my %AGI;

while(<STDIN>) {
        chomp;
        last unless length($_);
        if (/^agi_(\w+)\:\s+(.*)$/) {
                $AGI{$1} = $2;
        }
}



my $ug = new Data::UUID;
print "SET VARIABLE UUID \"" . $ug->create_str() . "\"";
print "\n";

