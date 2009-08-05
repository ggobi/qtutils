
#include <QTextEdit>

#include <qtbase.h>

extern "C" {
#include "textedit.h"
}

SEXP
qt_qtextEdit()
{
    return wrapQWidget(new QTextEdit(0));
}

SEXP
qt_qdocument_QTextEdit(SEXP x)
{
    return wrapQObject(unwrapQObject(x, QTextEdit)->
		       document());
}

SEXP
qt_qappend_QTextEdit(SEXP x, SEXP text)
{
    unwrapQObject(x, QTextEdit)->append(sexp2qstring(text));
    return R_NilValue;
}

