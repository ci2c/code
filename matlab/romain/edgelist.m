function[el]=edgelist(adj)
%adj is adjacency matrix
dim=size(adj);
rows=dim(1);
cols=dim(2);
el=[]
for i=1:rows;
    for j=(i+1):cols;
        if adj(i,j)>0 el=[el;i j];
        end;
    end;
end;

