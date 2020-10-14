% script to generate test data set and call vi_tool
closeall

load test_ims;
ims = abs(ims);

imagescn(squeeze(ims(:,:,3,:)), [1 120], [2 2], 8);
colormap(gray)

% fig =gcf;
% h_axis = flipud(findobj(fig, 'Type', 'Axes'));
% 
% for i = 1:length(h_axis)
% 	setappdata(h_axis(i), 'ImageData', squeeze(ims(:,:,:,i)));
% 	setappdata(h_axis(i), 'ImageRange', [ 1 16]);
% 	setappdata(h_axis(i), 'ImageRangeAll', [1 16]);
% 	setappdata(h_axis(i), 'CurrentImage', 3);
% end;
	

%VI_tool;
%PM_tool;


