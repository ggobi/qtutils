
#ifndef QTDEVICE_HELPERS_H
#define QTDEVICE_HELPERS_H

#include <QFont>
#include <QColor>
#include <QString>


#define r2qColor(col) QColor(R_RED(col), R_GREEN(col), R_BLUE(col), R_ALPHA(col))

QFont
r2qFont(const char *fontfamily, int fontface,
	double ps, double cex, 
	double lineheight, // ?? for multiple lines?
	QString dff);

Qt::PenStyle 
lty2style(int lty);

#endif
