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

File   : create_mask_valid_pixels.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2010
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

Description :  Create a mask file of valid pixels with :
           (span != 0.) & (span > 0.) & (span != NaN) & (span != Inf)

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

#define NPolType 9
/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = {
    "S2", "C2", "C3","C4", 
    "T3", "T4", "T6", "SPP", "IPP" };
  
/* Internal variables */
  int ii, lig, col;

/* Matrix arrays */
  float ***M_in;
  float **M_out;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncreate_mask_valid_pixels.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-idf	input data format\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
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

if(argc < 15) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-idf",str_cmd_prm,PolType,1,UsageHelp);
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

  NwinL = 1; NwinC = 1;
  
/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);

/* POLAR TYPE CONFIGURATION */
  if (strcmp(PolType,"S2")==0) strcpy(PolType, "S2T3");
  if (strcmp(PolType,"SPP")==0) strcpy(PolType, "SPPC2");
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);

  file_name_in = matrix_char(NpolarIn,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir, file_name_in);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
    if ((in_datafile[Np] = fopen(file_name_in[Np], "rb")) == NULL)
      edit_error("Could not open input file : ", file_name_in[Np]);

/* OUTPUT FILE OPENING*/
  sprintf(file_valid, "%s%s", out_dir, "mask_valid_pixels.bin");
  if ((in_valid = fopen(file_valid, "wb")) == NULL)
    edit_error("Could not open input file : ", file_valid);

/********************************************************************
********************************************************************/
/* MEMORY ALLOCATION */
/*
MemAlloc = NBlockA*Nlig + NBlockB
*/ 

/* Local Variables */
  NBlockA = 0; NBlockB = 0;
  /* Mout = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Min = NpolarOut*Nlig*Ncol */
  NBlockA += NpolarOut*Ncol; NBlockB += NpolarOut*Ncol;

/* Reading Data */
  NBlockB += Ncol + 2*Ncol + NpolarIn*2*Ncol + NpolarOut*NwinL*(Ncol+NwinC);

  memory_alloc(file_memerr, Nlig, 0, &NbBlock, NligBlock, NBlockA, NBlockB, MemoryAlloc);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  _VC_in = vector_float(2*Ncol);
  _VF_in = vector_float(Ncol);
  _MC_in = matrix_float(4,2*Ncol);
  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   
 
  M_in = matrix3d_float(NpolarOut, NligBlock[0], Ncol);
  M_out = matrix_float(NligBlock[0], Sub_Ncol);

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {

    if (strcmp(PolTypeIn,"S2")==0) {
      read_block_S2_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
      } else {
      read_block_SPP_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
      }

    } else {

    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    }

  /* Span Determination */
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if ((strcmp(PolTypeOut,"C2")==0) || (strcmp(PolTypeOut,"C2pp1")==0) || (strcmp(PolTypeOut,"C2pp2")==0) || (strcmp(PolTypeOut,"C2pp3")==0)) 
        span = M_in[0][lig][col]+M_in[3][lig][col];
      if ((strcmp(PolTypeOut,"C3")==0) || (strcmp(PolTypeOut,"T3")==0)) 
        span = M_in[0][lig][col]+M_in[5][lig][col]+M_in[8][lig][col];
      if ((strcmp(PolTypeOut,"C4")==0) || (strcmp(PolTypeOut,"T4")==0)) 
        span = M_in[0][lig][col]+M_in[7][lig][col]+M_in[12][lig][col]+M_in[15][lig][col];
      if (strcmp(PolTypeOut,"T6")==0) 
        span = M_in[0][lig][col]+M_in[11][lig][col]+M_in[20][lig][col]+M_in[27][lig][col]+M_in[32][lig][col]+M_in[35][lig][col];
      if (strcmp(PolTypeOut,"IPPpp4")==0) 
        span = M_in[0][lig][col]+M_in[1][lig][col]+M_in[2][lig][col];
      if ((strcmp(PolTypeOut,"IPPpp5")==0) || (strcmp(PolTypeOut,"IPPpp6")==0) || (strcmp(PolTypeOut,"IPPpp7")==0)) 
        span = M_in[0][lig][col]+M_in[1][lig][col];
      if (strcmp(PolTypeOut,"IPPfull")==0) 
        span = M_in[0][lig][col]+M_in[1][lig][col]+M_in[2][lig][col]+M_in[3][lig][col];
      M_out[lig][col] = 0.0;
      if ((span != 0.)&&( span > 0.)&&(my_isfinite(span) != 0)) M_out[lig][col] = 1.0;
      }
    }
  
  write_block_matrix_float(in_valid, M_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */

  free_matrix3d_float(M_in, NpolarOut, NligBlock[0]);
  free_matrix_float(M_out, NligBlock[0]);
  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);

/* OUTPUT FILE CLOSING*/
  fclose(in_valid);

/********************************************************************
********************************************************************/

  return 1;
}
