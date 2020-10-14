#!/usr/bin/perl
#convert Philips Rec-Files to different File formats
# Version 0.2
# http://www.mr.ethz.ch/~rluchin/
#needs: ImageMagick (ImageMagick-Magick++-5.4.2-2 is OK)
#       http://www.imagemagick.org/
#needs: gifsicle for all gif-outputs (to optimize gif-images!)
#       http://www.lcdf.org/gifsicle/

sub main_rec2any{

local $SIG{__DIE__} = \&mydie;

  $comment_in_image="Converted by rec2any.pl. (http://www.mr.ethz.ch/)"; 
  while ($ARGV[0] =~ /^-/) {
    $_ = shift @ARGV;
    if (/^-h(elp)?$/) {
      &usage;
    } elsif (/^-size$/) {
      $temp_image_size = shift @ARGV;
    } elsif (/^-outsize$/) {
      $temp_out_image_size = shift @ARGV;
    } elsif (/^-delay$/) {
      $temp_delay = shift @ARGV;
    } elsif (/^-nopar$/) {
      $no_par = 1;
    } else {
      print "Unkonown Option: $_\n";
      &usage;
    }
  }
  $image_size="";
  if ($temp_image_size =~ /^[0-9]+x[0-9]+$/) {
    $image_size=$temp_image_size;
  }
  $out_image_size="";
  if ($temp_out_image_size =~ /^[0-9]+x[0-9]+$/) {
    $out_image_size=$temp_out_image_size;
  } 
  $delay="3";
  if ($temp_delay =~ /^[0-9]+$/) {
    $delay=$temp_delay;
  }
  

  foreach $file (@ARGV) {
    $base_filename=$file;
    $base_filename=~s/\.[Rr][Ee][Cc]//;
    $par_filename="";
    if ( -f $base_filename."\.par") {
      $par_filename=$base_filename."\.par";
    } elsif ( -f $base_filename."\.PAR") {
      $par_filename=$base_filename."\.PAR";
    } elsif ( -f $base_filename."\.Par") {
      $par_filename=$base_filename."\.Par";
    }
    $temp_image_size="";
    if ($par_filename eq "" or $no_par eq 1) {
      if ($image_size ne "") {
	$temp_image_size=$image_size;
      } else {
	$temp_image_size="256x256";
      }
    } else {
      open(PAR,"$par_filename")|| die $!;
    LINE: while ($line=<PAR>){
	if ($line=~/Image pixel size/) {
	  $pixelsize=$line;
	  $pixelsize=~s/.+:\s+([0-9]+).*$/$1/;
	}
	last LINE if ($line=~/Recon resolution/);
	if ($line=~/#\s*sl\s+ec\s+dyn\s+ph/) {
	  $line=<PAR>;
	  if ($line!=~/s*[0-9]+/) {
	    $line=<PAR>;
	  }
          $line=~s/\s*[0-9]+\s+[0-9]+\s+[0-9]+\s+[0-9]+\s+[0-9]+\s+[0-9]+\s+[0-9]+\s+([0-9]+)\s+[0-9]+\s+([0-9]+)\s+([0-9]+).+$/$1 a: $2 $3/;
	  ($pixelsize,$line)=split(/ a/,$line);
	  last LINE;
	}
      }
      close(PAR);
      $pixelsize=1*$pixelsize;
      $line=~s/.*:\s+([0-9]+)\s+([0-9]+)\s*$/$1x$2/;
      $temp_image_size=$line;
    }
    if ($out_image_size eq "") {
      $temp_out_image_size=$temp_image_size;
    } else {
      $temp_out_image_size=$out_image_size;
    }
    if ($anim) {
      print "\nconvert $file to $base_filename.$format ($temp_image_size -> $temp_out_image_size)...\n";
       system("convert -comment \"$comment_in_image\" -geometry $temp_out_image_size -endian LSB -size $temp_image_size -delay $delay -depth $pixelsize -normalize gray:\"$file\" \"$base_filename.$format\"");
   } else {
      $temp_format="";
      if ($format eq "eps") {
	$temp_format="eps2:";
      }
      print "\nconvert $file to $base_filename\_xxx.$format ($temp_image_size -> $temp_out_image_size)...\n";
      system("convert -comment \"$comment_in_image\" -geometry $temp_out_image_size -endian LSB -size $temp_image_size -depth $pixelsize -normalize +adjoin gray:\"$file\" \"$temp_format$base_filename\_%03d.$format\"");
    }
    if ($format eq "gif") {
      print "Optimize gif-Images in size.\n";
      if ($anim) {
	#system("gifsicle --batch --optimize $base_filename.gif");
      } else {
	#system("gifsicle --batch --optimize $base_filename\_*.gif");

      }
    }
  }
}  

sub usage{
  @command=split(/\//,$0);
  $command=$command[-1];
  print "Usage:\n  $command [-size image_size -outsize out_image_size] filename(n)\n\n";
  print "e.g: $command -size 256x256 -outsize 128x128 test1.rec test2.rec\n\n";
  print "-h      : Help\n";
  print "-size   : No -size option is needed if a par-File is available.\n";
  print "-outsize: If -outsize option is missing, the same value as -size is used.\n";
  print "-nopar  : If the parameter -nopar is mentioned the par-file will not be used (needed if par-File should not be used!)\n";
  print "-delay  : delay in 1/100sec in case of animation (animated gif/mpeg)\n\n";        
  my $eingabe;
  print "Press enter to exit";
  chomp($eingabe=<STDIN>);
  exit;
}

sub mydie{
  my $why=shift;
  chomp $why;
  print "\n\n\n\ !!! Program stopped due to an error.\nPlease verify output and if needed report errors.\n\n$why\n\n";
  my $eingabe;
  print "Press enter to exit";
  chomp($eingabe=<STDIN>);
  exit 1;
}

return(1);


