

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


