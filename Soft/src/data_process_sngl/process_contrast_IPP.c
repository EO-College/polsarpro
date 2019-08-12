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

File   : process_contrast_IPP.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2011
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

Description :  Process the Contrast Parameter
Contrast = g1 / g0 = (Ip-Ic)/(Ip+Ic)

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

/* LOCAL VARIABLES */
  FILE *fileinput[3], *fileoutput;
  char file_name[FilePathLength];
  char *file_name_in_IPP[4] = { "I11.bin", "I21.bin", "I12.bin", "I22.bin" };
  
/* Internal variables */
  int lig, col;
  int PolIn[4];
  int index, Npolar = 2;

/* Matrix arrays */
  float **bufferin;
  float *bufferout;

  float *ValidMask;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nprocess_contrast_IPP.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (int)   	-ind 	index (1/2)\n");
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

if(argc < 15) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ind",int_cmd_prm,&index,1,UsageHelp);

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

  check_dir(in_dir);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);
  
  NwinL = 1; NwinC = 1;
  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);

  if (index == 1) {
    PolIn[0] = s11;
    PolIn[1] = s21;
    }
  if (index == 2) {
    PolIn[0] = s22;
    PolIn[1] = s12;
    }

/* INPUT FILE OPENING*/
  for (Np = 0; Np < Npolar; Np++) {
    sprintf(file_name, "%s%s", in_dir, file_name_in_IPP[PolIn[Np]]);
    if ((fileinput[Np] = fopen(file_name, "rb")) == NULL)
      edit_error("Could not open input file : ", file_name);
    }
    
  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
    if (index == 1) sprintf(file_name, "%s%s", out_dir, "Intensities_Contrast1.bin");
    if (index == 2) sprintf(file_name, "%s%s", out_dir, "Intensities_Contrast2.bin");
    if ((fileoutput = fopen(file_name, "wb")) == NULL)
      edit_error("Could not open input file : ", file_name);

/********************************************************************
********************************************************************/

/* MATRIX ALLOCATION */

  ValidMask = vector_float(Ncol);

  bufferin = matrix_float(Npolar, Ncol);
  bufferout = vector_float(Sub_Ncol);
    
/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
    for (col = 0; col < Sub_Ncol; col++) 
      ValidMask[col] = 1.;

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

  for (lig = 0; lig < Off_lig; lig++) {
    for (Np = 0; Np < Npolar; Np++) fread(&bufferin[Np][0], sizeof(float), Ncol, fileinput[Np]);
    if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    }
    
  for (lig = 0; lig < Sub_Nlig; lig++) {
    PrintfLine(lig,Sub_Nlig);
    for (Np = 0; Np < Npolar; Np++) fread(&bufferin[Np][0], sizeof(float), Ncol, fileinput[Np]);
    if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    for (col = 0; col < Sub_Ncol; col++) {
      if (ValidMask[col+Off_col] == 1.) {
        bufferout[col] = (bufferin[0][col + Off_col]-bufferin[1][col + Off_col]);
        bufferout[col] = bufferout[col]/(eps+bufferin[0][col + Off_col]+bufferin[1][col + Off_col]);
        } else {
        bufferout[col] = 0.;
        }
      }
    fwrite(&bufferout[0], sizeof(float), Sub_Ncol, fileoutput);
    }

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_vector_float(ValidMask);

  free_matrix_float(bufferin, Npolar);
  free_vector_float(bufferout);
*/  
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  fclose(fileoutput);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  for (Np = 0; Np < Npolar; Np++) fclose(fileinput[Np]);

/********************************************************************
********************************************************************/

  return 1;
}


