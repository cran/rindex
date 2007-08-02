\name{indexEQ}
\alias{indexEQ}
\alias{indexNE}
\alias{indexLT}
\alias{indexLE}
\alias{indexGT}
\alias{indexGE}
\alias{rindexEQ}
\alias{rindexNE}
\alias{rindexLT}
\alias{rindexLE}
\alias{rindexGT}
\alias{rindexGE}
\title{ High level comparison function }
\description{
  Compare index against value
}
\usage{
indexEQ(obj, x, what = c("pos", "val", "ind"), ...)
indexNE(obj, x, what = c("pos", "val", "ind"), ...)
indexLT(obj, x, what = c("pos", "val", "ind"), ...)
indexLE(obj, x, what = c("pos", "val", "ind"), ...)
indexGT(obj, x, what = c("pos", "val", "ind"), ...)
indexGE(obj, x, what = c("pos", "val", "ind"), ...)
}
\arguments{
  \item{obj}{ an object of class \sQuote{index} }
  \item{x}{ a scalar comparison value }
  \item{what}{ on of \code{c("ind", "pos", "val")} }
  \item{\dots}{ further arguments passed to \code{\link{indexFindInterval}} }
}
\details{
  \tabular{rl}{
   \code{\link{indexEQ}} \tab index EQual value \cr
   \code{\link{indexNE}} \tab index NotEqual value \cr
   \code{\link{indexLT}} \tab index LowerThan value \cr
   \code{\link{indexGT}} \tab index GreaterThan value \cr
   \code{\link{indexLE}} \tab index LowerEqual value \cr
   \code{\link{indexGE}} \tab index GreaterEqual value \cr
  }
}
\value{
  A vector of original positions (pos), index positions (ind) or values (val).
}
\author{ Jens Oehlschlägel }
\seealso{ \code{\link{index}}, \code{\link{indexFindInterval}}, \code{\link{==.index}} }
\keyword{ misc }
\keyword{ database }
