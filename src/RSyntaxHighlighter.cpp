
#include <QtGui>

#include "RSyntaxHighlighter.h"


// FIXME: \b (word boundary) matches '.', and this is not a good thing
// in R (e.g. 'library' is not a separate word in 'library.dynam'.  I
// haven't figured out a way around this (may need to replace \b by
// something more complex).


// FIXME: want to have some code common when we write an
// "RCodeEditorHighlighter"


RSyntaxHighlighter::RSyntaxHighlighter(QTextDocument *parent)
    : QSyntaxHighlighter(parent)
{
    HighlightingRule rule;

    // rules are ordered by priority (later rules override)


    // assignments: should we include = ?
    assignmentFormat.setFontWeight(QFont::Bold);
    assignmentFormat.setForeground(Qt::darkCyan);
    rule.pattern = QRegExp("<{1,2}[-]");
    rule.format = assignmentFormat;
    highlightingRules.append(rule);
    rule.pattern = QRegExp("[-]>{1,2}");
    rule.format = assignmentFormat;
    highlightingRules.append(rule);


    // function: anything followed by (
    functionFormat.setFontItalic(true);
    functionFormat.setForeground(Qt::darkBlue);
    rule.pattern = QRegExp("\\b[A-Za-z0-9_\\.]+(?=[ ]*\\()");
    rule.format = functionFormat;
    highlightingRules.append(rule);

    // argument: anything followed by =, but not at the start(???)
    // unfortunately look behind assertions are not supported
    argumentFormat.setFontItalic(true);
    argumentFormat.setForeground(Qt::darkMagenta);
    rule.pattern = QRegExp("[A-Za-z0-9_\\.]+(?=[ ]*=[^=])");
    rule.format = argumentFormat;
    highlightingRules.append(rule);

//     // numbers
//     numberFormat.setForeground(Qt::black);
//     QStringList numberPatterns;
//     numberPatterns << "\\b[0-9]+[\\.]?[0-9]*\\b" 
// 		   << "\\b[\\.][0-9]+\\b";
//     foreach (QString pattern, numberPatterns) {
// 	rule.pattern = QRegExp(pattern);
// 	rule.format = numberFormat;
// 	highlightingRules.append(rule);
//     }

    // constants: TRUE FALSE NA NULL Inf NaN
    constantFormat.setForeground(Qt::darkMagenta);
    constantFormat.setFontWeight(QFont::Bold);
    QStringList constantPatterns;
    constantPatterns << "\\bTRUE\\b" << "\\bFALSE\\b" << "\\bNA\\b" 
		     << "\\bNULL\\b" << "\\bInf\\b" << "\\bNaN\\b";
    foreach (QString pattern, constantPatterns) {
	rule.pattern = QRegExp(pattern);
	rule.format = constantFormat;
	highlightingRules.append(rule);
    }

    // keywords: while for in repeat if else switch break next
    // function return message warning stop
    keywordFormat.setForeground(Qt::magenta);
    keywordFormat.setFontWeight(QFont::Bold);
    QStringList keywordPatterns;
    keywordPatterns << "\\bwhile\\b" << "\\bfor\\b" << "\\bin([^%]?)\\b" 
		    << "\\brepeat\\b" << "\\bif\\b" << "\\belse\\b" 
		    << "\\bswitch\\b" << "\\bbreak\\b" << "\\bnext\\b" 
		    << "\\bfunction\\b" << "\\breturn\\b" << "\\bmessage\\b" 
		    << "\\bwarning\\b" << "\\bstop\\b";
    foreach (QString pattern, keywordPatterns) {
	rule.pattern = QRegExp(pattern);
	rule.format = keywordFormat;
	highlightingRules.append(rule);
    }

    // common functions (says who? (I hate attach)): library attach
    // detach source require
    commonFunctionFormat.setForeground(Qt::darkRed);
    commonFunctionFormat.setFontWeight(QFont::Bold);
    QStringList commonFunctionPatterns;
    commonFunctionPatterns << "\\blibrary\\b" << "\\bsource\\b" << "\\brequire\\b";
    foreach (QString pattern, commonFunctionPatterns) {
	rule.pattern = QRegExp(pattern);
	rule.format = commonFunctionFormat;
	highlightingRules.append(rule);
    }

    // operators
    operatorFormat.setForeground(Qt::darkCyan);
    operatorFormat.setFontWeight(QFont::Bold);
    QStringList operatorPatterns;

    operatorPatterns << "[\\&\\$\\@\\|\\:\\~\\{\\}\\(\\)!]" << "==" << "!=";

    foreach (QString pattern, operatorPatterns) {
	rule.pattern = QRegExp(pattern);
	rule.format = operatorFormat;
	highlightingRules.append(rule);
    }

    // namespace: anything followed by ::
    namespaceFormat.setForeground(Qt::darkRed);
    rule.pattern = QRegExp("\\b[A-Za-z0-9_\\.]+(?=::)");
    rule.format = namespaceFormat;
    highlightingRules.append(rule);

    // quotes: only activated after quotes are closed.  Does not
    // span lines.
    quotationFormat.setForeground(Qt::darkGreen);
    rule.pattern = QRegExp("\"[^\"]*\"");
    rule.format = quotationFormat;
    highlightingRules.append(rule);
    rule.pattern = QRegExp("'[^']*\'");
    rule.format = quotationFormat;
    highlightingRules.append(rule);

    // comments (should override everything else)
    commentFormat.setForeground(Qt::darkGray);
    rule.pattern = QRegExp("#[^\n]*");
    rule.format = commentFormat;
    highlightingRules.append(rule);


}


void RSyntaxHighlighter::highlightBlock(const QString &text)
{
    // FIXME: don't want highlighting before current prompt, which is
    // why we keep around current_line_start.  However, index below
    // only knows about current block, so we have to hope that nothing
    // above ever gets highlighted (we do disable highlighting of
    // output as it is printed using 'active').  If this doesn't work
    // out, we'll have to figure out something else.
    if (!active) { return; }
    foreach (HighlightingRule rule, highlightingRules) {
	QRegExp expression(rule.pattern);
	int index = text.indexOf(expression); 
	// NB: this is index in block, not full document
	while (index >= 0) {
	    int length = expression.matchedLength();
	    setFormat(index, length, rule.format);
	    index = text.indexOf(expression, index + length);
	}
    }
}
