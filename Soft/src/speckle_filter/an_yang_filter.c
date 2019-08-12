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

File   : an_yang_filter.c
Project  : ESA_POLSARPRO-SATIM
Authors  : Eric POTTIER, Jacek STRZELCZYK
Authors  : J. Chen, Y. Chen, W. An, Y. Cui, J. Yang
Version  : 2.0
Creation : 07/2015
Update  :
*--------------------------------------------------------------------
J. Chen, W. An, Y. Cui, J. Yang
Department of Electronic Engineering
Tsinghua University
Beijing 100084
China
 
Y. Chen
Department of Electrical Engineering and Computer Science
University of Michigan
Ann Arbor
MI 48109-2122 USA
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

Description :  An and Yang fully polarimetric speckle filter

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

/* CONSTANTS  */
#define Bias 4.158883083359672

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"

int matrix_det(float **m_det, float ***m_T, int nrh, int nch)
{
  int i, j;
#pragma omp parallel for private(j)
  for (i = 0; i < nrh; i++) {
    for (j = 0; j < nch; j++) {
      m_det[i][j] = fabs(m_T[0][i][j] * m_T[5][i][j] * m_T[8][i][j] + 
                    2.0 * (m_T[1][i][j] * m_T[3][i][j] * m_T[6][i][j] + m_T[1][i][j] * m_T[4][i][j] * m_T[7][i][j]
                    + m_T[2][i][j] * m_T[4][i][j] * m_T[6][i][j] - m_T[2][i][j] * m_T[3][i][j] * m_T[7][i][j]) 
                    - m_T[0][i][j] * (m_T[6][i][j] * m_T[6][i][j] + m_T[7][i][j] * m_T[7][i][j])
                    - m_T[5][i][j] * (m_T[3][i][j] * m_T[3][i][j] + m_T[4][i][j] * m_T[4][i][j])
                    - m_T[8][i][j] * (m_T[1][i][j] * m_T[1][i][j] + m_T[2][i][j] * m_T[2][i][j]));
    }
  }
  return 0;
}

int matrix_cirshift(float **m_shift, float **m_ori, int nrh, int nch, int sr, int sc)
{
  int i, j;
  
  if(sr >= 0) {
#pragma omp parallel for private(j) schedule(dynamic)
    for(i = 0; i < nrh - sr; i++) {
      if(sc >=0) {
        for(j = 0; j < nch - sc; j++) {
          m_shift[i + sr][j + sc] = m_ori[i][j];
          }
        for(j = nch - sc; j < nch; j++) {
          m_shift[i + sr][j - nch + sc] = m_ori[i][j];
          }
        } else {
        for(j = 0; j < nch + sc; j++) {
          m_shift[i + sr][j] = m_ori[i][j - sc];
          }
        for(j = nch + sc; j < nch; j++) {
          m_shift[i + sr][j] = m_ori[i][j - nch - sc];
          }
        }
      }
#pragma omp parallel for private(j) schedule(dynamic)
    for(i = nrh - sr; i < nrh; i++) {
      for(j = 0; j < nch; j++) {
        m_shift[i - nrh + sr][j] = m_ori[i][j];
        }
      }
    } else {
#pragma omp parallel for private(j) schedule(dynamic)
    for(i = -sr; i < nrh; i++) {
      if(sc >=0) {
        for(j = 0; j < nch - sc; j++) {
          m_shift[i + sr][j + sc] = m_ori[i][j];
          }
        for(j = nch - sc; j < nch; j++) {
          m_shift[i + sr][j - nch + sc] = m_ori[i][j];
          }
        } else {
        for(j = 0; j < nch + sc; j++) {
          m_shift[i + sr][j] = m_ori[i][j - sc];
          }
        for(j = nch + sc; j < nch; j++) {
          m_shift[i + sr][j] = m_ori[i][j - nch - sc];
          }
        }
     }
#pragma omp parallel for private(j) schedule(dynamic)
  for(i = 0; i < -sr; i++) {
    for(j = 0; j < nch; j++) {
      m_shift[i + nrh + sr][j] = m_ori[i][j];
      }
    }
  }
  return 0;
}

int matrix_AIm(float **m_AIm, float **m_ori, int nrh, int nch)
{
  int i, j;
  
  for(i = 0; i < nrh; i++) {
    m_AIm[i][0] = m_ori[i][0];
    }
  for(j = 1; j < nch; j++) {
    m_AIm[0][j] = m_ori[0][j];
    }
#pragma omp parallel for private(j) schedule(dynamic)
  for(i = 0; i < nrh; i++) {
    for(j = 1; j < nch; j++) {
      m_AIm[i][j] = m_AIm[i][j-1] + m_ori[i][j];
      }
    }
#pragma omp parallel for private(i) schedule(dynamic)
  for(j = 0; j < nch; j++) {
    for(i = 1; i < nrh; i++) {
      m_AIm[i][j] = m_AIm[i-1][j] + m_AIm[i][j];
      }
    }
  return 0;
}

int matrix_cal_Sd(float **m_Sd, float **m_det, float **m_det_shift, float **m_det_in_shift, int nrh, int nch)
{
int i, j;

#pragma omp parallel for private(j) schedule(dynamic)
  for(i = 0; i < nrh; i++){
    for(j = 0; j < nch; j++){
      m_Sd[i][j] = Bias + log(m_det[i][j] * m_det_shift[i][j]/(m_det_in_shift[i][j] * m_det_in_shift[i][j]));
      }
    }
  return 0;
}
int matrix3d_add(float ***m_dst, float ***m_src1, float ***m_src2, int nz, int nrh, int nch)
{
int i,j,k;

#pragma omp parallel for private(i,j) schedule(dynamic)
for(k = 0; k < nz; k++)
  for(i = 0; i < nrh; i++)
    for(j = 0; j < nch; j++)
      m_dst[k][i][j] = m_src1[k][i][j] + m_src2[k][i][j];
   return 0;
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

#define NPolType 12
/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = {
    "S2C3", "S2C4", "S2T3", "S2T4", "C2", "C3",
    "C4", "T2", "T3", "T4", "SPP", "IPP"};
  
/* Internal variables */
  int ii, jj, lig, col;
  
  int SwinL, SwinC;
  float K, Nlook, sigma, M_w;

/* Matrix arrays */
  float ***M_in;
  float ***M_out;
  float ***M_shift;
  float ***M_shift_in;
  float **M_det;
  float **M_AIm;
  float **M_det_shift;
  float **M_det_in_shift;
  float **M_Sd;
  float **M_Z;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nan_yang_filter.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-swr 	Swin Row\n");
strcat(UsageHelp," (int)   	-swc 	Swin Col\n");
strcat(UsageHelp," (float) 	-nlk 	Nlook\n");
strcat(UsageHelp," (float) 	-k   	K parameter\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
strcat(UsageHelp," (string)	-errf	memory error file\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");
strcat(UsageHelp," (noarg) 	-data	displays the help concerning Data Format parameter\n");

/********************************************************************
********************************************************************/

strcpy(UsageHelpDataFormat,"\nPolarimetric Input-Output Data Format\n\n");
for (ii=0; ii<NPolType; ii++) CreateUsageHelpDataFormat(PolTypeConf[ii]); 
strcat(UsageHelpDataFormat,"\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }
if(get_commandline_prm(argc,argv,"-data",no_cmd_prm,NULL,0,UsageHelpDataFormat)) {
  printf("\n Usage:\n%s\n",UsageHelpDataFormat); exit(1);
  }

if(argc < 27) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-swr",int_cmd_prm,&SwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-swc",int_cmd_prm,&SwinC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nlk",flt_cmd_prm,&Nlook,1,UsageHelp);
  get_commandline_prm(argc,argv,"-k",flt_cmd_prm,&K,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);

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

  Config = 0;
  for (ii=0; ii<NPolType; ii++) if (strcmp(PolTypeConf[ii],PolType) == 0) Config = 1;
  if (Config == 0) edit_error("\nWrong argument in the Polarimetric Data Format\n",UsageHelpDataFormat);
  }

/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);
  
  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);

/* POLAR TYPE CONFIGURATION */
  if (strcmp(PolType,"SPP")==0) strcpy(PolType, "SPPC2");
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);

  file_name_in = matrix_char(NpolarIn,1024); 
  file_name_out = matrix_char(NpolarOut,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir, file_name_in);
  init_file_name(PolTypeOut, out_dir, file_name_out);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
    if ((in_datafile[Np] = fopen(file_name_in[Np], "rb")) == NULL)
      edit_error("Could not open input file : ", file_name_in[Np]);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  for (Np = 0; Np < NpolarOut; Np++)
    if ((out_datafile[Np] = fopen(file_name_out[Np], "wb")) == NULL)
      edit_error("Could not open input file : ", file_name_out[Np]);

/********************************************************************
********************************************************************/
/* MEMORY ALLOCATION */
/*
MemAlloc = NBlockA*Nlig + NBlockB
*/ 

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  _VC_in = vector_float(2*Ncol);
  _VF_in = vector_float(Ncol);
  _MC_in = matrix_float(4,2*Ncol);
  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   

  Valid = matrix_float(Sub_Nlig, Sub_Ncol);

  M_in = matrix3d_float(NpolarOut, Sub_Nlig, Sub_Ncol);
  M_out = matrix3d_float(NpolarOut, Sub_Nlig, Sub_Ncol);

  M_shift = matrix3d_float(NpolarOut, Sub_Nlig, Sub_Ncol);
  M_shift_in = matrix3d_float(NpolarOut, Sub_Nlig, Sub_Ncol);

  M_det = matrix_float(Sub_Nlig, Sub_Ncol);
  M_AIm = matrix_float(Sub_Nlig, Sub_Ncol);
  M_det_shift = matrix_float(Sub_Nlig, Sub_Ncol);
  M_det_in_shift = matrix_float(Sub_Nlig, Sub_Ncol);
  M_Sd = matrix_float(Sub_Nlig, Sub_Ncol);
  M_Z = matrix_float(Sub_Nlig, Sub_Ncol);

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
#pragma omp parallel for private(col)
    for (lig = 0; lig < Sub_Nlig; lig++) 
      for (col = 0; col < Sub_Ncol; col++) 
        Valid[lig][col] = 1.;

/********************************************************************
********************************************************************/

/* DATA PROCESSING */
for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
if (FlagValid == 1) rewind(in_valid);

  if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {

    if (strcmp(PolTypeIn,"S2")==0) {
      read_block_S2_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, 0, 1, Sub_Nlig, Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
      } else {
      read_block_SPP_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, 0, 1, Sub_Nlig, Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
      }

    } else {

    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, 0, 1, Sub_Nlig, Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    }

  sigma = sqrt((K / Nlook))*(2 * NwinL + 1)*(2 * NwinC + 1);
  matrix_det(M_det, M_in, Sub_Nlig, Sub_Ncol);
  for(ii = -SwinL; ii <= SwinL; ii++) {
    PrintfLine(ii+SwinL,2*SwinL);
    for(jj = -SwinC; jj <= SwinC; jj++) {
      matrix_cirshift(M_det_shift, M_det, Sub_Nlig, Sub_Ncol, ii, jj);
      for (Np = 0; Np < NpolarOut; Np++) matrix_cirshift(M_shift[Np], M_in[Np], Sub_Nlig, Sub_Ncol, ii, jj);
      matrix3d_add(M_shift_in, M_shift, M_in, NpolarOut, Sub_Nlig, Sub_Ncol);
      matrix_det(M_det_in_shift, M_shift_in, Sub_Nlig, Sub_Ncol);
      matrix_cal_Sd(M_Sd, M_det, M_det_shift, M_det_in_shift, Sub_Nlig, Sub_Ncol);
      matrix_AIm(M_AIm, M_Sd, Sub_Nlig, Sub_Ncol);
#pragma omp parallel for private(col,Np,M_w) schedule(dynamic)
      for(lig = NwinL + 1; lig < Sub_Nlig - NwinL - 1; lig++) {
        for(col = NwinC + 1; col < Sub_Ncol - NwinC - 1; col++) {
          M_w = M_AIm[lig + NwinL][col + NwinC] + M_AIm[lig - NwinL - 1][col - NwinC - 1];
          M_w = M_w - M_AIm[lig + NwinL][col - NwinC - 1] - M_AIm[lig - NwinL - 1][col + NwinC];
          if(M_w > -sigma) {
            M_w = exp(M_w/sigma);
            } else {
            M_w = 0.;
            }
          M_Z[lig][col] = M_Z[lig][col] + M_w;
          for (Np = 0; Np < NpolarOut; Np++) M_out[Np][lig][col] = M_out[Np][lig][col] + M_w * M_shift[Np][lig][col];
          }
        }
        
      }
      // jj
    }
    // ii


  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, 0, 1, Sub_Nlig, Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  for(lig = NwinL + 1; lig < Sub_Nlig - NwinL - 1; lig++) {
    for(col = NwinC + 1; col < Sub_Ncol - NwinC - 1; col++) {
      if (Valid[lig][col] == 1.) {
        for (Np = 0; Np < NpolarOut; Np++) M_out[Np][lig][col] = M_out[Np][lig][col]/(M_Z[lig][col] + eps);
        } else {
        for (Np = 0; Np < NpolarOut; Np++) M_out[Np][lig][col] = 0.;
        }
      }
    }

  write_block_matrix3d_float(out_datafile, NpolarOut, M_out, Sub_Nlig, Sub_Ncol, 0, 0, Sub_Ncol);

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, Sub_Nlig);

  free_matrix3d_float(M_in, NpolarOut, Sub_Nlig);
  free_matrix3d_float(M_out, NpolarOut, Sub_Nlig);
  free_matrix3d_float(M_shift, NpolarOut, Sub_Nlig);
  free_matrix3d_float(M_shift_in, NpolarOut, Sub_Nlig);
  free_matrix_float(M_det, Sub_Nlig);
  free_matrix_float(M_AIm, Sub_Nlig);
  free_matrix_float(M_det_shift, Sub_Nlig);
  free_matrix_float(M_det_in_shift, Sub_Nlig);
  free_matrix_float(M_Sd, Sub_Nlig);
  free_matrix_float(M_Z, Sub_Nlig);
*/  
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarOut; Np++) fclose(out_datafile[Np]);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);

/********************************************************************
********************************************************************/

  return 1;
}


