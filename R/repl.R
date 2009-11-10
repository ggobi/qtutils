
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
                  font = Qt$QFont("monospace"),
                  incolor = qcolor("red"),
                  outcolor = qcolor("blue"),
                  errorcolor = qcolor("black"),
                  html.preferred = require(xtable))
{
    ## input1: REPL-like mode, type and execute code
    ined1 <- qeditor(rsyntax = TRUE, richtext = TRUE)
    ined1$setCurrentFont(font)
    ## input2: Editor mode, select and execute code.  input1 text gets appended here
    ined2 <- qeditor(rsyntax = TRUE, richtext = TRUE)
    ined2$setCurrentFont(font)
    ## output
    outed <- Qt$QTextEdit()
    outed$readOnly <- TRUE
    ## tabbed widget holding the two input editors
    intab <- Qt$QTabWidget()
    intab$addTab(ined1, label = "Input mode")
    intab$addTab(ined2, label = "Edit mode")

    intab$setSizePolicy(Qt$QSizePolicy$Expanding,
                        Qt$QSizePolicy$Preferred)
    outed$setSizePolicy(Qt$QSizePolicy$Expanding,
                        Qt$QSizePolicy$Expanding)
    ## qsetExpanding(intab, vertical = FALSE)
    ## qsetExpanding(outed, vertical = TRUE)
    ## messages
    msg <- Qt$QLabel("")
    msg$wordWrap <- TRUE
    ## container
    container <- Qt$QSplitter(Qt$Qt$Vertical)
    container$addWidget(outed)
    container$addWidget(intab)
    container$addWidget(msg)
    container$setStretchFactor(0L, 10L)
    container$setStretchFactor(1L, 0L)
    container$setStretchFactor(2L, 0L)
    msg$text <- "Type code, press Ctrl+Return to evaluate"
    ## add action to execute code
    ined1$setContextMenuPolicy(Qt$Qt$ActionsContextMenu)
    ined2$setContextMenuPolicy(Qt$Qt$ActionsContextMenu)
    ## function to perform code execution

    executeCode <- function(text, mode = c("input", "edit"))
    {
        mode <- match.arg(mode)
        pe <- tryParseEval(text = text, env = env)
        if (is(pe, "try-error"))
        {
            msg$text <- paste(strsplit(as.character(pe), "\n", fixed = TRUE)[[1]], collapse = "\\n")
        }
        else
        {
            msg$text <- ""
            if (mode == "input")
            {
                ined1$selectAll()
                ined1$setCurrentFont(font)
                ined2$append(text)
            }
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

    runAct1 <- qaction(desc = "Execute", shortcut = "Ctrl+Return", parent = ined1)
    runHandler1 <- function() { executeCode(ined1$plainText, mode = "input") }
    runAct1$shortcutContext <- 0 ## only triggered when widget has focus
    qconnect(runAct1, signal = "triggered", handler = runHandler1)
    qaddAction(ined1, runAct1)
    
    runAct2 <- qaction(desc = "Execute selection", shortcut = "Ctrl+Return", parent = ined2)
    runHandler2 <- function()
    {
        ## execute if selection exists, else select minimal parseable
        ## input starting backwords from current line
        sel <- qselectedText(ined2)
        if (nzchar(sel))
        {
            executeCode(sel, mode = "edit")
            qmoveCursor(ined2, "startofline", select = FALSE)
            qmoveCursor(ined2, "down", select = FALSE)
        }
        else
        {
            oldPos <- qcursorPosition(ined2)
            qmoveCursor(ined2, "endofline", select = FALSE)
            qmoveCursor(ined2, "startofline", select = TRUE)
            parseable <- !is(try(parse(text = qselectedText(ined2)), silent = TRUE), "try-error")
            reached0 <- qcursorPosition(ined2) == 0L
            while (!parseable && !reached0)
            {
                qmoveCursor(ined2, "up", select = TRUE)
                parseable <- !is(try(parse(text = qselectedText(ined2)), silent = TRUE), "try-error")
                reached0 <- qcursorPosition(ined2) == 0L
            }
            if (!parseable) qsetCursorPosition(ined2, oldPos) ## restore
        }
    }
    runAct2$shortcutContext <- 0 ## only triggered when widget has focus
    qconnect(runAct2, signal = "triggered", handler = runHandler2)
    qaddAction(ined2, runAct2)
    
    ## add action for text-completion (not yet in edit mode)
    compAct1 <- qaction(desc = "Complete", shortcut = "Ctrl+I", parent = ined1)
    compAct1$shortcutContext <- 0 ## only triggered when widget has focus
    compHandler1 <- function() {
        comps <- tryComplete(text = ined1$plainText, qcursorPosition(ined1))
        ined1$insertPlainText(comps$addition)
        msg$text <-
            if (nzchar(comps$addition) || any(nzchar(comps$comps))) paste(comps$comps)
            else "No completions."
    }
    qconnect(compAct1, signal = "triggered", handler = compHandler1)
    qaddAction(ined1, compAct1)

    ## save file in edit mode
    saveAct <- qaction(desc = "Save As", shortcut = "Ctrl+S", parent = ined2)
    saveAct$shortcutContext <- 0 ## only triggered when widget has focus
    saveHandler <- function() {
        savetext <- ined2$plainText
        file <- qfile.choose(caption = "Choose output file", filter = "*.R", allow.new = TRUE)
        if (nzchar(file)) cat(savetext, file = file)
    }
    qconnect(saveAct, signal = "triggered", handler = saveHandler)
    qaddAction(ined2, saveAct)

    ## load file in edit mode
    saveAct <- qaction(desc = "Append contents from file", shortcut = "Ctrl+O", parent = ined2)
    saveAct$shortcutContext <- 0 ## only triggered when widget has focus
    saveHandler <- function() {
        file <- qfile.choose(caption = "Choose file", filter = "*.R", allow.new = FALSE)
        if (nzchar(file)) ined2$append(paste(readLines(file), collapse = "\n"))
    }
    qconnect(saveAct, signal = "triggered", handler = saveHandler)
    qaddAction(ined2, saveAct)


    ## return containing splitter
    container
}



## ## text zoom: doesn't wok because font reset during each eval
## zoominAct1 <- qaction(desc = "Increase text size", shortcut = "Ctrl++", parent = ined1)
## zoominAct1$shortcutContext <- 0 ## only triggered when widget has focus
## qconnect(zoominAct1, signal = "triggered", handler = function() ined1$zoomIn())
## qaddAction(ined1, zoominAct1)

## zoomoutAct1 <- qaction(desc = "Decrease text size", shortcut = "Ctrl+-", parent = ined1)
## zoomoutAct1$shortcutContext <- 0 ## only triggered when widget has focus
## qconnect(zoomoutAct1, signal = "triggered", handler = function() ined1$zoomOut())
## qaddAction(ined1, zoomoutAct1)

## zoominAct2 <- qaction(desc = "Increase text size", shortcut = "Ctrl++", parent = ined2)
## zoominAct2$shortcutContext <- 0 ## only triggered when widget has focus
## qconnect(zoominAct2, signal = "triggered", handler = function() ined2$zoomIn())
## qaddAction(ined2, zoominAct2)

## zoomoutAct2 <- qaction(desc = "Decrease text size", shortcut = "Ctrl+-", parent = ined2)
## zoomoutAct2$shortcutContext <- 0 ## only triggered when widget has focus
## qconnect(zoomoutAct2, signal = "triggered", handler = function() ined2$zoomOut())
## qaddAction(ined2, zoomoutAct2)
