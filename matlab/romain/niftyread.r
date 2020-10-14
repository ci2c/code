library(oro.nifti)
library(dcemriS4)
library(readxl)

argv <- commandArgs(TRUE)
a <- as.string(argv[1])
b <- argv[1]

print(a)
print (b)

# data_aif <- read_excel("/NAS/tupac/protocoles/perfusion/data/aif_mediane.xlsx")
# aifparams <- orton.exp.lm(data_aif$time, data_aif$Mediane)
# aifparams$D <- 1
# 
# plot(data_aif$time, data_aif$Mediane, type="l", lwd=2)
# aoe <- aif.orton.exp(data_aif$time,aifparams$AB, aifparams$muB, aifparams$AG,aifparams$muG)
# lines(data_aif$time,aoe, lwd=2, col=2)
# 
# # subj <- read.csv('/NAS/tupac/protocoles/perfusion/scripts/DCE_normalized.txt',header=FALSE)
# # for (a in subj$V1) {
#     dce_file_name = paste0("/NAS/tupac/protocoles/perfusion/fs53/",a,"/Perf/run01/DCE_normalized.nii.gz");
#     mask_name = paste0("/NAS/tupac/protocoles/perfusion/data/nifti/",a,"/roi_d.nii");
#     if (file.exists(mask_name)&&file.exists(dce_file_name))
#     {
#       img <- readNIfTI(paste0("/NAS/tupac/protocoles/perfusion/fs53/",a,"/Perf/run01/DCE_normalized.nii.gz"),reorient=FALSE)
#       mask <- readNIfTI(paste0("/NAS/tupac/protocoles/perfusion/data/nifti/",a,"/roi_d.nii"),reorient=FALSE)
#       fit9 <- dcemri.bayes(img,data_aif$time,mask,model="orton.exp",aif="user",user=aifparams,multicore=TRUE,verbose=FALSE)
#       writeNIfTI(fit9$ktrans,paste0("/NAS/tupac/protocoles/perfusion/fs53/",a,"/Perf/run01/Kt"))
#       writeNIfTI(fit9$kep,paste0("/NAS/tupac/protocoles/perfusion/fs53/",a,"/Perf/run01/kep"))
#       writeNIfTI(fit9$ve,paste0("/NAS/tupac/protocoles/perfusion/fs53/",a,"/Perf/run01/Ve"))
#       writeNIfTI(fit9$vp,paste0("/NAS/tupac/protocoles/perfusion/fs53/",a,"/Perf/run01/vp"))
#     }
    

# }

    
    
    
    
    
    # median(fit9$ktrans,na.rm=T)
    # median(fit9$kep,na.rm=T)
    # median(fit9$ve,na.rm=T)
    # median(fit9$vp,na.rm=T)
    # 
    # mean(fit9$ktrans,na.rm=T,trm=0.2)
    # mean(fit9$kep,na.rm=T,trm=0.2)
    # mean(fit9$ve,na.rm=T,trm=0.2)
    # mean(fit9$vp,na.rm=T,trm=0.2)
    
# View(fit3$ktrans)
# range(fit3$ktrans,na.rm=T)
# hist(fit3$ktrans,na.rm=T,trm=0.2)
# plot(fit3$ktrans,fit3$ktrans, pch=3)
    
    #fit3 <- dcemri.lm(img,data_aif$time,mask,model="orton.exp",aif="user",user=aifparams,multicore=TRUE,verbose=FALSE)
    # fit3 <- dcemri.bayes(img,data_aif$time,mask,model="orton.exp",aif="orton.exp",multicore=TRUE,verbose=FALSE)
    # fit4 <- dcemri.bayes(img,data_aif$time,mask,model="extended",aif="user",user=aifparams,multicore=TRUE,verbose=FALSE)
    #fit4 <- dcemri.lm(img,data_aif$time,mask,model="extended",aif="tofts.kermode",multicore=TRUE,verbose=FALSE)
    
    # fit5 <- dcemri.bayes(img,data_aif$time,mask,model="extended",aif="user",user=aifparams,multicore=TRUE,verbose=FALSE)
    #fit5 <- dcemri.lm(img,data_aif$time,mask,model="extended",aif="fritz.hansen",multicore=TRUE,verbose=FALSE)
    
    #fit6 <- dcemri.lm(img,data_aif$time,mask,model="orton.cos",aif="user",user=aifparams,multicore=TRUE,verbose=FALSE)
    #fit6 <- dcemri.bayes(img,data_aif$time,mask,model="orton.cos",aif="orton.cos",multicore=TRUE,verbose=FALSE)
    
    #fit8 <- dcemri.map(img,data_aif$time,mask,model="orton.cos",aif="orton.cos",multicore=TRUE,verbose=FALSE)
    #fit10 <- dcemri.spline(img,data_aif$time,mask,model="orton.cos",aif="orton.cos",multicore=TRUE,verbose=FALSE)
    #fit9 <- dcemri.bayes(img,data_aif$time,mask,model="orton.exp",aif="orton.exp",multicore=TRUE,verbose=FALSE)