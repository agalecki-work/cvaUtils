# penAFTutils (under development)

Utility functions for penAFT package. Functions were adopted from `glmnetUtils` package.

## Installation

Approach 1 (recommended)

* Go to https://github.com/agalecki-work/penAFTutils /releases
* Select package version and download zip file using 'Source code' link
* From R session go to: Packages -> Install package(s) from local files ... 

Approach 2

```
devtools::install_github("agalecki-work/cvaUtils", build_vignettes = TRUE)
```

To check package documentation use `help.start()`


## Run scripts

```
library(cvaUtils)
?cvaUtils  # ... check Index fike
rm(list=ls())
setwd("C:/temp")
list.files()
```


```
runScript()
runScript("01setup.R")
#runScript("02save_cva.R") # cva Objects stored in C:/temp/cvaObjects.Rdata 
runScript("03inspect_cva.R")
```