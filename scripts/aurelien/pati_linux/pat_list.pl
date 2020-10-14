#!/usr/bin/perl

use FindBin;
use lib "$FindBin::Bin";
#use lib '/home/rluchin/pati_linux/';
require 'pati_common.pl';
require 'pati_subrout.pl';
$sepkey="&";  #^ would be better!!! 

while ($ARGV[0] =~ /^-/) {
    $_ = shift @ARGV;
    if (/^-h(elp)?$/) {
	&usage;
    } elsif (/^-s$/) {
	$node = shift @ARGV;
    } else {
	print "$term_red Unbekannte Option: $_$term_def\n";
	&usage;
    }
}    

while (($key,$val) = each %allowed_hosts) {
  if (lc($node) eq $key) {
    $host=$key;
    $host_rel=$val;
    $username=$username{$key};
    $pswd=$pswd{$key};
    $username_ftp=$username_ftp{$key};
    $pswd_ftp=$pswd_ftp{$key};
  }
}

if ($host eq ""){
    print "$term_red Scanner $node is not known.$term_def\n Exit.\n";
    exit 1;
}

&read_pat_db;

if ($num==0){
    print "No Results\n";
    exit 1;
}

for ($i=1;$i<$num;$i++){
    print "$i$sepkey$arr_soid[$i]$sepkey$arr_name[$i]$sepkey$arr_date[$i]\n";
}

sub usage {
    print "This Program diplay all Patients on the system.\n";
    print "Option: -s scanner\n\n";
    exit 1;
}





