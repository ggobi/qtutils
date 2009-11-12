
library(qtbase)

stream <- Qt$QTextStream



tmpf <- tempfile()
cat("x <- rnorm(10)\nsummary(x)\n", file = tmpf)

qfile <- Qt$QFile(tmpf)
status <- qfile$open(Qt$QIODevice$ReadOnly)
status

stream <- Qt$QTextStream(qfile)
edit$setText(stream$readAll())


