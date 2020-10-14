function [out] = read_xls_file(fne,dre)
% read all data from all sheets in an excel file
% function [out] = read_xls_file(fne,dre)
%
% inputs  2 - 2 optional
% fne     xls / xlsx file name            type char
% dre     xls / xlsx file location        type char
% 
% output 1
% out     results structure               type struct
%
% michael arant - Oct 18, 2010

if nargin == 0; [fne dre] = uigetfile('*.xls*','Select Excel file');
elseif nargin == 1; dre = [pwd filesep];
end

% read sheets in file
[typ, sheet] = xlsfinfo([dre fne]);

% read data from sheets in Excel file
for jj = 1:numel(sheet)
    % read sheet
    [num txt cel] = xlsread([dre fne],sheet{jj});

	% rename sheet if needed
	temp = sheet{jj};
	temp(ismember(double(temp), ...
		[33 64 35 36 37 94 38 40 41 123 125 124 96 126 34 59 62 60 46 44 61 45 43 39])) = [];
	temp = deblank(temp);
	temp = strrep(temp,' ','_');
	
	if isempty(temp); temp = 'Default'; end
			
	% check for existing sheet name
	if exist('out','var') && isfield(out,temp)
		fprintf('Sheet "%s" already exists.  Rename Sheet "%s"\n',temp,[temp '1']);
		temp = [temp '1'];
	end
	
	% save data
	out.(temp).num = num;
	out.(temp).txt = txt;
	out.(temp).cel = cel;
end
