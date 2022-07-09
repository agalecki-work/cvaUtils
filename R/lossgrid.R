## https://roxygen2.r-lib.org/articles/rd.html

#' C-V loss for `cva` objects
#'
#' `lossgrid` returns cross-validated loss for each value of alpha and lambda parameters 
#'
#' @details
#' The `lossgrid` is a generic function applied to cva objects. Returns dataframe with the info 
#' on C-V loss for each combination of alpha and lambda hyperparametervalues.
#'
#' @name lossgrid
#' 
#' @param x cva object (for example object of penAFT.cva class)
#' @return Data frame with one row per each combination of alpha and lambda values
#' @export
lossgrid <- function(x, ...) UseMethod("lossgrid")

#' Title2 reused (Description, if any, will be appended to Description section) 
#'
#' @rdname lossgrid
#' @export
lossgrid.default <- function(x, ...){
message("lossgrid method not implemented for object of class:", class(x)[1])
}

# Auxiliary function

.valid_cv_vars <- function(x){
   .penAFT   <- c("cv.err.linPred")
   .glmnet <- c("cvm", "cvsd", "cvup","cvlo")
   list(penAFT = .penAFT, glmnet =.glmnet)
}

#' Title3 reused (Description, if any, will be appended)
#'
#' @param cv.type 
#'    This can be either `"min"` which is 
#'  the minimum loss, or `"1se"` which is the highest loss within 1 standard error of the minimum. 
#'    The default is `"min"`.
#'
#' @rdname lossgrid
#' @method lossgrid penAFT.cva
#' @export
lossgrid.penAFT.cva <- function(x,...,  cv.vars = "cv.err.linPred ", cv.type = c("min", "1se")) {
    alpha <- x$alpha
    cv.type <- match.arg(cv.type,,)
    if (cv.type == "1se") stop("lossgrid.penAFT.cva method: cv.type = 1se not implemented \n")
    cv.type <- paste0("lambda.", cv.type)
    
    .dfList  <- lapply(x$modlist, function (mod){
              .ffit <- mod$full.fit
              .dfx  <- data.frame(alpha = .ffit$alpha, lambda = .ffit$lambda, 
                                 cv.err.linPred = mod$cv.err.linPred )
              .dfx[[cv.type]] <- .ffit$lambda == mod[[cv.type]]
              .dfx
              })
     do.call(rbind, .dfList)
}
