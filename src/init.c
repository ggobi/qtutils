
#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>


SEXP qt_qfile_choose(SEXP caption, SEXP dir, 
		     SEXP filter, SEXP allowNew, 
		     SEXP parent);
SEXP qt_qdir_choose(SEXP caption, SEXP dir, SEXP parent);
SEXP qt_qgetColor(SEXP parent);
SEXP qt_qgetDouble(SEXP title, SEXP label, SEXP value, SEXP minValue, SEXP maxValue, SEXP decimals, SEXP parent);
SEXP qt_qgetInteger(SEXP title, SEXP label, SEXP value, SEXP minValue, SEXP maxValue, SEXP step, SEXP parent);
SEXP qt_qgetText(SEXP title, SEXP label, SEXP text, SEXP parent);

SEXP qt_qeditor(SEXP file, SEXP readonly, SEXP richtext, SEXP rsyntax);
SEXP qt_qselectedText_QTextEdit(SEXP x);


/* from dataview.cpp */

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

/* from listview.cpp */

SEXP qt_qlistWidget(SEXP labels);
SEXP qt_qitem(SEXP x, SEXP row);
SEXP qt_qaddItem(SEXP x, SEXP labels);
SEXP qt_qcurrentRowListWidget(SEXP x);
SEXP qt_qsetItemListWidget(SEXP x, SEXP row, SEXP label);
SEXP qt_qsetItemToolTip(SEXP x, SEXP row, SEXP label);


void R_init_qtutils(DllInfo *dll);

#define CALLDEF(name, n)  {#name, (DL_FUNC) &name, n}

static R_CallMethodDef CallEntries[] = {

    CALLDEF(qt_qfile_choose, 5),
    CALLDEF(qt_qdir_choose, 3),
    CALLDEF(qt_qgetColor, 1),
    CALLDEF(qt_qgetDouble, 7),
    CALLDEF(qt_qgetInteger, 7),
    CALLDEF(qt_qgetText, 4),
    CALLDEF(qt_qeditor, 4),
    CALLDEF(qt_qselectedText_QTextEdit, 1),

    CALLDEF(qt_qtableWidget, 2),
    CALLDEF(qt_qisSortingEnabled, 1),
    CALLDEF(qt_qsetSortingEnabled, 2),
    CALLDEF(qt_qsetItem, 4),
    CALLDEF(qt_qsetCellWidget, 4),
    CALLDEF(qt_qresizeColumnsToContents, 2),
    CALLDEF(qt_qresizeRowsToContents, 2),
    CALLDEF(qt_qsetHeaderLabels, 3),
    CALLDEF(qt_qsetDim, 3),
    CALLDEF(qt_qcurrentColumn, 1),
    CALLDEF(qt_qcurrentRow, 1),

    CALLDEF(qt_qlistWidget, 1),
    CALLDEF(qt_qitem, 2),
    CALLDEF(qt_qaddItem, 2),
    CALLDEF(qt_qcurrentRowListWidget, 1),
    CALLDEF(qt_qsetItemListWidget, 3),
    CALLDEF(qt_qsetItemToolTip, 3),

    {NULL, NULL, 0}
};


void R_init_qtutils(DllInfo *dll)
{
    // Register C routines
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}

