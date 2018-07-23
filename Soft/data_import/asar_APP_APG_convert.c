/*******************************************************************************
PolSARpro v5.0 is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 (1991) of the License, or any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. 

See the GNU General Public License (Version 2, 1991) for more details.

********************************************************************************


File   : asar_APP_APG_convert.c
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

Description :  Convert ASAR Binary Data Files (Format APP and APG)

*-------------------------------------------------------------------------------
Routines  :
void edit_error(char *s1,char *s2);
void check_file(char *file);
float *vector_float(int nrh);
void free_vector_float(float *m);
void write_config(char *dir, int Nlig, int Ncol, char *PolarCase, char *PolarType);
void my_randomize(void);
float my_eps_random(void);

*******************************************************************************/

/* C INCLUDES */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif


/* ROUTINES DECLARATION */
#include "../lib/matrix.h"
#include "../lib/util.h"

/* CHARACTER STRINGS */
char CS_Texterreur[80];

/* ACCESS FILE */
FILE *fileinput;
FILE *fileoutput1;
FILE *fileoutput2;
FILE *fid;

/* GLOBAL ARRAYS */
char *dataread;
float *datareal;
float *tmpreal;

/*******************************************************************************
Routine  : main
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2003
Update  :
*-------------------------------------------------------------------------------

Description :  Convert ASAR Binary Data Files (Format APP and APG)

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

  char FileInput[FilePathLength];
  char DirOutput[FilePathLength];
  char FileOutput1[FilePathLength];
  char FileOutput2[FilePathLength];
  char PolarCase[20], PolarType[20];

  int lig, col, k, l;
  int Ncol, NN;
  int Nligoffset, Ncoloffset;
  int Nligfin, Ncolfin;
  int SubSampRG, SubSampAZ;
  int MDSOffset = 17;
  long unsigned int MPHOffset1, MPHOffset2;
  int MS, LS;

/******************************************************************************/
/* INPUT PARAMETERS */
/******************************************************************************/

  if (argc == 15) {
  strcpy(FileInput, argv[1]);
  strcpy(DirOutput, argv[2]);
  strcpy(FileOutput1, argv[3]);
  strcpy(FileOutput2, argv[4]);
  Ncol = atoi(argv[5]);
  Nligoffset = atoi(argv[6]);
  Ncoloffset = atoi(argv[7]);
  Nligfin = atoi(argv[8]);
  Ncolfin = atoi(argv[9]);
  MPHOffset1 = atol(argv[10]);
  MPHOffset2 = atol(argv[11]);
  SubSampRG = atoi(argv[12]);
  SubSampAZ = atoi(argv[13]);
  strcpy(PolarType, argv[14]);
  } else {
  printf
    ("TYPE: asar_APP_APG_convert FileInput DirOutput FileOutput1 FileOutput2 Ncol\n");
  printf
    ("OffsetLig OffsetCol FinalNlig FinalNcol MPHOffset1 MPHOffset2\n");
  printf("SubSamplingRG SubSamplingAZ PolarType\n");
  exit(1);
  }

  dataread = vector_char(MDSOffset + 2*Ncol);
  tmpreal = vector_float(Ncol);
  datareal = vector_float(Ncol);

  check_file(FileInput);
  check_dir(DirOutput);
  check_file(FileOutput1);
  check_file(FileOutput2);

/* OUPUT CONFIGURATIONS */
  strcpy(PolarCase, "intensities");

/* Nb of lines and rows sub-sampled image */
  Nligfin = (int) floor(Nligfin / SubSampAZ);
  Ncolfin = (int) floor(Ncolfin / SubSampRG);

  write_config(DirOutput, Nligfin, Ncolfin, PolarCase, PolarType);

  my_randomize();

/******************************************************************************/
/* INPUT / OUTPUT BINARY DATA FILES */
/******************************************************************************/

  if ((fileinput = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  if ((fileoutput1 = fopen(FileOutput1, "wb")) == NULL)
  edit_error("Could not open output file : ", FileOutput1);

  if ((fileoutput2 = fopen(FileOutput2, "wb")) == NULL)
  edit_error("Could not open output file : ", FileOutput2);

/******************************************************************************/
  rewind(fileinput);
  NN = floor(MPHOffset1 / (2*Ncol));
  for (k=0; k<NN; k++)
    {
    fread(&dataread[0], sizeof(char), 2*Ncol, fileinput);
    }
  fread(&dataread[0], sizeof(char), MPHOffset1-NN*2*Ncol, fileinput);

  for (lig = 0; lig < Nligoffset; lig++)
    fread(&dataread[0], sizeof(char), MDSOffset + 2*Ncol, fileinput);

  for (lig = 0; lig < Nligfin; lig++) {
  if (lig%(int)(Nligfin/20) == 0) {printf("%f\r", 100. * lig / (Nligfin - 1));fflush(stdout);}

  fread(&dataread[0], sizeof(char), MDSOffset + 2*Ncol, fileinput);
  for (col = 0; col < Ncol; col++) {
    MS = dataread[MDSOffset + 2*col];
    if (MS < 0)  MS = MS + 256;
    LS = dataread[MDSOffset + 2*col + 1];
    if (LS < 0)  LS = LS + 256;
    tmpreal[col] = 256. * MS + LS;
    if (tmpreal[col] < eps)  tmpreal[col] = my_eps_random();
  }

  for (col = 0; col < Ncolfin; col++) {
    datareal[col] = tmpreal[Ncoloffset + col * SubSampRG]* tmpreal[Ncoloffset + col * SubSampRG];
    if (my_isfinite(datareal[col]) == 0) datareal[col] = eps;
    }

  fwrite(&datareal[0], sizeof(float), Ncolfin, fileoutput1);

  for (l = 1; l < SubSampAZ; l++)
   fread(&dataread[0], sizeof(char), MDSOffset + 2*Ncol, fileinput);

  }

/******************************************************************************/
  rewind(fileinput);
  NN = floor(MPHOffset2 / (2*Ncol));
  for (k=0; k<NN; k++)
    {
    fread(&dataread[0], sizeof(char), 2*Ncol, fileinput);
    }
  fread(&dataread[0], sizeof(char), MPHOffset2-NN*2*Ncol, fileinput);

  for (lig = 0; lig < Nligoffset; lig++)
    fread(&dataread[0], sizeof(char), MDSOffset + 2*Ncol, fileinput);

  for (lig = 0; lig < Nligfin; lig++) {
  if (lig%(int)(Nligfin/20) == 0) {printf("%f\r", 100. * lig / (Nligfin - 1));fflush(stdout);}

  fread(&dataread[0], sizeof(char), MDSOffset + 2*Ncol, fileinput);
  for (col = 0; col < Ncol; col++) {
    MS = dataread[MDSOffset + 2*col];
    if (MS < 0)  MS = MS + 256;
    LS = dataread[MDSOffset + 2*col + 1];
    if (LS < 0)  LS = LS + 256;
    tmpreal[col] = 256. * MS + LS;
    if (tmpreal[col] < eps) tmpreal[col] = my_eps_random();
  }

  for (col = 0; col < Ncolfin; col++) {
    datareal[col] = tmpreal[Ncoloffset + col * SubSampRG]*tmpreal[Ncoloffset + col * SubSampRG];
    if (my_isfinite(datareal[col]) == 0) datareal[col] = eps;
    }

  fwrite(&datareal[0], sizeof(float), Ncolfin, fileoutput2);

  for (l = 1; l < SubSampAZ; l++)
   fread(&dataread[0], sizeof(char), MDSOffset + 2*Ncol, fileinput);

  }

  fclose(fileinput);
  fclose(fileoutput1);
  fclose(fileoutput2);

  return 1;
}
