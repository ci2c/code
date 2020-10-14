function FMRI_SplitActivationDetection(splitMat,outdir,prefix,num)

TApath = '/home/notorious/NAS/renaud/TotalActivation/TotalActivationTool';
addpath(genpath(TApath));

load(splitMat,'d','p','roi');

dtmp = d{num};
ptmp = p{num};
tic;
[TC_OUT,ptmp] = MySpatial(dtmp,roi,ptmp);
time2 = toc;

% disp(' ');
% disp(['IT TOOK ', num2str(time2), ' SECONDS FOR SPATIO_TEMPORAL REGULARIZATION OF ', num2str(ptmp.NbrVoxels), ' TIMECOURSES']);
% disp(' ');
ptmp.time=time2;


%% POST-PROCESSING

TC_D_OUT  = zeros(ptmp.Dimension(4),ptmp.NbrVoxels); % ACTIVITY-INDUCING SIGNAL
TC_D2_OUT = zeros(ptmp.Dimension(4),ptmp.NbrVoxels); % innovation signal

for i=1:ptmp.NbrVoxels,
	TC_D_OUT(:,i) = filter_boundary(ptmp.f_Recons.num,ptmp.f_Recons.den,TC_OUT(:,i),'normal');
    if strcmpi(ptmp.METHOD_TEMP,'block') || strcmpi(ptmp.METHOD_TEMP,'wiener')
        TC_D2_OUT(:,i) = [0;diff((TC_D_OUT(:,i)))];
%        TC_D_OUT2(:,i) = cumsum([zeros(5,1); TC_D2_OUT(6:end,i)]);  %Neglect the first 5 volumes?? sometimes shifts the response...
    end
end

save(fullfile(outdir,[prefix '_' num2str(num) '.mat']),'dtmp','TC_OUT','TC_D_OUT','TC_D2_OUT','ptmp');