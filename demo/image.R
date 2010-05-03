
library(qtbase)
library(qtutils)

im <- Qt$QImage()
im$load(qfile.choose())

imageLabel <- Qt$QLabel()
imageLabel$setBackgroundRole(Qt$QPalette$Base)
imageLabel$setSizePolicy(Qt$QSizePolicy$Ignored, Qt$QSizePolicy$Ignored)
imageLabel$setScaledContents(TRUE)


imageLabel$setPixmap(Qt$QPixmap$fromImage(im))
imageLabel

## change qimage

im$invertPixels() ## display not updated
imageLabel$setPixmap(Qt$QPixmap$fromImage(im)) ## is now

## modify image

hh <- im$height()
ww <- im$width()

## colors are not easy to figure out

col.picked <- im$pixel(sample(ww, 1)-1L, sample(hh, 1)-1L)
col.picked

## change some random subset to this color

##im$setPixel(20L, 20L, col.picked) ## needs a QRgb argument (unsigned int)

for (i in 1:10000) {
    foo <- sample(hh, 1)-1L
    im$setPixel(sample(ww, 1)-1L, sample(hh, 1)-1L, col.picked)
    im$setPixel(foo, foo, col.picked)
}
imageLabel$setPixmap(Qt$QPixmap$fromImage(im))


## for (i in 1:100) { print(try(qcolor("red")$rgba(), silent = TRUE)) }

## im$setPixel(10L, 10L, qcolor("#001100")$rgb())

## im$setPixel() needs a QRgb argument (unsigned int)
## this don't work because R doesn't have a uint equivalent

## col.rgba <- qcolor("red")$rgb()
## storage.mode(col.rgba) <- "integer"
## str(col.rgba)

## col.rgba <- 147L ## some arbitry integer



## n <- 500L
## yseq <- sample(0:(hh-1L), n, replace = TRUE)
## xseq <- sample(0:(ww-1L), n, replace = TRUE)
## for (i in 1:n)
## {
##     im$setPixel(xseq[i], yseq[i], col.rgba)
## }



