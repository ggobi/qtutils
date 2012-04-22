\name{modalutils}
\alias{qfile.choose}
\alias{qdir.choose}
\alias{qgetColor}
\alias{qgetDouble}
\alias{qgetInteger}
\alias{qgetText}
\alias{qgetItem}
\title{Various modal dialog utilities}
\usage{

qfile.choose(caption = "", dir = "", filter = "",
             allow.new = FALSE, parent = NULL)

qdir.choose(caption = "", dir = "", parent = NULL)

qgetColor(parent = NULL, title = "", alpha = 1)

qgetDouble(title = "Choose value",
           label = "Enter a numeric value",
           value = 0.0,
           minValue = -.Machine$double.xmax,
           maxValue = .Machine$double.xmax,
           decimals = 3L, parent = NULL)

qgetInteger(title = "Choose value", label = "Enter an integer value", value = 0L,
            minValue = -.Machine$integer.max,
            maxValue = .Machine$integer.max,
            step = 1L, parent = NULL)

qgetText(title = "Choose value", label = "Enter a text string",
         text = "",
         echomode = c("normal", "noecho", "password", "echoonedit"),
         parent = NULL)

qgetItem(title = "Choose value", label = "Choose a list item",
         items = "",
         current = 1L, editable = TRUE,
         parent = NULL)

}

\description{
  These utilities provide simple wrappers for various built-in modal
  dialogs in Qt.  Modal dialogs are used for one-time user input, such
  as getting a file name or choosing an item from a menu.
}

\details{

  \code{qfile.choose} can be used to select a file name.  It is a
  wrapper around either \code{Qt$QFileDialog$getOpenFileName} (if only
  an existing file's name may be selected) or
  \code{Qt$QFileDialog$getSaveFileName}.  The function returns a
  character string giving the absolute path of the selected file, or
  \code{NULL} if the dialog is canceled.

  \code{qdir.choose} is a similar wrapper for
  \code{Qt$QFileDialog$getExistingDirectory} that can be used to select
  a directory name.

  \code{qgetColor} can be used to select a color.  It is a wrapper for
  \code{Qt$QColorDialog$getColor}.  The function returns a character
  string giving the color in \code{"#RRGGBBAA"} hexadecimal format, or
  \code{NA} if the dialog is canceled.

  \code{qgetInteger}, \code{qgetDouble}, and \code{qgetText} can me used
  to obtain a double, integer, or character string respectively.
  \code{qgetItem} can be used to select an item from a list.  They are
  wrappers for the corresponding static functions of
  \code{Qt$QInputDialog}.  The return value on cancellation is the
  initial value for \code{qgetInteger} and \code{qgetDouble},
  \code{NULL} for \code{qgetText}, and the initially selected element
  for \code{qgetItem} (which may be \code{NULL} is \code{current} is out
  of range).

}

\author{Deepayan Sarkar}
\arguments{

  \item{caption, title}{ Character string giving caption or window title. }

  \item{dir}{ Character string giving the initial directory.  The file
    dialog's working directory will be set to \code{dir}.  If \code{dir}
    includes a file name, the file will be selected. }

  \item{parent}{ An optional QWidget, specifying the parent of the
    dialog. }

  \item{filter}{ Character string giving filter for file names.  Only
    files that match the filter are shown. Multiple filters are
    separated with \code{';;'}. For instance:
    \code{"Images (*.png *.xpm *.jpg);;Text files (*.txt);;XML files (*.xml)"}
  }

  \item{allow.new}{ Logical flag, specifying whether a non-existent file
    may be selected. }

  \item{alpha}{ An alpha-transparency factor (between 0 and 1) to be
    applied to the selected color. }

  \item{label}{Character string giving a label for the selection.}
  \item{value, text}{Initial value.}
  \item{minValue}{Minimum value allowed.}
  \item{maxValue}{Maximum value allowed.}
  \item{decimals}{The maximum number of decimals allowed.}
  \item{step}{The increment for \code{qgetInteger}. }
  \item{echomode}{Specifies how the user input should be displayed.
    Partial matching is allowed.}
  \item{items}{Character vector giving list of items to choose from.}
  \item{current}{The initial choice selected.}
  \item{editable}{Logical flag, specifying whether the list of items are
    immutable, or whether a new name may be specified. }

}
