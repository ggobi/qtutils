
#include <QWidget>
#include <QListWidget>
#include <QListWidgetItem>

#include <qtbase.h>

extern "C" {
#include "listview.h"
}


SEXP
qt_qlistWidget(SEXP labels)
{
    QListWidget *lw = new QListWidget(0);
    int i, n = length(labels);
    for (i = 0; i < n; i++)
	lw->addItem(sexp2qstring(STRING_ELT(labels, i)));
    return wrapQWidget(lw);
}

// wrapping not working.  Is a QListWidgetItem a QWidget or QObject?

// SEXP
// qt_qitem(SEXP x, SEXP row)
// {
//     if (row == R_NilValue)
// 	return wrapQObject(unwrapQObject(x, QListWidget)->currentItem());
//     else 
// 	return wrapQObject(unwrapQObject(x, QListWidget)->item(asInteger(row)));
// }


SEXP
qt_qitem(SEXP x, SEXP row)
{
    QListWidget *lw = unwrapQObject(x, QListWidget);
    int r;
    if (row == R_NilValue)
	r = lw->currentRow();
    else 
	r = asInteger(row)-1;
    if (r == -1) return R_NilValue;
    else return qstring2sexp(lw->item(r)->text());
}

SEXP
qt_qaddItem(SEXP x, SEXP labels)
{
    QListWidget *lw = unwrapQObject(x, QListWidget);
    int i, n = length(labels);
    for (i = 0; i < n; i++)
	lw->addItem(sexp2qstring(STRING_ELT(labels, i)));
    return R_NilValue;
}

SEXP
qt_qcurrentRowListWidget(SEXP x)
{
    return ScalarInteger(unwrapQObject(x, QListWidget)->currentRow() + 1);
}

SEXP
qt_qsetItemListWidget(SEXP x, SEXP row, SEXP label)
{
    QListWidget *lw = unwrapQObject(x, QListWidget);
    int r = asInteger(row) - 1;
    if (r >= 0 && r < lw->count()) 
	lw->item(r)->setText(sexp2qstring(label));
    return R_NilValue;
}

SEXP
qt_qsetItemToolTip(SEXP x, SEXP row, SEXP label)
{
    QListWidget *lw = unwrapQObject(x, QListWidget);
    int r = asInteger(row) - 1;
    if (r >= 0 && r < lw->count()) 
	lw->item(r)->setToolTip(sexp2qstring(label));
    return R_NilValue;
}





// At least two more things we want: 
// 
// (1) multiple selection mode: 
// (1) QList<QListWidgetItem *>QListWidget::selectedItems();
//     
// (2) list of selected items: QListWidgetItem::isSelected()


