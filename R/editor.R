
qeditor.old <-
    function(file = stop("file must be supplied"),
             readonly = FALSE,
             richtext = FALSE,
             rsyntax = tail(strsplit(basename(file),
                                     ".", fixed = TRUE)[[1]],
                            1) %in% c("R", "r", "S", "r"))
{
    .Call(qt_qeditor, path.expand(as.character(file)[1]),
          as.integer(readonly)[1],
          as.integer(richtext)[1],
          as.integer(rsyntax)[1])
}

qeditor <-
    function(file = NULL,
             readonly = FALSE,
             richtext = FALSE,
             rsyntax = tail(strsplit(basename(file),
                                     ".", fixed = TRUE)[[1]],
                            1) %in% c("R", "r", "S", "r"))
{
    if (!is.null(file))
    {
        qfile <- Qt$QFile(file)
        status <-
            if (readonly) qfile$open(Qt$QIODevice$ReadOnly)
            else qfile$open(Qt$QIODevice$ReadWrite)
        ## does mode really matter if we just copy the contents and close the file?
        if (!status) return(NULL)
    }
    edit <- Qt$QTextEdit()
    if (richtext) edit$setAcceptRichText(TRUE)
    else
    {
        edit$setAcceptRichText(FALSE)
        ## FIXME: edit$setFont(qfont(family = "monospace"))
        edit$setFontFamily("monospace")
	edit$setLineWrapMode(Qt$QTextEdit$NoWrap)
    }
    
    if (!is.null(file)) 
    {
        stream <- Qt$QTextStream(qfile)
        edit$setText(stream$readAll())
        if (readonly) edit$setReadOnly(TRUE)
        qfile$close()
    }

    cursor <- edit$textCursor()
    cursor$setPosition(0)
    edit$setTextCursor(cursor)
    edit$ensureCursorVisible()

    edit
}



qselectedText <- function(x, ...) UseMethod("qselectedText")

qselectedText.QTextEdit <- function(x, ...)
{
    x$textCursor()$selection()$toPlainText()
}

qpager <-
    function(file,
             header = "",
             title = "R Information",
             delete.file = FALSE,
             parent = NULL)
{
    ans <- qeditor(file = file, readonly = TRUE)
    if (delete.file)
    {
        if (getOption("verbose"))
            warning(sprintf("Deleting file: %s", file))
        unlink(file)
    }
    if (!is.null(parent) && is(parent, "QTabWidget"))
    {
        parent$addTab(ans, title)
        invisible(ans)
    }
    else 
    {
        ans$resize(600, 400)
        ans
    }
}


