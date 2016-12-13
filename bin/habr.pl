#!/usr/bin/env perl

use strict;
use warnings;
use lib '../lib';
use Local::Habr;

use Getopt::Long;
use DDP;

my $param = {};
my $command;
my $csv = "file.csv";
GetOptions ( $param, 'name=s', 'post=i', 'id=i', 'n=s', 'format=s', 'refresh'); 
my @k = keys %$param;
$param->{param} = "" if $#k == -1;
p $param;

while (<@ARGV>){
	$command = $_;
}


my $data = Local::Habr->new($command, $param);
$data->get;
if (!defined $data->{format}){
	print "not defined\n";
	$data->printout(undef);
}
elsif ( $data->{format} eq "csv") {
	p $csv;
	$data->printout( $csv );
}

else{
	$data->printout;
}
