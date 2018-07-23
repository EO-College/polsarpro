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

File   : test_SU_matX.c
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

*--------------------------------------------------------------------

Description :  Test if matrix is a SU matrix

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
  FILE *in_file, *out_file;
  char file_in[FilePathLength], file_out[FilePathLength], Tmp[100];
  
/* Internal variables */
  int ii, jj, Dim;

/* Matrix arrays */
  float ***MatX;
  float *det;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ntest_SU_matX.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input file matX\n");
strcat(UsageHelp," (string)	-of  	output file\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(argc < 19) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,file_in,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,file_out,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(file_in);
  check_file(file_out);
 
/********************************************************************
********************************************************************/

  if ((in_file = fopen(file_in, "r")) == NULL)
      edit_error("Could not open input file : ", file_in);
     
  if ((out_file = fopen(file_out, "w")) == NULL)
      edit_error("Could not open input file : ", file_out);
  
/********************************************************************
********************************************************************/
/* READ matX DATA */

  det = vector_float(2);
  fscanf(in_file, "%s\n", Tmp);
  fscanf(in_file, "%s\n", Tmp);
  fscanf(in_file, "%i\n", &Dim);
  MatX = matrix3d_float(Dim, Dim, 2); 
  for (ii = 0; ii < Dim; ii++) {  
    for (jj = 0; jj < Dim; jj++) {  
    fscanf(in_file, "%f\n", &MatX[ii][jj][0]);
    fscanf(in_file, "%f\n", &MatX[ii][jj][1]);
    }
  }
  fclose(in_file);

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

  if (Dim == 2) DeterminantCmplxMatrix2(MatX, det);
  if (Dim == 3) DeterminantCmplxMatrix3(MatX, det);
  if (Dim == 4) DeterminantCmplxMatrix4(MatX, det);

  if ((1. - eps <= det[0])&&(det[0] <= 1. + eps)&&(- eps <= det[1])&&(det[1] <= + eps)) fprintf(out_file,"OK\n");
  else fprintf(out_file,"KO\n");
  
  fclose(out_file);
  
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  fclose(out_file);

/* INPUT FILE CLOSING*/
  fclose(in_file);
  
/********************************************************************
********************************************************************/

  return 1;
}


