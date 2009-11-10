
#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>


SEXP qt_qgetDouble(SEXP title, SEXP label, SEXP value, SEXP minValue, SEXP maxValue, SEXP decimals, SEXP parent);
SEXP qt_qgetInteger(SEXP title, SEXP label, SEXP value, SEXP minValue, SEXP maxValue, SEXP step, SEXP parent);
SEXP qt_qgetText(SEXP title, SEXP label, SEXP text, SEXP parent);

#include "editor.h"
#include "dataview.h"
#include "listview.h"
#include "textedit.h"

void R_init_qtutils(DllInfo *dll);

#define CALLDEF(name, n)  {#name, (DL_FUNC) &name, n}

static R_CallMethodDef CallEntries[] = {

    CALLDEF(qt_qgetDouble, 7),
    CALLDEF(qt_qgetInteger, 7),
    CALLDEF(qt_qgetText, 4),

#include "calldefs.inc"

    {NULL, NULL, 0}
};


void R_init_qtutils(DllInfo *dll)
{
    // Register C routines
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}

