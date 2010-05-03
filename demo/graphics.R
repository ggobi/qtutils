
## We need to update qtpaint to resurrect mosaiq.  But in the
## meantime, how much can we do just with built-in
## QGraphicsScene/View?

library(qtbase)
source("~/svn/qtinterfaces/pkg/qtutils/demo/quilt.R")

myscene <- Qt$QGraphicsScene()

myview <- Qt$QGraphicsView()
myview$setScene(myscene)

myview

## myscene$addEllipse(0, 0, 10, 10)
## myscene$addEllipse(10, 10, 10, 10)


myscene$clear()

quilt.points(30 * rnorm(100), 20 * rnorm(100),
             col = "red", fill = "green",
             scene = myscene)

myview$scale(3, 3)

## myview$fitInView(myscene$sceneRect, Qt$Qt$KeepAspectRatio)
myview$fitInView(-50, -50, 100, 100, Qt$Qt$KeepAspectRatio)
