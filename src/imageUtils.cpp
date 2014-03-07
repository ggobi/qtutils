#include <QImage>
#include <QColor>

#include <qtbase.h>

extern "C" {
#include "imageUtils.h"
}

SEXP qt_qimage2matrix_gray(SEXP x)
{
    SEXP ans, dim;
    double *ip;
    QImage *img = unwrapSmoke(x, QImage);
    dim = PROTECT(allocVector(INTSXP, 2));
    int i, j, w = img->width(), h = img->height();
    INTEGER(dim)[0] = w;
    INTEGER(dim)[1] = h;
    ans = PROTECT(allocVector(REALSXP, w * h));
    setAttrib(ans, R_DimSymbol, dim);
    ip = REAL(ans);
    for (j = 0; j < h; j++) {
	for (i = 0; i < w; i++) {
            ip[i + j*w] = 1.0 * qGray(img->pixel(i, j)) / 255.0;
	}
    }
    UNPROTECT(2);
    return ans;
}

// DOES NOT CREATE new QImage, only replaces.  To create, use R wrapper suitably.
SEXP qt_matrix2qimage_gray(SEXP x, SEXP gray)
{
    QImage *img = unwrapSmoke(x, QImage);
    int i, j, col, w = img->width(), h = img->height();
    double *g = REAL(gray);
    for (j = 0; j < h; j++) {
	for (i = 0; i < w; i++) {
	    col = (int) (g[i + j*w] * 255);
	    img->setPixel(i, j, qRgb(col, col, col));
	}
    }
    return R_NilValue;
}




SEXP qt_qimage2matrix_rgb(SEXP x, SEXP alpha)
{
    SEXP ans, dim;
    double *ip;
    QRgb prgb;
    QImage *img = unwrapSmoke(x, QImage);
    dim = PROTECT(allocVector(INTSXP, 3));
    int i, j, components, w = img->width(), h = img->height();
    if (asLogical(alpha)) components = 4; else components = 3;
    INTEGER(dim)[0] = w;
    INTEGER(dim)[1] = h;
    INTEGER(dim)[2] = components;
    ans = PROTECT(allocVector(REALSXP, w * h * components));
    setAttrib(ans, R_DimSymbol, dim);
    ip = REAL(ans);
    if (components == 3) { // no alpha channel
	for (j = 0; j < h; j++) {
	    for (i = 0; i < w; i++) {
		prgb = img->pixel(i, j);
		ip[i + j*w] = 1.0 * qRed(prgb) / 255.0;
		ip[i + j*w + h*w] = 1.0 * qGreen(prgb) / 255.0;
		ip[i + j*w + 2*h*w] = 1.0 * qBlue(prgb) / 255.0;
	    }
	}
    }
    else {
	for (j = 0; j < h; j++) {
	    for (i = 0; i < w; i++) {
		prgb = img->pixel(i, j);
		ip[i + j*w] = 1.0 * qRed(prgb) / 255.0;
		ip[i + j*w + h*w] = 1.0 * qGreen(prgb) / 255.0;
		ip[i + j*w + 2*h*w] = 1.0 * qBlue(prgb) / 255.0;
		ip[i + j*w + 3*h*w] = 1.0 * qAlpha(prgb) / 255.0;
	    }
	}
    }
    UNPROTECT(2);
    return ans;
}

// DOES NOT CREATE new QImage, only replaces.  To create, use R wrapper suitably.
SEXP qt_matrix2qimage_rgb(SEXP x, SEXP red, SEXP green, SEXP blue, SEXP alpha)
{
    double *r, *g, *b, *a;
    QImage *img = unwrapSmoke(x, QImage);
    int i, j, w = img->width(), h = img->height();
    r = REAL(red);
    g = REAL(green);
    b = REAL(blue);
    a = REAL(alpha);
    if (alpha == R_NilValue) { // no alpha channel
	for (j = 0; j < h; j++) {
	    for (i = 0; i < w; i++) {
		img->setPixel(i, j, 
			      qRgb((int) (r[i + j*w] * 255),
				   (int) (g[i + j*w] * 255),
				   (int) (b[i + j*w] * 255)));
	    }
	}
    }
    else {
	for (j = 0; j < h; j++) {
	    for (i = 0; i < w; i++) {
		img->setPixel(i, j, 
			      qRgba((int) (r[i + j*w] * 255),
				    (int) (g[i + j*w] * 255),
				    (int) (b[i + j*w] * 255),
				    (int) (a[i + j*w] * 255)));
	    }
	}
    }
    return R_NilValue;
}



