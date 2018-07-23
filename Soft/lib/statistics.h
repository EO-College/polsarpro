/*******************************************************************************

	File	 : statistics.h
	Project  : ESA_POLSARPRO
	Authors  : Carlos LOPEZ MARTINEZ
	Version  : 1.1
	Creation : 06/2005
	Update	:

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
	Routines	:
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
void ksks(float data1[],float *xvalues, unsigned long nbins1, float data2[], unsigned long nbins2 ,float *d, float *prob);
void ks_testVector(float *VC, int Ncol, float min_value, float max_value, int Nbin, int pdf_case, float *d, float *prob);
float GaussCDF(float x);
float erff(float x);
float ExpCDF(float x);
float RayCDF(float x);
float UnifCDF(float x);

float AmplitudeComplex(float Re, float Im);
float PhaseComplex(float Re, float Im);
void CorrelationFactor(float *S1_re, float *S1_im, float *S2_re, float *S2_im, float Ncol, float *rho_amp, float *rho_phase);

*******************************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>


#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

#ifndef FlagStatistics
#define FlagStatistics

#include "PolSARproLib.h"
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
//void ksks(float data1[],float *xvalues, unsigned long nbins1, float data2[], unsigned long nbins2 ,float *d, float *prob);
void ksks(float *data,float *xvalues, unsigned long nbins, float (*func)(float),float *d, float *prob);
void ks_testVector(float *VC, int Ncol, float min_value, float max_value, int Nbin, int pdf_case, float *d, float *prob);
float GaussCDF(float x);
float erff(float x);
float ExpCDF(float x);
float RayCDF(float x);
float UnifCDF(float x);

float AmplitudeComplex(float Re, float Im);
float PhaseComplex(float Re, float Im);
void CorrelationFactor(float *S1_re, float *S1_im, float *S2_re, float *S2_im, float Ncol, float *rho_amp, float *rho_phase);

#endif
