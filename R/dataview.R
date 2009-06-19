

qtableWidget <- function(nrow = NULL, ncol = NULL)
{
    .Call(qt_qtableWidget, nrow, ncol)
}

qisSortingEnabled <- function(x)
{
    .Call(qt_qisSortingEnabled, x)
}

qsetSortingEnabled <- function(x, status = TRUE)
{
    .Call(qt_qsetSortingEnabled, x, as.integer(status))
}

qsetItem <- function(x, row = 1L, col = 1L, s, extend = FALSE)
{
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
    if (is(w, "QWidget"))
        .Call(qt_qsetCellWidget, x, as.integer(row), as.integer(col), w)
    else NULL
}

qresizeColumnsToContents <- function(x, cols = NULL)
{
    .Call(qt_qresizeColumnsToContents, x, cols)
}

qresizeRowsToContents <- function(x, rows = NULL)
{
    .Call(qt_qresizeRowsToContents, x, rows)
}

qsetHeaderLabels <-
    function(x, colnames = NULL, rownames = NULL,
             extend = FALSE)
{
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
    .Call(qt_qsetDim, x, nrow, ncol)
}

qcurrentRow <- function(x)
{
    if (inherits(x, "QListWidget"))
        .Call(qt_qcurrentRowListWidget, x)
    else
        .Call(qt_qcurrentRow, x)
}

qcurrentColumn <- function(x)
{
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
    if (length(cdim) == 2)
    {
        ans <- qtableWidget(cdim[1], cdim[2])
        qsetItem(ans,
                 row = seq_len(cdim[1]),
                 col = seq_len(cdim[2]),
                 as.character(x))
    }
    else if (length(cdim) == 1)
    {
        ans <- qtableWidget(cdim[1], 1L)
        qsetItem(ans,
                 row = seq_len(cdim[1]),
                 col = 1L,
                 as.character(x))        
    }
    if (!is.null(cdimnames))
    {
        if (!is.null(cdimnames[[1]]))
            qsetHeaderLabels(ans, rownames = cdimnames[[1]])
        if (length(cdimnames) > 1 && !is.null(cdimnames[[2]]))
            qsetHeaderLabels(ans, colnames = cdimnames[[2]])
    }
    ans
}

qdataview.data.frame <- function(x, ...)
{
    qdataview.array(do.call(cbind, lapply(x, as.character)))
}



