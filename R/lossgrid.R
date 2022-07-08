## https://roxygen2.r-lib.org/articles/rd.html
#' lossgrid generic
#' 
#' @param x cva object
#' @export
lossgrid <- function(x, ...) UseMethod("lossgrid")


#' @describeIn lossgrid Default 
#' @export

lossgrid.default <- function(x, ...){
message("lossgrid method not implemented for object of class:", class(x)[1])
}


#' lossgrid.penAFT.cva
#`
#' Cross-validated loss for each value of alpha and lambda parameters from Elastic Net fit 
#' @param x Object of
#' @param cv.type 
#'    This can be either `"min"` which is the minimum loss, or `"1se"` which is the highest loss within 1 standard error of the minimum. 
#     The default is `"min"`.
#'
#' @details
#' The `minlossplot` function gives the best (lowest) C-V loss for each value of alpha.
#' @method lossgrid penAFT.cva
#' @describeIn lossgrid lossgrid.penAFT.cva
#' @export
lossgrid.penAFT.cva <- function(x,..., cv.type = c("min", "1se")) {
    alpha <- x$alpha
    cv.type <- match.arg(cv.type)
    if (cv.type == "1se") stop("lossgrid.penAFT.cva method: cv.type = 1se not implemented \n")
    cv.type <- paste0("lambda.", cv.type)
    
    .dfList  <- lapply(x$modlist, function (mod){
              .ffit <- mod$full.fit
              data.frame(alpha = .ffit$alpha, lambda = .ffit$lambda, cv.err.linPred = mod$cv.err.linPred )
              })
     do.call(rbind, .dfList)
}
