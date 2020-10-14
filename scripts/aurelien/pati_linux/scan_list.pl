#!/usr/bin/perl

use Net::FTP;
use FindBin;
use lib "$FindBin::Bin";
#use lib '/home/rluchin/pati_linux/';
require 'pati_common.pl';
require 'pati_subrout.pl';
$sepkey="&";

while ($ARGV[0] =~ /^-/) {
    $_ = shift @ARGV;
    if (/^-h(elp)?$/) {
	&usage;
    } elsif (/^-s$/) {
	$node = shift @ARGV;
    } elsif (/^-cpx$/) {
	$cpx=1;
    } elsif (/^-p$/) {
	$study_oid = shift @ARGV;
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
    die "$term_red Scanner $node is not known.$term_def\n Exit.\n";
    exit 1;
}

if ($study_oid eq ""){
    print "$term_red Please add a Study_OID with option -p .$term_def\n Exit.\n";
    exit 1;
}

&read_scan_db;

if ($num==0){
    print "No Results\n";
    exit 1;
}
for ($i=1;$i<$num;$i++){
    print "$arr_acquisition_no[$i]$sepkey$arr_series_oid[$i]$sepkey$arr_study_date[$i]$sepkey$arr_scan_time_h[$i]:$arr_scan_time_m[$i]$sepkey$arr_proto[$i]$sepkey$arr_no_slice[$i]$sepkey$arr_no_echos[$i]$sepkey$arr_no_dyn[$i]$sepkey$arr_no_phases[$i]$sepkey";
    if ($cpx){
	print "$arr_blobname[$i]$sepkey$arr_blob_typ[$i]\n";
    } else {
	print "$arr_file[$i]\n";
    }
}

sub usage {
    print "This Program diplay all Scans of one Patient.\n";
    print "Option: -s scanner\n";
    print "        -p Study_OID\n";
    print "        -cpx CPX/IDX/RAW-Data\n\n";
    exit 1;
}
