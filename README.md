# cvaUtils (under development)

Utility functions for cva objects.

## Installation

Approach 1 (recommended)

* Go to https://github.com/agalecki-work/cvaUtils/releases
* Select (pre)release version and click on 'Assets' link. Download tar.gz file. 
* From R session go to: Packages -> Install package(s) from local files ... 

Approach 2

```
devtools::install_github("agalecki-work/cvaUtils", build_vignettes = TRUE)
```

To check package documentation use `help(package=cvaUtils)`


## Check scripts

```
library(cvaUtils)
?cvaUtils  # ... check Index fike
rm(list=ls())
runScript()
```