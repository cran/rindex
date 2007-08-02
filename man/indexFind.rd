\name{indexFind}
\alias{indexFind}
\alias{indexFindlike}
\alias{rindexFind}
\alias{rindexFindlike}
\title{ Low level search }
\description{
  Find position in index
}
\usage{
  indexFind(obj, val, findlow = TRUE)
  indexFindlike(obj, val, findlow = TRUE)
}
\arguments{
  \item{obj}{ an object of class \sQuote{index} }
  \item{val}{ search value }
  \item{findlow}{ FALSE to find highest instance of value (default false) }
}
\details{
  \tabular{rl}{
   \code{\link{indexFind}} \tab finding exact values in index \cr
   \code{\link{indexFindlike}} \tab finding values in index that begin like search value (character indices only) \cr
  }
}
\value{
  An integer position of lowest or highest instance of search value
}
\author{ Jens Oehlschlägel }
\seealso{ \code{\link{index}}, \code{\link{indexFindInterval}}, \code{\link[base]{grep}} }
\keyword{ misc }
\keyword{ database }
