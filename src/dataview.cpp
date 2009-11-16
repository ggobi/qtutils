
#include <QWidget>
#include <QTableWidget>
#include <QTableWidgetItem>

#include <qtbase.h>

extern "C" {
#include "dataview.h"
}

SEXP
qt_qsetItem_QTableWidget(SEXP x, SEXP row, SEXP col, SEXP s)
{
    QTableWidget *tab = unwrapSmoke(x, QTableWidget);
    int i, j, k,
	l = length(s), // s will be recycled
	m = length(row), 
	n = length(col);
    for (i = 0; i < m; i++)
	for (j = 0; j < n; j++) {
	    k = (j * m + i) % l;
	    QTableWidgetItem *item = new QTableWidgetItem(sexp2qstring(STRING_ELT(s, k)));
	    item->setFlags(Qt::ItemIsSelectable | Qt::ItemIsEnabled);
	    tab->setItem(INTEGER(row)[i]-1, INTEGER(col)[j]-1, item);
	}
    return R_NilValue;
}


// FIXME: maybe add qt_qsetColnames and qt_qsetRownames allowing
// settings specific row and column names.

SEXP
qt_qsetHeaderLabels_QTableWidget(SEXP x, SEXP colnames, SEXP rownames)
{
    QTableWidget *tab = unwrapSmoke(x, QTableWidget);
    if (colnames != R_NilValue) {
	for (int col = 0; col < length(colnames); col++) {
	    QTableWidgetItem *item = new QTableWidgetItem(sexp2qstring(STRING_ELT(colnames, col)));
	    tab->setHorizontalHeaderItem(col, item);
	}
    }
    if (rownames != R_NilValue) {
	for (int row = 0; row < length(rownames); row++) {
	    QTableWidgetItem *item = new QTableWidgetItem(sexp2qstring(STRING_ELT(rownames, row)));
	    tab->setVerticalHeaderItem(row, item);
	}
    }
    return R_NilValue;
}

