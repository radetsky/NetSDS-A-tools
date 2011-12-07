#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  astconf2sql.pl
#
#        USAGE:  ./astconf2sql.pl 
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
#      CREATED:  12/07/11 18:26:09 EET
#     REVISION:  ---
#===============================================================================

use 5.8.0;
use strict;
use warnings;

use DBI;
use POSIX;

if (@ARGV != 3) {
    print STDERR "Usage: ast2sql <ast_config_file> <table_name> <filename_in_table>\n";
    exit 1;
}
open(CONFIG_FILE, "<$ARGV[0]") || die $!;
my @lines;
my $cat_metric = -1; # incremented to 0 on first hit
my $var_metric = -1;
my $category;
while (<CONFIG_FILE>) {
    my $line = $_;
    chop($line);
    my($var_name, $var_val);

    next if ($line =~ /^\s*;/); # comment line skip

    if ($line =~ /^\s*\[(.*?)\]/) {
        $category = $1;
        $var_metric = -1;
        $cat_metric++;
    } elsif ($line =~ /^\s*(\w+)\s*=>\s*(.+)\s*;?.*$/ ||
               $line =~ /^\s*(\w+)\s*=\s*(.+)\s*;?.*$/) {
        $var_metric++;
        $var_name = $1;
        $var_val  = $2;
    } else {
        next; # no match, skip
    }
	my ($t1,$t2) = split (' ',$var_val);
	
	$var_val = $t1; 
    
	if ($var_metric >= 0) {
        my %hash = ('cat_metric' => $cat_metric,
                    'var_metric' => $var_metric,
                    'category'   => $category,
                    'var_name'   => $var_name,
                    'var_val'    => $var_val);
        push(@lines, \%hash);
    }
}

close(CONFIG_FILE);

my $dbh;
foreach my $row (@lines) {

    print "-- $row->{'cat_metric'}\t$row->{'category'}\t$row->{'var_metric'}\t$row->{'var_name'}\t$row->{'var_val'}\n";
	printf("insert into %s (filename, cat_metric, var_metric, category, var_name, var_val) values ('%s','%s','%s','%s','%s','%s');\n",
	$ARGV[1],
	$ARGV[2],
	$row->{'cat_metric'},
	$row->{'var_metric'},
	$row->{'category'},
	$row->{'var_name'},
	$row->{'var_val'} 
);
#    my $sth = $dbh->prepare("INSERT into $ARGV[1] (filename, cat_metric, var_metric, category, var_name, var_val) values (?, ?, ?, ?, ?, ?)");
#	
#	  $sth->bind_param(1, $ARGV[0]);
#	$sth->bind_param(2, $row->{'cat_metric'});
#	$sth->bind_param(3, $row->{'var_metric'});
#	$sth->bind_param(4, $row->{'category'});
##	$sth->bind_param(5, $row->{'var_name'});
#	$sth->bind_param(6, $row->{'var_val'});
}


1;
#===============================================================================

__END__

=head1 NAME

astconf2sql.pl

=head1 SYNOPSIS

astconf2sql.pl

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

