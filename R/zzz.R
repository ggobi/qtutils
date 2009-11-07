
.noGenerics <- TRUE

## test utility

showAndClose <- function(x, wait = 3, title = deparse(substitute(x)))
{
    x$show()
    x$windowTitle <- as.character(title)
    Sys.sleep(wait)
    x$close()
    invisible()
}    


## .onUnload <- function(libpath)
## {
##     library.dynam.unload("qtutils", libpath)
## }

## .onLoad <- function(libname, pkgname) 
## {
##     ## library.dynam("qtutils", pkgname, libname )
## }

