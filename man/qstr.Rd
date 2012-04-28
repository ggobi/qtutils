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
\alias{qbrowser}
\alias{qrecover}
\title{Graphical display of object structure}
\usage{
qstr(x, \dots)
\method{qstr}{default}(x, \dots)
\method{qstr}{QWidget}(x, \dots)
\method{qstr}{data.frame}(x, \dots)
\method{qstr}{matrix}(x, \dots)
\method{qstr}{function}(x, \dots)
\method{qstr}{list}(x, \dots)
\method{qstr}{environment}(x, \dots)

qbrowser(namespaces = FALSE)

qrecover()

}
\arguments{
  \item{x}{An \R object. }
  \item{\dots}{Further arguments.  Passed on as appropriate. }
  \item{namespaces}{Logical flag indicating  whether loaded but
    unattached namespaces should be included. }
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
  elements using a QSplitter.  The method for environments allows a
  simple REPL to be started with the correspoding environment as its
  evaluation environment.

  \code{qbrowser} leverages the list method to provide a simple object
  browser.  \code{qrecover} similarly provides a graphical replacement
  for \code{\link{recover}}, and may be used as the \code{"error"}
  option for interactive debugging.

}
\author{
  Deepayan Sarkar
}
