\name{qstr}
\alias{qstr}
\alias{qstr.default}
\alias{qstr.QWidget}
\alias{qstr.data.frame}
\alias{qstr.table}
\alias{qstr.matrix}
\alias{qstr.function}
\alias{qstr.list}
\alias{qstr.environment}
\title{Graphical display of object structure}
\usage{
qstr(x, \dots)
\method{qstr}{matrix}(x, \dots)
\method{qstr}{table}(x, \dots)
\method{qstr}{array}(x, \dots)
\method{qstr}{data.frame}(x, \dots)
}
\arguments{
  \item{x}{An \R object. }
  \item{\dots}{Further arguments.  Passed on as appropriate. }
}
\value{
  A QWidget instance.
}
\description{
  \code{qstr} creates a widget displaying the structure of an arbitrary
  \R object.  The default method simply shows the output of
  \code{print(x)} in a text area.  Table like objects are shown using
  \code{\link{qdataview}}.

  The methods for lists and environments allow recursive examination of
  elements using a QSplitter.
}
\author{
  Deepayan Sarkar
}
