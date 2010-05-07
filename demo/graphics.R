
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

## Simple example: A scatterplot with a (strip-like) main title, and a y-axis.  Main
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

## A custom QGraphicsView class for the scatterplot

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

myview


## A custom QGraphicsView class for the y-axis

qsetClass("MyYAxis", Qt$QGraphicsView,
          constructor = function(..., limit = c(0, 1), rot = 0) {
              parent(...)
              this$setHorizontalScrollBarPolicy(Qt$Qt$ScrollBarAlwaysOff)
              this$setVerticalScrollBarPolicy(Qt$Qt$ScrollBarAlwaysOff)
              this$limit <- limit
              this$rot <- rot
          })
qsetMethod("resizeEvent", MyYAxis, 
           function(event) {
               scene <- this$scene() ## FIXME: what if null?
               scene$clear()
               at <- pretty(this$limit)
               labels <- as.character(at)
               keep <- at > min(this$limit) & at < max(this$limit)
               at <- at[keep]
               labels <- labels[keep]
               for (i in seq_along(at))
               {
                   text <- scene$addText(labels[i])
                   brect <- text$boundingRect()
                   text$rotate(-this$rot)
                   ## text->translate(-hadj * brect.width(), -0.7 * brect.height());
                   text$setPos(0, at[i])
               }
               axisRect <- Qt$QRectF(0, lims$ylim[1],
                                     brect$width(),
                                     lims$ylim[2] - lims$ylim[1])
               scene$setSceneRect(axisRect)
               this$fitInView(this$sceneRect, Qt$Qt$IgnoreAspectRatio)
           }, "protected")

yaxisscene <- Qt$QGraphicsScene()
yaxisscene$setItemIndexMethod(Qt$QGraphicsScene$NoIndex)
yaxisview <- MyYAxis()
yaxisview$setScene(yaxisscene)


yaxisview




root <- Qt$QWidget()
root$setContentsMargins(0, 0, 0, 0)
rlayout <- Qt$QGridLayout(root)
rlayout$setSpacing(0)
rlayout$setContentsMargins(0, 0, 0, 0)

root

rlayout$addWidget(mainLabel, 0, 0)
rlayout$addWidget(myview, 1, 0)


