#!/usr/bin/env python
# -*- coding: utf-8 -*-

import datetime
import os, sys, re
import numpy as np, h5py
from scipy import sparse
import tables, warnings
from snap import *
from numba import jit
import networkx as nx

@jit
def load_sparse_matrix(fname) :
    warnings.simplefilter("ignore", UserWarning)
    f = tables.openFile(fname)
    M = sparse.csc_matrix( (f.root.connectomeVox.data[...], f.root.connectomeVox.ir[...], f.root.connectomeVox.jc[...]) )
    f.close()
    return M

@jit
def mat2snap(fname) :
        G1 = PUNGraph.New()
        X=M.shape[0]
        print X
        cpt=1;
        while cpt <= X:
            G1.AddNode(cpt)
            cpt=cpt+1

        CountEdge=0
        iligne=1;
        icolonne=0;
        while iligne <= X:
            icmax=M.indptr[iligne]
            for icolonne in range(icmax):
                indice=M.indices[icolonne]
        	if indice > iligne:
        		G1.AddEdge(int(iligne),int(indice+1))
        		CountEdge+=1
            iligne+=1

        print CountEdge
        return G1
    
def mat2nx(fname) :
        G1 = nx.Graph()
        X=M.shape[0]
        G1.add_nodes_from(range(1,X));
        CountEdge=0
        iligne=1;
        icolonne=0;
        while iligne <= X:
            icmax=M.indptr[iligne]
            for icolonne in range(icmax):
                indice=M.indices[icolonne]
        	if indice > iligne:
        		G1.add_edge(int(iligne),int(indice+1))
        		CountEdge+=1
            iligne+=1
        print CountEdge
        return G1
            
print "\n Commence à :" 
print datetime.datetime.now();

M=load_sparse_matrix(sys.argv[1]);
print "ici"
G=mat2nx(M);
print "la"
nx.write_graphml(G,"/home/romain/testGraphMl.graphml");
#snap.SaveEdgeList(M, "/home/romain/testSnap2graphTool.txt", "Save as tab-separated list of edges")
print "\n Fini de charger à :" 
print datetime.datetime.now();

#SaveMatlabSparseMtx(G, "TestSave.mat")


print "\n Fini de calculer à :" 
print datetime.datetime.now();
#print "\nIl y a %d nodes\n" % Count

