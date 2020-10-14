#!/usr/bin/perl
###################################################################
#              Pati V0.99e (Linux/Win32/VMS R9-R12/R1-2.x         #
#                RL 2010 IBT Zuerich (Switzerland)                #
#                     http://www.mr.ethz.ch/                      #
#                     Common used subroutiens                     #
###################################################################
$version_subrout="pati_subrout.pl (18.10.2010)";

sub open_sybase {
  #$_[0] filehandler, $_[1]: isql-request
  #open a filehandler for isql result.
  #sybase request for Win32
  if ($^O eq "MSWin32") {
    my $temp_file=$ENV{tmp}."\\sybase_temp.tmp";
    my $temp_file_out=$ENV{tmp}."\\sybase_temp_out.tmp";
    open(TEMP_FILE,">$temp_file")||die "can't open $temp_file";
    print TEMP_FILE $_[1];
    close(TEMP_FILE);
    system "\"$isql\" $isql_interface -S $host -U $username -P $pswd -w 10000 -i \"$temp_file\" -o \"$temp_file_out\"";
    unlink("$temp_file");
    @daten_isql=open($_[0],"$temp_file_out");
  } elsif ($^O eq "VMS") {
    $syslogin="sys\$login";
    my $temp_file=$ENV{$syslogin}."sybase_temp.tmp";
    my $temp_file_out=$ENV{$syslogin}."sybase_temp_out.tmp";
    open(TEMP_FILE,">$temp_file");
    print TEMP_FILE $_[1];
    close(TEMP_FILE);
    $command="ISQL /server_name=\"$host\" /user=\"$username\" /pass=\"$pswd\" /width=\"10000\" /interface=disk2:[user.rluchin.pati_linux]interfaces. /input=$temp_file /out=$temp_file_out";
    system "$command";
    unlink("$temp_file");
    @daten_isql=open($_[0],"$temp_file_out");
  } else {			#sybase request for Linux
    @daten_isql=open($_[0],"echo \'$_[1]\' | $isql -S $host -U $username -P $pswd -w 10000|");
  }
}

sub read_pat_db {
  # read patient names...
  #  needed:
  #  $isql isql-programm
  #  $host $host_rel
  #  $username
  #  $pswd
  #  Result:
  #  @daten and $num 
  $isql_request='use patientdb
go
select 
  CONVERT(varchar(14),patient.patient_OID)," ^ ", 
  CONVERT(varchar(14),study.study_OID)," ^ ", 
  SUBSTRING(patient.patient_name,1,20)," ^ ", 
  CONVERT(varchar(10),study.study_date,104)
from 
  patient,study
where
  patient.patient_OID=study.patient_OID
order by 
  study.study_date,study.study_OID
go';
  &open_sybase(ISQL,$isql_request);
  $num=1;
  while ($dataset=<ISQL>) {
    @daten=split(/ \^ /,$dataset);
    @daten=~ map (s/^[ ]*//, @daten);
    @daten=~ map (s/\n//,@daten);
    @daten=~ map (s/[ ]*$//, @daten);
    if ($daten[3] ne "") {
      ($arr_poid[$num],$arr_soid[$num],$arr_name[$num],$arr_date[$num])=@daten;
      $num++;
    }
  }
  close (ISQL);
}
#end sub read_pat_db

sub read_scan_db{
  #  needed:
  #  $cpx
  #  $host
  #  $username_ftp
  #  $pswd_ftp
  #  $username
  #  $pswd
  #  $study_oid

  #  Resulte:
  #  $num
  #  several: $arr_...
  if ($cpx) {
    #make a list of all blob-files on the scanner. 
    #No longer needed on R11 (???)
    if (($host_rel eq "r9") or ($host_rel eq "r10")){
      if ($^O eq "VMS") {
        if ($host_rel eq "r9") {
          $dir=$host."::gyro\$disk1:[GYROSCAN.EXAMS.SYBASE.PATIENTDB]";
          $dirblob=$dir."BLOB\*\.";
          @blobs=`dir/nohead/notrail/columns=1 $dirblob`;
          @blobs =~ map (s/\n// , @blobs);
          @blobs =~ map (s/\U\Q$dir\E\E//g , @blobs);
          @blobs =~ map (s/;[0-9]+$// , @blobs);
        } else {
          $dir_com="dir/ftp/full gyropc15.ethz.ch";
          $dir_com=$dir_com."\"$username_ftp $pswd_ftp\"::\"".$host."/bulk/patientdb/sri*b\"";
          @blobs=`$dir_com`;
          @blobs=map(split(/[ ]+/),@blobs);
          @blobs =~ map (s/patientdb\///g , @blobs);
          @blobs =~ map (s/\n// , @blobs);
          @blobs =~ map (s/[ ]+//g , @blobs);
        }
        $list=\@blobs;
      } else {
        if ($file_transfer{$host} ne "win_share") {
          $ftp = Net::FTP->new("$host_ftp", Debug => 0);
          $ftp->login("$username_ftp","$pswd_ftp");
          if ($host_rel eq "r9") {
            $ftp->cwd("DBBULK_DIR");
          }
          $ftp->cwd($file_transfer_dir{$host}."patientdb")||die "can't change to Folder".$file_transfer_dir{$host}."patientdb: $!";
          if ($host_rel eq "r9") {
            $list=$ftp->ls("blob*");
          } else {
            $list=$ftp->ls("sri*b")|| die "ftp: ls sri*b does not work";
          }
        } else {
  	  if ($^O eq "MSWin32"){
	    $add_dir_path=$file_transfer_dir{$host}."\\patientdb\\";
	    @blobs=`dir /b/l $add_dir_path"sri*b"`;
          } else {
	    $add_dir_path=$file_transfer_dir{$host}."/patientdb/";
	    @blobs=`find $add_dir_path -name "sri*b"`;
	    @blobs =~ map (s!$add_dir_path!!g , @blobs);
	  }
          $list=\@blobs;
        }
      }
      foreach $file (@{$list}) {
        $file=~s/\n//;
        $file_id=$file;
        if ($host_rel eq "r9") {
  	  $file_id=~s/^BLOB/blob/;
	  $file_id=~s/\;[0-9]+$//g;
        }
        $blob_file{$file_id}=$file;
      }				#make a list with all filenames of blob files
   }
   $isql_request='use patientdb
go
select 
       CONVERT(varchar(10),study.study_date,104)," ^ ",
       CONVERT(varchar(12),series.series_time,108)," ^ ",
       SUBSTRING(series.protocol_name,1,16)," ^ ",
       CONVERT(varchar(5),series.acquisition_no)," ^ ",
       CONVERT(varchar(5),series.reconstruction_no)," ^ ",
       CONVERT(varchar(4),series.no_slices)," ^ ",
       CONVERT(varchar(3),series.no_echoes)," ^ ",
       CONVERT(varchar(4),series.no_dynamic_scans)," ^ ",
       CONVERT(varchar(3),series.no_phases)," ^ ",';
    if ($host_rel ne "r9") {
      $isql_request=$isql_request.'
       convert(varchar(30),blobs.blob_filename)," ^ ",';
    } else {
      $isql_request=$isql_request.'
       "blob"+convert(varchar(20),blobs.blob_id)+"."," ^ ",';
    }
    $isql_request=$isql_request.'
       CONVERT(varchar(3),blobs.blob_name)," ^ ",
       series.series_OID
    from study,';
    if ($host_rel ne "r9") {
      $isql_request=$isql_request.'exam,';
    }
    $isql_request=$isql_request.'series,blobs 
    where
       ';
    $isql_request=$isql_request."study.study_OID=".$study_oid." AND";
    $isql_request=$isql_request.'
       blobs.blob_in_file=1 AND
       (blob_name="CPX" OR blob_name="RAW" OR blob_name="LAB") AND 
       blobs.parent_id=series.series_OID  AND
       study.study_OID=';
    if ($host_rel eq "r9") {
      $isql_request=$isql_request.'series.study_OID';
    } else {
      $isql_request=$isql_request.'exam.study_OID AND
       exam.exam_OID=series.exam_OID';
    }
    $isql_request=$isql_request.'      
   order by 
       series.series_OID,blobs.blob_id
go
';
    &open_sybase(ISQL,$isql_request);
    
    @main = <ISQL>;
    close (ISQL); 
    
    $num=1;
    foreach $dataset (@main) {
      #print "dataset $dataset"; 
      @daten=split(/ \^ /,$dataset);
      @daten=~ map (s/^[ ]*//, @daten);
      @daten=~ map (s/\n//,@daten);
      @daten=~ map (s/[ ]*$//, @daten);
      if ((($host_rel =~ /r1[12]/) and $daten[9] ne "") or $blob_file{$daten[9]} ne "") {
	($arr_study_date[$num],$arr_scan_time[$num],$arr_proto[$num],$arr_acquisition_no[$num],$arr_reconstruction_no[$num],$arr_no_slice[$num],$arr_no_echos[$num],$arr_no_dyn[$num],$arr_no_phases[$num],$arr_blobname[$num],$arr_blob_typ[$num],$arr_series_oid[$num])=@daten;
	($arr_scan_time_h[$num],$arr_scan_time_m[$num],$arr_scan_time_s[$num])=split(/:/,$arr_scan_time[$num]);
	$num++;
      }
    }
  } else {			#rec-Scans   
    $isql_request='use patientdb
go
select CONVERT(varchar(10),study.study_date,104)," ^ ",
       CONVERT(varchar(12),series.series_time,108)," ^ ",
       SUBSTRING(series.protocol_name,1,16)," ^ ",
       CONVERT(varchar(5),series.acquisition_no)," ^ ",
       CONVERT(varchar(5),series.reconstruction_no)," ^ ",
       CONVERT(varchar(4),series.no_slices)," ^ ",
       CONVERT(varchar(3),series.no_echoes)," ^ ",
       CONVERT(varchar(4),series.no_dynamic_scans)," ^ ",
       CONVERT(varchar(3),series.no_phases)," ^ ",
       image.image_filename," ^ ",
       series.series_OID';
    if ($host_rel ne "r9") {
      $isql_request=$isql_request.'
       ," ^ ",CONVERT(varchar(3),series.series_type)'
    }
    $isql_request=$isql_request.'
from 
   study,';
    if ($host_rel ne "r9") {
      $isql_request=$isql_request.'exam,';
    }
    $isql_request=$isql_request.'series,image
where
';
    $isql_request=$isql_request."study.study_OID=".$study_oid." AND";
    $isql_request=$isql_request.'
       study.study_OID=';
    if ($host_rel eq "r9") {
      $isql_request=$isql_request.'series.study_OID';
    } else {
      $isql_request=$isql_request.'exam.study_OID AND
       exam.exam_OID=series.exam_OID';
    }
    $isql_request=$isql_request.' AND
       series.series_OID=image.series_OID AND
       image.image_no<129
    group by series.series_OID 
    having
';
    $isql_request=$isql_request."study.study_OID=".$study_oid." AND";
    $isql_request=$isql_request.'
       study.study_OID=';
    if ($host_rel eq "r9") {
      $isql_request=$isql_request.'series.study_OID';
    } else {
      $isql_request=$isql_request.'exam.study_OID AND
       exam.exam_OID=series.exam_OID';
    }
    $isql_request=$isql_request.' AND
       series.series_OID=image.series_OID AND 
       image.image_no<129 AND
       min(image.image_no)=image.image_no
    order by image.image_OID 
go';
    &open_sybase(ISQL,$isql_request);
    $num=1;
    while ($dataset=<ISQL>) {
      @daten=split(/ \^ /,$dataset);
      #print $dataset;
      @daten=~ map (s/^[ ]*//, @daten);
      @daten=~ map (s/\n//,@daten);
      @daten=~ map (s/[ ]*$//, @daten);
      if ($daten[8] ne "") {
	($arr_study_date[$num],$arr_scan_time[$num],$arr_proto[$num],$arr_acquisition_no[$num],$arr_reconstruction_no[$num],$arr_no_slice[$num],$arr_no_echos[$num],$arr_no_dyn[$num],$arr_no_phases[$num],$arr_file[$num],$arr_series_oid[$num],$arr_series_type[$num])=@daten;
	$num++;
	($arr_scan_time_h[$num],$arr_scan_time_m[$num],$arr_scan_time_s[$num])=split(/:/,$arr_scan_time[$num]);
      }
    }
    close (ISQL);
  }				#end read db for rec-Scans
}				#end read_scan_db


###copy the screenshots of rel1.2 and convert them to imageformats (currently png)
sub get_screen_shot {	        #needs filename on the scanner als argument!
  #  needed:
  #  $host
  #  $username_ftp
  #  $pswd_ftp
  #  $username
  #  $pswd
  #  $series_oid
  $series_oid=$_[0];
  $filename_scanner=$_[1];
  if ($^O ne "VMS") {
    if ($file_transfer{$host} ne "win_share") {
      $ftp = Net::FTP->new("$host_ftp", Debug => 0);
      $ftp->login("$username_ftp","$pswd_ftp")  || die "\nCan't login with ftp($host $username_ftp $pswd_ftp): $!\!";
      if ($host_rel eq "r9") {
	$ftp->cwd("DBBULK_DIR");
      }
      $ftp->cwd($file_transfer_dir{$host}."patientdb");
      $ftp->binary;
      $test=$ftp->get($filename_scanner)  || die "\ncan't copy file $filename_scanner per ftp: $!\n";
      $ftp->quit;  
    } else {
      $filename_scanner=$file_transfer_dir{$host}."/patientdb/$filename_scanner";
    }
  }
  &get_file_basename;
  if ($screen_shot_image_format eq ""){
    $screen_shot_image_format="png";
  }
  #select: image Nummr, number_cols (x), number_rows (y), number of bits per bytes, number of bytes per pixel, image size, image offset
  $isql_request='use patientdb
go
select
   image.image_no,
   convert(int,series.no_cols),
   convert(int,series.no_rows),
   convert(int,image.bits_allocated),
   convert(int,image.samples_per_pixel),
   convert(int,image.planar_config),
   image.image_bulk_length,
   image.image_bulk_offset
from series,image
where series.series_OID='.$series_oid.' AND
   series.series_OID=image.series_OID
order by image.image_no
go';
  &open_sybase(ISQL,$isql_request);
  $num=0;
  while ($dataset=<ISQL>) {
    $dataset=~ s/^[ ]*//;
    @daten=split(/[ ]+/,$dataset);
    @daten=~ map (s/^[ ]*//, @daten);
    @daten=~ map (s/\n//,@daten);
    @daten=~ map (s/[ ]*$//, @daten);
    if ($daten[7] ne "" and !($daten[1]=~/----/)) {      
      if ($daten[4]==3) {
	$mode_scanner_file[$num]="rgb:";
	if ($daten[5]==1){
	   $add_convert_options[$num]="-interlace plane";
	} else {
	   $add_convert_options[$num]="-interlace none";
	}
	
      } else {
	$mode_scanner_file[$num]="gray:";
	$add_convert_options[$num]="";
      }	  
      $bild_pixel_size[$num]=$daten[3];
      $image_size[$num]=$daten[1]."x".$daten[2];
      $bild_size[$num]=$daten[6];
      $bild_start[$num]=$daten[7];
      $num++;
    }
  }
  if ($num!=0){
    $j=0;
    $stellen=length($num-1);
    open(MAIN,"$filename_scanner") || die "can't open screendump-file";    
    binmode(MAIN);
    while ($j<$num) {
      sysseek(MAIN,$bild_start[$j],0);
      if ($num>1){
	$target="$file_basename"."_".substr("00000000".($j),-$stellen,$stellen);
      } else {
	$target="$file_basename";
      }
      $convert_command_p1="convert -size ".$image_size[$j]." -depth ".$bild_pixel_size[$j]." ".$add_convert_options[$j]." ".$mode_scanner_file[$j];
      $convert_command_p2=" $target\.$screen_shot_image_format";
      if (($^O eq "MSWin32") || ($^O eq "VMS")){
	$convert_command=$convert_command_p1."temp_file_in.tmp".$convert_command_p2;
	open(TARGET,">temp_file_in.tmp") || die "can't write tmp_file (Screenshot))";
      } else {     
	$convert_command=$convert_command_p1."-".$convert_command_p2;
	open(TARGET,"| $convert_command") || die "can't write $screen_shot_image_format-File";
      }
      binmode(TARGET);
      if ($^O eq "VMS") {
        $i=0;
        while ($i<$bild_size[$j]) {
          sysread(MAIN,$bild,512)|| die "screendump: Sourcefile not huge enought";
          syswrite(TARGET,$bild,512);
          $i+=512;
        } 
      } else {
        sysread(MAIN,$bild,$bild_size[$j],0)|| die "screendump: Sourcefile not huge enought";
        syswrite(TARGET,$bild,$bild_size[$j]);
      }
      close(TARGET);
      if ($^O eq "MSWin32" || $^O eq "VMS"){
	system "$convert_command";
	unlink("temp_file_in.tmp");
      }      
      $j++;
      print "wrote screendump: $target\.$screen_shot_image_format\n";  
    }
    close(MAIN);
    if ($file_transfer{$host} ne "win_share") {
      unlink "$filename_scanner";
    }
  }
}


sub get_rec {			#needs filename on the scanner als argument!
  #  needed:
  #  $host
  #  $username_ftp
  #  $pswd_ftp
  #  $username
  #  $pswd
  #  $study_oid
  
  $filename_scanner=$_[0];
  my $temp_file_size=$anzahl_bilder*$bild_size[0]/1024;
  if ($temp_file_size < 1024){
    printf "Size of Rec-File: %.1f kB\n",$temp_file_size;
  } else {
    $temp_file_size=$temp_file_size/1024;
    printf "Size of Rec-File: %.1f MB\n",$temp_file_size;
  }
  if ($^O eq "VMS") {
    if ($host_rel eq "r9") {
      $copy_com="copy ".$host."::\"gyro\$disk1:[GYROSCAN.EXAMS.SYBASE.PATIENTDB]";
    } else {
      $copy_com="copy/ftp/binary gyropc15.ethz.ch";
      $copy_com=$copy_com.'"'.$username_ftp.' '.$pswd_ftp.'"::"/'.$host.'/bulk/patientdb/';
    }
    @test=`$copy_com$filename_scanner\" $filename_scanner `;
  } else {
    if ($file_transfer{$host} ne "win_share") {
      $ftp = Net::FTP->new("$host_ftp", Debug => 0);
      $ftp->login("$username_ftp","$pswd_ftp")  || die "\nCan't login with ftp($host $username_ftp $pswd_ftp): $!\!";
      if ($host_rel eq "r9") {
        $ftp->cwd("DBBULK_DIR");
      }
      $ftp->cwd($file_transfer_dir{$host}."patientdb");
      $ftp->binary;
      $test=$ftp->get($filename_scanner)  || die "\ncan't copy file $filename_scanner per ftp: $!\n";
      $ftp->quit;  
    } else {
      $filename_scanner=$file_transfer_dir{$host}."/patientdb/$filename_scanner";
    }
  }
  &get_file_basename;
  if ($image_reorder) {
    $target="$file_basename.rec"; 
    open(MAIN,"$filename_scanner") || die "can't open rec-file ($filename_scanner)";
    binmode(MAIN);
    open(TARGET,">$target") || die "can't write reordered rec-File";
    binmode(TARGET);
    $start=(times)[0];
    $j=0;
    print"\nStarting reordering (tot: $anzahl_bilder):\n ";
    $display_step=int($anzahl_bilder/25);
    if ($display_step==0){
      $display_step=1;
    }
    while ($j<$anzahl_bilder) {
      if (($j%$display_step==0) or ($j==$anzahl_bilder-1)){
	print "$j ";
	((int($j/$display_step)%15) == 0 and ($j != 0)) && print "\n";
      }
      sysseek(MAIN,$bild_start[$j],0);
      if ($^O eq "VMS") {
        $i=0;
        while ($i<$bild_size[$j]) {
          sysread(MAIN,$bild,512);
          syswrite(TARGET,$bild,512);
          $i+=512;
        } 
      } else {
        sysread(MAIN,$bild,$bild_size[$j],0);
        syswrite(TARGET,$bild,$bild_size[$j]);
      }
      $j++;
    }
    close(MAIN);
    close(TARGET);
    $ende=(times)[0];
    #print $ende-$start."\n";
    print "\n...all images of $target reordered ($anzahl_bilder images)\n\n";
    if ($file_transfer{$host} ne "win_share") {
      unlink "$filename_scanner";
    }
  } else {
    if ($file_transfer{$host} ne "win_share") {
      rename "$filename_scanner","$file_basename.rec";
    } else {
      copy ($filename_scanner, "$file_basename.rec") or die "Copy failed: $!";
    }
  }
}				#end get_rec


sub get_cpx {
  ($filename_scanner,$filename_extension)=($_[0],$_[1]);
  &get_file_basename;
  $target=$file_basename.".".lc($filename_extension);
  if (($host_rel =~ /r1[012]/)) {
    $add_limitation_no_cpx="";
    if ($filename_extension ne 'CPX') {
      $add_limitation_no_cpx=" and blob_name = \"$filename_extension\"";
    }
    $isql_request='use patientdb
go
select "temp_filename",blob_filename,act_blob_size,blob_name from blobs where parent_id IN (select parent_id from blobs where blob_filename="'.$filename_scanner.'") '.$add_limitation_no_cpx.' order by blob_name
go';
    &open_sybase(ISQL,$isql_request);
    $file_num=0;
    while ($dataset=<ISQL>) {
      $dataset=~s/^[ ]*//;
      @daten=split(/[ ]+/,$dataset);
      @daten=~map(s/^[ ]+//,@daten);
      @daten=~map(s/\n//,@daten);
      @daten=~map(s/[ ]*$//,@daten);
      if ($daten[0] eq 'temp_filename') {
        ($_,$arr_blob_filename[$file_num],$arr_blob_act_size[$file_num],$arr_blob_name[$file_num])=@daten;
        $file_num++;
      }
    }
    close(ISQL);
    if ($filename_extension ne 'CPX') {
      $file_num=1;		#Non CPX-Files will have no additional Blobs included
    } else {
      if (($file_num ne 10) && ($file_num ne 9)) {
	print "Falsche CPX-Anzahl ($file_num). Files allenfalls nicht lesbar unter Pride!\n"; 
	print "Only the following files available: ".join(" ",@arr_blob_name)."\n";
	print "Correct would be: CPX PDF_CONTROL_GEN_PARS PDF_CONTROL_PREP_PARS PDF_CONTROL_RECON_PARS PDF_CONTROL_SCAN_PARS PDF_EXAM_PARS PDF_HARDWARE_PARS PDF_PREP_PARS PDF_SPT_PARS RC";
      }
    } 
  }
  if ($^O eq "VMS") {
    if ($host_rel eq "r9") {
      $copy_com="copy ".$host."::gyro\$disk1:[GYROSCAN.EXAMS.SYBASE.PATIENTDB]";
      @test=`$copy_com$filename_scanner $target `;
      print @test;
    } else {
      $copy_com="copy/ftp/binary gyropc15.ethz.ch";
      $copy_com=$copy_com.'"'.$username_ftp.' '.$pswd_ftp.'"::"/'.$host.'/bulk/patientdb/';
      for ($i=0;$i<$file_num;$i++) {
	my $filename_scanner_tmp=$arr_blob_filename[$i];
	@test=`$copy_com$filename_scanner_tmp" $filename_scanner_tmp `;
        print @test;
      }
    }
  } else {
    if ($file_transfer{$host} ne "win_share") {
      $ftp = Net::FTP->new("$host_ftp", Debug => 0);
      $ftp->login("$username_ftp","$pswd_ftp");
      if ($host_rel eq "r9") {
        $ftp->cwd("DBBULK_DIR");
      }
      $ftp->cwd($file_transfer_dir{$host}."patientdb");
      $ftp->binary;
      if ($host_rel eq "r9") {
        $test=$ftp->get($filename_scanner,"$target")  || die "\ncan't copy file per ftp: ftp $filename_scanner -> $target $!\n";
      } else {
        for ($i=0;$i<$file_num;$i++) {
	  $test=$ftp->get($arr_blob_filename[$i],$arr_blob_filename[$i])  || die "\ncan't copy file per ftp: ftp ".$arr_blob_filename." -> $target $!\n";
        }
      }
      $ftp->quit;
    } else {
      for ($i=0;$i<$file_num;$i++) {
        $arr_blob_filename[$i]=$file_transfer_dir{$host}."/patientdb/".$arr_blob_filename[$i];
      }
    }
  }
  if ($host_rel ne "r9") {
    #wrong RAW and LAB-Files size for very large files!
    # use in any case normal file copy
    if (($filename_extension eq "RAW") or ($filename_extension eq "LAB")){
      $i=0; #RAW and LAB are single files!
      if ($file_transfer{$host} ne "win_share") {
        rename $arr_blob_filename[$i],$target;
      } else {
	my $tmp_filesize = -s $arr_blob_filename[$i];
	print "Size of file $target: $tmp_filesize\n";
        copy ($arr_blob_filename[$i],$target) or die "Copy failed: $!";
      }	
    } else {
      if ($^O eq "VMS") {
        $blocksize=512;
      } else {
        $blocksize=2097152;
      }
      open(OUT,">$target");
      binmode(OUT);
      for ($i=0;$i<$file_num;$i++) {
        if ($arr_blob_act_size[$i]>2147483600){
           $arr_blob_act_size[$i]= -s $arr_blob_filename[$i];
	   print "Warning: very large cpx-File. Filesize in database wrong. New value: ".$arr_blob_act_size[$i]."\n";
	}
        open(IN,$arr_blob_filename[$i]);
        binmode(IN);
        my $file_pos=0;
        while ($file_pos<=($arr_blob_act_size[$i]-$blocksize)) {
	  sysread(IN,$data,$blocksize);
  	  syswrite OUT,$data,$blocksize;
	  $file_pos+=$blocksize;
        } 
        sysread(IN,$data,$arr_blob_act_size[$i]-$file_pos);
        syswrite(OUT,$data,$arr_blob_act_size[$i]-$file_pos);
        close(IN);
        if ($file_transfer{$host} ne "win_share") {
          unlink($arr_blob_filename[$i]);
        }
      }
      close(OUT);
    }
  }
  my $target_file_size = -s $target;
  print "New file: $target (size: $target_file_size)\n";
  ($target_file_size>0) || die "Target file size is zero!!!";
  
}    

sub get_file_basename {
  if ($userdef_file_basename) {
    $file_basename=$userdef_file_basename;
  } else {
    $file_basename=$arr_name[$index_pat];
    $file_basename=~s/\W*(\w{1})\W*(\w{1}).*/$1$2/;
    if ($filename_format eq 2) {
      $file_basename=lc("$file_basename"."_".$arr_proto[$index_scan]."_".substr($arr_series_oid[$index_scan],-4,4));
    } elsif ($filename_format eq 1) {
      $file_basename=lc("$file_basename"."_".$arr_study_date[$index_scan]."_".$arr_proto[$index_scan]."_".substr($arr_series_oid[$index_scan],-4,4));
    } elsif ($filename_format eq 3) {
      $file_basename=lc("$file_basename"."_".$arr_study_date[$index_scan]."_".$arr_series_oid[$index_scan]."_".$arr_proto[$index_scan]);
    } elsif ($filename_format eq 4) {
      $temp_scantime=$arr_scan_time[$index_scan];
      $temp_scantime=~s/\.[0-9][0-9]//g;
      $temp_scantime=~s/://g;
      $file_basename=lc("$file_basename"."_".$arr_study_date[$index_scan]."_".$temp_scantime."_".$arr_acquisition_no[$index_scan]."_".$arr_reconstruction_no[$index_scan]."_".$arr_proto[$index_scan]);
    } elsif ($filename_format eq 5) {
      $temp_acqno = $arr_acquisition_no[$index_scan];
      if ($arr_acquisition_no[$index_scan]<10){
	$temp_acqno = join("",'0',$arr_acquisition_no[$index_scan]);
      }
      $temp_recnr = $arr_reconstruction_no[$index_scan];
      if ($arr_reconstruction_no[$index_scan]){
	$temp_recnr = join("",'0',$arr_reconstruction_no[$index_scan]);
      }
      $file_basename=lc("$file_basename"."_".$temp_acqno."_".$temp_recnr."_".$arr_proto[$index_scan]);
    } else {
      my $tmp_series_oid=$arr_series_oid[$index_scan];
      $tmp_series_oid=~s/00/0/g;
      $file_basename=lc("$file_basename"."_".$arr_study_date[$index_scan]."_".$arr_proto[$index_scan]."_".$tmp_series_oid);
    }
    $file_basename=~s/[\W:]//g;
    if ($pride_vers == 4) {
      $file_basename=$file_basename."V4";
    } elsif ($pride_vers == 4.1) {
      $file_basename=$file_basename."V41";
    } elsif ($pride_vers > 4.1) {
      $file_basename=$file_basename."V42";
    }
    $file_basename_wo_folder=$file_basename;
    if ($data_folder ne ""){
      $file_basename=$data_folder."/".$file_basename;
    }
  }
}

sub conv_xyz_2_apfhrl {
  use Math::Trig;
  my (@img_ori,@img_off,@pixel_spacing,@recon_resol);
  my(@row,@col,@norm,@rowcol_to_pat);
  ($img_ori[0],$img_ori[1],$img_ori[2],$img_ori[3],$img_ori[4],$img_ori[5],$img_off[0],$img_off[1],$img_off[2],$pixel_spacing[0],$pixel_spacing[1],$recon_resol[0],$recon_resol[1])=split(/ /,$_[0]);
  
  
  @row=($img_ori[0],$img_ori[1],$img_ori[2]);
  @col=($img_ori[3],$img_ori[4],$img_ori[5]);
  $norm[0]=$row[1]*$col[2]-$row[2]*$col[1];
  $norm[1]=$row[2]*$col[0]-$row[0]*$col[2];
  $norm[2]=$row[0]*$col[1]-$row[1]*$col[0];
  @rowcol_to_pat=(\@row,\@col,\@norm);
  if (((abs($norm[1]) > abs($norm[0])) ||
       ($norm[1]==-$norm[0])) && 
      ((abs($norm[1]) > abs($norm[2])) ||
       ($norm[1]==-$norm[2]))) {
    $view_axis = 'AP',
      $view_axis_value=3;
    @view_matrix[0]=[ 0.0, 0.0, 1.0];
    @view_matrix[1]=[-1.0, 0.0, 0.0];
    @view_matrix[2]=[ 0.0, 1.0, 0.0];
  } else {
    if ((abs($norm[0]) >= abs($norm[1])) &&
	((abs($norm[0]) > abs($norm[2])) || ($norm[0]==-$norm[2]))) {
      $view_axis = "RL";
      $view_axis_value=2;
      @view_matrix[0]=[ 0.0, 0.0,1.0];
      @view_matrix[1]=[ 0.0,-1.0,0.0];
      @view_matrix[2]=[-1.0, 0.0,0.0];
    } else {
      $view_axis = "FH";
      $view_axis_value=1;
      @view_matrix[0]=[ 0.0,-1.0, 0.0];
      @view_matrix[1]=[-1.0, 0.0, 0.0];
      @view_matrix[2]=[ 0.0, 0.0, 1.0];
    }
  }
  
  my @rowcol_to_slice=([ 0,-1,0],[-1, 0,0],[ 0, 0,1]);
  
  #rowcol_to_apat=view_matrix*rowcol_to_slice
  for ($i=0;$i<3;$i++) {
    $rowcol_to_apat[$i][0] = $view_matrix[0][0]*$rowcol_to_slice[$i][0]+ $view_matrix[1][0]*$rowcol_to_slice[$i][1]+ $view_matrix[2][0]*$rowcol_to_slice[$i][2];
    $rowcol_to_apat[$i][1] = $view_matrix[0][1]*$rowcol_to_slice[$i][0]+ $view_matrix[1][1]*$rowcol_to_slice[$i][1]+ $view_matrix[2][1]*$rowcol_to_slice[$i][2];
    $rowcol_to_apat[$i][2] = $view_matrix[0][2]*$rowcol_to_slice[$i][0]+ $view_matrix[1][2]*$rowcol_to_slice[$i][1]+ $view_matrix[2][2]*$rowcol_to_slice[$i][2];
  }
  
  #apat_to_pat=rowcol_to_pat*transpose(rowcol_to_apat)
  
  $apat_to_pat[0][0] = $rowcol_to_pat[0][0]*$rowcol_to_apat[0][0] + $rowcol_to_pat[1][0]*$rowcol_to_apat[1][0]+$rowcol_to_pat[2][0]*$rowcol_to_apat[2][0];
  $apat_to_pat[0][1] = $rowcol_to_pat[0][1]*$rowcol_to_apat[0][0] + $rowcol_to_pat[1][1]*$rowcol_to_apat[1][0]+$rowcol_to_pat[2][1]*$rowcol_to_apat[2][0];
  $apat_to_pat[0][2] = $rowcol_to_pat[0][2]*$rowcol_to_apat[0][0] + $rowcol_to_pat[1][2]*$rowcol_to_apat[1][0]+$rowcol_to_pat[2][2]*$rowcol_to_apat[2][0];
  
  $apat_to_pat[1][0] = $rowcol_to_pat[0][0]*$rowcol_to_apat[0][1] + $rowcol_to_pat[1][0]*$rowcol_to_apat[1][1]+$rowcol_to_pat[2][0]*$rowcol_to_apat[2][1];
  $apat_to_pat[1][1] = $rowcol_to_pat[0][1]*$rowcol_to_apat[0][1] + $rowcol_to_pat[1][1]*$rowcol_to_apat[1][1]+$rowcol_to_pat[2][1]*$rowcol_to_apat[2][1];
  $apat_to_pat[1][2] = $rowcol_to_pat[0][2]*$rowcol_to_apat[0][1] + $rowcol_to_pat[1][2]*$rowcol_to_apat[1][1]+$rowcol_to_pat[2][2]*$rowcol_to_apat[2][1];
  
  $apat_to_pat[2][0] = $rowcol_to_pat[0][0]*$rowcol_to_apat[0][2] + $rowcol_to_pat[1][0]*$rowcol_to_apat[1][2]+$rowcol_to_pat[2][0]*$rowcol_to_apat[2][2];
  $apat_to_pat[2][1] = $rowcol_to_pat[0][1]*$rowcol_to_apat[0][2] + $rowcol_to_pat[1][1]*$rowcol_to_apat[1][2]+$rowcol_to_pat[2][1]*$rowcol_to_apat[2][2];
  $apat_to_pat[2][2] = $rowcol_to_pat[0][2]*$rowcol_to_apat[0][2] + $rowcol_to_pat[1][2]*$rowcol_to_apat[1][2]+$rowcol_to_pat[2][2]*$rowcol_to_apat[2][2];
  
  $sy=-$apat_to_pat[2][0];
  ($sy<-1)&&($sy=-1);
  ($sy>1)&&($sy=1);
  $ang_y=asin($sy);
  $cy=cos($ang_y);
  if (($cy<0.01) and ($cy>-0.01)) {
    $ang_z=0;
    if ($ang_y>0) {
      $ang_y=pi/2;
    } else {
      $ang_y=- pi/2;
    }
    $ang_x = atan2($apat_to_pat[0][1]/$sy,$apat_to_pat[0][2]/$sy);
  } else {
    $ang_x = atan2($apat_to_pat[2][1]/$cy,$apat_to_pat[2][2]/$cy );
    $ang_z = atan2($apat_to_pat[1][0]/$cy,$apat_to_pat[0][0]/$cy );
  }
  $ang_x = -rad2deg($ang_x);
  $ang_y = -rad2deg($ang_y);
  $ang_z = -rad2deg($ang_z);
  (abs($ang_x)<0.005) && ($ang_x=0);
  (abs($ang_y)<0.005) && ($ang_y=0);
  (abs($ang_z)<0.005) && ($ang_z=0);

  $off_rl = $img_off[0]+$pixel_spacing[0]*$recon_resol[0]/2*$row[0]+$pixel_spacing[1]*$recon_resol[1]/2*$col[0];
  $off_ap = $img_off[1]+$pixel_spacing[0]*$recon_resol[0]/2*$row[1]+$pixel_spacing[1]*$recon_resol[1]/2*$col[1];
  $off_fh = $img_off[2]+$pixel_spacing[0]*$recon_resol[0]/2*$row[2]+$pixel_spacing[1]*$recon_resol[1]/2*$col[2];  

  return($view_axis_value,$ang_x,$ang_y,$ang_z,$off_ap,$off_fh,$off_rl);
}

sub get_par {

  #Some definitions of arrays
  %argrc_acq_contrast=(
  "DIFFUSION" => "0",
  "FLOW_ENCODED"=> "1",
  "FLUID_ATTENUATED" => "2",
  "PERFUSION" => "3",
  "PROTON_DENSITY" => "4",
  "STIR" => "5",
  "TAGGING" => "6",
  "T1" => "7",
  "T2" => "8",
  "T2_STAR" => "9",
  "TOF" => "10",
  "UNKNOWN" => "11",
  "MIXED" => "12"
  );
  $prep_dir_name[0]="RL";
  $prep_dir_name[1]="AP";
  $prep_dir_name[2]="FH";

  $pat_pos_name[0]="HFP";
  $pat_pos_name[1]="HFS";
  $pat_pos_name[2]="HFDR";
  $pat_pos_name[3]="HFDL";
  $pat_pos_name[4]="FFP";
  $pat_pos_name[5]="FFS";
  $pat_pos_name[6]="FFDR";
  $pat_pos_name[7]="FFDL";
 
  $scan_mode_name[1]="2D";
  $scan_mode_name[2]="3D";
  $scan_mode_name[3]="MS";
  $scan_mode_name[4]="M2D";

  $series_data_type_name[0]="Image   MRSERIES";
  $series_data_type_name[1]="1";
  $series_data_type_name[2]="COMPLEX";
  $series_data_type_name[3]="3";

  # new Version 3 and Version 4 possible
  $series_oid=$_[0]; 
  if ($cpx) {
    $pride_vers=4;		#CPX-Parfile exists only for Pride4!!!
  }
  if (($host_rel ne "r12") and ($pride_vers>4)){
    $pride_vers=4;
  }
    
  ##Get Par-File...
  if ($^O eq "MSWin32") {
    $crlfpl=""; 
  } else {
    $crlfpl="\cM";
  }
  $isql_request='use patientdb
go
select
    "series_Cardiac_heart_rate = ",CONVERT(varchar(4),heart_rate),char(10),
    "series_Cardiac_low_rr_value = ",CONVERT(varchar(4),low_rr_value),char(10),
    "series_Cardiac_high_rr_value = ",CONVERT(varchar(4),high_rr_value),char(10)
    from series_Cardiac
    where
';
  $isql_request=$isql_request."    series_OID=".$series_oid;
  $isql_request=$isql_request.'
go
';
  $isql_request=$isql_request.'
select
       "Delete until here!!!",char(10),
       "#",char(10),
       ".    Patient name                       :  ",SUBSTRING(patient.patient_name,1,';
  if ($anonym) {
    $isql_request=$isql_request."2";
  } else {
    $isql_request=$isql_request."20";
  }
  $isql_request=$isql_request.'),char(10),
       ".    Examination name                   :  ",CONVERT(varchar(20),SUBSTRING(study.study_description,1,20)),char(10),
       ".    Protocol name                      :  ",CONVERT(varchar(20),SUBSTRING(series.protocol_name,1,20)),char(10),
       ".    Examination date/time              :  ",CONVERT(varchar(10),series.series_date,102),"/",
                                                     CONVERT(varchar(8),series.series_time,108),char(10),';
  if ($pride_vers => 4) {
    $isql_request=$isql_request.'
       ".    Series_data_type                   :  ",CONVERT(varchar(20),series.series_data_type),char(10),';
  }
  $isql_request=$isql_request.'
       ".    Acquisition nr                     :  ",CONVERT(varchar(4),series.acquisition_no),char(10),
       ".    Reconstruction nr                  :  ",CONVERT(varchar(4),series.reconstruction_no),char(10),
       ".    Scan Duration [sec]                :  ",LTRIM(STR(series.scan_duration,10,2)),char(10),
       ".    Max. number of cardiac phases      :  ",CONVERT(varchar(4),series.no_phases),char(10),
       ".    Max. number of echoes              :  ",CONVERT(varchar(4),series.no_echoes),char(10), 
       ".    Max. number of slices/locations    :  ",CONVERT(varchar(4),series.no_slices),char(10),
       ".    Max. number of dynamics            :  ",CONVERT(varchar(4),series.no_dynamic_scans),char(10),
       ".    Max. number of mixes               :  ",CONVERT(varchar(4),series.no_mixes),char(10),';
  if ($pride_vers >= 4) {
    $isql_request=$isql_request.'
       ".    Patient Position                   :  ",CONVERT(varchar(20),series.patient_position),char(10),
       ".    Preparation direction              :  ",CONVERT(varchar(20),series_Stack.stack_preparation_di';
    if ($host_rel ne "r9") {
      $isql_request=$isql_request.'re';
    }
    $isql_request=$isql_request.'),char(10),';
  } else {			#v3
    $isql_request=$isql_request.'
       ".    Image pixel size [8 or 16 bits]    :  ",CONVERT(varchar(4),CONVERT(int,image.bits_allocated)),char(10),';
  }
  $isql_request=$isql_request.'
       ".    Technique                          :  ",CONVERT(varchar(20),SUBSTRING(series.scanning_technique,1,20)),char(10),';
  if ($pride_vers < 4) {
    $isql_request=$isql_request.'
       ".    Scan mode                          :  ",CONVERT(varchar(2),series.mr_acquisition_type),char(10),';
  }
  $isql_request=$isql_request.'
       ".    Scan resolution  (x, y)            :  ",CONVERT(varchar(4),CONVERT(int,series.measurement_scan_res';
  if ($host_rel ne "r9") {
    $isql_request=$isql_request.'ol';
  }
  $isql_request=$isql_request.')),
                                                     CONVERT(varchar(4),CONVERT(int,series.no_phase_enc_steps)),char(10),';
  if ($pride_vers >= 4) {
    $isql_request=$isql_request.'
       ".    Scan mode                          :  ",CONVERT(varchar(2),series.mr_acquisition_type),char(10),';
  } else {			#v3
    $isql_request=$isql_request.'
       ".    Scan percentage                    :  ",LTRIM(STR(CONVERT(integer,series.percent_sampling))),char(10),
       ".    Recon resolution (x, y)            :  ",CONVERT(varchar(4),CONVERT(int,series.no_cols)),
                                                     CONVERT(varchar(4),CONVERT(int,series.no_rows)),char(10),
       ".    Number of averages                 :  ",LTRIM(STR(CONVERT(integer,series.no_averages))),char(10),';
  }
  $isql_request=$isql_request.'
       ".    Repetition time [msec]             :  ",LTRIM(STR(series.repetition_times0,8,2))," ",
                                                     LTRIM(STR(series.repetition_times1,8,2)),char(10),
       ".    FOV (ap,fh,rl) [mm]                :  ",LTRIM(STR(series_Stack.stack_fov_ap,7,2)),
                                                     LTRIM(STR(series_Stack.stack_fov_fh,7,2)),
                                                     LTRIM(STR(series_Stack.stack_fov_rl,7,2)),char(10),';
  if ($pride_vers < 4) {
    $isql_request=$isql_request.'
       ".    Slice thickness [mm]               :  ",LTRIM(STR(image.slice_thickness,10,2)),char(10),
       ".    Slice gap [mm]                     :  ",LTRIM(STR(image.spacing_between_slic';
    if ($host_rel ne "r9") {
      $isql_request=$isql_request.'es';
    }
    $isql_request=$isql_request.'-image.slice_thickness,10,2)),char(10),';
  }
  $isql_request=$isql_request.'
       ".    Water Fat shift [pixels]           :  ",LTRIM(STR(series.water_fat_shift,6,2)),char(10),
       ".    Angulation midslice(ap,fh,rl)[degr]:  ",LTRIM(STR(series_Stack.stack_angulation_ap,8,2)),
                                                     LTRIM(STR(series_Stack.stack_angulation_fh,8,2)),
                                                     LTRIM(STR(series_Stack.stack_angulation_rl,8,2)),char(10),
       ".    Off Centre midslice(ap,fh,rl) [mm] :  ",LTRIM(STR(series_Stack.stack_offcentre_ap,8,2)),
                                                     LTRIM(STR(series_Stack.stack_offcentre_fh,8,2)),
                                                     LTRIM(STR(series_Stack.stack_offcentre_rl,8,2)),char(10),
       ".    Flow compensation <0=no 1=yes> ?   :  ",CONVERT(varchar(2),series.flow_compensation),char(10),
       ".    Presaturation     <0=no 1=yes> ?   :  ",CONVERT(varchar(2),series.presaturation),char(10),';
  if ($pride_vers < 4) {
    $isql_request=$isql_request.'
       ".    Cardiac frequency                  :  series_Cardiac_heart_rate",char(10),
       ".    Min. RR interval                   :  series_Cardiac_low_rr_value",char(10),
       ".    Max. RR interval                   :  series_Cardiac_high_rr_value",char(10),';
  }
  $isql_request=$isql_request.'
       ".    Phase encoding velocity [cm/sec]   :  ",LTRIM(STR(series.pc_velocity0,6,2))," ",
                                                     LTRIM(STR(series.pc_velocity1,6,2))," ",
                                                     LTRIM(STR(series.pc_velocity2,6,2)),char(10),
       ".    MTC               <0=no 1=yes> ?   :  ",CONVERT(varchar(2),series.mtc),char(10),
       ".    SPIR              <0=no 1=yes> ?   :  ",CONVERT(varchar(2),series.spir),char(10),
       ".    EPI factor        <0,1=no EPI>     :  ",CONVERT(varchar(4),series.epi_factor),char(10),';
  if ($pride_vers < 4) {
    $isql_request=$isql_request.'
       ".    TURBO factor      <0=no turbo>     :  ",CONVERT(varchar(4),series.echo_train_length),char(10),';
  }
  $isql_request=$isql_request.'
       ".    Dynamic scan      <0=no 1=yes> ?   :  ",CONVERT(varchar(2),series.dynamic_series),char(10),
       ".    Diffusion         <0=no 1=yes> ?   :  ",CONVERT(varchar(2),series.diffusion),char(10),
       ".    Diffusion echo time [msec]         :  ",LTRIM(STR(series.diffusion_echo_time,10,2)),char(10),';
  if ($pride_vers >= 4.1) {
  $isql_request=$isql_request.'
       ".    Max. number of diffusion values    :  ",CONVERT(varchar(4),series.no_diff_b_values),char(10),
       ".    Max. number of gradient orients    :  ",CONVERT(varchar(4),series.no_diff_grad_orients),char(10),';
  }
  if ($pride_vers == 4.2) {
  $isql_request=$isql_request.'
       ".    Number of label types   <0=no ASL> :  ",CONVERT(varchar(4),series.no_label_types),char(10),';
  }
  if ($pride_vers < 4) {
    $isql_request=$isql_request.'
       ".    Inversion delay [msec]             :  ",LTRIM(STR(series.inversion_time,10,2)),char(10),';
  }
  $isql_request=$isql_request.'char(10),
       "Delete from here!!!",char(10)
    from patient,study,';
  if ($host_rel ne "r9") {
    $isql_request=$isql_request.'exam,';
  }
  $isql_request=$isql_request.'series,';
  if ($pride_vers eq 3) {
    $isql_request=$isql_request.'image,';
  }
  $isql_request=$isql_request."series_Stack
    where series.series_OID=".$series_oid." AND
       study.study_OID=";
  if ($host_rel eq "r9") {
    $isql_request=$isql_request.'series.study_OID';
  } else {
    $isql_request=$isql_request.'exam.study_OID AND
       exam.exam_OID=series.exam_OID';
  }
  if ($pride_vers eq 3) {
    $isql_request=$isql_request." AND
       image.series_OID=$series_oid AND
       image.image_no<129";
  } 
  $isql_request=$isql_request." AND
       series_Stack.series_OID=$series_oid 
    group by series.series_OID 
    having
       series.series_OID=$series_oid AND
       patient.patient_OID=study.patient_OID AND
       study.study_OID=";
  if ($host_rel eq "r9") {
    $isql_request=$isql_request.'series.study_OID';
  } else {
    $isql_request=$isql_request.'exam.study_OID AND
       exam.exam_OID=series.exam_OID';
  }
  $isql_request=$isql_request.' AND
       series.series_OID=series_Stack.series_OID';
  if ($pride_vers eq 3) {
    $isql_request=$isql_request.' AND
       series.series_OID=image.series_OID AND 
       image.image_no<129 AND
       min(image.image_no)=image.image_no';
  }
  $isql_request=$isql_request.' AND
       min(series_Stack.series_Stack_idx)=series_Stack.series_Stack_idx 
go
';
  if (!$cpx) {			#rec-Teil vom PAR-file
    $isql_request=$isql_request.'
select
       CONVERT(varchar(5),image.slice_no),
       CONVERT(varchar(4),image.echo_no),
       CONVERT(varchar(5),image.dynamic_scan_no),
       CONVERT(varchar(3),image.phase_no),
       CONVERT(varchar(3),image.image_type_mr),
       CONVERT(varchar(3),image.scanning_sequence),
       "xxxx ",';
    if ($pride_vers >= 4) {
      $isql_request=$isql_request.'
       CONVERT(varchar(4),CONVERT(int,image.bits_allocated))," ",
       LTRIM(STR(CONVERT(integer,series.percent_sampling)))," ",
       CONVERT(varchar(4),CONVERT(int,series.no_cols))," ",
       CONVERT(varchar(4),CONVERT(int,series.no_rows))," ",'
    }
    $isql_request=$isql_request.'
       SUBSTRING(CONVERT(varchar(27),round(image.rescale_intercept,1)),1,7)," ",
       SUBSTRING(CONVERT(varchar(27),round(image.rescale_slope,5)),1,9)," ",
       SUBSTRING(CONVERT(varchar(38),round(image.scale_slope,12)),1,24)," ",
       SUBSTRING(CONVERT(varchar(27),round(image.window_center,3)),1,6)," ",
       SUBSTRING(CONVERT(varchar(27),round(image.window_width,3)),1,6)," ",';
    if (($host_rel eq "r9") or ($host_rel eq "r10")) {
      $isql_request=$isql_request.'SUBSTRING(CONVERT(varchar(26),round(image.image_angulation_ap,2)),1,5)," ",
       SUBSTRING(CONVERT(varchar(26),round(image.image_angulation_fh,2)),1,5)," ",
       SUBSTRING(CONVERT(varchar(26),round(image.image_angulation_rl,2)),1,5)," ",
       SUBSTRING(CONVERT(varchar(27),round(image.image_offcentre_ap,2)),1,6)," ",
       SUBSTRING(CONVERT(varchar(27),round(image.image_offcentre_fh,2)),1,6)," ",
       SUBSTRING(CONVERT(varchar(27),round(image.image_offcentre_rl,2)),1,6)," ",';
    } else {
      $isql_request=$isql_request.'SUBSTRING(CONVERT(varchar(26),round(0.00,2)),1,5)," ",
       SUBSTRING(CONVERT(varchar(26),round(0.00,2)),1,5)," ",
       SUBSTRING(CONVERT(varchar(26),round(0.00,2)),1,5)," ",
       SUBSTRING(CONVERT(varchar(27),round(0.00,2)),1,6)," ",
       SUBSTRING(CONVERT(varchar(27),round(0.00,2)),1,6)," ",
       SUBSTRING(CONVERT(varchar(27),round(0.00,2)),1,6)," ",';
    }
    if ($pride_vers >= 4) {
      $isql_request=$isql_request.'
       LTRIM(STR(image.slice_thickness,10,2))," ",
       LTRIM(STR(image.spacing_between_slic';
      if ($host_rel ne "r9") {
	$isql_request=$isql_request.'es';
      }
      $isql_request=$isql_request.'-image.slice_thickness,10,2)),';
    }
    if ($host_rel eq "r9") {
      $isql_request=$isql_request.'
       CONVERT(varchar(2),image.image_display_orient),';
    } else {
      $isql_request=$isql_request.'
       CONVERT(varchar(2),"0  "),';
    }
    if (($host_rel eq "r9") or ($host_rel eq "r10")) {
      $isql_request=$isql_request.'
       CONVERT(varchar(2),image.slice_orientation),';
    } else {
      $isql_request=$isql_request.'
       CONVERT(varchar(2),0),';
    }
    $isql_request=$isql_request.'
       CONVERT(varchar(4),image.fmri_status_indicati';
    if ($host_rel =~ /r1[012]/) {
      $isql_request=$isql_request.'on';
    }
    $isql_request=$isql_request.'),
       CONVERT(varchar(3),image.image_type_ed_es),
       SUBSTRING(CONVERT(varchar(26),round(image.pixel_spacing0,3)),1,6)," ",
       SUBSTRING(CONVERT(varchar(26),round(image.pixel_spacing1,3)),1,6)," ",
       SUBSTRING(CONVERT(varchar(26),round(image.echo_time,1)),1,5)," ",
       SUBSTRING(CONVERT(varchar(26),round(image.dyn_scan_begin_time,1)),1,5)," ",
       SUBSTRING(CONVERT(varchar(26),round(image.trigger_time,1)),1,5)," ",
       CONVERT(varchar(6),CONVERT(int,image.diffusion_b_factor)),';
    if ($pride_vers >= 4) {
      $isql_request=$isql_request.'
       LTRIM(STR(CONVERT(integer,series.no_averages)))," ",';
    }
    $isql_request=$isql_request.'
       SUBSTRING(CONVERT(varchar(26),round(series.flip_angle,1)),1,5)," ",';
    if ($pride_vers >= 4) {
      $isql_request=$isql_request.'
       " 0 0 0 ",
       CONVERT(varchar(4),series.echo_train_length)," ",
       LTRIM(STR(series.inversion_time,10,2))," ",';
    }
    if ($pride_vers >= 4.1) {
      $isql_request=$isql_request.'
       CONVERT(varchar(4),image.diff_b_value_no)," ",
       CONVERT(varchar(4),image.diff_grad_orient_no)," ",
       CONVERT(varchar(10),image.acquisition_contrast)," ",
       CONVERT(varchar(4),image.image_type_mr)," ",
       SUBSTRING(CONVERT(varchar(26),round(image.diffusion_direction_ap,3)),1,8)" ",
       SUBSTRING(CONVERT(varchar(26),round(image.diffusion_direction_fh,3)),1,8)," ",
       SUBSTRING(CONVERT(varchar(26),round(image.diffusion_direction_rl,3)),1,8)," ",';
    }
    if ($pride_vers == 4.2) {
      $isql_request=$isql_request.'
       CONVERT(varchar(4),image.label_type+1)," ",';
    }
    $isql_request=$isql_request.'
       CONVERT(varchar(10),image.image_bulk_length), 
       CONVERT(varchar(10),image.image_bulk_offset)';
    if ($host_rel =~ /r1[12]/) {
      $isql_request=$isql_request.',"&:&"
       ,image.image_orientation0,
       image.image_orientation1,
       image.image_orientation2,
       image.image_orientation3,
       image.image_orientation4,
       image.image_orientation5,
       image.image_position0,
       image.image_position1,
       image.image_position2,
       image.pixel_spacing0,
       image.pixel_spacing1,
       CONVERT(int,series.no_cols),
       CONVERT(int,series.no_rows)';
    }
    $isql_request=$isql_request.'
    FROM image,series WHERE 
';
    $isql_request=$isql_request."series.series_OID=".$series_oid;
    $isql_request=$isql_request.'
       AND series.series_OID=image.series_OID
order by image.dynamic_scan_no,';
    if ($host_rel =~ /r12/){
       $isql_request=$isql_request.'image.diff_b_value_no,image.diff_grad_orient_no,'
     }
    $isql_request=$isql_request.'image.slice_no,image.image_type_mr,
         image.scanning_sequence,image.phase_no,';
    if ($pride_vers == 4.2 ){
       $isql_request=$isql_request.'image.label_type,'
     }
    $isql_request=$isql_request.'image.echo_no
go
';
  }				#ende no CPX-Teil von PAR-file
  ##End ISQL par-File request
  #	print $isql_request;
  &get_file_basename;
  $target="$file_basename.par";
  &open_sybase(ISQL,$isql_request);
  @isql=<ISQL>;
  close(ISQL);
#print @isql;
#    print "$main_line";
# print $isql_request;
  @isql=~ map (s/^\s//m, @isql);
  @isql=~ map (s/\n//m, @isql);
  open(TARGET,">$target") || die "can't open parfile ($target): $!";
  if ($cpx) {
    print TARGET "**COMPLEX DATA SET**$crlfpl\n";
  }
  print TARGET "# === DATA DESCRIPTION FILE ======================================================$crlfpl
#$crlfpl
# CAUTION - Investigational device.$crlfpl
# Limited by Federal Law to investigational use.$crlfpl
#$crlfpl
# Dataset name: $file_basename_wo_folder$crlfpl
# Exported by Pati IBT Zuerich Switzerland (http://www.mr.ethz.ch/)$crlfpl
# CLINICAL TRYOUT             ";
    if ($cpx) {
      print TARGET "Research Complex Blob Data    ";
    } else {
      print TARGET "Research image export tool     ";
    }
  if ($pride_vers == 4) {
    print TARGET "V4";
  } elsif ($pride_vers == 4.1) {
    print TARGET "V4.1";
  } elsif ($pride_vers == 4.2) {
    print TARGET "V4.2";
  } else {
    print TARGET "V3";
  }
  ;
  print TARGET "$crlfpl
#$crlfpl
# === GENERAL INFORMATION ========================================================$crlfpl\n";
    $series_Cardiac_heart_rate=0;
  $series_Cardiac_low_rr_value=0;
  $series_Cardiac_high_rr_value=0;

  $main_line="";

  while (!($main_line=~/Delete until here!!!/)) {
    # print "$main_line";
    $main_line=shift(@isql);
    $main_line =~ s/NULL//;
    $main_line =~ s/[ ]*$//;
    $main_line =~ s/\c@//;
    if ($main_line=~/series_Cardiac_heart_rate/) {
      ($_,$series_Cardiac_heart_rate)=split(/ =  /,$main_line);
    } elsif ($main_line=~/series_Cardiac_low_rr_value/) {
      ($_,$series_Cardiac_low_rr_value)=split(/ =  /,$main_line);
    } elsif ($main_line=~/series_Cardiac_high_rr_value/) {
      ($_,$series_Cardiac_high_rr_value)=split(/ =  /,$main_line);
    } 
  }
   # print "$main_line";

 LINE0: while ($main_line=shift(@isql)) {
    #print "2 $main_line\n";
    last LINE0 if (($main_line=~/^ Delete from here/) && ($main_line eq ""));
    $main_line =~ s/NULL//;
    $main_line =~ s/[ ]+$//;
    $main_line =~ s/:$/:   /;
    $main_line =~ s/\c@//;
    $main_line =~ s/series_Cardiac_heart_rate/ $series_Cardiac_heart_rate/;
    $main_line =~ s/series_Cardiac_low_rr_value/ $series_Cardiac_low_rr_value/;
    $main_line =~ s/series_Cardiac_high_rr_value/ $series_Cardiac_high_rr_value/;
    if ($main_line=~/   Examination name  /) {
      if (length($main_line)<45){
        $main_line =~ s/:   /:   NONE/;
      }
    }
    if ($main_line=~/   Series_data_type  /) {
      ($_,$series_data_type_num)=split(/ :  /,$main_line);
      $main_line=".    Series_data_type                   :   ".$series_data_type_name[$series_data_type_num];
    }
    if ($main_line=~/   Preparation direction  /) {
      ($_,$prep_dir_num)=split(/ :  /,$main_line);
      $main_line=".    Preparation direction              :   ".$prep_dir_name[$prep_dir_num];
    }
    if ($main_line=~/   Patient Position  /) {
      ($_,$pat_pos_num)=split(/ :  /,$main_line);
      $main_line=".    Patient Position                   :   ".$pat_pos_name[$pat_pos_num];
    }
    if ($main_line=~/   Scan mode  /) {
      ($_,$scan_mode_num)=split(/ :  /,$main_line);
      $main_line=".    Scan mode                          :   ".$scan_mode_name[$scan_mode_num];
    }
    print TARGET "$main_line$crlfpl\n";
  }
  if ($cpx) {
    print TARGET "COMPLEX BULK DATA$crlfpl\n";
    @stat=stat("$file_basename.cpx");
    print TARGET $stat[7]."$crlfpl\n";
  } else {
    $main_line=shift(@isql);
    $main_line=shift(@isql);
    $main_line=shift(@isql);
    print TARGET        "#$crlfpl
# === PIXEL VALUES =============================================================$crlfpl
#  PV = pixel value in REC file, FP = floating point value, DV = displayed value on console$crlfpl
#  RS = rescale slope,           RI = rescale intercept,    SS = scale slope$crlfpl
#  DV = PV * RS + RI             FP = PV /  SS$crlfpl
#$crlfpl
# === IMAGE INFORMATION DEFINITION =============================================$crlfpl
#  The rest of this file contains ONE line per image, this line contains the following information:$crlfpl
#  $crlfpl
#  slice number                             (integer)$crlfpl
#  echo number                              (integer)$crlfpl
#  dynamic scan number                      (integer)$crlfpl
#  cardiac phase number                     (integer)$crlfpl
#  image_type_mr                            (integer)$crlfpl
#  scanning sequence                        (integer)$crlfpl
#  index in REC file (in images)            (integer)$crlfpl";
      if ($pride_vers >= 4) {
	print TARGET "
#  image pixel size (in bits)               (integer)$crlfpl
#  scan percentage                          (integer)$crlfpl
#  recon resolution (x,y)                   (2*integer)$crlfpl";
			   }
    print TARGET "
#  rescale intercept                        (float)$crlfpl
#  rescale slope                            (float)$crlfpl
#  scale slope                              (float)$crlfpl
#  window center                            (integer)$crlfpl
#  window width                             (integer)$crlfpl
#  image angulation (ap,fh,rl in degrees )  (3*float)$crlfpl
#  image offcentre (ap,fh,rl in mm )        (3*float)$crlfpl";
  if ($pride_vers >= 4) {
    print TARGET "
#  slice thickness                          (float)$crlfpl
#  slice gap                                (float)$crlfpl";
		       }
    print TARGET "
#  image_display_orientation                (integer)$crlfpl
#  slice orientation ( TRA/SAG/COR )        (integer)$crlfpl
#  fmri_status_indication                   (integer)$crlfpl
#  image_type_ed_es  (end diast/end syst)   (integer)$crlfpl
#  pixel spacing (x,y) (in mm)              (2*float)$crlfpl
#  echo_time                                (float)$crlfpl
#  dyn_scan_begin_time                      (float)$crlfpl
#  trigger_time                             (float)$crlfpl
#  diffusion_b_factor                       (float)$crlfpl";
  if ($pride_vers >= 4) {
    print TARGET "
#  number of averages                       (float)$crlfpl";
		       }
    print TARGET "
#  image_flip_angle (in degrees)            (float)$crlfpl";
  if ($pride_vers >= 4) {
    print TARGET "
#  cardiac frequency                        (integer)$crlfpl
#  min. RR. interval                        (integer)$crlfpl
#  max. RR. interval                        (integer)$crlfpl
#  turbo factor                             (integer)$crlfpl
#  inversion delay                          (float)$crlfpl";
		       }
  if ($pride_vers > 4) {
    print TARGET "
#  diffusion b value number    (imagekey!)  (integer)$crlfpl
#  gradient orientation number (imagekey!)  (integer)$crlfpl
#  contrast type                            (string)$crlfpl
#  diffusion anisotropy type                (string)$crlfpl
#  diffusion (ap, fh, rl)                   (3*float)$crlfpl";
		      }
  if ($pride_vers > 4.1) {
    print TARGET "
#  label type (ASL)            (imagekey!)  (integer)$crlfpl";
                      }
    print TARGET "
#$crlfpl
# === IMAGE INFORMATION ==========================================================$crlfpl";
  if ($pride_vers >= 4) {
    print TARGET "
#sl ec dyn ph ty  idx pix % rec size (re)scale     window       angulation      offcentre         thick  gap   info   spacing   echo  dtime ttime    diff avg  flip  freq RR_int  turbo  delay";
    if ($pride_vers > 4) {
      print TARGET " b grad cont anis               diffusion";
    }
    if ($pride_vers > 4.1) {
      print TARGET "      L.ty";
    }
    print TARGET "$crlfpl\n$crlfpl\n";
  } else {
    print TARGET "
#sl ec dyn ph ty  idx (re)scale             window       angulation        offcentre         info     spacing   echo  dtime ttime diff  flip$crlfpl\n$crlfpl\n";
  }
  LINE1: while ($main_line=shift(@isql)) {
      last LINE1 if (($main_line=~/---- /));
    }
    $anzahl_bilder=0;		#Zahlt Bilder-1
  LINE2: while ($main_line=shift(@isql)) {
      last LINE2 if (($main_line=~/ affected/));
      $temp_nr="$anzahl_bilder        ";
      $temp_nr=substr($temp_nr,0,5);
      $main_line=~s/xxxx/$temp_nr/g;
      $temp_line=$main_line;
      $temp_line=~s/\s+/ /g;
      ($temp_line,$slice_orient_r11)=split(/&:&/,$temp_line);
      $slice_orient_r11=~s/^\s//;
      @line_part=split(/\s/,$temp_line);
      $bild_sl[$anzahl_bilder]=$line_part[0];
      $bild_ec[$anzahl_bilder]=$line_part[1];
      $bild_dyn[$anzahl_bilder]=$line_part[2];
      $bild_ph[$anzahl_bilder]=$line_part[3];
      if ($pride_vers >= 4) {
	$bild_scale[$anzahl_bilder]=$line_part[12];
	$line_part[12]=1.0*$line_part[12];
	$line_part[36]=$series_Cardiac_heart_rate;
	$line_part[37]=$series_Cardiac_low_rr_value;
	$line_part[38]=$series_Cardiac_high_rr_value;
	if ($pride_vers==4){
	  $bild_start[$anzahl_bilder]=$line_part[42];
	  $bild_size[$anzahl_bilder]=$line_part[41];
	} elsif ($pride_vers==4.1) {
	  $bild_start[$anzahl_bilder]=$line_part[49];
	  $bild_size[$anzahl_bilder]=$line_part[48];
	} else {
	  $bild_start[$anzahl_bilder]=$line_part[50];
	  $bild_size[$anzahl_bilder]=$line_part[49];
	}
	if ($pride_vers>4){
	  $line_part[43]=$argrc_acq_contrast{$line_part[43]};
	  if ($line_part[43]==""){
	     $line_part[43]=0;
	  }
	}
      } else {
	$bild_scale[$anzahl_bilder]=$line_part[8];
	$bild_start[$anzahl_bilder]=$line_part[30];
	$bild_size[$anzahl_bilder]=$line_part[29];
	$line_part[8]=1.0*$line_part[8];
      }
      #rel1.2/11 conversion of the angulation etc.
      if ($host_rel =~ /r1[12]/) {
	($view_axis,$ang_rl,$ang_ap,$ang_fh,$off_ap,$off_fh,$off_rl)=conv_xyz_2_apfhrl($slice_orient_r11);
	if ($pride_vers >= 4) {
	  $line_part[16]=$ang_ap;
	  $line_part[17]=$ang_fh;
	  $line_part[18]=$ang_rl;
	  $line_part[19]=$off_ap;
	  $line_part[20]=$off_fh;
	  $line_part[21]=$off_rl;
	  $line_part[25]=$view_axis;
	} else {
	  $line_part[12]=$ang_ap;
	  $line_part[13]=$ang_fh;
	  $line_part[14]=$ang_rl;
	  $line_part[15]=$off_ap;
	  $line_part[16]=$off_fh;
	  $line_part[17]=$off_rl;
	  $line_part[19]=$view_axis;
	}
      }
      #end conversion

      $anzahl_bilder++;
      $out_index_temp="%-4.4s";
      if ($line_part[2]>999) {
	$out_index_temp="%-5.5s";
      }
      if ($pride_vers >= 4) {
	$out_par_4_1="";
	if ($pride_vers >= 4.1) {
	  $out_par_4_1=" %2d %4d %-10.10s %-6.6s %7.3g %7.3g %7.3g";
	}
	if ($pride_vers == 4.2) {
	  $out_par_4_1="$out_par_4_1 %2d";
	}
	printf TARGET " %-5.5s%-4.4s$out_index_temp%-3.3s%-3.3s%-2.2s%-6.6s %2d %3d %4d %4d %8.6g %8.6g %9.5e %6d %6d %5.2f %5.2f %5.2f %7.3f %7.3f %7.3f %-7.7s%-7.7s %1d %1d %1d %1d %-6.6s %-6.6s %-6.6s%-6.6s%-6.6s%-5.5s %4d %-6.6s %3d %4d %5d %3d %-5.5s$out_par_4_1$crlfpl\n",@line_part;
      } else {
	printf TARGET " %-5.5s%-4.4s$out_index_temp%-3.3s%-3.3s%-2.2s%-6.6s %8.6g %8.6g %9.5g %6d %6d %5.2f %5.2f %5.2f %7.3f %7.3f %7.3f %1d %1d %1d %1d %-6.6s %-6.6s %-6.6s%-6.6s%-6.6s%-6.6s%-6.6s$crlfpl\n",@line_part;
      }
    }	
    print TARGET "$crlfpl\n# === END OF DATA DESCRIPTION FILE ===============================================$crlfpl\n";
  }				# ende no cpx Teil von PAR-file     
  close(TARGET);
  print "Par-File ($target) created\n"; 
}

return(1);
