
## functions used by graphics.R


quilt_drawGlyphs <-
    function(scene, pch, x, y, cex = 1,
             stroke = "red", fill = "yellow")
{
    brush <- Qt$QBrush(); brush$setColor(qcolor(fill)); brush$setStyle(Qt$Qt$SolidPattern)
    pen <- Qt$QPen(); pen$setColor(qcolor(stroke))
    for (i in seq_along(x))
    {
        print(i)
        ## str(list(i = i, x = x[i], y = y[i], stroke = stroke, fill = fill))
        ## scene$addEllipse(x[i], y[i], 10, 10)
        ## p <- scene$addPath(qcircle,
        ##                    Qt$QPen(), ## qcolor(stroke)
        ##                    Qt$QBrush() ) ## qcolor(fill)))
        p <- scene$addPath(qcircle, pen, brush)
        ## str(p)
        if (cex != 1) p$scale(cex, cex)
        p$setFlag(Qt$QGraphicsItem$ItemIgnoresTransformations, TRUE)
        p$setPos(x[i], y[i])
    }
}


## quilt_drawLines(scene, pch, x, y, cex = cex, stroke = "black", fill = "transparent")
## {
##     for (i in seq_along(x))
##     {
##         scene$addEllipse(x, y, 10, 10)
##     }
## }

quilt.points <-
    function(x, y = NULL, 
             type = "p", jitter.x = FALSE, jitter.y = FALSE,
             factor = 0.5, amount = NULL, horizontal = FALSE,
             ## pch = qpathCircle(0, 0, 5),
             cex = 1,
             col = "black", fill = "transparent", ...,
             scene)
{
    xy <- xy.coords(x, y, recycle = TRUE)
    n <- length(x <- xy$x)
    y <- xy$y
    if (any(is.finite(x) & is.finite(y)))
    {
        rgb.col <- col2rgb(col, TRUE)
        rgb.fill <- col2rgb(fill, TRUE)
        if ("o" %in% type || "b" %in% type)
            type <- c(type, "p", "l")
        if ("p" %in% type)
        {
            quilt_drawGlyphs(scene, pch,
                             x = if (jitter.x) jitter(x, factor = factor, amount = amount) else x,
                             y = if (jitter.y) jitter(y, factor = factor, amount = amount) else y,
                             cex = cex, stroke = rgb.col, fill = rgb.fill)
        }
            
        ## if ("l" %in% type)
        ##     qdrawLine(painter, x = x, y = y, stroke = rgb.col)
        ## if ("h" %in% type)
        ## {
        ##     if (horizontal)
        ##         qdrawSegment(painter, x, y, 0, y, stroke = rgb.col)
        ##     else
        ##         qdrawSegment(painter, x, y, x, 0, stroke = rgb.col)
        ## }
        ## if ("r" %in% type)
        ##     mosaiq.lmline(x, y, ...)
        ## if ("smooth" %in% type)
        ##     mosaiq.loess(x, y, horizontal = horizontal, ...)
        ## ## if ("a" %in% type) qv.panel.average(x, y, horizontal = horizontal)
    }
}


qcircle <-  Qt$QPainterPath()
qcircle$addEllipse(-5, -5, 10, 10)
