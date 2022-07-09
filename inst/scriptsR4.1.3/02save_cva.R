setwd("C:/temp")

library(cvaUtils)
rm(list =ls())
str(proteins21)
dtc <- proteins21

# penAFTcva
X  <- as.matrix(dtc[, 3:26])
logY  <- log(dtc[, "time"]) 
delta <- dtc[, "status"]   # status=0 indicates censored observation 
alpha <- seq(0, 1, len = 11)^3
penAFT.en.cva <- penAFT.cva(x=X, logY = logY, delta = delta,
               alpha = alpha,
               nlambda = 50, lambda.ratio.min = 0.1, lambda = NULL,
               penalty = "EN", nfolds = 5, seed = 1234)

# 

download.file("https://web.stanford.edu/~hastie/glmnet/glmnetData/Leukemia.RData",
               "Leukemia.RData")

load("Leukemia.Rdata")
leuk <- do.call(data.frame, Leukemia)
leuk.glmnet.cva <- cva.glmnet(y ~ ., leuk, family="binomial")


save(penAFT.en.cva, leuk.glmnet.cva , file = "cvaObjects.Rdata")
detach(package:cvaUtils)
