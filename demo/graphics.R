
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


## How do we work with QGraphicsLayouts?

## Simple example: A scatterplot with a (strip-like) main title.  Main
## title height should be fixed, scatterplot should occupy full space.

library(qtbase)
source("~/svn/qtinterfaces/pkg/qtutils/demo/quilt.R")

df <- data.frame(x = 1:10, y = sort(rnorm(10)))
lims <- list(xlim = extendrange(range(df$x)),
             ylim = extendrange(range(df$y)))
main <- "Main title"

## easier with widgets

## Label - simple
mainLabel <- Qt$QLabel(main)
mainLabel$setAlignment(Qt$Qt$AlignVCenter | Qt$Qt$AlignHCenter)

## A custom QGraphicsView class

qsetClass("MyView", Qt$QGraphicsView,
          constructor = function(...) {
              parent(...)
              this$setHorizontalScrollBarPolicy(Qt$Qt$ScrollBarAlwaysOff)
              this$setVerticalScrollBarPolicy(Qt$Qt$ScrollBarAlwaysOff)
          })
qsetMethod("resizeEvent", MyView, 
           function(event) {
               this$fitInView(this$sceneRect, Qt$Qt$IgnoreAspectRatio)
           }, "protected")

myscene <- Qt$QGraphicsScene()
myscene$setItemIndexMethod(Qt$QGraphicsScene$NoIndex)
myview <- MyView()
myview$setScene(myscene)
myscene$clear()
with(df, quilt.points(x, y, col = "red", fill = "green", scene = myscene))
axisRect <- Qt$QRectF(lims$xlim[1], lims$ylim[1],
                      lims$xlim[2] - lims$xlim[1],
                      lims$ylim[2] - lims$ylim[1])
axisRectItem <- myscene$addRect(axisRect)
myscene$setSceneRect(axisRect)

## myview$setHorizontalScrollBarPolicy(Qt$Qt$ScrollBarAlwaysOff)
## myview$setVerticalScrollBarPolicy(Qt$Qt$ScrollBarAlwaysOff)

myview

## myview$fitInView(axisRect, Qt$Qt$KeepAspectRatio)
## myview$fitInView(axisRect, Qt$Qt$IgnoreAspectRatio)

root <- Qt$QWidget()
root$setContentsMargins(0, 0, 0, 0)
rlayout <- Qt$QGridLayout(root)
rlayout$setSpacing(0)
rlayout$setContentsMargins(0, 0, 0, 0)

root

rlayout$addWidget(mainLabel, 0, 0)
rlayout$addWidget(myview, 1, 0)


