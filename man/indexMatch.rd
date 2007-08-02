\name{indexMatch}
\alias{indexMatch}
\alias{rindexMatch}
\title{ Mid level search: match set }
\description{
  Find (lowest/highest) index positions for set of search values
}
\usage{
 indexMatch(obj, x, findlow = TRUE, what = c("ind", "pos", "val"))
}
\arguments{
  \item{obj}{ an object of class \sQuote{index} }
  \item{x}{ a vector of search values }
  \item{findlow}{ FALSE to take highest instance (default TRUE) }
  \item{what}{ on of \code{c("ind", "pos", "val")} }
}
\details{
  \tabular{rl}{
   \code{\link{indexMatch}} \tab finding positions of vector of search values \cr
  }
}
\value{
  A vector of index positions (ind), original positions (pos) or values (val).
}
\author{ Jens Oehlschlägel }
\note{
  \code{indexMatch} warns if called on a non-unique index. This warning can be suppressed by giving parameter \code{findlow} explicitely.
}
\seealso{ \code{\link{index}}, \code{\link{indexFind}}, \code{\link{indexFindInterval}}, \code{\link{match}} }
\keyword{ misc }
\keyword{ database }
