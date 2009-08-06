
#include <QTextEdit>

#include <qtbase.h>

extern "C" {
#include "textedit.h"
}

SEXP
qt_qtextEdit()
{
    QTextEdit *ans = new QTextEdit(0);
    ans->setFontFamily("monospace");
    ans->setLineWrapMode(QTextEdit::NoWrap);
    return wrapQWidget(ans);
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

SEXP
qt_qsetTextColor_QTextEdit(SEXP x, SEXP color)
{
    const QColor col = asQColor(color);
    unwrapQObject(x, QTextEdit)->setTextColor(col);
    return R_NilValue;
}

SEXP
qt_qsetCurrentFont_QTextEdit(SEXP x, SEXP font)
{
    const QFont f = asQFont(font);
    unwrapQObject(x, QTextEdit)->setCurrentFont(f);
    return R_NilValue;
}


