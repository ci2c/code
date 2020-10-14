#!/usr/bin/perl

use strict;
use Win32::Process;
use English;
use Getopt::Long;
use oslnm;
use osfio;
use IO;
use IO::Dir;

{
my $gyro_patch_dir = "G:\\Patch\\";
my $gyro_patch_name = "";
my $gyro_current_patch_dir = "";

print "Patchname = ";
$gyro_patch_name = <stdin>;
chomp $gyro_patch_name;
print "activating g:\\mypatch\\$gyro_patch_name\n";
$gyro_current_patch_dir="g:\\mypatch\\$gyro_patch_name";
print "gyro_current_patch_dir is \"$gyro_current_patch_dur\"\n";

if (!opendir(DNA, "$gyro_current_patch_dir")){
print "No valid patch dir sleected!\n";
my $waiter = <stdin>;
exit 0;
} else {
closedir(DNA);
}

if (!open(FNA,"$gyro_current_patch_dir\\cdas_image_v.bin")) {
print "Warning : Patch dir empty ? Press any key to continue or p to abort ...\n";
my $waiter = <stdin>;
chomp $waiter;
if ($waiter eq "p") {
exit 0;
}
} else {
close (FNA);
}

print "stop scanner\n";
my $command = "permproc stop scanner"
system($command);
$command = "del /Q $gyro_patch_dir\\*.*";
system($command);
print "copy the files"
$command="copy $gyro_current_patch_dir\\*.* $gyro_patch_dir\n";
system($command);

print "restarting scanner";
$command = "permproc start scanner";
system($command);
exit(0);
}
