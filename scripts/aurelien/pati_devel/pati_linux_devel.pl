#!/usr/bin/perl
###################################################################
#              Pati V0.99e (Linux/Win32/VMS R9-R12/R1-2.x         #
#                RL 2010 IBT Zuerich (Switzerland)                #
#                     http://www.mr.ethz.ch/                      #
#                               main                              #
###################################################################
local $SIG{__DIE__} = \&mydie;

$version_pati="pati_linux.pl (18.10.2010)";

if ($^O ne "VMS"){
    require Net::FTP;
    if ($^O eq "MSWin32"){
	require WIN32::NetResource;
    }
} else {
  require IO::File;
  require VMS::Stdio;
}
$|=1;
use File::Copy;
use FindBin;
use lib "$FindBin::Bin";
require 'pati_common.pl';
require 'pati_subrout.pl';

#&version_subrout;
#initialize values...
$host="";

#terminalcolors:
if ($use_terminal_colors) {
  $term_clear="\c[\[2J";
  $term_inv="\c[\[7m";
  $term_def="\c[\[0m";
  $term_red="\c[\[31m";
}


print "\n\n\n\n\n$term_clear$term_inv
     pati-Version: $version_pati, $version_subrout       \b
                                                                              \b
                  Pati (R9-R12/R1.x/R2.x Linux/Win32/VMS)                     \b
                   DM/RL 2010 IBT Zuerich (Switzerland)                       \b
                          http://www.mr.ethz.ch/                              \b
                                help: -h                                      \b
                                                                              \b$term_def\n\n";

### parse options

while ($ARGV[0] =~ /^[-\/]/) {
  $_ = shift @ARGV;
  $_ =~s/^\//-/;
  if (/^-h(elp)?$/) {
    &usage;
  } elsif (/^-s$/) {
    $node = shift @ARGV;
  } elsif (/^-p(ride)?3$/) {
    $pride_vers=3;
  } elsif (/^-p(ride)?4$/) {
    $pride_vers=4;
  } elsif (/^-p(ride)?4(\.)?1$/) {
    $pride_vers=4.1;
  } elsif (/^-p(ride)?4(\.)?2$/) {
    $pride_vers=4.2;
  } elsif (/^-file(name)?$/) {
    $filename_only=1;
  } elsif (/^-fl$/) {
    $filename_format_temp = shift @ARGV;
  } elsif (/^-cpx$/) {
    $cpx=1;
  } elsif (/^-spec$/) {
    $spec=1;
  } elsif (/^-nore$/) {
    $image_reorder=0;
  } elsif (/^-par$/) {
    $parfile_only=1;
  } elsif (/^-soid$/) {
    $soid_only=1;
  } elsif (/^-f$/) {
    $no_conf=1;
  } elsif (/^-i$/) {
    $no_conf=0;
  } elsif (/^-new$/) {
    $ask_userdef_filename=1;
  } else {
    print "$term_red Unbekannte Option: $_$term_def\n";
    &usage;
  }
}
print "Pride Version: $pride_vers\n\n";
if ($ARGV[0] ne ""){
  if (-d $ARGV[0]){
     $data_folder=$ARGV[0];
  }
}

$i=1;
$scanner_nr[0]="";
if ($node eq ""){

  foreach (sort {$order_hosts{$a} cmp $order_hosts{$b}} keys(%allowed_hosts)) {
    $key=$_;
    print "     $i. ".uc($key)." (".$allowed_hosts{$key}.")\n";
    $scanner_nr[$i]=$key;
    $i++;
  }
  print "    $term_inv Please select a scanner: (q quit)$term_def ";
  chomp($eingabe=<STDIN>);
  if ($eingabe eq "q") {
    print "Exit pati\n";exit;
  }
  if ($eingabe < $i){
    $node=$scanner_nr[$eingabe];
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
    if ($host_ftp eq ""){
       $host_ftp=$key;
    }
  }
}

if (($node) && (!$host)){
  die "unknown Scanner: $node";
}

if (($^O eq "MSWin32") && ($file_transfer{$host} eq "win_share")){
    $Connection=0;
    my %NETRESOURCE;
    $NETRESOURCE{'Type'}=RESOURCETYPE_DISK;
    $NETRESOURCE{'RemoteName'}="\\\\$host\\bulk";
    $file_transfer_dir{$host}="\\\\$host\\bulk";
    $Con=Win32::NetResource::AddConnection(\%NETRESOURCE,$pswd_ftp,$username_ftp,$Connection);
    print "connection: $Con";
}
if (($^O eq "MSWin32") && ($file_transfer{$host} eq "win_share_local")){
    $file_transfer{$host}="win_share";
}

if (($filename_format_temp eq "0") or ($filename_format_temp eq "1") or ($filename_format_temp eq "2") or ($filename_format_temp eq "3") or ($filename_format_temp eq "4") or ($filename_format_temp eq "5")) {
  $filename_format=$filename_format_temp;
}

if ($host eq "") {
  print "$term_red Scanner $node is not known.$term_def\n Exit.\n";
  &usage;
}

##calculate xterm size;
$row=25;
if ($use_terminal_size) {
  require 'sys/ioctl.ph';
  die "no TIOCGWINSZ " unless defined &TIOCGWINSZ;
  open(TTY, "+</dev/tty")                     or die "No tty: $!";
  unless (ioctl(TTY, &TIOCGWINSZ, $winsize='')) {
    die sprintf "$0: ioctl TIOCGWINSZ (%08x: $!)\n", &TIOCGWINSZ;
  }
  ($row, $col, $xpixel, $ypixel) = unpack('S4', $winsize);
  print "row=$row";
}
if ($row eq "") {
  $row=25;
}

$!=0;
for ($i=0;$i<$row;$i++) {
  print"\n";
} 

print "Connecting to sybase...\n";

&read_pat_db;

$eingabe="";

$nr_series=$num-1;
print "$term_clear\n";
for ($i=1;$i<$nr_series/2+1;$i++) {
  $j=$i+int($nr_series/2+0.5);
  printf "%5d %19.19s %11.11s |",$i,$arr_name[$i],$arr_date[$i];
  if ($j<=$nr_series) {
    printf "%5d %20.20s %11.11s\n",$j,$arr_name[$j],$arr_date[$j];
  } else {
    print"\n";
  }
  if ($i%(int($row)-2)==0) {
    print "  > for next page of Patient-Names on $host Press ENTER > ";
    chomp($temp = <STDIN>);
    if ($temp ne ""){
      $eingabe=$temp;
      $i=$nr_series/2+1;
    }
  }
}

do {
  if ($eingabe eq "") {
    print "Please select Patients from $host (eg 1,3-6 or q): ";
    chomp($eingabe=<STDIN>);
  }
  if ($eingabe eq "q") {
    print "Exit pati\n";exit;
  }
  $eingabe=$eingabe.",";
  @auswahl=split(/([,-])/,$eingabe);
  $i=0;
  $j=0;
  $eingabe_ok=1;
  undef @auswahl2;
  do {
    if (($i+3 <= @auswahl) and (0<int($auswahl[$i]))and (int($auswahl[$i])<=$nr_series) and ($auswahl[$i+1] eq "-") and (0<int($auswahl[$i+2])) and (int($auswahl[$i+2])<=$nr_series) and ($auswahl[$i+3]eq ",") and ($auswahl[$i]<$auswahl[$i+2])) {
      for ($k=$auswahl[$i];$k<=$auswahl[$i+2];$k++) {
        $auswahl2[$j]=$k;
        $j++;
      }
      $i=$i+4;
    } elsif (($i+1 <= @auswahl) and (0<int($auswahl[$i]))and (int($auswahl[$i])<=$nr_series) and ($auswahl[$i+1] eq ",")) {
      $auswahl2[$j]=$auswahl[$i];
      $i=$i+2;
      $j++;
    } else {
      $eingabe_ok=0;
      print "$term_red Your selection: $eingabe is not valid$term_def\n";
      $eingabe="";
      $i=@auswahl+1;
    }
  } until ($i>=@auswahl);
  if ($eingabe_ok) {
    print "\n$term_inv Selected Patients:$term_def\n";
    foreach $k (@auswahl2) {
      printf "x%4d (%4d) %20.20s %20.20s\n",$k,$arr_acquisition_no[$k],$arr_name[$k],$arr_date[$k];
    }
    if (! $no_conf) {
      print "\nOK? (y/n):";
      chomp($temp = <STDIN>);
      if ($temp eq "n") {
	$eingabe_ok=0;
      }
    }
  }
} until ($eingabe_ok);

#Now for each selected patient...
foreach $index_pat (@auswahl2) {

  $study_oid=$arr_soid[$index_pat];
  &read_scan_db;

  if ($cpx) {			#display cpx-scans
    $nr_scans=$num-1;
    print "\n\n\n$term_inv Scan-List of Patient :  $arr_name[$index_pat]
 No AqcNo Protocol           Time    Sli Ech Dyn Pha  Type  name$term_def
-----------------------------------------------------------------------------\n";
    for ($i=1;$i<$num;$i++) {
      printf "%4d %4d %-16.16s %2.2s:%2.2s:%2.2s %4.4s%4.4s%4.4s%4.4s %4.4s %18.18s\n",$i,$arr_acquisition_no[$i],$arr_proto[$i],$arr_scan_time_h[$i],$arr_scan_time_m[$i],$arr_scan_time_s[$i],$arr_no_slice[$i],$arr_no_echos[$i],$arr_no_dyn[$i],$arr_no_phases[$i],$arr_blob_typ[$i],$arr_blobname[$i];
    }
  } else {			#display rec_scans
    $nr_scans=$num-1;
    print "\n\n\n$term_inv Scan-List of Patient :  $arr_name[$index_pat]
 No     Name       AqNr Sli Ec Dyn Pha| No     Name       AqNr Sli Ec Dyn Pha $term_def
-----------------------------------------------------------------------------\n";
    for ($i=1;$i<$nr_scans/2+1;$i++) {
      $j=$i+int($nr_scans/2+0.5);
      printf "%3d %15.15s %3d%4.4s%3.3s%4.4s%3.3s |",$i,$arr_proto[$i],$arr_acquisition_no[$i],$arr_no_slice[$i],$arr_no_echos[$i],$arr_no_dyn[$i],$arr_no_phases[$i];
      if ($j<=$nr_scans) {
	printf "%3d %15.15s %3d%4.4s%3.3s%4.4s%3.3s \n",$j,$arr_proto[$j],$arr_acquisition_no[$j],$arr_no_slice[$j],$arr_no_echos[$j],$arr_no_dyn[$j],$arr_no_phases[$j];
      } else {
	print"\n";
      }
      if ($i%(int($row)-5)==0) {
	print "$term_inv                          > > > Press ENTER < < <";
	chomp($temp = <STDIN>);
	print " Scan-List of Patient :  $arr_name[$index_pat]
 No     Name       AqNr Sli Ec Dyn Pha| No     Name       AqNr Sli Ec Dyn Pha $term_def
-----------------------------------------------------------------------------\n";
      }
    }
	
  }				#end display rec-scans
    
  do {
    if ($cpx) {
      $cpx_text="with CPX, RAW or LAB-Files";
    }
    if ($nr_scans < 1) {
      print "$term_red No scans $cpx_text\n\nExit pati$term_def\n";exit;
    }
    print "Please select scan (z.B 1,3-6 oder q): ";
    chomp($eingabe=<STDIN>);
    if ($eingabe eq "q") {
      print "Exit pati\n";exit;
    }
    $eingabe=$eingabe.",";
    @auswahl=split(/([,-])/,$eingabe);
    $i=0;
    $j=0;
    $eingabe_ok=1;
    undef @auswahl3;
    do {
      if (($i+3 <= @auswahl) and (0<int($auswahl[$i]))and (int($auswahl[$i])<=$nr_scans) and ($auswahl[$i+1] eq "-") and (0<int($auswahl[$i+2])) and (int($auswahl[$i+2])<=$nr_scans) and ($auswahl[$i+3]eq ",") and ($auswahl[$i]<$auswahl[$i+2])) {
	for ($t=$auswahl[$i];$t<=$auswahl[$i+2];$t++) {
	  $auswahl3[$j]=$t;
	  $j++;
	}
	$i=$i+4;
      } elsif (($i+1 <= @auswahl) and (0<int($auswahl[$i]))and (int($auswahl[$i])<=$nr_scans) and ($auswahl[$i+1] eq ",")) {
	$auswahl3[$j]=$auswahl[$i];
	$i=$i+2;
	$j++;
      } else {
	$eingabe_ok=0;
	print "$term_red Your selection: $eingabe is not valid$term_def\n";
	$i=@auswahl+1;
      }
    } until ($i>=@auswahl);
    if ($eingabe_ok) {
      print "\nSelected Scans from patient $arr_name[$index_pat]:\n";
      foreach $l (@auswahl3) {
	if ($cpx) {
	  printf "%4d %18.18s %8.8s %4.4s:%2.2s %4.4s %18.18s\n",$l,$arr_proto[$l],$arr_study_date[$l],$arr_scan_time_h[$l],$arr_scan_time_m[$l],,$arr_blob_typ[$l],$arr_series_oid[$l];
	} else {
	  printf "x %4d%15.15s %4.4s%4.4s%4.4s%4.4s%4.4s %14.15s\n   %35.36s\n",$l,$arr_proto[$l],$arr_no_slice[$l],$arr_no_echos[$l],$arr_no_dyn[$l],$arr_no_phases[$l],$arr_series_type[$l],$arr_series_oid[$l],$arr_file[$l];
	}
      }
      if (! $no_conf) {
	print "\nOK? (y/n):";
	chomp($temp = <STDIN>);
	if ($temp eq "n") {
	  $eingabe_ok=0;
	}
      }
    }
  } until ($eingabe_ok);
  
  if ($filename_only){
    print "\nNo File saved. Press any key to exit:";
    chomp($temp = <STDIN>);
    if ($temp eq "n") {
      $eingabe_ok=0;
    }
  } else {
    ##Files kopieren und Par-Files generieren
    foreach $index_scan (@auswahl3) {    
      if ($ask_userdef_filename eq 1){
	print "\n\nEnter filename without extension only (a-zA-Z0-9 and \"_\" are allowed!)\nFilename: ";
	chomp($userdef_file_basename=<STDIN>);
	$userdef_file_basename=~s/\W/_/g;
      }
      if (!$soid_only) {
	if ($cpx) {
    	  $pride_vers=4;   #CPX-Parfile exists only for Pride4!!!
          &get_cpx($arr_blobname[$index_scan],$arr_blob_typ[$index_scan]);
          if ($arr_blob_typ[$index_scan] eq "CPX"){
	    &get_par(($arr_series_oid[$index_scan]));
	  }
	} elsif ($arr_series_type[$index_scan] ne 3) {
          &get_par($arr_series_oid[$index_scan]);
          if (!$parfile_only) {
	    &get_rec($arr_file[$index_scan]);
 	  }
	} else {
          &get_screen_shot($arr_series_oid[$index_scan],$arr_file[$index_scan]);
	}
      }
    }				##end foreach $index_scan (@auswahl3)
  }				##end foreach $index_pat (@auswahl2)
}

sub usage {
  print "Usage:  $0 [-i/f] [-nore] [-cpx -par] [-fl {0-3}] [-new] -s Scannername [output_folder]\n
VMS-notation of the Options (/ instade of -) is also accepted.
-i/f : Programm will/will not ask for confirmation
-cpx : copy cpx, raw and lab-Files
-nore: no reorder of Rec-File
-par : Gets only a PAR-File no REC-files (Only possible without -cpx)
-p3/p4/p41/p42 : Creates Pride Par-File Version 3/4/4.1/4.2
-s Scannername
     : If you want to access an other than the default scanner ($node)
       That scanner has to be known by the programm
output_folder: If the files should not be placed in the lokal folder add the 
               destination folder as last argument!
-fl level(0-5) : format of the outputfiles default: $filename_format
       0: pat_name+study_date+scan_name+series_oid 
       1: pat_name+study_date+scan_name+last 4 digits series_oid (unique??)
       2: pat_name+scan_name+last 4 digits series_oid (unique??)
       3: pat_name+study_date+series_oid+scan_name 
       4: pat_name+study_date+series_time+acqu_nr+recon_nr+scan_name 
       5: pat_name+acqu_nr+recon_nr+scan_name 
-new    : User can choose the filebase name !!No extension!!\n
Screendumps will now be downloaded and stored as png (gif under VMS)!\n\n";
  my $eingabe;
  print "Press enter to exit";
  chomp($eingabe=<STDIN>);
  exit;
}


sub mydie{
  my $why=shift;
  chomp $why;
  print "\n\n\n$term_red  !!! Program stopped due to an error.$term_def \nPlease verify output and if needed report errors.\n\n$why\n\n";
  my $eingabe;
  print "Press enter to exit";
  chomp($eingabe=<STDIN>);
  exit 1;
}
