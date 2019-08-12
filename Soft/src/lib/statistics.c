/*******************************************************************************
PolSARpro v5.0 is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 (1991) of the License, or any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. 

See the GNU General Public License (Version 2, 1991) for more details.

********************************************************************************

File   : statistics.c
Project  : ESA_POLSARPRO
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.1
Creation : 06/2005
Update  : 12/2006 (Stephane MERIC)

*-------------------------------------------------------------------------------
INSTITUT D'ELECTRONIQUE et de TELECOMMUNICATIONS de RENNES (I.E.T.R)
UMR CNRS 6164
Groupe Image et Teledetection
Equipe SAPHIR (SAr Polarimetrie Holographie Interferometrie Radargrammetrie)
UNIVERSITE DE RENNES I
Pôle Micro-Ondes Radar
Bât. 11D - Campus de Beaulieu
263 Avenue Général Leclerc
35042 RENNES Cedex
Tel :(+33) 2 23 23 57 63
Fax :(+33) 2 23 23 69 63
e-mail : eric.pottier@univ-rennes1.fr, laurent.ferro-famil@univ-rennes1.fr
*-------------------------------------------------------------------------------
Description :  STATISTICS Routines
*-------------------------------------------------------------------------------
Routines  :
float MeanVectorReal(float *VC, int Ncol);
float SecondOrderCenteredVectorReal(float *VC, int Ncol);
float SecondOrderNonCenteredVectorReal(float *VC, int Ncol);
float ThirdOrderCenteredVectorReal(float *VC, int Ncol);
float ThirdOrderNonCenteredVectorReal(float *VC, int Ncol);
float FourthOrderCenteredVectorReal(float *VC, int Ncol);
float FourthOrderNonCenteredVectorReal(float *VC, int Ncol);

float MeanMatrixReal(float **MT,int Nlin, int Ncol);
float SecondOrderCenteredMatrixReal(float **MT,int Nlin, int Ncol);
float SecondOrderNonCenteredMatrixReal(float **MT,int Nlin, int Ncol);
float ThirdOrderCenteredMatrixReal(float **MT,int Nlin, int Ncol);
float ThirdOrderNonCenteredMatrixReal(float **MT,int Nlin, int Ncol);
float FourthOrderCenteredMatrixReal(float **MT,int Nlin, int Ncol);
float FourthOrderNonCenteredMatrixReal(float **MT,int Nlin, int Ncol);

void HistogramVectorReal(float *VC, int Ncol, float min_value, float max_value, int Nbin, float *Xhist, float *Yhist);
void HistogramMatrixReal(float **MT, int Nlin, int Ncol, float min_value, float max_value, int Nbin, float *Xhist, float *Yhist);
int comp_float(const void *a, const void *b);

void chisq(float *bins, float *ebins, int nbins, int knstrn, float *df, float *chsq, float *prob);
float gammln(float xx);
void gser(float *gamser, float a, float x, float *gln);
void gcf(float *gammcf, float a, float x, float *gln);
float gammp(float a, float x);
float gammq(float a, float x);
void chisq_testVector(float *VC, int Ncol, float min_value, float max_value, int Nbin, int pdf_case, float *df, float *chsq, float *prob);
void GaussHist(float mean, float var, int Nsamples, int Nbin, float *Xvalue, float *ThHist);
void ExpHist(float mean, int Nsamples, int Nbin, float *Xvalue, float *ThHist);
void RayHist(float mean, int Nsamples, int Nbin, float *Xvalue, float *ThHist);
void UnifHist(float min_value, float max_value, int Nsamples, int Nbin, float *Xvalue, float *ThHist);

void HistogramVectorRealNorm(float *VC, int Ncol, float min_value, float max_value, int Nbin, float *Xhist, float *Yhist);
void GaussHistNorm(float mean, float var, int Nsamples, int Nbin, float *Xvalue, float *ThHist);
void ExpHistNorm(float mean, int Nsamples, int Nbin, float *Xvalue, float *ThHist);
void RayHistNorm(float mean, int Nsamples, int Nbin, float *Xvalue, float *ThHist);
void UnifHistNorm(float min_value, float max_value, int Nsamples, int Nbin, float *Xvalue, float *ThHist);

float probks(float alam);
void ksks(float *data1,float *xvalues, unsigned long nbins1, float data2[], unsigned long nbins2 ,float *d, float *prob);
void ks_testVector(float *VC, int Ncol, float min_value, float max_value, int Nbin, int pdf_case, float *d, float *prob);
float GaussCDF(float x);
float UnifCDF(float x);
float ExpCDF(float x);
float RayCDF(float x);
float erff(float x);

float AmplitudeComplex(float Re, float Im);
float PhaseComplex(float Re, float Im);
void CorrelationFactor(float *S1_re, float *S1_im, float *S2_re, float *S2_im, float Ncol, float *rho_amp, float *rho_phase);

*******************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#if defined(__sun) || defined(__sun__)
#include <ieeefp.h>
#endif

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

#include "PolSARproLib.h"

#define ITMAX 100
#define EPS 3.0e-7
#define EPS1 0.001
#define EPS2 1.0e-8
#define FPMIN 1.0e-30

/**********************/
/* MOMENTS OF VECTORS */
/**********************/

/*******************************************************************************
Routine  : MeanVectorReal
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the Mean of a Vector of floats
*-------------------------------------------------------------------------------
Inputs arguments :
VC      : Input Vector
Ncol    : Number of columns of VC
Returned values  :
VC_mean    : Mean of the vector
*******************************************************************************/
float MeanVectorReal(float *VC, int Ncol)
{  
  int mm;
  float VC_moment;
  
  VC_moment = 0.0;
  for(mm = 0; mm < Ncol; mm++)
    VC_moment += VC[mm];
  VC_moment = VC_moment / (float) Ncol;
  
  return VC_moment;
}

/*******************************************************************************
Routine  : SecondOrderCenteredVectorReal
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the Second Order Centered Moment (Variance) of a Vector of floats
*-------------------------------------------------------------------------------
Inputs arguments :
VC      : Input Vector
Ncol    : Number of columns of VC
Returned values  :
VC_mean    : Second Centered Moment of the vector
*******************************************************************************/
float SecondOrderCenteredVectorReal(float *VC, int Ncol)
{  
  int mm;
  float VC_mean, VC_moment;
  
  VC_mean = MeanVectorReal(VC,Ncol);
  VC_moment = 0.0;
  for(mm = 0; mm < Ncol; mm++)
    VC_moment += (VC[mm] - VC_mean) * (VC[mm] - VC_mean);
  VC_moment = VC_moment / (float) (Ncol - 1);
  
  return VC_moment;
}

/*******************************************************************************
Routine  : SecondOrderNonCenteredVectorReal
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the Second Order Non Centered Moment (Power) of a Vector of floats
*-------------------------------------------------------------------------------
Inputs arguments :
VC      : Input Vector
Ncol    : Number of columns of VC
Returned values  :
VC_mean    : Second Non Centered Moment of the vector
*******************************************************************************/
float SecondOrderNonCenteredVectorReal(float *VC, int Ncol)
{  
  int mm;
  float VC_moment;
  
  VC_moment = 0.0;
  for(mm = 0; mm < Ncol; mm++)
    VC_moment += (VC[mm]) * (VC[mm]);
  VC_moment = VC_moment / (float) Ncol;
  
  return VC_moment;
}

/*******************************************************************************
Routine  : ThirdOrderCenteredVectorReal
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the Third Order Centered Moment (Skewness) of a Vector of floats
*-------------------------------------------------------------------------------
Inputs arguments :
VC      : Input Vector
Ncol    : Number of columns of VC
Returned values  :
VC_mean    : Third Centered Moment of the vector 
*******************************************************************************/
float ThirdOrderCenteredVectorReal(float *VC, int Ncol)
{  
  int mm;
  float VC_variance, VC_mean, VC_moment;
  
  VC_mean   = MeanVectorReal(VC,Ncol);
  VC_variance = SecondOrderCenteredVectorReal(VC,Ncol);
  
  VC_moment = 0.0;
  for(mm = 0; mm < Ncol; mm++)
    VC_moment += (VC[mm] - VC_mean) * (VC[mm] - VC_mean) * (VC[mm] - VC_mean);
  VC_moment = VC_moment / (float) Ncol;
  VC_moment = VC_moment / (float) sqrt(VC_variance * VC_variance *VC_variance);
  
  return VC_moment;
}

/*******************************************************************************
Routine  : ThirdOrderNonCenteredVectorReal
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the Third Order Non Centered Moment of a Vector of floats
*-------------------------------------------------------------------------------
Inputs arguments :
VC      : Input Vector
Ncol    : Number of columns of VC
Returned values  :
VC_mean    : Third Non Centered Moment of the vector
*******************************************************************************/
float ThirdOrderNonCenteredVectorReal(float *VC, int Ncol)
{  
  int mm;
  float VC_moment;
  
  VC_moment = 0.0;
  for(mm = 0; mm < Ncol; mm++)
    VC_moment += VC[mm] * VC[mm] * VC[mm];
  VC_moment = VC_moment / (float) Ncol;
  
  return VC_moment;
}

/*******************************************************************************
Routine  : FourthOrderCenteredVectorReal
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the Fourth Order Centered Moment (Kurtosis) of a Vector of floats
*-------------------------------------------------------------------------------
Inputs arguments :
VC      : Input Vector
Ncol    : Number of columns of VC
Returned values  :
VC_mean    : Fourth Centered Moment of the vector 
*******************************************************************************/
float FourthOrderCenteredVectorReal(float *VC, int Ncol)
{  
  int mm;
  float VC_variance, VC_mean, VC_moment;
  
  VC_mean   = MeanVectorReal(VC,Ncol);
  VC_variance = SecondOrderCenteredVectorReal(VC,Ncol);
  
  VC_moment = 0.0;
  for(mm = 0; mm < Ncol; mm++)
    VC_moment += (VC[mm] - VC_mean) * (VC[mm] - VC_mean) * (VC[mm] - VC_mean) * (VC[mm] - VC_mean);
  VC_moment = VC_moment / (float) Ncol;
  VC_moment = VC_moment / (VC_variance * VC_variance);
  
  return VC_moment;
}

/*******************************************************************************
Routine  : FourthOrderNonCenteredVectorReal
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the Fourth Order Non Centered Moment of a Vector of floats
*-------------------------------------------------------------------------------
Inputs arguments :
VC      : Input Vector
Ncol    : Number of columns of VC
Returned values  :
VC_mean    : Fourth Non Centered Moment of the vector
*******************************************************************************/
float FourthOrderNonCenteredVectorReal(float *VC, int Ncol)
{  
  int mm;
  float VC_moment;
  
  VC_moment = 0.0;
  for(mm = 0; mm < Ncol; mm++)
    VC_moment += VC[mm] * VC[mm] * VC[mm] * VC[mm];
  VC_moment = VC_moment / (float) Ncol;
  
  return VC_moment;
}

/***********************/
/* MOMENTS OF MATRICES */
/***********************/

/*******************************************************************************
Routine  : MeanMatrixReal
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the Mean of a Matrix of floats
*-------------------------------------------------------------------------------
Inputs arguments :
MT      : Input Matrix
Nlin    : Number of lines of MT
Ncol    : Number of columns of MT
Returned values  :
MT_mean    : Mean of the Matrix
*******************************************************************************/
float MeanMatrixReal(float **MT, int Nlin, int Ncol)
{  
  int mm,nn;
  float MT_moment;
  
  MT_moment = 0.0;
  for(nn = 0; nn < Nlin; nn++)
    for(mm = 0; mm < Ncol; mm++)
      MT_moment += MT[nn][mm];
  MT_moment = MT_moment / (float) (Ncol * Nlin);
  
  return MT_moment;
}

/*******************************************************************************
Routine  : SecondOrderCenteredMatrixReal
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the Second Order Centered Moment (Variance) of a Matrix of floats
*-------------------------------------------------------------------------------
Inputs arguments :
MT      : Input Matrix
Nlin    : Number of lines of MT
Ncol    : Number of columns of MT
Returned values  :
MT_mean    : Second Centered Moment of the Matrix
*******************************************************************************/
float SecondOrderCenteredMatrixReal(float **MT, int Nlin, int Ncol)
{  
  int mm,nn;
  float MT_mean, MT_moment;
  
  MT_mean = MeanMatrixReal(MT,Nlin,Ncol);
  MT_moment = 0.0;
  for(nn = 0; nn < Nlin; nn++)
    for(mm = 0; mm < Ncol; mm++)
      MT_moment += (MT[nn][mm] - MT_mean) * (MT[nn][mm] - MT_mean);
  MT_moment = MT_moment / (float) (Ncol * Nlin - 1);
  
  return MT_moment;
}

/*******************************************************************************
Routine  : SecondOrderNonCenteredMatrixReal
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the Second Order Non Centered Moment (Power) of a Matrix of floats
*-------------------------------------------------------------------------------
Inputs arguments :
MT      : Input Matrix
Nlin    : Number of lines of MT
Ncol    : Number of columns of MT
Returned values  :
MT_mean    : Second Non Centered Moment of the Matrix
*******************************************************************************/
float SecondOrderNonCenteredMatrixReal(float **MT, int Nlin, int Ncol)
{  
  int mm,nn;
  float MT_moment;
  
  MT_moment = 0.0;
  for(nn = 0; nn < Nlin; nn++)
    for(mm = 0; mm < Ncol; mm++)
      MT_moment += (MT[nn][mm]) * (MT[nn][mm]);
  MT_moment = MT_moment / (float) (Ncol * Nlin);
  
  return MT_moment;
}

/*******************************************************************************
Routine  : ThirdOrderCenteredMatrixReal
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the Third Order Centered Moment (Skewness) of a Matrix of floats
*-------------------------------------------------------------------------------
Inputs arguments :
MT      : Input Matrix
Nlin    : Number of lines of MT
Ncol    : Number of columns of MT
Returned values  :
MT_mean    : Third Centered Moment of the Matrix 
*******************************************************************************/
float ThirdOrderCenteredMatrixReal(float **MT, int Nlin, int Ncol)
{  
  int mm,nn;
  float MT_variance, MT_mean, MT_moment;
  
  MT_mean   = MeanMatrixReal(MT,Nlin,Ncol);
  MT_variance = SecondOrderCenteredMatrixReal(MT,Nlin,Ncol);
  
  MT_moment = 0.0;
  for(nn = 0; nn < Nlin; nn++)
    for(mm = 0; mm < Ncol; mm++)
      MT_moment += (MT[nn][mm] - MT_mean) * (MT[nn][mm] - MT_mean) * (MT[nn][mm] - MT_mean);
  MT_moment = MT_moment / (float) (Ncol * Nlin);
  MT_moment = MT_moment / (float) sqrt(MT_variance * MT_variance *MT_variance);
  
  return MT_moment;
}

/*******************************************************************************
Routine  : ThirdOrderNonCenteredMatrixReal
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the Third Order Non Centered Moment of a Matrix of floats
*-------------------------------------------------------------------------------
Inputs arguments :
MT      : Input Matrix
Nlin    : Number of lines of MT
Ncol    : Number of columns of MT
Returned values  :
MT_mean    : Third Non Centered Moment of the Matrix
*******************************************************************************/
float ThirdOrderNonCenteredMatrixReal(float **MT, int Nlin, int Ncol)
{  
  int mm,nn;
  float MT_moment;
  
  MT_moment = 0.0;
  for(nn = 0; nn < Nlin; nn++)
    for(mm = 0; mm < Ncol; mm++)
      MT_moment += MT[nn][mm] * MT[nn][mm] * MT[nn][mm];
  MT_moment = MT_moment / (float) (Ncol * Nlin);
  
  return MT_moment;
}

/*******************************************************************************
Routine  : FourthOrderCenteredMatrixReal
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the Fourth Order Centered Moment (Kurtosis) of a Matrix of floats
*-------------------------------------------------------------------------------
Inputs arguments :
MT      : Input Matrix
Nlin    : Number of lines of MT
Ncol    : Number of columns of MT
Returned values  :
MT_mean    : Fourth Centered Moment of the Matrix 
*******************************************************************************/
float FourthOrderCenteredMatrixReal(float **MT, int Nlin, int Ncol)
{  
  int mm,nn;
  float MT_variance, MT_mean, MT_moment;
  
  MT_mean   = MeanMatrixReal(MT,Nlin,Ncol);
  MT_variance = SecondOrderCenteredMatrixReal(MT,Nlin,Ncol);
  
  MT_moment = 0.0;
  for(nn = 0; nn < Nlin; nn++)
    for(mm = 0; mm < Ncol; mm++)
      MT_moment += (MT[nn][mm] - MT_mean) * (MT[nn][mm] - MT_mean) * (MT[nn][mm] - MT_mean) * (MT[nn][mm] - MT_mean);
  MT_moment = MT_moment / (float) (Ncol * Nlin);
  MT_moment = MT_moment / (MT_variance * MT_variance);
  
  return MT_moment;
}

/*******************************************************************************
Routine  : FourthOrderNonCenteredMatrixReal
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the Fourth Order Non Centered Moment of a Matrix of floats
*-------------------------------------------------------------------------------
Inputs arguments :
MT      : Input Matrix
Ncol    : Number of columns of MT
Returned values  :
MT_mean    : Fourth Non Centered Moment of the Matrix
*******************************************************************************/
float FourthOrderNonCenteredMatrixReal(float **MT, int Nlin, int Ncol)
{  
  int mm,nn;
  float MT_moment;
  
  MT_moment = 0.0;
  for(nn = 0; nn < Nlin; nn++)
    for(mm = 0; mm < Ncol; mm++)
      MT_moment += MT[nn][mm] * MT[nn][mm] * MT[nn][mm] * MT[nn][mm];
  MT_moment = MT_moment / (float) (Ncol * Nlin);
  
  return MT_moment;
}

/*************************/
/* HISTOGRAM CALCULATION */
/*************************/

/*******************************************************************************
Routine  : comp
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description : Auxiliary function for the computation of Histograms
*-------------------------------------------------------------------------------
*******************************************************************************/
int comp_float(const void *a, const void *b )
{
    float ai, bi;
    int result;
    
    ai = *((float *)a);
    bi = *((float *)b);
    result = 0;
    if (ai > bi) {
        result = 1;
    } else if (bi > ai) {
        result = -1;
    }
    return result;
}

/*******************************************************************************
Routine  : HistogramVectorReal
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the Histogram of a vector of floats
*-------------------------------------------------------------------------------
Inputs arguments :
MT      : Input Vector
Ncol    : Number of columns of MT
min_value  : Minimum value of the histogram
max_value  : Maximum value of the histogram
Nbin    : Number of bins of the histogram
Returned values  :
Xhist    : Vector of length Nbin with the centers of the bins
Yhist    : # Samples in the bin
*******************************************************************************/
void HistogramVectorReal(float *VC, int Ncol, float min_value, float max_value, int Nbin, float *Xhist, float *Yhist)
{
  float *Xlim;
  float delta,count;
  int mm,nn; 
  
  Xlim = vector_float(Nbin + 1);
  
  /* Creation of abcissa */
  delta = (max_value - min_value) / (float) Nbin;
  Xhist[0] = min_value + (delta / 2);
  Xlim[0]  = min_value;
  for (mm = 1; mm < Nbin; mm++){
    Xhist[mm] = Xhist[mm-1] + delta;
    Xlim[mm] = Xlim[mm-1] + delta;
  }
  Xlim[Nbin] = Xlim[Nbin-1] + delta;
  
  /* Sorting of the input */
  qsort(VC,Ncol,sizeof(float),comp_float);
  
  /* Generation of the histogram */
  nn = 0;
  while(VC[nn]<min_value)
    nn++;
  for(mm = 0; mm < Nbin; mm++){
    count = 0.0;
    while( (VC[nn]>=Xlim[mm]) & (VC[nn]<Xlim[mm+1])){
      count += 1.0;
      nn ++;
    }
    Yhist[mm] = count;
  }
}

/*******************************************************************************
Routine  : HistogramMatrixReal
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the Histogram of a Matrix of floats
*-------------------------------------------------------------------------------
Inputs arguments :
MT      : Input Matrix
Ncol    : Number of columns of MT
min_value  : Minimum value of the histogram
max_value  : Maximum value of the histogram
Nbin    : Number of bins of the histogram
Returned values  :
Xhist    : Vector of length Nbin with the centers of the bins
Yhist    : # Samples in the bin
*******************************************************************************/
void HistogramMatrixReal(float **MT, int Nlin, int Ncol, float min_value, float max_value, int Nbin, float *Xhist, float *Yhist)
{
  float *Xlim, *VC;
  float delta,count;
  int mm,nn; 
    
  Xlim = vector_float(Nbin + 1);
  VC  = vector_float(Nlin * Ncol);
  
  /* Transform the matrix into a vector */

  for (nn = 0; nn < Nlin; nn++)
    for (mm = 0; mm < Ncol; mm++)
      VC[nn*Ncol + mm] = MT[nn][mm];
    
  /* Creation of abcissa */
  delta = (max_value - min_value) / (float) Nbin;
  Xhist[0] = min_value + (delta / 2);
  Xlim[0]  = min_value;
  for (mm = 1; mm < Nbin; mm++){
    Xhist[mm] = Xhist[mm-1] + delta;
    Xlim[mm] = Xlim[mm-1] + delta;
  }
  Xlim[Nbin] = Xlim[Nbin-1] + delta;
  
  /* Sorting of the input */
  qsort(VC,Nlin*Ncol,sizeof(float),comp_float);
  
  /* Generation of the histogram */
  nn = 0;
  while(VC[nn]<min_value)
    nn++;
  for(mm = 0; mm < Nbin; mm++){
    count = 0.0;
    while( (VC[nn]>=Xlim[mm]) & (VC[nn]<Xlim[mm+1])){
      count += 1.0;
      nn ++;
    }
    Yhist[mm] = count;
  }
}

/*********************/
/* STATISTICAL TESTS */
/*********************/

/* CHI-SQUARE TEST */

/*******************************************************************************
Routine  : gammln
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Returns the value ln[Gamma(xx)] for xx > 0.
*-------------------------------------------------------------------------------
Numerical Recipes
*******************************************************************************/
float gammln(float xx)
{
  double x,y,tmp,ser;
  static double cof[6]={76.18009172947146,-86.50532032941677, 24.01409824083091,-1.231739572450155,0.1208650973866179e-2,-0.5395239384953e-5};
  int j;
  y  = xx;
  x  = xx;
  tmp  = x+5.5;
  tmp -= (x+0.5)*log(tmp);
  ser  = 1.000000000190015;
  for (j = 0; j<=5 ; j++)
    ser += cof[j]/++y;
  return -tmp+log(2.5066282746310005*ser/x);
}

/*******************************************************************************
Routine  : gser
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Returns the incomplete gamma function P(a, x) evaluated 
by its series representation as gamser.Also returns ln Gamma(a) as gln.
*-------------------------------------------------------------------------------
Numerical Recipes
******************************************************************************/
void gser(float *gamser, float a, float x, float *gln)
{
  float gammln(float xx);
  
  int nn;
  float sum,del,ap;
  
  *gln=gammln(a);
  if (x <= 0.0) {
    if (x < 0.0) edit_error("x less than 0 in routine gser","");
    *gamser=0.0;
    return;
  }
  else {
    ap  = a;
    del = 1.0/a;
    sum = 1.0/a;
    for (nn = 1; nn <= ITMAX; nn++) {
      ++ap;
      del *= x/ap;
      sum += del;
      if (fabs(del) < fabs(sum)*EPS) {
        *gamser=sum*exp(-x+a*log(x)-(*gln));
        return;
      }
    }
  edit_error("a too large, ITMAX too small in routine gser","");
  return;
  }
}

/*******************************************************************************
Routine  : gcf
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Returns the incomplete gamma function Q(a, x) evaluated by 
its continued fraction representation as gammcf. Also returns ln Gamma(a) as gln.
*-------------------------------------------------------------------------------
Numerical Recipes
******************************************************************************/
void gcf(float *gammcf, float a, float x, float *gln)
{
  float gammln(float xx);
  
  int i;
  float an,b,c,d,del,h;
  
  *gln = gammln(a);
  b  = x+1.0-a;
  c  = 1.0/FPMIN;
  d  = 1.0/b;
  h  = d;

  for (i = 1; i <= ITMAX; i++) { 
    an = -i*(i-a);
    b += 2.0;
    d  = an*d+b;
    if (fabs(d) < FPMIN) d=FPMIN;
      c = b+an/c;
    if (fabs(c) < FPMIN) c=FPMIN;
      d = 1.0/d;
    del = d*c;
    h  *= del;
    if (fabs(del-1.0) < EPS) break;
  }
  if (i > ITMAX) edit_error("a too large, ITMAX too small in gcf","");
  if (i > ITMAX) 
    *gammcf = 0.0; //Error control "a too large, ITMAX too small in gcf";
  else
    *gammcf = exp(-x+a*log(x)-(*gln))*h;
}

/*******************************************************************************
Routine  : gammap
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Returns the incomplete gamma function P(a, x)
*-------------------------------------------------------------------------------
Numerical Recipes
******************************************************************************/
float gammp(float a, float x)
{
 void gcf(float *gammcf, float a, float x, float *gln);
 void gser(float *gamser, float a, float x, float *gln);
 float gamser,gammcf,gln;

 if (x < 0.0 || a <= 0.0) edit_error("Invalid arguments in routine gammp","");
 if (x < (a+1.0))
 {
 /* Use the series representation.*/
 gser(&gamser,a,x,&gln);
  return gamser;
 }
 else
 {/* Use the continued fraction representation*/
  gcf(&gammcf,a,x,&gln);
  return 1.0-gammcf; /*and take its complement.*/
 }
}

/*******************************************************************************
Routine  : gammaq
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Returns the incomplete gamma function Q(a, x) = 1 - P(a, x).
*-------------------------------------------------------------------------------
Numerical Recipes
******************************************************************************/
float gammq(float a, float x)
{
  void gcf(float *gammcf, float a, float x, float *gln);
  void gser(float *gamser, float a, float x, float *gln);
  
  float gamser,gammcf,gln;

  if (x < 0.0 || a <= 0.0)  printf("Error \n"); //Error control 

  if (x < (a+1.0)) { /*Use the series representation*/
    gser(&gamser,a,x,&gln);
    return 1.0-gamser; 
  } 
  else{ /*Use the continued fraction representation*/
    gcf(&gammcf,a,x,&gln); 
    return gammcf;
  }
}

/*******************************************************************************
Routine  : chisq
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Given the array bins[1..nbins] containing the observed numbers of 
events, and an array ebins[1..nbins] containing the expected numbers of events, 
and given the number of constraints knstrn (normally one), this routine returns 
(trivially) the number of degrees of freedom df, and (nontrivially) 
the chi-square chsq and the signifcance prob. A small value of prob
indicates a signifcant diference between the distributions bins and ebins.
Note that bins and ebins are both float arrays, although bins will normally 
contain integer values.
*-------------------------------------------------------------------------------
Numerical Recipes
******************************************************************************/
void chisq(float *bins, float *ebins, int nbins, int knstrn, float *df, float *chsq, float *prob)
{
  float gammq(float a, float x);
  
  int mm;
  float temp;
  
  *df  = nbins-knstrn;
  *chsq = 0.0;
  for (mm = 0; mm <= nbins-1; mm++) {
    if (ebins[mm] > 0.0) {
      temp  = bins[mm]-ebins[mm];
      *chsq += temp*temp/ebins[mm];
    }
    else {
      temp  = bins[mm]-EPS;
      *chsq += temp*temp/EPS; 
    }
  }
  if (finite(*chsq))
    *prob = gammq(0.5*(*df),0.5*(*chsq));
  else {
    *prob = 0.0;
    *chsq = -1.0;
  }
}

/*******************************************************************************
Routine  : GaussHist
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Calculates the Gaussian PDF
*-------------------------------------------------------------------------------
Inputs arguments :
mean   : Mean
var     : Variance
Nsamples : Number of samples to which the PDF is calculated
Nbin   : Number of samples in abcissa
Xvalue   : Abcissas in which the PDF has to be calculated

Outputs arguments : 
ThHist  : Theoretical Distribution
******************************************************************************/
void GaussHist(float mean, float var, int Nsamples, int Nbin, float *Xvalue, float *ThHist)
{
  int mm;
  float cte,delta;
   
  cte = 1 / sqrt(2 * pi * var);
  for(mm = 0; mm < Nbin; mm++)
    ThHist[mm] = cte * exp ( (-.5) * (Xvalue[mm] - mean) * (Xvalue[mm] - mean) / var);
    
  /* PDF to Histogram */ 
  delta = Xvalue[1]-Xvalue[0];
  for(mm = 0; mm < Nbin; mm++)
    ThHist[mm] = ThHist[mm] * Nsamples * delta;
}

/*******************************************************************************
Routine  : ExpHist
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Calculates the Exponential PDF
*-------------------------------------------------------------------------------
Inputs arguments :
mean   : Mean
Nsamples : Number of samples to which the PDF is calculated
Nbin   : Number of samples in abcissa
Xvalue   : Abcissas in which the PDF has to be calculated

Outputs arguments : 
ThHist  : Theoretical Distribution
******************************************************************************/
void ExpHist(float mean, int Nsamples, int Nbin, float *Xvalue, float *ThHist)
{
  int mm;
  float delta;
  
  for(mm = 0; mm < Nbin; mm++){
    ThHist[mm] = ((1.0) / mean) * exp((-1.0) * Xvalue[mm] / mean);
  }
    
  /* PDF to Histogram */ 
  delta = Xvalue[1]-Xvalue[0];
  for(mm = 0; mm < Nbin; mm++)
    ThHist[mm] = ThHist[mm] * Nsamples * delta;
}

/*******************************************************************************
Routine  : RayHist
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Calculates the Rayleigh PDF
*-------------------------------------------------------------------------------
Inputs arguments :
mean   : Mean
Nsamples : Number of samples to which the PDF is calculated
Nbin   : Number of samples in abcissa
Xvalue   : Abcissas in which the PDF has to be calculated

Outputs arguments : 
ThHist  : Theoretical Distribution
******************************************************************************/
void RayHist(float mean, int Nsamples, int Nbin, float *Xvalue, float *ThHist)
{
  int mm;
  float delta;
  
  mean = (1.0 / pi) * (2.0 * mean) * (2.0 * mean);
  for(mm = 0; mm < Nbin; mm++)
    ThHist[mm] = (2.0 / mean) * Xvalue[mm] * exp(-1.0 * Xvalue[mm] * Xvalue[mm] / mean);
    
  /* PDF to Histogram */ 
  delta = Xvalue[1]-Xvalue[0];
  for(mm = 0; mm < Nbin; mm++)
    ThHist[mm] = ThHist[mm] * Nsamples * delta;
}

/*******************************************************************************
Routine  : UnifHist
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Calculates the Exponential PDF
*-------------------------------------------------------------------------------
Inputs arguments :
min_value: Minimum value od the distribution to test
max_value: Maximum value od the distribution to test
Nsamples : Number of samples to which the PDF is calculated
Nbin   : Number of samples in abcissa
Xvalue   : Abcissas in which the PDF has to be calculated

Outputs arguments : 
ThHist  : Theoretical Distribution
******************************************************************************/
void UnifHist(float min_value, float max_value, int Nsamples, int Nbin, float *Xvalue, float *ThHist)
{
  int mm;
  float delta;
  
  for(mm = 0; mm < Nbin; mm++)
    ThHist[mm] = 1 / (max_value-min_value);
    
  /* PDF to Histogram */ 
  delta = Xvalue[1]-Xvalue[0];
  for(mm = 0; mm < Nbin; mm++)
    ThHist[mm] = ThHist[mm] * Nsamples * delta;
}

/*******************************************************************************
Routine  : chisq_testVector
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  This function performs the Chi Square Test following diffent models

*-------------------------------------------------------------------------------
Inputs arguments :
VC      : Input vector of floats
Ncol    : Number of columns of VC
min_value : Minimum value od the distribution to test
max_value : Maximum value od the distribution to test
Nbin    : Number of bins to perform the Chi Square test
pdf_case  : PDF to test (0: Gaussian)

Outputs arguments : 
df    : Degrees of freedom
chsq  : The Chi Square value  
prob   : The probability that the data follows the proposed model
******************************************************************************/
void chisq_testVector(float *VC, int Ncol, float min_value, float max_value, int Nbin, int pdf_case, float *df, float *chsq, float *prob)
{
  float *XHist, *ExpDataHist, *ThDataHist;
  float p1,p2;

  XHist    = vector_float(Nbin);
  ExpDataHist = vector_float(Nbin);
  ThDataHist  = vector_float(Nbin);
  
  /* Calculation of the histogram of the experimental data */
  HistogramVectorReal(VC,Ncol,min_value,max_value,Nbin,XHist,ExpDataHist);
  
  /* Calculation of the histogram of the theoretical data */
  if (pdf_case == 0) { 
      /* Gaussian Case */
      p1 = MeanVectorReal(VC,Ncol);
      p2 = SecondOrderCenteredVectorReal(VC,Ncol);
      GaussHist(p1,p2,Ncol,Nbin,XHist,ThDataHist);
  }
  else if (pdf_case == 1){
      /* Exponential Case */
      /* Checks negative values */
      //if (min_value < 0) error
      p1 = MeanVectorReal(VC,Ncol);
      ExpHist(p1,Ncol,Nbin,XHist,ThDataHist);  
  }
  else if (pdf_case == 2){
      /* Rayleigh Case */
      //if (min_value < 0) error
      p1 = MeanVectorReal(VC,Ncol);
      RayHist(p1,Ncol,Nbin,XHist,ThDataHist);
  }
  else if (pdf_case == 3){
      /* Uniform Case */
      UnifHist(min_value,max_value,Ncol,Nbin,XHist,ThDataHist);
  }
  
  /* Makes the test */  
  chisq(ExpDataHist,ThDataHist,Nbin,1,df,chsq,prob);
}

/* KOLMOGOROV SMIRNOV TEST */

/*******************************************************************************
Routine  : probsks
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Kolmogorov - Smirnov Probability function.
*-------------------------------------------------------------------------------
Numerical Recipes
******************************************************************************/
float probks(float alam)
{
  int j;
  float a2,fac,sum,term,termbf;
  
  fac  = 2.0;
  sum  = 0.0;
  termbf = 0.0;
  a2   = -2.0 * alam * alam;
  for (j = 1; j <= 100; j++) {
    term = fac*exp(a2*j*j);
    sum += term;
    if (fabs(term) <= EPS1*termbf || fabs(term) <= EPS2*sum) return sum;
    fac  = -fac; 
    termbf = fabs(term);
  }
  return 1.0; 
}

/*******************************************************************************
Routine  : ksks
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description : Given an array data1[1..n1], and an array data2[1..n2], this routine 
returns the KS statistic d, and the signi.cance level prob for the null hypothesis 
that the data sets are drawn from the same distribution. Small values of prob show 
that the cumulative distribution function of data1 is signifcantly diferent
from that of data2. The arrays data1 and data2 are modified by being sorted into 
ascending order.
*-------------------------------------------------------------------------------
Numerical Recipes
******************************************************************************/
void ksks(float *data,float *xvalues, unsigned long nbins, float (*func)(float),float *d, float *prob)
{
  float probks(float alam);
  unsigned long j;
  float dt,en,ff;
  
  en = nbins;
  *d = 0.0;
  for(j = 0; j <= nbins-1; j++) { 
    
    ff = (*func)(xvalues[j]); 
    dt = fabs(ff-data[j]);
    
    if (dt > *d) *d = dt;
  }
  en  = sqrt(en);
  *prob = probks( (en + 0.12 + 0.11 / en) * (*d) ); 
}

/*******************************************************************************
Routine  : erf
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Calculates the Error Function
*-------------------------------------------------------------------------------
Inputs arguments :
x    : Abcissa where CDF is calculated

Outputs arguments : 
y    : Erf value
******************************************************************************/
float erff(float x)
{
  float gammp(float a, float x);

  return x < 0.0 ? gammq(0.5,x * x) - 1.0 : 1.0 - gammq(0.5,x * x);
}

/*******************************************************************************
Routine  : GaussCDF
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Calculates the Gaussian CDF
*-------------------------------------------------------------------------------
Inputs arguments :
x    : Abcissa where CDF is calculated

Outputs arguments : 
y    : CDF value
******************************************************************************/
float GaussCDF(float x)
{
  float y;
  
  y = 0.5 * (1.0 + erff(x / sqrt(2.0)) );
  return y;
}

/*******************************************************************************
Routine  : ExpCDF
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Calculates the Exponential CDF
*-------------------------------------------------------------------------------
Inputs arguments :
x    : Abcissa where CDF is calculated

Outputs arguments : 
y    : CDF value
******************************************************************************/
float ExpCDF(float x)
{
  float y;
  
  y = 1.0 - exp(-1.0 * x);
  return y;
}

/*******************************************************************************
Routine  : RayCDF
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Calculates the Exponential CDF
*-------------------------------------------------------------------------------
Inputs arguments :
x    : Abcissa where CDF is calculated

Outputs arguments : 
y    : CDF value
******************************************************************************/
float RayCDF(float x)
{
  float y;
  
  y = 1.0 - exp(- 1.0 * (pi / 4.0) * x * x);
  return y;
}

/*******************************************************************************
Routine  : UnifCDF
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Calculates the Uniform CDF between 0 and 1
*-------------------------------------------------------------------------------
Inputs arguments :
x    : Abcissa where CDF is calculated

Outputs arguments : 
y    : CDF value
******************************************************************************/
float UnifCDF(float x)
{
  return (x);
}

/*******************************************************************************
Routine  : ks_testVector
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description : This function performs the KS Test following diffent models

*-------------------------------------------------------------------------------
Inputs arguments :
VC      : Input vector of floats
Ncol    : Number of columns of VC
min_value : Minimum value of the distribution to test
max_value : Maximum value of the distribution to test
Nbin    : Number of bins to perform the Chi Square test
pdf_case  : PDF to test (0: Gaussian, 1: Exponential, 2: Rayleigh, 3:Uniform)

Outputs arguments : 
df    : Degrees of freedom
chsq  : The Chi Square value  
prob   : The probability that the data follows the proposed model
******************************************************************************/
void ks_testVector(float *VC, int Ncol, float min_value, float max_value, int Nbin, int pdf_case, float *d, float *prob)
{
  float *XHist, *ExpDataHist, *ExpDataHist_norm, *ExpDataCDF, *VC2;
  float p1,p2;
  int mm;
  XHist      = vector_float(Nbin);
  ExpDataHist    = vector_float(Nbin);
  ExpDataHist_norm = vector_float(Nbin);
  ExpDataCDF     = vector_float(Nbin);
  VC2        = vector_float(Ncol);

  /* Normalization of the data */
  if (pdf_case == 0) { 
    /* Gaussian Case */
    /* Normalization for mean equal to 0 and var equal to 1*/
    p1 = MeanVectorReal(VC,Ncol);
    p2 = SecondOrderCenteredVectorReal(VC,Ncol);
    for(mm = 0; mm < Ncol; mm++)
      VC2[mm] = (VC[mm] - p1) / sqrt(p2);
    
    /* Calculation of the histogram of the normalized experimental data */
    HistogramVectorReal(VC2,Ncol,-10.0,10.0,Nbin,XHist,ExpDataHist);
  }
  else if (pdf_case == 1){
    /* Exponential Case */
    /* Normalization for mean equal to 1*/
    p1 = MeanVectorReal(VC,Ncol);
    for(mm = 0; mm < Ncol; mm++)
      VC2[mm] = VC[mm] / p1;
      
    /* Calculation of the histogram of the normalized experimental data */
    HistogramVectorReal(VC2,Ncol,0.0,10.0,Nbin,XHist,ExpDataHist);
  }
  else if (pdf_case == 2){
    /* Rayleigh Case */
    /* Normalization */
    p1 = MeanVectorReal(VC,Ncol);
    for(mm = 0; mm < Ncol; mm++)
      VC2[mm] = VC[mm] / p1;
      
    /* Calculation of the histogram of the normalized experimental data */
    HistogramVectorReal(VC2,Ncol,0.0,10.0,Nbin,XHist,ExpDataHist);
  }
  else if (pdf_case == 3){
    /* Uniform Case */
    /* Normalization between 0 and 1 */
    for(mm = 0; mm < Ncol; mm++)
      VC2[mm] = (VC[mm] / (max_value-min_value)) + 0.5;
        
    /* Calculation of the histogram of the normalized experimental data */
    HistogramVectorReal(VC2,Ncol,0.0,1.0,Nbin,XHist,ExpDataHist);
  }
  
  /* Normalization of the Histogram */
  for(mm = 0; mm <Nbin; mm++)
    ExpDataHist_norm[mm] = ExpDataHist[mm] / Ncol;
        
  /* CDF */
  p1 = 0.0;
  for(mm = 0; mm <Nbin; mm++){
    p1 += ExpDataHist_norm[mm];
    ExpDataCDF[mm] = p1;
  }  
  
  /* Makes the Test */
  if (pdf_case == 0) { 
      /* Gaussian Case */
      ksks(ExpDataCDF,XHist,Nbin,GaussCDF,d,prob);
  }
  else if (pdf_case == 1){
      /* Exponential Case */
      
      /* Checks negative values */
      //if (min_value < 0) error
      
      /* Makes the test */  
      ksks(ExpDataCDF,XHist,Nbin,ExpCDF,d,prob);
  }
  else if (pdf_case == 2){
      /* Rayleigh Case */
      
      /* Checks negative values */
      //if (min_value < 0) error
      
      /* Makes the test */  
      ksks(ExpDataCDF,XHist,Nbin,RayCDF,d,prob);    
  }
  else if (pdf_case == 3){
      /* Uniform Case */
      /* Makes the test */  
      ksks(ExpDataCDF,XHist,Nbin,UnifCDF,d,prob);    
  }
}

/***********************/
/* AUXILIARY FUCNTIONS */
/***********************/

/*******************************************************************************
Routine  : AmplitudeComplex
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Creation : 06/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Calculates the amplitude of a complex number
*-------------------------------------------------------------------------------
Inputs arguments :
Re    : Input Real part
Im    : Input Imaginary part
Returned values  :
    : Amplitude
*******************************************************************************/

float AmplitudeComplex(float Re, float Im)
{
  return((float) sqrt((double) ((Re * Re) + (Im * Im)) ) );
}

/*******************************************************************************
Routine  : PhaseComplex
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Creation : 06/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Calculates the amplitude of a complex number
*-------------------------------------------------------------------------------
Inputs arguments :
Re    : Input Real part
Im    : Input Imaginary part
Returned values  :
    : Amplitude
*******************************************************************************/

float PhaseComplex(float Re, float Im)
{
  return((float) atan2((double) Im,(double) Re));
}
/*******************************************************************************
Routine  : CorrelationFactor
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Creation : 06/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Calculates the correlation factor with the Sxy elements
*-------------------------------------------------------------------------------
Inputs arguments :
S1_re  : Real part first component
S1_im  : Imaginary part first component
S2_re  : Real part second component
S2_im  : Imaginary part second component
Ncol  : Number of elements
Returned values:
rho_amp  : Amplitude of the correlation factor
rho_phase : Phase of te correlation factor 
*******************************************************************************/
void CorrelationFactor(float *S1_re, float *S1_im, float *S2_re, float *S2_im, float Ncol, float *rho_amp, float *rho_phase)
{
  float S1conjS2_re, S1conjS2_im, S1_power, S2_power, rho_re, rho_im;
  int elem;
  
  S1conjS2_re = 0.0;
  S1conjS2_im = 0.0;
  S1_power  = 0.0;
  S2_power  = 0.0;
  
  for (elem = 0; elem < Ncol; elem++){
    S1_power  += (S1_re[elem] * S1_re[elem]) + (S1_im[elem] * S1_im[elem]);
    S2_power  += (S2_re[elem] * S2_re[elem]) + (S2_im[elem] * S2_im[elem]);
    S1conjS2_re += (S1_re[elem] * S2_re[elem]) + (S1_im[elem] * S2_im[elem]);
    S1conjS2_im += (S1_im[elem] * S2_re[elem]) - (S1_re[elem] * S2_im[elem]);
  }
  rho_re   = S1conjS2_re / sqrt (S1_power * S2_power);
  rho_im   = S1conjS2_im / sqrt (S1_power * S2_power);
  *rho_amp  = AmplitudeComplex(rho_re,rho_im);
  *rho_phase = PhaseComplex(rho_re,rho_im);
}

/*******************************************************************************
Routine  : HistogramVectorRealNorm
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the Histogram of a vector of floats
*-------------------------------------------------------------------------------
Inputs arguments :
MT      : Input Vector
Ncol    : Number of columns of MT
min_value  : Minimum value of the histogram
max_value  : Maximum value of the histogram
Nbin    : Number of bins of the histogram
Returned values  :
Xhist    : Vector of length Nbin with the centers of the bins
Yhist    : # Samples in the bin
*******************************************************************************/
void HistogramVectorRealNorm(float *VC, int Ncol, float min_value, float max_value, int Nbin, float *Xhist, float *Yhist)
{
  float *Xlim;
  float delta,count;
  int mm,nn; 
  float maxhisto;
  
  Xlim = vector_float(Nbin + 1);
  
  /* Creation of abcissa */
  delta = (max_value - min_value) / (float) Nbin;
  Xhist[0] = min_value + (delta / 2);
  Xlim[0]  = min_value;
  for (mm = 1; mm < Nbin; mm++){
    Xhist[mm] = Xhist[mm-1] + delta;
    Xlim[mm] = Xlim[mm-1] + delta;
  }
  Xlim[Nbin] = Xlim[Nbin-1] + delta;
  
  /* Sorting of the input */
  qsort(VC,Ncol,sizeof(float),comp_float);
  
  /* Generation of the histogram */
  nn = 0;
  while(VC[nn]<min_value)
    nn++;
  for(mm = 0; mm < Nbin; mm++){
    count = 0.0;
    while( (VC[nn]>=Xlim[mm]) & (VC[nn]<Xlim[mm+1])){
      count += 1.0;
      nn ++;
    }
    Yhist[mm] = count;
  }
  
  maxhisto = -10000.00;
  for(nn = 0; nn < Nbin; nn++) 
    if (maxhisto <= Yhist[nn]) maxhisto = Yhist[nn];
  for(nn = 0; nn < Nbin; nn++) Yhist[nn] = Yhist[nn] / maxhisto;
  
}

/*******************************************************************************
Routine  : GaussHistNorm
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Calculates the Gaussian PDF
*-------------------------------------------------------------------------------
Inputs arguments :
mean   : Mean
var     : Variance
Nsamples : Number of samples to which the PDF is calculated
Nbin   : Number of samples in abcissa
Xvalue   : Abcissas in which the PDF has to be calculated

Outputs arguments : 
ThHist  : Theoretical Distribution
******************************************************************************/
void GaussHistNorm(float mean, float var, int Nsamples, int Nbin, float *Xvalue, float *ThHist)
{
  int mm,nn;
  float cte,delta;
  float maxhisto;
   
  cte = 1 / sqrt(2 * pi * var);
  for(mm = 0; mm < Nbin; mm++)
    ThHist[mm] = cte * exp ( (-.5) * (Xvalue[mm] - mean) * (Xvalue[mm] - mean) / var);
    
  /* PDF to Histogram */ 
  delta = Xvalue[1]-Xvalue[0];
  for(mm = 0; mm < Nbin; mm++)
    ThHist[mm] = ThHist[mm] * Nsamples * delta;
    
  maxhisto = -10000.00;
  for(nn = 0; nn < Nbin; nn++) 
    if (maxhisto <= ThHist[nn]) maxhisto = ThHist[nn];
  for(nn = 0; nn < Nbin; nn++) ThHist[nn] = ThHist[nn] / maxhisto;

}

/*******************************************************************************
Routine  : ExpHistNorm
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Calculates the Exponential PDF
*-------------------------------------------------------------------------------
Inputs arguments :
mean   : Mean
Nsamples : Number of samples to which the PDF is calculated
Nbin   : Number of samples in abcissa
Xvalue   : Abcissas in which the PDF has to be calculated

Outputs arguments : 
ThHist  : Theoretical Distribution
******************************************************************************/
void ExpHistNorm(float mean, int Nsamples, int Nbin, float *Xvalue, float *ThHist)
{
  int mm,nn;
  float delta;
  float maxhisto;
  
  for(mm = 0; mm < Nbin; mm++){
    ThHist[mm] = ((1.0) / mean) * exp((-1.0) * Xvalue[mm] / mean);
  }
    
  /* PDF to Histogram */ 
  delta = Xvalue[1]-Xvalue[0];
  for(mm = 0; mm < Nbin; mm++)
    ThHist[mm] = ThHist[mm] * Nsamples * delta;
    
  maxhisto = -10000.00;
  for(nn = 0; nn < Nbin; nn++) 
    if (maxhisto <= ThHist[nn]) maxhisto = ThHist[nn];
  for(nn = 0; nn < Nbin; nn++) ThHist[nn] = ThHist[nn] / maxhisto;

}

/*******************************************************************************
Routine  : RayHistNorm
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Calculates the Rayleigh PDF
*-------------------------------------------------------------------------------
Inputs arguments :
mean   : Mean
Nsamples : Number of samples to which the PDF is calculated
Nbin   : Number of samples in abcissa
Xvalue   : Abcissas in which the PDF has to be calculated

Outputs arguments : 
ThHist  : Theoretical Distribution
******************************************************************************/
void RayHistNorm(float mean, int Nsamples, int Nbin, float *Xvalue, float *ThHist)
{
  int mm,nn;
  float delta;
  float maxhisto;
  
  mean = (1.0 / pi) * (2.0 * mean) * (2.0 * mean);
  for(mm = 0; mm < Nbin; mm++)
    ThHist[mm] = (2.0 / mean) * Xvalue[mm] * exp(-1.0 * Xvalue[mm] * Xvalue[mm] / mean);
    
  /* PDF to Histogram */ 
  delta = Xvalue[1]-Xvalue[0];
  for(mm = 0; mm < Nbin; mm++)
    ThHist[mm] = ThHist[mm] * Nsamples * delta;

  maxhisto = -10000.00;
  for(nn = 0; nn < Nbin; nn++) 
    if (maxhisto <= ThHist[nn]) maxhisto = ThHist[nn];
  for(nn = 0; nn < Nbin; nn++) ThHist[nn] = ThHist[nn] / maxhisto;

}

/*******************************************************************************
Routine  : UnifHistNorm
Authors  : Carlos LOPEZ - MARTINEZ
Creation : 05/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Calculates the Exponential PDF
*-------------------------------------------------------------------------------
Inputs arguments :
min_value: Minimum value od the distribution to test
max_value: Maximum value od the distribution to test
Nsamples : Number of samples to which the PDF is calculated
Nbin   : Number of samples in abcissa
Xvalue   : Abcissas in which the PDF has to be calculated

Outputs arguments : 
ThHist  : Theoretical Distribution
******************************************************************************/
void UnifHistNorm(float min_value, float max_value, int Nsamples, int Nbin, float *Xvalue, float *ThHist)
{
  int mm,nn;
  float delta;
  float maxhisto;
  
  for(mm = 0; mm < Nbin; mm++)
    ThHist[mm] = 1 / (max_value-min_value);
    
  /* PDF to Histogram */ 
  delta = Xvalue[1]-Xvalue[0];
  for(mm = 0; mm < Nbin; mm++)
    ThHist[mm] = ThHist[mm] * Nsamples * delta;

  maxhisto = -10000.00;
  for(nn = 0; nn < Nbin; nn++) 
    if (maxhisto <= ThHist[nn]) maxhisto = ThHist[nn];
  for(nn = 0; nn < Nbin; nn++) ThHist[nn] = ThHist[nn] / maxhisto;

}
