#!/usr/bin/perl
#Convert PAR-Files V3->V4
#Please send Comments/Problems to rluchin@biomed.ee.ethz.ch

use File::Copy;
use English;

while ($ARGV[0] =~ /^-/) {
  $_ = shift @ARGV;
  if (/^-h(elp)?$/) {
    &usage;
  } elsif (/^-copy$/) {
    $hardlink=1;
  } else {
  print "Unknown Option: $_\n";
  &usage;
  }
}

if ($ARGV[0] eq ""){
  &usage;
}

# expand *.par on Windows (standard on Unix)
#disable shortcuts on Windows

if ($^O eq "MSWin32"){
    $hardlink=1;   
    use File::DosGlob;
    @ARGV = map {
                  my @g = File::DosGlob::glob($_) if /[*?]/;
                  @g ? @g : $_;
                } @ARGV;
}

# Test if softlinks are avalable
if ($hardlink eq 0){
  $symlink_exists = eval { symlink("",""); 1 };
  if ($symlink_exists ne 1){
    print "No symbolic link on this operating system.\nThe Rec-File will be copied!\n";
    $hardlink=1;
  }
}

# old Parameters
%oldstrings=(
	     "pat_name" => ".    Patient name",
	     "exam_name" => ".    Examination name",
	     "prot_name" => ".    Protocol name",
	     "exam_date" => ".    Examination date/time",
	     "acq_nr" => ".    Acquisition nr",
	     "recon_nr" => ".    Reconstruction nr",
	     "scan_dur" => ".    Scan Duration",
	     "nr_cardiac" => ".    Max. number of cardiac phases",
	     "nr_echo" => ".    Max. number of echoes",
	     "nr_slice" => ".    Max. number of slices/locations",
	     "nr_dyn" => ".    Max. number of dynamics",
	     "nr_mix" => ".    Max. number of mixes",
	     "pixel_depth" => ".    Image pixel size ",
	     "technique" => ".    Technique",
	     "scan_mode" => ".    Scan mode",
	     "scan_res" => ".    Scan resolution ",
	     "scan_perc" => ".    Scan percentage",
	     "recon_res" => ".    Recon resolution ",
	     "nr_avg" => ".    Number of averages",
	     "tr" => ".    Repetition time ",
	     "fov" => ".    FOV ",
	     "slice_thick" => ".    Slice thickness ",
	     "slice_gap" => ".    Slice gap ",
	     "wf_shift" => ".    Water Fat shift ",
	     "angulation" => ".    Angulation midslice",
	     "off_center" => ".    Off Centre midslice",
	     "flow_comp" => ".    Flow compensation <0=no 1=yes>",
	     "presat" => ".    Presaturation     <0=no 1=yes>",
	     "cardiac_freq" => ".    Cardiac frequency",
	     "min_rr" => ".    Min. RR interval",
	     "max_rr" => ".    Max. RR interval",
	     "enc_veloc" => ".    Phase encoding velocity ",
	     "mtc" => ".    MTC               <0=no 1=yes>",
	     "spir" => ".    SPIR              <0=no 1=yes>",
	     "epi_fact" => ".    EPI factor        <0,1=no EPI>",
	     "turbo_fact" => ".    TURBO factor      <0=no turbo>",
	     "dyn_scan" => ".    Dynamic scan      <0=no 1=yes>",
	     "diff" => ".    Diffusion         <0=no 1=yes>",
	     "diff_te" => ".    Diffusion echo time ",
	     "inv_delay" => ".    Inversion delay ");

#loop over all files
foreach $file (@ARGV) {
  $base_filename=$file;
  $base_filename=~s/\.[Pp][Aa][Rr]//;
  $rec_filename="";
  if ( -f $base_filename."\.rec"){
    $rec_filename=$base_filename."\.rec";
  } elsif ( -f $base_filename."\.REC"){
    $rec_filename=$base_filename."\.REC";
  } elsif ( -f $base_filename."\.Rec"){
    $rec_filename=$base_filename."\.Rec";
  } else {
    print "No recfile for file $file found!!!\n\n";
    exit;
  }

  open(PI,"$file");  #PI old par-file
  $line=<PI>;
  if ($line=~/^\*\*/){
    $line=<PI>;
  }

  $new_base_filename=$base_filename."V4"; #new filename

  $new_par_header="**EXPERIMENTAL PRIDE DATA SET** (Initial Series created by PRIDE_IC)\n";
  $new_par_header="$new_par_header$line";
  my $ver3_file=0;
 LINE0: while ($line=<PI>){
    if ($line=~/^\#/){
      if ($line=~/export tool\s*V3/){
	$ver3_file=1;   #allow only conversion of Vers3 Files
	$line=~s/(export tool\s*)V3/$1V4/;
      }
      $new_par_header="$new_par_header$line";
    } else {
      last LINE0;
    }
    if ($line=~/GENERAL INFORMATION/){
      $new_par_header=$new_par_header."#\n";
      last LINE0;
    }
  }
  if ($ver3_file){
    open(PO,">$new_base_filename\.par");   #new par-File
    print PO $new_par_header;

  LINE1: while ($line=<PI>){  #read upper part of par-File
      $line=~s/\n//;
      $line =~s/\cM//;
    SWITCH: {
	while (($key,$val)=each %oldstrings){
	  if ($line=~/^$val/){
	    ($_,$old_value{$key})=split(/:\s+/,$line);
	    @_=keys %oldstrings;
	    last SWITCH;
	  }
	}
      }
      $old_value{exam_date}=~s/ //g;
      ($old_value{exam_date_date},$old_value{exam_date_time})=split(/\//,$old_value{exam_date});
      if ($line=~/^\# === PIXEL VALUES/){
	last LINE1;
      }
    }
  LINE2: while ($line=<PI>){
      if ($line=~/^\# === IMAGE INF/){
	last LINE2;
      }
    }
    $i=0;
  LINE3: while ($line=<PI>){  #read lower part of par-File
      if ($line=~/^\#/){
	next LINE3;
      }
      $line=~s/^\s+//;
      if ($line == ""){
	next LINE3;
      }
      $line=~s/\s\s+/ /g;
      $line=~s/\n//;
      $line =~s/\cM//;
      my @image_arr_temp=split(/ /,$line);
      $image_arr[$i]=\@image_arr_temp;
      $i++;
    }
    $image_max=$i-1;  #number of images
    
#write rest of new par-Files
    print PO ".    Patient name                       :   $old_value{pat_name}
.    Examination name                   :   $old_value{exam_name}
.    Protocol name                      :   $old_value{prot_name}
.    Examination date/time              :   $old_value{exam_date_date} / $old_value{exam_date_time}
.    Series_data_type                   :   Image
.    Acquisition nr                     :   $old_value{acq_nr}
.    Reconstruction nr                  :   $old_value{recon_nr}
.    Scan Duration [sec]                :   $old_value{scan_dur}
.    Max. number of cardiac phases      :   $old_value{nr_cardiac}
.    Max. number of echoes              :   $old_value{nr_echo}
.    Max. number of slices/locations    :   $old_value{nr_slice}
.    Max. number of dynamics            :   $old_value{nr_dyn}
.    Max. number of mixes               :   $old_value{nr_mix}
.    Patient Position                   :   PRIDE_unknown_position
.    Preparation direction              :   PRIDE_unknown_preparation_direction
.    Technique                          :   $old_value{technique}
.    Scan resolution  (x, y)            :   $old_value{scan_res}
.    Scan mode                          :   $old_value{scan_mode}
.    Repetition time [msec]             :   $old_value{tr}
.    FOV (ap,fh,rl) [mm]                :   $old_value{fov}
.    Water Fat shift [pixels]           :   $old_value{wf_shift}
.    Angulation midslice(ap,fh,rl)[degr]:   $old_value{angulation}
.    Off Centre midslice(ap,fh,rl) [mm] :   $old_value{off_center}
.    Flow compensation <0=no 1=yes> ?   :   $old_value{flow_comp}
.    Presaturation     <0=no 1=yes> ?   :   $old_value{presat}
.    Phase encoding velocity [cm/sec]   :   $old_value{enc_veloc}
.    MTC               <0=no 1=yes> ?   :   $old_value{mtc}
.    SPIR              <0=no 1=yes> ?   :   $old_value{spir}
.    EPI factor        <0,1=no EPI>     :   $old_value{epi_fact}
.    Dynamic scan      <0=no 1=yes> ?   :   $old_value{dyn_scan}
.    Diffusion         <0=no 1=yes> ?   :   $old_value{diff}
.    Diffusion echo time [msec]         :   $old_value{diff_te}
#
# === PIXEL VALUES =============================================================
#  PV = pixel value in REC file, FP = floating point value, DV = displayed value on console
#  RS = rescale slope,           RI = rescale intercept,    SS = scale slope
#  DV = PV * RS + RI             FP = DV / (RS * SS)
#
# === IMAGE INFORMATION DEFINITION =============================================
#  The rest of this file contains ONE line per image, this line contains the following information:
#
#  slice number                             (integer)
#  echo number                              (integer)
#  dynamic scan number                      (integer)
#  cardiac phase number                     (integer)
#  image_type_mr                            (integer)
#  scanning sequence                        (integer)
#  index in REC file (in images)            (integer)
#  image pixel size (in bits)               (integer)
#  scan percentage                          (integer)
#  recon resolution (x,y)                   (2*integer)
#  rescale intercept                        (float)
#  rescale slope                            (float)
#  scale slope                              (float)
#  window center                            (integer)
#  window width                             (integer)
#  image angulation (ap,fh,rl in degrees )  (3*float)
#  image offcentre (ap,fh,rl in mm )        (3*float)
#  slice thickness                          (float)
#  slice gap                                (float)
#  image_display_orientation                (integer)
#  slice orientation ( TRA/SAG/COR )        (integer)
#  fmri_status_indication                   (integer)
#  image_type_ed_es  (end diast/end syst)   (integer)
#  pixel spacing (x,y) (in mm)              (2*float)
#  echo_time                                (float)
#  dyn_scan_begin_time                      (float)
#  trigger_time                             (float)
#  diffusion_b_factor                       (float)
#  number of averages                       (float)
#  image_flip_angle (in degrees)            (float)
#  cardiac frequency                        (integer)
#  min. RR. interval                        (integer)
#  max. RR. interval                        (integer)
#  turbo factor                             (integer)
#  inversion delay                          (float)
#
# === IMAGE INFORMATION ==========================================================
#sl ec dyn ph ty  idx pix % rec size (re)scale     window       angulation      offcentre         thick  gap   info   spacing   echo  dtime ttime    diff avg  flip  freq RR_int  turbo  delay\n\n";

  close (PI);
    for ($i=0;$i<=$image_max;$i++){
      ($recon_res1,$recon_res2)=split(/[ ]+/,$old_value{'recon_res'});
      @data_line=(@{$image_arr[$i]}[0 .. 6],$old_value{'pixel_depth'},$old_value{'scan_perc'},$recon_res1,$recon_res2,@{$image_arr[$i]}[7 .. 17],$old_value{'slice_thick'},$old_value{'slice_gap'},@{$image_arr[$i]}[18 .. 27],$old_value{'nr_avg'},@{$image_arr[$i]}[28],$old_value{'cardiac_freq'},$old_value{'min_rr'},$old_value{'max_rr'},$old_value{'turbo_fact'},$old_value{'inv_delay'});
      if ($data_line[2]>999){
	printf PO " %-4.4s%-4.4s%-5.5s%-3.3s%-2.2s%-2.2s%-6.6s %2d %3d %4d %4d %-8.8s%-8.8s %-9.9s %6d %6d %5.2f %5.2f %5.2f %7.3f %7.3f %7.3f %-7.7s%-7.7s %1d %1d %1d %1d %-6.6s%-6.6s%-6.6s%-6.6s%-6.6s%-5.5s %4d %-6.6s %3d %4d %5d %3d %-5.5s\n",@data_line;
      } else {
	printf PO " %-4.4s%-4.4s%-4.4s%-3.3s%-2.2s%-2.2s%-6.6s %2d %3d %4d %4d %-8.8s%-8.8s %-9.9s %6d %6d %5.2f %5.2f %5.2f %7.3f %7.3f %7.3f %-7.7s%-7.7s %1d %1d %1d %1d %-6.6s%-6.6s%-6.6s%-6.6s%-6.6s%-5.5s %4d %-6.6s %3d %4d %5d %3d %-5.5s\n",@data_line;
      }
    }
    printf PO "\n";
    printf PO "# === END OF DATA DESCRIPTION FILE ===============================================\n";
    
    close(PO); #close new par-File

    if ($hardlink eq 1){  #copy Rec-File
      $copy_ok=copy("$rec_filename","$new_base_filename\.rec");
    } else {              #softlink Rec-File
      $copy_ok=symlink("$rec_filename","$new_base_filename\.rec");
    }
    if (!$copy_ok){
      print "Error copy file...\n";
    } else {
      print "File $file converted!\n";
    }
  } else {
    close (PI);
    print "File not Version 3: Not converted!!!\n";
  }
}
  
  
  sub usage {
    print "Usage: $0 [-h] filename[s]\n";
    print "filename[s]: enter the par-File!\n";
    print "-h Help\n";
    print "-copy copy rec-Files (Unix: default softlink)\n";
    print "      under Windows it will allways copy the files\n\n";
    if ($^O eq "MSWin32"){
      print "                   > > > Press ENTER to Exit< < <";
      chomp($temp = <STDIN>);
    }
    exit;
}
