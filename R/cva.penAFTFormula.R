#' @include cvaUtils.r
NULL

#' @name penAFT.cva
#' @export
penAFT.cva <- function(x, ...)
UseMethod("penAFT.cva")

#' Elastic net cross-validation of alpha and lambda for penAFT model 
#' 
#' Do elastic net cross-validation of alpha and lambda simultaneously for penAFT models by calling penAFT::penAFT.cv() function
#'
#' @param x A matrix of predictor variables; or for the plotting methods, an object returned by `penAFT.cva`.
#' @param logY A response vector ( with n-elements) of log-survival or log-censoring times.
#' @param delta A binary vector indicating whether the jth element of logY is an observed log-survival time (d_j = 1) or a log-censoring time (d_j = 0) for j=1,..., n.
#' @param alpha A vector of alpha values for which to do cross-validation. The default is a sequence of 11 values more closely spaced around alpha = 0. For the `predict` and `coef` methods, the specific value of alpha for which to return predictions/regression coefficients.
#' @param nfolds The number of cross-validation folds to use. Defaults to 10.
#' @param seed Seed value. It is recommended to  provide seed value. As a result the same folds are used for every value of vector `alpha`. Defualts to NULL.
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
#' @rdname penAFT.cva
#' @method penAFT.cva default
#' @importFrom parallel parLapply
#' @importFrom penAFT penAFT.cv
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



