## Based on https://stuff.mit.edu/afs/athena/software/r/current/RStudio/resources/roxygen_help.html
## see library/roxygen2/doc/rd.html
## https://bookdown.dongzhuoer.com/hadley/r-pkgs/man.html (Section 8)
#'
#' @details
#'  For a complete list of functions use:
#' ```
#'  library(help = "cvaUtils")
#' ```
#'   or 
#' ```
#' help.start()
#' ```
#'  and locate `cvaUtils` package 
## assorted imports from base packages
#' @importFrom glmnetUtils minlossplot
#' @importFrom graphics lines plot
#' @importFrom grDevices palette topo.colors
#' @importFrom stats coef na.pass predict terms .getXlevels delete.response
#' @importFrom stats model.frame model.extract model.matrix model.response
#' @keywords internal
"_PACKAGE"
