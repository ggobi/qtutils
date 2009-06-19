
qlistWidget <- function(labels)
{
    .Call(qt_qlistWidget, as.character(labels))
}

qitem <- function(x, row = qcurrentRow(x))
{
    .Call(qt_qitem, x, row)
}

qaddItem <- function(x, labels)
{
    .Call(qt_qaddItem, x, as.character(labels))
}

qsetItemToolTip <- function(x, row, label)
{
    .Call(qt_qsetItemToolTip, x, as.integer(row), as.character(label)[1])
}



### see dataview.R
## qcurrentRow <- function(x) 
## {
##     .Call(qt_qcurrentRow, x)
## }

