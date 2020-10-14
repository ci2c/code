data("buckley")
#Exemple DCEMRIS4
## Generate AIF params using the orton.exp function from Buckley's AIF
xi <- seq(5, 300, by=5)
time <- buckley$time.min[xi]
aif <- buckley$input[xi]
aifparams <- orton.exp.lm(time, aif)
aifparams$D <- 1
unlist(aifparams[1:4])
aoe <- aif.orton.exp(time, aifparams$AB, aifparams$muB, aifparams$AG,
                     aifparams$muG)
with(buckley, plot(time.min, input, type="l", lwd=2))
lines(time, aoe, lwd=2, col=2)
legend("right", c("Buckley's AIF", "Our approximation"), lty=1,
       lwd=2, col=1:2)
cbind(time, aif, aoe)[1:10,]

#Exemple BATAILLE (data extraite avec Nifty_fit)
library(readxl)
data_aif <- read_excel("/NAS/tupac/protocoles/perfusion/data/nifti/BATAILLE_RICHARD_2013-02-12/data_aif.xlsx")
View(data_aif)

timeRV <- data_aif$Timing_Data
aifRV <- data_aif$Original_AIF_Curve
aifparamsRV <- orton.exp.lm(timeRV, aifRV)
aifparamsRV <- orton
aifparamsRV$D <- 1

aoeRV <- aif.orton.exp(timeRV, aifparams$AB, aifparams$muB, aifparams$AG,aifparams$muG)

with(data_aif, plot(Timing_Data, Original_AIF_Curve, type="l", lwd=2))
lines(timeRV, aoeRV, lwd=2, col=2)
legend("right", c("BATAILLE's AIF", "DCEMRIS4"), lty=1,lwd=2, col=1:2)
cbind(timeRV, aifRV, aoeRV)[1:10,]

aifparams <- dcemriS4::orton.exp.lm(time, aif)
aifparams <- dcemriS4::orton.exp.lm(TR_TimeFileRV$V1/60,AIF_data$V1)
plot(TR_TimeFileRV$V1/60,AIF_data$V1, type="l", lwd=2)
plot(time,aif, type="l", lwd=2)
lines(time,aif, lwd=2, col=2)

lines(TR_TimeFileRV$V1/60,aoe, lwd=2, col=2)
legend("right", c("Buckley's AIF", "Our approximation"), lty=1,lwd=2, col=1:2)
cbind(TR_TimeFileRV$V1/60,AIF_data$V1, aoe)[1:10,]