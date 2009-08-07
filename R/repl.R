
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
    container <- qsplitter(horizontal = FALSE)
    ined <- qeditor(tempfile(), rsyntax = TRUE, richtext = FALSE)
    ## ined$setCurrentFont(qfont("monospace"))
    outed <- qtextEdit()
    outed$setCurrentFont(qfont("monospace"))
    ## outed$font <- qfont()
    outed$readOnly <- TRUE
    qsetExpanding(ined, vertical = FALSE)
    qaddWidget(container, outed)
    qaddWidget(container, ined)
    qsetStretchFactor(container, 0L, 10L)
    qsetStretchFactor(container, 1L, 0L)
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
                     x$ined$append(paste("## ", as.character(pe), collapse = "\n"))
                 }
                 else
                 {
                     x$ined$selectAll()
                     for (i in seq_along(pe))
                     {
                         x$outed$setTextColor(qcolor("red"))
                         x$outed$append(pe[[i]]$ein)
                         x$outed$setTextColor(qcolor("blue"))
                         if (!is.null(pe[[i]]$eout)) x$outed$append(pe[[i]]$eout)
                         x$outed$setTextColor(qcolor("grey"))
                     }
                 }
             },
             user.data = list(ined = ined, outed = outed))
    qaddAction(ined, runAct)
    container
}




