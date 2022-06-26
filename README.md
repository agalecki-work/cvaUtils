# penAFTutils (under development)

Utility functions for penAFT package. Functions were adopted from `glmnetUtils` package.

## Installation

Approach 1 (recommended)

* Go to https://github.com/agalecki-work/penAFTutils /releases
* Select package version and download zip file using 'Source code' link
* From R session go to: Packages -> Install package(s) from local files ... 

Approach 2

`devtools::install_github("agalecki-work/penAFTutils", build_vignettes = TRUE)`

## Code snippets

### Dataset(s) 

Note `drc` dataframe contains complete cases.

```
library(penAFTutils)
str(proteins21)
dtc <- proteins21
```


### Function penAFT.cva


```
X  <- as.matrix(dtc[, 3:26])
logY  <- log(dtc[, "time"]) 
delta <- dtc[, "status"]   # status=0 indicates censored observation 
alpha <- seq(0, 1, len = 11)^3
fit.en.cva <- penAFT.cva(x=X, logY = logY, delta = delta,
               alpha = alpha,
               nlambda = 50, lambda.ratio.min = 0.1, lambda = NULL,
               penalty = "EN", nfolds = 5, seed = 1234)
```

Save fit for later use.

```
setwd("C:/temp")
save(fit.en.cva, file = "fit.en.cva.Rdata")
```

### Predict, coef

```
load("fit.en.cva.Rdata")
predict(fit.en.cva, newx=X[1:5,],alpha = alpha[3])

```