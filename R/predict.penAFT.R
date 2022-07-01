#' `predict` method for objects of `penAFT.cva` class
#'
#' @param object An object returned by `penAFT.cva`.
#' @param newx  A matrix of predictors.
#' @param alpha desired value of alpha parameter (scalar)
#' @param which An alternative way of specifying alpha; the index number of the desired value.
#'     within the `alpha` vector. If both `which` and `alpha` are supplied, the former takes precedence.
#' @lambda  if `lambda` is set to `NULL` the optimal value which minimizes C-V linear predictor scores is selected
#' @param ... Further arguments to be passed to `penAFT::penAFT.predict()` function. 
#'
#' @details
#' The `predict` method computes predictions for a specific alpha value for a given `penAFT.cva` object. 
#`  It looks up the supplied alpha (possibly supplied indirectly via the `which` argument) 
#'  in the object's stored `alpha` vector, and calls `penAFT::penAFT.predict` on the corresponding `penAFT.cv` fit. All the arguments to that function are (or should be) supported.
#'
#' @seealso [penAFT::penAFT.predict], [glmnet::coef.cv.glmnet] 
#'
#' @method predict penAFT.cva
#' @rdname predict.penAFT.cva
#' @export
predict.penAFT.cva <- function(object, newx, alpha, which=match(TRUE, abs(object$alpha - alpha) < 1e-8),  
    lambda = NULL, ...){
    if(is.na(which)) {
        stop("supplied alpha value not found")
   } else {
        message ("Predicted values from predict.penAFT.cva for alpha =", object$alpha[which])    
   } 
   
   if (class(object) != "penAFT.cva") {
        stop("Input 'fit' must be a model fit of `penAFT.cva` class")
    }
    
    #cat("which=", which, "\n")
    mod <- object$modlist[[which]]
    if (is.null(lambda)) message("lambda is set to optimal value which minimized C-V linear predictor scores.")
    # print(str(mod))
    penAFT::penAFT.predict(mod, Xnew = newx, lambda = lambda)
}
