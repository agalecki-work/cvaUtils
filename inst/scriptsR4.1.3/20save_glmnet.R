setwd("C:/temp")

rm(list =ls())



# download leukemia data
download.file("https://web.stanford.edu/~hastie/glmnet/glmnetData/Leukemia.RData",
               "Leukemia.RData")

load("Leukemia.Rdata")
leuk <- do.call(data.frame, Leukemia)

dim(leuk)
nms <- names (leuk)
head(nms)
tail(nms)
y <- leuk[,"y"]
x <- as.matrix(leuk[, colnames(leuk != "y")])

library(glmnet)

#-- ?glmnet

glmnet.bnml <- glmnet(x,y, family="binomial",alpha =1)
class(glmnet.bnml) #  "lognet" "glmnet"

#--?cv.glmnet
set.seed(123)
nf <- 10 # No of folds
foldid <- sample(1:nf, size = length(y), replace = TRUE)
cv.glmnet.bnml <- cv.glmnet(x,y, foldid= foldid,
  family="binomial")
class(cv.glmnet.bnml) #  "cv.glmnet"

-----

library(glmnetUtils)
leuk.glmnet.cva <- cva.glmnet(y ~ ., leuk, family="binomial")
class(leuk.glmnet.cva)

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
