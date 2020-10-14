%==========================================================================
% Author        Amol Pednekar
%               MR Clinical Science
%               Philips medical systems
%               9/8/2009
%==========================================================================
function varargout =  DelineateLV(varargin)
% Global PRIDE XML info
global PRIDE
PRIDE.XML_TEMPLATE         =  'PRIDE_Series_Template.XML';
% XML tag names
PRIDE.XML_HEADER           =  'PRIDE_V5';
PRIDE.XML_SERIES_HEADER    =  'Series_Info';
PRIDE.XML_IMAGE_ARR_HEADER =  'Image_Array';
PRIDE.XML_IMAGE_HEADER     =  'Image_Info';
PRIDE.XML_IMAGE_KEY_HEADER =  'Key';
PRIDE.XML_ATTRIB_HEADER    =  'Attribute';
% Data dimensions
PRIDE.read_type = [];
PRIDE.Xres = 0;
PRIDE.Yres = 0;
PRIDE.imageSize_bytes = 0;
PRIDE.maxSlice = 0;
PRIDE.maxPhase = 0;
% Determine the running location and clean up input output directories
consolePath = 'C:\Program Files (x86)\PMS\Mipnet42';
run_location = pwd;
if (strcmp(run_location,consolePath)) % On console
    cd('G:\patch\PRIDE');
    fprintf('%s Recognized console ...',pwd);
    p = inputParser;
    p.addRequired('roid', @ischar);
    try % Checl
        p.parse(varargin{:});
        source_location = 'G:\patch\PRIDE\tempinputseries';
        destination_location = 'G:\patch\PRIDE\tempoutputseries';
        % Clean up source and destination locations for XML/REC
        if (exist(source_location,'dir')==7)
            cd(source_location);
            delete('*');
            cd(run_location);
        else
            mkdir(source_location);
        end
        if (exist(destination_location,'dir')==7)
            cd(destination_location);
            delete('*');
            cd(run_location);
        else
            mkdir(destination_location);
        end
        % Export XML/REC using leacher
        leacher_location = 'c:\Program Files (x86)\PMS\Mipnet42\pridexmlleacher_win_cs.exe';
        system_command_string = sprintf('"%s" %s',leacher_location, p.Results.roid);
        [status,result] = system(system_command_string);
        if(status)
            fprintf('system_command_string = %s\nstatus = %d\nresult=\n%s', system_command_string, status, result);
            exit;
        end
        % Get XML/REC file names
        xmlNames = dir([source_location filesep '*.XML']);
        xmlFileName = xmlNames(1).name;
        % Ouput XML/REC file names
        xmlOutFileName = [destination_location filesep xmlFileName];
        recOutFileName = [destination_location filesep [xmlFileName(1:(end-4)) '.REC']];
        %         fprintf('%s \n%s',xmlOutFileName, recOutFileName);
        %         pause;
        xmlFileName = strcat('G:\patch\PRIDE\tempinputseries\',xmlFileName);
        recFileName = [xmlFileName(1:(end-4)) '.REC'];
    catch e
        report_error(e);
    end
else % Not on console
    fprintf('Not a console ...');
    if nargin < 1
        [fname,pname] = uigetfile('*.XML','Select *.XML file');
    end
    xmlFileName = sprintf('%s',pname,fname);
    recFileName = [xmlFileName(1:(end-4)) '.REC'];
    destination_location = strcat(run_location,'\tempoutputseries');
    if (exist(destination_location,'dir')==7)
        cd(destination_location);
        delete('*');
        cd(run_location);
    else
        mkdir(destination_location);
    end
    % Ouput XML/REC file names
    xmlOutFileName = [destination_location filesep fname];
    recOutFileName = [destination_location filesep [fname(1:(end-4)) '.REC']];
end

%% Read in and validate the cine data
% Get PRIDE XML tree
inTree = xmlread(xmlFileName);
% Sanity check
OK = isPRIDEseries(inTree);
% Extract series information
[seriesStruct, seriesDims] = getXMLSeriesInfo(inTree);
% Extract image information
% (only from the first image as sample)
imageStruct = getXMLImageInfo(inTree);
% Generate image keys for data navigation
[numImages, imageIndx, imageDims] = createXMLImageIndx(inTree);
% Compute image size
pixel_bits = double(imageStruct.Pixel_Size);
switch (pixel_bits)
    case { 8 }, read_type = 'int8';
    case { 16 }, read_type = 'short';
    otherwise, read_type = 'uchar';
end
PRIDE.read_type = read_type;
PRIDE.Xres = double(imageStruct.Resolution_X);
PRIDE.Yres = double(imageStruct.Resolution_Y);
PRIDE.imageSize_bytes = PRIDE.Xres*PRIDE.Yres*pixel_bits/8;
PRIDE.maxSlice = seriesStruct.Max_No_Slices;
PRIDE.maxPhase = seriesStruct.Max_No_Phases;
PRIDE.Slice_Gap = double(imageStruct.Slice_Gap);
% Validate REC file size
REC_OK = validateREC(recFileName, numImages, PRIDE.imageSize_bytes);

%% Perform LV segmentation

% Any application can go here

% % Crop all cine images
% [AllCroppedCine, rect] = load_croppedCine(recFileName);
% contouredImg = contourLV(AllCroppedCine, rect);
%% Write resultant images
% Update series information
% Create XML tree and fill series information
outTree = createXML(seriesStruct);
% Write REC file
MaxSl = size(contouredImg,3); MaxPh = size(contouredImg,4);
seriesStruct.Max_No_Slices = MaxSl; seriesStruct.Max_No_Phases = MaxPh;
for NoSl = 1:MaxSl
    for NoPh = 1:MaxPh
        imageDims.Slice = NoSl; imageDims.Phase = NoPh;
        imageStruct.Slice = NoSl; imageStruct.Phase = NoPh;
        imageStruct.Index = ((NoSl-1)*MaxPh)+NoPh-1;
        imageStruct.Resolution_X = size(AllCroppedCine,1);
        imageStruct.Resolution_Y = size(AllCroppedCine,2);
        % Add image information to XML
        outTree = addImageToXML(outTree,imageStruct);
        keyString = ['key_' num2str(imageDims.Slice) '_'  num2str(imageDims.Echo)...
            '_'  num2str(imageDims.Dynamic) '_'  num2str(imageDims.Phase)...
            '_'  num2str(imageDims.BValue) '_'  num2str(imageDims.Grad_Orient)...
            '_'  char(imageDims.Label_Type) '_'  char(imageDims.Type)...
            '_'  char(imageDims.Sequence)...
            ];
        Fid = fopen(recOutFileName,'a','l');
        outImage = reshape(contouredImg(:,:,NoSl,NoPh),size(AllCroppedCine,1),size(AllCroppedCine,2));
        fwrite(Fid,outImage, PRIDE.read_type);
        fclose(Fid);
    end
end
% Write XML file
xmlwrite(xmlOutFileName,outTree);
fprintf('Tool run successful...');
% pause;
% if (strcmp(run_location,consolePath)) % On console
if (~isempty(strfind(run_location, 'C:\Vedamol\')))
    exit;
end
%% Display all contoured images
scrsz = get(0,'ScreenSize');
figure('Position',[1 1 scrsz(3) scrsz(4)]);
for slNo = 1:size(contouredImg,3)
    for phNo = 1:size(contouredImg,4)
        set(gcf, 'Position',[1 1 scrsz(3) scrsz(4)]);hold on;
        imshow(reshape(contouredImg(:,:,slNo,phNo),size(AllCroppedCine,1),size(AllCroppedCine,2)),[]);hold on;
        set(gcf, 'Position',[1 1 scrsz(3) scrsz(4)]);hold on;
        pause(0.05);
    end
end
%% Display all images
% Fid = fopen(RECfilename,'r','l');
% for imgNo = 1:numImages
%     fseek(Fid,(imgNo-1)*imageSize_bytes, 'bof');
%     image = reshape(fread(Fid,Xres*Yres,read_type),Xres,Yres);
%     imshow(image,[]);
%     pause(0.005);
% end
% fclose(Fid);
%% Ensure REC file size matches expected number of images
function OK = validateREC(RECfilename, numImages, imageSize)
RecFileInfo = dir(RECfilename);
RecFileSize = RecFileInfo.bytes;
if (RecFileSize ~= numImages*imageSize)
    disp(sprintf('Expected %d bytes.  Found %d bytes',imageSize,RecFileSize));
    if (RecFileSize > imageSize)
        error('.REC file has more data than expected from .XML file')
    else
        error('.REC file has less data than expected from .XML file')
    end
else
    OK = 1;
    disp(sprintf('.REC file size consistent with that expected from .XML file'));
end
%% Popup error message
function report_error (e)
error_message_str = sprintf('message = %s\nidentifier = %s', e.message, e.identifier);
for k=1:length(e.stack),
    error_message_str = sprintf('%s\n\nfile=%s\nname=%s\nline=%d', error_message_str, e.stack(k).file, e.stack(k).name, e.stack(k).line);
end
herror = errordlg(error_message_str, 'PRIDE Research Matlab example: ERROR');
waitfor(herror);
if isdeployed,
    exit;
end