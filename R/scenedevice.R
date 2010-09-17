

qsceneDevice <-
    function(width = 7, height = 7, pointsize = 12, family = "",
             rscene = Qt$QGraphicsScene())
{
    force(rscene)
    .Call(qt_qsceneDevice,
          as.numeric(width),
          as.numeric(height),
          as.numeric(pointsize),
          as.character(family),
          rscene)
    invisible(rscene)
}


QT <- function(..., antialias = TRUE)
{
    rscene <- qsceneDevice(...)
    gview <- Qt$QGraphicsView(rscene)
    if (antialias) gview$setRenderHints(Qt$QPainter$Antialiasing) 
    gview$setDragMode(Qt$QGraphicsView$ScrollHandDrag)

    ## Activate context menu with actions
    gview$setContextMenuPolicy(Qt$Qt$ActionsContextMenu)

    ## Add "Actions" to scale
    zoominAct <- Qt$QAction("Zoom In", gview)
    zoominAct$setShortcut(Qt$QKeySequence("Ctrl++"))
    qconnect(zoominAct,
             signal = "triggered",
             handler = function(checked) {
                 gview$scale(1.2, 1.2)
             })
    gview$addAction(zoominAct)
    zoomoutAct <- Qt$QAction("Zoom Out", gview)
    zoomoutAct$setShortcut(Qt$QKeySequence("Ctrl+-"))
    qconnect(zoomoutAct,
             signal = "triggered",
             handler = function(checked) {
                 gview$scale(1/1.2, 1/1.2)
             })
    gview$addAction(zoomoutAct)

    ## Helper function to print
    printHandler <- function(full = TRUE)
    {
        printer <- Qt$QPrinter(Qt$QPrinter$HighResolution)
        rpaper <- getOption("papersize")
        if (is.null(rpaper)) rpaper <- "A4"
        qtpaper <- names(Qt$QPrinter)
        usepaper <- qtpaper[ match(tolower(rpaper), tolower(qtpaper)) ]
        if (is.na(usepaper)) usepaper <- "A4"
        printer$setPageSize(Qt$QPrinter[[usepaper]])
        pd <- Qt$QPrintDialog(printer)
        acceptPrint <- pd$exec()
        if (acceptPrint)
        {
            painter <- Qt$QPainter()
            painter$begin(printer)
            if (full)
                rscene$render(painter)
            else
                gview$render(painter)
            painter$end()
        }
    }
    
    ## Actions to print
    printAct <- Qt$QAction("Print", gview)
    printAct$setShortcut(Qt$QKeySequence("Ctrl+P"))
    qconnect(printAct,
             signal = "triggered",
             handler = function(checked) {
                 printHandler(TRUE)
             })
    gview$addAction(printAct)
    printVisibleAct <- Qt$QAction("Print visible", gview)
    qconnect(printVisibleAct,
             signal = "triggered",
             handler = function(checked) {
                 printHandler(FALSE)
             })
    gview$addAction(printVisibleAct)

    ## Action to export (to image file)
    addImageExportAction(gview)

    ## Return view widget
    gview
}


## This is a bit more involved, so factor out as separate function.
## May want to do something for printing as well, and maybe also PDF
## export to file with custom width/height and margins.  Direct export
## to PDF (like copy2pdf) could definitely be useful.

## This function is exported, and can be useful for any view
exportToFile <-
    function(gview, fileName,
             fmt = tail(strsplit(basename(fileName), ".", fixed = TRUE)[[1]], 1),
             full = FALSE)
{
        size <-
            if (full) gview$sceneRect$size()
            else gview$size
        qimg <- Qt$QImage(size$toSize(), Qt$QImage$Format_ARGB32_Premultiplied)
        qimg$fill(0L) ## FIXME: need color to uint conversion
        painter <- Qt$QPainter()
        painter
        painter$begin(qimg)
        painter$setRenderHint(Qt$QPainter$Antialiasing)
        painter$setRenderHint(Qt$QPainter$TextAntialiasing)
        if (full)
            gview$scene()$render(painter)
        else
            gview$render(painter)
        painter$end()
        qimg$save(fileName, toupper(fmt))
}

saveAsImage <- function(gview, fmt, full = TRUE)
{
    initialPath <- file.path(getwd(), paste("untitled.", tolower(fmt), sep = ""))
    fileName <-
        Qt$QFileDialog$getSaveFileName(gview, "Save As",
                                       initialPath,
                                       sprintf("%s Files (*.%s);;All Files (*)",
                                               toupper(fmt),
                                               toupper(fmt)))
    if (!is.null(fileName)) {
        exportToFile(gview, fileName, fmt = fmt, full = full)
    }
}

addImageExportAction <- function(gview)
{
    saveAsMenu <- Qt$QMenu("&Export As", gview)
    ## FIXME: doesn't work because QByteArray not handled
    ## supportedFormats <- unlist(QImageReader::supportedImageFormats()))
    supportedFormats <- c("BMP", "JPG", "PNG")
    for (fmt in supportedFormats)
    {
        action <- Qt$QAction(fmt, gview)
        qconnect(action, signal = "triggered",
                 handler = function(user.data) {
                     saveAsImage(gview, user.data)
                 }, user.data = fmt)
        saveAsMenu$addAction(action)
    }
    saveAsAct <- saveAsMenu$menuAction()
    gview$addAction(saveAsAct)
}

