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

File  : scattering_mechanism_entropy_vanzyl.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2011
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

Description :  VanZyl 3 components Decomposition
Calculate the scattering mechanism entropy

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
  FILE *out_file;
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C3", "T3"};
  char file_name[FilePathLength];
  
/* Internal variables */
  int ii, lig, col;

  float Span, SpanMin, SpanMax;
  float CC11, CC13_re, CC13_im, CC22, CC33;
  float FV;
  float ALPre, ALPim, BETre, BETim;
  float HHHH,HVHV,VVVV;
  float HHVVre, HHVVim;
  float HHHHv,HVHVv,VVVVv;
  float HHVVvre;
  float ratio;
  float sq_rt, alp1, alp2, alp3, alpmin;
  float Lambda1, Lambda2;
  float OMEGA1, OMEGA2;
  float A0A0, B0pB;
  float ODD, DBL, VOL;
  float p1, p2, p3;

/* Matrix arrays */
  float ***M_avg;
  float **M_out;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nscattering_mechanism_entropy_vanzyl.exe\n");
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
strcat(UsageHelp," (int)   	-mem 	Allocated memory for blocksize determination (in Mb)\n");
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

  MemoryAlloc = -1;
  get_commandline_prm(argc,argv,"-mem",int_cmd_prm,&MemoryAlloc,0,UsageHelp);
  MemoryAlloc = my_max(MemoryAlloc,1000);

  FlagValid = 0;strcpy(file_valid,"");
  get_commandline_prm(argc,argv,"-mask",str_cmd_prm,file_valid,0,UsageHelp);
  if (strcmp(file_valid,"") != 0) FlagValid = 1;

  Config = 0;
  for (ii=0; ii<NPolType; ii++) if (strcmp(PolTypeConf[ii],PolType) == 0) Config = 1;
  if (Config == 0) edit_error("\nWrong argument in the Polarimetric Data Format\n",UsageHelpDataFormat);
  }

  if (strcmp(PolType,"S2")==0) strcpy(PolType,"S2C3");

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
  sprintf(file_name, "%s%s", out_dir, "entropy_scatt_mecha_vanzyl.bin");
  if ((out_file = fopen(file_name, "wb")) == NULL)
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
  NBlockA += Sub_Ncol; NBlockB += 0;

  /* Mout = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB = 0;
  /* Mavg = NpolarOut*Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB = 0;
  
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

  Valid = matrix_float(NligBlock[0], Sub_Ncol);

  M_avg = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);
  M_out = matrix_float(NligBlock[0], Sub_Ncol);

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
    for (lig = 0; lig < NligBlock[0]; lig++) 
      for (col = 0; col < Sub_Ncol; col++) 
        Valid[lig][col] = 1.;
 
/********************************************************************
********************************************************************/
/* SPANMIN / SPANMAX DETERMINATION */
for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
if (FlagValid == 1) rewind(in_valid);

SpanMin = INIT_MINMAX;
SpanMax = -INIT_MINMAX;
  
for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
  read_block_S2_avg(in_datafile, M_avg, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
  } else {
  /* Case of C,T or I */
  read_block_TCI_avg(in_datafile, M_avg, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
  }
  if (strcmp(PolTypeOut,"T3")==0) T3_to_C3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        Span = M_avg[C311][lig][col]+M_avg[C322][lig][col]+M_avg[C333][lig][col];
        if (Span >= SpanMax) SpanMax = Span;
        if (Span <= SpanMin) SpanMin = Span;
        }
      }
    }
  } // NbBlock

  if (SpanMin < eps) SpanMin = eps;

/********************************************************************
********************************************************************/
/* DATA PROCESSING */
for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
if (FlagValid == 1) rewind(in_valid);

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
  read_block_S2_avg(in_datafile, M_avg, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
  } else {
  /* Case of C,T or I */
  read_block_TCI_avg(in_datafile, M_avg, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
  }
  if (strcmp(PolTypeOut,"T3")==0) T3_to_C3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        CC11 = M_avg[C311][lig][col];
        CC13_re = M_avg[C313_re][lig][col];
        CC13_im = M_avg[C313_im][lig][col];
        CC22 = M_avg[C322][lig][col];
        CC33 = M_avg[C333][lig][col];

        HHHH = CC11; HVHV = CC22 / 2.; VVVV = CC33;
        HHVVre = CC13_re; HHVVim = CC13_im;

        /*Yamaguchi algorithm*/
        ratio = 10.*log10(VVVV/HHHH);
        if (ratio <= -2.) {
          HHHHv = 8.; VVVVv = 3.; HVHVv = 4.;  HHVVvre = 2.;
          }
        if (ratio > 2.) {
          HHHHv = 3.; VVVVv = 8.; HVHVv = 4.;  HHVVvre = 2.;
          }
        if ((ratio > -2.)&&(ratio <= 2.)) {
          HHHHv = 3.; VVVVv = 3.; HVHVv = 2.;  HHVVvre = 1.;
          }

        /*Van Zyl algorithm*/
        sq_rt = HHHH*VVVVv + VVVV*HHHHv - 2.*HHVVre*HHVVvre;
        sq_rt = sq_rt*sq_rt;
        sq_rt = sq_rt -4.*(HHVVvre*HHVVvre - HHHHv*VVVVv)*(HHVVre*HHVVre+HHVVim*HHVVim - HHHH*VVVV);
        sq_rt = sqrt(sq_rt + eps);

        alp1 = 2.*HHVVre*HHVVvre - (HHHH*VVVVv + VVVV*HHHHv) + sq_rt;
        alp1 = alp1 / 2. / (HHVVvre - HHHHv*VVVVv + eps);

        alp2 = 2.*HHVVre*HHVVvre - (HHHH*VVVVv + VVVV*HHHHv) - sq_rt;
        alp2 = alp2 / 2. / (HHVVvre - HHHHv*VVVVv + eps);

        alp3 = HVHV / HVHVv;

        alpmin = alp1;
        if (alp2 < alpmin) alpmin = alp2;
        if (alp3 < alpmin) alpmin = alp3;

        /* C reminder */
        if (ratio <= -2.) {
          FV = 15. * alpmin;
          HHHH = HHHH - 8.*alpmin;
          VVVV = VVVV - 3.*alpmin;
          HHVVre = HHVVre - 2.*alpmin;
          }
        if (ratio > 2.) {
          FV = 15. * alpmin;
          HHHH = HHHH - 3.*alpmin;
          VVVV = VVVV - 8.*alpmin;
          HHVVre = HHVVre - 2.*alpmin;
          }
        if ((ratio > -2.)&&(ratio <= 2.)) {
          FV = 8. * alpmin;
          HHHH = HHHH - 3.*alpmin;
          VVVV = VVVV - 3.*alpmin;
          HHVVre = HHVVre - 1.*alpmin;
          }

        /*Van Zyl 1992 algorithm*/
        sq_rt = (HHHH-VVVV)*(HHHH-VVVV) + 4*(HHVVre*HHVVre+HHVVim*HHVVim);
        sq_rt = sqrt(sq_rt + eps);

        Lambda1 = (HHHH+VVVV + sq_rt) / 2.;
        Lambda2 = (HHHH+VVVV - sq_rt) / 2.;

        ALPre = 2.*HHVVre / (VVVV - HHHH + sq_rt);
        ALPim = 2.*HHVVim / (VVVV - HHHH + sq_rt);

        BETre = 2.*HHVVre / (VVVV - HHHH - sq_rt);
        BETim = 2.*HHVVim / (VVVV - HHHH - sq_rt);

        OMEGA1 = Lambda1 * (VVVV - HHHH + sq_rt) * (VVVV - HHHH + sq_rt) / ((VVVV - HHHH + sq_rt)*(VVVV - HHHH + sq_rt) + 4.*(HHVVre*HHVVre+HHVVim*HHVVim));
        OMEGA2 = Lambda2 * (VVVV - HHHH - sq_rt) * (VVVV - HHHH - sq_rt) / ((VVVV - HHHH - sq_rt)*(VVVV - HHHH - sq_rt) + 4.*(HHVVre*HHVVre+HHVVim*HHVVim));

        /*Target Generator Determination*/
        A0A0 = OMEGA1*((1.+ALPre)*(1.+ALPre)+ALPim*ALPim);
        B0pB = OMEGA1*((1.-ALPre)*(1.-ALPre)+ALPim*ALPim);

        if (A0A0 > B0pB) {
          ODD = OMEGA1 * (1 + ALPre * ALPre + ALPim * ALPim);
          DBL = OMEGA2 * (1 + BETre * BETre + BETim * BETim);
          } else {
          DBL = OMEGA1 * (1 + ALPre * ALPre + ALPim * ALPim);
          ODD = OMEGA2 * (1 + BETre * BETre + BETim * BETim);
          }
        VOL = FV;

        if (ODD < 0.) ODD = 0.;
        if (ODD > SpanMax) ODD = SpanMax;

        if (DBL < 0.) DBL = 0.;
        if (DBL > SpanMax) DBL = SpanMax;

        if (VOL < 0.) VOL = 0.;
        if (VOL > SpanMax) VOL = SpanMax;

        p1 = ODD / (ODD + DBL + VOL);
        p2 = DBL / (ODD + DBL + VOL);
        p3 = VOL / (ODD + DBL + VOL);
  
        M_out[lig][col] = -(p1*log(p1)+p2*log(p2)+p3*log(p3))/log(3.);
        } else {
        M_out[lig][col] = 0.;
        }
      }
    }

  write_block_matrix_float(out_file, M_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_avg, NpolarOut, NligBlock[0]);
  free_matrix_float(M_out, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  fclose(out_file);
  
/********************************************************************
********************************************************************/

  return 1;
}


