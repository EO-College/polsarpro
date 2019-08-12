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

File  : surface_inversion_histo.c
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

Description :  Surface Parameter Data Inversion : Histograms

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

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{

#define NPolType 5
/* LOCAL VARIABLES */
  FILE *out_ratio;
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C3", "C4", "T3", "T4"};
  char file_name[FilePathLength],statisticsbin1[FilePathLength],statisticsbin2[FilePathLength];
  
/* Internal variables */
  int ii, lig, col, Npts;
  float Shhhh, Shvhv, Svvvv;
  int ligDone = 0;

/* Matrix arrays */
  float ***M_in;
  float **M_avg;
  float *Ratio;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nsurface_inversion_histo.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (string)	-hvvv	output file (ratio HVHV / VVVV)\n");
strcat(UsageHelp," (string)	-hhvv	output file (ratio HHHH / VVVV)\n");
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

if(argc < 17) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-hvvv",str_cmd_prm,statisticsbin1,1,UsageHelp);
  get_commandline_prm(argc,argv,"-hhvv",str_cmd_prm,statisticsbin2,1,UsageHelp);
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

  if (strcmp(PolType,"S2")==0) strcpy(PolType,"S2C3");

/********************************************************************
********************************************************************/

  check_dir(in_dir);
  if (FlagValid == 1) check_file(file_valid);
  check_file(statisticsbin1);
  check_file(statisticsbin2);

  NwinL = 1; NwinC = 1;
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

  /* Ratio = Sub_Nlig*Sub_Ncol */
  NBlockA += 0; NBlockB += Sub_Nlig*Sub_Ncol;
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
  Ratio = vector_float(Sub_Nlig*Sub_Ncol);

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
Npts = -1;

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
  if (strcmp(PolTypeOut,"T3")==0) T3_to_C3(M_in, NligBlock[Nb], Sub_Ncol + NwinC, 0, 0);
  if (strcmp(PolTypeOut,"T4")==0) T4_to_C3(M_in, NligBlock[Nb], Sub_Ncol + NwinC, 0, 0);
  if (strcmp(PolTypeOut,"C4")==0) C4_to_C3(M_in, NligBlock[Nb], Sub_Ncol + NwinC, 0, 0);

#pragma omp parallel for private(col, M_avg) shared(ligDone)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        Shvhv = M_avg[C322][col]/2.;
        Svvvv = M_avg[C333][col];
        Npts++;
        Ratio[Npts] =  fabs(Shvhv/Svvvv);
        if (Ratio[Npts] > eps) Ratio[Npts] = 10. * log10(Ratio[Npts]);
        else Npts--;
        }
      }
    free_matrix_float(M_avg,NpolarOut);
    }
  } // NbBlock

  Npts++;

/* OUTPUT FILE OPENING*/
  strcpy(file_name, statisticsbin1);
  if ((out_ratio = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  fwrite(&Npts, sizeof(int),1,out_ratio);
  fwrite(&Ratio[0], sizeof(float),Npts,out_ratio);
  
  fclose(out_ratio);

/********************************************************************
********************************************************************/
for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
if (FlagValid == 1) rewind(in_valid);

Npts = -1;

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
  if (strcmp(PolTypeOut,"T3")==0) T3_to_C3(M_in, NligBlock[Nb], Sub_Ncol + NwinC, 0, 0);
  if (strcmp(PolTypeOut,"T4")==0) T4_to_C3(M_in, NligBlock[Nb], Sub_Ncol + NwinC, 0, 0);
  if (strcmp(PolTypeOut,"C4")==0) C4_to_C3(M_in, NligBlock[Nb], Sub_Ncol + NwinC, 0, 0);

#pragma omp parallel for private(col, M_avg) shared(ligDone)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        Shhhh = M_avg[C311][col];
        Svvvv = M_avg[C333][col];
        Npts++;
        Ratio[Npts] =  fabs(Shhhh/Svvvv);
        if (Ratio[Npts] > eps) Ratio[Npts] = 10. * log10(Ratio[Npts]);
        else Npts--;
        }
      }
    free_matrix_float(M_avg,NpolarOut);
    }
  } // NbBlock

  Npts++;

/* OUTPUT FILE OPENING*/
  strcpy(file_name, statisticsbin2);
  if ((out_ratio = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  fwrite(&Npts, sizeof(int),1,out_ratio);
  fwrite(&Ratio[0], sizeof(float),Npts,out_ratio);
  
  fclose(out_ratio);
  
/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_avg, NpolarOut, NligBlock[0]);
  free_vector_float(Ratio);
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/********************************************************************
********************************************************************/

  return 1;
}
