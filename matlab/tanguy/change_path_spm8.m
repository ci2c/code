function change_path_spm8


%% listing path
pa=path;
sep=[0 find(pa==':') length(pa)+1];
for i = 1 : length(sep)-1
    p{i,1}=pa(sep(i)+1:sep(i+1)-1);
end


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
clear torem

%% looking for spm5 in path

for i = 1 : size(pa,1)
    s5(i)=~isempty(findstr(p{i},'/home/global/matlab_toolbox/spm5'));
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


%% add spm8 to path

addpath('/home/global/matlab_toolbox/spm8')


clear all; close all; clc