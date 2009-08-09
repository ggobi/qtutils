#ifndef QTUTILS_TEXTEDIT_H
#define QTUTILS_TEXTEDIT_H

SEXP qt_qtextEdit();
SEXP qt_qdocument_QTextEdit(SEXP);
SEXP qt_qappend_QTextEdit(SEXP,SEXP);
SEXP qt_qsetTextColor_QTextEdit(SEXP,SEXP);
SEXP qt_qsetCurrentFont_QTextEdit(SEXP,SEXP);
SEXP qt_qmoveCursor_QTextEdit(SEXP,SEXP,SEXP);
SEXP qt_qcursorPosition_QTextEdit(SEXP);

#endif

