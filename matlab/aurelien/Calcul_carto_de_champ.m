clear all;

%format long;

[fid,chemin]=uigetfile('','MultiSelect', 'on');
% [fid,chemin]=uigetfile('');


if ~ischar(fid)
    nbfile=size(fid, 2);
else
    nbfile=1;
end
% Volumemag = zeros(128);

for n = 1:nbfile,
    if nbfile > 1,
        file=strcat(chemin, char(fid(n)));   
    else
        file=strcat(chemin, char(fid));
    end
    
        eval(['header' num2str(n) '=dicominfo(file);']);
        h = 1:nbfile;
            eval(['slope' num2str(n) '=header' num2str(n) '.PerFrameFunctionalGroupsSequence.Item_1.Private_2005_140f.Item_1.Private_2005_100e']);
%             eval(['slope' num2str(n) '=header' num2str(n) '.PerFrameFunctionalGroupsSequence.Item_2.Private_2005_140f.Item_1.Private_2005_100e']);
            eval(['intercept' num2str(n) '=header' num2str(n) '.PerFrameFunctionalGroupsSequence.Item_2.Private_2005_140f.Item_1.Private_2005_100d']);
            eval(['dicomfile' num2str(n) '=dicomread(file);']);
            eval(['dicomfile' num2str(n) '=double(dicomfile' num2str(n) ');']);
%             eval(['dicomfile' num2str(n) '=(dicomfile' num2str(n) '- intercept' num2str(n) ') ./ slope' num2str(n) ';']);
            eval(['dicomfile' num2str(n) '=squeeze(dicomfile' num2str(n) ');']);
end

