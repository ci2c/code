#!/usr/bin/perl
##############################
# Write Dicom2 CD's
# (C) 2009 RL IBT Zuerich
##############################
use FindBin;
use File::Path;
use lib "$FindBin::Bin";
require 'pati_common.pl';

$i=1;
$scanner_nr[0]="";
if ($node eq ""){

  foreach (sort {$order_hosts{$a} cmp $order_hosts{$b}} keys(%allowed_hosts)) {
    $key=$_;
    print "     $i. ".uc($key)." (".$allowed_hosts{$key}.")\n";
    $scanner_nr[$i]=$key;
    $i++;
  }
  print "    Please select a scanner: (q quit)$term_def ";
  chomp($eingabe=<STDIN>);
  if ($eingabe eq "q") {
    print "Exit pati\n";exit;
  }
  if ($eingabe lt $i){
    $scanner=$scanner_nr[$eingabe];
  }
}

$dir_dicom="\\\\$scanner\\dicom";
$temp_dir=$ENV{tmp}."\\$scanner"."_dicom2";
rmtree($temp_dir);
mkdir($temp_dir);
print "$temp_dir\n";
#Verzeichnis erstellen
$command="\"C:\\Program Files\\createcd\\dicom2.exe\" --warn=n --rename=ser_nb:img_nb0 $dir_dicom\\DICOM\\IM_* --to=$temp_dir -d=il";
print "$command\n";
system $command;

$last_scan="";
$last_image=0;
opendir(DIR,$temp_dir);
while( ($filename = readdir(DIR))){
     ($scan,$image)=split(/-/,$filename);
     if ($last_scan ne $scan){ 
	if ($last_image>0){
	   print "($last_image images)\n";
	   $last_image=1;
        }
        print("$filename: "); 
        $last_scan=$scan;
     } else {
        $image=~/i(\d+)\.dcm/;
        $last_image=$1;
     }
} 
print "($last_image images)\n";
closedir(DIR);


$command="\"C:\\Program Files\\createcd\\CreateCD3.exe\" -r:e -eject $temp_dir\\*.dcm";
print "$command\n";

print "Do you want to write the CD (y/n)) ";
chomp($eingabe=<STDIN>);
if ($eingabe ne "y") {
  print "Exit\n";exit;
} else {
  print "please insert an empty CD and press enter\n";
  chomp($eingabe=<STDIN>);
  system $command;
  print "Please remove CD.\n\n";
  print "Do you want to delete the dicom-Folder $dir_dicom (y/n)?\n";
  chomp($eingabe=<STDIN>);
  rmtree($temp_dir);
  if ($eingabe eq "y") {
    rmtree($dicom_dir);  
    print "Files on the scanner deleted!";
  }
}
print "\n";
