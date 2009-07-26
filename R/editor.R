
qeditor <-
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

qselectedText <- function(x, ...) UseMethod("qselectedText")

qselectedText.QTextEdit <- function(x, ...)
{
    gsub("\u2029", "\n",
         .Call(qt_qselectedText_QTextEdit, x),
         fixed = TRUE)
}

qpager <-
    function(file,
             header = "",
             title = "R Information",
             delete.file = FALSE,
             parent = NULL)
{
    ans <- qeditor(file = file, readonly = TRUE)
    if (!is.null(parent))
        qaddTab(parent, ans, label = title)
    if (delete.file)
    {
        if (getOption("verbose"))
            warning(sprintf("Deleting file: %s", file))
        unlink(file)
    }
    print(ans)
}



