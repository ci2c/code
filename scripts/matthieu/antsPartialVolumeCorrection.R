#!/usr/bin/env Rscript
options(digits=3)
Args <- commandArgs()
self<-Args[4]
self<-substring(self,8,nchar(as.character(self)))
getPckg <- function(pckg) install.packages(pckg, repos = "http://cran.r-project.org")
pckg = try(require(getopt))
if(!pckg) {
cat("Installing 'getopt' from CRAN\n")
getPckg("getopt")
require("getopt")
}
pckg = try(require(igraph))
if(!pckg) {
  getPckg("igraph")
}
library(igraph)

spec = c(
'help'     , 'h', 0, "logical" ," print the help ", 
'cbf'    , 'c', "0", "character" ," name of the mean CBF image ",
'gmProb'   , 'g', "0", "character" ," name of the GM probability image ",
'wmProb'   , 'w', "0", "character" ," name of the WM probability image ",
'output'   , 'o', "1", "character"," the output prefix ")
# ............................................. #
spec=matrix(spec,ncol=5,byrow=TRUE)
# get the options
opt = getopt(spec)
# ............................................. #
#help was asked for.
if ( !is.null(opt$help) || length(opt) == 1 ) {
#print a friendly message and exit with a non-zero error code
cat("\n")
cat(paste(self,"\n"))
for ( x in 1:nrow(spec) ) {
cat("\n")
longopt<-paste("--",spec[x,1],sep='')
shortopt<-paste("-",spec[x,2],sep='')
hlist<-paste(shortopt,"|",longopt,spec[x,5],"\n \n")
# print(hlist,quote=F)
cat(format(hlist, width=40, justify = c("left")))
}
cat(format("Example: \n", width=40, justify = c("left")))
ex<-paste(self," -o myoutput --cbfT1 CBFWarpedToT1.nii.gz --gmProb GMPosteriors2.nii.gz --wmProb WMPosteriors3.nii.gz \n \n ")
ex<-format(ex, width=length(ex), justify = c("left"))
cat("\n")
cat(ex)
q(status=1);
}

for ( myfn in c( opt$cbfT1, opt$gmProb, opt$wmProb ) )
  {
    if ( !file.exists(myfn) ) 
      {
        print(paste("input file",myfn,"does not exist. Exiting."))
        q(status=1)
      } # else print(paste(" have input file",myfn))
  }
  
suppressMessages( library(ANTsR) )

cbf<-antsImageRead( opt$cbf, 3 )
gm.prob<-antsImageRead( opt$gmProb, 3 )
wm.prob<-antsImageRead( opt$wmProb, 3 )

cbf_pvc<-partialVolumeCorrection( cbf, gm.prob, wm.prob )

fn<-paste( opt$output,"_PVC_MeanCBF.nii.gz",sep='')
antsImageWrite( cbf_pvc , fn )

