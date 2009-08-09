
#include <QTextEdit>
#include <QTextCursor>

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


SEXP
qt_qmoveCursor_QTextEdit(SEXP x, SEXP operation, SEXP select)
{
    QString sop = sexp2qstring(operation);
    QTextCursor::MoveOperation mop;
    if (sop == "nomove") mop = QTextCursor::NoMove; 
    else if (sop == "start") mop = QTextCursor::Start; 
    else if (sop == "startofline") mop = QTextCursor::StartOfLine; 
    else if (sop == "startofblock") mop = QTextCursor::StartOfBlock; 
    else if (sop == "startofword") mop = QTextCursor::StartOfWord; 
    else if (sop == "previousblock") mop = QTextCursor::PreviousBlock; 
    else if (sop == "previouscharacter") mop = QTextCursor::PreviousCharacter; 
    else if (sop == "previousword") mop = QTextCursor::PreviousWord; 
    else if (sop == "up") mop = QTextCursor::Up; 
    else if (sop == "left") mop = QTextCursor::Left; 
    else if (sop == "wordleft") mop = QTextCursor::WordLeft; 
    else if (sop == "end") mop = QTextCursor::End; 
    else if (sop == "endofline") mop = QTextCursor::EndOfLine; 
    else if (sop == "endofword") mop = QTextCursor::EndOfWord; 
    else if (sop == "endofblock") mop = QTextCursor::EndOfBlock; 
    else if (sop == "nextblock") mop = QTextCursor::NextBlock; 
    else if (sop == "nextcharacter") mop = QTextCursor::NextCharacter; 
    else if (sop == "nextword") mop = QTextCursor::NextWord; 
    else if (sop == "down") mop = QTextCursor::Down; 
    else if (sop == "right") mop = QTextCursor::Right; 
    else if (sop == "wordright") mop = QTextCursor::WordRight; 
    else if (sop == "nextcell") mop = QTextCursor::NextCell; 
    else if (sop == "previouscell") mop = QTextCursor::PreviousCell; 
    else if (sop == "nextrow") mop = QTextCursor::NextRow; 
    else if (sop == "previousrow") mop = QTextCursor::PreviousRow;
    if (asLogical(select))
	unwrapQObject(x, QTextEdit)->moveCursor(mop, QTextCursor::KeepAnchor);
    else
	unwrapQObject(x, QTextEdit)->moveCursor(mop, QTextCursor::MoveAnchor);
    return R_NilValue;
}

SEXP
qt_qcursorPosition_QTextEdit(SEXP x)
{
    return ScalarInteger(unwrapQObject(x, QTextEdit)->textCursor().position());
}


