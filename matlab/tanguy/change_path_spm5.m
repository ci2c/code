function change_path_spm5


%% listing path
pa=path;
sep=[0 find(pa==':') length(pa)+1];
for i = 1 : length(sep)-1
    p{i,1}=pa(sep(i)+1:sep(i+1)-1);
end


%% looking for spm8 in path

for i = 1 : size(pa,1)
    s8(i)=~isempty(findstr(p{i},'/home/global/matlab_toolbox/spm8'));
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

%% looking for spm12 in path

for i = 1 : size(pa,1)
    s12(i)=~isempty(findstr(p{i},'/home/global/matlab_toolbox/spm12'));
end
s=find(s12==1);
if isempty(s)
    torem={''};
else
    for i = 1 : sum(s12)
        torem{i}=p{s(i)};
    end
end
%% remove spm12 from path

for i = 1 : size(torem,1)
    rmpath(torem{i})
end


%% add spm5 to path

addpath('/home/global/matlab_toolbox/spm5')


clear all; close all; clc