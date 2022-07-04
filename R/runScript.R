
## -> runScript function
#' Executes scripts stored in penAFTutils package
#'
#' Default call of the function without arguments, prints a list of available scripts.
#'
#' @param script character string containing name of the script to be executed. By default is set to NA.
#' @param package character string containing package name. By default `penAFTutils`.
#' @param subdir subdirectory containing scripts. By default: scriptsR4.1.3
#' @param echo logical. Used by source function. By default set to TRUE.
#' @return Script is executed and results are printed.
#' @export
#' @examples runScript()
#'

runScript <- function(script= NA,  package = "penAFTutils", subdir = "scriptsR4.1.3",
    echo = TRUE){
    scriptsDir <- system.file(subdir, package = package)
    scriptsList <- list.files(scriptsDir, pattern = "[[:alnum:]][.][R]$")
    scriptFile <- file.path(scriptsDir, script)
    if (!(script %in% scriptsList)) {
        if (is.na(script)) {
            errFun <- message
            errMsg <- ""
        }
        else {
            errFun <- stop
            errMsg <- paste("Example", example, "does not exist. ")
        }
        errFun(errMsg, "Scripts in ", scriptsDir, " are: \n", paste("\"",scriptsList, 
            collapse = "\", \n", sep=""), "\"")   
    }
    if (!is.na(script)) {
       sourceText <- source(scriptFile, echo=echo)
    } else sourceText <- NULL
    sourceText
}
