/********************************************************************
PolSARpro v5.0 is free software; you can redistribute it and/or 
modify it under the terms of the GNU General Public License as 
published by the Free Software Foundation; either version 2 (1991) of
the License, or any later version. This program is distributed in the
hope that it will be useful, but WITHOUT ANY WARRANTY; without even 
the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE. 

See the GNU General Public License (Version 2, 1991) for more details

*********************************************************************

File   : statistics_C2.c
Project  : ESA_POLSARPRO
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.1
Creation : 06/2005
Update  :
*--------------------------------------------------------------------
INSTITUT D'ELECTRONIQUE et de TELECOMMUNICATIONS de RENNES (I.E.T.R)
UMR CNRS 6164

Waves and Signal department
SHINE Team 


UNIVERSITY OF RENNES I
Bât. 11D - Campus de Beaulieu
263 Avenue Général Leclerc
35042 RENNES Cedex
Tel :(+33) 2 23 23 57 63
Fax :(+33) 2 23 23 69 63
e-mail: eric.pottier@univ-rennes1.fr

*--------------------------------------------------------------------

Description :  Obtains the statistics of the matrix C2 for a given
               area

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "omp.h"

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* ALIASES  */
#define BINS 100
#define LIMTEST 10
#define LIMPLOT 4
#define EXP_RAY_MEAN_LIM 1e-5
#define DELTA_RHO 0.05

/* Real and Imaginary parts */
#define sre 0
#define sim 1
#define sab 2
#define sph 3

/* X matrix */
#define X11  0
#define X12  1
#define X22  2

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{
  /*******************/  
  /* LOCAL VARIABLES */
  /*******************/
  
  /* Input/Output file pointer arrays*/
  FILE *in_file;
  FILE *out_file_stat;
  FILE *out_file_hist;
  FILE *out_file_hist_label;
  

  char file_data[FilePathLength],file_stat[FilePathLength],file_hist[FilePathLength],file_hist_label[FilePathLength];
  char *X_Elements[4]      = {"C11","C12","C22","rho_12"};
  char *X_Elements_part[4] = {"Real Part","Imaginary Part","Amplitude","Phase"};
  char *PDF_test[4]        = {"Gaussian","Exponential","Rayleigh","Uniform"};
  int Elem_jump[3]         = {0,1,3};  
  int Elem_jump2[3]        = {0,6,30};  /* Jumps for Histograms */
   
  /* Temporal matrices */
  float *tmp_file, *tmp_elem, *tmp_elem2, *tmp_elem3, *tmp_elem4, **X2_hist, ***X2, *Xhist, *Yhist;

  /* Internal variables */
  int np, col, ind, dt, dt_ini, dt_fin, st, Npolar_X, Nelement_X, Rho_Factors, TypeData;
  float maxmin,tmp,tmp2,tmp3;

  /******************/
  /* PROGRAM STARTS */
  /******************/
  
  if (argc == 5){
    strcpy(file_data, argv[1]);
    strcpy(file_stat, argv[2]);
    strcpy(file_hist, argv[3]);
    strcpy(file_hist_label, argv[4]);
  } else
    edit_error("statistics_C2 file_data file_stat file_hist file_hist_label\n","");

  check_file(file_data);
  check_file(file_stat);
  check_file(file_hist);
  check_file(file_hist_label);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);
  
  /* Initialization of variables */
  Npolar_X    = 4;
  Nelement_X  = 3;  
  Rho_Factors = 1;

  /* Input/Output configurations */
  if ((in_file = fopen(file_stat, "r")) == NULL)
    edit_error("Could not open input file : ", file_stat);
  fscanf(in_file, "%i\n", &Ncol);
  fscanf(in_file, "%i\n", &TypeData); /* 0: C2 */
  fclose(in_file);

  /* Matrix Declarations */
  tmp_file  = vector_float(Npolar_X * Ncol);
  X2       = matrix3d_float(Nelement_X + Rho_Factors,4,Ncol); /* Includes also the correlation factors */
  tmp_elem  = vector_float(Ncol);
  tmp_elem2 = vector_float(Ncol);
  tmp_elem3 = vector_float(Ncol);
  tmp_elem4 = vector_float(Ncol);
  Xhist    = vector_float(BINS);
  Yhist    = vector_float(BINS);
  X2_hist  = matrix_float((2 + 1 * 4) * 6 + Rho_Factors * 8,BINS); /* Histograms of the elements & correlation Factors */


  /* Input file opening & reading */
  if ((in_file = fopen(file_data, "rb")) == NULL)
    edit_error("Could not open input file : ", file_data);
  fread(&tmp_file[0], sizeof(float), Npolar_X * Ncol, in_file);
  
  /* Output statistics file opening */
  if ((out_file_stat = fopen(file_stat, "wb")) == NULL)
    edit_error("Could not open input file : ", file_stat);
  
  /* Output histogram file opening */
  if ((out_file_hist = fopen(file_hist, "wb")) == NULL)
    edit_error("Could not open input file : ", file_hist);
    
  /* Output histogram labels file opening */
  if ((out_file_hist_label = fopen(file_hist_label, "wb")) == NULL)
    edit_error("Could not open input file : ", file_hist_label);
  
  /* Read Input Data */
  for (np = 0; np < Nelement_X; np++){
    PrintfLine(np,Nelement_X);
    if (np == 0 || np == 2){      /* Reads Diagonal Elements */
      for (col = 0; col < Ncol; col++){  
        ind = (Elem_jump[np] * Ncol) + col;
        X2[np][sab][col] = tmp_file[ind];
      }
    }
    else{
      for (col = 0; col < Ncol; col++){    /* Reads Off-diagonal Elements Real Part */
        ind = (Elem_jump[np] * Ncol) + col;
        X2[np][sre][col] = tmp_file[ind];
      }
      for (col = 0; col < Ncol; col++){    /* Reads Off-diagonal Elements Imaginary Part */
        ind = ((Elem_jump[np] + 1) * Ncol) + col;
        X2[np][sim][col] = tmp_file[ind];
        X2[np][sab][col] = AmplitudeComplex(X2[np][sre][col],X2[np][sim][col]);
        X2[np][sph][col] = PhaseComplex(X2[np][sre][col],X2[np][sim][col]);
      }
    }
  }

  /* Calculation of the correlation factors */
  
  /* Factor rho_12*/
  for (col = 0; col < Ncol; col++){
    PrintfLine(col,Ncol);
    tmp  = X2[X11][sab][col];
    tmp2 = X2[X22][sab][col];
    if ( (tmp>0) && (tmp2>0) ){
      X2[Nelement_X][sre][col] = X2[X12][sre][col] / ( sqrt(tmp * tmp2) );
      X2[Nelement_X][sim][col] = X2[X12][sim][col] / ( sqrt(tmp * tmp2) );
      X2[Nelement_X][sab][col] = AmplitudeComplex(X2[Nelement_X][sre][col],X2[Nelement_X][sim][col]);
      X2[Nelement_X][sph][col] = PhaseComplex(X2[Nelement_X][sre][col],X2[Nelement_X][sim][col]);
    }
    else{
      X2[Nelement_X][sre][col] = 0.;
      X2[Nelement_X][sim][col] = 0.;
      X2[Nelement_X][sab][col] = 0.;
      X2[Nelement_X][sph][col] = 0.;
    }
  }

  /*********************/
  /* STATS CALCULATION */
  /*********************/
  
  fprintf(out_file_hist_label,"%i \n",((2 + 1 * 4) * 5) + Rho_Factors * 4); /* Number of labels*/
  
  fprintf(out_file_stat,"C2 MATRIX STATISTICS\n");
  fprintf(out_file_stat,"====================\n");
  fprintf(out_file_stat,"Number of samples: %i\n\n", Ncol);
  
  /* Statisitical study of the elements of the matrices */
  for (np = 0; np < Nelement_X; np++){ 
    PrintfLine(np,Nelement_X + Rho_Factors);
    fprintf(out_file_stat,"Element %s\n",X_Elements[(TypeData * ( Nelement_X+Rho_Factors )) + np]);
    fprintf(out_file_stat,"==========\n");
    
    if (np == 0 || np == 2){  /* To differentiate the diagional elements */
      dt_ini = 2; dt_fin = 3;
    }
    else{
      dt_ini = 0; dt_fin = 4;
    }
        
    for (dt = dt_ini; dt < dt_fin; dt++){  
      fprintf(out_file_stat,"# %s\n",X_Elements_part[dt]);
      
      /* Selects the data to calculate */
      for(col = 0; col < Ncol; col++)
        tmp_elem[col] = X2[np][dt][col];
        
      /* Statistics Real, Imaginary, Amplitude and Phase components*/              
      tmp = MeanVectorReal(tmp_elem,Ncol);
      fprintf(out_file_stat," 1st order: Mean = %2.5f\n",tmp);
      tmp = SecondOrderCenteredVectorReal(tmp_elem,Ncol);
      maxmin = sqrt(tmp);
      fprintf(out_file_stat," 2st order: Variance = %2.5f\n",tmp);
      tmp = SecondOrderNonCenteredVectorReal(tmp_elem,Ncol);
      fprintf(out_file_stat," 2st order: Power = %2.5f\n",tmp);
      tmp = ThirdOrderCenteredVectorReal(tmp_elem,Ncol);
      fprintf(out_file_stat," 3rd order: Skewness = %2.5f\n",tmp);
      tmp = ThirdOrderNonCenteredVectorReal(tmp_elem,Ncol);
      fprintf(out_file_stat," 3rd order: Non Centered Skewness = %2.5f\n",tmp);
      tmp = FourthOrderCenteredVectorReal(tmp_elem,Ncol);
      fprintf(out_file_stat," 4rd order: Kurtosis = %2.5f\n",tmp);
      tmp = FourthOrderNonCenteredVectorReal(tmp_elem,Ncol);
      fprintf(out_file_stat," 4rd order: Non Centered Kurtosis = %2.5f\n",tmp);

      /* Statistical Tests */
      
      /* ChiSquate */
      fprintf(out_file_stat,"\n  ChiSquare Statistical Test:\n");
      for(st = 0; st < 4; st++){
        if(dt==0 ||dt==1){
          chisq_testVector(tmp_elem,Ncol,-1.0 * LIMTEST * maxmin,LIMTEST * maxmin,BINS,st,&tmp2,&tmp3,&tmp);
          fprintf(out_file_stat,"  %s: Significance = %2.5f, Deg. freedom = %2.0f, Chi-square = %e\n",PDF_test[st],tmp,tmp2,tmp3);
        }
        else if (dt==2){
          chisq_testVector(tmp_elem,Ncol,0,1 * LIMTEST * maxmin,BINS,st,&tmp2,&tmp3,&tmp);
          fprintf(out_file_stat,"  %s: Significance = %2.5f, Deg. freedom = %2.0f, Chi-square = %e\n",PDF_test[st],tmp,tmp2,tmp3);
        }
        else if (dt==3){
          chisq_testVector(tmp_elem,Ncol,-1.0 * pi,pi,BINS,st,&tmp2,&tmp3,&tmp);
          fprintf(out_file_stat,"  %s: Significance = %2.5f, Deg. freedom = %2.0f, Chi-square = %e\n",PDF_test[st],tmp,tmp2,tmp3);
        }  
      }  
      
      /* Kolmogorov-Smirnov */
      fprintf(out_file_stat,"\n  Kolmogorov-Smirnov Statistical Test:\n");
      for(st = 0; st < 4; st++){
        if(dt==0 ||dt==1){
          ks_testVector(tmp_elem,Ncol,-1.0 * LIMTEST * maxmin,LIMTEST * maxmin,BINS,st,&tmp2,&tmp);
          fprintf(out_file_stat,"  %s: Significance = %2.5f, K-S statistic = %2.5f\n",PDF_test[st],tmp,tmp2);
        }
        else if (dt==2){
          ks_testVector(tmp_elem,Ncol,0,LIMTEST * maxmin,BINS,st,&tmp2,&tmp);
          fprintf(out_file_stat,"  %s: Significance = %2.5f, K-S statistic = %2.5f\n",PDF_test[st],tmp,tmp2);
        }
        else if (dt==3){
          ks_testVector(tmp_elem,Ncol,-1.0 * pi,pi,BINS,st,&tmp2,&tmp);
          fprintf(out_file_stat,"  %s: Significance = %2.5f, K-S statistic = %2.5f\n",PDF_test[st],tmp,tmp2);
        }
      }
      fprintf(out_file_stat,"\n");
      
      /* Calculation of the Real Histogram */
      if(dt==0 ||dt==1){
        HistogramVectorRealNorm(tmp_elem,Ncol,-1.0 * LIMPLOT * maxmin,LIMPLOT * maxmin,BINS,Xhist,Yhist);
      }
      else if (dt==2){
        HistogramVectorRealNorm(tmp_elem,Ncol,0,LIMPLOT * maxmin,BINS,Xhist,Yhist);
      }
      else if (dt==3){
        HistogramVectorRealNorm(tmp_elem,Ncol,-1.0 * pi,pi,BINS,Xhist,Yhist);
      }
    
      if (np == 0 || np == 2)      /* Selects the indices for the diagonal and off-diagonal elements */
        ind = Elem_jump2[np];
      else
        ind = Elem_jump2[np] + dt * 6;
        
      for(col = 0;col < BINS; col++){
        X2_hist[ind][col]   = Xhist[col];
        X2_hist[ind + 1][col] = Yhist[col];
      }
      
      /* Calculation of the Theoretical Histograms */
      tmp  = MeanVectorReal(tmp_elem,Ncol);             /* Mean */
      tmp2 = SecondOrderCenteredVectorReal(tmp_elem,Ncol);    /* Variance */
      
      GaussHistNorm(tmp,tmp2,Ncol,BINS,Xhist,Yhist);
      for(col = 0;col < BINS; col++)
        X2_hist[ind + 2][col] = Yhist[col];
      
      if (tmp < EXP_RAY_MEAN_LIM)
        ExpHistNorm(EXP_RAY_MEAN_LIM,Ncol,BINS,Xhist,Yhist);
      else
        ExpHistNorm(tmp,Ncol,BINS,Xhist,Yhist);
      for(col = 0;col < BINS; col++){
      if( finite(Yhist[col]) && Xhist[col] > 0.0)
          X2_hist[ind + 3][col] = Yhist[col];
        else
          X2_hist[ind + 3][col] = 0.0;
      }
    
      if (tmp < EXP_RAY_MEAN_LIM)
        RayHistNorm(EXP_RAY_MEAN_LIM,Ncol,BINS,Xhist,Yhist);
      else
        RayHistNorm(tmp,Ncol,BINS,Xhist,Yhist);
      for(col = 0;col < BINS; col++){
        if( finite(Yhist[col]) && Xhist[col] > 0.0)
          X2_hist[ind + 4][col] = Yhist[col];
        else
          X2_hist[ind + 4][col] = 0.0;
      }    
      if(dt==0 ||dt==1)
        UnifHistNorm(-1.0 * LIMPLOT * maxmin,LIMPLOT * maxmin,Ncol,BINS,Xhist,Yhist);
      else if (dt==2)
        UnifHistNorm(-1.0 * LIMPLOT * maxmin,LIMPLOT * maxmin,Ncol,BINS,Xhist,Yhist);
      else if (dt==3)
        UnifHist(-1.0 * pi,pi,Ncol,BINS,Xhist,Yhist);
      
      for(col = 0;col < BINS; col++)
        X2_hist[ind + 5][col] = Yhist[col];
      /* File of labels for the histogram */ 
      fprintf(out_file_hist_label,"%s %s\n",X_Elements[(TypeData * ( Nelement_X+Rho_Factors )) + np],X_Elements_part[dt]);
      for (st = 0; st < 4; st++)
        fprintf(out_file_hist_label,"%s %s (%s model)\n",X_Elements[(TypeData * ( Nelement_X+Rho_Factors )) + np],X_Elements_part[dt],PDF_test[st]);
    }
  }
  
  /* Statisitical study of the correlation elements of the matrices */
  for (np = Nelement_X; np < Nelement_X + Rho_Factors; np++){ 
    PrintfLine(np,Nelement_X + Rho_Factors);
    fprintf(out_file_stat,"Correlation %s\n",X_Elements[(TypeData * ( Nelement_X+Rho_Factors )) + np]);
    fprintf(out_file_stat,"===============\n");
    
    for (dt = 0; dt < 4; dt++){  
      fprintf(out_file_stat,"# %s\n",X_Elements_part[dt]);
      
      /* Selects the data to calculate */
      for(col = 0; col < Ncol; col++){
        tmp_elem[col] = X2[np][dt][col];
      }
        
      /* Statistics Real, Imaginary, Amplitude and Phase components*/              
      tmp = MeanVectorReal(tmp_elem,Ncol);
      fprintf(out_file_stat," 1st order: Mean = %2.5f\n",tmp);
      tmp = SecondOrderCenteredVectorReal(tmp_elem,Ncol);
      maxmin = sqrt(tmp);
      fprintf(out_file_stat," 2st order: Variance = %2.5f\n",tmp);
      tmp = SecondOrderNonCenteredVectorReal(tmp_elem,Ncol);
      fprintf(out_file_stat," 2st order: Power = %2.5f\n",tmp);
      tmp = ThirdOrderCenteredVectorReal(tmp_elem,Ncol);
      fprintf(out_file_stat," 3rd order: Skewness = %2.5f\n",tmp);
      tmp = ThirdOrderNonCenteredVectorReal(tmp_elem,Ncol);
      fprintf(out_file_stat," 3rd order: Non Centered Skewness = %2.5f\n",tmp);
      tmp = FourthOrderCenteredVectorReal(tmp_elem,Ncol);
      fprintf(out_file_stat," 4rd order: Kurtosis = %2.5f\n",tmp);
      tmp = FourthOrderNonCenteredVectorReal(tmp_elem,Ncol);
      fprintf(out_file_stat," 4rd order: Non Centered Kurtosis = %2.5f\n",tmp);
      fprintf(out_file_stat,"\n");
      
      /* Calculation of the Real Histogram */
      if(dt==0 ||dt==1){
        HistogramVectorRealNorm(tmp_elem,Ncol,-1.0 * LIMPLOT * maxmin,LIMPLOT * maxmin,BINS,Xhist,Yhist);
      }
      else if (dt==2){
        HistogramVectorRealNorm(tmp_elem,Ncol,0.0,1.0 + DELTA_RHO,BINS,Xhist,Yhist);
      }
      else if (dt==3){
        HistogramVectorRealNorm(tmp_elem,Ncol,-1.0 * pi,pi,BINS,Xhist,Yhist);
      }
    
      ind = 6 * (2 + 1 * 4) + (np - Nelement_X) * 8 + dt * 2;
      
      for(col = 0;col < BINS; col++){
        X2_hist[ind][col]   = Xhist[col];
        X2_hist[ind + 1][col] = Yhist[col];
      }
      /* File of labels for the histogram */ 
      fprintf(out_file_hist_label,"%s %s\n",X_Elements[(TypeData * ( Nelement_X+Rho_Factors )) + np],X_Elements_part[dt]);
    }
  }

  /* Histograms files */
  for(col = 0; col < BINS; col++){
    ind = (2 + 1 * 4);
    for (np = 0; np < ind ; np++){ /* Elements of X2 */
      fprintf(out_file_hist,"%f ",X2_hist[np * 6][col]);
      fprintf(out_file_hist,"%f ",X2_hist[np * 6 + 1][col]);
      fprintf(out_file_hist,"%f ",X2_hist[np * 6 + 2][col]);
      fprintf(out_file_hist,"%f ",X2_hist[np * 6 + 3][col]);
      fprintf(out_file_hist,"%f ",X2_hist[np * 6 + 4][col]);
      fprintf(out_file_hist,"%f ",X2_hist[np * 6 + 5][col]);
    }
    ind = (2 + 1 * 4) * 6;
    for (np = 0; np < Rho_Factors ; np++){ /* Correlations */
      fprintf(out_file_hist,"%f ",X2_hist[ind + np * 8][col]);
      fprintf(out_file_hist,"%f ",X2_hist[ind + np * 8 + 1][col]);
      fprintf(out_file_hist,"%f ",X2_hist[ind + np * 8 + 2][col]);
      fprintf(out_file_hist,"%f ",X2_hist[ind + np * 8 + 3][col]);
      fprintf(out_file_hist,"%f ",X2_hist[ind + np * 8 + 4][col]);
      fprintf(out_file_hist,"%f ",X2_hist[ind + np * 8 + 5][col]);
      fprintf(out_file_hist,"%f ",X2_hist[ind + np * 8 + 6][col]);
      fprintf(out_file_hist,"%f ",X2_hist[ind + np * 8 + 7][col]);
    }
    fprintf(out_file_hist,"\n");
  }
  
  /* Matrix closing */
  free_vector_float(tmp_file);
  free_matrix3d_float(X2,Nelement_X + Rho_Factors,4);
  free_vector_float(tmp_elem);
  free_vector_float(tmp_elem2);
  free_vector_float(tmp_elem3);
  free_vector_float(tmp_elem4);
  free_vector_float(Xhist);
  free_vector_float(Yhist);
  free_matrix_float(X2_hist,6 * (2 + 1 * 4) + Rho_Factors * 8);
  
  /* Files closinf */
  fclose(in_file);
  fclose(out_file_stat);
  fclose(out_file_hist);
  fclose(out_file_hist_label);
   return 1;
}


