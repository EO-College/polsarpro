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

File  : raney_decomposition.c
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

Description :  K. Raney Decomposition (m-delta and m-chi)

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

#define NPolType 2
/* LOCAL VARIABLES */
  FILE *out_m, *out_del, *out_chi;
  FILE *out_odd, *out_dbl, *out_rnd;
  int Config;
  char *PolTypeConf[NPolType] = {"SPP", "C2"};
  char file_name[FilePathLength];
  
/* Internal variables */
  int ii, lig, col;
  int ligDone = 0;

  float StkG0,StkG1,StkG2,StkG3;

/* Matrix arrays */
  float ***M_in;
  float **M_avg;
  float **M_m;
  float **M_del;
  float **M_chi;
  float **M_odd;
  float **M_dbl;
  float **M_rnd;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nraney_decomposition.exe\n");
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
  if (strcmp(PolType,"SPP")==0) strcpy(PolType,"SPPC2");
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
  sprintf(file_name, "%s%s", out_dir, "Raney_m.bin");
  if ((out_m = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "Raney_delta.bin");
  if ((out_del = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "Raney_chi.bin");
  if ((out_chi = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

    sprintf(file_name, "%s%s", out_dir, "Raney_Odd.bin");
  if ((out_odd = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "Raney_Dbl.bin");
  if ((out_dbl = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "Raney_Rnd.bin");
  if ((out_rnd = fopen(file_name, "wb")) == NULL)
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

  /* Mm = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mdelta = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mchi = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Modd = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mdbl = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mrnd = Nlig*Sub_Ncol */
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
  M_m = matrix_float(NligBlock[0], Sub_Ncol);
  M_del = matrix_float(NligBlock[0], Sub_Ncol);
  M_chi = matrix_float(NligBlock[0], Sub_Ncol);
  M_odd = matrix_float(NligBlock[0], Sub_Ncol);
  M_dbl = matrix_float(NligBlock[0], Sub_Ncol);
  M_rnd = matrix_float(NligBlock[0], Sub_Ncol);

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

for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}
 
  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    read_block_SPP_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

StkG0 = StkG1 = StkG2 = StkG3 = 0.;
#pragma omp parallel for private(col, M_avg) firstprivate(StkG0,StkG1,StkG2,StkG3) shared(ligDone)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        StkG0 = M_avg[C211][col] + M_avg[C222][col];
        StkG1 = M_avg[C211][col] - M_avg[C222][col];
        StkG2 = 2.*M_avg[C212_re][col];
        StkG3 = -2.*M_avg[C212_im][col];

        M_m[lig][col] = sqrt(StkG1*StkG1+StkG2*StkG2+StkG3*StkG3) / StkG0;
        M_del[lig][col] = atan2(StkG3,StkG2);
        M_chi[lig][col] = 0.5*asin(-StkG3/(M_m[lig][col] * StkG0));
        
        M_odd[lig][col] = sqrt(0.5 * M_m[lig][col] * StkG0 * (1. - sin(2. * M_chi[lig][col])));
        M_dbl[lig][col] = sqrt(0.5 * M_m[lig][col] * StkG0 * (1. + sin(2. * M_chi[lig][col])));
        M_rnd[lig][col] = sqrt(StkG0 * (1. - M_m[lig][col]));
        M_del[lig][col] = M_del[lig][col] * 180. / pi;
        M_chi[lig][col] = M_chi[lig][col] * 180. / pi;

        } else {
        M_m[lig][col] = 0.;
        M_del[lig][col] = 0.;
        M_chi[lig][col] = 0.;
        M_odd[lig][col] = 0.;
        M_dbl[lig][col] = 0.;
        M_rnd[lig][col] = 0.;
        }
      }
    free_matrix_float(M_avg,NpolarOut);
    }

  write_block_matrix_float(out_m, M_m, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_del, M_del, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_chi, M_chi, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_odd, M_odd, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_dbl, M_dbl, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_rnd, M_rnd, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_avg, NpolarOut, NligBlock[0]);
  free_matrix_float(M_m, NligBlock[0]);
  free_matrix_float(M_del, NligBlock[0]);
  free_matrix_float(M_chi, NligBlock[0]);
  free_matrix_float(M_odd, NligBlock[0]);
  free_matrix_float(M_dbl, NligBlock[0]);
  free_matrix_float(M_rnd, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  fclose(out_m);
  fclose(out_del);
  fclose(out_chi);
  fclose(out_odd);
  fclose(out_dbl);
  fclose(out_rnd);
  
/********************************************************************
********************************************************************/

  return 1;
}


