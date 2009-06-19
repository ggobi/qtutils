
#ifndef CONSOLE_HIGHLIGHTER_H
#define CONSOLE_HIGHLIGHTER_H

#include <QSyntaxHighlighter>

#include <QHash>
#include <QTextCharFormat>

class QTextDocument;

class RSyntaxHighlighter : public QSyntaxHighlighter
{
    Q_OBJECT

 public:
    RSyntaxHighlighter(QTextDocument *parent = 0);
    void setActive(bool a) { active = a; }
    void setLineStart(int p) { current_line_start = p; }

 protected:
    void highlightBlock(const QString &text);

 private:
    bool active;
    int current_line_start;
    struct HighlightingRule
    {
	QRegExp pattern;
	QTextCharFormat format;
    };
    QVector<HighlightingRule> highlightingRules;

    // initial classifications and values borrowed from ESS

    QTextCharFormat assignmentFormat;
    QTextCharFormat functionFormat;
    QTextCharFormat numberFormat;
    QTextCharFormat argumentFormat;
    QTextCharFormat constantFormat;
    QTextCharFormat keywordFormat;
    QTextCharFormat commonFunctionFormat;
    QTextCharFormat operatorFormat;
    QTextCharFormat namespaceFormat;
    QTextCharFormat commentFormat;
    QTextCharFormat quotationFormat;
};

#endif
