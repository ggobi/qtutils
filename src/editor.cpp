
#include <QTextStream>
#include <QTextEdit>
#include <QFileInfo>
#include <QFile>
#include <QTextCursor>

#include "RSyntaxHighlighter.h"

#include <qtbase.h>

extern "C" {
#include "editor.h"
}

SEXP
qt_qsetRSyntaxHighlighter(SEXP x)
{
    QTextEdit *edit = unwrapSmoke(x, QTextEdit);
    RSyntaxHighlighter *highlighter = new RSyntaxHighlighter(edit->document());
    highlighter->setActive(true);
    return R_NilValue;
}

// A wrapper to save contents to a file

// SEXP qt_qsaveEditor(SEXP edit, SEXP file)
// {
//     QFile *qfile = new QFile(sexp2qstring(file));
//     bool status;
//     if (!qfile->open(QFile::WriteOnly))
//         return FALSE;
//     QTextStream ts(qfile);
//     ts.setCodec(QTextCodec::codecForName("UTF-8"));
//     ts << unwrapQObject(x, QTextEdit)->document()->toHtml("UTF-8");
//     unwrapQObject(x, QTextEdit)->document()->setModified(false);
//     return TRUE;
//  } 

