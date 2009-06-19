

qhelp <- function(..., htmlhelp = TRUE)
{
    oc <- match.call()
    oc[[1]] <- quote(utils::help)
    oc$htmlhelp <- htmlhelp
    hfile <- eval(oc)
    str(hfile)
    if (length(hfile) == 1)
    {
        if (htmlhelp)
            qwebView(hfile)
        else
            qtextBrowser(hfile)
    }
    else message("No appropriate help file found.")
}


