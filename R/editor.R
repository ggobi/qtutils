
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
    if (rsyntax)
        .Call(qt_qsetRSyntaxHighlighter, edit)
    
    if (!is.null(file)) 
    {
        stream <- Qt$QTextStream(qfile)
        txt <- stream$readAll()
        if (!is.null(txt)) edit$setText(txt)
        if (readonly) edit$setReadOnly(TRUE)
        qfile$close()
    }

    cursor <- edit$textCursor()
    cursor$setPosition(0)
    edit$setTextCursor(cursor)
    edit$ensureCursorVisible()

    edit$resize(600, 400)
    edit
}



qselectedText <- function(x, ...) UseMethod("qselectedText")

qselectedText.QTextEdit <- function(x, ...)
{
    ans <- x$textCursor()$selection()$toPlainText()
    if (is.null(ans)) ""
    else ans
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


