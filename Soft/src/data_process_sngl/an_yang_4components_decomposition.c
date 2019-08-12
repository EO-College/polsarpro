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

File  : an_yang_4components_decomposition.c
Project  : ESA_POLSARPRO-SATIM
Authors  : Eric POTTIER, Jacek STRZELCZYK
Version  : 2.0
Creation : 07/2015
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

Description :  An and Yang 4 components Decomposition

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

#define lim_al1 55.  /* H and alpha decision boundaries */
#define lim_al2 50.
#define lim_al3 48.
#define lim_al4 42.
#define lim_al5 40.
#define lim_H1  0.9
#define lim_H2  0.5

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"
int unitary_rotation(float *TT, float teta);
int DecompYam3(float *TT,float *Ps,float *Pd,float *Pv);
int DecompYam4(float *TT,float *Ps,float *Pd,float *Pv,float *Pc);

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{

#define NPolType 3
/* LOCAL VARIABLES */
  FILE *out_odd, *out_dbl, *out_vol, *out_hlx;
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C3", "T3"};
  char file_name[FilePathLength];
    
/* Internal variables */
  int ii, k, lig, col;
  int ligDone = 0;

  float Span, SpanMin, SpanMax;
  float Alpha, Entropy, alphak, pk, HAlphaClass;
  float a1, a2, a3, a4, a5, h1, h2;
  float r1, r2, r3, r4, r5, r6, r7, r8, r9;
    
//  float ALPre, ALPim, BETre, BETim;
  float teta, x11, x22;
  float Ps, Pd, Pv, Pc;
  
/* Matrix arrays */
  float ***M_in;
  float **M_avg;
  float **M_odd;
  float **M_dbl;
  float **M_vol;
  float **M_hlx;
  float *TT;

  float ***M;
  float ***V;
  float *lambda;
  
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nan_yang_4components_decomposition.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
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
for (ii=0; ii<NPolType; ii++) CreateUsageHelpDataFormatInput(PolTypeConf[ii]); 
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

if(argc < 19) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);
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

  if (strcmp(PolType,"S2")==0) strcpy(PolType,"S2T3");

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
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);
  
  file_name_in = matrix_char(NpolarIn,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir, file_name_in);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
  if ((in_datafile[Np] = fopen(file_name_in[Np], "rb")) == NULL)
    edit_error("Could not open input file : ", file_name_in[Np]);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  sprintf(file_name, "%sAn_Yang4_Odd.bin", out_dir);
  if ((out_odd = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%sAn_Yang4_Dbl.bin", out_dir);
  if ((out_dbl = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%sAn_Yang4_Vol.bin", out_dir);
  if ((out_vol = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  
  sprintf(file_name, "%sAn_Yang4_Hlx.bin", out_dir);
  if ((out_hlx = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

/********************************************************************
********************************************************************/
/* MEMORY ALLOCATION */
/*
MemAlloc = NBlockA*Nlig + NBlockB
*/ 

/* Local Variables */
  NBlockA = 0; NBlockB = 0;
  /* Mask */ 
  NBlockA += Sub_Ncol+NwinC; NBlockB += NwinL*(Sub_Ncol+NwinC);

  /* Modd = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mdbl = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mvol = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mhlx = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Min = NpolarOut*Nlig*Sub_Ncol */
  NBlockA += NpolarOut*(Ncol+NwinC); NBlockB += NpolarOut*NwinL*(Ncol+NwinC);
  /* Mavg = NpolarOut */
  NBlockA += 0; NBlockB += NpolarOut*Sub_Ncol;
  
/* Reading Data */
  NBlockB += Ncol + 2*Ncol + NpolarIn*2*Ncol + NpolarOut*NwinL*(Ncol+NwinC);

  memory_alloc(file_memerr, Sub_Nlig, NwinL, &NbBlock, NligBlock, NBlockA, NBlockB, MemoryAlloc);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  _VC_in = vector_float(2*Ncol);
  _VF_in = vector_float(Ncol);
  _MC_in = matrix_float(4,2*Ncol);
  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   

  Valid = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);

  M_in = matrix3d_float(NpolarOut, NligBlock[0] + NwinL, Ncol + NwinC);
  //M_avg = matrix_float(NpolarOut, Sub_Ncol);
  M_odd = matrix_float(NligBlock[0], Sub_Ncol);
  M_dbl = matrix_float(NligBlock[0], Sub_Ncol);
  M_vol = matrix_float(NligBlock[0], Sub_Ncol);
  M_hlx = matrix_float(NligBlock[0], Sub_Ncol);

  //TT = vector_float(NpolarOut);
  
  //M = matrix3d_float(3, 3, 2);
  //V = matrix3d_float(3, 3, 2);
  //lambda = vector_float(3);
  
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
/* SPANMIN / SPANMAX DETERMINATION */
for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
if (FlagValid == 1) rewind(in_valid);

Span = 0.;
SpanMin = INIT_MINMAX;
SpanMax = -INIT_MINMAX;
  
for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
    read_block_S2_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
  /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }
  if (strcmp(PolTypeOut,"C3")==0) C3_to_T3(M_in, NligBlock[Nb], Sub_Ncol + NwinC, 0, 0);

#pragma omp parallel for private(col, M_avg) firstprivate(Span) shared(ligDone, SpanMin, SpanMax)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        Span = M_avg[C311][col]+M_avg[C322][col]+M_avg[C333][col];
        if (Span >= SpanMax) SpanMax = Span;
        if (Span <= SpanMin) SpanMin = Span;
        }       
      }
    free_matrix_float(M_avg,NpolarOut);
    }
  } // NbBlock

  if (SpanMin < eps) SpanMin = eps;

/********************************************************************
********************************************************************/
/* DATA PROCESSING */
for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
if (FlagValid == 1) rewind(in_valid);

for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
    read_block_S2_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
  /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }
  if (strcmp(PolTypeOut,"C3")==0) C3_to_T3(M_in, NligBlock[Nb], Sub_Ncol + NwinC, 0, 0);

Alpha = Entropy = alphak = pk = 0.;
a1 = a2 = a3 = a4 = a5 = h1 = h2 = 0.;
r1 = r2 = r3 = r4 = r5 = r6 = r7 = r8 = r9 = 0.;
HAlphaClass = teta = Pc = Pv = Ps = Pd = x11 = x22 = 0.;
#pragma omp parallel for private(col, Np, k, TT, M_avg, M, V, lambda) firstprivate(Alpha, Entropy, alphak, pk, a1, a2, a3, a4, a5, h1, h2, r1, r2, r3, r4, r5, r6, r7, r8, r9, HAlphaClass, teta, Pc, Pv, Ps, Pd, x11, x22) shared(ligDone)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    M = matrix3d_float(3, 3, 2);
    V = matrix3d_float(3, 3, 2);
    lambda = vector_float(3);  
    TT = vector_float(NpolarOut);
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        for (Np = 0; Np < NpolarOut; Np++) TT[Np] = M_avg[Np][col];
        M[0][0][0] = eps + M_avg[0][col];
        M[0][0][1] = 0.;
        M[0][1][0] = eps + M_avg[1][col];
        M[0][1][1] = eps + M_avg[2][col];
        M[0][2][0] = eps + M_avg[3][col];
        M[0][2][1] = eps + M_avg[4][col];
        M[1][0][0] =  M[0][1][0];
        M[1][0][1] = -M[0][1][1];
        M[1][1][0] = eps + M_avg[5][col];
        M[1][1][1] = 0.;
        M[1][2][0] = eps + M_avg[6][col];
        M[1][2][1] = eps + M_avg[7][col];
        M[2][0][0] =  M[0][2][0];
        M[2][0][1] = -M[0][2][1];
        M[2][1][0] =  M[1][2][0];
        M[2][1][1] = -M[1][2][1];
        M[2][2][0] = eps + M_avg[8][col];
        M[2][2][1] = 0.;

        /* EIGENVECTOR/EIGENVALUE DECOMPOSITION */
        /* V complex eigenvecor matrix, lambda real vector*/
        Diagonalisation(3, M, V, lambda);
  
        for (k = 0; k < 3; k++)  if (lambda[k] < 0.) lambda[k] = 0.;
        Alpha = 0.; Entropy = 0.;
        for (k = 0; k < 3; k++)  {
          alphak = acos(sqrt(V[0][k][0] * V[0][k][0] + V[0][k][1] * V[0][k][1]));
          pk = lambda[k] / (eps + lambda[0] + lambda[1] + lambda[2]);
          if (pk < 0.) pk = 0.; if (pk > 1.) pk = 1.;
          Alpha += alphak * pk;
          Entropy -= pk * log(pk + eps);
          }
        Alpha *= 180./pi;
        Entropy /= log(3.);
        
        a1 = (Alpha <= lim_al1);
        a2 = (Alpha <= lim_al2);
        a3 = (Alpha <= lim_al3);
        a4 = (Alpha <= lim_al4);
        a5 = (Alpha <= lim_al5);

        h1 = (Entropy <= lim_H1);
        h2 = (Entropy <= lim_H2);

        /* ZONE 1 (top right)*/
        r1 = !a1 * !h1;
        /* ZONE 2 (center right)*/
        r2 = a1 * !a5 * !h1;
        /* ZONE 3 (bottom right)*/
        r3 = a5 * !h1;
        /* ZONE 4 (top center)*/
        r4 = !a2 * h1 * !h2;
        /* ZONE 5 (center center)*/
        r5 = a2 * !a5 * h1 * !h2;
        /* ZONE 6 (bottom center)*/
        r6 = a5 * h1 * !h2;
        /* ZONE 7 (top left)*/
        r7 = !a3 * h2;
        /* ZONE 8 (center left)*/
        r8 = a3 * !a4 * h2;
        /* ZONE 9 (bottom left)*/
        r9 = a4 * h2;

        HAlphaClass = (float) r1 + 2. * r2 + 3. * r3 + 4. * r4 + 5. * r5 + 6. * r6 + 7. * r7 + 8. * r8 + 9. * r9;

        if ((HAlphaClass == 1.)||(HAlphaClass == 2.)||(HAlphaClass == 5.)) {
          DecompYam4(TT, &Ps, &Pd, &Pv, &Pc);
          }else {
          teta = 0.5 * atan(2*TT[T323_re]/(TT[T322]-TT[T333]));
          unitary_rotation(TT,teta);
          Pc = 2.*fabs(TT[T323_im]);          
          Pv = 3.*(TT[T333] - (Pc/2.));
          if (Pv < 0.) {
            DecompYam3(TT, &Ps, &Pd, &Pv);
            } else {
            if (Pv + Pc > TT[T311]+TT[T322]+TT[T333]) {
              Ps = 0.; Pd = 0.; Pv = TT[T311]+TT[T322]+TT[T333] - Pc;
              } else {
              if (TT[T311] < TT[T333] - (Pc/2.)) {
//                ALPre = 0.; ALPim = 0.;
//                BETre = 0.; BETim = 0.;
                Pv = 3.*TT[T311]; Ps = 0.;
                Pd = TT[T322]+TT[T333]-2.*TT[T311] - Pc;
                } else {
                Pv = 3.*(TT[T333] - (Pc/2.));
                x11 = TT[T311] - (TT[T333] - (Pc/2.));
                x22 = TT[T322] - TT[T333];
                if (TT[T312_re]*TT[T312_re]+TT[T312_im]*TT[T312_im] > x11*x22) {
                  if (x11 > x22) {
//                    ALPre = 0.; ALPim = 0.;
//                    BETre = TT[T312_re]*sqrt(x22/x11)/sqrt(TT[T312_re]*TT[T312_re]+TT[T312_im]*TT[T312_im]);
//                    BETim = TT[T312_im]*sqrt(x22/x11)/sqrt(TT[T312_re]*TT[T312_re]+TT[T312_im]*TT[T312_im]);
                    Ps = x11 + x22;
                    Pd = 0.;
                    } else { 
//                    BETre = 0.; BETim = 0.;
//                    ALPre = TT[T312_re]*sqrt(x11/x22)/sqrt(TT[T312_re]*TT[T312_re]+TT[T312_im]*TT[T312_im]);
//                    ALPim = TT[T312_im]*sqrt(x11/x22)/sqrt(TT[T312_re]*TT[T312_re]+TT[T312_im]*TT[T312_im]);
                    Pd = x11 + x22;
                    Ps = 0.;
                    }                
                  } else {
                  if (x11 > x22) {
//                    ALPre = 0.; ALPim = 0.;
//                    BETre = TT[T312_re]/x11;
//                    BETim = TT[T312_im]/x11;
                    Ps = x11 + (TT[T312_re]*TT[T312_re]+TT[T312_im]*TT[T312_im])/x11;
                    Pd = x22 - (TT[T312_re]*TT[T312_re]+TT[T312_im]*TT[T312_im])/x11;
                    } else { 
//                    BETre = 0.; BETim = 0.;
//                    ALPre = TT[T312_re]/x22;
//                    ALPim = TT[T312_im]/x22;
                    Ps = x11 - (TT[T312_re]*TT[T312_re]+TT[T312_im]*TT[T312_im])/x22;
                    Pd = x22 + (TT[T312_re]*TT[T312_re]+TT[T312_im]*TT[T312_im])/x22;
                    }                 
                  }                  
                }
              }
            }
          }
            
        if (Ps < SpanMin) Ps = SpanMin;
        if (Pd < SpanMin) Pd = SpanMin;
        if (Pv < SpanMin) Pv = SpanMin;
        if (Pc < SpanMin) Pc = SpanMin;

        if (Ps > SpanMax) Ps = SpanMax;
        if (Pd > SpanMax) Pd = SpanMax;
        if (Pv > SpanMax) Pv = SpanMax;
        if (Pc > SpanMax) Pc = SpanMax;

        M_odd[lig][col] = Ps;
        M_dbl[lig][col] = Pd;
        M_vol[lig][col] = Pv;
        M_hlx[lig][col] = Pc;

        } else {
        M_odd[lig][col] = 0.;
        M_dbl[lig][col] = 0.;
        M_vol[lig][col] = 0.;
        M_hlx[lig][col] = 0.;
        }
      }
    free_matrix3d_float(M, 3, 3);
    free_matrix3d_float(V, 3, 3);
    free_vector_float(lambda);  
    free_vector_float(TT);
    free_matrix_float(M_avg,NpolarOut);
    }

  write_block_matrix_float(out_odd, M_odd, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_dbl, M_dbl, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_vol, M_vol, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_hlx, M_hlx, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_avg, NpolarOut, NligBlock[0]);
  free_matrix_float(M_odd, NligBlock[0]);
  free_matrix_float(M_dbl, NligBlock[0]);
  free_matrix_float(M_vol, NligBlock[0]);
  free_matrix_float(M_hlx, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  fclose(out_odd);
  fclose(out_dbl);
  fclose(out_vol);
  fclose(out_hlx);
  
/********************************************************************
********************************************************************/

  return 1;
}

/********************************************************************
********************************************************************/
/********************************************************************
********************************************************************/

int unitary_rotation(float *TT, float teta)
{
  float T11, T12_re, T12_im, T13_re, T13_im;
  float T22, T23_re, T23_im;
  float T33;
  
  T11 = TT[T311]; 
  T12_re = TT[T312_re]; T12_im = TT[T312_im];
  T13_re = TT[T313_re]; T13_im = TT[T313_im];
  T22 = TT[T322]; 
  T23_re = TT[T323_re]; T23_im = TT[T323_im];
  T33 = TT[T333]; 

  TT[T311] = T11;
  TT[T312_re] = T12_re*cos(teta)+T13_re*sin(teta);
  TT[T312_im] = T12_im*cos(teta)+T13_im*sin(teta);
  TT[T313_re] = -T12_re*sin(teta)+T13_re*cos(teta);
  TT[T313_im] = -T12_im*sin(teta)+T13_im*cos(teta);
  TT[T322] = T22*cos(teta)*cos(teta)+2.*T23_re*cos(teta)*sin(teta)+T33*sin(teta)*sin(teta);
  TT[T323_re] = -T22*cos(teta)*sin(teta)+T23_re*cos(teta)*cos(teta)-T23_re*sin(teta)*sin(teta)+T33*cos(teta)*sin(teta);
  TT[T323_im] = T23_im*cos(teta)*cos(teta)+T23_im*sin(teta)*sin(teta);
  TT[T333] = T22*sin(teta)*sin(teta)+T33*cos(teta)*cos(teta) - 2.*T23_re*cos(teta)*sin(teta);
  
  return 1;
}

/********************************************************************
********************************************************************/
/********************************************************************
********************************************************************/

int DecompYam3(float *TTT,float *PPs,float *PPd,float *PPv)
{
  float FS, FD, FV;
  float ALPre, ALPim, BETre, BETim;
  float HHHH,HVHV,VVVV;
  float HHVVre, HHVVim;
  float rtemp, ratio;

  HHHH = (TTT[T311] + 2 * TTT[T312_re] + TTT[T322]) / 2.;
  HHVVre = (TTT[T311] - TTT[T322]) / 2.;
  HHVVim = -TTT[T312_im];
  HVHV = TTT[T333] / 2.;
  VVVV = (TTT[T311] - 2. * TTT[T312_re] + TTT[T322]) / 2.;
  
  /*Freeman - Yamaguchi algorithm*/
  ratio = 10.*log10(VVVV/HHHH);
  if (ratio <= -2.) {
    FV = 15. * HVHV / 4.;
    HHHH = HHHH - 8.*FV/15.;
    VVVV = VVVV - 3.*FV/15.;
    HHVVre = HHVVre - 2.*FV / 15.;
    }
  if (ratio > 2.) {
    FV = 15. * HVHV / 4.;
    HHHH = HHHH - 3.*FV/15.;
    VVVV = VVVV - 8.*FV/15.;
    HHVVre = HHVVre - 2.*FV / 15.;
    }
  if ((ratio > -2.)&&(ratio <= 2.)) {
    FV = 8. * HVHV / 2.;
    HHHH = HHHH - 3.*FV/8.;
    VVVV = VVVV - 3.*FV/8.;
    HHVVre = HHVVre - 1.*FV / 8.;
    }

  /*Case 1: Volume Scatter > Total*/
  if ((HHHH <= eps) || (VVVV <= eps)) {
    FD = 0.; FS = 0.;
    if ((ratio > -2.)&&(ratio <= 2.)) FV = (HHHH + 3.*FV/8.) + HVHV + (VVVV + 3.*FV/8.);
    if (ratio <= -2.) FV = (HHHH + 8.*FV/15.) + HVHV + (VVVV + 3.*FV/15.);
    if (ratio > 2.) FV = (HHHH + 3.*FV/15.) + HVHV + (VVVV + 8.*FV/15.);
 
    } else {
    /*Data conditionning for non realizable ShhSvv* term*/
    if ((HHVVre * HHVVre + HHVVim * HHVVim) > HHHH * VVVV) {
      rtemp = HHVVre * HHVVre + HHVVim * HHVVim;
      HHVVre = HHVVre * sqrt(HHHH * VVVV / rtemp);
      HHVVim = HHVVim * sqrt(HHHH * VVVV / rtemp);
      }
    /*Odd Bounce*/
    if (HHVVre >= 0.) {
      ALPre = -1.; ALPim = 0.;
      FD = (HHHH * VVVV - HHVVre * HHVVre - HHVVim * HHVVim) / (HHHH + VVVV + 2 * HHVVre);
      FS = VVVV - FD;
      BETre = (FD + HHVVre) / FS;
      BETim = HHVVim / FS;
      }
    /*Even Bounce*/
    if (HHVVre < 0.) {
      BETre = 1.; BETim = 0.;
      FS = (HHHH * VVVV - HHVVre * HHVVre - HHVVim * HHVVim) / (HHHH + VVVV - 2 * HHVVre);
      FD = VVVV - FS;
      ALPre = (HHVVre - FS) / FD;
      ALPim = HHVVim / FD;
      }
    }

  *PPs = FS * (1. + BETre * BETre + BETim * BETim);
  *PPd = FD * (1. + ALPre * ALPre + ALPim * ALPim);
  *PPv = FV;
  
  return 1;
}

/********************************************************************
********************************************************************/
/********************************************************************
********************************************************************/

int DecompYam4(float *TTT,float *PPs,float *PPd,float *PPv,float *PPc)
{
  float FS, FD, FV;
  float ALPre, ALPim, BETre, BETim;
  float HHHH,HVHV,VVVV;
  float HHVVre,HHVVim;

  float rtemp, ratio;
  float S, D, Cre, Cim, CO;

  float Ps, Pd, Pv, Pc, TP;

  Pc = 2. * fabs(TTT[T323_im]);

  /* Surface scattering */
  ratio = 10.*log10((TTT[T311] + TTT[T322]-2.*TTT[T312_re])/(TTT[T311] + TTT[T322]+2.*TTT[T312_re]));
  if ((ratio > -2.)&&(ratio <= 2.)) Pv = 2.*(2.*TTT[T333] - Pc); 
  else Pv = (15./8.)*(2.*TTT[T333] - Pc); 

  TP = TTT[T311] + TTT[T322] + TTT[T333];
  
  if (Pv < 0.) {
    /********************************************/
    /*Freeman - Yamaguchi 3-components algorithm*/
    /********************************************/
    HHHH = (TTT[T311] + 2 * TTT[T312_re] + TTT[T322]) / 2.;
    HHVVre = (TTT[T311] - TTT[T322]) / 2.;
    HHVVim = -TTT[T312_im];
    HVHV = TTT[T333] / 2.;
    VVVV = (TTT[T311] - 2. * TTT[T312_re] + TTT[T322]) / 2.;

    ratio = 10.*log10(VVVV/HHHH);
    if (ratio <= -2.) {
      FV = 15. * (HVHV / 4.);
      HHHH = HHHH - 8.*(FV/15.);
      VVVV = VVVV - 3.*(FV/15.);
      HHVVre = HHVVre - 2.*(FV/15.);
      }
    if (ratio > 2.) {
      FV = 15. * (HVHV/4.);
      HHHH = HHHH - 3.*(FV/15.);
      VVVV = VVVV - 8.*(FV/15.);
      HHVVre = HHVVre - 2.*(FV/15.);
      }
    if ((ratio > -2.)&&(ratio <= 2.)) {
      FV = 8. * (HVHV/2.);
      HHHH = HHHH - 3.*(FV/8.);
      VVVV = VVVV - 3.*(FV/8.);
      HHVVre = HHVVre - 1.*(FV/8.);
      }

    /*Case 1: Volume Scatter > Total*/
    if ((HHHH <= eps) || (VVVV <= eps)) {
      FD = 0.; FS = 0.;
      if ((ratio > -2.)&&(ratio <= 2.)) FV = (HHHH + 3.*(FV/8.)) + HVHV + (VVVV + 3.*(FV/8.));
      if (ratio <= -2.) FV = (HHHH + 8.*(FV/15.)) + HVHV + (VVVV + 3.*(FV/15.));
      if (ratio > 2.) FV = (HHHH + 3.*(FV/15.)) + HVHV + (VVVV + 8.*(FV/15.));
    
      } else {

      /*Data conditionning for non realizable ShhSvv* term*/
      if ((HHVVre * HHVVre + HHVVim * HHVVim) > HHHH * VVVV) {
        rtemp = HHVVre * HHVVre + HHVVim * HHVVim;
        HHVVre = HHVVre * sqrt((HHHH * VVVV) / rtemp);
        HHVVim = HHVVim * sqrt((HHHH * VVVV )/ rtemp);
        }
      /*Odd Bounce*/
      if (HHVVre >= 0.) {
        ALPre = -1.; ALPim = 0.;
        FD = (HHHH * VVVV - HHVVre * HHVVre - HHVVim * HHVVim) / (HHHH + VVVV + 2 * HHVVre);
        FS = VVVV - FD;
        BETre = (FD + HHVVre) / FS;
        BETim = HHVVim / FS;
        }
      /*Even Bounce*/
      if (HHVVre < 0.) {
        BETre = 1.; BETim = 0.;
        FS = (HHHH * VVVV - HHVVre * HHVVre - HHVVim * HHVVim) / (HHHH + VVVV - 2 * HHVVre);
        FD = VVVV - FS;
        ALPre = (HHVVre - FS) / FD;
        ALPim = HHVVim / FD;
        }
      }

    *PPs = FS * (1. + BETre * BETre + BETim * BETim);
    *PPd = FD * (1. + ALPre * ALPre + ALPim * ALPim);
    *PPv = FV;
    *PPc = 0.;

    } else {
    
    /********************************************/
    /*Yamaguchi 4-Components algorithm*/
    /********************************************/
          
    /* Surface scattering */
    S = TTT[T311] - (Pv / 2.);
    D = TP - Pv - Pc - S;
    Cre = TTT[T312_re] + TTT[T313_re];
    Cim = TTT[T312_im] + TTT[T313_im];
    if (ratio <= -2.) Cre = Cre - (Pv / 6.);
    if (ratio > 2.) Cre = Cre + (Pv / 6.);
            
    if ((Pv + Pc) > TP) {
      Ps = 0.;
      Pd = 0.;
      Pv = TP - Pc;
      } else {
      CO = 2.*TTT[T311] + Pc - TP;
      if (CO > 0.) {
        Ps = S + (Cre*Cre + Cim*Cim)/S;
        Pd = D - (Cre*Cre + Cim*Cim)/S;
        } else {
        Pd = D + (Cre*Cre + Cim*Cim)/D;
        Ps = S - (Cre*Cre + Cim*Cim)/D;
        }
      }
    if (Ps < 0.) {
      if (Pd < 0.) {
        Ps = 0.; Pd = 0.;
        Pv = TP - Pc;
        } else {
        Ps = 0.;
        Pd = TP - Pv - Pc;
        }
      } else {
      if (Pd < 0.) {
        Pd = 0.;
        Ps = TP - Pv - Pc;
        }
      }
            
    *PPs = Ps;
    *PPd = Pd;
    *PPv = Pv;
    *PPc = Pc;
    }
    
  return 1;
}
