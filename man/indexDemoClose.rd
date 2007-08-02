\name{indexDemoClose}
\alias{indexDemoOpen}
\alias{indexDemoClose}
\title{ Demo functions for creating and removing external pointers }
\description{
  Function \code{indexDemoOpen} creates an external pointer pointing to an integer vector of length \option{n}, \code{indexDemoClose} frees the memory linked to the pointer.
}
\usage{
indexDemoOpen(n = 10)
indexDemoClose(extPtr)
}
\arguments{
  \item{extPtr}{ the external pointer returned by \code{indexDemoOpen} }
  \item{n}{ the length of the vector stored in C RAM }
}
\details{
  If the returned pointer is removed finalization happens at the next \code{gc()}, if \code{indexDemoClose} is used on the pointer then finalization happens immediately, if the pointer is then removed, the finalizer is called \emph{again} at the next \code{gc()} (but doesn't finalize again).
}
\value{
  Function \code{indexDemoOpen} returns an external pointer, \code{indexDemoClose} returns the integer vector previously linked by the pointer.
}
\references{ R Development Core Team (2007). Writing R Extensions. }
\author{ Jens Oehlschlägel }
\seealso{ \code{\link{indexInit}}, \code{\link{indexDone}}, \code{\link{indexAddTree}}, \code{\link{indexDelTree}} }
\examples{
ptr <- indexDemoOpen()
rm(ptr)
gc()

ptr <- indexDemoOpen()
indexDemoClose(ptr)
rm(ptr)
gc()
}
\keyword{ misc }
