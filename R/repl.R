
## not exactly a REPL, but something that looks like it. The idea is
## to have a widget where one can input R commands, and evaluate them
## on demand.  The typical use case would be a limited REPL as used in
## browser() and recover().


## first prototype: have an editor for text, and an associated
## environment.  Selected text can be evaluated, but the results will
## be shown in the main console


qrepl <- function(env = .GlobalEnv)
{
    ed <- qeditor(tempfile())
    ed$plainText <- "\n## Type code, select and \n## press Ctrl+R to evaluate in \n## this environment\n\n"
    qsetContextMenuPolicy(ed, "actions")
    runAct <- qaction(desc = "Execute selection", shortcut = "Ctrl+R", parent = ed)
    runAct$shortcutContext <- 0 ## only triggered when widget has focus
    qconnect(runAct, signal = "triggered",
             handler = function(x, ...) {
                 .u_tryEval(text = qselectedText(x), env = env)
             },
             user.data = ed)
    qaddAction(ed, runAct)
    ed
}





