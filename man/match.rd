\name{match}
\alias{match.index}
\alias{match.rindex}
\title{ High level match function/operator }
\description{
  Match values in index
}
\usage{
match.index(x, table, nomatch = NA)
match.rindex(x, table, nomatch = NA)
}
\arguments{
  \item{x}{ a set of search values }
  \item{table}{ an object of class \sQuote{index} or a simple vector }
  \item{nomatch}{ the value to return for non-matches (default NA) }
}
\value{
  Functions \code{match.index} and \code{match.rindex} return a vector of original positions (or the nomatch value NA).
}
\author{ Jens Oehlschlägel }
\seealso{ \code{\link{index}}, \code{\link{indexFind}}, \code{\link{indexMatch}}, \code{\link{match}}  }
\keyword{ misc }
\keyword{ database }
