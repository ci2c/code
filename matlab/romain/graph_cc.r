library(RBGL)
library(R.matlab)
library("graph")
data_f <- readMat('/NAS/dumbo/romain/test_10000_f.mat')

g1 <- graphAM(adjMat = data_f$Mat.s.full)
k = length(nodes(g1))
ccw1 <- clusteringCoefAppr(g1, k, Weighted=TRUE)