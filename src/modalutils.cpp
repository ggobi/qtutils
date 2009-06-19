
// The goal here is mainly to provide interfaces to common
// blocking/modal dialogs already implemented in Qt, perhaps with more
// sophisticated replacements at some future date.  QDialog is
// inherited by (among others) QColorDialog, QErrorMessage,
// QFileDialog, QFontDialog, QInputDialog, QMessageBox,
// QPageSetupDialog, QPrintPreviewDialog, QProgressDialog, and
// QWizard.


#include <QFileDialog>
#include <QColorDialog>
#include <QInputDialog>

#include <R.h>
#include <Rinternals.h>

#include <qtbase.h>

extern "C" {

    SEXP qt_qfile_choose(SEXP caption, SEXP dir, 
			 SEXP filter, SEXP allowNew, 
			 SEXP parent);
    SEXP qt_qdir_choose(SEXP caption, SEXP dir, SEXP parent);

    SEXP qt_qgetColor(SEXP parent);
    SEXP qt_qgetDouble(SEXP title, SEXP label, SEXP value, SEXP minValue, SEXP maxValue, SEXP decimals, SEXP parent);
    SEXP qt_qgetInteger(SEXP title, SEXP label, SEXP value, SEXP minValue, SEXP maxValue, SEXP step, SEXP parent);
    SEXP qt_qgetText(SEXP title, SEXP label, SEXP text, SEXP parent);

}


// QFileDialog

SEXP 
qt_qfile_choose(SEXP caption, SEXP dir, 
		SEXP filter, SEXP allowNew,
		// SEXP multiple=FALSE, (allow multiple selctions?
		// FIXME: needs vector version qstringlist2sexp
		SEXP parent) {
    QWidget *p = 0;
    if (parent != R_NilValue)
	p = unwrapQObject(parent, QWidget);
    QString choice;
    if (asInteger(allowNew))
	choice = QFileDialog::getSaveFileName
	    (p,
	     sexp2qstring(caption),
	     sexp2qstring(dir),
	     sexp2qstring(filter));
    else
	choice = QFileDialog::getOpenFileName
	    (p,
	     sexp2qstring(caption),
	     sexp2qstring(dir),
	     sexp2qstring(filter));
    return
	qstring2sexp(choice);
}

SEXP qt_qdir_choose(SEXP caption, SEXP dir, SEXP parent) {
    QWidget *p = 0;
    if (parent != R_NilValue)
	p = unwrapQObject(parent, QWidget);
    return
	qstring2sexp(QFileDialog::getExistingDirectory
		     (p,
		      sexp2qstring(caption),
		      sexp2qstring(dir)));
}


// QInputDialog, QMessageBox, QPageSetupDialog, QPrintPreviewDialog,
// QProgressDialog, and QWizard.


SEXP qt_qgetColor(SEXP parent) {
    SEXP ans;
    QWidget *p = 0;
    if (parent != R_NilValue)
	p = unwrapQObject(parent, QWidget);
    QRgb rgba = QColorDialog::getRgba(0xffffffff, 0, p);
    ans = PROTECT(allocVector(INTSXP, 4));
    INTEGER(ans)[0] = qRed(rgba);
    INTEGER(ans)[1] = qGreen(rgba);
    INTEGER(ans)[2] = qBlue(rgba);
    INTEGER(ans)[3] = qAlpha(rgba);
    UNPROTECT(1);
    return ans;
}


SEXP qt_qgetDouble(SEXP title, SEXP label, SEXP value, SEXP minValue, SEXP maxValue, SEXP decimals, SEXP parent) {
    QWidget *p = 0;
    if (parent != R_NilValue)
	p = unwrapQObject(parent, QWidget);
    double ans = 
	QInputDialog::getDouble(p, sexp2qstring(title), sexp2qstring(label), 
				asReal(value),
				asReal(minValue),
				asReal(maxValue),
				asInteger(decimals));
    return ScalarReal(ans);
}

SEXP qt_qgetInteger(SEXP title, SEXP label, SEXP value, SEXP minValue, SEXP maxValue, SEXP step, SEXP parent) {
    QWidget *p = 0;
    if (parent != R_NilValue)
	p = unwrapQObject(parent, QWidget);
    int ans = 
	QInputDialog::getInteger(p, sexp2qstring(title), sexp2qstring(label), 
				 asInteger(value), 
				 asInteger(minValue), 
				 asInteger(maxValue), 
				 asInteger(step));
    return ScalarInteger(ans);
}

SEXP qt_qgetText(SEXP title, SEXP label, SEXP text, SEXP parent) {
    QWidget *p = 0;
    if (parent != R_NilValue)
	p = unwrapQObject(parent, QWidget);
    QString ans = 
	QInputDialog::getText(p, sexp2qstring(title), sexp2qstring(label), 
			      QLineEdit::Normal,
			      sexp2qstring(text));
    return qstring2sexp(ans);
}


// QInputDialog::getDouble
// (parent, title, label, double value = 0, double minValue = -2147483647, double maxValue = 2147483647, int decimals = 1, bool * ok = 0)

// QInputDialog::getInteger
// (parent, title, label, int value = 0, int minValue = -2147483647, int maxValue = 2147483647, int step = 1, bool * ok = 0)

// QString QInputDialog::getItem
// (parent, title, label, const QStringList & list, int current = 0, bool editable = true, bool * ok = 0)

// QString QInputDialog::getText
// (parent, title, label, QLineEdit::EchoMode mode = QLineEdit::Normal, text = QString(), bool * ok = 0)


