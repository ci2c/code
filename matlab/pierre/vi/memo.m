

%A small example of how to run vi matlab function
%If you employ vi function please refer to :
%(1)Dimitriadis SI, Laskaris NA, Del Rio-Portilla Y, Koudounis GC. 
% Characterizing dynamic functional connectivity across sleep stages from EEG. 
% Brain Topography Volume 22, Number 2 / September, 2009 p.119-133. 
% 
% (2)Dimitriadis SI, Laskaris NA, Tsirka V, Vourkas V, Micheloyannis S.
% An EEG study of brain connectivity dynamics at the resting state. 
% Nonlinear Dynamics, Physchology and Life Sciences.

%1)create 2 random connectivity graphs
nodes=30;
graph1=rand(30,30);

for i=1:nodes
    graph1(i,i)=0;
end

graph2=rand(30,30);

for i=1:nodes
    graph2(i,i)=0;
end

%2)run modularity_dir() for each graph seperately
[Ci1 Q1]=modularity_dir(graph1);

[Ci2 Q1]=modularity_dir(graph2);

%3)run vi to get the distance between two clusterings
[VI_value,NVI, adjvi] = vi(Ci1',Ci2');