\name{qrepl}
\alias{qreplu}
\alias{qrepl}
\title{A Qt based REPL emulator}
\usage{
qrepl(env = .GlobalEnv, \dots,
      family = "monospace", pointsize = 12,
      incolor = "red", outcolor = "blue", msgcolor = "black",
      html.preferred = FALSE, history = TRUE,
      title)

qreplu(env = .GlobalEnv,
       \dots,
       history = TRUE,
       eval.on.newline = TRUE,
       incolor = "red",
       outcolor = "blue",
       msgcolor = "black")
}

\description{Creates a Qt Widget that emulates the R REPL.}

\details{

  This widget tries to emulate the behaviour of the R command-line
  interface (Read-Eval-Print-Loop) in a GUI.  The current implementation
  is essentially a proof-of-concept, and not meant for serious use.

  Two versions are available.  \code{qreplu} emulates the conventional
  REPL interface where commands are typed at a command prompt and
  evaluated when Enter is pressed (except that parse errors are trapped
  and not evaluated).  \code{qrepl} provides an alternative interface
  with two command specification modes and a common output area.
  Commands can be entered either in input mode, where one or more
  commands may be typed and then executed using Ctrl+Enter, or in edit
  mode, where commands are typed in a file, and selections may be
  executed similarly.  The latter mode is intended to facilitate the
  recommended method of working in ESS, where commands are entered and
  modified within an editor, and executed as necessary.  When working in
  edit mode, commands executed are automatically added to the editor
  area, keeping a record of those commands.

  All code editing interfaces support command completion and code
  indentation (but the rules are not yet customizable).
}

\value{A QWidget instance.}
\author{Deepayan Sarkar}
\arguments{
  \item{env}{The evaluation environment for the REPL.}
  \item{\dots}{Further arguments, passed on to \code{\link{RCodeEditor}}.}
  \item{family}{Font family to be used.}
  \item{pointsize}{Font pointsize to be used.}
  \item{incolor}{The color used for code that is evaluated.}
  \item{outcolor}{The color used for output.}
  \item{msgcolor}{The color used for messages.}
  \item{html.preferred}{Logical flag indicating whether HTML output is preferred (for table-like objects).}
  \item{history}{Logical flag indicating whether command history should
    be available.  If enabled, pressing Ctrl+Up or Down arrows allow
    navigation through previous commands.  History is currently not
    retained across invocations.}
  \item{title}{Character string giving window title.}
  \item{eval.on.newline}{Logical flag indicating whether execution
    should be attempted whenever Enter is pressed.  Otherwise execution
    must be explicitly triggered, e.g., by pressing the Ctrl+Enter
    shortcut. }
}
