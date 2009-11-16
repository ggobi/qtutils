
#include <QWidget>
#include <QListWidget>
#include <QListWidgetItem>

#include <qtbase.h>

extern "C" {
#include "listview.h"
}


SEXP
qt_qaddItem_QListWidget(SEXP x, SEXP labels)
{
    QListWidget *lw = unwrapSmoke(x, QListWidget);
    int i, n = length(labels);
    for (i = 0; i < n; i++)
	lw->addItem(sexp2qstring(STRING_ELT(labels, i)));
    return R_NilValue;
}


// At least two more things we want: 
// 
// (1) multiple selection mode: 
// (1) QList<QListWidgetItem *>QListWidget::selectedItems();
//     
// (2) list of selected items: QListWidgetItem::isSelected()


