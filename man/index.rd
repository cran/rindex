\name{index}
\alias{index}
\alias{c.index}
\alias{indexAddTree}
\alias{indexDelTree}
\alias{indexAutobatch}
\alias{rindex}
\alias{c.rindex}
\alias{rindexAddTree}
\alias{rindexDelTree}
\alias{rindexAutobatch}
\title{ Indexing vectors }
\description{
  Indexing allows to extract small fractions of large vectors very quickly.
}
\usage{
 index(x, uni = NULL, batch = NULL, verbose = FALSE)
 \method{c}{index}(\dots)
 indexAddTree(obj, batch = NULL)
 indexDelTree(obj)
 indexAutobatch(n, batch = 64)
}
\arguments{
  \item{x}{ a vector (currently only character) }
  \item{uni}{ set to TRUE or FALSE to save checking for duplicates (default NULL for checking) }
  \item{batch}{ set to preferred batch size to influence \acronym{RAM} -- speed -- trade-off (default NULL for \command{indexAutobatch}) }
  \item{verbose}{ set to TRUE to report timing of index creation (default FALSE) }
  \item{n}{ number of elements to build a tree on }
  \item{obj}{ an object of class \sQuote{index} }
  \item{\dots}{ objects of class \sQuote{index} }
}
\details{
  \tabular{rl}{
   \strong{Basic functions} \tab \emph{creating, modifying and removing indices} \cr
   index \tab create an index object and build a tree \cr
   c.index \tab concatenate index objects (currently not tuned) \cr
   indexAutobatch \tab calculates the optimal index resolution (size of a leaf) given number of elements and desired batch size (default 64) \cr
   indexAddTree \tab build or rebuild tree (\command{Calloc}) \cr
   indexDelTree \tab remove tree (\command{Free}) \cr
   \code{\link[base]{rm}} \tab removing index object removes tree at next garbage collection \code{\link[base]{gc}} \cr
   \strong{Index information} \tab \emph{information, printing and retrieving all values} \cr
   \code{\link{indexNodes}} \tab returns number of tree nodes \cr
   \code{\link{indexBytes}} \tab returns indes size in bytes \cr
   \code{\link{print.index}} \tab prints index info and optionally tree \cr
   \code{\link{str.index}} \tab removes class and calls NextMethod("str") \cr
   \code{\link{length.index}} \tab identical to \code{\link[base]{length}} of original vector \cr
   \code{\link{names.index}} \tab currently forbidden \cr
   \code{\link{names<-.index}} \tab currently forbidden \cr
   \strong{Basic access} \tab \emph{information, printing and retrieving all values} \cr
   \code{\link{sort.index}} \tab identical to \code{\link[base]{sort}} of original vector, but much faster \cr
   \code{\link{order.index}} \tab identical to \code{\link[base]{order}} of original vector, but much faster \cr
   \code{\link{[.index}} \tab \code{index[]} returns original vector, subsetting works identical to susetting original vector \code{\link[base]{[}} (via \code{\link[base]{NextMethod}}) \cr
   \code{\link{[<-.index}} \tab currently forbidden \cr
   \code{\link{is.na.index}} \tab identical to \code{\link[base]{is.na}} of original vector, but much faster \cr
   \strong{Low level search} \tab \emph{low level search functions return positions in \emph{index order} (sorted)} \cr
   \code{\link{indexFind}} \tab finding exact values in index \cr
   \code{\link{indexFindlike}} \tab finding values in index that begin like search value (character indices only) \cr
   \strong{Mid level search} \tab \emph{mid level search functions return positions in \emph{index order} (sorted)} \cr
   \code{\link{indexFindInterval}} \tab finding a sequence of exact or approximate values \cr
   \code{\link{indexMatch}} \tab finding positions of vector of search values \cr
   \strong{High level search} \tab \emph{high level search functions return positions in \emph{original order} (unsorted)} \cr
   \code{\link{indexEQ}} \tab index EQual value \cr
   \code{\link{indexNE}} \tab index NotEqual value \cr
   \code{\link{indexLT}} \tab index LowerThan value \cr
   \code{\link{indexGT}} \tab index GreaterThan value \cr
   \code{\link{indexLE}} \tab index LowerEqual value \cr
   \code{\link{indexGE}} \tab index GreaterEqual value \cr
   \strong{High level operators} \tab \emph{high level operators return logical vectors in \emph{original order} (unsorted)} \cr
   \code{\link{==.index}} \tab index EQual value \cr
   \code{\link{!=.index}} \tab index NotEqual value \cr
   \code{\link{<.index}} \tab index LowerThan value \cr
   \code{\link{>.index}} \tab index GreaterThan value \cr
   \code{\link{<=.index}} \tab index LowerEqual value \cr
   \code{\link{>=.index}} \tab index GreaterEqual value \cr
   \strong{match and \%in\%} \tab \emph{high level matching and \%in\% behave as expected} \cr
   \code{\link{match}} \tab redefined version of \code{\link[base]{match}} automatically recognizing index tables \cr
   \code{\link{\%in\%}} \tab redefined version of \code{\link[base:match]{\%in\%}} (redefinition needed for finding redefined \code{\link{match}} in spite of namespaces)  \cr
   }
}
\value{
  An object of class \sQuote{index}, i.e. a list with components
  \item{val}{sorted vector of values}
  \item{pos}{integer vector of original positions of sorted values}
  \item{n}{number of values (including NAs)}
  \item{nNA}{number of NAs}
  \item{batch}{resolution of tree}
  \item{uni}{logical flagging the index as unique (TRUE) or non-unique (FALSE)}
  \item{tree}{external pointer to C-tree}
}
\section{Theory}{
  Linear search has \eqn{O(n)} time complexity. By using an index tree, search time can be reduced to \eqn{O(log(n))}. An index that can be used with any R-vector \code{x} of length \code{n} needs to store the original values together with the original positions, i.e.
  \code{list(val=x, pos=order(x))}, thus requires -- strongly simplified -- \eqn{2*n} \acronym{RAM}. If we store this information in a binary tree, each value pair \{val,pos\} is stored in its own node together with two pointers, the memory requirements are -- strongly simplified -- \eqn{4*n} \acronym{RAM}. The b-tree stores more than one value and two pointers in one node and thus minimizes the number of nodes that need to be read (from disk). However, used in \acronym{RAM}, b-trees increase the search time because they impurify logarithmic search across nodes with linear search within nodes. By contrast, the t-tree is optimized for \acronym{RAM}: it stores only two pointers but many sorted values within each node: for branching only min and max values need to be searched, linear search is only required at the final leaf node. However, realizing a  t-tree within R's memory model requires additional overhead for the SEXPREC data structures. We avoid that by defining a static read only tree (and save implementation of insert and delete operations). The b*tree and t*tree versions of the mentioned indices reduce the size of the search nodes by storing the data itself in the leafnodes only. This leads to some redundant storage but speeds up search. Some implementations connect the leafnodes by extra pointers to speed up linear search. If we take this principle to the extreme, we can save these extra pointers and merge all leave nodes into one single big leaf. By doing so we loose the ability to update the index, but we gain a static read-only tree structure that supports very fast linear search as well as logarithmic search.
  \preformatted{
           .
         /   \
       .       .
     /   \   /   \   C-tree
   _________________  R-val
   _________________  R-pos
  }

  We implement this efficiently by storing the sorted values vector together with the order positions as standard R (SEXPREC) objects and add a pure C tree that is built from pointered struct nodes. The leaf nodes do use integer addressing instead of pointers to identify the associated part of the SEXPREC vector (pointers can't be used because the R garbage collector may move the vector). The topnode  is linked into R using an external pointer. The tree itself can be removed explicitely from memory using \code{indexDelTree}. If the index object containing the external pointer is deleted, the tree will be freed from memory at the next garbage collection through its finalization method. If the index object does not contain a valid external pointer to the tree -- e.g. when loading an index object from disk -- the tree will be quickly transparently rebuild or can be build explicitely via \code{indexAddTree}.
}
\section{Benefits}{
  \itemize{
   \item much faster access to small fractions of large vectors (or few rownames of long data.frames)
   \item index allows and handles duplicated values
   \item index allows and handles NAs (unique version of index can still have more than one NA)
   \item index sort order is identical to (implemented via) \code{\link{order}} with \code{na.last=TRUE}.
   \item sorted values and original positions are stored simply as standard R vectors
   \item values in original sequence can be retrieved via \code{[} from the index (original vector not required, thus no duplication of values)
   \item several vector methods give expected results (\code{length}, \code{is.na}, \code{sort}, \code{order}, \code{[}, \code{Comparison operators})
   \item the tree needs minimum \acronym{RAM} due to lean C structs (index is close to 2*n)
   \item the tree resolution can be user-defined (\acronym{RAM} -- speed -- trade-off)
   \item the tree will not consume disk space when the index is saved
   \item the tree is build up transparently when needed the first time (e.g. after loading the index from disk)
   \item the tree is build up very quickly because the main work -- the sorting -- needs not to be repeated
   \item the tree is removed transparently from the garbage collector when the index is deleted
   \item this type of tree should perfectly complement the new disk vectors (packages \pkg{ff} and \pkg{R.huge})
  }
}
\section{Limitations}{
  \itemize{
   \item currently indexing is only available for character vectors (not logical, integer, real, complex)
   \item currently indices cannot be stored as columns of data frames
   \item functions that want to retrieve the index values in original order need to call \code{indexname[]} if the complete vector is needed
   \item building the index is rather slow (as slow as sorting in R is, building the tree is very fast)
   \item like all indices the index will reduce performance if a large fraction of the vector is accessed.
   \item not all methods have been maximally tuned via C-code (e.g. \code{c.index}).
  }
}
\section{Open questions}{
  \itemize{
   \item Will R core officially export C entry points to UTF-8 resistant strcmp (STRCOLL) and strncmp (nothing yet)?
   \item Shall we make order() generic to allow dispatch of order.index like we have already dispatch of sort.index?
   \item Shall we - in R base - modify match and \%in\% to avoid masking them by rindex?
   \item Can we call the evaluator from C in order to make <>=comparisons independent of atomic mode (UTF-8 etc.) or will this kill to much performance?
   \item Can we call the evaluator from C for [-accessing the vector elements in order to generalize the index to ff or R.huge or will this kill to much performance?
  }
}
\note{
 For each \command{FOOindexFOO} related to the \sQuote{index} class a function \command{FOOrindexFOO} exists related to the \sQuote{rindex} class.
 The \sQuote{rindex} class is a pure R-prototype and is kept for regression-testing using \code{\link[regtest]{binregtest}} from package \pkg{regtest}.
 The regression tests are in \code{dontshow} sections in the examples of this help.
 If you run \code{example(index)} the regression tests will (unavoidably) trigger warnings.
}
\author{ Jens Oehlschlägel }
\references{
 Tobin J. Lehman, Michael J. Carey (1986) A Study of Index Structures for Main Memory Database Management Systems. Proceedings of the 12th International Conference on Very Large Data Bases, 294 -- 303.
 \cr   Pfaff, Ben (2004). An Introduction to Binary Search Trees and Balanced Trees, Libavl Binary Search Tree Library. Free Software Foundation, Inc.
}
\seealso{ \code{\link[base]{order}}, \code{\link[base]{sort}} , \code{\link[base]{match}} }
\examples{
  #library(rindex)
  x <- sample(c(rep("c", 5), paste("d", 1:5, sep=""), c(letters[c(1,2,5,6)], NA)))

  cat("\n")
  cat("creating an index from atomic vector\n")
  i <- index(x)
  i
  cat("creating an index by combining indices\n")
  i2 <- c(i,i)
  i2
  cat("if the index (or index$tree) is removed, the C-tree is removed at the next garbage collection\n")
  cat("the index tree can also removed and created explicitely\n")
  i <- indexDelTree(i)
  i
  i <- indexAddTree(i, batch=3)
  print(i, tree=TRUE)
  indexNodes(i)
  indexBytes(i)

  cat("\n")
  cat("extracting the original vector\n")
  i[]
  cat("subsetting works as expected\n")
  i[1:3]
  cat("accessing the sorted data is much faster\n")
  sort(i)[1:3]
  cat("accessing the ordering is also much faster (order.index is not dispatched since order is not yet generic)\n")
  order.index(i)[1:3]

  identical(is.na(i),is.na(x))
  identical(length(i),length(x))

  cat("\n")
  cat("LOW LEVEL SEARCH returns position in SORTED VECTOR\n")
  cat("low level search for position of lowest instance of value in the index\n")
  indexFind(i, "c")
  cat("low level search for position of highest instance of value in the index\n")
  indexFind(i, "c", findlow=FALSE)
  cat("low level search for position of lowest instance beginning like search value\n")
  indexFindlike(i,"d")
  cat("low level search for position of highest instance beginning like search value\n")
  indexFindlike(i,"d",findlow=FALSE)

  cat("\n")
  cat("MID LEVEL SEARCH also returns position in SORTED VECTOR\n")
  cat("mid level search for a set of values\n")
  indexMatch(i,c("c","f"), findlow=TRUE)  # giving parameter findlow= suppresses the warning issued on non-unique indices
  sort(i)[indexMatch(i,c("c","f"), findlow=TRUE)]
  i[indexMatch(i,c("c","f"), findlow=TRUE, what="pos")]
  indexMatch(i,c("c","f"), findlow=TRUE, what="val")
  indexMatch(i,c("c","f"), findlow=TRUE, what="pos")
  indexMatch(i,c("c","f"), findlow=FALSE, what="pos")

  cat("mid level search for interval of values\n")
  indexFindInterval(i,"b","f")
  cat("by default the searched endpoints are included\n")
  sort(i)[indexFindInterval(i,"b","f")]
  cat("but they can be excluded\n")
  sort(i)[indexFindInterval(i,"b","f",high.include=FALSE)]
  cat("by default the searched endpoints need not to be present\n")
  sort(i)[indexFindInterval(i,"a1","e1")]
  cat("but this can be required\n")
  sort(i)[indexFindInterval(i,"a1","e1",low.exact=TRUE)]
  cat("each of the searched endpoints can be defined via indexFindlike\n")
  sort(i)[indexFindInterval(i,"c","d",FUN=indexFindlike)]


  cat("\n")
  cat("HIGH LEVEL SEARCH returns POSITION(s) IN ORIGINAL VECTOR but in SEQUENCE OF INDEX\n")
  indexEQ(i,"d3")
  indexNE(i,"d3")
  indexLT(i,"d3")
  indexLE(i,"d3")
  indexGT(i,"d3")
  indexGE(i,"d3")
  cat("searching for several values returns a list\n")
  indexEQ(i,c("b","c","z",NA))
  indexEQ(i,c("b","c","z",NA), what="val")


  cat("\n")
  cat("HIGH LEVEL OPERATORS returns TRUE/FALSE AT ORIGINAL VECTOR POSITIONS\n")
  i=="d3"
  i!="d3"
  i<"d3"
  i<="d3"
  i>"d3"
  i>="d3"

  cat("HIGH LEVEL match AND \%in\% behave as expected\n")
  match(c("b","c","z",NA), x)
  match(c("b","c","z",NA), i)
  c("b","c","z",NA) \%in\% x
  c("b","c","z",NA) \%in\% i

\dontshow{

  cat("\n")
  cat("creating an rindex from atomic vector\n")
  ri <- rindex(x)
  ri
  cat("creating an rindex by combining indices\n")
  ri2 <- c(ri,ri)
  ri2
  cat("if the rindex (or rindex$tree) is removed, the C-tree is removed at the next garbage collection\n")
  cat("the rindex tree can also removed and created explicitely\n")
  ri <- rindexDelTree(ri)
  ri
  ri <- rindexAddTree(ri, batch=3)
  print(ri, tree=TRUE)
  rindexNodes(ri)
  rindexBytes(ri)

  cat("\n")
  cat("extracting the original vector\n")
  ri[]
  cat("subsetting works as expected\n")
  ri[1:3]
  cat("accessing the sorted data is much faster\n")
  sort(ri)[1:3]
  cat("accessing the ordering is also much faster (order.rindex is not dispatched since order is not yet generic)\n")
  order.rindex(ri)[1:3]

  identical(is.na(ri),is.na(x))
  identical(length(ri),length(x))

  cat("\n")
  cat("LOW LEVEL SEARCH returns position in SORTED VECTOR\n")
  cat("low level search for position of lowest instance of value in the rindex\n")
  rindexFind(ri, "c")
  cat("low level search for position of highest instance of value in the rindex\n")
  rindexFind(ri, "c", findlow=FALSE)
  cat("low level search for position of lowest instance beginning like search value\n")
  rindexFindlike(ri,"d")
  cat("low level search for position of highest instance beginning like search value\n")
  rindexFindlike(ri,"d",findlow=FALSE)

  cat("\n")
  cat("MID LEVEL SEARCH also returns position in SORTED VECTOR\n")
  cat("mid level search for a set of values\n")
  rindexMatch(ri,c("c","f"), findlow=TRUE)  # giving parameter findlow= suppresses the warning issued on non-unique indices
  sort(ri)[rindexMatch(ri,c("c","f"), findlow=TRUE)]
  ri[rindexMatch(ri,c("c","f"), findlow=TRUE, what="pos")]
  rindexMatch(ri,c("c","f"), findlow=TRUE, what="val")
  rindexMatch(ri,c("c","f"), findlow=TRUE, what="pos")
  rindexMatch(ri,c("c","f"), findlow=FALSE, what="pos")

  cat("mid level search for interval of values\n")
  rindexFindInterval(ri,"b","f")
  cat("by default the searched endpoints are included\n")
  sort(ri)[rindexFindInterval(ri,"b","f")]
  cat("but they can be excluded\n")
  sort(ri)[rindexFindInterval(ri,"b","f",high.include=FALSE)]
  cat("by default the searched endpoints need not to be present\n")
  sort(ri)[rindexFindInterval(ri,"a1","e1")]
  cat("but this can be required\n")
  sort(ri)[rindexFindInterval(ri,"a1","e1",low.exact=TRUE)]
  cat("each of the searched endpoints can be defined via rindexFindlike\n")
  sort(ri)[rindexFindInterval(ri,"c","d",FUN=rindexFindlike)]

  cat("\n")
  cat("HIGH LEVEL SEARCH returns POSITION(s) IN ORIGINAL VECTOR but in SEQUENCE OF INDEX\n")
  rindexEQ(ri,"d3")
  rindexNE(ri,"d3")
  rindexLT(ri,"d3")
  rindexLE(ri,"d3")
  rindexGT(ri,"d3")
  rindexGE(ri,"d3")
  cat("searching for several values returns a list\n")
  rindexEQ(ri,c("b","c","z",NA))
  rindexEQ(ri,c("b","c","z",NA), what="val")

  cat("\n")
  cat("HIGH LEVEL OPERATORS returns TRUE/FALSE AT ORIGINAL VECTOR POSITIONS\n")
  ri=="d3"
  ri!="d3"
  ri<"d3"
  ri<="d3"
  ri>"d3"
  ri>="d3"

  cat("HIGH LEVEL match AND  behave as expected\n")
  match(c("b","c","z",NA), x)
  match(c("b","c","z",NA), ri)
  c("b","c","z",NA) \%in\% x
  c("b","c","z",NA) \%in\% ri

}

\dontrun{

   cat("function timefactor helps with timing\n")

   n <-  1000000
   x <- sample(1:n)
   names(x) <- paste("a", x, sep="")
   d <- data.frame(x=as.vector(x), row.names=names(x))

   nsub  <- 100
   i <- sample(1:n, nsub)
   ni <- names(x)[i]

   ind <- index(names(x), verbose=TRUE)
   ind

   # test vectors
   cat("character susetting is by magnitude slower than integer subsettting\n")
   timefactor( x[ni] , x[i] , 10, 10000)
   cat("character susetting is approx as slow as matching\n")
   timefactor( x[ni] , x[match(ni,names(x))] , 10, 10)
   cat("for small fractions of n indexing is much faster\n")
   timefactor( x[ni] , x[indexMatch(ind,ni)] , 10, 100)

   # test dataframes
   cat("character susetting is by magnitude slower than integer subsettting\n")
   timefactor( d[ni,] , d[i,] , 1, 100)
   cat("obvious implementation problem (in R-2.5.1 subsetting is much slower than via matching)\n")
   timefactor( d[ni,] , d[match(ni,rownames(d)),] , 1, 1)
   cat("for small fractions of n indexing is much faster\n")
   timefactor( d[ni,] , d[indexMatch(ind,ni),] , 1, 10)

}

\dontshow{

  #library(rindex)
  x <- c(rep("c", 5), paste("d", 1:5, sep=""), c(letters[c(1,2,5,6)], NA))[
   c(6L, 14L, 12L, 8L, 1L, 11L, 5L, 4L, 10L, 3L, 2L, 15L, 7L, 9L, 13L) ]

  i <- index(x)
  ri <- rindex(x)
  stopifnot(identical(indexNodes(i), rindexNodes(ri)))
  i$tree <- NULL
  ri$tree <- NULL
  stopifnot(identical(unclass(i),unclass(ri)))

  i <- index(x)
  i2 <- c(i,i)
  ri <- rindex(x)
  ri2 <- c(ri,ri)
  stopifnot(identical(indexNodes(i2), rindexNodes(ri2)))
  i2$tree <- NULL
  ri2$tree <- NULL
  stopifnot(identical(unclass(i2),unclass(ri2)))

  stopifnot(identical(length(i),length(x)))
  stopifnot(identical(length(ri),length(x)))
  stopifnot(identical(i[],x))
  stopifnot(identical(ri[],x))
  stopifnot(identical(is.na(i),is.na(x)))
  stopifnot(identical(is.na(ri),is.na(x)))

  success <- TRUE

  success <- success && binregtest(
    sort
  , sort
  , PAR1=list(i)
  , PAR2=list(x)
  , na.last=list(missing, FALSE, TRUE)
  , decreasing=list(missing, FALSE, TRUE)
  , COMP=identical
  , NAME="COMPARE sort BETWEEN index AND original vector"
  )

  success <- success && binregtest(
    sort
  , sort
  , PAR1=list(ri)
  , PAR2=list(x)
  , na.last=list(missing,FALSE, TRUE)
  , decreasing=list(missing,FALSE,TRUE)
  , COMP=identical
  , NAME="COMPARE sort BETWEEN rindex AND original vector"
  )

  success <- success && binregtest(
    order.index
  , order
  , PAR1=list(i)
  , PAR2=list(x)
  , na.last=list(missing,FALSE, TRUE)
  , decreasing=list(missing,FALSE) # ,TRUE
  , COMP=identical
  , NAME="COMPARE order BETWEEN non-unique index AND original vector"
  )

  success <- success && binregtest(
   order.rindex
  , order
  , PAR1=list(ri)
  , PAR2=list(x)
  , na.last=list(missing,FALSE, TRUE)
  , decreasing=list(missing,FALSE) # ,TRUE
  , COMP=identical
  , NAME="COMPARE order BETWEEN non-unique rindex AND original vector"
  )

  success <- success && binregtest(
    order.index
  , order
  , PAR1=list(index(unique(x)))
  , PAR2=list(unique(x))
  , na.last=list(missing,FALSE, TRUE)
  , decreasing=list(missing,FALSE,TRUE)
  , COMP=identical
  , NAME="COMPARE order BETWEEN unique index AND original vector"
  )

  success <- success && binregtest(
    order.rindex
  , order
  , PAR1=list(rindex(unique(x)))
  , PAR2=list(unique(x))
  , na.last=list(missing,FALSE, TRUE)
  , decreasing=list(missing,FALSE,TRUE)
  , COMP=identical
  , NAME="COMPARE order BETWEEN unique rindex AND original vector"
  )

  stopifnot(identical(indexFind(i, "c"),as.integer(c(0,3))))
  stopifnot(identical(rindexFind(ri, "c"),as.integer(c(0,3))))
  stopifnot(identical(indexFind(i, "c", findlow=FALSE),as.integer(c(0,7))))
  stopifnot(identical(rindexFind(ri, "c", findlow=FALSE),as.integer(c(0,7))))

  stopifnot(identical(indexFindlike(i,"d"), as.integer(c(0,8))))
  stopifnot(identical(rindexFindlike(ri,"d"), as.integer(c(0,8))))
  stopifnot(identical(indexFindlike(i,"d",findlow=FALSE), as.integer(c(0,12))))
  stopifnot(identical(rindexFindlike(ri,"d",findlow=FALSE), as.integer(c(0,12))))

  stopifnot(identical(indexMatch(i,c("c","f"), findlow=TRUE), as.integer(c(3,14))))
  stopifnot(identical(sort(i)[indexMatch(i,c("c","f"), findlow=TRUE)], c("c","f")))
  stopifnot(identical(i[indexMatch(i,c("c","f"), findlow=TRUE, what="pos")], c("c","f")))
  stopifnot(identical(indexMatch(i,c("c","f"), findlow=TRUE, what="val"), c("c","f")))
  stopifnot(identical(indexMatch(i,c("c","f"), findlow=TRUE, what="pos"), as.integer(c(5,2))))
  stopifnot(identical(indexMatch(i,c("c","f"), findlow=FALSE, what="pos"), as.integer(c(11,2))))

  success <- success && binregtest(
    indexMatch
  , rindexMatch
  , PAR1=list(i)
  , PAR2=list(ri)
  , x = list(c("c","f"))
  , findlow=list(missing, FALSE, TRUE)
  , what = list(missing, "ind", "pos", "val")
  , COMP=identical
  , NAME="COMPARE indexMatch with rindexMatch"
  )


  stopifnot(identical(indexFindInterval(i,"","z"), 1:14))
  stopifnot(identical(indexFindInterval(i,"","z", low.include=FALSE, high.include=FALSE), 1:14))
  stopifnot(identical(indexFindInterval(i,"","z", low.include=TRUE, high.include=TRUE), 1:14))
  stopifnot(identical(indexFindInterval(i,"","z", low.exact=TRUE), integer()))
  stopifnot(identical(indexFindInterval(i,"","z", high.exact=TRUE), integer()))

  stopifnot(identical(indexFindInterval(i,"b","f"), 2:14))
  stopifnot(identical(indexFindInterval(i,"b","f", low.include=FALSE), 3:14))
  stopifnot(identical(indexFindInterval(i,"b","f", high.include=FALSE), 2:13))
  stopifnot(identical(indexFindInterval(i,"b","f", low.include=TRUE), 2:14))
  stopifnot(identical(indexFindInterval(i,"b","f", high.include=TRUE), 2:14))

  stopifnot(identical(indexFindInterval(i,"a1","e1"), 2:13))
  stopifnot(identical(indexFindInterval(i,"a1","e1", low.include=FALSE, high.include=FALSE), 2:13))
  stopifnot(identical(indexFindInterval(i,"a1","e1", low.include=TRUE, high.include=TRUE), 2:13))
  stopifnot(identical(indexFindInterval(i,"a1","e1", low.exact=TRUE), integer()))
  stopifnot(identical(indexFindInterval(i,"a1","e1", high.exact=TRUE), integer()))

  stopifnot(identical(indexFindInterval(i,"","", FUN=indexFindlike), 1:14))
  stopifnot(identical(indexFindInterval(i,"c","d", FUN=indexFindlike), 3:12))
  stopifnot(identical(indexFindInterval(i,"c","d", FUN=indexFindlike, low.include=FALSE), 8:12))
  stopifnot(identical(indexFindInterval(i,"c","d", FUN=indexFindlike, high.include=FALSE), 3:7))
  stopifnot(identical(indexFindInterval(i,"c","d", FUN=indexFindlike, low.include=FALSE, high.include=FALSE), integer()))
  stopifnot(identical(indexFindInterval(i,"c","d", FUN=indexFindlike, low.exact=TRUE, high.exact=TRUE), 3:12))
  stopifnot(identical(indexFindInterval(i,"c","d", highFUN=indexFindlike), 3:12))
  stopifnot(identical(indexFindInterval(i,"c","d", lowFUN=indexFindlike), 3:7))

  success <- success && binregtest(
    indexFindInterval
  , rindexFindInterval
  , PAR1=list(i)
  , PAR2=list(ri)
  , list("b")
  , list("f")
  , low.include=list(missing, FALSE, TRUE)
  , high.include=list(missing, FALSE, TRUE)
  , low.exact=list(missing, FALSE, TRUE)
  , high.exact=list(missing, FALSE, TRUE)
  , lowFUN=list(missing, function(obj, ...)if (inherits(obj, "index")) indexFind(obj, ...) else rindexFind(obj, ...), function(obj, ...)if (inherits(obj, "index")) indexFindlike(obj, ...) else rindexFindlike(obj, ...))
  , highFUN=list(missing, function(obj, ...)if (inherits(obj, "index")) indexFind(obj, ...) else rindexFind(obj, ...), function(obj, ...)if (inherits(obj, "index")) indexFindlike(obj, ...) else rindexFindlike(obj, ...))
  , COMP=identical
  , NAME="COMPARE indexFindInterval with rindexFindInterval"
  )


  stopifnot(identical(indexEQ(i,"c"),c(5L, 7L, 8L, 10L, 11L)))
  stopifnot(identical(indexNE(i,"c"),c(6L, 3L, 1L, 13L, 4L, 14L, 9L, 15L, 2L)))
  stopifnot(identical(indexLT(i,"c"),c(6L, 3L)))
  stopifnot(identical(indexLE(i,"c"),c(6L, 3L, 5L, 7L, 8L, 10L, 11L)))
  stopifnot(identical(indexGT(i,"c"),c(1L, 13L, 4L, 14L, 9L, 15L, 2L)))
  stopifnot(identical(indexGE(i,"c"),c(5L, 7L, 8L, 10L, 11L, 1L, 13L, 4L, 14L, 9L, 15L, 2L)))
  stopifnot(identical(indexEQ(i,c("b","c","z",NA)), list(3L, c(5L, 7L, 8L, 10L, 11L), integer(0), 12L)))
  stopifnot(identical(indexEQ(i,c("b","c","z",NA), what="val"), list("b", c("c", "c", "c", "c", "c"), character(0), NA_character_)))

  for (j in list(list(indexEQ,rindexEQ), list(indexNE,rindexNE), list(indexLT,rindexLT), list(indexLE,rindexLE), list(indexGT,rindexGT), list(indexGE,rindexGE))){
   success <- success && binregtest(
      j[[1]]
    , j[[2]]
    , PAR1=list(i)
    , PAR2=list(ri)
    , list("c")
    , low.exact=list(missing, FALSE, TRUE)
    , high.exact=list(missing, FALSE, TRUE)
    , lowFUN=list(missing, function(obj, ...)if (inherits(obj, "index")) indexFind(obj, ...) else rindexFind(obj, ...), function(obj, ...)if (inherits(obj, "index")) indexFindlike(obj, ...) else rindexFindlike(obj, ...))
    , highFUN=list(missing, function(obj, ...)if (inherits(obj, "index")) indexFind(obj, ...) else rindexFind(obj, ...), function(obj, ...)if (inherits(obj, "index")) indexFindlike(obj, ...) else rindexFindlike(obj, ...))
    , COMP=identical
    , NAME="COMPARE indexXX with rindexXX"
    )
  }

  stopifnot(identical(i=="c",x=="c"))
  stopifnot(identical(i!="c",x!="c"))
  stopifnot(identical(i<"c",x<"c"))
  stopifnot(identical(i<="c",x<="c"))
  stopifnot(identical(i>"c",x>"c"))
  stopifnot(identical(i>="c",x>="c"))

  stopifnot(identical(ri=="c",x=="c"))
  stopifnot(identical(ri!="c",x!="c"))
  stopifnot(identical(ri<"c",x<"c"))
  stopifnot(identical(ri<="c",x<="c"))
  stopifnot(identical(ri>"c",x>"c"))
  stopifnot(identical(ri>="c",x>="c"))

  stopifnot(identical(match(c("b","c","z",NA), i), match(c("b","c","z",NA), x)))
  stopifnot(identical(match(c("b","c","z",NA), ri), match(c("b","c","z",NA), x)))

  stopifnot(identical(c("b","c","z",NA) \%in\% i, c("b","c","z",NA) \%in\% x))
  stopifnot(identical(c("b","c","z",NA) \%in\% ri, c("b","c","z",NA) \%in\% x))

  stopifnot(success)

  cat("8 warnings 'indexMatch used with non-unique index' are expected\n")

  }

}
\keyword{ misc }
\keyword{ database }
