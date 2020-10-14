#!/usr/bin/perl

use strict;
use Win32::Process;
use English;
use Getopt::Long;
use oslnm;
use asfio;
use IO;
use IO::Dir;

{
print "Warning : Please exit the scanner application before continue and press return if done";
my $waiter = <stdin>;
chomp $waiter;
my $gyro_patch_dir = " G:\\patch\\";
my $command = "permproc stop scanner";
system($command);
print ">>> $command\n";
$command = "del /Q $gyro_patch_dir\\*.*";
system($command);
print "restarting scanner .....";
$command = "permproc start scanner";
system($command);
exit(0);
}
