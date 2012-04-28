\name{qsceneDevice}
\alias{qsceneDevice}
\alias{QT}
\title{Graphics device based on Qt's Graphics View framework}
\usage{
qsceneDevice(width = 10, height = 10, pointsize = 12, family = "")
QT(rscene, \dots, antialias = TRUE, opengl = FALSE)
}
\description{ Starts a QGraphicsScene graphics device. }
\details{

  \code{qsceneDevice} starts a graphics device that is based on Qt's
  Graphics View framework.  In the abstract sense, the device is a
  \sQuote{graphics scene}, which contains various graphical items
  such as circles, lines, and text.  The scene itself is not tied to
  a particular on-screen view or output file.  Further steps must be
  taken to view the contents of the scene, or render it to a file in
  a suitable format.

  \code{QT} is convenient user-level wrapper for the \code{qsceneDevice}
  device.  It returns a QGraphicsView instance (which is also a QWidget
  instance) whose scene is set to the QGraphicsScene instance created by
  a call to \code{qsceneDevice(\dots)}.  In addition, several predefined
  actions are associated with the view, allowing (through a context menu
  and keyboard shortcuts) zooming, printing, and exporting as a bitmap
  image.  The device also supports basic interaction, namely, confirming
  new pages by pressing Enter and locator functionality.

}

\value{

  \code{qsceneDevice} returns a QGraphicsScene instance.  Drawing
  operations will result in QGraphicsItems being added to the scene.
  Note that unlike common R graphics devices, the return value is
  nontrivial.

  \code{QT} returns a QGraphicsView instance.
}

\note{

  There are several limitations in the current implementation, and it
  should not be considered stable.  Reports of problematic behaviour
  (and of course suggested fixes) are welcome.

  In particular, plotmath has trouble with character placement, although
  the characters themselves are mostly correct.

}

\author{Deepayan Sarkar}
\arguments{
  \item{width}{Width of the scene in inches, assuming 72 pixels per inch.}
  \item{height}{Height of the scene in inches, assuming 72 pixels per inch.}
  \item{pointsize}{Default pointsize.}
  \item{family}{Default font family.}
  \item{rscene}{
    A QGraphicsScene instance produced by a call to
    \code{\link{qsceneDevice}}.  Can be missing, in which case a
    suitable instance will be created (see \code{\dots} below).
  }
  \item{\dots}{
    Arguments passed on to \code{\link{qsceneDevice}} if
    \code{rscene} is missing.
  }
  \item{antialias}{
    Logical flag.  Specifies whether the view should
    be antialiased.
  }
  \item{opengl}{
    Logical flag.  Specifies whether the view should be
    a QGLWidget, used for rendering OpenGL graphics.
  }
}
