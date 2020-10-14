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

spec = c(
'help'     , 'h', 0, "logical" ," print the help ", 
'InI'      , 'i', "0", "character" ," Input image ",
'OutI'     , 'o', "0", "character" ," Output image ",
'dim'      , 'd', 2, "numeric" ," dimensionality ",
'smoothf'  , 's', 2, "numeric"," smoothing factor ")
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
ex<-paste(self," --InI input_img.nii --OutI output_img.nii --dim 3 --smoothf 2.548 \n \n ")
ex<-format(ex, width=length(ex), justify = c("left"))
cat("\n")
cat(ex)
q(status=1);
}

for ( myfn in c( opt$InI ) )
  {
    if ( !file.exists(myfn) ) 
      {
        print(paste("input file",myfn,"does not exist. Exiting."))
        q(status=1)
      } # else print(paste(" have input file",myfn))
  }
  
suppressMessages( library(ANTsR) )

SmoothImage( opt$dim, opt$InI, opt$smoothf, opt$OutI )

