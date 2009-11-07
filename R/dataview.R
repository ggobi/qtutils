

qtableWidget <- function(nrow = NULL, ncol = NULL)
{
    .Deprecated("none")
    .Call(qt_qtableWidget, nrow, ncol)
}

qisSortingEnabled <- function(x)
{
    .Deprecated("none")
    .Call(qt_qisSortingEnabled, x)
}

qsetSortingEnabled <- function(x, status = TRUE)
{
    .Deprecated("none")
    .Call(qt_qsetSortingEnabled, x, as.integer(status))
}

qsetItem <- function(x, row = 1L, col = 1L, s, extend = FALSE)
{
    .Deprecated("none")
    if (inherits(x, "QListWidget"))
        return(.Call(qt_qsetItemListWidget,
                     x, as.integer(row), as.character(s)[1]))
    if (extend)
    {
        cdim <- qsetDim(x)
        if (any(row > cdim[1]) || any(col > cdim[2]))
            qsetDim(x, max(row, cdim[1]), max(col, cdim[2]))
    }
    .Call(qt_qsetItem, x, as.integer(row), as.integer(col), as.character(s))
}


## FIXME: not clear what this actually does.  Setting w = qlineEdit()
## makes the text editable, but that seems to be about it.

qsetCellWidget <- function(x, row = 1L, col = 1L, w)
{
    .Deprecated("none")
    if (is(w, "QWidget"))
        .Call(qt_qsetCellWidget, x, as.integer(row), as.integer(col), w)
    else NULL
}

qresizeColumnsToContents <- function(x, cols = NULL)
{
    .Deprecated("none")
    .Call(qt_qresizeColumnsToContents, x, cols)
}

qresizeRowsToContents <- function(x, rows = NULL)
{
    .Deprecated("none")
    .Call(qt_qresizeRowsToContents, x, rows)
}

qsetHeaderLabels <-
    function(x, colnames = NULL, rownames = NULL,
             extend = FALSE)
{
    .Deprecated("none")
    if (extend)
    {
        cdim <- qsetDim(x)
        if ((length(rownames) > cdim[1]) || (length(colnames) > cdim[2]))
            qsetDim(x,
                    max(length(rownames), cdim[1]),
                    max(length(colnames), cdim[2]))
    }
    .Call(qt_qsetHeaderLabels, x, colnames, rownames)
}

qsetDim <- function(x, nrow = NULL, ncol = NULL)
{
    .Deprecated("none")
    .Call(qt_qsetDim, x, nrow, ncol)
}

qcurrentRow <- function(x)
{
    .Deprecated("none")
    if (inherits(x, "QListWidget"))
        .Call(qt_qcurrentRowListWidget, x)
    else
        .Call(qt_qcurrentRow, x)
}

qcurrentColumn <- function(x)
{
    .Deprecated("none")
    .Call(qt_qcurrentColumn, x)
}





qdataview <- function(x, ...)
{
    UseMethod("qdataview")
}

qdataview.matrix <- qdataview.table <- qdataview.array <-
    function(x, ...)
{
    cdim <- dim(x)
    cdimnames <- dimnames(x)
    if (length(cdim) > 2)
        stop("Arrays of more than two dimensions not supported yet")
    if (length(cdim) == 1)
    {
        cdim <- dim(x) <- c(cdim, 1L)
        ## FIXME: need to change cdimnames?
    }
    ans <- Qt$QTableWidget(cdim[1], cdim[2])
    sx <- as.character(x)
    rowx <- row(x) - 1L
    colx <- col(x) - 1L
    for (i in seq_len(cdim[1] * cdim[2]))
    {
        item <- Qt$QTableWidgetItem(sx[i])
        item$setFlags(33L) ## selectable(1) | can interact(32)
        ans$setItem(rowx[i], colx[i], item)
    }
    if (!is.null(cdimnames))
    {
        if (!is.null(cdimnames[[1]]))
            ans$setVerticalHeaderLabels(cdimnames[[1]])
        if (length(cdimnames) > 1 && !is.null(cdimnames[[2]]))
            ans$setHorizontalHeaderLabels(cdimnames[[2]])
    }
    ans$resize(600, 400)
    ans
}

qdataview.data.frame <- function(x, ...)
{
    qdataview.array(do.call(cbind, lapply(x, as.character)))
}



