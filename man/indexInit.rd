\name{indexInit}
\alias{indexInit}
\alias{indexDone}
\title{ Load / unload rindex library }
\description{
  Function \code{indexInit} loads the rindex shared library, \code{indexDone} unloads the rindex shared library.
}
\usage{
indexInit()
indexDone()
}
\details{
  You are responsible to free all memory using \code{\link{indexDelTree}} before calling \code{indexDone}.
}
\value{
  See \code{\link[base]{dyn.load}} and \code{\link[base]{dyn.unload}}
}
\author{ Jens Oehlschlägel }
\seealso{ \code{\link[base]{dyn.load}}, \code{\link[base]{dyn.unload}}, \code{\link{indexDelTree}} }
\keyword{ misc }
\keyword{ database }
