
## various utilities, typically modal dialogs such as file chooser,
## yes/no dialogs, or message dialogs.

qfile.choose <-
    function(caption = "", dir = "", filter = "",
             allow.new = FALSE,
             parent = NULL)
{
    FUN <-
        if (allow.new) Qt$QFileDialog$getSaveFileName
        else Qt$QFileDialog$getOpenFileName
    ans <- FUN(parent, as.character(caption),
               path.expand(dir), as.character(filter))
    (ans)
}

qdir.choose <- function(caption = "", dir = "", parent = NULL)
{
    FUN <- Qt$QFileDialog$getExistingDirectory
    ans <- FUN(parent,
               as.character(caption),
               as.character(dir))
    (ans)
}

qgetColor <- function(parent = NULL, title = "",
                      alpha = 1)
{
    ok <- TRUE
    FUN <- Qt$QColorDialog$getColor
    ans <- FUN(Qt$QColor(255, 255, 255),
               parent,
               as.character(title))
    if (ans$isValid())
        rgb(ans$red(), ans$green(), ans$blue(),
            alpha * 255, maxColorValue = 255)
    else NA_character_
}

qgetDouble <-
    function(title = "Choose value",
             label = "Enter a numeric value",
             value = 0.0,
             minValue = -.Machine$double.xmax,
             maxValue = .Machine$double.xmax,
             decimals = 3L, parent = NULL)
{
    FUN <- Qt$QInputDialog$getDouble
    ans <- FUN(parent,
               as.character(title),
               as.character(label),
               as.double(value),
               as.double(minValue),
               as.double(maxValue),
               as.integer(decimals))
    (ans)
}

qgetInteger <-
    function(title = "Choose value", label = "Enter an integer value", value = 0L,
             minValue = -.Machine$integer.max,
             maxValue = .Machine$integer.max,
             step = 1L, parent = NULL)
{
    stop("Not fixed -- easy")
    ## .Call(qt_qgetInteger,
    ##       as.character(title)[1],
    ##       as.character(label)[1],
    ##       as.integer(value)[1],
    ##       as.integer(minValue)[1], as.integer(maxValue)[1],
    ##       as.integer(step)[1],
    ##       if (is(parent, "QWidget")) parent else NULL)
}

qgetText <-
    function(title = "Choose value", label = "Enter a text string",
             text = "", parent = NULL)
{
    stop("Not fixed -- easy")
    ## .Call(qt_qgetText,
    ##       as.character(title)[1],
    ##       as.character(label)[1],
    ##       as.character(text)[1], 
    ##       if (is(parent, "QWidget")) parent else NULL)
}


##


qexport <- function(x, ...)
{
    stop("Not updated yet")
    ## UseMethod("qexport")
}


qexport.QWidget <-
    function(x,
             file = qfile.choose(caption = "Choose output file",
                                 allow.new = TRUE, parent = x),
             type, ...)
{
    file <- as.character(file)
    stopifnot(length(file) == 1)
    if (nzchar(file)) ## file=="" if selection cancelled
    {
        extension <- tail(strsplit(basename(file), ".", fixed = TRUE)[[1]], 1)
        if (missing(type))
            type <-
                if (tolower(extension) %in% c("ps", "pdf")) "vector"
                else if (tolower(extension) %in% "svg") "svg"
                else "raster"
        switch(type,
               svg = qrenderToSVG(x, file),
               raster = qrenderToPixmap(x, file),
               vector = qrender(x, file))
        invisible()
    }
}

## FIXME: make this accept a file argument
qexport.QGraphicsView <-
    function(x, ...)
{
    qrenderGraphicsView(x)
}

