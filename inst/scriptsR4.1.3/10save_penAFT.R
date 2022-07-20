
setwd("C:/temp")

library(cvaUtils)
rm(list =ls())
str(proteins21)

# Prep data
dtc <- proteins21
X  <- as.matrix(dtc[, 3:26])
logY  <- log(dtc[, "time"]) 
delta <- dtc[, "status"]   # status=0 indicates censored observation 


#--  ?penAFT{penAFT]
library(penAFT)

# Fit the solution path for the regularized semiparametric AFT model

# -----------------------------------------------
# Fit elastic net penalized estimator
# -----------------------------------------------
# Notes: alpha is scalar
#      
penAFT.en <- penAFT(X = X, logY = logY, delta = delta,
                   nlambda = 50, lambda.ratio.min = 0.01,
                   penalty = "EN",
                   alpha = 1)
class(penAFT.en)# penAFT

#-- ?penAFT.cv{penAFT}

penAFT.en.cv <- penAFT.cv(X = X, logY = logY, delta = delta,
                   nlambda = 10, lambda.ratio.min = 0.1,
                   penalty = "EN", nfolds = 5,
                   alpha = 1)

class(penAFT.en.cv)# penAFT.cv


# penAFTcva
# Note: alpha is a vector
alpha <- seq(0, 1, len = 11)^3
penAFT.en.cva <- penAFT.cva(x=X, logY = logY, delta = delta,
               alpha = alpha,
               nlambda = 50, lambda.ratio.min = 0.1, lambda = NULL,
               penalty = "EN", nfolds = 5, seed = 1234)
class(penAFT.en.cva)

save(penAFT.en, penAFT.en.cv, penAFT.en.cva, file = "10penAFT.Rdata")

detach(package:cvaUtils)
detach(package:penAFT)