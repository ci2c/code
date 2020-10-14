function h = myErrorBars(M,labels,doRange)
%
% h = myErrorBars(M,labels,doRange)
%
% M : a 1 x Ngroups cell array, with only one measurement per subject
%     for example {[22x1] [15x1] [13x1] [13x1]}
% labels: a Ngroups x 1 cell of strings
% doRange: 1 or 0, to show the min and max per group


if nargin<2
   labels=[]; 
end

numCats = size(M,2);
for col = 1 : numCats
    a = M{:,col};                   % get the data to plot
    SEM = std(a)./sqrt(length(a));  % standard error for the mean
    tcrit = tinv(1-(0.05./2),length(a));   % calculate t critical at alpha = 0.05, see http://www.itl.nist.gov/div898/handbook/eda/section3/eda352.htm
    ciLo = mean(a) - tcrit * SEM;    % compute the confidence interval of the mean
    ciMa = mean(a) + tcrit * SEM;

    %CI = [ciLo ciMa];               % The confidence interval of the mean
    CI = bootci(5000,@mean,a);       % the bootstrapped confidence interval of the mean
    
    if col == 1  %we're doing the control here, save some data for the end
       yy = [CI(1) CI(1) CI(2) CI(2)];
       xx = [0.5 numCats+0.5 numCats+0.5 0.5];
       h(1).CIcontrols = patch(xx,yy,[0]);
       set(h(1).CIcontrols,'FaceColor',[0.7 0.7 0.7]);
      set(h(1).CIcontrols,'FaceAlpha',0.5);
      set(h(1).CIcontrols,'EdgeAlpha',0);
      set(h(1).CIcontrols,'LineWidth',0.5);
      set(h(1).CIcontrols,'EdgeColor',[0.7 0.7 0.7]);
      hold on
      h(1).meanLine = plot([0.5 numCats+0.5],[mean(a) mean(a)],'k');hold on
      
    end
    
    h(col).std = plot([col col],[mean(a)-std(a) mean(a)+std(a)],'k','LineWidth',2); % plot the standard deviation
    hold on
    h(col).ci = plot([col col],CI,'r','LineWidth',10);                              % plot the CI
    h(col).theMean = plot([col col],[mean(a) mean(a)],' ok');
    set(h(col).theMean,'MarkerFaceColor','w');
    set(h(col).theMean,'MarkerEdgeColor','w');
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