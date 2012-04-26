\name{qpager}
\alias{qpager}
\alias{qwebbrowser}
\title{Qt based implementations of pager an browser}
\usage{
qpager(file, header = "", title = "R Information",
       delete.file = FALSE, parent)
qwebbrowser(url, \dots)
}

\description{
  These functions provide Qt-based implementations of a pager (file
  viewer) and web browser.  They can be used as the \R options
  \code{"pager"} and \code{"browser"}.
}

\details{ This function may be set as the \code{"pager"} option. }
\value{A QTextEdit or RCodeEditor instance (see \code{\link{qeditor}}).}
\author{Deepayan Sarkar}
\arguments{
  \item{file}{The file whose content is to be displayed.}
  \item{header}{Ignored.}
  \item{title}{Character string to be used as the widget title if applicable.}
  \item{delete.file}{Logical flag indicating whether the file should
    be deleted after being shown.}
  \item{parent}{An optional QTabWidget instance.  If supplied, the
    editor widget is added as a child.}
  \item{url}{The URL to view.}
  \item{\dots}{Ignored by \code{qwebbrowser}}
}
