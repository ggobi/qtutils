library(qtutils)
QT()

dragplot <- function(..., xlim = NULL, ylim = NULL, xaxs = "r", yaxs = "r") {
    plot(..., xlim = xlim, ylim = ylim, xaxs = xaxs, yaxs = yaxs)
    startx <- NULL
    starty <- NULL
    usr <- NULL
    
    devset <- function()
        if (dev.cur() != eventEnv$which) dev.set(eventEnv$which)
    
    dragmousedown <- function(buttons, x, y) {
        ## cat("Down: ", buttons, x, y, "\n")
        startx <<- x
        starty <<- y
        devset()
        usr <<- par("usr")
        eventEnv$onMouseMove <- dragmousemove
        NULL
    }
    
    dragmousemove <- function(buttons, x, y) {
        ## cat("Move: ", buttons, x, y, "\n")
        devset()
        deltax <- diff(grconvertX(c(startx, x), "ndc", "user"))
        deltay <- diff(grconvertY(c(starty, y), "ndc", "user"))
        plot(..., xlim = usr[1:2]-deltax, xaxs = "i",
             ylim = usr[3:4]-deltay, yaxs = "i")
        NULL
    }
    
    mouseup <- function(buttons, x, y) {
        ## cat("Up: ", buttons, x, y, "\n")
        eventEnv$onMouseMove <- NULL
    }   
    
    keydown <- function(key) {
        cat("Key: ", key, "\n")
        if (key == "q") return(invisible(1))
        eventEnv$onMouseMove <- NULL
        NULL
    }
    
    setGraphicsEventHandlers(prompt = "Click and drag, q will quit",
                             onMouseDown = dragmousedown,
                             onMouseUp = mouseup,
                             onKeybd = keydown)
    eventEnv <- getGraphicsEventEnv()
}

dragplot(rnorm(1000), rnorm(1000))


getGraphicsEvent()

