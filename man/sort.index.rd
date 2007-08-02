\name{sort.index}
\alias{[.index}
\alias{[<-.index}
\alias{sort.index}
\alias{order.index}
\alias{is.na.index}
\alias{[.rindex}
\alias{[<-.rindex}
\alias{sort.rindex}
\alias{order.rindex}
\alias{is.na.rindex}
\title{ Index extraction }
\description{
  Functions to extract from an index 1) the original vecor, 2) the sorted vector, 3) the original positions (order) and 4) logical NAiness.
}
\usage{
  \method{[}{index}(x, i, ...)
  \method{sort}{index}(x, decreasing = FALSE, na.last = NA, ...)
  order.index(..., na.last = TRUE, decreasing = FALSE)
  \method{is.na}{index}(x)
}
\arguments{
  \item{x}{ an object of class \sQuote{index} }
  \item{i}{ subset information }
  \item{\dots}{ one object of class \sQuote{index} for \command{order.index}, otherwise not to be used }
  \item{decreasing}{ TRUE to sort decreasing (default FALSE) }
  \item{na.last}{ FALSE to sort NAs first (default TRUE) }
}
\details{
  \tabular{rl}{
   \code{\link{sort.index}} \tab identical to \code{\link[base]{sort}} of original vector, but much faster \cr
   \code{\link{order.index}} \tab identical to \code{\link[base]{order}} of original vector, but much faster \cr
   \code{\link{[.index}} \tab \code{index[]} returns original vector, subsetting works identical to susetting original vector \code{\link[base]{[}} (via \code{\link[base]{Next.Method}}) \cr
   \code{\link{[<-.index}} \tab currently forbidden \cr
   \code{\link{is.na.index}} \tab identical to \code{\link[base]{is.na}} of original vector, but much faster \cr
  }
}
\value{
  Function \command{[.index} returns the original vector (or part of it), \command{sort.index} returns a sorted vector of values, \command{order.index} returns a vector of original integer positions and \command{is.na.index} returns a logical vector.
}
\author{ Jens Oehlschlägel }
\note{
  There are dummy functions \command{names.index}, \command{names<-.index} and \command{[<-.index} that catch non-supported use of these generics on index objects.
 \cr Note that for non-unique indices \code{order.index(...,decreasing=TRUE)} handles ties not identical to \code{order(...,decreasing=TRUE)}.
}
\seealso{ \code{\link{index}}, \code{\link[base]{sort}}, \code{\link[base]{order}}, \code{\link[base]{[}} }
\keyword{ misc }
\keyword{ database }
