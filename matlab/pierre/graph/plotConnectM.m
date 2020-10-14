function plotConnectM(M, Areas)
% Usage : plotConnectM(M, Areas)
%
% M      : NxN Connectivity Matrix. 
%          If M is the connectivity matrix of the two hemisperes, 
%          N / 2 first component are left hemi,
%          others are right hemisphere
%         
%
% Areas  : Array of N/2 (M is two hemispheres matrix) or 
%                   N (M only 1 hemisphere) strings

if nargin ~= 2
    error('Invalid expression');
end

if length(Areas) ~= (length(M) ./ 2) & length(Areas) ~= length(M)
    error('Size of Areas incompatible with size of M');
end

imagesc(M);
% set(gca, 'XTick', 1:length(M));
% set(gca, 'XTick', []);
% set(gca, 'YTick', 1:length(M));
% set(gca, 'YTick', []);
if length(Areas) == length(M) ./ 2
    Areas = [Areas, Areas];
end
h=gca;
% a=get(h,'XTickLabel');
set(h,'XTickLabel',[]);
set(h,'YTickLabel',[]);
% b=get(h,'XTick');
% c=get(h,'YTick');
% th=text(b,repmat(c(1)-.1*(c(2)-c(1)),length(b),1),a,'HorizontalAlignment','left','rotation',90);
for k = 1 : size(M, 1)
    text(k, (size(M, 1)+0.7), 1, char(Areas(k)), 'HorizontalAlignment', 'right', 'rotation', 90);
    text(0.3, k+0.5, 1, char(Areas(k)), 'HorizontalAlignment', 'right');
end
set(gca, 'XTick', (1:length(M))-0.5);
set(gca, 'YTick', (1:length(M))-0.5);
grid on