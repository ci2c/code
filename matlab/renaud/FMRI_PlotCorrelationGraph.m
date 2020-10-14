function FMRI_PlotCorrelationGraph(resClust,netw)

name = 'all_networks';

nameROI   = [];
coord     = [];
maskClust = [];
tabind    = [];
for k = 1:length(netw)
    coord     = [coord;resClust.roi{netw(k)}.coord];
    nameROI   = [nameROI resClust.roi{netw(k)}.nameRoi];
    ind       = find(resClust.stats.maskClust==netw(k));
    maskClust = [maskClust resClust.stats.maskClust(ind)];
    tabind    = [tabind ind];
end
temp = resClust.stats.mtR;
mtR  = zeros(length(tabind),length(tabind));
for i = 1:length(tabind)
    mtR(i,:) = temp(tabind(i),tabind);
end
%     Pr        = ComputePvalue(mtR,nbframes,alpha);
%     mtRthres  = mtR;
%     mtRthres(Pr>alpha) = 0;

handleGraph1 = figure('Units','normalized','Name',['Correlation Graph - Roi_level - ' name],'Resize','on','Position',[0.3 0.0302734 0.5 0.42]);
%nedica_visu_graph(mtRthres,coord,nameROI,[-1 1],[],maskClust);
nedica_visu_graph(mtR,coord,nameROI,[-1 1],[],maskClust);
rotate3d('on')
title(['Correlation Graph - Roi_level - ' name],'Interpreter','none')
paramGraph.data          = mtR;
paramGraph.coord         = coord;
paramGraph.name          = nameROI;
paramGraph.maskClust     = maskClust;
paramGraph.selectionName = name;
paramGraph.cmap          = 'jet';
paramGraph.bounds        = [-1 1];
paramGraph.type          = 'ROI';
paramGraph.handleFig     = handleGraph1;
handleThres              = uicontrol(handleGraph1,'Style','edit','Units','normalized','Position',[0.91 0.05 0.08 0.05],...
                            'enable','inactive','Tag','SliderThres','string','0','FontSize',9);
paramGraph.handleThres   = handleThres;
handleSliderThres        = uicontrol(handleGraph1,'Style','slider','Units','normalized','Position',[0.94 0.15 0.02 0.8],...
                            'Callback',{@update_sliderThres,paramGraph},'Tag','SliderThres');
handleSliderText         = uicontrol(handleGraph1,'Style','text','Units','normalized','Position',[0.91 0.11 0.08 0.04],...
                            'String','Thres.','Tag','SliderText','FontSize',9);
                            


%%=========================================================================
% update_sliderThres %%%%%%%%%%%%%%%%%%%%%%
function varargout = update_sliderThres(handleSliderThres, eventdata, paramGraph)

warning('off')
thres = get(handleSliderThres,'Value');
set(paramGraph.handleThres,'String',num2str(thres))
graph = paramGraph.data;
if strcmp(paramGraph.cmap,'redblue')
    graph((abs(graph)<thres)&(abs(graph)>(1-thres))) = 0;
else
    graph(abs(graph)<thres) = 0;
end
figure(paramGraph.handleFig);
hgraph = gca;
camPos = get(hgraph,'cameraPosition');
cla
nedica_visu_graph(graph,paramGraph.coord,paramGraph.name,paramGraph.bounds,[],paramGraph.maskClust,paramGraph.cmap);
set(hgraph,'cameraPosition',camPos);
rotate3d('on')
title(['Correlation Graph - Roi_level - ' paramGraph.selectionName],'Interpreter','none')

% end update_sliderThres