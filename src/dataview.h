#ifndef QTUTILS_DATAVIEW_H 
#define QTUTILS_DATAVIEW_H 
 
SEXP qt_qtableWidget(SEXP,SEXP); 
SEXP qt_qisSortingEnabled(SEXP); 
SEXP qt_qsetSortingEnabled(SEXP,SEXP); 
SEXP qt_qsetItem(SEXP,SEXP,SEXP,SEXP); 
SEXP qt_qsetCellWidget(SEXP,SEXP,SEXP,SEXP); 
SEXP qt_qresizeColumnsToContents(SEXP,SEXP); 
SEXP qt_qresizeRowsToContents(SEXP,SEXP); 
SEXP qt_qsetHeaderLabels(SEXP,SEXP,SEXP); 
SEXP qt_qsetDim(SEXP,SEXP,SEXP); 
SEXP qt_qcurrentRow(SEXP); 
SEXP qt_qcurrentColumn(SEXP); 
 
#endif 
 
