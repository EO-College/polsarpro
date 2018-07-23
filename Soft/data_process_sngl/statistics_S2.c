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

File   : statistics_S2.c
Project  : ESA_POLSARPRO
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.1
Creation : 06/2005
Update  :
*--------------------------------------------------------------------
INSTITUT D'ELECTRONIQUE et de TELECOMMUNICATIONS de RENNES (I.E.T.R)
UMR CNRS 6164

Image and Remote Sensing Group
SAPHIR Team 
(SAr Polarimetry Holography Interferometry Radargrammetry)

UNIVERSITY OF RENNES I
Bât. 11D - Campus de Beaulieu
263 Avenue Général Leclerc
35042 RENNES Cedex
Tel :(+33) 2 23 23 57 63
Fax :(+33) 2 23 23 69 63
e-mail: eric.pottier@univ-rennes1.fr

*--------------------------------------------------------------------

Description :  Obtains the statistics of the matrix S2 for a given
               area

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* ALIASES  */
#define BINS 100
#define LIMTEST 10
#define LIMPLOT 4
#define EXP_RAY_MEAN_LIM 0.1

/* Real and Imaginary parts */
#define sre 0
#define sim 1
#define sab 2
#define sph 3

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
  char *S_Elements[4]    = {"S11","S12","S21","S22"};
  char *S_ElementsPP1[2]  = {"S11","S21"};
  char *S_ElementsPP2[2]  = {"S22","S12"};
  char *S_ElementsPP3[2]  = {"S11","S22"};
  char *S_Elements_part[4] = {"Real Part","Imaginary Part","Amplitude","Phase"};
  char *PDF_test[4]     = {"Gaussian","Exponential","Rayleigh","Uniform"};
    
  /* Temporal matrices */
  float *tmp_file, *tmp_elem, *tmp_elem2, *tmp_elem3, *tmp_elem4, **S2_hist, *Xhist, *Yhist, ***S2;

  /* Internal variables */
  int np, np2, col, ind, dt, st, Npolar_S, TypeData;
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
    edit_error("statistics_S2 file_data file_stat file_hist file_hist_label\n","");

  check_file(file_data);
  check_file(file_stat);
  check_file(file_hist);
  check_file(file_hist_label);
  
  /* Input/Output configurations */
  if ((in_file = fopen(file_stat, "r")) == NULL)
    edit_error("Could not open input file : ", file_stat);
  fscanf(in_file, "%i\n", &Ncol);
  fscanf(in_file, "%i\n", &TypeData); /* 0: full, 1: pp1, 2: pp2, 3: pp3 */
  fclose(in_file);

  /* Initialization of variables */
  if (TypeData == 0) Npolar_S = 4;
  else Npolar_S = 2;

  /* Matrix Declarations */
  tmp_file  = vector_float(2 * Npolar_S * Ncol);
  S2       = matrix3d_float(Npolar_S,4,Ncol);
  tmp_elem  = vector_float(Ncol);
  tmp_elem2 = vector_float(Ncol);
  tmp_elem3 = vector_float(Ncol);
  tmp_elem4 = vector_float(Ncol);
  Xhist    = vector_float(BINS);
  Yhist    = vector_float(BINS);
  S2_hist  = matrix_float((Npolar_S * 4) * 6,BINS);

  /* Input file opening & reading */
  if ((in_file = fopen(file_data, "rb")) == NULL)
    edit_error("Could not open input file : ", file_data);
  fread(&tmp_file[0], sizeof(float), 2 * Npolar_S * Ncol, in_file);
  
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
  for (np = 0; np < Npolar_S; np++){
    PrintfLine(np,Npolar_S);
    for (col = 0; col < Ncol; col++){
      ind = (np * 2 * Ncol) + 2 * col;
      S2[np][sre][col] = tmp_file[ind];
      S2[np][sim][col] = tmp_file[ind + 1];
      S2[np][sab][col] = AmplitudeComplex(S2[np][sre][col],S2[np][sim][col]);
      S2[np][sph][col] = PhaseComplex(S2[np][sre][col],S2[np][sim][col]);
    }
  }
    
  /*********************/
  /* STATS CALCULATION */
  /*********************/
  
  fprintf(out_file_hist_label,"%i \n",Npolar_S * 4 * 5); /* Number of labels*/

  if (TypeData == 0) fprintf(out_file_stat,"S2 MATRIX STATISTICS\n");
  else  fprintf(out_file_stat,"SPP MATRIX STATISTICS\n");
  fprintf(out_file_stat,"====================\n");
  fprintf(out_file_stat,"Number of samples: %i\n\n", Ncol);
  
  for (np = 0; np < Npolar_S; np++){ /* Elements of S2 */
    PrintfLine(np,Npolar_S);
    if (TypeData == 0) fprintf(out_file_stat,"Element %s\n",S_Elements[np]);
    if (TypeData == 1) fprintf(out_file_stat,"Element %s\n",S_ElementsPP1[np]);
    if (TypeData == 2) fprintf(out_file_stat,"Element %s\n",S_ElementsPP2[np]);
    if (TypeData == 3) fprintf(out_file_stat,"Element %s\n",S_ElementsPP3[np]);
    fprintf(out_file_stat,"===========\n");
    for (dt = 0; dt < 4; dt++){  
      fprintf(out_file_stat,"# %s\n",S_Elements_part[dt]);
      
      /* Selects the data to calculate */
      for(col = 0; col < Ncol; col++)
        tmp_elem[col] = S2[np][dt][col];
        
      /* Statistics Real, Imaginary, Amplitude and Phase components*/              
      tmp = MeanVectorReal(tmp_elem,Ncol);
      fprintf(out_file_stat," 1st order: Mean = %2.5f\n",tmp);
      tmp = SecondOrderCenteredVectorReal(tmp_elem,Ncol);
      maxmin = sqrt(tmp);
      fprintf(out_file_stat," 2st order: Variance = %2.5f\n",tmp);
      tmp = SecondOrderNonCenteredVectorReal(tmp_elem,Ncol);
      fprintf(out_file_stat," 2st order: Variance Power = %2.5f\n",tmp);
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
      
      for(col = 0;col < BINS; col++){
        S2_hist[(np * 4 + dt) * 6][col]   = Xhist[col];
        S2_hist[(np * 4 + dt) * 6 + 1][col] = Yhist[col];
      }
      
      /* Calculation of the Theoretical Histograms */
      tmp  = MeanVectorReal(tmp_elem,Ncol);             /* Mean */
      tmp2 = SecondOrderCenteredVectorReal(tmp_elem,Ncol);    /* Variance */
      
      GaussHistNorm(tmp,tmp2,Ncol,BINS,Xhist,Yhist);
      for(col = 0;col < BINS; col++)
        S2_hist[(np * 4 + dt) * 6 + 2][col] = Yhist[col];
      
      if (tmp < EXP_RAY_MEAN_LIM)
        ExpHistNorm(EXP_RAY_MEAN_LIM,Ncol,BINS,Xhist,Yhist);
      else
        ExpHistNorm(tmp,Ncol,BINS,Xhist,Yhist);
      for(col = 0;col < BINS; col++){
      if( finite(Yhist[col]) && Xhist[col] >0)
          S2_hist[(np * 4 + dt) * 6 + 3][col] = Yhist[col];
        else
          S2_hist[(np * 4 + dt) * 6 + 3][col] = 0.0;
      }
    
      if (tmp < EXP_RAY_MEAN_LIM)
        RayHistNorm(EXP_RAY_MEAN_LIM,Ncol,BINS,Xhist,Yhist);
      else
        RayHistNorm(tmp,Ncol,BINS,Xhist,Yhist);
      for(col = 0;col < BINS; col++){
        if( finite(Yhist[col]) && Xhist[col] >0)
          S2_hist[(np * 4 + dt) * 6 + 4][col] = Yhist[col];
        else
          S2_hist[(np * 4 + dt) * 6 + 4][col] = 0.0;
      }    
      if(dt==0 ||dt==1)
        UnifHistNorm(-1.0 * LIMPLOT * maxmin,LIMPLOT * maxmin,Ncol,BINS,Xhist,Yhist);
      else if (dt==2)
        UnifHistNorm(-1.0 * LIMPLOT * maxmin,LIMPLOT * maxmin,Ncol,BINS,Xhist,Yhist);
      else if (dt==3)
        UnifHist(-1.0 * pi,pi,Ncol,BINS,Xhist,Yhist);
      
      for(col = 0;col < BINS; col++)
        S2_hist[(np * 4 + dt) * 6 + 5][col] = Yhist[col];
      
      /* File of labels for the histogram */ 
      if (TypeData == 0) fprintf(out_file_hist_label,"%s %s\n",S_Elements[np],S_Elements_part[dt]);
      if (TypeData == 1) fprintf(out_file_hist_label,"%s %s\n",S_ElementsPP1[np],S_Elements_part[dt]);
      if (TypeData == 2) fprintf(out_file_hist_label,"%s %s\n",S_ElementsPP2[np],S_Elements_part[dt]);
      if (TypeData == 3) fprintf(out_file_hist_label,"%s %s\n",S_ElementsPP3[np],S_Elements_part[dt]);
      for (st = 0; st < 4; st++) {
        if (TypeData == 0) fprintf(out_file_hist_label,"%s %s (%s model)\n",S_Elements[np],S_Elements_part[dt],PDF_test[st]);
        if (TypeData == 1) fprintf(out_file_hist_label,"%s %s (%s model)\n",S_ElementsPP1[np],S_Elements_part[dt],PDF_test[st]);
        if (TypeData == 2) fprintf(out_file_hist_label,"%s %s (%s model)\n",S_ElementsPP2[np],S_Elements_part[dt],PDF_test[st]);
        if (TypeData == 3) fprintf(out_file_hist_label,"%s %s (%s model)\n",S_ElementsPP3[np],S_Elements_part[dt],PDF_test[st]);
      }
      
    }
    
  }
    
  /* Calculation of the coherence values */
  fprintf(out_file_stat,"Correlation Factors\n");
  fprintf(out_file_stat,"===================\n");
  
  for (np = 0; np < Npolar_S; np++){
    PrintfLine(np,Npolar_S);
    for(col = 0; col < Ncol; col++){
      tmp_elem[col]  = S2[np][sre][col];
      tmp_elem2[col] = S2[np][sim][col];
    }
    for (np2 = np; np2 < Npolar_S; np2++){
      for(col = 0; col < Ncol; col++){
        tmp_elem3[col] = S2[np2][sre][col];
        tmp_elem4[col] = S2[np2][sim][col];
      }
      CorrelationFactor(tmp_elem,tmp_elem2,tmp_elem3,tmp_elem4,Ncol,&tmp,&tmp2);
      if (TypeData == 0) fprintf(out_file_stat,"  %sconj(%s): ",S_Elements[np],S_Elements[np2]);
      if (TypeData == 1) fprintf(out_file_stat,"  %sconj(%s): ",S_ElementsPP1[np],S_ElementsPP1[np2]);
      if (TypeData == 2) fprintf(out_file_stat,"  %sconj(%s): ",S_ElementsPP2[np],S_ElementsPP2[np2]);
      if (TypeData == 3) fprintf(out_file_stat,"  %sconj(%s): ",S_ElementsPP3[np],S_ElementsPP3[np2]);
      fprintf(out_file_stat," Amplitude = %f, Phase(rad.) = %f\n",tmp,tmp2);
    }
  }
  
  /* Histograms files */
  for(col = 0; col < BINS; col++){
    for (np = 0; np < (Npolar_S * 4) ; np++){ /* Elements of S2 */
      fprintf(out_file_hist,"%f ",S2_hist[np * 6][col]);
      fprintf(out_file_hist,"%f ",S2_hist[np * 6 + 1][col]);
      fprintf(out_file_hist,"%f ",S2_hist[np * 6 + 2][col]);
      fprintf(out_file_hist,"%f ",S2_hist[np * 6 + 3][col]);
      fprintf(out_file_hist,"%f ",S2_hist[np * 6 + 4][col]);
      fprintf(out_file_hist,"%f ",S2_hist[np * 6 + 5][col]);
    }
    fprintf(out_file_hist,"\n");
  }
  
  /* Matrix closing */
  free_vector_float(tmp_file);
  free_matrix3d_float(S2,Npolar_S,4);
  free_vector_float(tmp_elem);
  free_vector_float(tmp_elem2);
  free_vector_float(tmp_elem3);
  free_vector_float(tmp_elem4);
  free_vector_float(Xhist);
  free_vector_float(Yhist);
  free_matrix_float(S2_hist,Npolar_S * 4 * 6);
  
  /* Files closinf */
  fclose(in_file);
  fclose(out_file_stat);
  fclose(out_file_hist);
  fclose(out_file_hist_label);
   return 1;
}


