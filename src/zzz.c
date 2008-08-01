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


/* --------------------------------------------------------------------------------
 { begin external pointer demo */

typedef int INT, *pINT;

static void demo_rindex_finalize(SEXP extPtr){
  pINT ptr = R_ExternalPtrAddr(extPtr);
  if(ptr){
    Free(ptr);
    Rprintf("finalized\n");
  }else{
    /* make sure the finalizer does nothing in case it is called with a nil pointer
       because it might get called twice
    */
    Rprintf("nothing to finalize\n");
  }
  return;
}

SEXP demo_rindex_open(
  SEXP Sn
){
  int i,n = INTEGER(Sn)[0];
  pINT ptr = Calloc(n, INT);
  SEXP extPtr, ret;
  for (i=0;i<n;i++){
    ptr[i] = i;
  }
  extPtr = R_MakeExternalPtr(ptr, install("Rindex_extPtr"), R_NilValue);
  R_RegisterCFinalizer(extPtr, demo_rindex_finalize);

  PROTECT(ret = allocVector(VECSXP, 1));
  SET_VECTOR_ELT(ret,0,extPtr);
  UNPROTECT(1);
  return ret;
}

SEXP demo_rindex_close(
  SEXP obj
){
  int i, n= 10;
  SEXP ret, extPtr=VECTOR_ELT(obj, 0);
  pINT p, ptr = R_ExternalPtrAddr(extPtr);

  PROTECT(ret = allocVector(INTSXP, n));
  p = INTEGER(ret);
  for (i=0;i<n;i++){
    /* Rprintf("ptri=%d\n",ptr[i]); */
    p[i] = ptr[i];
  }

  /* this does finalize immediately but at next garbage collection again
  */
  demo_rindex_finalize(extPtr);
  /* this must not called otherwise the pointer is gone at garbage collection time
  */
  R_ClearExternalPtr(extPtr);

  /* this triggers the finalizer but only at next garbage collection
  SET_VECTOR_ELT(obj,0,R_NilValue);
  */

  UNPROTECT(1);
  return ret;
}

/* end external pointer demo }
   -------------------------------------------------------------------------------- */
