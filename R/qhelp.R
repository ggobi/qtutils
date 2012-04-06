
##' .. content for \description{} (no empty lines) ..
##'
##' .. content for \details{} ..
##' @title A Qt web browser widget
##' @param x The URL to view.
##' @param ... Ignored.
##' @return A QWebView instance
##' @author Deepayan Sarkar
qwebbrowser <- function(x, ...)
{
    ## str(list(x = x, ...))
    w <- Qt$QWebView()
    w$load(Qt$QUrl(x))
    w$show()
    w
}



