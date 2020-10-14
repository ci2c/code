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
  } elsif (/^-b$/) {
    $scanner_blobname = shift @ARGV;
    $cpx=1;
  } elsif (/^-e$/) {
    $series_extension = shift @ARGV;
  } elsif (/^-f$/) {
    $scanner_filename = shift @ARGV;
    $cpx=0;
  } elsif (/^-o$/) {
    $userdef_file_basename = shift @ARGV;
  } elsif (/^-nore$/) {
    $image_reorder=0;
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
    $host_ftp=$host_ftp{$key};
    if ($host_ftp eq "") {
      $host_ftp=$key;
    }
  }
}

if (($^O eq "MSWin32") && ($file_transfer{$host} eq "win_share")) {
  $Connection=0;
  my %NETRESOURCE;
  $NETRESOURCE{'Type'}=RESOURCETYPE_DISK;
  $NETRESOURCE{'RemoteName'}="\\\\$host\\bulk";
  $file_transfer_dir{$host}="\\\\$host\\bulk";
  $Con=Win32::NetResource::AddConnection(\%NETRESOURCE,$pswd_ftp,$username_ftp,$Connection);
  print "conection: $Con";
}

if (($^O eq "MSWin32") && ($file_transfer{$host} eq "win_share_local")) {
   $file_transfer{$host}="win_share";
}
if ($host eq "") {
  die "$term_red Scanner $node is not known.$term_def\n Exit.\n";
  exit 1;
}

if ($userdef_file_basename eq "") {
  die "$term_red Filename needed!$term_def\n Exit.\n";
  exit 1;
}

if ($scanner_blobname eq "" and $scanner_filename eq "") {
  print "$term_red Please use either option -b or -f.$term_def\n Exit.\n";
  exit 1;
}

if ($cpx) {
  &get_cpx($scanner_blobname,$series_extension);
} else {   
  $isql_request='use patientdb
go
select series_OID," ^ ",image_filename
from image
where image_filename like "'.$scanner_filename.'" AND
    image_no<10
go';
  &open_sybase(ISQL,$isql_request);
  while ($dataset=<ISQL>) {
    @daten=split(/ \^ /,$dataset);
    #debug sqlrequesti
    @daten=~ map (s/^[ ]*//, @daten);
    @daten=~ map (s/\n//,@daten);
    @daten=~ map (s/[ ]*$//, @daten);
    if ($daten[1] eq $scanner_filename) {
      $series_oid=$daten[0];
    }
  }
  if ($series_oid eq ""){
    exit;
  }
  &get_par($series_oid);
  &get_rec($scanner_filename);
}


sub usage {
  print "This Program diplay all Patients on the system.\n";
  print "Option: -s scanner\n";
  print "        -b blob-filename_on_scanner (CPX,RAW,LAB)\n"; 
  print "        -f REC-filename_on scanner (REC)\n"; 
  print " (-b or -f needed)\n";
  print "        -e Series Extension (recommended for RAW,IDX,LAB)\n";
  print "        -o filename for REC/CPX/PAR-File (needed) (without extension!)\n";
  exit 1;
}
