\name{qeditor}
\alias{qeditor}
\title{An editor widget.}
\usage{
qeditor(file, readonly = FALSE, richtext = FALSE, ..., rsyntax)
}
\description{An editor widget.}
\details{
  This function creates an editor widget, optionally initializing it
  with the contents of a file.
}
\value{
  If \code{richtext=TRUE}, a QTextEdit instance.  Otherwise
  a \code{\link{RCodeEditor}} instance.
}
\author{Deepayan Sarkar}
\arguments{
  \item{file}{
    Character string giving the name of the file to be
    displayed.
  }
  \item{readonly}{Logical flag indicating whether the editor should
    be in read-only initially.}
  \item{richtext}{Logical flag indicating whether the editor should
    be cabaple of displaying rich-text (HTML).}
  \item{...}{Further arguments, passed on to
    \code{\link{RCodeEditor}} if relevant.}
  \item{rsyntax}{Logical flag indicating whether R syntax
    highlighting should be applied to the contents of the editor.}

}
