
#include <QTextEdit>
#include <QTextCursor>

#include <qtbase.h>

extern "C" {
#include "textedit.h"
}


SEXP
qt_qsetCursorPosition_QTextEdit(SEXP x, SEXP pos)
{
    QTextEdit *te = unwrapSmoke(x, QTextEdit);
    QTextCursor tc = te->textCursor();
    tc.setPosition(asInteger(pos));
    te->setTextCursor(tc);
    return R_NilValue;
}

