
## not exactly a REPL, but something that looks like it. The idea is
## to have a widget where one can input R commands, and evaluate them
## on demand.  The typical use case would be a limited REPL as used in
## browser() and recover().


## Two editors in a splitter, one for input and one for output.



tryComplete <- function(text, cursor = nchar(text))
{
    utils:::.win32consoleCompletion(linebuffer = text, cursorPosition = cursor,
                                    check.repeat = TRUE, 
                                    minlength = -1)
}


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

qrepl <- function(env = .GlobalEnv,
                  font = qfont("monospace"),
                  incolor = qcolor("red"),
                  outcolor = qcolor("blue"),
                  errorcolor = qcolor("black"),
                  html.preferred = require(xtable))
{
    ## input
    ined <- qeditor(tempfile(), rsyntax = TRUE, richtext = TRUE)
    ined$setCurrentFont(font)
    ## output
    outed <- qtextEdit()
    outed$readOnly <- TRUE
    qsetExpanding(ined, vertical = FALSE)
    qsetExpanding(outed, vertical = TRUE)
    ## messages
    msg <- qlabel("")
    msg$wordWrap <- TRUE
    ## container
    container <- qsplitter(horizontal = FALSE)
    qaddWidget(container, outed)
    qaddWidget(container, ined)
    qaddWidget(container, msg)
    qsetStretchFactor(container, 0L, 10L)
    qsetStretchFactor(container, 1L, 0L)
    qsetStretchFactor(container, 2L, 0L)
    msg$text <- "Type code, press Ctrl+Return to evaluate"
    ## add action to execute code
    qsetContextMenuPolicy(ined, "actions")
    runAct <- qaction(desc = "Execute", shortcut = "Ctrl+Return", parent = ined)
    runHandler = function() {
        pe <- tryParseEval(text = ined$plainText, env = env)
        if (is(pe, "try-error"))
        {
            msg$text <- paste(as.character(pe), collapse = "\n")
        }
        else
        {
            msg$text <- ""
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
                    qmoveCursor(outed, "end")
                    outed$setTextColor(errorcolor)
                    outed$append(paste(strsplit(as.character(evis), "\n")[[1]],
                                       collapse = "\n")) # remove final newline
                }
                else if (evis$visible)
                {
                    if (html.preferred &&
                        !inherits(try(xtab <- xtable(evis$value), silent = TRUE),
                                  "try-error"))
                    {
                        qmoveCursor(outed, "end")
                        html.output <- capture.output(print(xtab, type = "html"))
                        ## FIXME: need something append-like (add to end)
                        outed$insertHtml(paste(html.output, collapse = "\n"))
                    }
                    else
                    {
                        text.output <- capture.output(evis$value)
                        outed$append(paste(text.output, collapse = "\n"))
                    }
                }
            }
            qmoveCursor(outed, "end")
        }
    }
    runAct$shortcutContext <- 0 ## only triggered when widget has focus
    qconnect(runAct, signal = "triggered", handler = runHandler)
    qaddAction(ined, runAct)
    ## add action for text-completion
    compAct <- qaction(desc = "Complete", shortcut = "Ctrl+I", parent = ined)
    compAct$shortcutContext <- 0 ## only triggered when widget has focus
    compHandler = function() {
        comps <- tryComplete(text = ined$plainText, qcursorPosition(ined))
        ined$insertPlainText(comps$addition)
        if (length(comps$comps))
        {
            msg$text <- paste(comps$comps)
        }
    }
    qconnect(compAct, signal = "triggered", handler = compHandler)
    qaddAction(ined, compAct)
    ## return containing splitter
    container
}

