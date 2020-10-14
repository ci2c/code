function ControleQualiteElekta_SAG(dicomPath,sequence,threshold,maxDef)
%
%ControleQualiteElekta_SAG allows user to quantify geometrical distorsions in
%three sagittal slices from a DICOM files directory.
%
%Requires: Image Processing Toolbox
%
%Usage: ControleQualiteElekta_SAG(dicomPath,sequence,threshold,maxDef)
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


close all;

%% Set default parameter values %%
if nargin < 3
    threshold = 0;
    maxDef = 4;
end
if nargin < 4
    maxDef = 4;
end

%% Catch list of DICOM files in DICOM path
dicomList = dir(fullfile(dicomPath,'*.dcm'));
if isempty(dicomList)
    dicomList = dir(fullfile(dicomPath,'MR*'));
end

%%  Use 3D DICOM viewer to determine the three quality controlled slices %%
dcm3DViewer(dicomPath);

%% Input the three quality controlled slices numbers %%
prompt={'Enter the number of the first slice selected:','Enter the number of the second slice selected:','Enter the number of the third slice selected:'};
nameI='Input slices for quality control';
numlines=3;
defaultanswer={'0','0','0'};
options.Resize='on';
options.WindowStyle='normal';
answer=inputdlg(prompt,nameI,numlines,defaultanswer,options);
NumSlices= [str2num(answer{1}) str2num(answer{2}) str2num(answer{3})];


%% Set initial values %%
preDetectOK=0;

%% Loop on the number of controlled slices %%
for i = 1:length(NumSlices)
    
    cp = NumSlices(i);
    if (cp == 0) || (cp > size(dicomList,1))
        continue;
    end       
    name = fullfile(dicomPath,dicomList(cp).name);
    
    %% Main loop activated if DICOM image exists %%
    if exist(name)~=0

        %% Setting input parameters for good automated detection of control points %%
        while ~preDetectOK
            pCg=[];
            if sequence=='T1'
                pCg = PreDetection_SAG(name, sequence, threshold, maxDef);
                choice = questdlg('Are you satisfied with the automated detection of control points ?', ...
                 'Preview of the automated detection of control points', ...
                 'Yes','No, switch to T2 detection','Yes');
                % Handle response
                switch choice
                    case 'Yes'
                        preDetectOK = 1;
                    case 'No, switch to T2 detection'
                        sequence='T2'
                        prompt={'Enter the binary image threshold:'};
                        nameI='Input for PreDetection T2';
                        numlines=1;
                        defaultanswer={'0'};
                        options.Resize='on';
                        options.WindowStyle='normal';
                        answer=inputdlg(prompt,nameI,numlines,defaultanswer,options);
                        threshold=str2num(answer{1});
                end
            elseif sequence=='T2'
                pCg = PreDetection_SAG(name, sequence, threshold, maxDef);
                choice = questdlg('Are you satisfied with the automated detection of control points ?', ...
                 'Preview of the automated detection of control points', ...
                 'Yes','No, change the binary image threshold','No, switch to T1 detection','Yes');
                % Handle response
                switch choice
                    case 'Yes'
                        preDetectOK = 1;
                    case 'No, change the binary image threshold'
                        prompt={'Enter the new binary image threshold:'};
                        nameI='Input for PreDetection T2';
                        numlines=1;
                        defaultanswer={'0'};
                        options.Resize='on';
                        options.WindowStyle='normal';
                        answer=inputdlg(prompt,nameI,numlines,defaultanswer,options);
                        threshold=str2num(answer{1});
                    case 'No, switch to T1 detection'
                        sequence='T1'
                end
            end     
            close all;
        end

        %% Automated detection of control points + manual add of missing detected points + manual remove wrong detected points
        Cg = Detection_SAG(name, sequence, threshold, maxDef);   

        %% Sort control points according Y then X rising
        Cgt = Tri_SAG(Cg);      

        %% Compute 3D coordinates of control points + compute theoretical sight + register theoretical onto detected control points
        [R,q,dep,Pf,error,CG,Cth] = Recalage_SAG(name,Cgt);

        %% 2D characterization of geometrical distorsions
        [dY,dZ,dR,Yv,Zv,Ima1info,x0]= Deformations_SAG(name,Pf,CG,Cgt,cp,maxDef);

    end
    
    %% Backup output images before passing to the next controlled slice %%
    f = figure;
    h = uicontrol('Position',[20 20 200 40],'String','Control next slice',...
                  'Callback','uiresume(gcbf)');
    uiwait(gcf); 
    disp('This will print after you click Control next slice');
    close(f);
    
    %% Clear all variables linked to this iteration loop, close all figures and reset PreDetection %%
    clear dY dZ dR Yv Zv Ima1info x0 R q dep Pf error CG Cth Cgt Cg name;
    close all;
    preDetectOK=0;
    
end