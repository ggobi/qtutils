
#include <qtbase.h>

#define R_USE_PROTOTYPES 0

extern "C" {
#include <R_ext/GraphicsEngine.h>
#include <R_ext/GraphicsDevice.h>
}

#include "devhelpers.hpp"


QFont
r2qFont(const char *fontfamily,
	int fontface,
	double ps,
	double cex,
	double lineheight, // ?? for multiple lines?
	QString dff)       // default font face
{
    Q_UNUSED(lineheight);
    // meaning of fontface:
    // 1 = plain, 2 =  bold, 3 = italic, 4 = bold italic.

//     // constructor
//     QFont::QFont (const QString & family,
// 		  int pointSize = -1,
// 		  int weight = -1,
// 		  bool italic = false);

//     Rprintf("fontfamily=%s,fontface=%d, ps=%g, cex=%g, lineheight=%g\n",
// 	    fontfamily, fontface, ps, cex, lineheight);

    int fontwt;
    if (fontface == 1 || fontface == 3)
	fontwt = QFont::Normal;
    else if (fontface == 2 || fontface == 4)
	fontwt = QFont::Bold;
    else
	fontwt = 1;

    QString ff;
    if (fontface == 5) ff = QString("symbol");
    else 
    if (strlen(fontfamily) == 0) ff = dff;
    else ff = QString(fontfamily);

    QFont font(ff,
	       (int) (ps * cex),
	       fontwt,
	       fontface == 3 || fontface == 4);
    return font;
}



Qt::PenStyle lty2style(int lty) 
{
    switch (lty) {
    case LTY_SOLID:
    	return Qt::SolidLine;
    case LTY_DASHED:
    	return Qt::DashLine;
    case LTY_DOTTED:
    	return Qt::DotLine;
    case LTY_DOTDASH:
    	return Qt::DashDotLine;
    	// FIXME: these (and more) need to be custom patterns
    case LTY_LONGDASH:
    case LTY_TWODASH:
    	return Qt::DashDotDotLine;
    default:
    	return Qt::SolidLine;
    }
    return Qt::SolidLine;
}

