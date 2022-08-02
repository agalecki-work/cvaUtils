#' minlossplot
#'
#' minlossplot functiom
#'
#' @name minlossplot
#' @export
function (x, ...) UseMethod("minlossplot")


#' minlossplot
#'
#' minloss desc2
#'
#' @param x Object 
#' @param cv.type For `minlossplot`, which cross-validated loss value to plot for each value of alpha.
#'    This can be either `"min"` which is the minimum loss, or `"1se"` which is the highest loss within 1 standard error of the minimum. 
#     The default is `"min"`.
#'
#' @details
#' The `minlossplot` function gives the best (lowest) C-V loss for each value of alpha.
#' @rdname minlossplot.penAFT.cva
#' @method minlossplot penAFT.cva
#' @export
minlossplot.penAFT.cva <- function(x, ..., 
    cv.type = c("min", "1se"), 
    plot.it = c("min", "all")) {
    alpha <- x$alpha
    cv.type <- match.arg(cv.type)
    if (cv.type == "1se") stop("minlossplot: cv.type = 1se not implemented \n")
    cv.type <- paste0("lambda.", cv.type)
     
    plot.it <- match.arg(plot.it)

    cvm <- sapply(x$modlist, function(mod) {
        mod$cv.err.linPred[mod$lambda == mod[[cv.type]]] # cvm -> cv.err.linPred
    })
    #plot(alpha, cvm, ylab="CV loss", ...)
    nx <- length(alpha)
    if (plot.it == "all") {
    matplot(cvm, type = c("b"), pch =1, col= 1:nx, ylab = "cv.err.linPred")
    legend("topleft", legend = 1:nx, col=1:nx, pch=1)
    } else if (plot.it == "min") {
    cvm2 <- apply(cvm, 2, min)
    # print(cvm2)
    plot (cvm2 ~ alpha, type = c("b"), ylab = "cv.err.linPred_min", xlab = "alpha")
    }
    invisible(x)
}
