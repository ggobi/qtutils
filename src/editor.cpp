
#include <QTextStream>
#include <QTextEdit>
#include <QTextBrowser>
#include <QFileInfo>
#include <QFile>
#include <QTextCursor>

#include "RSyntaxHighlighter.h"

#include <qtbase.h>

extern "C" {
    SEXP qt_qeditor(SEXP file, SEXP readonly, SEXP richtext, SEXP rsyntax);
    SEXP qt_qselectedText_QTextEdit(SEXP x);
}


SEXP
qt_qeditor(SEXP file, SEXP readonly, SEXP richtext, SEXP rsyntax)
{
    QFile *qfile = new QFile(sexp2qstring(file));
    bool status;
    if (asInteger(readonly)) status = qfile->open(QIODevice::ReadOnly);
    else status = qfile->open(QIODevice::ReadWrite);
    if (!status) return R_NilValue;
    QTextEdit *edit = new QTextEdit();
    if (asInteger(richtext)) {
	edit->setAcceptRichText(true);
    }
    else {
	edit->setAcceptRichText(false);
	edit->setFontFamily("monospace");
	edit->setFontWeight(QFont::Normal);
	edit->setLineWrapMode(QTextEdit::NoWrap);
    }
    QTextStream *stream = new QTextStream(qfile);
    edit->setText(stream->readAll());      
    if (asInteger(readonly)) edit->setReadOnly(true);
    else edit->setReadOnly(false);
    QTextCursor c = edit->textCursor();
    c.setPosition(0);
    edit->setTextCursor(c);
    edit->ensureCursorVisible();
    if (asInteger(rsyntax)) {
	RSyntaxHighlighter *highlighter = new RSyntaxHighlighter(edit->document());
	highlighter->setActive(true);
    }
    return wrapQWidget(edit);
}

SEXP
qt_qselectedText_QTextEdit(SEXP x)
{
    return qstring2sexp(unwrapQObject(x, QTextEdit)->textCursor().selectedText());
}

/*

// A wrapper to save contents to a file

SEXP qt_qsaveEditor(SEXP edit, SEXP file)
{

    QFile *qfile = new QFile(sexp2qstring(file));
    bool status;
    if (!qfile->open(QFile::WriteOnly))
        return FALSE;
    QTextStream ts(qfile);
    ts.setCodec(QTextCodec::codecForName("UTF-8"));
    ts << unwrapQObject(x, QTextEdit)->document()->toHtml("UTF-8");
    unwrapQObject(x, QTextEdit)->document()->setModified(false);
    return TRUE;
 } 


 */
