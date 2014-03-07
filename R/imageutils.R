
qimage2matrix <- function(x, gray = !alpha, alpha = FALSE)
{
    if (gray && alpha)
    {
        stop("Alpha channel extraction not supported with 'gray=TRUE'")
    }
    if (gray)
        .Call("qt_qimage2matrix_gray", x)
    else
        .Call("qt_qimage2matrix_rgb", x, alpha)
}

matrix2qimage <-
    function(x = NULL, colors,
             red = NULL, green = NULL, blue = NULL, alpha = NULL)
{
    rgb <- !is.null(red) && !is.null(green) && !is.null(blue)
    xdim <- if (rgb) dim(red) else dim(colors)
    if (rgb)
    {
        if (!identical(dim(green), xdim)) stop("Dimension mismatch")
        if (!identical(dim(blue), xdim)) stop("Dimension mismatch")
        if (!is.null(alpha) && !identical(dim(alpha), xdim)) stop("Dimension mismatch")
    }
    ## x: if NULL, create QImage of suitable size. Else check
    ## dimensions.
    if (is.null(x))
    {
        x <- Qt$QImage(xdim[1], xdim[2],
                       if (is.null(alpha)) Qt$QImage$Format_RGB32
                       else Qt$QImage$Format_ARGB32)
    }
    ## FIXME: else check if existing format is compatible with desired (gray/alpha)
    if (rgb)
    {
        .Call("qt_matrix2qimage_rgb", x, red, green, blue, alpha)
    }
    else 
    {
        .Call("qt_matrix2qimage_gray", x, colors)
    }
    x
}
