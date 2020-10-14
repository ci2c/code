------------------------------------------------------------------


  BM3D demo software for image/video restoration and enhancement  
                   Public release v1.7 (12 Dec 2009) 

------------------------------------------------------------------

Copyright (c) 2006-2009 Tampere University of Technology. 
All rights reserved.
This work should be used only for nonprofit purposes.

Authors:                     Kostadin Dabov
                             Alessandro Foi

BM3D web page:               http://www.cs.tut.fi/~foi/GCF-BM3D


------------------------------------------------------------------
Installation
------------------------------------------------------------------

Unzip both BM3D.zip (contains codes) and BM3D_images.zip (contains 
test images) in a folder that is in the MATLAB path.


------------------------------------------------------------------
Requirements
------------------------------------------------------------------

*) MS Windows (32- or 64-bit CPU) or Linux (32-bit or 64-bit CPU)
    note: CVBM3D supports only 32-bit Windows
*) Matlab v.6.5 or later with installed:
  -- Image Processing Toolbox (for visualization with "imshow"),

------------------------------------------------------------------
What's new in this release
------------------------------------------------------------------
v1.7
 + Add CVBM3D.m script that performs denoising on RGB-videos with
   AWGN
 + Fix VBM3D.m to use declipping in the case when noisy AVI file
   is provided.

v1.6
 + Make few fixes to the "getTransfMatrix" internal function.
   Now, if used with default parameters, BM3D does not require
   neither Wavelet, PDE, nor Signal Processing toolbox.
 + Add support for x86_64 Linux

v1.5.1
 + Fix bugs for older versions of Matlab
 + Add support for 32-bit Linux
 + improve the structure of the VBM3D.m script

v1.5
 + Add x86_64 version of the MEX-files that run on 64-bit Matlab 
   under Windows
 + Add a missing function in BM3DDEB.m
 + Improves some of the comments in the codes
 + Fix a bug in VBM3D when only a input noisy video is provided

v1.4.1
 + Fix a bug in the grayscale-image deblurring codes and make
   these codes compatible with Matlab 7 or newer versions.

v1.4
 + Add grayscale-image deblurring

v1.3
 + Add grayscale-image joint sharpening and denoising

v1.2.1
 + Fix the output of the VBM3D to be the final Wiener estimate 
   rather than the intermedaite basic estimate
 + Fix a problem when the original video is provided as a 3D
   matrix

v1.2.
 + Add grayscale-video denoising files

v1.1.3. 
 + Add support for Linux x86-compatible platforms

v1.1.2. 
 + Fixed bugs related with Matlab v.6.1

v1.1.1. 
 + Fixed bugs related with Matlab v.6 (e.g., "isfloat" was not 
   available and "imshow" did not work with single precision)
 + Improved the usage examples shown by executing "help BM3D"
   or "help CBM3D" MATLAB commands

v1.1. 
 + Fixed a bug in comparisons of the image sizes, which was
   causing problems when executing "CBM3D(1,z,sigma);"
 + Fixed a bug that was causing a crash when the input images are
   of type "uint8"
 + Fixed a problem that has caused some versions of imshow to 
   report an error
 + Fixed few typos in the comments of the functions
 + Made the parameters of the BM3D and the C-BM3D the same

v1.0. Initial version.


------------------------------------------------------------------
Contents
------------------------------------------------------------------

The package comprises these functions

*) BM3D.m        : BM3D grayscale-image denoising [1]
*) CBM3D.m       : C-BM3D RGB-image denoising [2]
*) VBM3D.m       : V-BM3D grayscale-video denoising [3]
*) BM3DSHARP.m   : BM3D-SH3D grayscale-image sharepening & 
                   denoising [4]
*) BM3DDEB.m     : BM3D-DEB grayscale-image deblurring [5]

For help on how to use these scripts, you can e.g. use "help BM3D"
or "help CBM3D".

Each demo calls a pair of MEX-functions. These MEX functions have 
an extensive interface that allows to change all possible 
parameters used in the algorithm from within the corresponding 
M-file. 

The BM3D.m function uses:

*) bm3d_thr.dll   : Step 1 of the algorithm presented in [1],
                    using collaborative hard-thresholding (HT)
*) bm3d_wiener.dll: Step 2 of the algorithm presented in [1],
                    using collaborative Wiener filtering

The CBM3D.m function uses:

*) bm3d_thr_color.dll  : Step 1 of the algorithm presented in [2]
                         using collaborative hard-thresholding and
                         grouping constraint on the chrominances
*) bm3d_wiener_color.dll: Step 2 of the algorithm presented in [2]
                          using collaborative Wiener filtering and
                          grouping constraint on the chrominances


The VBM3D.m function uses:

*) bm3d_thr_video.dll   : Step 1 of the algorithm presented in [3],
                    using collaborative hard-thresholding (HT)
*) bm3d_wiener_video.dll: Step 2 of the algorithm presented in [3],
                    using collaborative Wiener filtering

The BM3DSHARP.m function uses:

*) bm3d_thr_sharpen_var.dll: Implements the BM3D-SH3D joint 
                    sharpening and filtering using BM3D developed 
                    in [4]. 

The BM3DDEB.m function uses:

*) bm3d_thr_colored_noise.dll   : Colored-noise suprression 
                    used in Step 1 in [5],
*) bm3d_wiener_colored_noise.dll: Colored-noise suprression 
                    used in Step 2 in [5],


------------------------------------------------------------------
Publications
------------------------------------------------------------------

[1] K. Dabov, A. Foi, V. Katkovnik, and K. Egiazarian, "Image 
denoising by sparse 3D transform-domain collaborative filtering," 
IEEE Trans. Image Process., vol. 16, no. 8, August 2007.

[2] K. Dabov, A. Foi, V. Katkovnik, and K. Egiazarian, "Color 
image denoising via sparse 3D collaborative filtering with 
grouping constraint in luminance-chrominance space," Proc. IEEE
Int. Conf. Image Process., ICIP 2007, San Antonio, TX, USA, 
September 2007.

[3] K. Dabov, A. Foi, and K. Egiazarian, "Video denoising by 
sparse 3D transform-domain collaborative filtering," Proc.
European Signal Process. Conf., EUSIPCO 2007, Poznan, Poland,
September 2007.

[4] K. Dabov, A. Foi, V. Katkovnik, and K. Egiazarian, "Joint 
image sharpening and denoising by 3D transform-domain 
collaborative filtering," Proc. 2007 Int. TICSP Workshop Spectral 
Meth. Multirate Signal Process., SMMSP 2007, Moscow, Russia, 
September 2007.

[5] K. Dabov, A. Foi, and K. Egiazarian, "Image restoration by 
sparse 3D transform-domain collaborative filtering," Proc.
SPIE Electronic Imaging, January 2008.

------------------------------------------------------------------
Future additions
------------------------------------------------------------------

Image processing techniques based on the BM3D filtering:
- signal-dependent noise removal,

(Updates, examples, publications, presentations, etc. can be found
at  http://www.cs.tut.fi/~foi/GCF-BM3D)


------------------------------------------------------------------
Disclaimer
------------------------------------------------------------------

Any unauthorized use of these routines for industrial or profit-
oriented activities is expressively prohibited. By downloading 
and/or using any of these files, you implicitly agree to all the 
terms of the TUT limited license:
http://www.cs.tut.fi/~foi/GCF-BM3D/legal_notice.html


------------------------------------------------------------------
Feedback
------------------------------------------------------------------

If you have any comment, suggestion, or question, please do
contact Kostadin Dabov at: dabov _at_ cs.tut.fi

