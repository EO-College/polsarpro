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

File   : create_cielab_file.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Authors  : Cheng-Yen CHIANG, Kun-Shan CHEN, Chih-Yuan CHU, 
           Yang-Lang CHANG and Kuo-Chin FAN
Version  : 1.0
Creation : 08/2018
Update  :
*--------------------------------------------------------------------
Cheng-Yen CHIANG, Kuo-Chin FAN
Department of Computer Science and Information Engineering, 
National Central University, Taoyuan City 32001, Taiwan

Kun-Shan CHEN
State Key Laboratory of Remote Sensing Science, 
Institute of Remote Sensing and Digital Earth,
Chinese Academy of Science, Beijing 100094, China

Kun-Shan CHEN
Department of Computer Sciences, University of California at Santa Barbara,
Santa Barbara, CA 93111, USA

Chih-Yuan CHU, Yang-Lang CHANG
Department of Electrical Engineering, 
National Taipei University of Technology, Taipei 10608, Taiwan;
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

Description :  Creation of a CIE-LAB RGB BMP file from 4 binary files

Publication : 
Color Enhancement for Four-Component Decomposed Polarimetric SAR Image
Based on a CIE-Lab Encoding
Cheng-Yen CHIANG, Kun-Shan CHEN, Chih-Yuan CHU, Yang-Lang CHANG
and Kuo-Chin FAN
Remote Sensing, MDPI, 2018, 10, 545; doi:10.3390/rs10040545

This PolSARpro software is based on the source code provided by
Cheng-Yen CHIANG

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"

//+------------------------------------------------------------------+
//|                                                                  |
//|                         STRUCTURE                                |
//|                                                                  |
//+------------------------------------------------------------------+
//Authors  : Cheng-Yen CHIANG, Kun-Shan CHEN, Chih-Yuan CHU, 
//           Yang-Lang CHANG and Kuo-Chin FAN

typedef struct {
  float R[3], G[3], B[3];
  float RefWhiteRGB[3];
  float Gamma;
  float MtxRGB2XYZ[9], MtxXYZ2RGB[9];
} RGBModel;

typedef struct {
  float MtxAdaptMa[9];
  float AdaptationIndex;
  float MtxAdaptMaI[9];
} Adaptation;

//+------------------------------------------------------------------+
//|                                                                  |
//|                         SUBROUTINES                              |
//|                                                                  |
//+------------------------------------------------------------------+
//Authors  : Cheng-Yen CHIANG, Kun-Shan CHEN, Chih-Yuan CHU, 
//           Yang-Lang CHANG and Kuo-Chin FAN
void FindMinMax(const float* data, const long N, float* min, float* max){
  *min =  99999999;
  *max = -99999999;
  
  for(long i=0;i<N;++i){
    if(data[i] < *min){ *min = data[i]; }
    if(data[i] > *max){ *max = data[i]; }
  }
}

/********************************************************************
Authors  : Cheng-Yen CHIANG, Kun-Shan CHEN, Chih-Yuan CHU, 
           Yang-Lang CHANG and Kuo-Chin FAN
*********************************************************************/
void HistogramCalc(const long Nbins, const long N, const float* data, long** hist, float** idx){
  // Find Min & Max
  float min, max;
  FindMinMax(data, N, &min, &max);
  
  // reset to zero
  for(long i=0; i<Nbins; ++i){
    (*hist)[i] = 0;
  }
  
  // bin width
  float d = (max - min)/((float)Nbins - 1);
  
  // make index series
  for(long i=0; i<Nbins; ++i){
    (*idx)[i] = (float)i * d + min;
  }
  
  // Scan for each pixel
  for(long i=0; i<N; ++i){
    // Find which bin(index) needs to to count.
    float k = round((data[i] - d/2 - min) / d);  // same as IDL
    if(k < 0){ k = 0; }
    (*hist)[(long)k]++;
  }
}

/********************************************************************
Authors  : Cheng-Yen CHIANG, Kun-Shan CHEN, Chih-Yuan CHU, 
           Yang-Lang CHANG and Kuo-Chin FAN
*********************************************************************/
double total(const long* hist, const long Nbins){
  // Get total
  double sum = 0;
  for(long i=0;i<Nbins;++i){
    sum += hist[i];
  }
  return sum;
}

/********************************************************************
Authors  : Cheng-Yen CHIANG, Kun-Shan CHEN, Chih-Yuan CHU, 
           Yang-Lang CHANG and Kuo-Chin FAN
*********************************************************************/
long FindNearestIndex(const double* cum, const long Nbins, const double value){
  double diff, d = 99999999999;
  long idx = 0;
  for(long i=0;i<Nbins;++i){
    diff = fabs(cum[i] - value);
    if(diff < d){
      idx = i;
      d = diff;
    }
  }
  return idx;
}

/********************************************************************
Authors  : Cheng-Yen CHIANG, Kun-Shan CHEN, Chih-Yuan CHU, 
           Yang-Lang CHANG and Kuo-Chin FAN
*********************************************************************/
void GetHistogramBoundary(float** array, const long N, const float truncate_percent, const long NBINS,  // input
              float* min_val, float* max_val, int SHOW){                  // output
  // Get histogram
  long* hist;
  float* idx;
  
  // Memory allocate
  hist = (long*)malloc(NBINS * sizeof(long));
  if(hist == NULL){
    printf("GetHistogramBoundary::ERROR:Memory allocation 'hist' fail.\n");
    exit(EXIT_FAILURE);
  }
  
  idx = (float*)malloc(NBINS * sizeof(float));
  if(idx == NULL){
    printf("GetHistogramBoundary::ERROR:Memory allocation 'idx' fail.\n");
    exit(EXIT_FAILURE);
  }
  
  HistogramCalc(NBINS, N, *array, &hist, &idx);

  // Calculate cumulate density function
  double sum = total(hist, NBINS);
  double* cum = (double*)malloc(NBINS * sizeof(double));
  for(long i=0;i<NBINS;++i){
    cum[i] = hist[i] / sum;
  }
  for(long i=1;i<NBINS;++i){
    cum[i] += cum[i-1];
  }
  
  // Find boundary
  long idx_min = FindNearestIndex(cum, NBINS, truncate_percent/100.);
  long idx_max = FindNearestIndex(cum, NBINS, (100.-truncate_percent)/100.);
  *min_val = idx[idx_min];
  *max_val = idx[idx_max];
  
  if(SHOW != 0){
    printf("======================================\n");
    printf(" In %f%% truncated : \n", truncate_percent);
    printf("     Minimum value = %f\n", *min_val);
    printf("     Maximum value = %f\n", *max_val);
  }
 
  free(hist);
  free(idx);
  free(cum);
}

/********************************************************************
Authors  : Cheng-Yen CHIANG, Kun-Shan CHEN, Chih-Yuan CHU, 
           Yang-Lang CHANG and Kuo-Chin FAN
*********************************************************************/
float Max(const float v1, const float v2, const float v3, const float v4){
  float val = v1;
  if(v2 > val){ val = v2; }
  if(v3 > val){ val = v3; }
  if(v4 > val){ val = v4; }
  return val;
}

/********************************************************************
Authors  : Cheng-Yen CHIANG, Kun-Shan CHEN, Chih-Yuan CHU, 
           Yang-Lang CHANG and Kuo-Chin FAN
*********************************************************************/
float Max3(const float v1, const float v2, const float v3){
  float val = v1;
  if(v2 > val){ val = v2; }
  if(v3 > val){ val = v3; }
  return val;
}

/********************************************************************
Authors  : Cheng-Yen CHIANG, Kun-Shan CHEN, Chih-Yuan CHU, 
           Yang-Lang CHANG and Kuo-Chin FAN
*********************************************************************/
float Min3(const float v1, const float v2, const float v3){
  float val = v1;
  if(v2 < val){ val = v2; }
  if(v3 < val){ val = v3; }
  return val;
}

/********************************************************************
Authors  : Cheng-Yen CHIANG, Kun-Shan CHEN, Chih-Yuan CHU, 
           Yang-Lang CHANG and Kuo-Chin FAN
*********************************************************************/
void Scale(const float* in, const long N, const float min_val, const float max_val, float** out){
  float min_in, max_in;
  FindMinMax(in, N, &min_in, &max_in);
  
  for(long i=0;i<N;++i){
    (*out)[i] = (max_val-min_val)/(max_in-min_in) * (in[i]-min_in) + min_val;
  }
}

/********************************************************************
Authors  : Cheng-Yen CHIANG, Kun-Shan CHEN, Chih-Yuan CHU, 
           Yang-Lang CHANG and Kuo-Chin FAN
*********************************************************************/
float deg2rad(const float deg){
  return deg/180. * pi;
}

/********************************************************************
Authors  : Cheng-Yen CHIANG, Kun-Shan CHEN, Chih-Yuan CHU, 
           Yang-Lang CHANG and Kuo-Chin FAN
*********************************************************************/
void Invert(const float in[9], float out[9]){
  // computes the inverse of a matrix in
  double det = in[0] * (in[4] * in[8] - in[5] * in[7]) -
  in[3] * (in[1] * in[8] - in[7] * in[2]) +
  in[6] * (in[1] * in[5] - in[4] * in[2]);
  
  double invdet = 1 / det;
  
  out[0] = (in[4] * in[8] - in[5] * in[7]) * invdet;
  out[3] = (in[6] * in[5] - in[3] * in[8]) * invdet;
  out[6] = (in[3] * in[7] - in[6] * in[4]) * invdet;
  out[1] = (in[7] * in[2] - in[1] * in[8]) * invdet;
  out[4] = (in[0] * in[8] - in[6] * in[2]) * invdet;
  out[7] = (in[1] * in[6] - in[0] * in[7]) * invdet;
  out[2] = (in[1] * in[5] - in[2] * in[4]) * invdet;
  out[5] = (in[2] * in[3] - in[0] * in[5]) * invdet;
  out[8] = (in[0] * in[4] - in[1] * in[3]) * invdet;
}

/********************************************************************
Authors  : Cheng-Yen CHIANG, Kun-Shan CHEN, Chih-Yuan CHU, 
           Yang-Lang CHANG and Kuo-Chin FAN
*********************************************************************/
void MatrixMultiply(const float M[9], const float v[3], float o[3]){
  o[0] = M[0]*v[0] + M[1]*v[1] + M[2]*v[2];
  o[1] = M[3]*v[0] + M[4]*v[1] + M[5]*v[2];
  o[2] = M[6]*v[0] + M[7]*v[1] + M[8]*v[2];
}

/********************************************************************
Authors  : Cheng-Yen CHIANG, Kun-Shan CHEN, Chih-Yuan CHU, 
           Yang-Lang CHANG and Kuo-Chin FAN
*********************************************************************/
void MatrixMultiply2(const float M[9], const float v0, const float v1, const float v2,
           float* o0, float* o1, float* o2){
  *o0 = M[0]*v0 + M[1]*v1 + M[2]*v2;
  *o1 = M[3]*v0 + M[4]*v1 + M[5]*v2;
  *o2 = M[6]*v0 + M[7]*v1 + M[8]*v2;
}

/********************************************************************
Authors  : Cheng-Yen CHIANG, Kun-Shan CHEN, Chih-Yuan CHU, 
           Yang-Lang CHANG and Kuo-Chin FAN
*********************************************************************/
void GetRGBModel_CIERGB(RGBModel* M){
  M->R[0] = 0.735; M->R[1] = 0.265; M->R[2] = 1 - M->R[0] - M->R[1];
  M->G[0] = 0.274; M->G[1] = 0.717; M->G[2] = 1 - M->G[0] - M->G[1];
  M->B[0] = 0.167; M->B[1] = 0.009; M->B[2] = 1 - M->B[0] - M->B[1];
  M->RefWhiteRGB[0] = 1; M->RefWhiteRGB[1] = 1; M->RefWhiteRGB[2] = 1;
  M->Gamma =  2.2;
  
  float m[9], mi[9];
  m[0] = M->R[0]/M->R[1]; m[1] = M->G[0]/M->G[1]; m[2] = M->B[0]/M->B[1];
  m[3] = M->R[1]/M->R[1]; m[4] = M->G[1]/M->G[1]; m[5] = M->B[1]/M->B[1];
  m[6] = M->R[2]/M->R[1]; m[7] = M->G[2]/M->G[1]; m[8] = M->B[2]/M->B[1];
  
  Invert(m, mi);
  float srgb[3];
  MatrixMultiply(mi, M->RefWhiteRGB, srgb);

  for(int j=0;j<3;++j){
    for(int i=0;i<3;++i){
      M->MtxRGB2XYZ[j*3+i] = srgb[i] * m[j*3+i];
    }
  }
  
  Invert(M->MtxRGB2XYZ, M->MtxXYZ2RGB);
}

/********************************************************************
Authors  : Cheng-Yen CHIANG, Kun-Shan CHEN, Chih-Yuan CHU, 
           Yang-Lang CHANG and Kuo-Chin FAN
*********************************************************************/
void GetRefWhite_D50(float RefWhite[3]){
  RefWhite[0] = 0.96422;
  RefWhite[1] = 1;
  RefWhite[2] = 0.82521;
}

/********************************************************************
Authors  : Cheng-Yen CHIANG, Kun-Shan CHEN, Chih-Yuan CHU, 
           Yang-Lang CHANG and Kuo-Chin FAN
*********************************************************************/
void GetAdaptation_Bradford(Adaptation* A){
  A->MtxAdaptMa[0] =  0.8951; A->MtxAdaptMa[3] = -0.7502; A->MtxAdaptMa[6] =  0.0389;
  A->MtxAdaptMa[1] =  0.2664; A->MtxAdaptMa[4] =  1.7135; A->MtxAdaptMa[7] = -0.0685;
  A->MtxAdaptMa[2] = -0.1614; A->MtxAdaptMa[5] =  0.0367; A->MtxAdaptMa[8] =  1.0296;
  A->AdaptationIndex = 0;
  // Invert 3x3 matrix
  Invert(A->MtxAdaptMa, A->MtxAdaptMaI);
}

/********************************************************************
Authors  : Cheng-Yen CHIANG, Kun-Shan CHEN, Chih-Yuan CHU, 
           Yang-Lang CHANG and Kuo-Chin FAN
*********************************************************************/
float Cubed(const float in){
  return in*in*in;
}

/********************************************************************
Authors  : Cheng-Yen CHIANG, Kun-Shan CHEN, Chih-Yuan CHU, 
           Yang-Lang CHANG and Kuo-Chin FAN
*********************************************************************/
void Lab2XYZ(const float Lab[3], const float RefWhite[3], float XYZ[3]){
  float kE = 216. / 24389.;
  float kK = 24389 / 27.;
  float kKE = 8;
  float fxyz[3], fx3, fz3;
  
  fxyz[1] = (Lab[0] + 16.)/116.;
  fxyz[0] = 0.002 * Lab[1] + fxyz[1];
  fxyz[2] = fxyz[1] - 0.005 * Lab[2];
  
  fx3 = Cubed(fxyz[0]);
  fz3 = Cubed(fxyz[2]);
  
  XYZ[0] = (fx3 > kE)? fx3 : ((116. * fxyz[0] - 16.) / kK);
  XYZ[1] = (Lab[0] > kKE)? Cubed((Lab[0] + 16.) / 116.) : (Lab[0] / kK);
  XYZ[2] = (fz3 > kE)? fz3 : ((116. * fxyz[2] - 16.) / kK);
  
  XYZ[0] *= RefWhite[0];
  XYZ[1] *= RefWhite[1];
  XYZ[2] *= RefWhite[2];
}

/********************************************************************
Authors  : Cheng-Yen CHIANG, Kun-Shan CHEN, Chih-Yuan CHU, 
           Yang-Lang CHANG and Kuo-Chin FAN
*********************************************************************/
void RGBLinear2NonLinear(const float RGB[3], const float Gamma,  float compRGB[3]){
  // Convert from linear to non-linear RGB
  float R = RGB[0];
  float G = RGB[1];
  float B = RGB[2];
  
  if(Gamma > 0){
    R = (R > 1)? 1:R; R = (R < 0)? 0:R;
    G = (G > 1)? 1:G; G = (G < 0)? 0:G;
    B = (B > 1)? 1:B; B = (B < 0)? 0:B;
    
    compRGB[0] = pow(R, 1./Gamma);
    compRGB[1] = pow(G, 1./Gamma);
    compRGB[2] = pow(B, 1./Gamma);
    }else{
    // Change negtive to positive
    
    float sR, sG, sB;
    
    sR = (RGB[0] < 0)? -1:1;
    sG = (RGB[1] < 0)? -1:1;
    sB = (RGB[2] < 0)? -1:1;
    compRGB[0] = sR * RGB[0];
    compRGB[1] = sG * RGB[1];
    compRGB[2] = sB * RGB[2];
    
    if(Gamma < 0){
      // sRGB
      // R
      if(compRGB[0] < 0.0031308){
        compRGB[0] *= 12.92;
      }else{
        compRGB[0] = 1.055 * powf(compRGB[0], (1/2.4) - 0.055);
      }
      // G
      if(compRGB[1] < 0.0031308){
        compRGB[1] *= 12.92;
      }else{
        compRGB[1] = 1.055 * powf(compRGB[1], (1/2.4) - 0.055);
      }
      // B
      if(compRGB[2] < 0.0031308){
        compRGB[2] *= 12.92;
      }else{
        compRGB[2] = 1.055 * powf(compRGB[2], (1/2.4) - 0.055);
      }
    }else{
      // L*
      // R
      if(compRGB[0] < (216./24389.)){
        compRGB[0] = compRGB[0] * 24389./2700.;
      }else{
        compRGB[0] = 1.16 * powf(compRGB[0], (1/3.) - 0.16);
      }
      // G
      if(compRGB[1] < (216./24389.)){
        compRGB[1] = compRGB[1] * 24389./2700.;
      }else{
        compRGB[1] = 1.16 * powf(compRGB[1], (1/3.) - 0.16);
      }
      // B
      if(compRGB[2] < (216./24389.)){
        compRGB[2] = compRGB[2] * 24389./2700.;
      }else{
        compRGB[2] = 1.16 * powf(compRGB[2], (1/3.) - 0.16);
      }
      // sign back
      compRGB[0] *= sR;
      compRGB[1] *= sG;
      compRGB[2] *= sB;
    }
  }
}

/********************************************************************
Authors  : Cheng-Yen CHIANG, Kun-Shan CHEN, Chih-Yuan CHU, 
           Yang-Lang CHANG and Kuo-Chin FAN
*********************************************************************/
void XYZ2RGB(const float XYZ[3], const RGBModel* M, const float RefWhite[3], const Adaptation* A,  float RGB[3]){                    // output
  float s[3], d[3];
  float rgb[3];
  
  float xyz[3];
  
  if(A->AdaptationIndex != 3){
    MatrixMultiply(A->MtxAdaptMa, RefWhite, s);
    MatrixMultiply(A->MtxAdaptMa, M->RefWhiteRGB, d);
    
    MatrixMultiply(A->MtxAdaptMa, XYZ, rgb);
    rgb[0] *= (d[0]/s[0]); rgb[1] *= (d[1]/s[1]); rgb[2] *= (d[2]/s[2]);
    MatrixMultiply(A->MtxAdaptMaI, rgb, xyz);
  }else{
    printf("ERROR::XYZ2RGB:AdaptationIndex == 3 is not support\n");
    exit(EXIT_FAILURE);
  }
  
  MatrixMultiply(M->MtxXYZ2RGB, xyz, rgb);
  RGBLinear2NonLinear(rgb, M->Gamma, RGB);
}

/********************************************************************
Authors  : Cheng-Yen CHIANG, Kun-Shan CHEN, Chih-Yuan CHU, 
           Yang-Lang CHANG and Kuo-Chin FAN
*********************************************************************/
void Lab2RGB(const float Lab[3], const RGBModel* M, const float RefWhite[3], const Adaptation* A, float RGB[3]){
  float XYZ[3];
  Lab2XYZ(Lab, RefWhite, XYZ);
  XYZ2RGB(XYZ, M, RefWhite, A, RGB);
}
  
/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{

/* LOCAL VARIABLES */
  FILE *filebmp;
  FILE *file_Dbl, *file_Odd, *file_Vol, *file_Hlx;
  char DblFileInput[FilePathLength], OddFileInput[FilePathLength];
  char VolFileInput[FilePathLength], HlxFileInput[FilePathLength];
  char FileOutput[FilePathLength];
  
/* Internal variables */
  int lig, col, l;
  long NBINS = 32768;
  float truncate_percent_L, truncate_percent_ab;
  float A_min = -128;
  float A_max =  127;
  float B_min = -128;
  float B_max =  127;
  float Ps_max, Pd_max, Pv_max, Pc_max;
  float rg_L_min, rg_L_max, rg_ab_min, rg_ab_max;
  float LRg, LMin, LMax, max_val, TpTot;
  float RefWhite[3], lab[3], rgb[3];

/* Matrix arrays */
  float *ValidMask;
  float *Pd, *Ps, *Pv, *Pc, *Tp;
  char *dataimg;
    
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncreate_cielab_file.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-ifo 	input binary file: odd channel\n");
strcat(UsageHelp," (string)	-ifd 	input binary file: dbl channel\n");
strcat(UsageHelp," (string)	-ifv 	input binary file: vol channel\n");
strcat(UsageHelp," (string)	-ifh 	input binary file: hlx channel\n");
strcat(UsageHelp," (string)	-of  	output CIE RGB BMP file\n");
strcat(UsageHelp," (int)   	-inr 	Initial Number of Row\n");
strcat(UsageHelp," (int)   	-inc 	Initial Number of Col\n");
strcat(UsageHelp," (float) 	-lv  	Truncated value in percent for L-axis, default = 0.01\n");
strcat(UsageHelp," (float) 	-lab 	Truncated value in percent for ab-plane, default = 15.0\n");
strcat(UsageHelp," (int)   	-bin 	Number of bin for histogram calculation, default = 32768\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
strcat(UsageHelp," (string)	-errf	memory error file\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }
  
if(argc < 21) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-ifo",str_cmd_prm,OddFileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifd",str_cmd_prm,DblFileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifv",str_cmd_prm,VolFileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifh",str_cmd_prm,HlxFileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-inr",int_cmd_prm,&Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-inc",int_cmd_prm,&Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-lv",flt_cmd_prm,&truncate_percent_L,1,UsageHelp);
  get_commandline_prm(argc,argv,"-lab",flt_cmd_prm,&truncate_percent_ab,1,UsageHelp);
  get_commandline_prm(argc,argv,"-bin",int_cmd_prm,&NBINS,1,UsageHelp);

  get_commandline_prm(argc,argv,"-errf",str_cmd_prm,file_memerr,0,UsageHelp);

  MemoryAlloc = -1; MemoryAlloc = CheckFreeMemory();
  MemoryAlloc = my_max(MemoryAlloc,1000);

  FlagValid = 0;strcpy(file_valid,"");
  get_commandline_prm(argc,argv,"-mask",str_cmd_prm,file_valid,0,UsageHelp);
  if (strcmp(file_valid,"") != 0) FlagValid = 1;
  }

/********************************************************************
********************************************************************/

  check_file(OddFileInput);
  check_file(DblFileInput);
  check_file(VolFileInput);
  check_file(HlxFileInput);
  check_file(FileOutput);
  if (FlagValid == 1) check_file(file_valid);

  NwinL = 1; NwinC = 1;

  ExtraColBMP = (int) fmod(4 - (int) fmod(3*Ncol, 4), 4);
  NcolBMP = 3*Ncol + ExtraColBMP;
  ExtraColBMP = (int) fmod(4 - (int) fmod(Ncol, 4), 4);
  Sub_NcolBMP = Ncol + ExtraColBMP;

  /* INPUT FILE OPENING */
  if ((file_Odd = fopen(OddFileInput, "rb")) == NULL)
    edit_error("Could not open input file : ", OddFileInput);
  if ((file_Dbl = fopen(DblFileInput, "rb")) == NULL)
    edit_error("Could not open input file : ", DblFileInput);
  if ((file_Vol = fopen(VolFileInput, "rb")) == NULL)
    edit_error("Could not open input file : ", VolFileInput);
  if ((file_Hlx = fopen(HlxFileInput, "rb")) == NULL)
    edit_error("Could not open input file : ", HlxFileInput);

  if (FlagValid == 1) {
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);
    }

/* OUTPUT FILE OPENING */
  if ((filebmp = fopen(FileOutput, "wb")) == NULL)
    edit_error("ERREUR DANS L'OUVERTURE DU FICHIER", FileOutput);
  
/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  Ps = vector_float(Ncol);
  Pd = vector_float(Ncol);
  Pv = vector_float(Ncol);
  Pc = vector_float(Ncol);
  Tp = vector_float(Nlig*Ncol);

  ValidMask = vector_float(Ncol);
  
  dataimg = vector_char(NcolBMP);

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0)  
    for (col = 0; col < Ncol; col++) ValidMask[col] = 1.;

/********************************************************************
********************************************************************/
  rewind(file_Odd);
  rewind(file_Dbl);
  rewind(file_Vol);
  rewind(file_Hlx);
  if (FlagValid == 1) rewind(in_valid);

  // Read binary files, get total power and min/max values
  for (lig = 0; lig < Nlig; lig++) {
    if (lig%(int)(Nlig/20) == 0) {printf("%f\r", 100. * lig / (Nlig - 1));fflush(stdout);}
    fread(&Ps[0], sizeof(float), Ncol, file_Odd);
    fread(&Pd[0], sizeof(float), Ncol, file_Dbl);
    fread(&Pv[0], sizeof(float), Ncol, file_Vol);
    fread(&Pc[0], sizeof(float), Ncol, file_Hlx);
    if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    for (col = 0; col < Ncol; col++) {
      Tp[lig*Ncol+col] = 0.;
      if (ValidMask[col] == 1.) {
        Tp[lig*Ncol+col] = Ps[col]+Pd[col]+Pv[col]+Pc[col];
        }
      } /* col */
    } /* lig */

  // Get boundaries
  GetHistogramBoundary(&Tp, Nlig*Ncol, truncate_percent_L,  NBINS, &rg_L_min,  &rg_L_max,  0);
  GetHistogramBoundary(&Tp, Nlig*Ncol, truncate_percent_ab, NBINS, &rg_ab_min, &rg_ab_max, 0);
    
/********************************************************************
********************************************************************/
  rewind(file_Odd);
  rewind(file_Dbl);
  rewind(file_Vol);
  rewind(file_Hlx);
  if (FlagValid == 1) rewind(in_valid);

  Ps_max = -9999.99;
  Pd_max = -9999.99;
  Pv_max = -9999.99;
  Pc_max = -9999.99;

  // Boundary values of L-axis
  LRg = 100.0 - truncate_percent_L * 2.0;
  LMin = (100.0 - LRg) / 2.0;
  LMax = 100.0 - LMin;
  
  // Read binary files, get total power and min/max values
  for (lig = 0; lig < Nlig; lig++) {
    if (lig%(int)(Nlig/20) == 0) {printf("%f\r", 100. * lig / (Nlig - 1));fflush(stdout);}
    fread(&Ps[0], sizeof(float), Ncol, file_Odd);
    fread(&Pd[0], sizeof(float), Ncol, file_Dbl);
    fread(&Pv[0], sizeof(float), Ncol, file_Vol);
    fread(&Pc[0], sizeof(float), Ncol, file_Hlx);
    if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    for (col = 0; col < Ncol; col++) {
      if (ValidMask[col] == 1.) {
        //+----------------------------------------------------------+
        //|               L-axis boundary trim                       |
        //+----------------------------------------------------------+
        // minimun constrain
        if(Tp[lig*Ncol+col] < rg_L_min){
          Ps[col] = Ps[col] * (rg_L_min / Tp[lig*Ncol+col]);
          Pd[col] = Pd[col] * (rg_L_min / Tp[lig*Ncol+col]);
          Pv[col] = Pv[col] * (rg_L_min / Tp[lig*Ncol+col]);
          Pc[col] = Pc[col] * (rg_L_min / Tp[lig*Ncol+col]);
          Tp[lig*Ncol+col] = rg_L_min;
          }
        // maximun constrain
        if(Tp[lig*Ncol+col] > rg_L_max){
          Ps[col] = Ps[col] / Tp[lig*Ncol+col] * rg_L_max;
          Pd[col] = Pd[col] / Tp[lig*Ncol+col] * rg_L_max;
          Pv[col] = Pv[col] / Tp[lig*Ncol+col] * rg_L_max;
          Pc[col] = Pc[col] / Tp[lig*Ncol+col] * rg_L_max;
          Tp[lig*Ncol+col] = rg_L_max;
          }
        //+----------------------------------------------------------+
        //|              ab-plane boundary trim                      |
        //+----------------------------------------------------------+
        if(Tp[lig*Ncol+col] > rg_ab_max){
          Ps[col] = Ps[col] / Tp[lig*Ncol+col] * rg_ab_max;
          Pd[col] = Pd[col] / Tp[lig*Ncol+col] * rg_ab_max;
          Pv[col] = Pv[col] / Tp[lig*Ncol+col] * rg_ab_max;
          Pc[col] = Pc[col] / Tp[lig*Ncol+col] * rg_ab_max;
          }
          
        if (Ps_max <= Ps[col]) Ps_max = Ps[col];
        if (Pd_max <= Pd[col]) Pd_max = Pd[col];
        if (Pv_max <= Pv[col]) Pv_max = Pv[col];
        if (Pc_max <= Pc[col]) Pc_max = Pc[col];
        
        Tp[lig*Ncol+col] = 10.*log10f(Tp[lig*Ncol+col]);
        }
      } /* col */
    } /* lig */

/*******************************************************************/
/* OUTPUT BMP FILE CREATION */
/*******************************************************************/

/* BMP HDR FILE */
  write_bmp_hdr(Nlig, Ncol, 0., 0., 24, FileOutput);

/* BMP HEADER */
  write_header_bmp_24bit(Nlig, Ncol, filebmp);
  
/********************************************************************
********************************************************************/
  max_val = Max(Ps_max, Pd_max, Pv_max, Pc_max);

  RGBModel M;
  Adaptation A;
  
  GetRGBModel_CIERGB(&M);
  GetRefWhite_D50(RefWhite);
  GetAdaptation_Bradford(&A);

//+------------------------------------------------------------------+
//|                       CIE-Lab composition                        |
//+------------------------------------------------------------------+
  Scale(Tp, Nlig*Ncol, LMin, LMax, &Tp);

//+------------------------------------------------------------------+
//|                       Convert to CIE-RGB                         |
//+------------------------------------------------------------------+
  rewind(file_Odd);
  rewind(file_Dbl);
  rewind(file_Vol);
  rewind(file_Hlx);
  if (FlagValid == 1) rewind(in_valid);

  my_fseek(file_Odd, 1, Nlig, Ncol*sizeof(float));    
  my_fseek(file_Dbl, 1, Nlig, Ncol*sizeof(float));    
  my_fseek(file_Vol, 1, Nlig, Ncol*sizeof(float));    
  my_fseek(file_Hlx, 1, Nlig, Ncol*sizeof(float));    
  if (FlagValid == 1) my_fseek(in_valid, 1, Nlig, Ncol*sizeof(float));
 
  for (lig = 0; lig < Nlig; lig++) {
    if (lig%(int)(Nlig/20) == 0) {printf("%f\r", 100. * lig / (Nlig - 1));fflush(stdout);}
  
    my_fseek(file_Odd, -1, Ncol, sizeof(float));
    fread(&Ps[0], sizeof(float), Ncol, file_Odd);
    my_fseek(file_Odd, -1, Ncol, sizeof(float));

    my_fseek(file_Dbl, -1, Ncol, sizeof(float));
    fread(&Pd[0], sizeof(float), Ncol, file_Dbl);
    my_fseek(file_Dbl, -1, Ncol, sizeof(float));

    my_fseek(file_Vol, -1, Ncol, sizeof(float));
    fread(&Pv[0], sizeof(float), Ncol, file_Vol);
    my_fseek(file_Vol, -1, Ncol, sizeof(float));

    my_fseek(file_Hlx, -1, Ncol, sizeof(float));
    fread(&Pc[0], sizeof(float), Ncol, file_Hlx);
    my_fseek(file_Hlx, -1, Ncol, sizeof(float));

    if (FlagValid == 1) {
      my_fseek(in_valid, -1, Ncol, sizeof(float));
      fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
      my_fseek(in_valid, -1, Ncol, sizeof(float));
      }
    
    for (col = 0; col < Ncol; col++) {
      if (ValidMask[col] == 1.) {

        TpTot = Ps[col]+Pd[col]+Pv[col]+Pc[col];
        if(TpTot < rg_L_min){
          Ps[col] = Ps[col] * (rg_L_min / TpTot);
          Pd[col] = Pd[col] * (rg_L_min / TpTot);
          Pv[col] = Pv[col] * (rg_L_min / TpTot);
          Pc[col] = Pc[col] * (rg_L_min / TpTot);
          TpTot = rg_L_min;
          }
        if(TpTot > rg_L_max){
          Ps[col] = Ps[col] / TpTot * rg_L_max;
          Pd[col] = Pd[col] / TpTot * rg_L_max;
          Pv[col] = Pv[col] / TpTot * rg_L_max;
          Pc[col] = Pc[col] / TpTot * rg_L_max;
          TpTot = rg_L_max;
          }
        if(TpTot > rg_ab_max){
          Ps[col] = Ps[col] / TpTot * rg_ab_max;
          Pd[col] = Pd[col] / TpTot * rg_ab_max;
          Pv[col] = Pv[col] / TpTot * rg_ab_max;
          Pc[col] = Pc[col] / TpTot * rg_ab_max;
          }

        lab[0] = Tp[(Nlig-1-lig)*Ncol+col];
        lab[1] = A_min * Pv[col] * cos(deg2rad(30))/max_val + A_max * Pd[col] * cos(deg2rad(30))/max_val;
        lab[2] = B_min * Ps[col]/max_val + B_max * ((Pv[col] + Pd[col])*cos(deg2rad(60)) + Pc[col])/max_val;
        Lab2RGB(lab, &M, RefWhite, &A, rgb);
        l = (int) (floor(255 * rgb[2]));
        dataimg[3 * col + 0] = (char) (l);
        l = (int) (floor(255 * rgb[1]));
        dataimg[3 * col + 1] =  (char) (l);
        l = (int) (floor(255 * rgb[0]));
        dataimg[3 * col + 2] =  (char) (l);
        } else {
        dataimg[3 * col + 0] = (char) (0);
        dataimg[3 * col + 1] = (char) (1);
        dataimg[3 * col + 2] = (char) (0);
        } /* valid */
      } /*col*/
    for (col = 0; col < ExtraColBMP; col++) {
      l = (int) (floor(255 * 0.));
      dataimg[col + 3*Ncol] = (char) (l);
      } /*col*/
    fwrite(&dataimg[0], sizeof(char), NcolBMP, filebmp);
    } /*lig*/

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_vector_char(dataimg);
  free_vector_float(datatmp);
  free_vector_float(bufferdatablue);
  free_vector_float(bufferdatared);
  free_vector_float(bufferdatagreen);
  free_vector_float(ValidMask);
*/
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  fclose(filebmp);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  fclose(file_Odd);
  fclose(file_Dbl);
  fclose(file_Vol);
  fclose(file_Hlx);

/********************************************************************
********************************************************************/

  return 1;
}


