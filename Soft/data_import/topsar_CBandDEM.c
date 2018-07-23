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

File   : topsar_CBandDEM.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 2.0
Creation : 05/2011
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

Description :  Conversion from a JPL - TOPSAR Auxiliary Data File

********************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>


#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif


/* ALIASES  */

/* CONSTANTS  */

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
  FILE *in_file, *out_file, *headerfile;

/* Strings */
  char *buf;
  char file_name[FilePathLength], out_dir[FilePathLength], Tmp[FilePathLength], HeaderFile[FilePathLength];

/* Input variables */
  int Ncol;      /* Initial image nb of lines and rows */
  int Off_lig, Off_col;  /* Lines and rows offset values */
  int M_Nlig, M_Ncol;  /* Sub-image nb of lines and rows */

/* Internal variables */
  int i, j, MS, LS;
  long unsigned int kl, reclength;
  float DEMIncr, DEMOffset;

/* Matrix arrays */
  float *M_out;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ntopsar_CBandDEM.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input data file\n");
strcat(UsageHelp," (string)	-hf  	input header file\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
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

if(argc < 17) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,file_name,1,UsageHelp);
  get_commandline_prm(argc,argv,"-hf",str_cmd_prm,HeaderFile,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nc",int_cmd_prm,&Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&M_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&M_Ncol,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(file_name);
  check_dir(out_dir);
  check_file(HeaderFile);

/* Nb of lines and rows sub-sampled image */

  M_out = vector_float( M_Ncol);
  buf = vector_char(2 * Ncol);

/* READ HEADER FILE */
  if ((headerfile = fopen(HeaderFile, "rb")) == NULL)
  edit_error("Could not open input file : ", HeaderFile);
  rewind(headerfile);
  fscanf(headerfile, "%s\n", Tmp);
  fscanf(headerfile, "%s\n", Tmp); fscanf(headerfile, "%s\n", Tmp); fscanf(headerfile, "%s\n", Tmp);
  fscanf(headerfile, "%s\n", Tmp); fscanf(headerfile, "%s\n", Tmp); fscanf(headerfile, "%s\n", Tmp);
  fscanf(headerfile, "%s\n", Tmp); fscanf(headerfile, "%s\n", Tmp); fscanf(headerfile, "%s\n", Tmp); 
  fscanf(headerfile, "%s\n", Tmp); fscanf(headerfile, "%li\n", &reclength); fscanf(headerfile, "%s\n", Tmp); 
  fscanf(headerfile, "%s\n", Tmp); fscanf(headerfile, "%f\n", &DEMIncr); fscanf(headerfile, "%s\n", Tmp); 
  fscanf(headerfile, "%s\n", Tmp); fscanf(headerfile, "%f\n", &DEMOffset); fscanf(headerfile, "%s\n", Tmp); 
  fclose(headerfile);

/* INPUT/OUTPUT FILE OPENING*/

  if ((in_file = fopen(file_name, "rb")) == NULL)
  edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%sCBandDEM.bin", out_dir);
  if ((out_file = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open output file : ", file_name);

/* OFFSET HEADER DATA READING */
  rewind(in_file);
  for (kl = 0; kl < reclength; kl++) fgets(buf, 2, in_file);

/* OFFSET LINES READING */
  for (i = 0; i < Off_lig; i++)
  fread(&buf[0], sizeof(char), 2 * Ncol, in_file);

/* READING */
  for (i = 0; i < M_Nlig; i++) {
  if (i%(int)(M_Nlig/20) == 0) {printf("%f\r", 100. * i / (M_Nlig - 1));fflush(stdout);}

  fread(&buf[0], sizeof(char), 2 * Ncol, in_file);

  for (j = 0; j < M_Ncol; j++) {

    MS = buf[2*(Off_col + j)]; if (MS < 0) MS = MS + 256;
    LS = buf[2*(Off_col + j) + 1]; if (LS < 0) LS = LS + 256;
    M_out[j] = 256. * MS + LS;
    if (M_out[j] > 32767.) M_out[j] = M_out[j] - 65536.;
    M_out[j] = DEMIncr * M_out[j] + DEMOffset;
    if (my_isfinite(M_out[j]) == 0) M_out[j] = eps;
    }

  fwrite(&M_out[0], sizeof(float), M_Ncol, out_file);

  }        /*i */


/* FILE CLOSING */
  fclose(in_file);
  fclose(out_file);

  free_vector_float(M_out);

  return 1;
}        /*main */
