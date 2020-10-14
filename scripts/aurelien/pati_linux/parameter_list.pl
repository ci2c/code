#!/usr/bin/perl

use Net::FTP;
use FindBin;
use lib "$FindBin::Bin";
require 'pati_common.pl';
require 'pati_subrout.pl';
$sepkey="&";

while ($ARGV[0] =~ /^-/) {
  $_ = shift @ARGV;
  if (/^-h(elp)?$/) {
    &usage;
  } elsif (/^-s$/) {
    $node = shift @ARGV;
  } elsif (/^-n$/) {
    $series_oid = shift @ARGV;
  } elsif (/^-f$/) {
    $sybase_table_list[0] = shift @ARGV;
    if ($sybase_table_list[0] eq "all"){
      @sybase_table_list=("bulk_files","image","presentstate","series","series_Cardiac","series_Equipment","series_Geom","series_PlscSurvey","series_Reference","series_SC_Equipment","series_Scanogram","series_Slab","series_SpMix","series_Spectro","series_SpectroPrHst","series_Stack","series_Volume","spectrum","deleted_series","blobs");
    }
  } else {
    print "$term_red Unbekannte Option: $_$term_def\n";
    &usage;
  }
}    

if ($sybase_table eq ""){
    $sybase_table="series_cardiac";
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

if ($series_oid eq ""){
    print "$term_red Please add a Series_OID with option -n .$term_def\n Exit.\n";
    exit 1;
}

foreach my $sybase_table (@sybase_table_list){
  print "\nTable: $sybase_table\n";
  $isql_request="use patientdb
go
select 
    * from $sybase_table 
where ";
  if ($sybase_table ne "blobs") {
    $isql_request=$isql_request."series_OID=".$series_oid."\ngo";
  } else {
    $isql_request=$isql_request."parent_id=".$series_oid." order by blob_name\ngo";
  }
  if ($^O eq "MSWin32"){
    my $temp_file=$ENV{tmp}."\\sybase_temp.tmp";
    my $temp_file_out=$ENV{tmp}."\\sybase_temp_out.tmp";
    open(TEMP_FILE,">$temp_file");
    print TEMP_FILE $isql_request;
    close(TEMP_FILE);
    system "\"$isql\" -S $host -U $username -P $pswd -w 100000  -s \"&\" -i \"$temp_file\" -o \"$temp_file_out\"";
    unlink("$temp_file");
    @daten_isql=open(ISQL,"$temp_file_out");
  } else {
    @daten_isql=open(ISQL,"echo \'$isql_request\' | $isql -S $host -U $username -P $pswd -w 100000 -s \"&\"|");
  }
  @main = <ISQL>;
  close (ISQL);
  if ($^O eq "MSWin32"){
    unlink("$temp_file_out");
  }
  #print $isql_request		;
  $num=1;
  foreach $dataset (@main){
    if ($num==1){
      @line=split(/&/,$dataset);
      @line=~ map (s/^[ ]*//, @line);
      @line=~ map (s/\n//,@line);
      @line=~ map (s/[ ]*$//, @line);
    } elsif ($num>=3){
      @daten=split(/&/,$dataset);
      @daten=~ map (s/^[ ]*//, @daten);
      @daten=~ map (s/\n//,@daten);
      @daten=~ map (s/[ ]*$//, @daten);
      shift(@daten);
      $count_elem=0;
      if (($daten[0] ne "10") and !($daten[0] =~ /affected\)$/)){
	foreach $value (@daten) {
	  print $line[$count_elem]." : ".$value."\n";
	  $count_elem++;
	}
      }
    }
    $num++;
  }

  if ($num<2) { 
   print "no data in table $sybase_table\n\n";
 }	
}

sub usage {
    print "\nThis Program diplay all Patients on the system.\n";
    print "Option: -s scanner \n";
    print "        -n Series_OID\n";
    print "        -f Name of database table\n";
    print " valid table names: blobs, image, presentstate, series,\n";
    print "                    series_Cardiac, series_Equipment,\n";
    print "                    series_Geom, series_PlscSurvey, series_Reference,\n";
    print "                    series_SC_Equipment, series_Scanogram,\n";
    print "                    series_Slab, series_SpMix,\n";
    print "                    series_Spectro, series_SpectroPrHst,\n";
    print "                    series_Stack, series_Volume,\n";
    print "                    spectrum, deleted_series\n";
    print "                    all\n";
    exit 1;
}
