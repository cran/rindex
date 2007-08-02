/*
 *  R : A Computer Language for Statistical Data Analysis
 *  Copyright (C) 1995, 1996  Robert Gentleman and Ross Ihaka
 *  Copyright (C) 1998-2006   The R Development Core Team.
 *  Copyright (C) 2004        The R Foundation
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street Fifth Floor, Boston, MA 02110-1301  USA
 */

/* <UTF8> char here is handled as a whole string.
   Does rely on strcoll being correct.
 */


#include <R.h>
#include <Rinternals.h>
//#include <Rdefines.h>
#include <Rmath.h>  /* for M_LN2 ftrunc fmax2 imax2 R_pow R_pow_di */


/* --------------------------------------------------------------------------------------------
 { This code heavily borrows from sort.c including use of some internal interfaces, notably STRCOLL */

#if defined(Win32) && defined(SUPPORT_UTF8)
#define STRCOLL Rstrcoll
#else

#define HAVE_STRCOLL 1

#ifdef HAVE_STRCOLL
#define STRCOLL strcoll
#else
#define STRCOLL strcmp
#endif

#endif

      /*--- Part I: Comparison Utilities ---*/
/* NAs have been handled before */
static int rindex_strcmp(SEXP x, SEXP y)
{
    return STRCOLL(translateChar(x), translateChar(y));
}
/* currently not needed
static int rindex_strncmp(SEXP x, SEXP y, int n)
{
    return strncmp(translateChar(x), translateChar(y), n);
}
*/
static int rindex_strlike(SEXP x, char *y, int n)
{
    return strncmp(translateChar(x), y, n);
}

/* This code heavily borrows from sort.c including use of some internal interfaces, notably STRCOLL }
   -------------------------------------------------------------------------------------------- */


/* --------------------------------------------------------------------------------------------
 { begin node definitions */

/* this is needed to find out whether the topnode is Treeleaf or Treenode */
typedef struct treeroot {
  int           nNodes;  /* if 1 topnode is Treeleaf, if >1 topnode is Treenode */
  void        *topnode;
} Treeroot, *pTreeroot;

typedef struct treenode {
  int   mid;
  void *low;
  void *high;
  int  lowhightype;  /* mark whether low(1) and/or high(2) are Treeleaf */
} Treenode, *pTreenode;

typedef struct treeleaf {
  int  low;
  int  high;
} Treeleaf, *pTreeleaf;


/* end node definitions }
   -------------------------------------------------------------------------------- */



/* --------------------------------------------------------------------------------------------
 { helper functions for getting and setting list elements by name */

SEXP getListElement(SEXP list, char *str)
{
  SEXP elmt = R_NilValue, names = getAttrib(list, R_NamesSymbol);
  int i;
  for (i = 0; i < length(list); i++)
    if(strcmp(CHAR(STRING_ELT(names, i)), str) == 0) {
      elmt = VECTOR_ELT(list, i);
      break;
    }
  return elmt;
}
void setListElement(SEXP list, char *str, SEXP elmt)
{
  SEXP names = getAttrib(list, R_NamesSymbol);
  int i;
  for (i = 0; i < length(list); i++)
    if(strcmp(CHAR(STRING_ELT(names, i)), str) == 0) {
      elmt = SET_VECTOR_ELT(list, i, elmt);
      break;
    }
  return;
}

/* helper functions for getting and setting list elements by name }
   -------------------------------------------------------------------------------- */


/* --------------------------------------------------------------------------------------------
 { begin tree functions */


/* calculating optimal batch size */
int rindex_indexAutobatch(int n, int batch){
  return( imax2(3, ceil(((double)n)/R_pow_di(2,imax2(ceil((log((double)n)-log((double)batch))/M_LN2), 0))))  );
}
/* just for testing: OK */
SEXP Srindex_indexAutobatch(SEXP n_, SEXP batch_){
  int n=INTEGER(n_)[0], batch=INTEGER(batch_)[0];
  SEXP z;
  PROTECT(z = allocVector(INTSXP, 1));
  INTEGER(z)[0] = rindex_indexAutobatch(n,batch);
  UNPROTECT(1);
  return(z);
}



/* must only be called for Treenode, not for Treeleaf */
void rindex_recfree(int *pnNodes, Treenode *pnode){
  //Rprintf("low=%d mid=%d high=%d type=%d\n", pnode->low, pnode->mid, pnode->high, pnode->lowhightype);
  if (pnode->lowhightype & 1){
    //Rprintf("Free low subnode\n");
    Free(pnode->low);
    (*pnNodes)--;
  }else{
    //Rprintf("Go low subnode\n");
    rindex_recfree(pnNodes, pnode->low);
  }
  if (pnode->lowhightype & 2){
    //Rprintf("Free high subnode\n");
    Free(pnode->high);
    (*pnNodes)--;
  }else{
    //Rprintf("Go high subnode\n");
    rindex_recfree(pnNodes, pnode->high);
  }
  //Rprintf("Free inner node\n");
  Free(pnode);
  (*pnNodes)--;
  return;
}

static void rindex_FinalizeTree(SEXP extPtr){
  Treeroot *tree = R_ExternalPtrAddr(extPtr);
  int nNodes=0;
  if(tree){
    if (tree->nNodes){
       if (tree->nNodes==1){
         // topnode is a leaf
         Free(tree->topnode);
         tree->nNodes--;
       }else{
         // topnode is a node
         rindex_recfree(&(tree->nNodes), tree->topnode);
       }
    }
    nNodes=tree->nNodes;
    Free(tree);

    if (nNodes==0){
      Rprintf("finalized tree\n");
    }else{
      error("nNodes!=0 after rindex_recfree (%d)", nNodes);
    }

  }else{
    /* make sure the finalizer does nothing in case it is called with a nil pointer
       because it might get called twice
    */
    Rprintf("no tree to finalize\n");
  }
  return;
}


void *rindex_recuni(int *pnNodes, int *plowhightype, int batch, int low, int high){
  void *ret=R_NilValue; /* -Wall */
  int mid, lowtype,hightype;
  if ((high-low+1)>batch){
    mid = (high+low)/2;
    //Rprintf("rindex_recuni creates node: low=%d  mid=%d  high=%d\n", low, mid, high);
    Treenode *pnode;
    pnode = Calloc(sizeof(Treenode), Treenode);
    pnode->mid  = mid;
    pnode->low  = rindex_recuni(pnNodes, &lowtype, batch, low, mid);
    pnode->high = rindex_recuni(pnNodes, &hightype, batch, mid+1, high);
    (*pnNodes)++;
    pnode->lowhightype = lowtype + 2*hightype;
    (*plowhightype)=0;
    ret = pnode;
  }else{
    //Rprintf("rindex_recuni creates leaf: low=%d  high=%d\n", low, high);
    Treeleaf *pleaf;
    pleaf = Calloc(sizeof(Treeleaf), Treeleaf);
    pleaf->low  = low;
    pleaf->high = high;
    (*pnNodes)++;
    (*plowhightype)=1;
    ret = pleaf;
  }
  return(ret);
}


void *rindex_rectie(int *pnNodes, int *plowhightype, int batch, int low, int high, int flexbatch, SEXP val){
  int mid, lowtype,hightype;
  //Rprintf("rindex_rectie low=%d  high=%d  batch=%d  flexbatch=%d\n", low, high, batch, flexbatch);
  if ((high-low+1)>flexbatch){
    mid = (high+low)/2;
    /* make sure that all equal values end up in the same leave
       thus, may need to adjust mid for ties and maybe skip splitting (if everything equal)
    */
    SEXP midval=STRING_ELT(val,mid);
    //Rprintf(CHAR(midval));
    //Rprintf("\n");

    Rboolean goon=TRUE;
    int midlow=mid;
    int midhigh=mid;
    int takewhich=0;

    while(goon){
      if (midhigh<high){
        midhigh = midhigh + 1;
        if (rindex_strcmp(STRING_ELT(val,midhigh),midval)!=0){
          takewhich = +1;
          break;
        }
      }else{
        goon = FALSE;
      }
      if (midlow>low){
        midlow = midlow - 1;
        if (rindex_strcmp(STRING_ELT(val,midlow),midval)!=0){
          takewhich = -1;
          break;
        }
      }else{
        goon = FALSE;
      }
    }


    if (takewhich>0){
      Treenode *pnode;
      pnode = Calloc(sizeof(Treenode), Treenode);
      if (midhigh==mid+1){  /* the default if no ties are present */
        //Rprintf("rindex_rectie creates node (takewhich>0 no ties): low=%d  mid=%d  high=%d\n", low, mid, high);
        pnode->mid  = mid;
        pnode->low  = rindex_rectie(pnNodes, &lowtype, batch, low    , midhigh-1, batch, val);
        pnode->high = rindex_rectie(pnNodes, &hightype, batch, midhigh, high     , batch, val);
      }else{
        //Rprintf("rindex_rectie creates node (takewhich>0 with ties): low=%d  mid=%d  high=%d\n", low, mid, high);
        pnode->mid  = mid;
        pnode->low  = rindex_rectie(pnNodes, &lowtype, batch, low    , midhigh-1, rindex_indexAutobatch(midhigh-low   , batch), val);  /* taking original batch here assures that batch does not recursively shrink */
        pnode->high = rindex_rectie(pnNodes, &hightype, batch, midhigh, high     , rindex_indexAutobatch(high-midhigh+1, batch), val);  /* taking original batch here assures that batch does not recursively shrink */
      }
      (*plowhightype)=0;
      (*pnNodes)++;
      pnode->lowhightype = lowtype + 2*hightype;
      return(pnode);
    }else if (takewhich<0){
      Treenode *pnode;
      pnode = Calloc(sizeof(Treenode), Treenode);
      //Rprintf("rindex_rectie creates node (takewhich<0 ): low=%d  mid=%d  high=%d\n", low, midlow, high);
      pnode->mid  = midlow;
      pnode->low  = rindex_rectie(pnNodes, &lowtype, batch, low     , midlow, rindex_indexAutobatch(midlow-low+1, batch), val);  /* taking original batch here assures that batch does not recursively shrink */
      pnode->high = rindex_rectie(pnNodes, &hightype, batch, midlow+1, high  , rindex_indexAutobatch(high-midlow , batch), val);  /* taking original batch here assures that batch does not recursively shrink */
      (*plowhightype)=0;
      (*pnNodes)++;
      pnode->lowhightype = lowtype + 2*hightype;
      return(pnode);
    }

  }
  /* if (low-high+1)<=flexbatch OR all values equal (takewhich==0) */
  //Rprintf("rindex_rectie creates leaf: low=%d  high=%d\n", low, high);
  Treeleaf *pleaf;
  pleaf = Calloc(sizeof(Treeleaf), Treeleaf);
  pleaf->low  = low;
  pleaf->high = high;
  (*plowhightype)=1;
  (*pnNodes)++;
  return(pleaf);
}


SEXP rindex_indexAddTree(SEXP obj){
  SEXP val = getListElement(obj, "val");
  //int *pos = INTEGER(getListElement(obj, "pos")) ;
  int n     = asInteger(getListElement(obj, "n"));
  if (n){
    int nNA   = asInteger(getListElement(obj, "nNA"));
    int batch = asInteger(getListElement(obj, "batch"));
    int uni   = asLogical(getListElement(obj, "uni"));
    SEXP extPtr;
    Treeroot *tree;
    tree = Calloc(sizeof(Treeroot), Treeroot);

    int dummylowhightype=0; /* not stored in topnode since tree->nNodes>1 is sufficient */
    tree->nNodes=0;
    if (uni){
      tree->topnode = rindex_recuni(&(tree->nNodes), &dummylowhightype, batch, 0, n-nNA-1);
    }else{
      tree->topnode = rindex_rectie(&(tree->nNodes), &dummylowhightype, batch, 0, n-nNA-1, batch, val);
    }

    extPtr = R_MakeExternalPtr(tree, install("Rindex_extPtrTree"), R_NilValue);
    R_RegisterCFinalizer(extPtr, rindex_FinalizeTree);
    setListElement(obj,"tree",extPtr);
  }
  return obj;
}


SEXP rindex_indexDelTree(SEXP obj){
  SEXP extPtr = getListElement(obj, "tree");
  rindex_FinalizeTree(extPtr);
  R_ClearExternalPtr(extPtr);
  return obj;
}


SEXP rindex_indexNodes(SEXP extPtr){
  Treeroot *tree = R_ExternalPtrAddr(extPtr);
  SEXP ret;
  PROTECT(ret = allocVector(INTSXP, 1));
  if(tree && tree->nNodes){
    INTEGER(ret)[0] =tree->nNodes;
  }else{
    INTEGER(ret)[0] =0;
  }
  UNPROTECT(1);
  return ret;
}


/* must only be called for Treenode, not for Treeleaf */
void rindex_recbytes(int *pBytes, Treenode *pnode){
  if (pnode->lowhightype & 1){
    (*pBytes)+=sizeof(Treeleaf);
  }else{
    rindex_recbytes(pBytes, pnode->low);
  }
  if (pnode->lowhightype & 2){
    (*pBytes)+=sizeof(Treeleaf);
  }else{
    rindex_recbytes(pBytes, pnode->high);
  }
  (*pBytes)+=sizeof(Treenode);
  return;
}

SEXP rindex_indexBytes(SEXP extPtr){
  Treeroot *tree = R_ExternalPtrAddr(extPtr);
  int nBytes=0;
  SEXP ret;
  if(tree && tree->nNodes){
       if (tree->nNodes==1){
         // topnode is a leaf
         nBytes+=sizeof(Treeleaf);
       }else{
         // topnode is a node
         rindex_recbytes(&nBytes, tree->topnode);
       }
       nBytes+=sizeof(Treeroot);
  }
  PROTECT(ret = allocVector(INTSXP, 1));
  INTEGER(ret)[0] =nBytes;
  UNPROTECT(1);
  return ret;
}



/* must only be called for Treenode, not for Treeleaf */
void rindex_recprint(int level, Treenode *pnode){
  int i;
  Treeleaf *ptreeleaf;

  for (i=0;i<level;i++)Rprintf("  ");
  Rprintf("low=%d mid=%d high=%d type=%d\n", pnode->low, pnode->mid, pnode->high, pnode->lowhightype);
  level++;
  if (pnode->lowhightype & 1){
    ptreeleaf = pnode->low;
    for (i=0;i<level;i++)Rprintf("  ");
    Rprintf("low=%d high=%d\n", ptreeleaf->low, ptreeleaf->high);
  }else{
    rindex_recprint(level, pnode->low);
  }
  if (pnode->lowhightype & 2){
    ptreeleaf = pnode->high;
    for (i=0;i<level;i++)Rprintf("  ");
    Rprintf("low=%d high=%d\n", ptreeleaf->low, ptreeleaf->high);
  }else{
    rindex_recprint(level, pnode->high);
  }
  return;
}



SEXP rindex_PrintTree(SEXP extPtr){
  Treeroot *tree = R_ExternalPtrAddr(extPtr);
  if(tree && tree->nNodes){
       if (tree->nNodes==1){
         // topnode is a leaf
         Rprintf("low=%d high=%d\n", ((pTreeleaf)tree->topnode)->low, ((pTreeleaf)tree->topnode)->high);
       }else{
         // topnode is a node
         rindex_recprint(0, tree->topnode);
       }
  }else{
    Rprintf("No tree to print\n");
  }
  return R_NilValue;
}



/* must only be called for Treenode, not for Treeleaf */
void rindex_recIndexFind(Rboolean isleaf, void *pnode, SEXP val, SEXP v, int findlow, int *pstatus, int *pfound){
  int i=0;
  int vi2val=0;
  if (isleaf){
    Treeleaf *lnode=pnode;
    if (findlow){
      for (i=lnode->low;i<=(lnode->high);i++){
        vi2val = rindex_strcmp(STRING_ELT(v,i),val);
        if (vi2val>=0){
          (*pfound)=i;
          if (vi2val==0){
            (*pstatus)=0;
          }else{
            (*pstatus)=1;
          }
          return;
        }
      }
      (*pfound)=-1;
      (*pstatus)=-1;
    }else{
      for (i=lnode->high;i>=lnode->low;i--){
        vi2val = rindex_strcmp(STRING_ELT(v,i),val);
        if (vi2val<=0){
          (*pfound)=i;
          if (vi2val==0){
            (*pstatus)=0;
          }else{
            (*pstatus)=1;
          }
          return;
        }
      }
      (*pfound)=-1;
      (*pstatus)=-1;
    }
  }else{
    Treenode *inode=pnode;
    if (rindex_strcmp(val, STRING_ELT(v,inode->mid))>0){
      rindex_recIndexFind(inode->lowhightype & 2, inode->high, val, v, findlow, pstatus, pfound);
    }else{
      rindex_recIndexFind(inode->lowhightype & 1, inode->low, val, v, findlow, pstatus, pfound);
    }
  }
  return;
}


SEXP rindex_indexFind(SEXP obj, SEXP val_, SEXP findlow_){
  int n   = asInteger(getListElement(obj, "n"));
  int nNA = asInteger(getListElement(obj, "nNA"));
  int status= -1, found= -1;
  SEXP ret;
  PROTECT(ret = allocVector(INTSXP, 2));
  if (n){
    SEXP val = asChar(val_);
      int findlow = asLogical(findlow_);
    if (val==NA_STRING){
      if (nNA){
        if (findlow){
          status = 0;
          found  = n-nNA;
        }else{
          status = 0;
          found  = n-1;
        }
      }
    }else{
      SEXP v = getListElement(obj, "val");
      Treeroot *tree = R_ExternalPtrAddr(getListElement(obj, "tree"));
      if(!tree || !tree->nNodes){
        rindex_indexAddTree(obj);
      }
      tree = R_ExternalPtrAddr(getListElement(obj, "tree"));

      rindex_recIndexFind(tree->nNodes==1, tree->topnode, val, v, findlow, &status, &found);
    }

  }
  INTEGER(ret)[0] =status;
  INTEGER(ret)[1] =found + 1; /* R offset for vector indexing */
  UNPROTECT(1);
  return ret;
}




/* must only be called for Treenode, not for Treeleaf */
int rindex_recIsLikeHigh(Rboolean isleaf, void *pnode, char *val, int nval, SEXP v){
  int ret=0;
  if (isleaf){
    Treeleaf *lnode=pnode;
    ret = rindex_strlike(STRING_ELT(v,lnode->low),val, nval)==0;
  }else{
    Treenode *inode=pnode;
    ret = rindex_recIsLikeHigh(inode->lowhightype & 1, inode->low, val, nval, v);
  }
  return(ret);
}

/* must only be called for Treenode, not for Treeleaf */
void rindex_recIndexFindlike(Rboolean isleaf, void *pnode, char *val, int nval, SEXP v, int findlow, int *pstatus, int *pfound){
  int i=0;
  int vi2val=0;
  if (isleaf){
    Treeleaf *lnode=pnode;
    if (findlow){
      for (i=lnode->low;i<=(lnode->high);i++){
        vi2val = rindex_strlike(STRING_ELT(v,i),val, nval);
        if (vi2val>=0){
          (*pfound)=i;
          if (vi2val==0){
            (*pstatus)=0;
          }else{
            (*pstatus)=1;
          }
          return;
        }
      }
      (*pfound)=-1;
      (*pstatus)=-1;
    }else{
      for (i=lnode->high;i>=lnode->low;i--){
        vi2val = rindex_strlike(STRING_ELT(v,i),val, nval);
        if (vi2val<=0){
          (*pfound)=i;
          if (vi2val==0){
            (*pstatus)=0;
          }else{
            (*pstatus)=1;
          }
          return;
        }
      }
      (*pfound)=-1;
      (*pstatus)=-1;
    }
  }else{
    Treenode *inode=pnode;
    if ((rindex_strlike(STRING_ELT(v,inode->mid), val, nval)<0)  ||
    (!findlow && rindex_recIsLikeHigh(inode->lowhightype & 2, inode->high, val, nval, v)) ){
      rindex_recIndexFindlike(inode->lowhightype & 2, inode->high, val, nval, v, findlow, pstatus, pfound);
    }else{
      rindex_recIndexFindlike(inode->lowhightype & 1, inode->low, val, nval, v, findlow, pstatus, pfound);
    }
  }
  return;
}


SEXP rindex_indexFindlike(SEXP obj, SEXP val_, SEXP findlow_){
  int n   = asInteger(getListElement(obj, "n"));
  int nNA = asInteger(getListElement(obj, "nNA"));
  int status= -1, found= -1;
  SEXP ret;
  PROTECT(ret = allocVector(INTSXP, 2));
  if (n){
    SEXP val = asChar(val_);
      int findlow = asLogical(findlow_);
    if (val==NA_STRING){
      if (nNA){
        if (findlow){
          status = 0;
          found  = n-nNA;
        }else{
          status = 0;
          found  = n-1;
        }
      }
    }else{
      SEXP v = getListElement(obj, "val");
      Treeroot *tree = R_ExternalPtrAddr(getListElement(obj, "tree"));
      if(!tree || !tree->nNodes){
        rindex_indexAddTree(obj);
      }
      tree = R_ExternalPtrAddr(getListElement(obj, "tree"));

      rindex_recIndexFindlike(tree->nNodes==1, tree->topnode, translateChar(val), LENGTH(val), v, findlow, &status, &found);
    }

  }
  INTEGER(ret)[0] =status;
  INTEGER(ret)[1] =found + 1; /* R offset for vector indexing */
  UNPROTECT(1);
  return ret;
}



SEXP rindex_indexMatch(SEXP obj, SEXP val_, SEXP findlow_){
  int n   = asInteger(getListElement(obj, "n"));
  int nNA = asInteger(getListElement(obj, "nNA"));
  int status= -1, found= -1;
  SEXP ret;
  if (n){
    SEXP v = getListElement(obj, "val");
    SEXP val;
    int findlow = asLogical(findlow_);
    int i, nval = LENGTH(val_);
    PROTECT(ret = allocVector(INTSXP, nval));

    Treeroot *tree = R_ExternalPtrAddr(getListElement(obj, "tree"));
    if(!tree || !tree->nNodes){
      rindex_indexAddTree(obj);
    }

    tree = R_ExternalPtrAddr(getListElement(obj, "tree"));
    for (i=0;i<nval;i++){
      val = STRING_ELT(val_,i);

      if (val==NA_STRING){
        if (nNA){
          if (findlow){
            INTEGER(ret)[i] = n-nNA+1;
          }else{
            INTEGER(ret)[i] = n;
          }
        }else{
          INTEGER(ret)[i] = NA_INTEGER;
        }
      }else{
        rindex_recIndexFind(tree->nNodes==1, tree->topnode, val, v, findlow, &status, &found); /* R offset for vector indexing */
        if (status==0)
          INTEGER(ret)[i] = found + 1;
        else
          INTEGER(ret)[i] = NA_INTEGER;
      }
    }
  }else{
    PROTECT(ret = allocVector(INTSXP, 0));
  }
  UNPROTECT(1);
  return ret;
}



/* end tree functions }
   -------------------------------------------------------------------------------------------- */
