#ifndef QTUTILS_IMAGEUTILS_H
#define QTUTILS_IMAGEUTILS_H

SEXP qt_qimage2matrix_gray(SEXP x);
SEXP qt_matrix2qimage_gray(SEXP x, SEXP gray);
SEXP qt_qimage2matrix_rgb(SEXP x, SEXP alpha);
SEXP qt_matrix2qimage_rgb(SEXP x, SEXP red, SEXP green, SEXP blue, SEXP alpha);

#endif

