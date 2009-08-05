
qtextEdit <- function() .Call(qt_qtextEdit)

qdocument <- function(x) UseMethod("qdocument")

qappend <- function(x, text) UseMethod("qappend")

qdocument.QTextEdit <- function(x)
    .Call(qt_qdocument_QTextEdit, x)

qappend.QTextEdit <- function(x, text)
    .Call(qt_qappend_QTextEdit, x, text)


