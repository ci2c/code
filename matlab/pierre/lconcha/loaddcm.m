function [imaVOL, scaninfo, dcminfo] = loaddcm(FileNames,dir_path)
%function [imaVOL, scaninfo, dcminfo] = loaddcm(FileNames,dir_path)
%
% Inputs:
%   FileNames - cell array containing the file names of images
%   dir_path  - directory of the image files
%
% Outputs:
%   imaVOL    - 3D int16 array of the images
%   scaninfo  - short structure including the most important 
%               info for the volume
%   dcminfo   - dicom header structure relating to
%               the last opened images file /FileNames(end)/ 
%
% Matlab library function for MIA_gui utility. 
% University of Debrecen, PET Center/LB 2003
try
    hm = [];
	if nargin == 0
         [FilesSelected, dir_path] = uigetfiles('*.dcm','Select DICOM file');
          if isempty(FilesSelected);
              imaVOL = [];scaninfo = [];
              return;
          end
          FileNames = sortrows(FilesSelected');
          filename = [dir_path,char(FileNames(1))];
          num_of_files = size(FileNames,1);
		  for i=1:num_of_files
            filelist(i).name = char(FileNames(i));
		  end
		  filelist = filelist';
	elseif nargin == 1
          FilesSelected = FileNames.Images;
          dir_path = FileNames.Path;
          FileNames = sortrows(FilesSelected);
          filename = [dir_path,char(FileNames(1))];
          num_of_files = size(FileNames,1);
		  for i=1:num_of_files
            filelist(i).name = char(FileNames(i));
		  end
		  filelist = filelist';
	elseif nargin == 2
          num_of_files = size(FileNames,1);
          filename = [dir_path,char(FileNames(1))];
	end
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% open DICOM file & get the needed image parameters (scaninfo) 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	hm = msgbox('Dicom opening ...','MIA Info' );
	SetData=setptr('watch');set(hm,SetData{:});
	hmc = (get(hm,'children'));
	set(hmc(2),'enable','inactive');
    pause(1);
	
	dcminfo = dicominfo(filename);
	%
	% get info from dcm file and save them in the scaninfo structure 
	%
    ImgPrcTlbx = ver('images');
    ImgPrcTlbxVersion = str2double(ImgPrcTlbx.Version);
    if ImgPrcTlbxVersion == 4
		if isfield(dcminfo.PatientsName,'GivenName')
            scaninfo.pnm	    = [dcminfo.PatientsName.GivenName,' ',dcminfo.PatientsName.FamilyName];	
		else
            scaninfo.pnm	    = dcminfo.PatientsName.FamilyName;	
		end
    elseif ImgPrcTlbxVersion == 4.2
        if isfield(dcminfo.PatientName,'GivenName')
            scaninfo.pnm	    = [dcminfo.PatientName.GivenName,' ',dcminfo.PatientName.FamilyName];	
		else
            scaninfo.pnm	    = dcminfo.PatientName.FamilyName;	
		end
    end
	scaninfo.brn        = [];
	if isfield(dcminfo,'PatientID')
        scaninfo.rid	    = dcminfo.PatientID;	
	else
        scaninfo.rid	    = [];
	end
	scaninfo.rin	    = [];
	if isfield(dcminfo,'AcquisitionDate')
		if ~isempty(dcminfo.AcquisitionDate)
			scaninfo.daty	    = dcminfo.AcquisitionDate(1:4);
			scaninfo.datm	    = dcminfo.AcquisitionDate(5:6);
			scaninfo.datd       = dcminfo.AcquisitionDate(7:8);
		end
	elseif isfield(dcminfo,'StudyDate')
        if ~isempty(dcminfo.StudyDate)
            scaninfo.daty	    = dcminfo.StudyDate(1:4);
			scaninfo.datm	    = dcminfo.StudyDate(5:6);
			scaninfo.datd       = dcminfo.StudyDate(7:8);
        end
	else
        scaninfo.daty	    = [];
		scaninfo.datm	    = [];
		scaninfo.datd       = [];
	end
	if isfield(dcminfo,'AcquisitionTime')
		if ~isempty(dcminfo.AcquisitionTime)
			scaninfo.timh	    = dcminfo.AcquisitionTime(1:2);
			scaninfo.timm	    = dcminfo.AcquisitionTime(3:4);
			scaninfo.tims	    = dcminfo.AcquisitionTime(5:6);
		end
	elseif isfield(dcminfo,'StudyTime')
        if ~isempty(dcminfo.StudyTime)
            scaninfo.timh	    = dcminfo.StudyTime(1:2);
			scaninfo.timm	    = dcminfo.StudyTime(3:4);
			scaninfo.tims	    = dcminfo.StudyTime(5:6);
        end
	else
        scaninfo.timh	    = [];
		scaninfo.timm	    = [];
		scaninfo.tims	    = [];
	end
	scaninfo.mtm        = [];
	if isfield(dcminfo,'RadiopharmaceuticalInformationSequence')
        if isfield(dcminfo.RadiopharmaceuticalInformationSequence.Item_1,'Radiopharmaceutical')
            scaninfo.iso 	= dcminfo.RadiopharmaceuticalInformationSequence.Item_1.Radiopharmaceutical;
        else
            scaninfo.iso 	= [];
        end
	else
        scaninfo.iso 	= [];
	end
	scaninfo.half       = [];
	scaninfo.trat       = [];
	scaninfo.imfm  	    = [dcminfo.Rows dcminfo.Columns];
	scaninfo.cntx       = [];
	scaninfo.cal        = [];
	scaninfo.min        = [];
	scaninfo.mag        = [];
	if isfield(dcminfo,'PixelSpacing')
        scaninfo.pixsize    = dcminfo.PixelSpacing';
        if length(scaninfo.pixsize) == 2; % pixel size info only for 2D 
           if isfield(dcminfo,'SliceThickness')
                scaninfo.pixsize(3) = dcminfo.SliceThickness;
           else
                scaninfo.pixsize(3) = 0;
           end
       elseif length(scaninfo.pixsize) < 2; % no pixel size info at all
           button = questdlg('No pixel size information was found! Do you want to continue to define them?',...
		'Continue Operation','Yes','No','No');
			if strcmp(button,'No')
                imaVOL = [];
                scaninfo = [];
                return;
            else
                prompt = {['Enter the X size in [mm] :'],['Enter the Y size in [mm] :'],['Enter the Z size in [mm] :']};
				dlg_title = 'Input for pixel sizes';
				num_lines= 1;
				def     = {'1','1','1'};
				scaninfo.pixsize  = str2double(inputdlg(prompt,dlg_title,num_lines,def))';
            end    
       elseif scaninfo.pixsize(3) == 0 % the Z size = 0
             button = questdlg('The Z pixel size is 0! Do you want to continue?',...
		'Continue Operation','Yes','No','No');
			if strcmp(button,'No')
                imaVOL = [];
                scaninfo = [];
                return;
            else
                prompt = {['Enter Z pixel size(mm) /X,Y size are '...
                            ,num2str(scaninfo.pixsize(1)),',',num2str(scaninfo.pixsize(2)),'/ :']};
				dlg_title = 'Input for pixel size';
				num_lines= 1;
				def     = {'1'};
				scaninfo.pixsize(3)  = str2double(inputdlg(prompt,dlg_title,num_lines,def));
            end
		end 
	else
        scaninfo.pixsize = [1 1];
	end
	if isfield(dcminfo,'NumberOfFrames')
        scaninfo.Frames             = dcminfo.NumberOfFrames;
	else
        scaninfo.Frames =1;
	end
	if isfield(dcminfo,'FrameTime')
        FrameTime = dcminfo.FrameTime/1000;%[sec];
        scaninfo.tissue_ts          = [FrameTime:FrameTime:scaninfo.Frames*FrameTime];
        scaninfo.start_times        = [];
        scaninfo.frame_lengths      = FrameTime*ones(1,scaninfo.Frames);
	else
        scaninfo.tissue_ts = [];
        scaninfo.start_times        = [];
        scaninfo.frame_lengths      = [];
	end
	if num_of_files > 1 
        scaninfo.num_of_slice = num_of_files;
	elseif isfield(dcminfo,'NumberOfSlices')
        scaninfo.num_of_slice       = dcminfo.NumberOfSlices;
	else
        scaninfo.num_of_slice       = 1;
	end
	if scaninfo.Frames == scaninfo.num_of_slice
        scaninfo.Frames =1;
	end
	scaninfo.float = 0;
	scaninfo.FileType    = 'dcm';
	%
	% creating the imaVOL
	%
	
	if num_of_files > 1 
        delete(hm);
        imaVOL = int16(zeros(dcminfo.Rows ,dcminfo.Columns,num_of_files));
        % setup the progress bar
        info.color=[1 0 0];
		info.title='dcm slice reading';
		info.size=1;
        info.pos='topleft';
		p=progbar(info);
		progbar(p,0);
        for i=1:num_of_files
            filename = [dir_path,char(FileNames(i))];
            dcminfo = dicominfo(filename);
     
%              disp(' ');
%              disp(char(FileNames(i)));
%              disp(num2str(dcminfo.AcquisitionNumber));
%              disp(num2str(dcminfo.InstanceNumber));
%             disp(dcminfo.SOPInstanceUID);
            SliceImage = dicomread(dcminfo);
            if size(SliceImage,3) > 1 % the slice image should be 2D
                % This is not true in the case of screencaptured dcm images
                disp('');
                disp('The dicom slices are 3D images!. They might be screencapture images.');  
                if ishandle(hm)
                    delete(hm);
                end
                imaVOL = []; scaninfo = []; dcminfo = [];
            end
            if isfield(dcminfo,'RescaleSlope')
                imaVOL(:,:,dcminfo.InstanceNumber) = flipdim(squeeze(int16( ...
                    double(SliceImage)*dcminfo.RescaleSlope + dcminfo.RescaleIntercept ...
                    )),2);
            else
                imaVOL(:,:,dcminfo.InstanceNumber) = flipdim(squeeze(SliceImage),2);
            end
            if mod(i,3) == 0
                progbar(p,round(i/num_of_files*100));drawnow;
            end
        end
        close(p);
    else
        if isfield(dcminfo,'RescaleSlope')
            SliceImage = dicomread(dcminfo);
            if size(SliceImage,3) > 1 % the slice image should be 2D
                % This is not true in the case of screencaptured dcm images
                disp('');
                disp('The dicom slices are 3D images!. They might be screencapture images.');  
                if ishandle(hm)
                    delete(hm);
                end
                imaVOL = []; scaninfo = []; dcminfo = [];
            end
            imaVOL = flipdim(squeeze(int16( ...
                    double(SliceImage)*dcminfo.RescaleSlope + dcminfo.RescaleIntercept ...
                    )),2);
        else
            imaVOL = flipdim(squeeze(SliceImage),2);
        end
        delete(hm);
	end
catch %in case of any error
    ErrorOnDicomOpening = lasterr
    if ishandle(hm)
        delete(hm);
    end
    imaVOL = []; scaninfo = []; dcminfo = [];
end