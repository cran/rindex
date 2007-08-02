\name{strncmp}
\alias{strcmp}
\alias{strncmp}
\title{ String comparison á la C }
\description{
  Functiions to compare two vectors of strings like the standard C functions do.
}
\usage{
strcmp(a, b)
strncmp(a, b, n)
}
\arguments{
  \item{a}{ character vector }
  \item{b}{ character vector }
  \item{n}{ number of characters to compare }
}
\value{
  1 if a>b, -1 if a<b, 0 if a==b.
}
\author{ Jens Oehlschlägel }
\seealso{ \code{\link[base]{substr}}, \code{\link[base]{Comparison}} }
\keyword{ misc }
