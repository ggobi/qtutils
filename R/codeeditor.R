require(qtbase)

## Class that subclasses QPlainTextEdit and overrides TAB key

rm(RCodeEditor)

qsetClass("RCodeEditor", Qt$QPlainTextEdit,
          constructor = function(family = "monospace", pointsize = 14, underscore.assign = TRUE) {
              this$setFont(qfont(family = family, pointsize = pointsize))
              this$centerOnScroll <- TRUE
              this$setLineWrapMode(Qt$QTextEdit$NoWrap)
              this$tabMode <- "complete"
              this$uassign <- underscore.assign
          })


findLastUnmatched <- function(s)
{
    ## s is like "(" "[" "]" "(" ")" "{" "(" ")" "{" "}"
    ## want to find last unmatched left-open
    nbrace <- nbracket <- nparen <- 0L
    for (i in rev(seq_along(s)))
    {
        switch(s[i],
               "}" = { nbrace <- nbrace + 1L },
               "]" = { nbracket <- nbracket + 1L },
               ")" = { nparen <- nparen + 1L },
               "{" = { if (nbrace == 0L) return(i) else nbrace <- nbrace - 1L },
               "[" = { if (nbracket == 0L) return(i) else nbracket <- nbracket - 1L },
               "(" = { if (nparen == 0L) return(i) else nparen <- nparen - 1L })
    }
    return (0L)
}


computeTabSpaces <- function(text)
{
    ## want intended number of spaces for last line.
    ## Assume current call goes back to last line with 0 leading spaces
    ll <- strsplit(text, "\n")[[1]]
    countLeadingSpaces <- function(x) # x is already split
    {
        spaces <- (x == " ")
        if (length(spaces))
        {
            nsp <- which(!spaces)
            if (length(nsp))
            {
                nsp[1] - 1L
            }
            else length(spaces) # all spaces
        }
        else 0
    }
    spaces <- sapply(strsplit(ll, ""), countLeadingSpaces)
    goBackTo <- tail(which(spaces == 0), 1)
    if (length(goBackTo))
    {
        useText <- if (goBackTo == 1L) ll else tail(ll, -(goBackTo-1L))
        ## cat(useText, sep = "\n")
        ## now count number of {, }, ), (
        useTextCombined <- paste(useText, collapse = "\n")
        occurencePattern <- function(p)
        {
            p <- gregexpr(p, useTextCombined, fixed = TRUE)[[1]]
            if (all(p == -1)) integer(0)
            else as.numeric(p)
        }
        linebreaks <- occurencePattern("\n")
        pkey <- c("(", ")", "[", "]", "{", "}")
        poccur <- sapply(pkey, occurencePattern, simplify = FALSE)
        ## str(poccur)
        ord <- order(unlist(poccur))
        osorted <- rep(pkey, sapply(poccur, length))[ord]
        ## print(osorted)
        lastUnmatched <- findLastUnmatched(osorted)
        if (lastUnmatched == 0L) return(0) # apparently complete
        ## what is it and where?
        posUnmatched <- unlist(poccur)[ord][lastUnmatched]
        switch(osorted[lastUnmatched],
               "(" = ,
               "[" = {
                   ## indent to that position + 1. To find position, see difference from previous newline
                   if (any(linebreaks < posUnmatched)) 
                   {
                       return(posUnmatched - tail(which(linebreaks < posUnmatched), 1))
                   }
                   else return(posUnmatched) # unmatched bracket in first line
               },
               "{" = {
                   ## indent to indent of line containing that { + 4
                   ## Find line number by counting preceding newlines
                   linenum <- sum(linebreaks < posUnmatched) + 1L
                   return(countLeadingSpaces(strsplit(useText[linenum], "")[[1]]) + 4)
               })
        1
    }
    else # no line starts at beginning 
        0
}

qsetMethod("keyPressEvent", RCodeEditor,
           function(e) {
               et <- e$text()
               ## base::print(et)
               if (et == "\r")
               {
                   spaces <- computeTabSpaces(document()$toPlainText())
                   insertPlainText("\n")
                   insertPlainText(base::paste(rep(" ", spaces), collapse = ""))
               }
               else if (et == "{")
               {
                   ## go back by 4 if this is the first character of line
               }
               else if (et == "\t") 
               {
                   base::print(tabMode)
                   spaces <- computeTabSpaces(document()$toPlainText())
                   base::print(spaces)
                   insertPlainText(base::paste(rep(" ", spaces), collapse = ""))
               }
               else if (uassign && et == "_")
                   insertPlainText(" <- ")
               else super("keyPressEvent", e)
           })


(foo <- RCodeEditor())



