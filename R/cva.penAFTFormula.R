#' @include penAFTUtils.r
NULL

#' @name penAFT.cva
#' @export
penAFT.cva <- function(x, ...)
UseMethod("penAFT.cva")

#' Do elastic net cross-validation for alpha and lambda simultaneously (based on glmnetUtils package)
#'
#' @param x A matrix of predictor variables; or for the plotting methods, an object returned by `penAFT.cva`.
#' @param logY A response vector ( with n-elements) of log-survival or log-censoring times.
#' @param delta A binary vector indicating whether the jth element of logY is an observed log-survival time (d_j = 1) or a log-censoring time (d_j = 0) for j=1,..., n.
#' @param alpha A vector of alpha values for which to do cross-validation. The default is a sequence of 11 values more closely spaced around alpha = 0. For the `predict` and `coef` methods, the specific value of alpha for which to return predictions/regression coefficients.
#' @param nfolds The number of cross-validation folds to use. Defaults to 10.
#' @param seed Seed value. Defualts to NULL.
#' @param outerParallel Method of parallelising the outer loop over alpha. See 'Details' below. If `NULL`, the loop is run sequentially.
#' @param checkInnerParallel If the outer loop is run in parallel, check that the inner loop over lambda will not be in contention for cores.
#'
#' @details
#' The `penAFT.cva` function does simultaneous cross-validation for both the alpha and lambda parameters in an elastic net model. The procedure is as outlined in the documentation for [glmnet::cv.glmnet]: it creates a vector `foldid` allocating the observations into folds, and then calls `penAFT.cv` in a loop over different values of alpha, but the same values of `foldid` each time.
#'
#' Optionally this loop over alpha can be parallelised; currently, `penAFT.cva` knows about two methods of doing so:
#'
#' * Via [parLapply] in the parallel package. To use this, set `outerParallel` to a valid cluster object created by [makeCluster].
#' * Via `rxExec` as supplied by Microsoft R Server's RevoScaleR package. To use this, set `outerParallel` to a valid compute context created by `RxComputeContext`, or a character string specifying such a context.
#'
#' If the outer loop is run in parallel, `penAFT.cva` can check if the inner loop (over lambda) is also set to run in parallel, and disable this if it would lead to contention for cores. This is done if it is likely that the parallelisation is local on a multicore machine, ie if `outerParallel` is a `SOCKcluster` object running on `"localhost"`, or if the RevoScaleR compute context is local parallel.
#'
#' @examples
#' \dontrun{
#' dtc <- proteins21
#' X  <- as.matrix(dtc[, 3:26])
#' logY  <- log(dtc[, "time"]) 
#' delta <- dtc[, "status"]   # status=0 indicates censored observation 
#' fit.en.cva <- penAFT.cva(x=X, logY = logY, delta = delta,
#'               alpha = seq(0, 1, len = 11)^3,
#'               nlambda = 50, lambda.ratio.min = 0.1, lambda = NULL,
#'               penalty = "EN", nfolds = 5, seed = 1234)
#' }
## ' @seealso
## ' \co[penAFT::penAFT.cv]
#' @rdname penAFT.cva
#' @method penAFT.cva default
#' @importFrom parallel parLapply
#' @importFrom penAFT penAFT.cv
#' @export
penAFT.cva.default <- function (
      x, logY, delta, alpha = seq(0, 1, len = 11)^3,
      nfolds = 10,  seed = NULL, ..., 
      outerParallel = NULL, checkInnerParallel = TRUE) 
{
    cl <- match.call()
    .cvfunc <- function(a, xmat, logY, delta, nfolds, seed, ...) {
        if (!is.null(seed)) set.seed(seed)
        cat("--- alpha=", a, "--- \n")
        penAFT::penAFT.cv(xmat, logY, delta, alpha = a, nfolds = nfolds, ...)
    }
    .chkPar <- function() {
        if (checkInnerParallel && isTRUE(dotargs$parallel)) {
            warning("Setting parallel to FALSE for inner loop over lambda", 
                call. = FALSE)
            dotargs$parallel <<- FALSE
        }
    }
    # if (length(foldid) != nrow(x) || !is.numeric(foldid)) stop("invalid foldid specified")
    dotargs <- list(...)
    rxContexts <- c("RxLocalSeq", "local", "RxLocalParallel", 
        "localpar", "RxHadoopMR", "hadoopmr", 
        "RxSpark", "spark", "RxInTeradata", 
        "teradata", "RxForeachDoPar", "dopar", 
        "RxInSqlServer", "sqlserver")
    if (is.character(outerParallel) && (outerParallel %in% rxContexts) && 
        eval(parse(text = "require(RevoScaleR)"))) 
        outerParallel <- eval(parse(text = "RevoScaleR::RxComputeContext"))(outerParallel)
    lst <- if (inherits(outerParallel, "cluster")) {
        if (inherits(outerParallel, "SOCKcluster") && identical(outerParallel[[1]]$host, 
            "localhost")) 
            .chkPar()
        do.call(parallel::parLapply, c(list(outerParallel, alpha, 
            .cvfunc, xmat = x, logY = logY, delta = delta, nfolds = nfolds, seed = seed), 
            dotargs))
    }
    else if (inherits(outerParallel, "RxComputeContext")) {
        eval(parse(text = "\n        oldContext <- rxSetComputeContext(outerParallel)\n        on.exit(rxSetComputeContext(oldContext))\n        if(is(outerParallel, \"RxLocalParallel\"))\n            .chkPar()\n        do.call(rxExec, c(list(.cvfunc, a=rxElemArg(alpha), xmat=x, logY=logY, delta= delta, nfolds=nfolds, seed=seed\n ), dotargs))"))
    }
    else if (is.null(outerParallel)) {
        lapply(alpha, .cvfunc, xmat = x, logY = logY, delta= delta, nfolds = nfolds, seed=seed, ...)
    }
    else stop("unknown value for outerParallel")
    out <- list(alpha = alpha, nfolds = nfolds, seed=seed, modlist = lst, 
        call = cl)
    class(out) <- "penAFT.cva"
    out
}


#' @param object For the `predict` and `coef` methods, an object returned by `penAFT.cva`.
#' @param newx For the `predict` method, a matrix of predictor variables.
#' @param alpha desired value of alpha parameter (scalar)
#' @param which An alternative way of specifying alpha; the index number of the desired value within the alpha vector. If both `which` and `alpha` are supplied, the former takes precedence.
#' @param ... Further arguments to be passed to lower-level functions. In the case of `penAFT.cva`, these arguments are passed to `penAFT.cv`; for `predict` and `coef`, they are passed to `predict.cv.glmnet`; and for `plot` and `minlossplot`, to `plot`.
#'
#' @details
#' The `predict` method computes predictions for a specific alpha value given a `penAFT.cva` object. It looks up the supplied alpha (possibly supplied indirectly via the `which` argument) in the object's stored `alpha` vector, and calls `penAFT::penAFT.predict` on the corresponding `penAFT.cv` fit. All the arguments to that function are (or should be) supported.
#'
#' @seealso
#' {penAFT::penAFT.predict], [glmnet::coef.cv.glmnet], 
#'
#' @method predict penAFT.cva
#' @rdname penAFT.cva
#' @export
predict.penAFT.cva <- function(object, newx, alpha, which=match(TRUE, abs(object$alpha - alpha) < 1e-8),  
    lambda = NULL, ...){
    if(is.na(which)) {
        stop("supplied alpha value not found")
   } else {
        message ("Predicted values from predict.penAFT.cva for alpha =", object$alpha[which])    
   } 
   
   if (class(object) != "penAFT.cva") {
        stop("Input 'fit' must be a model fit from penAFT.cva")
    }
    
    #cat("which=", which, "\n")
    mod <- object$modlist[[which]]
    if (is.null(lambda)) message("lambda is set to optimal value which minimized C-V linear predictor scores.")
    # print(str(mod))
    penAFT::penAFT.predict(mod, Xnew = newx, lambda = lambda)
}

#' @name penAFT.cva
#' @rdname penAFT.cva
#' @export
minlossplot <- function(x, ...)
UseMethod("minlossplot")


#' @param cv.type For `minlossplot`, which cross-validated loss value to plot for each value of alpha. This can be either `"min"` which is the minimum loss, or `"1se"` which is the highest loss within 1 standard error of the minimum. The default is `"1se"`.
#'
#' @details
#' The `minlossplot` function gives the best (lowest) C-V loss for each value of alpha.
#'
#' @rdname penAFT.cva
#' @export
minlossplot.penAFT.cva <- function(x, ..., cv.type=c("min", "1se"))
{
    alpha <- x$alpha
    cv.type <- match.arg(cv.type)
    
    cv.type <- paste0("lambda.", cv.type)
    cvm <- sapply(x$modlist, function(mod) {
        mod$cv.err.linPred[mod$lambda == mod[[cv.type]]] # cvm -> cv.err.linPred
    })
    plot(alpha, cvm, ylab="CV loss", ...)
    invisible(x)
}
