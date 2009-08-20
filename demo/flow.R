
setMethod("qstr", "view",
          function(x, ...)
      {
          ostr <- capture.output(print(x, ...))
          ## summary
          wsummary <- qtextEdit()
          wsummary$setCurrentFont(qfont("Arial"))
          wsummary$plainText <- paste(ostr, collapse = "\n")
          wsummary
          ## children
          require(graph)
          tree <- tree(x)
          adjbase <- adj(tree, identifier(x))[[1]]
          if (length(adjbase) > 0)
          {
              xlist <- lapply(adjbase, function(nm) x@env[[nm]])
              ## FIXME: human readable names
              names(xlist) <-
                  sapply(adjbase, function(nm) names(x@env[[nm]]))
              xlist$data <- Data(x)
              wlist <- qstr(xlist)
              ## splitter
              container <- qsplitter(horizontal = FALSE)
              container$opaqueResize <- FALSE
              qaddWidget(container, wsummary)
              qaddWidget(container, wlist)
              container
          }
          else wsummary
      })

setMethod("qstr", "workFlow",
          function(x, ...)
      {
          require(graph)
          tree <- tree(x)
          adjbase <- adj(tree, nodes(tree)[1])[[1]]
          xlist <- lapply(adjbase, function(nm) x[[nm]])
          names(xlist) <- sapply(adjbase, function(nm) names(x[[nm]]))
          x <- xlist
          callNextMethod()
      })

setMethod("qstr", "flowSet",
          function(x, ...)
      {
          qdataview(pData(x))
      })
          




setMethod("tree", "view",
          function(object, ...) 
      {
          tree <- grep("^treeRef", ls(object@env), value = TRUE)
          get(tree, object@env)
      })
          
          


data(GvHD)

wf <- workFlow(GvHD[1:5])

rg <- rectangleGate("FSC-H" = c(200, 800))

add(wf, rg)

rg2 <- rectangleGate("SSC-H" = c(200, 800), filterId = "SSCgate")

add(wf, rg2, "defaultRectangleGate+")
