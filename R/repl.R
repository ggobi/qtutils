
qselectedText_QTextEdit <- function(x)
{
    ans <- x$textCursor()$selection()$toPlainText()
    if (is.null(ans)) ""
    else ans
}



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




##' Creates a Qt Widget that emulates the R REPL
##'
##' This widget tries to emulate the behaviour of the R command-line
##' interface (Read-Eval-Print-Loop) in a GUI.  The current
##' implementation is essentially a proof-of-concept, and not meant
##' for serious use.
##' 
##' @title A Qt based REPL emulator
##' @param env The evaluation environment for the REPL. 
##' @param font A QFont instance. 
##' @param incolor The color used for code that is evaluated.
##' @param outcolor The color used for output.
##' @param errorcolor The color used for error messages.
##' @param html.preferred Logical.  Whether HTML output is preferred (for table-like objects).
##' @return A QWidget instance
##' @author Deepayan Sarkar
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
                    outed$moveCursor(Qt$QTextCursor$End)
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
                        outed$moveCursor(Qt$QTextCursor$End)
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
            outed$moveCursor(Qt$QTextCursor$End)
        }
    }

    ##qaction(desc = "Execute", shortcut = "Ctrl+Return", parent = ined1)
    runAct1 <- Qt$QAction(text = "Execute", parent = ined1)
    runAct1$setShortcut(Qt$QKeySequence("Ctrl+Return"))
    runHandler1 <- function(checked) { executeCode(ined1$plainText, mode = "input") }
    runAct1$setShortcutContext(Qt$Qt$WidgetShortcut) ## only triggered when widget has focus
    qconnect(runAct1, signal = "triggered", handler = runHandler1)
    ined1$addAction(runAct1)
    
    runAct2 <- Qt$QAction(text = "Execute selection", parent = ined2)
    runAct2$setShortcut(Qt$QKeySequence("Ctrl+Return"))
    ## runAct2 <- qaction(desc = "Execute selection", shortcut = "Ctrl+Return", parent = ined2)
    runHandler2 <- function(checked)
    {
        ## execute if selection exists, else select minimal parseable
        ## input starting backwords from current line
        sel <- qselectedText_QTextEdit(ined2)
        if (nzchar(sel))
        {
            executeCode(sel, mode = "edit")
            ined2$moveCursor(Qt$QTextCursor$StartOfLine)
            ined2$moveCursor(Qt$QTextCursor$Down)
        }
        else
        {
            oldCursor <- ined2$textCursor()
            ## oldPos <- ined2$textCursor()$position()
            ined2$moveCursor(Qt$QTextCursor$EndOfLine)
            ined2$moveCursor(Qt$QTextCursor$StartOfLine, Qt$QTextCursor$KeepAnchor)
            ## qmoveCursor(ined2, "endofline", select = FALSE)
            ## qmoveCursor(ined2, "startofline", select = TRUE)
            parseable <- !is(try(parse(text = qselectedText_QTextEdit(ined2)), silent = TRUE), "try-error")
            reached0 <- ined2$textCursor()$position() == 0L ## qcursorPosition(ined2) == 0L
            while (!parseable && !reached0)
            {
                ined2$moveCursor(Qt$QTextCursor$Up, Qt$QTextCursor$KeepAnchor)
                ## qmoveCursor(ined2, "up", select = TRUE)
                parseable <- !is(try(parse(text = qselectedText_QTextEdit(ined2)), silent = TRUE), "try-error")
                reached0 <- qcursorPosition(ined2) == 0L
            }
            if (!parseable) ## qsetCursorPosition(ined2, oldPos) ## restore
                ined2$setTextCursor(oldCursor)
        }
    }
    runAct2$setShortcutContext(Qt$Qt$WidgetShortcut) ## only triggered when widget has focus
    qconnect(runAct2, signal = "triggered", handler = runHandler2)
    ined2$addAction(runAct2)
    
    ## add action for text-completion (not yet in edit mode)
    compAct1 <- Qt$QAction(text = "Complete", parent = ined1)
    compAct1$setShortcut(Qt$QKeySequence("Ctrl+I"))
    ## qaction(desc = "Complete", shortcut = "Ctrl+I", parent = ined1)
    compAct1$setShortcutContext(Qt$Qt$WidgetShortcut)
    compHandler1 <- function(checked) {
        comps <- tryComplete(text = ined1$plainText, ined1$textCursor()$position())
        ined1$insertPlainText(comps$addition)
        msg$text <-
            if (nzchar(comps$addition) || any(nzchar(comps$comps))) paste(comps$comps)
            else "No completions."
    }
    qconnect(compAct1, signal = "triggered", handler = compHandler1)
    ined1$addAction(compAct1)

    ## save file in edit mode
    saveAct <- Qt$QAction(text = "Save As", parent = ined2)
    saveAct$setShortcut(Qt$QKeySequence("Ctrl+S"))
    saveAct$setShortcutContext(Qt$Qt$WidgetShortcut)
    saveHandler <- function(checked) {
        savetext <- ined2$plainText
        file <- qfile.choose(caption = "Choose output file", filter = "*.R", allow.new = TRUE)
        if (nzchar(file)) cat(savetext, file = file)
    }
    qconnect(saveAct, signal = "triggered", handler = saveHandler)
    ined2$addAction(saveAct)

    ## load file in edit mode
    loadAct <- Qt$QAction(text = "Append contents from file", parent = ined2)
    loadAct$setShortcut(Qt$QKeySequence("Ctrl+O"))
    loadAct$setShortcutContext(Qt$Qt$WidgetShortcut)
    loadHandler <- function(checked) {
        file <- qfile.choose(caption = "Choose file", filter = "*.R", allow.new = FALSE)
        if (nzchar(file)) ined2$append(paste(readLines(file), collapse = "\n"))
    }
    qconnect(loadAct, signal = "triggered", handler = loadHandler)
    ined2$addAction(loadAct)

    ## return containing splitter
    container$resize(600, 400)
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


qreplu <- function(env = .GlobalEnv,
                   font = Qt$QFont("monospace"),
                   incolor = qcolor("red"),
                   outcolor = qcolor("blue"),
                   errorcolor = qcolor("black"),
                   messagecolor = qcolor("black"),
                   html.preferred = FALSE)
{
    ## ed: REPL-like mode, type and execute code
    ed <- qeditor(rsyntax = FALSE, richtext = FALSE)
    ed$setCurrentFont(font)

    ## messages
    msg <- Qt$QLabel("")
    msg$wordWrap <- TRUE
    ## container
    container <- Qt$QSplitter(Qt$Qt$Vertical)
    container$addWidget(ed)
    container$addWidget(msg)
    container$setStretchFactor(0L, 10L)
    container$setStretchFactor(1L, 0L)
    msg$text <- "Type code, press Ctrl+Return to evaluate"

    ed$setContextMenuPolicy(Qt$Qt$ActionsContextMenu)

    ed$insertHtml("<p>Welcome to qrepl().</p> <br>")

    ed$setCurrentFont(font)
    ed$setTextColor(incolor)
    ed$insertPlainText("\n> ")
    ed$moveCursor(Qt$QTextCursor$End)
    lastPosition <- ed$textCursor()$position()

    evalenv <- env
    setEnv <- function(e)
    {
        evalenv <<- e
        m <- capture.output(print(e))
        ## ed$setTextColor(messagecolor)
        ## ed$insertPlainText(sprintf("\n\nChanged active environment to %s.\n", m))
        ## ed$setCurrentFont(font)
        ## ed$setTextColor(incolor)
        ## ed$insertPlainText("\n> ")
        ## ed$moveCursor(Qt$QTextCursor$End)
        ## lastPosition <<- ed$textCursor()$position()
        msg$text <- sprintf("\n\nChanged active environment to %s.\n", m)
   }

    setReadOnlyMode <- function(undo = FALSE)
    {
        ## ed$setReadOnly(ed$textCursor()$position() < lastPosition)
        if (ed$textCursor()$position() < lastPosition)
        {
            if (undo) ed$undo()
            ic <- ed$textCursor()
            ic$setPosition(lastPosition)
            ed$setTextCursor(ic)
        }
    }
    
    qconnect(ed, "cursorPositionChanged", setReadOnlyMode)
    qconnect(ed, "textChanged", setReadOnlyMode, user.data = TRUE)

    processCodeIfReady <- function()
    {
        ed$moveCursor(Qt$QTextCursor$End)
        ic <- ed$textCursor()
        ic$setPosition(lastPosition, Qt$QTextCursor$KeepAnchor)
        ed$setTextCursor(ic)
        intext <- qselectedText_QTextEdit(ed)
        parseable <- !is(try(parse(text = intext), silent = TRUE), "try-error")
        if (parseable)
        {
            ic$removeSelectedText()
            executeCode(intext)
        }
    }

    ## add action to execute code

    runAct <- Qt$QAction(text = "Execute", parent = ed)
    runAct$setShortcut(Qt$QKeySequence("Ctrl+Return"))
    runAct$setShortcutContext(Qt$Qt$WidgetShortcut) ## only triggered when widget has focus
    qconnect(runAct, signal = "triggered", handler = processCodeIfReady)
    ed$addAction(runAct)

    closeAct <- Qt$QAction(text = "Close REPL", parent = ed)
    closeAct$setShortcut(Qt$QKeySequence("Ctrl+Q"))
    closeAct$setShortcutContext(Qt$Qt$WidgetShortcut) ## only triggered when widget has focus
    qconnect(closeAct, signal = "triggered", handler = container$close)
    ed$addAction(closeAct)
    
    ## function to perform code execution

    executeCode <- function(text)
    {
        pe <- tryParseEval(text = text, env = env)
        if (is(pe, "try-error"))
        {
            msg$text <- paste(strsplit(as.character(pe), "\n", fixed = TRUE)[[1]], collapse = "\\n")
            return (FALSE)
        }
        else
        {
            msg$text <- "Evaluating..."
            ic <- ed$textCursor()
            ic$setPosition(lastPosition)
            lastPosition <<- lastPosition - 2L
            ed$setTextCursor(ic)
            ed$moveCursor(Qt$QTextCursor$StartOfLine, Qt$QTextCursor$KeepAnchor)
            ed$textCursor()$removeSelectedText()
            for (i in seq_along(pe))
            {
                ein <- pe[[i]]$ein
                output <- pe[[i]]$output
                evis <- pe[[i]]$evis
                ## input
                ed$setCurrentFont(font)
                ed$setTextColor(incolor)
                ed$insertPlainText(ein)
                ed$insertPlainText("\n")
                ## output
                ed$setTextColor(outcolor)
                ## any captured output (by-product of evaluation)
                if (length(output))
                    ed$insertPlainText(paste(output, collapse = "\n"))
                ## return value of evaluation (may need to be printed)
                if (inherits(evis, "try-error"))
                {
                    ed$moveCursor(Qt$QTextCursor$End)
                    ed$setTextColor(errorcolor)
                    ed$insertPlainText(paste(strsplit(as.character(evis), "\n")[[1]],
                                    collapse = "\n")) # remove final newline
                }
                else if (evis$visible)
                {
                    if (html.preferred &&
                        !inherits(try(xtab <- xtable(evis$value), silent = TRUE),
                                  "try-error"))
                    {
                        ed$moveCursor(Qt$QTextCursor$End)
                        html.output <- capture.output(print(xtab, type = "html"))
                        ## FIXME: need something append-like (add to end)
                        ed$insertHtml(paste(html.output, collapse = "\n"))
                    }
                    else
                    {
                        text.output <- capture.output(evis$value)
                        ed$insertPlainText(paste(text.output, collapse = "\n"))
                    }
                }
            }
            ed$setTextColor(incolor)
            ed$insertPlainText("\n> ")
            ed$moveCursor(Qt$QTextCursor$End)
            lastPosition <<- ed$textCursor()$position()
            msg$text <- "Type code, press Ctrl+Return to evaluate"
        }
    }

    ## return containing splitter
    container$resize(600, 400)
    attr(container, "setEnv") <- setEnv
    container
}


