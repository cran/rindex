\name{match}
\alias{match}
\alias{\%in\%}
\title{ High level match function/operator }
\description{
  Match values in index
}
\usage{
match(x, table, nomatch = NA, incomparables = FALSE)
 x \%in\% table
}
\arguments{
  \item{x}{ a set of search values }
  \item{table}{ an object of class \sQuote{index} or a simple vector }
  \item{nomatch}{ the value to return for non-matches (default NA) }
  \item{incomparables}{ not yet used }
}
\details{
  \tabular{rl}{
   \code{\link{match}} \tab redefined version of \code{\link[base]{match}} automatically recognizing index tables \cr
   \code{\link{\%in\%}} \tab redefined version of \code{\link[base:match]{\%in\%}} (redefinition needed for finding redefined \code{\link{match}} in spite of namespaces)  \cr
  }
}
\value{
  Function \code{match} returns a vector of original positions (or the nomatch value NA), function \code{\%in\%} returns a logical vector.
}
\author{ Jens Oehlschlägel }
\seealso{ \code{\link{index}}, \code{\link{indexFind}}, \code{\link{indexMatch}} }
\keyword{ misc }
\keyword{ database }
