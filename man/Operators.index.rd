\name{Operators.index}
\alias{==.index}
\alias{!=.index}
\alias{>.index}
\alias{>=.index}
\alias{<.index}
\alias{<=.index}
\alias{==.rindex}
\alias{!=.rindex}
\alias{>.rindex}
\alias{>=.rindex}
\alias{<.rindex}
\alias{<=.rindex}
\title{ High level comparison operator }
\description{
  Compare index against value
}
\usage{
 \method{==}{index}(e1, e2)
 \method{!=}{index}(e1, e2)
 \method{<}{index}(e1, e2)
 \method{<=}{index}(e1, e2)
 \method{>}{index}(e1, e2)
 \method{>=}{index}(e1, e2)
}
\arguments{
  \item{e1}{ an object of class \sQuote{index} }
  \item{e2}{ a scalar comparison value }
}
\details{
  \tabular{rl}{
   \code{\link{==.index}} \tab index EQual value \cr
   \code{\link{!=.index}} \tab index NotEqual value \cr
   \code{\link{<.index}} \tab index LowerThan value \cr
   \code{\link{>.index}} \tab index GreaterThan value \cr
   \code{\link{<=.index}} \tab index LowerEqual value \cr
   \code{\link{>=.index}} \tab index GreaterEqual value \cr
  }
}
\value{
  A vector of logical values
}
\author{ Jens Oehlschlägel }
\seealso{ \code{\link{index}}, \code{\link{indexFindInterval}}, \code{\link{indexEQ}} }
\keyword{ misc }
\keyword{ database }
