.onAttach <-function(libname,pckname){
packageStartupMessage("Version: ", utils::packageVersion("cvaUtils"),". Built on: ",  utils::packageDate("cvaUtils"))
}
