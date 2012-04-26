\name{miscutils}
\alias{data.browse}
\alias{qdataview}
\alias{qdataview.matrix}
\alias{qdataview.table}
\alias{qdataview.array}
\alias{qdataview.data.frame}
\title{Miscellaneous utilities}
\usage{
data.browse(all = TRUE)
qdataview(x, \dots)
\method{qdataview}{matrix}(x, \dots)
\method{qdataview}{table}(x, \dots)
\method{qdataview}{array}(x, \dots)
\method{qdataview}{data.frame}(x, \dots)
}
\arguments{
  \item{all}{Logical indicating whether datasets from
    unattached packages should also be shown.
  }
  \item{x}{An \R object, typically table-like. }
  \item{\dots}{Further arguments.  Passed on to
    \code{\link{qdataFrameModel}} by the \sQuote{data.frame} method,
    ignored for others.
  }
}
\value{
  A QWidget instance.
}
\description{
  \code{data.browse} creates a widget displaying available datasets as a
  table.

  \code{qdataview} produces a similar table widget for various
  table-like objects.
}
\author{
  Deepayan Sarkar
}
