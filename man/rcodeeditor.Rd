\name{RCodeEditor}
\alias{RCodeEditor}
\title{A widget for editing R code}
\usage{

# constructor
RCodeEditor(family = "monospace", pointsize = 14,
            underscore.assign = FALSE, comp.tooltip = TRUE)

}

\description{
  \code{RCodeEditor} subclasses \code{Qt$QPlainTextEdit} to provide
  additional functionality suitable for a R code editor, namely, code
  indentation and command completion (both using TAB, with indentation
  preferred, and completion if already indented).  The details of
  indentation are not yet customizable. 
}

\value{An RCodeEditor instance.}
\author{Deepayan Sarkar}
\arguments{
  \item{family}{Font family to be used.}
  \item{pointsize}{Font pointsize to be used.}
  \item{underscore.assign}{Logical flag, indicating whether pressing the
    underscore key adds the assignment operator \code{<-} instead of an
    underscore.
  }
  \item{comp.tooltip}{Logical flag, indicating whether multiple
    completions should be indicated by a tooltip.  Otherwise, a signal
    \code{completionsAvailable(QString character)} is emitted with
    a single argument containing the possible completions.
  }
}
