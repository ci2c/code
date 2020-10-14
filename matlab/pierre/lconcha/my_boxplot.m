function h = my_boxplot(M,labels,doRange)
%
% function h = my_boxplot(M,labels,doRange)
%
% here the confidence intervals of the median are shown just like in matlab's
% own boxplot, remember that:
%
%   In a notched box plot the notches represent a robust estimate of the
%   uncertainty about the medians for box-to-box comparison.  Boxes whose
%   notches do not overlap indicate that the medians of the two groups
%   differ at the 5% significance level.  Whiskers extend from the box
%   out to the most extreme data value within WHIS*IQR, where WHIS is the
%   value of the 'whisker' parameter and IQR is the interquartile range
%   of the sample.

if nargin<2
   labels=[]; 
end

numCats = size(M,2);
for col = 1 : numCats
    a = M{:,col};                   % get the data to plot
    
    pctiles = prctile(a,[25;50;75]);
    q1 = pctiles(1);
    med = pctiles(2);
    q3 = pctiles(3);
    n1 = med + 1.57*(q3-q1)/sqrt(length(a));    % obtain the CI of the median
    n2 = med - 1.57*(q3-q1)/sqrt(length(a));
    if n1>q3, n1 = q3; end
    if n2<q1, n2 = q1; end
    
    CI = [n1 n2];
    
    if col == 1  %we're doing the control here, save some data for the end
       yy = [n1 n1 n2 n2];
       xx = [0.5 numCats+0.5 numCats+0.5 0.5];
       h(1).CIcontrols = patch(xx,yy,[0]);
       set(h(1).CIcontrols,'FaceColor',[0.7 0.7 0.7])
       set(h(1).CIcontrols,'FaceAlpha',0.5)
       set(h(1).CIcontrols,'EdgeAlpha',0)
       hold on
    end
    
    h(col).std = plot([col col],[q1 q3],'k','LineWidth',2); % plot the interquartile range
    hold on
    
    h(col).ci = plot([col col],CI,'r','LineWidth',10);                              % plot the CI of the median
    h(col).theMedian = plot([col col],[median(a) median(a)],' ok');
    set(h(col).theMedian,'MarkerFaceColor','w');
    set(h(col).theMedian,'MarkerEdgeColor','w');
    if nargin>2 & doRange == 1
        h(col).range = plot([col col],[min(a) max(a)],'. k');   % plot the range of values
    end
end
        

set(gca,'XLim',[0.5 numCats+0.5]) % adjust the X axis to give room on the sides


if ~isempty(labels)
    set(gca,'XTick',[1:1:numCats])  % put the labels, if available
    set(gca,'XTickLabel',labels)
end

set(gca,'FontName','Times')         % I like this font


hold off