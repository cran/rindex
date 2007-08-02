\name{indexFindInterval}
\alias{indexFindInterval}
\alias{rindexFindInterval}
\title{ Mid level search: interval }
\description{
  Find index positions in interval of search values
}
\usage{
 indexFindInterval(obj, low = NULL, high = NULL, low.include = TRUE, high.include = TRUE, low.exact = FALSE, high.exact = FALSE, lowFUN = FUN, highFUN = FUN, FUN = indexFind)
}
\arguments{
  \item{obj}{ an object of class \sQuote{index} }
  \item{low}{ low search value }
  \item{high}{ high search value }
  \item{low.include}{ FALSE to not include the lower search value (default TRUE) }
  \item{high.include}{ FALSE to not include the upper search value (default TRUE) }
  \item{low.exact}{ TRUE to require the the low search value is present (default FALSE) }
  \item{high.exact}{ TRUE to require the the upper search value is present (default FALSE) }
  \item{lowFUN}{ low level search function to identify lower index position (default \code{FUN}) }
  \item{highFUN}{ low level search function to identify lower index position (default \code{FUN}) }
  \item{FUN}{ low level search function to identify both index positions (default \code{\link{indexFind}}) }
}
\details{
  \tabular{rl}{
   \code{\link{indexFindInterval}} \tab finding a sequence of exact or approximate values \cr
  }
}
\value{
  An integer sequence of index positions
}
\author{ Jens Oehlschlägel }
\seealso{ \code{\link{index}}, \code{\link{indexFind}}, \code{\link{indexMatch}} }
\keyword{ misc }
\keyword{ database }
