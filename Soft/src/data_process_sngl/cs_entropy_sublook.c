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

File   : cs_entropy_sublook.c
Project  : ESA_POLSARPRO-SATIM
Authors  : Kamil Szostek & Hubert Michalik & E. Pottier
Version  : 1.0
Creation : 05/2016
Update  :
*--------------------------------------------------------------------

Description :  Coherent Scatterers recognition using entropy

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "omp.h"

#ifdef _WIN32
#include <Windows.h>
#include <dos.h>
#include <conio.h>
#endif

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"

typedef struct _complexf
{
  float re;
  float im;
}complexf;

void swap(complexf *v1, complexf *v2)
{
  complexf tmp = *v1;
  *v1 = *v2;
  *v2 = tmp;
}

//shift fft for complex data (re im re im re im)
void FftShift(complexf *data, int count)
{
  int k = 0;
  int c = (int)floor((float)count / 2);
  if (count % 2 == 0)
  {
    for (k = 0; k < c; k++)
      swap(&data[k], &data[k + c]);
  }
  else
  {
    complexf tmp = data[0];
    for (k = 0; k < c; k++)
    {
      data[k] = data[c + k + 1];
      data[c + k + 1] = data[k + 1];
    }
    data[c] = tmp;
  }
}

void iFftShift(complexf *data, int count)
{
  int k = 0;
  int c = (int)floor((float)count / 2);
  if (count % 2 == 0)
  {
    for (k = 0; k < c; k++)
      swap(&data[k], &data[k + c]);
  }
  else
  {
    complexf tmp = data[count - 1];
    for (k = c - 1; k >= 0; k--)
    {
      data[c + k + 1] = data[k];
      data[k] = data[c + k];
    }
    data[c] = tmp;
  }
}

float ccabs(complexf v)
{
  return sqrt(v.re*v.re + v.im*v.im);
}

float ccabsf(float re, float im)
{
  return sqrt(re*re + im*im);
}

void Phase(float *M_in, int Ncol, float * phase)
{
  int i = 0;
  for (i = 0; i < Ncol; i++)
    phase[i] = atan2f(M_in[i * 2 + 1], M_in[i * 2]);
}

unsigned long upper_power_of_two(unsigned long v)
{
  v--;
  v |= v >> 1;
  v |= v >> 2;
  v |= v >> 4;
  v |= v >> 8;
  v |= v >> 16;
  v++;
  return v;

}

void hamming2(float ham_a, float *ham_win, int n)
{
  int lig;

  for (lig = 0; lig<n; lig++)
    ham_win[lig] = (float)(ham_a + (1.0f - ham_a)*cos(2.0 * pi * (lig - (n - 1) / 2.0) / (n - 1)));
}

complexf cmult(const complexf z1, const complexf z2)
{
  complexf z;
  z.re = z1.re*z2.re - z1.im*z2.im;
  z.im = z1.re*z2.im + z2.re*z1.im;

  return z;
}

complexf cmultConj(const complexf z1, const complexf z2)
{
  complexf z;
  z.re = z1.re*z2.re + z1.im*z2.im;
  z.im = z2.re*z1.im - z1.re*z2.im;

  return z;
}

void boxcarfast(complexf** M_in, complexf** M_tmp, int len, int NligBlockNb, int NwinLM1S2, int NwinCM1S2, int NwinC)
{
  int lig, col, k, l, idxY;
  complexf mean;

#pragma omp parallel for private(col, k, l, mean, idxY) schedule(dynamic)
  for (lig = 0; lig < NligBlockNb; lig++)
  {
    mean.re = 0;
    mean.im = 0;

    for (col = 0; col < len; col++)
    {
      if (col == 0)
      {
        for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++)
          for (l = -NwinCM1S2; l < 1 + NwinCM1S2; l++)
          {
            mean.re += M_in[NwinLM1S2 + lig + k][NwinCM1S2 + col + l].re;// *Valid[NwinLM1S2 + lig + k][NwinCM1S2 + col + l];
            mean.im += M_in[NwinLM1S2 + lig + k][NwinCM1S2 + col + l].im;
          }
      }
      else
      {
        for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++)
        {
          idxY = NwinLM1S2 + lig + k;

          mean.re -= M_in[idxY][col - 1].re;// *Valid[idxY][col - 1];
          mean.im -= M_in[idxY][col - 1].im;// *Valid[idxY][col - 1];

          mean.re += M_in[idxY][NwinC - 1 + col].re;// *Valid[idxY][NwinC - 1 + col];
          mean.im += M_in[idxY][NwinC - 1 + col].im;// *Valid[idxY][NwinC - 1 + col];
        }
      }
      M_tmp[lig][col] = mean;      
    }
  }
  for (lig = 0; lig < NligBlockNb; lig++)
  {
    for (col = 0; col < len; col++)
    {
      M_in[lig][col] = M_tmp[lig][col];      
    }
  }
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
  FILE *fileinput, *fileoutput;
  char FileInput[FilePathLength], FileOutput[FilePathLength];

/* Internal variables */
  int lig, col, k;

  int Ncol2Powk;
  int Nsublooks = 4;
  int *subLookS;
  int *subLookE;
  int myThreadId = 0;
  complexf ***subLooks;
  complexf tmp;
  int sl = 0;
  int sl2 = 0;
  int len = 0;

/* Matrix arrays */
  float **M_in;
  float **M_out;
  float ****C;
  complexf ***Csubs;
  float ampl;
  float phase;
  float *hm;
  float *hm2; // na sublooki
  float threshold = 0.3f;

  float ****eigens;
  float **eigVal;
  float lambdaSum = 0; 
  float log10f_Nsublooks;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncs_entropy_sublook.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input file\n");
strcat(UsageHelp," (string)	-of  	output file\n");
strcat(UsageHelp," (int)   	-inc 	Initial Number of Col\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (int)   	-ns  	Number of sublooks (must be power of 2)\n");
strcat(UsageHelp," (float) 	-tr  	Threshold (default 0.7)\n");
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

if(argc < 23) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,FileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-inc",int_cmd_prm,&Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1, UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1, UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-tr",flt_cmd_prm,&threshold,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ns",int_cmd_prm,&Nsublooks,1,UsageHelp);

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

  check_file(FileInput);
  check_file(FileOutput);
  if (FlagValid == 1) check_file(file_valid);
  
  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

  PSP_Threads = omp_get_num_procs();
  if (PSP_Threads > 1) omp_set_num_threads(PSP_Threads-1);

/* INPUT FILE OPENING*/
  if ((fileinput = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  if ((fileoutput = fopen(FileOutput, "wb")) == NULL)
  edit_error("Could not open output file : ", FileOutput);

/********************************************************************
********************************************************************/
/* MEMORY ALLOCATION */
/*
MemAlloc = NBlockA*Nlig + NBlockB
*/ 
  Ncol2Powk = upper_power_of_two(Ncol);

/* Local Variables */
  NBlockA = 0; NBlockB = 0;
  /* Mask */ 
  NBlockA += Sub_Ncol+NwinC; NBlockB += NwinL*(Sub_Ncol+NwinC);

  /* Min = (Nlig+NwinL)*2*(Ncol2Powk+NwinC) */
  NBlockA += 2*(Ncol2Powk+NwinC); NBlockB += NwinL*2*(Ncol2Powk+NwinC);
  /* Mout = Nlig*2*Ncol2Powk */
  NBlockA += 2*Ncol2Powk; NBlockB += 0;
  /* Csubs = (Nsublooks*Nsublooks+1)*(Nlig + NwinL)*(Ncol2Powk * 2 / Nsublooks + 2*NwinC)*/ 
  NBlockA += (Nsublooks*Nsublooks+1)*(Ncol2Powk * 2 / Nsublooks + 2*NwinC); NBlockB += (Nsublooks*Nsublooks+1)*NwinL*(Ncol2Powk * 2 / Nsublooks + 2*NwinC);
  
/* Reading Data */
  NBlockB += Ncol + 2*Ncol + NpolarIn*2*Ncol + NpolarOut*NwinL*(Ncol+NwinC);

  memory_alloc(file_memerr, Sub_Nlig, NwinL, &NbBlock, NligBlock, NBlockA, NBlockB, MemoryAlloc);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  _VI_in = vector_int(Ncol);
  _VC_in = vector_float(2*Ncol);
  _VF_in = vector_float(Ncol);
  _MC_in = matrix_float(4,2*Ncol);
  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   

  Valid = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);
  
  M_in = matrix_float(NligBlock[0] + NwinL, 2 * Ncol2Powk + NwinC);
  M_out = matrix_float(NligBlock[0], 2 * Ncol2Powk);

  Csubs = (complexf***)matrix3d_float(Nsublooks*Nsublooks+1, NligBlock[0] + NwinL, Ncol2Powk * 2 / Nsublooks + 2*NwinC); // Nsublooks*Nsublooks = z wymiaru macierzy kowariancji, 

  hm = vector_float(Ncol2Powk);
  hm2 = vector_float(Ncol2Powk);
  subLooks = (complexf***)matrix3d_float(Nsublooks,PSP_Threads, Ncol2Powk * 2); // *2/2 ?
  subLookS = vector_int(Nsublooks);
  subLookE = vector_int(Nsublooks);

  C = (float****)malloc(sizeof(float***)*PSP_Threads);
  eigens = (float****)malloc(sizeof(float***)*PSP_Threads);
  eigVal = (float**)malloc(sizeof(float*)*PSP_Threads);

  for (myThreadId = 0; myThreadId < PSP_Threads; myThreadId++) {
    C[myThreadId] = matrix3d_float(Nsublooks, Nsublooks, 2);
    eigens[myThreadId] = matrix3d_float(Nsublooks, Nsublooks, 2);
    eigVal[myThreadId] = vector_float(Nsublooks);
    } 
  log10f_Nsublooks = log10f(Nsublooks);
  
/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
#pragma omp parallel for private(col)
    for (lig = 0; lig < NligBlock[0] + NwinL; lig++) 
      for (col = 0; col < Sub_Ncol + NwinC; col++) 
        Valid[lig][col] = 1.;

/********************************************************************
********************************************************************/
/* DATA PROCESSING */
  len = floor(Ncol2Powk / (float)Nsublooks);// +Ncol % 2;

  hamming2(0.54f, hm, Ncol2Powk);
  hamming2(0.54f, hm2, len);

  //podziel widmo 
  subLookS[0] = 0;
  subLookE[0] = len;
  for (k = 1; k < Nsublooks; k++) {
    subLookS[k] = subLookE[k - 1];
    subLookE[k] = subLookS[k] + subLookE[0];
    } 

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  read_block_matrix_cmplx(fileinput, M_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

#pragma omp parallel for private(col,sl,sl2,tmp,k,myThreadId,ampl,phase)  schedule(dynamic)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    myThreadId = omp_get_thread_num();
    //fft
    Fft(M_in[lig] + NwinCM1S2*2, Ncol2Powk, 1);
    //fftshift
    FftShift((complexf*)M_in[lig] + NwinCM1S2*2, Ncol2Powk);

    // nie trzeba normalizowaæ, nie trzeba liczyæ amplitudy i fazy dla wiersza, tylko dla elementu
    for (sl = 0; sl < Nsublooks; sl++) { //dla kazdego sublooka 
      for (col = 0, k = subLookS[sl]; k < subLookE[sl]; col++, k++) {
        ampl = ccabsf(M_in[lig][2 * k], M_in[lig][2 * k + 1]);
        phase = atan2(M_in[lig][2 * k + 1], M_in[lig][2 * k]);

        tmp.re = ampl / hm[k] * hm2[col];
        subLooks[sl][myThreadId][col].re = tmp.re *cos(phase); //RE
        subLooks[sl][myThreadId][col].im = tmp.re *sin(phase); //IM            
        }
      iFftShift(subLooks[sl][myThreadId], Ncol2Powk);
      Fft((float*)subLooks[sl][myThreadId], Ncol2Powk, -1);
      }

    //konjugacje
    for (sl = 0; sl < Nsublooks; sl++) {
      for (sl2 = 0; sl2 < Nsublooks; sl2++) {            
        for (col = 0; col < Ncol2Powk; col++) {
          Csubs[sl*Nsublooks + sl2][lig][col + NwinCM1S2] = cmultConj(subLooks[sl][myThreadId][col], subLooks[sl2][myThreadId][col]);
          }
        }
      } 
    }//lig

  for (sl = 0; sl < Nsublooks; sl++) {
    for (sl2 = 0; sl2 < Nsublooks; sl2++) {
      boxcarfast(Csubs[sl*Nsublooks + sl2], Csubs[Nsublooks*Nsublooks], Ncol2Powk, NligBlock[Nb], NwinLM1S2, NwinCM1S2, NwinC);
      }
    }

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
#pragma omp parallel for private(sl, sl2, lambdaSum, myThreadId)
    for (col = 0; col < Ncol2Powk; col++) {
      myThreadId = omp_get_thread_num();
      for (sl = 0; sl < Nsublooks; sl++) {
        for (sl2 = 0; sl2 < Nsublooks; sl2++) {
          C[myThreadId][sl][sl2][0] = Csubs[sl*Nsublooks + sl2][lig ][col ].re;
          C[myThreadId][sl][sl2][1] = Csubs[sl*Nsublooks + sl2][lig ][col ].im;
          }
        }

    //policz lambdy itd
    Diagonalisation(Nsublooks, C[myThreadId], eigens[myThreadId], eigVal[myThreadId]);
    lambdaSum = 0;
    for (sl = 0; sl < Nsublooks; sl++) lambdaSum += eigVal[myThreadId][sl];
    for (sl = 0; sl < Nsublooks; sl++) eigVal[myThreadId][sl] /= lambdaSum;
          
    lambdaSum = 0;
    for (sl = 0; sl < Nsublooks; sl++)
      lambdaSum += eigVal[myThreadId][sl] * log10f(eigVal[myThreadId][sl]) / log10f_Nsublooks;
          
      M_out[lig][col] = -lambdaSum < threshold;// -(p[0] * log10(p[0]) / log10(Nsublooks) + p[1] * log10(p[1]) / log10(Nsublooks) + p[2] * log10(p[2]) / log10(Nsublooks) + p[3] * log10(p[3]) / log10(Nsublooks)) < threshold;
      }
    fwrite(M_out[lig], sizeof(float), Sub_Ncol, fileoutput);
    }
  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0] + NwinL);

  free_matrix_float(M_in, NligBlock[0] + NwinL);
  free_matrix_float(M_out, NligBlock[0]);

*/  
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  fclose(fileoutput);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  fclose(fileinput);

/********************************************************************
********************************************************************/

  return 1;
}



