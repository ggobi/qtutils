
## various utilities, typically modal dialogs such as file chooser,
## yes/no dialogs, or message dialogs.

qfile.choose <-
    function(caption = "", dir = "", filter = "",
             allow.new = FALSE,
             parent = NULL)
{
    .Call(qt_qfile_choose,
          as.character(caption[1]),
          as.character(dir[1]),
          as.character(filter[1]),
          as.integer(allow.new[1]),
          if (is(parent, "QWidget")) parent else NULL)
}

qdir.choose <- function(caption = "", dir = "", parent = NULL)
{
    .Call(qt_qdir_choose,
          as.character(caption[1]),
          as.character(dir[1]),
          if (is(parent, "QWidget")) parent else NULL)
}

qexport <- function(x, ...) UseMethod("qexport")

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




qgetColor <- function(parent = NULL)
{
    ans <-
        .Call(qt_qgetColor,
              if (is(parent, "QWidget")) parent else NULL)
    rgb(ans[1], ans[2], ans[3], ans[4], maxColorValue = 255)
}

qgetDouble <-
    function(title = "Choose value", label = "Enter a numeric value", value = 0.0,
             minValue = -.Machine$double.xmax,
             maxValue = .Machine$double.xmax,
             decimals = 3L, parent = NULL)
{
    .Call(qt_qgetDouble,
          as.character(title)[1],
          as.character(label)[1],
          as.double(value)[1],
          as.double(minValue)[1], as.double(maxValue)[1],
          as.integer(decimals)[1],
          if (is(parent, "QWidget")) parent else NULL)
}

qgetInteger <-
    function(title = "Choose value", label = "Enter an integer value", value = 0L,
             minValue = -.Machine$integer.max,
             maxValue = .Machine$integer.max,
             step = 1L, parent = NULL)
{
    .Call(qt_qgetInteger,
          as.character(title)[1],
          as.character(label)[1],
          as.integer(value)[1],
          as.integer(minValue)[1], as.integer(maxValue)[1],
          as.integer(step)[1],
          if (is(parent, "QWidget")) parent else NULL)
}

qgetText <-
    function(title = "Choose value", label = "Enter a text string",
             text = "", parent = NULL)
{
    .Call(qt_qgetText,
          as.character(title)[1],
          as.character(label)[1],
          as.character(text)[1], 
          if (is(parent, "QWidget")) parent else NULL)
}


