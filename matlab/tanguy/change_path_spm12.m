function change_path_spm12

%% SPM path

% SPM5
spm5_path='/home/global/matlab_toolbox/spm5';

% SPM8
spm8_path='/home/global/matlab_toolbox/spm8';

% SPM12
spm12_path='/home/global/matlab_toolbox/spm12b'


%% listing path
pa=path;
sep=[0 find(pa==':') length(pa)+1];
for i = 1 : length(sep)-1
    p{i,1}=pa(sep(i)+1:sep(i+1)-1);
end


%% looking for spm8 in path

for i = 1 : size(pa,1)
    s8(i)=~isempty(findstr(p{i},spm8_path));
end
s=find(s8==1);
if isempty(s)
    torem={''};
else
    for i = 1 : sum(s8)
        torem{i}=p{s(i)};
    end
end
%% remove spm8 from path

for i = 1 : size(torem,1)
    rmpath(torem{i})
end
clear torem

%% looking for spm5 in path

for i = 1 : size(pa,1)
    s5(i)=~isempty(findstr(p{i},spm5_path));
end
s=find(s5==1);
if isempty(s)
    torem={''};
else
    for i = 1 : sum(s5)
        torem{i}=p{s(i)};
    end
end
%% remove spm5 from path

for i = 1 : size(torem,1)
    rmpath(torem{i})
end


%% add spm12 to path

addpath(spm12_path)


clear all; close all; clc