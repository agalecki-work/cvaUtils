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

alpha <- seq(0, 1, len = 11)^3
penAFT.en.cva <- penAFT.cva(x=X, logY = logY, delta = delta,
               alpha = alpha,
               nlambda = 50, lambda.ratio.min = 0.1, lambda = NULL,
               penalty = "EN", nfolds = 5, seed = 1234)
class(penAFT.en.cva)
# 

download.file("https://web.stanford.edu/~hastie/glmnet/glmnetData/Leukemia.RData",
               "Leukemia.RData")

load("Leukemia.Rdata")
leuk <- do.call(data.frame, Leukemia)
library(glmnetUtils)
leuk.glmnet.cva <- cva.glmnet(y ~ ., leuk, family="binomial")
class(leuk.glmnet.cva)

save(penAFT.en.cva, leuk.glmnet.cva , file = "cvaObjects.Rdata")
detach(package:cvaUtils)
