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

File  : height_estimation_inversion_procedure_DEM.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2012
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
    laurent.ferro-famil@univ-rennes1.fr
*--------------------------------------------------------------------

Description :  Height Estimation from Inversion Procedures

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

/* LOCAL VARIABLES */

/* Input/Output file pointer arrays */
  FILE *gamma_high_file, *gamma_low_file, *Kz_file, *out_file;

/* Strings */
  char file_name[FilePathLength], file_kz[FilePathLength], file_gamma_high[FilePathLength], file_gamma_low[FilePathLength];

/* Internal variables */
  int lig, col;
  float x, y;

/* Matrix arrays */
  float *M_out;
  float *Gh;
  float *Gl;
  float *Kz;
  
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nheight_estimation_inversion_procedure_DEM.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-kz  	input kz file\n");
strcat(UsageHelp," (string)	-ifgh	input file : gamma high\n");
strcat(UsageHelp," (string)	-ifgl	input file : gamma low\n");
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
  get_commandline_prm(argc,argv,"-ifgh",str_cmd_prm,file_gamma_high,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifgl",str_cmd_prm,file_gamma_low,1,UsageHelp);
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
  check_file(file_gamma_high);
  check_file(file_gamma_low);
  check_file(file_kz);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/********************************************************************
********************************************************************/

/* MATRIX DECLARATION */
  Gh = vector_float(2*Sub_Ncol);
  Gl = vector_float(2*Sub_Ncol);
  Kz = vector_float(Sub_Ncol);
  M_out = vector_float(Sub_Ncol);

/*******************************************************************/
/*******************************************************************/

/* INPUT/OUTPUT FILE OPENING*/
  sprintf(file_name, "%s", file_gamma_high);
  if ((gamma_high_file = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s", file_gamma_low);
  if ((gamma_low_file = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s", file_kz);
  if ((Kz_file = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "DEM_diff_heights.bin");
  if ((out_file = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

/*******************************************************************/
/*******************************************************************/

/* OFFSET LINES READING */
  for (lig = 0; lig < Off_lig; lig++)
  {  
  fread(&Gh[0], sizeof(float), 2*Ncol, gamma_high_file);
  fread(&Gl[0], sizeof(float), 2*Ncol, gamma_low_file);
  fread(&Kz[0], sizeof(float), Ncol, Kz_file);
  }

/* FILES READING */
  for (lig = 0; lig < Sub_Nlig; lig++) {
    PrintfLine(lig,Sub_Nlig);  
    fread(&Gh[0], sizeof(float), 2*Ncol, gamma_high_file);
    fread(&Gl[0], sizeof(float), 2*Ncol, gamma_low_file);
    fread(&Kz[0], sizeof(float), Ncol, Kz_file);
    for (col = 0; col < Sub_Ncol; col++) {
      Gh[2*col] = Gh[2*(col + Off_col)]; Gh[2*col+1] = Gh[2*(col + Off_col)+1];
      Gl[2*col] = Gl[2*(col + Off_col)]; Gl[2*col+1] = Gl[2*(col + Off_col)+1];
      Kz[col] = Kz[col + Off_col];
      }
    for (col = 0; col < Sub_Ncol; col++) {
      x = Gh[2*col]*Gl[2*col]+Gh[2*col+1]*Gl[2*col+1];
      y = Gh[2*col+1]*Gl[2*col]-Gh[2*col]*Gl[2*col+1];
      M_out[col] = atan2(y,x) / (Kz[col] + eps);
      }
    fwrite(&M_out[0], sizeof(float), Sub_Ncol, out_file);
    }

  fclose(gamma_high_file);
  fclose(gamma_low_file);
  fclose(Kz_file);
  fclose(out_file);

return 1;
}


