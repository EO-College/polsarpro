/*******************************************************************************
PolSARpro v5.0 is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 (1991) of the License, or any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. 

See the GNU General Public License (Version 2, 1991) for more details.

********************************************************************************


File   : asar_data_format_type.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Version  : 2.0
Creation : 01/2004
Update  :


*-------------------------------------------------------------------------------
INSTITUT D'ELECTRONIQUE et de TELECOMMUNICATIONS de RENNES (I.E.T.R)
UMR CNRS 6164
Groupe Image et Teledetection
Equipe SAPHIR (SAr Polarimetrie Holographie Interferometrie Radargrammetrie)
UNIVERSITE DE RENNES I
Pôle Micro-Ondes Radar
Bât. 11D - Campus de Beaulieu
263 Avenue Général Leclerc
35042 RENNES Cedex
Tel :(+33) 2 23 23 57 63
Fax :(+33) 2 23 23 69 63
e-mail : eric.pottier@univ-rennes1.fr, laurent.ferro-famil@univ-rennes1.fr
*-------------------------------------------------------------------------------

Description :  Read ASAR Data Format Type from Header

*-------------------------------------------------------------------------------
Routines  :
void edit_error(char *s1,char *s2);
void check_file(char *file);
void check_dir(char *dir);

*******************************************************************************/
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
#include "../lib/graphics.h"
#include "../lib/matrix.h"
#include "../lib/processing.h"
#include "../lib/util.h"


/* CHARACTER STRINGS */
char CS_Texterreur[80];

/* ACCESS FILE */
FILE *fileinput;
FILE *fileheader;

/*******************************************************************************
Routine  : main
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2004
Update  :
*-------------------------------------------------------------------------------

Description :  Read ASAR Data Format Type from Header

*-------------------------------------------------------------------------------
Inputs arguments :
argc : nb of input arguments
argv : input arguments array
Returned values  :
void
*******************************************************************************/

int main(int argc, char *argv[])
/*                                      */
{

/* LOCAL VARIABLES */

  char FileInput[FilePathLength], FileFormat[FilePathLength], Buf[100], Tmp[100];


/******************************************************************************/
/* INPUT PARAMETERS */
/******************************************************************************/

  if (argc == 3) {
  strcpy(FileInput, argv[1]);
  strcpy(FileFormat, argv[2]);
  } else {
  printf("TYPE: asar_data_format_type  FileInput FormatOutputFile\n");
  exit(1);
  }

  check_file(FileInput);
  check_file(FileFormat);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

  if ((fileinput = fopen(FileInput, "r")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  if ((fileheader = fopen(FileFormat, "w")) == NULL)
  edit_error("Could not open configuration file : ", FileFormat);

  //for (ii = 0; ii < 42; ii++)
  //fgets(&Buf[0], 100, fileinput);
  //strcpy(Tmp, "");
  //strncat(Tmp, &Buf[16], 28);

  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[9], 7);
  fprintf(fileheader, "%s", &Tmp[0]);

  fclose(fileheader);
  fclose(fileinput);

  return 1;
}
