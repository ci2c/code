#!/usr/bin/env python
# -*- coding: utf-8 -*-

import datetime
import os, sys, re
import numpy as np
from scipy import sparse

def load_sparse_matrix(fname) :
    warnings.simplefilter("ignore", UserWarning)
    f = tables.openFile(fname)
    M = sparse.csc_matrix( (f.root.connectomeVox.data[...], f.root.connectomeVox.ir[...], f.root.connectomeVox.jc[...]) )
    f.close()
    return M
    
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
M=load_sparse_matrix(sys.argv[1]);
print "Fin" 


