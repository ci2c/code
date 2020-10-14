#!/usr/bin/perl
#convert Philips Rec-Files to tif
#needs: ImageMagick (ImageMagick-Magick++-5.4.2-2 is OK)
use FindBin;
use lib "$FindBin::Bin";
require 'rec2any.pl';
$format="eps";
$anim=0;
&main_rec2any;
