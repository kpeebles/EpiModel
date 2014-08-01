
# Exported Functions ------------------------------------------------------

#' @title Obtain Transparent Colors
#'
#' @description Returns an RGB transparent color from any standard R color.
#'
#' @param col a vector consisting of colors, of any of the three kinds of
#'        \code{R} color specifications (named, hexadecimal, or integer; see
#'        \code{\link{col2rgb}}).
#' @param alpha a vector of transparency levels, where 0 is transparent and 1
#'        is opaque.
#' @param invisible supresses printing of the RGB color.
#'
#' @details
#' The purpose of this function is to facilitate color transparency, which is
#' used widely in \code{EpiModel} plots. This is an internal function that is
#' not ordinarily called by the end-user. This function allows that one of col
#' or alpha may be of length greater than 1.
#'
#' @return
#' A vector of length equal to the input \code{col} vector or the \code{alpha},
#' vector, if one or the other is of length greater than 1, containing the
#' transformed color values in hexidemical format.
#'
#' @seealso \code{\link{rgb}}, \code{\link{col2rgb}}
#'
#' @export
#' @keywords colorUtils internal
#'
#' @examples
#' ## Example 1: Bubble plot with multiple length color vector
#' n <- 25
#' x <- sort(sample(1:200, n))
#' y <- 10 + 2*x + rnorm(n, 0, 10)
#' z <- rpois(n, 10)
#' cols <- transco(c("steelblue", "black"), 0.5)
#' par(mar=c(2, 2, 1, 1))
#' plot(x, y, cex = z/4, pch = 21, col = "black",
#'      bg = cols[1], lwd = 1.2, axes = FALSE,
#'      ylim = c(0, 500), xlim = c(0, 250),
#'      yaxs = "r", xaxs = "r")
#' axis(2, seq(0, 500, 100), col = "white", las = 2,
#'     cex.axis = 0.9, mgp = c(2, 0.5, 0))
#' axis(1, seq(0, 250, 50), cex.axis = 0.9,
#'      mgp = c(2, 0.5, 0))
#' abline(h = seq(100, 500, 100), col = cols[2])
#'
#' ## Example 2: Network plot with multiple length alpha vector
#' net <- network.initialize(500, directed = FALSE)
#' vcol <- transco("firebrick",
#'                 alpha = seq(0, 1, length = network.size(net)))
#' par(mar = c(0, 0, 0, 0))
#' plot(net, vertex.col = vcol, vertex.border = "grey70",
#'      vertex.cex = 1.5, edge.col = "grey50")
#'
transco <- function(col,
                    alpha = 1,
                    invisible = FALSE
                    ) {

  if (length(alpha) > 1 && length(col) > 1) {
    stop("Length of col or length of alpha must be 1")
  }

  if (alpha > 1 || alpha < 0) {
    stop("Specify alpha between 0 and 1")
  }

  newa <- floor(alpha * 255)
  t1 <- col2rgb(col, alpha = FALSE)
  t2 <- rep(NA, length(col))

  if (length(col) > 1) {
    for (i in seq_along(col)) {
      t2[i] <- rgb(t1[1,i], t1[2,i], t1[3,i], newa, maxColorValue = 255)
    }
  }
  if (length(alpha) > 1) {
    for (i in seq_along(alpha)) {
      t2[i] <- rgb(t1[1,1], t1[2,1], t1[3,1], newa[i], maxColorValue = 255)
    }
  }
  if (length(col) == 1 && length(alpha) == 1) {
    t2 <- rgb(t1[1,1], t1[2,1], t1[3,1], newa, maxColorValue = 255)
  }

  if (invisible == TRUE) {
    invisible(t2)
  } else {
    return(t2)
  }
}


#' @title RColorBrewer Color Ramp for EpiModel Plots
#'
#' @description Returns vector of colors consistent with a high-brightness set
#'              of colors from an \code{RColorBrewer} palette.
#'
#' @param plt \code{RColorBrewer} palette from \code{\link{brewer.pal}}
#' @param n number of colors to return
#' @param delete.lights delete the lightest colors from the color palette,
#'        helps with plotting in many high-contrast palettes
#'
#' @details
#' \code{RColorBrewer} provides easy access to helpful color palettes, but the
#' built-in palettes are limited to the set of colors in the existing palette.
#' This function expands the palette size to any number of colors by filling
#' in the gaps. Also, colors within the "div" and "seq" set of palettes whose
#' colors are very light (close to white) are deleted by default for better
#' visualization of plots.
#'
#' @return
#' A vector of length equal to \code{n} with a range of color values consistent
#' with an RColorBrewer color palette.
#'
#' @seealso \code{\link{RColorBrewer}}
#' @keywords colorUtils internal
#' @export
#'
#' @examples
#' # Shows a 100-color ramp for 4 RColorBrewer palettes
#' par(mfrow = c(2, 2), mar=c(1, 1, 2, 1))
#' pals <- c("Spectral", "Greys", "Blues", "Set1")
#' for (i in seq_along(pals)) {
#'  plot(1:100, 1:100, type = "n", axes = FALSE, main = pals[i])
#'  abline(v = 1:100, lwd = 6, col = brewer_ramp(100, pals[i]))
#' }
#'
brewer_ramp <- function(n, plt, delete.lights = TRUE){

  pltmax <- brewer.pal.info[row.names(brewer.pal.info)==plt, ]$maxcolors
  pltcat <- brewer.pal.info[row.names(brewer.pal.info)==plt, ]$category

  if (pltcat == "div") {
    if (delete.lights == TRUE) {
      colors <- brewer.pal(pltmax, plt)[-c(4:7)]
    } else {
      colors <- brewer.pal(pltmax, plt)
    }
  }
  if (pltcat == "qual") {
    colors <- brewer.pal(pltmax, plt)
  }
  if (pltcat == "seq") {
    if (delete.lights == TRUE) {
      colors <- rev(brewer.pal(pltmax, plt)[-c(1:3)])
    } else {
      colors <- rev(brewer.pal(pltmax, plt))
    }
  }

  pal <- colorRampPalette(colors)

  return(pal(n))
}





# Non-Exported Functions --------------------------------------------------

deleteAttr <- function(attrList, ids) {
  if (length(ids) > 0) {
    attrList <- lapply(attrList, function(x) x[-ids])
  }
  return(attrList)
}

eval_list <- function(x) {

  largs <- as.numeric(which(sapply(x, class) %in% c("call", "name")))
  for (i in largs) {
    x[[i]] <- eval.parent(x[[i]], n = 2)
  }

  return(x)
}


sampledf <- function(df, size, replace=FALSE, prob=NULL, group, status){

  if (!missing(group) && !missing(status))
    elig.ids <- df$ids[df$group %in% group & df$status %in% status]

  if (missing(group) && !missing(status))
    elig.ids <- df$ids[df$status %in% status]

  if (!missing(group) && missing(status))
    elig.ids <- df$ids[df$group %in% group]

  if (missing(group) && missing(status))
    elig.ids <- df$ids

  if (length(elig.ids) > 1) {
    ids <- sample(elig.ids, size, replace, prob)
  } else {
    if (size > 0) {
      ids <- elig.ids
    } else {
      ids <- NULL
    }
  }

  return(ids)
}


split_list <- function(x, exclude) {

  largs <- rep(FALSE, length(x))
  for (i in seq_along(x)) {
    largs[i] <- class(eval.parent(x[[i]], n = 2)) == "list"
  }
  largs <- which(largs)

  if (!missing(exclude)) {
    largs <- largs[-which(names(largs) %in% exclude)]
  }

  largsn <- names(largs)
  if (length(largsn) > 0) {
    for (i in seq_along(largsn)) {
      crlist <- eval.parent(x[[largsn[i]]], n = 2)
      crlistn <- names(crlist)
      for (j in seq_along(crlistn)) {
        x[[crlistn[j]]] <- crlist[[j]]
      }
      x[[largsn[[i]]]] <- NULL
    }
  }

  return(x)
}


ssample <- function(x, size, replace = FALSE, prob = NULL) {

  if (length(x) > 1) {
    return(sample(x, size, replace, prob))
  }

  if (length(x) == 1 && size > 0) {
    return(x)
  }

  if (length(x) == 1 && size == 0) {
    return(NULL)
  }

}