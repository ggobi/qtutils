
#include <QWidget>
#include <QTableWidget>
#include <QTableWidgetItem>

#include <qtbase.h>

extern "C" {

    SEXP qt_qtableWidget(SEXP nrow, SEXP ncol);
    SEXP qt_qisSortingEnabled(SEXP x);
    SEXP qt_qsetSortingEnabled(SEXP x, SEXP status);
    SEXP qt_qsetItem(SEXP x, SEXP row, SEXP col, SEXP s);
    SEXP qt_qsetCellWidget(SEXP x, SEXP row, SEXP col, SEXP w);
    SEXP qt_qresizeColumnsToContents(SEXP x, SEXP cols);
    SEXP qt_qresizeRowsToContents(SEXP x, SEXP rows);
    SEXP qt_qsetHeaderLabels(SEXP x, SEXP colnames, SEXP rownames);
    SEXP qt_qsetDim(SEXP x, SEXP nrow, SEXP ncol);
    SEXP qt_qcurrentRow(SEXP x);
    SEXP qt_qcurrentColumn(SEXP x);

}


SEXP
qt_qtableWidget(SEXP nrow, SEXP ncol)
{
    int nr, nc;
    if (nrow == R_NilValue && ncol == R_NilValue)
	return wrapQWidget(new QTableWidget(0));
    if (nrow == R_NilValue) nr = 0; else nr = asInteger(nrow);
    if (ncol == R_NilValue) nc = 0; else nc = asInteger(ncol);
    return wrapQWidget(new QTableWidget(nr, nc, 0));
}

SEXP
qt_qisSortingEnabled(SEXP x)
{
    if (unwrapQObject(x, QTableWidget)->isSortingEnabled())
	return ScalarLogical(TRUE);
    else 
	return ScalarLogical(FALSE);
}

SEXP
qt_qsetSortingEnabled(SEXP x, SEXP status)
{
    if (asInteger(status)) 
	unwrapQObject(x, QTableWidget)->setSortingEnabled(true);
    else 
	unwrapQObject(x, QTableWidget)->setSortingEnabled(false);
    return R_NilValue;
}

SEXP
qt_qsetItem(SEXP x, SEXP row, SEXP col, SEXP s)
{
    QTableWidget *tab = unwrapQObject(x, QTableWidget);
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

SEXP
qt_qsetCellWidget(SEXP x, SEXP row, SEXP col, SEXP w)
{
    unwrapQObject(x, QTableWidget)->setCellWidget(asInteger(row)-1, asInteger(col)-1, unwrapQObject(w, QWidget));
    return R_NilValue;
}

SEXP
qt_qresizeColumnsToContents(SEXP x, SEXP cols)
{
    QTableWidget *tab = unwrapQObject(x, QTableWidget);
    if (cols == R_NilValue)
	tab->resizeColumnsToContents();
    else {
	for (int i = 0; i < length(cols); i++)
	    tab->resizeColumnToContents(INTEGER(cols)[i]-1);
    }
    return R_NilValue;
}

SEXP
qt_qresizeRowsToContents(SEXP x, SEXP rows)
{
    QTableWidget *tab = unwrapQObject(x, QTableWidget);
    if (rows == R_NilValue)
	tab->resizeRowsToContents();
    else {
	for (int i = 0; i < length(rows); i++)
	    tab->resizeRowToContents(INTEGER(rows)[i]-1);
    }
    return R_NilValue;
}

// FIXME: maybe add qt_qsetColnames and qt_qsetRownames allowing
// settings specific row and column names.

SEXP
qt_qsetHeaderLabels(SEXP x, SEXP colnames, SEXP rownames)
{
    QTableWidget *tab = unwrapQObject(x, QTableWidget);
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

SEXP
qt_qsetDim(SEXP x, SEXP nrow, SEXP ncol)
{
    SEXP ans = PROTECT(allocVector(INTSXP, 2));
    QTableWidget *tab = unwrapQObject(x, QTableWidget);
    INTEGER(ans)[0] = tab->rowCount();
    INTEGER(ans)[1] = tab->columnCount();
    if (nrow != R_NilValue)
	tab->setRowCount(asInteger(nrow));
    if (ncol != R_NilValue)
	tab->setColumnCount(asInteger(ncol));
    UNPROTECT(1);
    return ans;
}

SEXP qt_qcurrentRow(SEXP x)
{
    return ScalarInteger(unwrapQObject(x, QTableWidget)->currentRow() + 1);
}

SEXP qt_qcurrentColumn(SEXP x)
{
    return ScalarInteger(unwrapQObject(x, QTableWidget)->currentColumn() + 1);
}

