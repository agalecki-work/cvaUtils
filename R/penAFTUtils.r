#' @title Utilities for penAFT
#' @description
#' Some quality-of-life functions to streamline the process of fitting elastic net models with the `penAFT` package, specifically:
#'
#' * `penAFT.cva` ??? .
#' * `glmnet.formula` provides a formula/data frame interface to `glmnet`.
#' * `cv.glmnet.formula` does a similar thing for `cv.glmnet`.
#' * Methods for `predict` and `coef` for both the above.
#' * A function `penAFT.cva` to choose both the alpha and lambda parameters via cross-validation, following the approach described in the help page for `penAFT.cv`. Optionally does the cross-validation in parallel.
#' * Methods for `plot`, `predict` and `coef` for the above.
#'
#' @docType package
#' @name JSKPanel
#' @aliases JSKPanel-package
NULL


## assorted imports from base packages
#' @importFrom graphics lines plot
#' @importFrom grDevices palette topo.colors
#' @importFrom stats coef na.pass predict terms .getXlevels delete.response
#' @importFrom stats model.frame model.extract model.matrix model.response
NULL
