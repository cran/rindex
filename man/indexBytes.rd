\name{indexBytes}
\alias{names.index}
\alias{names<-.index}
\alias{print.index}
\alias{str.index}
\alias{length.index}
\alias{indexNodes}
\alias{indexBytes}
\alias{names.rindex}
\alias{names<-.rindex}
\alias{print.rindex}
\alias{str.rindex}
\alias{length.rindex}
\alias{rindexNodes}
\alias{rindexBytes}
\title{ Index information }
\description{
  Some functions giving information about indices
}
\usage{
indexNodes(obj)
indexBytes(obj)
\method{print}{index}(x, tree = FALSE, ...)
\method{str}{index}(object, ...)
\method{length}{index}(x)
}
\arguments{
  \item{x}{ an object of class \sQuote{index} }
  \item{obj}{ an object of class \sQuote{index} }
  \item{object}{ an object of class \sQuote{index} }
  \item{tree}{ TRUE to print the tree (default FALSE) }
  \item{\dots}{ ignored or passed }
}
\details{
  \tabular{rl}{
   \code{\link{indexNodes}} \tab returns number of tree nodes \cr
   \code{\link{indexBytes}} \tab returns indes size in bytes \cr
   \code{\link{print.index}} \tab prints index info and optionally tree \cr
   \code{\link{str.index}} \tab removes class and calls NextMethod("str") \cr
   \code{\link{length.index}} \tab identical to \code{\link[base]{length}} of original vector \cr
   \code{\link{names.index}} \tab currently forbidden \cr
   \code{\link{names<-.index}} \tab currently forbidden \cr
  }
}
\value{
  Functions \command{indexNodes}, \command{indexBytes} and \command{length.index} return an integer (number of nodes, number of bytes, length of vector).
}
\author{ Jens Oehlschlägel }
\note{
  There are dummy functions \command{names.index}, \command{names<-.index} and \command{[<-.index} that catch non-supported use of these generics on index objects.
}
\seealso{ \code{\link{index}}, \code{\link[base]{length}}, \code{\link[utils]{object.size}} }
\keyword{ misc }
\keyword{ database }
