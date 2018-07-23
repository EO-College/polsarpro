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

File  : phase_center_height_estimation.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2012
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
    laurent.ferro-famil@univ-rennes1.fr
*--------------------------------------------------------------------

Description :  Phase Center Heights determination

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

/* LOCAL VARIABLES */

/* Input/Output file pointer arrays */
  FILE *in_file, *out_file, *Kz_file;

/* Strings */
  char filename[FilePathLength], file_kz[FilePathLength], CohType[10];

/* Input variables */
  int Ncol;  /* Initial image nb of lines and rows */
  int Off_lig, Off_col;  /* Lines and rows offset values */
  int Sub_Nlig, Sub_Ncol;  /* Sub-image nb of lines and rows */

/* Internal variables */
  int lig, col;
  int CohAvgFlag;
  float x, y;

/* Matrix arrays */
  float *C_in;
  float *M_out;
  float *Kz;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nphase_center_height_estimation.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-kz  	input kz file\n");
strcat(UsageHelp," (string)	-type	coherence type\n");
strcat(UsageHelp," (int)   	-avg 	coherence average flag (1/0)\n");
strcat(UsageHelp," (int)   	-nc  	Number of Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
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
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-kz",str_cmd_prm,file_kz,1,UsageHelp);
  get_commandline_prm(argc,argv,"-avg",int_cmd_prm,&CohAvgFlag,1,UsageHelp);
  get_commandline_prm(argc,argv,"-type",str_cmd_prm,CohType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nc",int_cmd_prm,&Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  }

/********************************************************************
********************************************************************/
  
  check_dir(in_dir);
  check_dir(out_dir);
  check_file(file_kz);

/********************************************************************
********************************************************************/
  
/* MATRIX DECLARATION */
  C_in = vector_float(2 * Ncol);
  Kz = vector_float(Ncol);
  M_out = vector_float(Sub_Ncol);

/********************************************************************
********************************************************************/
  
/* INPUT/OUTPUT FILE OPENING*/
  sprintf(filename, "%scmplx_coh_%s.bin", in_dir,CohType);
  if (CohAvgFlag != 0) sprintf(filename, "%scmplx_coh_avg_%s.bin", in_dir,CohType);
  if ((in_file = fopen(filename, "rb")) == NULL) edit_error("Could not open input file : ", filename);

  sprintf(filename, "%sphase_center_height_%s.bin", out_dir,CohType);
  if (CohAvgFlag != 0) sprintf(filename, "%sphase_center_height_avg_%s.bin", in_dir,CohType);
  if ((out_file = fopen(filename, "wb")) == NULL) edit_error("Could not open input file : ", filename);

  sprintf(filename, "%s", file_kz);
  if ((Kz_file = fopen(filename, "rb")) == NULL)
  edit_error("Could not open input file : ", filename);

/********************************************************************
********************************************************************/

/* OFFSET LINES READING */
  for (lig = 0; lig < Off_lig; lig++) {  
    fread(&C_in[0], sizeof(float), 2 * Ncol, in_file);
    fread(&Kz[0], sizeof(float), Ncol, Kz_file);
    }

/* READING */
  for (lig = 0; lig < Sub_Nlig; lig++) {
    PrintfLine(lig,Sub_Nlig);
  
    fread(&C_in[0], sizeof(float), 2 * Ncol, in_file);
    fread(&Kz[0], sizeof(float), Ncol, Kz_file);

/* Row-wise shift */
    for (col = 0; col < Sub_Ncol; col++) {
      x = C_in[2*(col + Off_col)];
      y = C_in[2*(col + Off_col) + 1];
      M_out[col] = atan2(y, x) / (Kz[col + Off_col] + eps);
      }
    fwrite(&M_out[0], sizeof(float), Sub_Ncol, out_file);
    }  /*lig */

fclose(in_file);
fclose(out_file);

return 1;
}


