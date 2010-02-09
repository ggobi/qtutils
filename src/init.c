
#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>

#include "editor.h"
#include "dataview.h"
#include "listview.h"
#include "textedit.h"

SEXP qt_qsceneDevice(SEXP width, SEXP height, SEXP pointsize, SEXP family, SEXP rscene);

void R_init_qtutils(DllInfo *dll);

#define CALLDEF(name, n)  {#name, (DL_FUNC) &name, n}

static R_CallMethodDef CallEntries[] = {

#include "calldefs.inc"

    CALLDEF(qt_qsceneDevice, 5),

    {NULL, NULL, 0}
};


void R_init_qtutils(DllInfo *dll)
{
    // Register C routines
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}

