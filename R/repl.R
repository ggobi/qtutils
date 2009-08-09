
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
        .GlobalEnv$.qexpr <- exprs[[i]] # env$.expr <- exprs[[i]]
        output <-
            capture.output(evis <- try(evalq(withVisible(eval(.GlobalEnv$.qexpr)),
                                             envir = env),
                                        silent = TRUE))
        ##eout <- evis
        ans[[i]] <- list(ein = paste("> ", paste(ein, collapse = "\n+ "), sep = ""),
                         evis = evis,
                         output = output)
    }
    ans
}



## tryParseEval.old <- function(text, env)
## {
##     exprs <- try(parse(text = text), silent = TRUE)
##     esrc <- lapply(attr(exprs, "srcref"), as.character)
##     if (is(exprs, "try-error")) return (exprs)
##     ans <- vector(mode = "list", length = length(exprs))
##     for (i in seq_along(exprs))
##     {
##         ein <- esrc[[i]]
##         .GlobalEnv$.qexpr <-  # env$.expr <- exprs[[i]]
##         evis <- try(capture.output(eval(exprs[[i]], envir = env)),
##                     silent = TRUE)
##         eout <- 
##             if (inherits(evis, "try-error")) strsplit(as.character(evis), "\n", fixed = TRUE)[[1]]
##             else if (length(evis) > 0) evis
##             else NULL
##         ans[[i]] <- list(ein = paste("> ", paste(ein, collapse = "\n+ "), sep = ""),
##                          eout = if (is.null(eout)) NULL else paste(eout, collapse = "\n"))
##     }
##     ans
## }



qrepl <- function(env = .GlobalEnv,
                  font = qfont("monospace"),
                  incolor = qcolor("red"),
                  outcolor = qcolor("blue"),
                  errorcolor = qcolor("black"),
                  html.preferred = TRUE)
{
    ## input
    ined <- qeditor(tempfile(), rsyntax = TRUE, richtext = TRUE)
    ined$setCurrentFont(font)
    ## output
    outed <- qtextEdit()
    outed$readOnly <- TRUE
    qsetExpanding(ined, vertical = FALSE)
    qsetExpanding(outed, vertical = TRUE)
    ## container
    container <- qsplitter(horizontal = FALSE)
    qaddWidget(container, outed)
    qaddWidget(container, ined)
    qsetStretchFactor(container, 0L, 10L)
    qsetStretchFactor(container, 1L, 0L)
    ined$append("## Type code, press Ctrl+Return to evaluate\n")
    ## add action to execute code
    qsetContextMenuPolicy(ined, "actions")
    runAct <- qaction(desc = "Execute", shortcut = "Ctrl+Return", parent = ined)
    runHandler = function(x, ...) {
        pe <- tryParseEval(text = ined$plainText, env = env)
        if (is(pe, "try-error"))
        {
            ined$append(paste("## ",
                              strsplit(as.character(pe), "\n", fixed = TRUE)[[1]],
                              collapse = "\n"))
        }
        else
        {
            ined$selectAll()
            ined$setCurrentFont(font)
            for (i in seq_along(pe))
            {
                ein <- pe[[i]]$ein
                output <- pe[[i]]$output
                evis <- pe[[i]]$evis
                ## input
                outed$setCurrentFont(font)
                outed$setTextColor(incolor)
                outed$append(ein)
                ## output
                outed$setTextColor(outcolor)
                ## any captured output (by product of evaluation)
                if (length(output))
                    outed$append(paste(output, collapse = "\n"))
                ## return value of evaluation (may need to be printed)
                if (inherits(evis, "try-error"))
                {
                    outed$setTextColor(errorcolor)
                    outed$append(as.character(evis))
                }
                else if (evis$visible)
                {
                    if (html.preferred &&
                        !inherits(try(xtab <- xtable(evis$value), silent = TRUE),
                                  "try-error"))
                    {
                        html.output <- capture.output(print(xtab, type = "html"))
                        outed$insertHtml(paste(html.output, collapse = "\n"))
                    }
                    else
                    {
                        text.output <- capture.output(evis$value)
                        outed$append(paste(text.output, collapse = "\n"))
                    }
                }
            }
        }
    }
    runAct$shortcutContext <- 0 ## only triggered when widget has focus
    qconnect(runAct, signal = "triggered", handler = runHandler)
    ## user.data = list(ined = ined, outed = outed))
    qaddAction(ined, runAct)
    container
}

