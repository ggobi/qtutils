
## not exactly a REPL, but something that looks like it. The idea is
## to have a widget where one can input R commands, and evaluate them
## on demand.  The typical use case would be a limited REPL as used in
## browser() and recover().


## first prototype: have an editor for text, and an associated
## environment.  Selected text can be evaluated, but the results will
## be shown in the main console


qrepl.old <- function(env = .GlobalEnv)
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

## second attempt: two editors in a layout, one for input and one for
## output.

tryParseEval <- function(text, env)
{
    exprs <- try(parse(text = text), silent = TRUE)
    esrc <- lapply(attr(exprs, "srcref"), as.character)
    if (is(exprs, "try-error")) return (exprs)
    ans <- vector(mode = "list", length = length(exprs))
    for (i in seq_along(exprs))
    {
        ein <- esrc[[i]]
        env$.expr <- exprs[[i]]
        evis <- try(evalq(withVisible(eval(.expr)),
                          envir = env),
                    silent = TRUE)
        if (inherits(evis, "try-error")) return(evis)
        eout <- if (evis$visible) capture.output(evis$value) else NULL
        ans[[i]] <- list(ein = paste("> ", paste(ein, collapse = "\n+ "), sep = ""),
                         eout = if (is.null(eout)) NULL else paste(eout, collapse = "\n"))
    }
    ans
}



qrepl <- function(env = .GlobalEnv)
{
    container <- qwidget()
    ll <- qlayout()
    qsetLayout(container, ll)
    ined <- qeditor(tempfile(), rsyntax = TRUE, richtext = FALSE)
    qsetCurrentFont(ined, qfont("monospace"))
    outed <- qtextEdit()
    qsetCurrentFont(outed, qfont("monospace"))
    ## outed$font <- qfont()
    outed$readOnly <- TRUE
    qsetExpanding(ined, vertical = FALSE)
    ll[1, 1] <- outed
    ll[2, 1] <- ined
    ined$plainText <- "\n## Type code, press Ctrl+Return to evaluate\n\n"
    qsetContextMenuPolicy(ined, "actions")
    runAct <- qaction(desc = "Execute", shortcut = "Ctrl+Return", parent = ined)
    runAct$shortcutContext <- 0 ## only triggered when widget has focus
    qconnect(runAct, signal = "triggered",
             handler = function(x, ...) {
                 pe <- tryParseEval(text = x$ined$plainText, env = env)
                 ## str(pe)
                 if (is(pe, "try-error"))
                 {
                     qappend(x$ined, paste("## ", as.character(pe), collapse = "\n"))
                 }
                 else
                 {
                     x$ined$clear()
                     for (i in seq_along(pe))
                     {
                         qsetTextColor(x$outed, "red")
                         qappend(x$outed, pe[[i]]$ein)
                         qsetTextColor(x$outed, "blue")
                         if (!is.null(pe[[i]]$eout)) qappend(x$outed, pe[[i]]$eout)
                         qsetTextColor(x$outed, "grey")
                     }
                 }
             },
             user.data = list(ined = ined, outed = outed))
    qaddAction(ined, runAct)
    container
}




