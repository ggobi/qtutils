\name{qexport}
\alias{qexport}
\alias{qexport.QGraphicsScene}
\alias{qexport.QWidget}
\alias{qexport.QGraphicsView}
\title{Export Qt objects}
\usage{
qexport(x, ...)
}
\description{
  Exports a Qt object, usually as a bitmap image.
}
\arguments{
  \item{x}{A Qt object instance.}
  \item{...}{Passed on to methods}
}
\details{
  A generic function that is meant to export a Qt object to an
  external file.  Currently, only export to some image formats is
  supported.  This is used, in particular, to allow exporting the
  contents of a \code{\link{qsceneDevice}} via a context menu item
  for a corresponding view.
}
\author{Deepayan Sarkar}
