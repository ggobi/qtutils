
qtextEdit <- function() .Call(qt_qtextEdit)

qdocument <- function(x) UseMethod("qdocument")

qappend <- function(x, text) UseMethod("qappend")

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


