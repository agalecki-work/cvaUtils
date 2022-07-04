library(penAFTutils)
sessionInfo()
rm(list =ls())

setwd("C:/temp")

xnew <- as.matrix(proteins21[1:5, 3:26])

alpha <- seq(0, 1, len = 11)^3

load("fit.en.cva.Rdata")
mod <- fit.en.cva$modlist[[3]]
str(mod)
penAFT::penAFT.predict(mod, Xnew =xnew, lambda = mod$full.fit$lmbda[10])

predict(fit.en.cva, newx=xnew,alpha = alpha[3])
minlossplot(fit.en.cva)
