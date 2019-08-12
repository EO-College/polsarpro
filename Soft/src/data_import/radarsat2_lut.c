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

File   : radarsat2_lut.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 10/2008
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

Description :  Create a Output Scaling Look-Up-Table Array File

********************************************************************/
/* C INCLUDES */
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

/* ACCESS FILE */
FILE *file_in;
FILE *file_out;

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

  char DirInput[FilePathLength];
  char FileName[FilePathLength];

  char Buf[100], Tmp[100];
  int Ncol, i;
//  float Offset;
  float *LutArray;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nradarsat2_lut.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (int)   	-nc  	Final Number of Col\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 5) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,DirInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nc",int_cmd_prm,&Ncol,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_dir(DirInput);

  LutArray = vector_float(Ncol);
  
  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/*******************************************************************/
/* INPUT FILE */
/*******************************************************************/

  sprintf(FileName, "%s%s", DirInput, "product_lut.txt");
  if ((file_in = fopen(FileName, "r")) == NULL)
    edit_error("Could not open output file : ", FileName);

  rewind(file_in);

  fgets(&Buf[0], 100, file_in); fgets(&Buf[0], 100, file_in);  fgets(&Buf[0], 100, file_in);
  fgets(&Buf[0], 100, file_in); fgets(&Buf[0], 100, file_in);  fgets(&Buf[0], 100, file_in);

  fgets(&Buf[0], 100, file_in); strcpy(Tmp, ""); strncat(Tmp, &Buf[71], strlen(Buf) - 71); //Offset = floor(atof(Tmp));
  fgets(&Buf[0], 71, file_in);
  for (i = 0; i < Ncol; i++) {
    fscanf(file_in, "%f ", &LutArray[i]);
  }

  fclose(file_in);

/*******************************************************************/
/* WRITE LUT FILE */
/*******************************************************************/

  sprintf(FileName, "%s%s", DirInput, "product_lut.bin");
  if ((file_out = fopen(FileName, "wb")) == NULL)
    edit_error("Could not open output file : ", FileName);

  fwrite(&LutArray[0], sizeof(float), Ncol, file_out);
  fclose(file_out);

  free_vector_float(LutArray);

  return 1;
}



