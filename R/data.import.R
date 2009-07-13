

## eventually a graphical data import function.  We don't have all the
## pieces yet, but will try out some ideas.


file.chooser <- function()
{
    container <- qwidget()
    l <- qlayout(NULL)
    file.loc <- qlineEdit()
    file.button <- qpushButton("Choose")
    qsetLayout(container, l)
    qaddWidgetToLayout(l, file.loc, 1, 1)
    qaddWidgetToLayout(l, file.button, 1, 2)
    ans <-
        list(container = container,
             tfield = file.loc,
             file.button = file.button,
             layout = l)
    qconnect(file.button, 
             signal = "clicked",
             handler = function(x) {
                 qsetText(x$tfield, qfile.choose(caption = "Choose File to Import",
                                                 parent = x$container))
             },
             user.data = ans)
    ans
}

text.field <- function(label, initial = "")
{
    container <- qwidget()
    l <- qlayout(NULL)
    qsetContentsMargins(l, 0, 0, 0, 0)
    tlab <- qlabel(label)
    tfield <- qlineEdit(initial)
    qsetLayout(container, l)
    qaddWidgetToLayout(l, tlab, 1, 1)
    qaddWidgetToLayout(l, tfield, 1, 2)
    ans <-
        list(container = container,
             tlab = tlab, tfield = tfield)
    ans
}


checkbox.field <- function(label, initial = FALSE)
{
    container <- qwidget()
    l <- qlayout(NULL)
    qsetContentsMargins(l, 0, 0, 0, 0)
    cbox <- qcheckBox(label)
    qsetChecked(cbox, initial)
    qsetLayout(container, l)
    qaddWidgetToLayout(l, cbox, 1, 1)
    ans <-
        list(container = container,
             cbox = cbox)
    ans
}

get.field.value <- function(x)
{
    if (!is.null(x$tfield)) 
        qtext(x$tfield)
    else if (!is.null(x$cbox))
        qisChecked(x$cbox)
    else
        NULL
}

set.field.value <- function(x, val)
{
    qsetText(x$tfield, val) 
}



read.table.options <- function()
{
    wlist <-
        list(file = file.chooser(),
             header = checkbox.field("Header", FALSE), ##  text.field("Header", initial = "FALSE"), ## FIXME: should be checkbox
             sep = text.field("Field separator", ""),
             quote = text.field("Quotes", "\"'"),
             dec = text.field("Decimal symbol", "."), 
             na.strings = text.field("Missing symbol", "NA"),
             ## colClasses = NA,
             nrows = text.field("Lines to read", "-1"),
             skip = text.field("Lines to skip",  "0"),
             ## check.names = TRUE, 
             ## fill = !blank.lines.skip,
             ## strip.white = FALSE,
             ## blank.lines.skip = TRUE, 
             comment.char = text.field("Comment character", "#"),
             ## allowEscapes = FALSE,
             ## flush = FALSE, 
             ## stringsAsFactors = default.stringsAsFactors(),
             encoding = text.field("Encoding", "unknown"))
    container <- qwidget()
    l <- qlayout(NULL)
    qsetContentsMargins(l, 0, 0, 0, 0)
    qsetSpacing(l, 1L)
    qsetLayout(container, l)
    qaddWidgetToLayout(l, wlist$file$container, 1, 1, 1, 2)
    qaddWidgetToLayout(l, wlist$sep$container, 2, 1)
    qaddWidgetToLayout(l, wlist$quote$container, 2, 2)
    qaddWidgetToLayout(l, wlist$na.strings$container, 3, 1)
    qaddWidgetToLayout(l, wlist$comment.char$container, 3, 2)
    ## qaddWidgetToLayout(l, wlist$header, 4, 1)
    qaddWidgetToLayout(l, wlist$header$container, 4, 1)
    qaddWidgetToLayout(l, wlist$dec$container, 4, 2)
    qaddWidgetToLayout(l, wlist$nrows$container, 5, 1)
    qaddWidgetToLayout(l, wlist$skip$container, 5, 2)
    qaddWidgetToLayout(l, wlist$encoding$container, 6, 1)
    preview.button <- qpushButton("Preview")
    qaddWidgetToLayout(l, preview.button, 7, 2)
    list(container = container, wlist = wlist,
         preview = preview.button)
}


data.import <- function(file = "")
{
    container <- qwidget()
    l <- qlayout(NULL)
    qsetLayout(container, l)
    rto <- read.table.options()
    set.field.value(rto$wlist$file, file)
    preview.env <- new.env(parent = emptyenv())
    preview.env$dataview <- NULL
    preview.env$importbutton <- NULL
    preview.env$done <- FALSE
    qaddWidgetToLayout(l, rto$container, 1, 1)
    qconnect(rto$preview,
             signal = "clicked",
             user.data = list(layout = l, args = rto$wlist, preview.button = rto$preview, preview.env = preview.env),
             handler = function(x) {
                 vals <- lapply(x$args, get.field.value)
                 ## str(vals)
                 df <-
                     try(read.table(vals$file, 
                                    header = vals$header,
                                    sep = vals$sep,
                                    quote = vals$quote,
                                    dec = vals$dec,
                                    na.strings = vals$na.strings,
                                    nrows = 6, ## as.integer(vals$nrows),
                                    skip = vals$skip,
                                    comment.char = vals$comment.char,
                                    encoding = vals$encoding),
                         silent = TRUE)
                 if (inherits(df, "try-error"))
                 {
                     if (!is.null(preview.env$dataview))
                         qclose(preview.env$dataview)
                     if (!is.null(preview.env$importbutton))
                         qclose(preview.env$importbutton)
                     flines <- paste(readLines(vals$file, n = 6), collapse = "\n")
                     preview.env$dataview <-
                         qlabel(sprintf("Error with current settings: \n%s\n\nContents preview: \n%s",
                                        df, flines))
                     qaddWidgetToLayout(x$layout, preview.env$dataview, 2, 1)
                     qsetText(x$preview.button, "Preview")
                 }
                 else 
                 {
                     if (!is.null(preview.env$dataview))
                         qclose(preview.env$dataview)
                     if (!is.null(preview.env$importbutton))
                         qclose(preview.env$importbutton)
                     preview.env$dataview <- qdataview(df)
                     qaddWidgetToLayout(x$layout, preview.env$dataview, 2, 1)
                     qsetText(x$preview.button, "Update preview")
                     preview.env$importbutton <- qpushButton("Import")
                     qaddWidgetToLayout(x$layout, preview.env$importbutton, 3, 1)
                     qconnect(preview.env$importbutton,
                              signal = "clicked",
                              user.data = preview.env,
                              handler = function(x) {
                                  x$done <- TRUE
                              })
                 }
             })
    qshow(container)
    while (!preview.env$done) { Sys.sleep(0.1) }
    vals <- lapply(rto$wlist, get.field.value)
    qclose(container)
    read.table(vals$file,
               header = vals$header,
               sep = vals$sep,
               quote = vals$quote,
               dec = vals$dec,
               na.strings = vals$na.strings,
               nrows = as.integer(vals$nrows),
               skip = vals$skip,
               comment.char = vals$comment.char,
               encoding = vals$encoding)
}


## if (FALSE)
## {
##     library(qtutils)
##     library(qtconnect)
##     foo <- data.import("")
## }

