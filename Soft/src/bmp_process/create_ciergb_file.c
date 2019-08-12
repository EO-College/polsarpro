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

File   : create_ciergb_file.c
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

Description :  Creation of a CIE-RGB BMP file from 3 binary files

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

#include "omp.h"

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"

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
  FILE *file_Dbl, *file_Odd, *file_Vol;
  char DblFileInput[FilePathLength], OddFileInput[FilePathLength];
  char VolFileInput[FilePathLength];
  char FileOutput[FilePathLength];
  
/* Internal variables */
  int lig, col, l;
  long NBINS = 32768;
  float truncate_percent;
  float Ps_max, Pd_max, Pv_max;
  float Ps_min, Pd_min, Pv_min;
  float rg_min, rg_max, min_val, max_val, TpTot;

/* Matrix arrays */
  float *ValidMask;
  float *Pd, *Ps, *Pv, *Tp;
  char *dataimg;
    
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncreate_ciergb_file.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-ifo 	input binary file: odd channel\n");
strcat(UsageHelp," (string)	-ifd 	input binary file: dbl channel\n");
strcat(UsageHelp," (string)	-ifv 	input binary file: vol channel\n");
strcat(UsageHelp," (string)	-of  	output CIE RGB BMP file\n");
strcat(UsageHelp," (int)   	-inr 	Initial Number of Row\n");
strcat(UsageHelp," (int)   	-inc 	Initial Number of Col\n");
strcat(UsageHelp," (float) 	-lv  	Truncated value in percent, default = 2.\n");
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
  
if(argc < 17) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-ifo",str_cmd_prm,OddFileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifd",str_cmd_prm,DblFileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifv",str_cmd_prm,VolFileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-inr",int_cmd_prm,&Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-inc",int_cmd_prm,&Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-lv",flt_cmd_prm,&truncate_percent,1,UsageHelp);
  get_commandline_prm(argc,argv,"-bin",int_cmd_prm,&NBINS,1,UsageHelp);

  get_commandline_prm(argc,argv,"-errf",str_cmd_prm,file_memerr,0,UsageHelp);

  MemoryAlloc = -1; MemoryAlloc = CheckFreeMemory();
  MemoryAlloc = my_max(MemoryAlloc,1000);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

  FlagValid = 0;strcpy(file_valid,"");
  get_commandline_prm(argc,argv,"-mask",str_cmd_prm,file_valid,0,UsageHelp);
  if (strcmp(file_valid,"") != 0) FlagValid = 1;
  }

/********************************************************************
********************************************************************/

  check_file(OddFileInput);
  check_file(DblFileInput);
  check_file(VolFileInput);
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
  if (FlagValid == 1) rewind(in_valid);

  // Read binary files, get total power and min/max values
  for (lig = 0; lig < Nlig; lig++) {
    if (lig%(int)(Nlig/20) == 0) {printf("%f\r", 100. * lig / (Nlig - 1));fflush(stdout);}
    fread(&Ps[0], sizeof(float), Ncol, file_Odd);
    fread(&Pd[0], sizeof(float), Ncol, file_Dbl);
    fread(&Pv[0], sizeof(float), Ncol, file_Vol);
    if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    for (col = 0; col < Ncol; col++) {
      Tp[lig*Ncol+col] = 0.;
      if (ValidMask[col] == 1.) {
        Tp[lig*Ncol+col] = Ps[col]+Pd[col]+Pv[col];
        }
      } /* col */
    } /* lig */

  // Get boundaries
  GetHistogramBoundary(&Tp, Nlig*Ncol, truncate_percent,  NBINS, &rg_min,  &rg_max,  0);
    
/********************************************************************
********************************************************************/
  rewind(file_Odd);
  rewind(file_Dbl);
  rewind(file_Vol);
  if (FlagValid == 1) rewind(in_valid);

  Ps_max = -9999.99; Ps_min = +9999.99;
  Pd_max = -9999.99; Pd_min = +9999.99;
  Pv_max = -9999.99; Pv_min = +9999.99;
  
  // Read binary files, get total power and min/max values
  for (lig = 0; lig < Nlig; lig++) {
    if (lig%(int)(Nlig/20) == 0) {printf("%f\r", 100. * lig / (Nlig - 1));fflush(stdout);}
    fread(&Ps[0], sizeof(float), Ncol, file_Odd);
    fread(&Pd[0], sizeof(float), Ncol, file_Dbl);
    fread(&Pv[0], sizeof(float), Ncol, file_Vol);
    if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    for (col = 0; col < Ncol; col++) {
      if (ValidMask[col] == 1.) {
        // maximun constrain
        if(Tp[lig*Ncol+col] > rg_max){
          Ps[col] = Ps[col] / Tp[lig*Ncol+col] * rg_max;
          Pd[col] = Pd[col] / Tp[lig*Ncol+col] * rg_max;
          Pv[col] = Pv[col] / Tp[lig*Ncol+col] * rg_max;
          }
        // minimun constrain
        if(Tp[lig*Ncol+col] < rg_min){
          Ps[col] = Ps[col] * (rg_min / Tp[lig*Ncol+col]);
          Pd[col] = Pd[col] * (rg_min / Tp[lig*Ncol+col]);
          Pv[col] = Pv[col] * (rg_min / Tp[lig*Ncol+col]);
          }
          
        if (Ps_max <= Ps[col]) Ps_max = Ps[col];
        if (Ps[col] < Ps_min) Ps_min = Ps[col];
        if (Pd_max <= Pd[col]) Pd_max = Pd[col];
        if (Pd[col] < Pd_min) Pd_min = Pd[col];
        if (Pv_max <= Pv[col]) Pv_max = Pv[col];
        if (Pv[col] < Pv_min) Pv_min = Pv[col];
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
  max_val = Max3(Ps_max, Pd_max, Pv_max);
  min_val = Min3(Ps_min, Pd_min, Pv_min);

//+------------------------------------------------------------------+
//|                       Convert to CIE-RGB                         |
//+------------------------------------------------------------------+
  rewind(file_Odd);
  rewind(file_Dbl);
  rewind(file_Vol);
  if (FlagValid == 1) rewind(in_valid);

  my_fseek(file_Odd, 1, Nlig, Ncol*sizeof(float));    
  my_fseek(file_Dbl, 1, Nlig, Ncol*sizeof(float));    
  my_fseek(file_Vol, 1, Nlig, Ncol*sizeof(float));    
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

    if (FlagValid == 1) {
      my_fseek(in_valid, -1, Ncol, sizeof(float));
      fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
      my_fseek(in_valid, -1, Ncol, sizeof(float));
      }
    
    for (col = 0; col < Ncol; col++) {
      if (ValidMask[col] == 1.) {

        TpTot = Ps[col]+Pd[col]+Pv[col];
        if(TpTot < rg_min){
          Ps[col] = Ps[col] * (rg_min / TpTot);
          Pd[col] = Pd[col] * (rg_min / TpTot);
          Pv[col] = Pv[col] * (rg_min / TpTot);
          }
        if(TpTot > rg_max){
          Ps[col] = Ps[col] / TpTot * rg_max;
          Pd[col] = Pd[col] / TpTot * rg_max;
          Pv[col] = Pv[col] / TpTot * rg_max;
          }

        l = (int) (floor(255 * (Ps[col] - min_val)/(max_val - min_val)));
        dataimg[3 * col + 0] = (char) (l);
        l = (int) (floor(255 * (Pv[col] - min_val)/(max_val - min_val)));
        dataimg[3 * col + 1] =  (char) (l);
        l = (int) (floor(255 * (Pd[col] - min_val)/(max_val - min_val)));
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

/********************************************************************
********************************************************************/

  return 1;
}


