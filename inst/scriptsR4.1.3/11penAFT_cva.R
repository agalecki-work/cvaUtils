library(cvaUtils)
sessionInfo()
rm(list =ls())

setwd("C:/temp")
list.files()

load("cvaObjects.Rdata")
ls()

#--- Inspecting penAFT.en.cva object
class(penAFT.en.cva)

# Create `xnew` data for testing

xnew <- as.matrix(proteins21[1:5, 3:26])
alpha <- seq(0, 1, len = 11)^3

# Extract model fit(s) for selected alpha

which.alpha <- 3
mod <- penAFT.en.cva$modlist[[which.alpha]]
str(mod)
penAFT::penAFT.predict(mod, Xnew =xnew, lambda = mod$full.fit$lmbda[10])


predict(penAFT.en.cva, newx=xnew, alpha = alpha[which.alpha])
minlossplot(penAFT.en.cva)
lossdf <- lossgrid(penAFT.en.cva)
