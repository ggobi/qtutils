
qtextEdit <- function() .Call(qt_qtextEdit)

qdocument <- function(x) UseMethod("qdocument")

qappend <- function(x, text) UseMethod("qappend")

qmoveCursor <- function(x, ...) UseMethod("qmoveCursor")

qcursorPosition <- function(x) UseMethod("qcursorPosition")



qsetTextColor <- function(x, color)
    UseMethod("qsetTextColor")

qsetCurrentFont <- function(x, font)
    UseMethod("qsetCurrentFont")


qdocument.QTextEdit <- function(x)
    .Call(qt_qdocument_QTextEdit, x)

qappend.QTextEdit <- function(x, text)
    .Call(qt_qappend_QTextEdit, x, text)

qsetTextColor.QTextEdit <- function(x, color)
{
    if (!is(color, "QColor"))
    {
        if (length(color) > 1) warning("Only first color used")
        rgb.col <- col2rgb(color[1], alpha = TRUE)[, 1]
        color <- do.call(qcolor, as.list(rgb.col))
    }
    .Call(qt_qsetTextColor_QTextEdit, x, color)
}

qsetCurrentFont.QTextEdit <- function(x, font)
    .Call(qt_qsetCurrentFont_QTextEdit, x, font)


qmoveCursor.QTextEdit <-
    function(x,
             operation = c("nomove", "start", "startofline", "startofblock", "startofword", 
                           "previousblock", "previouscharacter", "previousword", "up", "left", 
                           "wordleft", "end", "endofline", "endofword", "endofblock", "nextblock", 
                           "nextcharacter", "nextword", "down", "right", "wordright", "nextcell", 
                           "previouscell", "nextrow", "previousrow"),
             select = FALSE, ...)
{
    operation <-
        match.arg(tolower(operation),
                  c("nomove", "start", "startofline", "startofblock", "startofword", 
                    "previousblock", "previouscharacter", "previousword", "up", "left", 
                    "wordleft", "end", "endofline", "endofword", "endofblock", "nextblock", 
                    "nextcharacter", "nextword", "down", "right", "wordright", "nextcell", 
                    "previouscell", "nextrow", "previousrow"))
    .Call(qt_qmoveCursor_QTextEdit, x, operation, as.logical(select))
}

qcursorPosition.QTextEdit <- function(x)
{
    .Call(qt_qcursorPosition_QTextEdit, x)
}



