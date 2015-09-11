/* file:        descmatch.c
** author:      Minsu Cho
** description: descriptor matching.
**/

/* 
by Minsu Cho, 
CVL, Seoul National University, April 2010

original codes are created by Andrea Vedaldi
UCLA Vision Lab - Department of Computer Science

 *
 * input:  ( DESC1, DESC2, bHALF=0, THRESH_RATIO = 0.8 , THRESH_DIST = 0 , KNN = 0 )
 *        DESC - dim of desc x num of desc (e.g., 128 x nDesc matrix for SIFT )
 *        bHALF - half comparison for matching whithin a single image     
 *        THRESH_RATIO ( < 1.0) - dist ratio of the best to the second - Lowe's unambiguous matching  : disabled if 0  
 *        THRESH_DIST  - absolute dist threshold for inliers : INF if 0 
 *        KNN          - max num of matching features for each feature : INF if 0  
*/


#include"mexutils.h"
#include<stdlib.h>
#include<string.h>
#include<math.h>
#include<stdio.h>

#define greater(a,b) ((a) > (b))
#define min(a,b) (((a)<(b))?(a):(b))
#define max(a,b) (((a)>(b))?(a):(b))

#define TYPEOF_mxDOUBLE_CLASS double
#define TYPEOF_mxSINGLE_CLASS float
#define TYPEOF_mxINT8_CLASS   char
#define TYPEOF_mxUINT8_CLASS  unsigned char

#define PROMOTE_mxDOUBLE_CLASS double
#define PROMOTE_mxSINGLE_CLASS float
#define PROMOTE_mxINT8_CLASS   int
#define PROMOTE_mxUINT8_CLASS  int

#define MAXVAL_mxDOUBLE_CLASS mxGetInf()
#define MAXVAL_mxSINGLE_CLASS ((float)mxGetInf())
#define MAXVAL_mxINT8_CLASS   0x7fffffff
#define MAXVAL_mxUINT8_CLASS  0x7fffffff

typedef struct
{
  int k1 ;
  int k2 ;
  double score ;
} Pair ;

/*
 * This macro defines the matching function for abstract type; that
 * is, it is a sort of C++ template.  This is also a good illustration
 * of why C++ is preferable for templates :-)
 */
#define _COMPARE_TEMPLATE(MXC)                                          \
  Pair* compare_##MXC (Pair* pairs_iterator,                            \
                       const TYPEOF_##MXC * L1_pt,                      \
                       const TYPEOF_##MXC * L2_pt,                      \
                       int K1, int K2, int ND, int max_pairs, int bHalf, double thresh_ratio,      \
                       double thresh_dist,int kNN )                      \
  {                                                                     \
    int k1, k2, itr_i, itr_j, idx_start, kBound, num_selected;          \
    int tmpIdx; PROMOTE_##MXC tmpScore;                               \
    const PROMOTE_##MXC maxval = MAXVAL_##MXC;                                \
    int* candIdx;                                                           \
    PROMOTE_##MXC* candScore;                                               \
    int nPairs = 0;                                                     \
    printf("- Match func: ratio th:%f, dist th:%f \n", thresh_ratio, thresh_dist);     \
    thresh_ratio = thresh_ratio*thresh_ratio;                            \
    thresh_dist = thresh_dist*thresh_dist;                            \
    if ( thresh_ratio > 0 )                                            \
    { /* Lowe's method: unambiguous one-to-one*/                        \
        if (thresh_dist == 0) {                                              \
            thresh_dist = maxval; }                                         \
                                                                            \
        for(k1 = 0 ; k1 < K1 ; ++k1, L1_pt += ND ) {                        \
                                                                            \
          double best = thresh_dist ;                                \
          double second_best = thresh_dist ;                         \
          int bestk = -1 ;                                                  \
          if (bHalf == 1) {                                              \
            idx_start = k1+1;                                               \
            L2_pt += (k1+1)*ND;                                              \
          }                                                                 \
          else                                                              \
            idx_start = 0;                                                  \
          /* For each point P2[k2] in the second image... */                \
          for(k2 =  idx_start ; k2 < K2 ; ++k2, L2_pt += ND) {              \
                                                                            \
            int bin ;                                                       \
            PROMOTE_##MXC acc = 0 ;                                         \
            for(bin = 0 ; bin < ND ; ++bin) {                               \
              PROMOTE_##MXC delta =                                         \
                ((PROMOTE_##MXC) L1_pt[bin]) -                              \
                ((PROMOTE_##MXC) L2_pt[bin]) ;                              \
              acc += delta*delta ;                                          \
            }                                                               \
                                                                            \
            /* Filter the best and second best matching point. */           \
            if(acc < best) {                                                \
              second_best = best ;                                          \
              best = acc ;                                                  \
              bestk = k2 ;                                                  \
            } else if(acc < second_best) {                                  \
              second_best = acc ;                                           \
            }                                                               \
          }                                                                 \
                                                                            \
          L2_pt -= ND*K2 ;                                                  \
          /* Lowe's method: accept the match only if unique. */             \
          if( (double) best <= thresh_ratio * (double) second_best &&      \
             bestk != -1) {                                             \
            pairs_iterator->k1 = k1 ;                                       \
            pairs_iterator->k2 = bestk ;                                    \
            pairs_iterator->score = best ;                                  \
            pairs_iterator++ ;                                              \
            nPairs++ ;                                              \
          }                                                             \
        }                                                                   \
    }                                                                       \
    else                                                                    \
    { /* one-to-many matches */                                             \
        if (thresh_dist == 0) {                                              \
            thresh_dist = maxval; }                                         \
        if (kNN == 0) {                                              \
            kNN = K2; }                                                    \
        candIdx = (int*) malloc(K2 * sizeof(int));                         \
        candScore = (PROMOTE_##MXC*) malloc(K2 * sizeof(PROMOTE_##MXC));   \
                                                                            \
        for(k1 = 0 ; k1 < K1 ; ++k1, L1_pt += ND ) {                        \
                                                                            \
          num_selected = 0;                                             \
          if (bHalf == 1) {                                              \
            idx_start = k1+1;                                               \
            L2_pt += (k1+1)*ND;                                              \
          }                                                                 \
          else                                                              \
            idx_start = 0;                                                  \
          /* For each point P2[k2] in the second image... */                \
          for(k2 =  idx_start ; k2 < K2 ; ++k2, L2_pt += ND) {                      \
                                                                            \
            int bin ;                                                       \
            PROMOTE_##MXC acc = 0 ;                                         \
            for(bin = 0 ; bin < ND ; ++bin) {                               \
              PROMOTE_##MXC delta =                                         \
                ((PROMOTE_##MXC) L1_pt[bin]) -                              \
                ((PROMOTE_##MXC) L2_pt[bin]) ;                              \
              acc += delta*delta ;                                          \
            }                                                               \
                                                                            \
            /* Filter the bad matches using thresh_dist */                  \
            if(acc < thresh_dist) {                                         \
              candIdx[num_selected] = k2 ;                                     \
              candScore[num_selected] = acc ;                                     \
              num_selected++ ;                                              \
            }                                                               \
          }                                                                 \
                                                                            \
          L2_pt -= ND*K2 ;                                                  \
          /* Find kNN from the candidates */                                \
          kBound = min( kNN, num_selected );                            \
          for(itr_i = 0; itr_i < kBound; ++itr_i ) {                      \
                if( kNN < num_selected ) {                                  \
                    for (itr_j = itr_i; itr_j < num_selected; ++itr_j ) {   \
                      if(candScore[itr_i] > candScore[itr_j]) {               \
                          tmpScore = candScore[itr_i];                       \
                          candScore[itr_i] = candScore[itr_j];            \
                          candScore[itr_j] = tmpScore;                        \
                          tmpIdx = candIdx[itr_i];                            \
                          candIdx[itr_i] = candIdx[itr_j];                 \
                          candIdx[itr_j] = tmpIdx;                            \
                      }                                                     \
                    }                                                       \
              }                                                             \
              pairs_iterator->k1 = k1 ;                                     \
              pairs_iterator->k2 = candIdx[itr_i] ;                        \
              pairs_iterator->score = candScore[itr_i] ;                   \
              pairs_iterator++ ;                                            \
              nPairs++ ;                                                    \
              if( nPairs == max_pairs ){                                  \
                break; }                                                  \
            }                                                             \
            if( nPairs == max_pairs ){                                  \
              break; }                                                  \
       }                                                                \
       free(candIdx);                                                   \
       free(candScore);                                                 \
                                                                        \
    }                                                                   \
                                                                        \
    return pairs_iterator ;                                             \
  }                                                                     \

_COMPARE_TEMPLATE( mxDOUBLE_CLASS )
_COMPARE_TEMPLATE( mxSINGLE_CLASS )
_COMPARE_TEMPLATE( mxINT8_CLASS   )
_COMPARE_TEMPLATE( mxUINT8_CLASS  )

void
mexFunction(int nout, mxArray *out[],
            int nin, const mxArray *in[])
{
  int K1, K2, ND ;
  void* L1_pt ;
  void* L2_pt ;
  double thresh_ratio = 0.8 ;
  double thresh_dist = 0 ;
  int kNN = 0;
  int bHalf = 0;
  mxClassID data_class ;
  enum {L1=0,L2, HALF, THRESH_RATIO, THRESH_DIST, KNN} ;
  enum {MATCHES=0,D} ;

  /* ------------------------------------------------------------------
  **                                                Check the arguments
  ** --------------------------------------------------------------- */
  if (nin < 2) {
    mexErrMsgTxt("At least two input arguments required");
  } else if (nout > 2) {
    mexErrMsgTxt("Too many output arguments");
  }

  if(!mxIsNumeric(in[L1]) ||
     !mxIsNumeric(in[L2]) ||
     mxGetNumberOfDimensions(in[L1]) > 2 ||
     mxGetNumberOfDimensions(in[L2]) > 2) {
    mexErrMsgTxt("L1 and L2 must be two dimensional numeric arrays") ;
  }

  K1 = mxGetN(in[L1]) ;
  K2 = mxGetN(in[L2]) ;
  ND = mxGetM(in[L1]) ;

  if(mxGetM(in[L2]) != ND) {
    mexErrMsgTxt("L1 and L2 must have the same number of rows") ;
  }

  data_class = mxGetClassID(in[L1]) ;
  if(mxGetClassID(in[L2]) != data_class) {
    mexErrMsgTxt("L1 and L2 must be of the same class") ;
  }

  L1_pt = mxGetData(in[L1]) ;
  L2_pt = mxGetData(in[L2]) ;
  
  
  if(nin > 2) {
    if(!uIsRealScalar(in[HALF])) {
      mexErrMsgTxt("bHALF should be a real scalar") ;
    }
    bHalf = *mxGetPr(in[HALF]) ;
  }
  if(nin > 3) {
    if(!uIsRealScalar(in[THRESH_RATIO])) {
      mexErrMsgTxt("THRESH_RATIO should be a real scalar") ;
    }
    thresh_ratio = *mxGetPr(in[THRESH_RATIO]) ;
  }
  if(nin > 4) {
    if(!uIsRealScalar(in[THRESH_DIST])) {
      mexErrMsgTxt("THRESH_DIST should be a real scalar") ;
    }
    thresh_dist = *mxGetPr(in[THRESH_DIST]) ;
  } 
  if(nin > 5) {
    if(!uIsRealScalar(in[KNN])) {
      mexErrMsgTxt("KNN should be a real scalar") ;
    }
    kNN = *mxGetPr(in[KNN]);      
  } 
  
  if(nin > 6) {
    mexErrMsgTxt("At most six arguments are allowed") ;
  }

  /* ------------------------------------------------------------------
  **                                                         Do the job
  ** --------------------------------------------------------------- */
  {
    int max_pairs = K1*500;  
    Pair* pairs_begin = (Pair*) mxMalloc(sizeof(Pair) * max_pairs) ;
    Pair* pairs_iterator = pairs_begin ;


#define _DISPATCH_COMPARE( MXC )                                        \
    case MXC :                                                          \
      pairs_iterator = compare_##MXC(pairs_iterator,                    \
                                     (const TYPEOF_##MXC*) L1_pt,       \
                                     (const TYPEOF_##MXC*) L2_pt,       \
                                     K1,K2,ND,max_pairs, bHalf, thresh_ratio,thresh_dist, \
                                     kNN ) ;                            \
    break ;                                                             \

    switch (data_class) {
    _DISPATCH_COMPARE( mxDOUBLE_CLASS ) ;
    _DISPATCH_COMPARE( mxSINGLE_CLASS ) ;
    _DISPATCH_COMPARE( mxINT8_CLASS   ) ;
    _DISPATCH_COMPARE( mxUINT8_CLASS  ) ;
    default :
      mexErrMsgTxt("Unsupported numeric class") ;
      break ;
    }

    /* ---------------------------------------------------------------
     *                                                        Finalize
     * ------------------------------------------------------------ */
    {
      Pair* pairs_end = pairs_iterator ;
      double* M_pt ;
      double* D_pt = NULL ;

      out[MATCHES] = mxCreateDoubleMatrix
        (2, pairs_end-pairs_begin, mxREAL) ;
      printf("- %d \n", pairs_end-pairs_begin);
      M_pt = mxGetPr(out[MATCHES]) ;

      if(nout > 1) {
        out[D] = mxCreateDoubleMatrix(1,
                                      pairs_end-pairs_begin,
                                      mxREAL) ;
        D_pt = mxGetPr(out[D]) ;
      }

      for(pairs_iterator = pairs_begin ;
          pairs_iterator < pairs_end  ;
          ++pairs_iterator) {
        *M_pt++ = pairs_iterator->k1 + 1 ;
        *M_pt++ = pairs_iterator->k2 + 1 ;
        if(nout > 1) {
          *D_pt++ = pairs_iterator->score ;
        }
      }
    }
    mxFree(pairs_begin) ;
  }
}
