library(penAFTutils)
rm(list =ls())
str(proteins21)
dtc <- proteins21


X  <- as.matrix(dtc[, 3:26])
logY  <- log(dtc[, "time"]) 
delta <- dtc[, "status"]   # status=0 indicates censored observation 
alpha <- seq(0, 1, len = 11)^3
fit.en.cva <- penAFT.cva(x=X, logY = logY, delta = delta,
               alpha = alpha,
               nlambda = 50, lambda.ratio.min = 0.1, lambda = NULL,
               penalty = "EN", nfolds = 5, seed = 1234)
setwd("C:/temp")
save(fit.en.cva, file = "fit.en.cva.Rdata")
