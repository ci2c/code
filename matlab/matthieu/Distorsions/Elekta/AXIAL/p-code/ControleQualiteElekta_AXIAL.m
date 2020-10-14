function ControleQualiteElekta_AXIAL(dicomPath,sequence,threshold,maxDef)
%
%ControleQualiteElekta_AXIAL allows user to quantify geometrical distorsions in
%three axial slices from a DICOM files directory.
%
%Requires: Image Processing Toolbox
%
%Usage: ControleQualiteElekta_AXIAL(dicomPath,sequence,threshold,maxDef)
%   
%   Arguments :
%       dicomPath                       : DICOM files directory
%       sequence                        : Enter the type of sequence ('T1' or 'T2')
% 
%   Optional arguments :
%       threshold (default : 0)         : Threshold to binarize T2 DICOM file
%       maxDef (default : 4)            : distorsion maximum accepted
%
% 
%Author: Matthieu Vanhoutte - CHRU Lille
%email: matthieuvanhoutte@gmail.com
%Release: 1.0
%Date: August 22, 2014
%