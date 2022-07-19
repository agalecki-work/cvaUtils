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



# How extract model fit(s) from cva object for selected alpha
# ... and calculate predicted values
which.alpha <- 3
mod.cv <- penAFT.en.cva$modlist[[which.alpha]]
class(mod.cv) # penAFT.cv
str(mod.cv)

# Calculate 
penAFT::penAFT.predict(mod, Xnew =xnew, lambda = mod$full.fit$lmbda[10])

# Calculate 
predict(penAFT.en.cva, newx=xnew, alpha = alpha[which.alpha])
minlossplot(penAFT.en.cva)
lossdf <- lossgrid(penAFT.en.cva)
