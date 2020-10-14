function outFilename = anonymizeDicom(filename,wipe);
%
% outFilename = anonymizeDicom(filename,wipe);
%
% This function overwrites the critical patient information in a single
% DICOM file, creating a dummy name that is generated from the first two
% letters of the family and given names, as well as the date of birth, the
% series number and the image number.
%
% - filename : The DICOM file to anonimize
% - wipe     : Set = 1 if you want to delete the original file. 
%              If not specified, it defaults to zero, not deleting the
%              original file, so you will have a duplicate of the file, but
%              with a new file name (outFilename) and anonymized.
%
% Example: outFileName = anonymizeDicom('JohnDoe_5_4.IMA',1)
%
%          >> outFileName = DO_JO_1977_5_4.IMA


if nargin < 2
    wipe = 0;    
end

metadata = dicominfo(filename);
image    = dicomread(filename);

FamilyName = metadata.PatientName.FamilyName;
GivenName  = metadata.PatientName.GivenName;

dummyName         = [FamilyName(1:2) '_' GivenName(1:2) '_' metadata.PatientBirthDate];
newFilename       = [dummyName '_' num2str(metadata.SeriesNumber) '_' num2str(metadata.InstanceNumber) '.IMA'];
metadata.Filename = newFilename;

if isfield(metadata,'OperatorName')
    metadata.OperatorName            = 'TheOperator';
end
if isfield(metadata,'ReferringPhysicianName')
    metadata.ReferringPhysicianName  = 'TheDoc';
end
if isfield(metadata,'PerformingPhysicianName')
    metadata.PerformingPhysicianName = 'TheDoc';
end

metadata.PatientName.FamilyName  = dummyName;
metadata.PatientName.GivenName   = dummyName;


dicomwrite(image,newFilename,metadata);
outFilename = newFilename;


if wipe == 1
   eval(['!del ' filename ]); 
   disp([filename ' was renamed as ' outFilename])
end