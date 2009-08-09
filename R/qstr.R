
qstr <- function(x, ...)
{
    UseMethod("qstr")
}


qstr.default <- function(x, ...)
{
    if (is.list(x)) return(qstr.list(x, ...))
    if (is(x, "standardGeneric")) return(qstr(S4methodsList(x), ...))
    temp <- tempfile()
    ## ostr <- capture.output(str(x, ...))
    ostr <- capture.output(print(x, ...))
    cat(paste(ostr, collapse = "\n"), file = temp)
    ## FIXME: no need to write out file
    w <- qeditor(temp, readonly = TRUE, rsyntax = FALSE)
    unlink(temp)
    w
}

qstr.data.frame <- function(x, ...)
{
    qdataview(x)
}

qstr.table <- function(x, ...)
{
    if (length(dim(x)) == 2) qdataview(x)
    else qstr.default(x, ...)
}

qstr.matrix <- function(x, ...)
{
    qdataview(x)
}

S4methodsList <- function(x)
{
    generic <- x@generic
    allDefs <- showMethods(generic, includeDefs = TRUE, printTo = FALSE)
    wz <- which(!nzchar(allDefs))[c(FALSE, TRUE)] ## blank lines come in sets of 2
    wz <- head(wz, -1) ## last one not needed
    starts <- 1L + c(1L, wz)
    ends <- c(wz, length(allDefs))
    stopifnot(length(starts) == length(ends))
    ans <- vector(mode = "list", length = length(starts))
    names(ans) <- sprintf("%s (%s)", generic, allDefs[starts])
    for (i in seq_along(ans))
    {
        ans[[i]] <- eval(parse(text = allDefs[(starts[i]+1):ends[i]]))
    }
    ans
}



qstr.function <- function(x, ...)
{
    temp <- tempfile()
    ostr <- capture.output(print(x, ...))
    cat(paste(ostr, collapse = "\n"), file = temp)
    wfun <- qeditor(temp, readonly = TRUE, rsyntax = TRUE)
    unlink(temp)
    ## qsetStyleSheet("font-family : monospace", widget = wfun)
    wfun
}

qstr.listOrEnv <- function(x, ...)
{
    isList <- is.list(x)
    objs <- 
        if (isList)
        {
            if (is.null(names(x)))
                names(x) <- as.character(seq_along(x))
            names(x)
        }
        else
            ls(x, all.names = TRUE)
    container <- qsplitter(horizontal = TRUE)
    container$opaqueResize <- FALSE

    ## container <- qwidget()
    ## qsetExpanding(container, horizontal = TRUE)
    ## qsetContentsMargins(container, 0, 0, 0, 0)
    ## l <- qlayout(NULL)
    ## qsetContentsMargins(l, 0, 0, 0, 0)
    ## qsetSpacing(l, 0L)
    ## qsetLayout(container, l)

    wlist <- qlistWidget(objs)
    for (i in seq_along(objs))
    {
        if (!isList && bindingIsActive(objs[i], x))
        {
            obj.class <- obj.mode <- "Active binding"
        }
        else
        {
            obj.class <- class(x[[ objs[i] ]])
            obj.mode <- mode(x[[ objs[i] ]])
        }
        qsetItemToolTip(wlist, i,
                        sprintf("<html>%s<br><strong>Class: </strong>%s<br><strong>Mode: </strong>%s</html>",
                                objs[i],
                                paste(obj.class, collapse = ","),
                                obj.mode))
    }
    preview.container <- qwidget()
    preview.layout <- qlayout()
    qsetContentsMargins(preview.layout, 0, 0, 0, 0)
    qsetSpacing(preview.layout, 0L)
    qsetLayout(preview.container, preview.layout)

    ## qsetContentsMargins(wlist, 0, 0, 0, 0)
##     if (isList)
##     {
##         qaddWidget(l, wlist, 1, 1, 2, 1)
##     }
##     else 
##     {
##         wrepl <- qrepl(x)
##         qsetExpanding(wrepl, horizontal = FALSE)
##         qaddWidget(l, wlist, 1, 1)
##         qaddWidget(l, wrepl, 2, 1)
##     }

    qaddWidget(container, wlist)
    qaddWidget(container, preview.container)
    qsetExpanding(wlist, horizontal = FALSE)
    qsetExpanding(preview.container, horizontal = TRUE)
    qsetStretchFactor(container, 0L, 0L)
    qsetStretchFactor(container, 1L, 10L)

    sub.env <- new.env(parent = emptyenv())
    sub.env$preview <- NULL
    sub.env$objects <- objs
    sub.env$wlist <- wlist
    sub.env$preview.layout <- preview.layout
    sub.env$preview.container <- preview.container

    user.data <- list(x = x, sub.env = sub.env)
    handleSelection <- function(u)
    {
        i <- qcurrentRow(u$sub.env$wlist)
        obj <- u$sub.env$objects[i]
        new.preview <- qstr(u$x[[obj]])
        if (!is.null(u$sub.env$preview))
            qclose(u$sub.env$preview)
        u$sub.env$preview.layout[1,1] <- new.preview
        u$sub.env$preview <- new.preview
    }

##     qconnect(wlist,
##              user.data = user.data,
##              handler = handleSelection,
##              ## which = "cellClicked_int_int")
##              which = "itemClicked_qlistwidgetitem")
    ## attr(container, "activation.handler") <- 
    qconnect(wlist,
             signal = "itemActivated",
             user.data = user.data,
             handler = handleSelection)    
    container
}

qstr.list <- qstr.listOrEnv
qstr.environment <- qstr.listOrEnv




