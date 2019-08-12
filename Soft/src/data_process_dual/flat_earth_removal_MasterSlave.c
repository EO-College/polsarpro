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

File  : flat_earth_removal_MasterSlave.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 06/2012
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

Description :  Remove the Flat Earth on the Master and Slave
               Directory data sets.

Master
if conjugate = 0 => sij = sij * exp(complex(0, +flatearth/2))
if conjugate = 1 => sij = sij * exp(complex(0, -flatearth/2))
Slave
if conjugate = 0 => sij = sij * exp(complex(0, -flatearth/2))
if conjugate = 1 => sij = sij * exp(complex(0, +flatearth/2))

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

/* CHARACTER STRINGS */
char CS_Texterreur[80];

/* CONSTANTS  */

/* GLOBAL ARRAYS */
float *FlatEarth;
float **M_in;
float **M_out;

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

  FILE *in_file1[4], *out_file1[4], *flatearth_file;
  FILE *in_file2[4], *out_file2[4];

  char DirInput1[FilePathLength],DirOutput1[FilePathLength],file_name[FilePathLength];
  char DirInput2[FilePathLength],DirOutput2[FilePathLength];
  char FlatEarthFile[FilePathLength], FlatEarthFormat[10];
  char *FileInputOutputS2[4] = { "s11.bin", "s12.bin", "s21.bin", "s22.bin"};
  char *FileInputOutputSPP1[2] = { "s11.bin", "s21.bin"};
  char *FileInputOutputSPP2[2] = { "s12.bin", "s22.bin"};
  char *FileInputOutputSPP3[2] = { "s11.bin", "s22.bin"};
  char PolarCase[20], PolarType[20], InputFormat[10];

  int lig, col, np;
  int Npolar;
  int Nlig,Ncol,ConjugateFlag;
  int FlatEarthIEEE;
  float xang, xr, xi;
  char *pc;
  float fl1, fl2;
  float *v;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nflat_earth_removal_MasterSlave.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-idm 	input master directory\n");
strcat(UsageHelp," (string)	-ids 	input slave directory\n");
strcat(UsageHelp," (string)	-odm 	output master directory\n");
strcat(UsageHelp," (string)	-ods 	output slave directory\n");
strcat(UsageHelp," (string)	-fe  	input flat Earth file\n");
strcat(UsageHelp," (string)	-fmt 	output format (cmplx / realdeg / realrad)\n");
strcat(UsageHelp," (int)   	-cf  	conjugate flag (1/0)\n");
strcat(UsageHelp," (int)   	-ieee	ieee flag (1/0)\n");
strcat(UsageHelp," (string)	-idf 	input data format (SPP, S2)\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 19) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-idm",str_cmd_prm,DirInput1,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ids",str_cmd_prm,DirInput2,1,UsageHelp);
  get_commandline_prm(argc,argv,"-odm",str_cmd_prm,DirOutput1,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ods",str_cmd_prm,DirOutput2,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fe",str_cmd_prm,FlatEarthFile,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fmt",str_cmd_prm,FlatEarthFormat,1,UsageHelp);
  get_commandline_prm(argc,argv,"-cf",int_cmd_prm,&ConjugateFlag,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ieee",int_cmd_prm,&FlatEarthIEEE,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_dir(DirInput1);
  check_dir(DirOutput1);
  check_dir(DirInput2);
  check_dir(DirOutput2);
  check_file(FlatEarthFile);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(DirInput1, &Nlig, &Ncol, PolarCase, PolarType);

  if (strcmp(InputFormat,"S2") == 0) Npolar = 4;
  else Npolar = 2;

  M_in = matrix_float(2*Npolar, 2 * Ncol);
  M_out = matrix_float(2*Npolar, 2 * Ncol);
  if (strcmp(FlatEarthFormat,"cmplx") ==0 ) FlatEarth = vector_float(2 * Ncol);
  else FlatEarth = vector_float(Ncol);

/*******************************************************************/
/* INPUT / OUTPUT BINARY DATA FILES */
/*******************************************************************/
  if (strcmp(InputFormat,"S2") == 0) {
    for (np = 0; np < Npolar; np++) {
      sprintf(file_name, "%s%s", DirInput1, FileInputOutputS2[np]);
      if ((in_file1[np] = fopen(file_name, "rb")) == NULL)
        edit_error("Could not open input file : ", file_name);
      sprintf(file_name, "%s%s", DirInput2, FileInputOutputS2[np]);
      if ((in_file2[np] = fopen(file_name, "rb")) == NULL)
        edit_error("Could not open input file : ", file_name);
      }
    for (np = 0; np < Npolar; np++) {
      sprintf(file_name, "%s%s", DirOutput1, FileInputOutputS2[np]);
      if ((out_file1[np] = fopen(file_name, "wb")) == NULL)
        edit_error("Could not open input file : ", file_name);
      sprintf(file_name, "%s%s", DirOutput2, FileInputOutputS2[np]);
      if ((out_file2[np] = fopen(file_name, "wb")) == NULL)
        edit_error("Could not open input file : ", file_name);
      }
    } else {
    if (strcmp(PolarType,"pp1") == 0) {
      for (np = 0; np < Npolar; np++) {
        sprintf(file_name, "%s%s", DirInput1, FileInputOutputSPP1[np]);
        if ((in_file1[np] = fopen(file_name, "rb")) == NULL)
          edit_error("Could not open input file : ", file_name);
        sprintf(file_name, "%s%s", DirInput2, FileInputOutputSPP1[np]);
        if ((in_file2[np] = fopen(file_name, "rb")) == NULL)
          edit_error("Could not open input file : ", file_name);
        }
      for (np = 0; np < Npolar; np++) {
        sprintf(file_name, "%s%s", DirOutput1, FileInputOutputSPP1[np]);
        if ((out_file1[np] = fopen(file_name, "wb")) == NULL)
          edit_error("Could not open input file : ", file_name);
        sprintf(file_name, "%s%s", DirOutput2, FileInputOutputSPP1[np]);
        if ((out_file2[np] = fopen(file_name, "wb")) == NULL)
          edit_error("Could not open input file : ", file_name);
        }
      }
    if (strcmp(PolarType,"pp2") == 0) {
      for (np = 0; np < Npolar; np++) {
        sprintf(file_name, "%s%s", DirInput1, FileInputOutputSPP2[np]);
        if ((in_file1[np] = fopen(file_name, "rb")) == NULL)
          edit_error("Could not open input file : ", file_name);
        sprintf(file_name, "%s%s", DirInput2, FileInputOutputSPP2[np]);
        if ((in_file2[np] = fopen(file_name, "rb")) == NULL)
          edit_error("Could not open input file : ", file_name);
        }
      for (np = 0; np < Npolar; np++) {
        sprintf(file_name, "%s%s", DirOutput1, FileInputOutputSPP2[np]);
        if ((out_file1[np] = fopen(file_name, "wb")) == NULL)
          edit_error("Could not open input file : ", file_name);
        sprintf(file_name, "%s%s", DirOutput2, FileInputOutputSPP2[np]);
        if ((out_file2[np] = fopen(file_name, "wb")) == NULL)
          edit_error("Could not open input file : ", file_name);
        }
      }
    if (strcmp(PolarType,"pp3") == 0) {
      for (np = 0; np < Npolar; np++) {
        sprintf(file_name, "%s%s", DirInput1, FileInputOutputSPP3[np]);
        if ((in_file1[np] = fopen(file_name, "rb")) == NULL)
          edit_error("Could not open input file : ", file_name);
        sprintf(file_name, "%s%s", DirInput2, FileInputOutputSPP3[np]);
        if ((in_file2[np] = fopen(file_name, "rb")) == NULL)
          edit_error("Could not open input file : ", file_name);
        }
      for (np = 0; np < Npolar; np++) {
        sprintf(file_name, "%s%s", DirOutput1, FileInputOutputSPP3[np]);
        if ((out_file1[np] = fopen(file_name, "wb")) == NULL)
          edit_error("Could not open input file : ", file_name);
        sprintf(file_name, "%s%s", DirOutput2, FileInputOutputSPP3[np]);
        if ((out_file2[np] = fopen(file_name, "wb")) == NULL)
          edit_error("Could not open input file : ", file_name);
        }
      }
    }
    
  sprintf(file_name, "%s", FlatEarthFile);
  if ((flatearth_file = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name);

/*******************************************************************/
for (np = 0; np < Npolar; np++) rewind(in_file1[np]);
for (np = 0; np < Npolar; np++) rewind(in_file2[np]);
 
for (lig = 0; lig < Nlig; lig++) {
  PrintfLine(lig,Nlig);
  
  for (np = 0; np < Npolar; np++) fread(&M_in[np][0], sizeof(float), 2 * Ncol, in_file1[np]);
  for (np = 0; np < Npolar; np++) fread(&M_in[np+4][0], sizeof(float), 2 * Ncol, in_file2[np]);

  if (FlatEarthIEEE ==0 ) {
    if (strcmp(FlatEarthFormat,"cmplx") ==0 ) fread(&FlatEarth[0], sizeof(float), 2*Ncol, flatearth_file);
    else fread(&FlatEarth[0], sizeof(float), Ncol, flatearth_file);
    } else {
    if (strcmp(FlatEarthFormat,"cmplx") ==0 ) {
      for (col = 0; col < Ncol; col++) {
        v = &fl1;pc = (char *) v;
        pc[3] = getc(flatearth_file);pc[2] = getc(flatearth_file);
        pc[1] = getc(flatearth_file);pc[0] = getc(flatearth_file);
        v = &fl2;pc = (char *) v;
        pc[3] = getc(flatearth_file);pc[2] = getc(flatearth_file);
        pc[1] = getc(flatearth_file);pc[0] = getc(flatearth_file);
        FlatEarth[2 * col] = fl1;FlatEarth[2 * col + 1] = fl2;
        }
      } else {
      for (col = 0; col < Ncol; col++) {
        v = &fl1;pc = (char *) v;
        pc[3] = getc(flatearth_file);pc[2] = getc(flatearth_file);
        pc[1] = getc(flatearth_file);pc[0] = getc(flatearth_file);
        FlatEarth[col] = fl1;
        }
      }
    }
  
  for (col = 0; col < Ncol; col++) {
    if (strcmp(FlatEarthFormat,"cmplx") ==0 ) {
      xang=atan2(FlatEarth[2*col+1],FlatEarth[2*col]);
      xr = cos(xang/2.); xi = sin(xang/2.);
      }
    if (strcmp(FlatEarthFormat,"realdeg") ==0 ) {
      xr = cos(FlatEarth[col]*pi/360.); xi = sin(FlatEarth[col]*pi/360.);
      }
    if (strcmp(FlatEarthFormat,"realrad") ==0 ) {
      xr = cos(FlatEarth[col]/2.); xi = sin(FlatEarth[col]/2.);
      }
    if (ConjugateFlag == 1) xi = -xi; 

    if (my_isfinite(xr) == 0) xr = eps;
    if (my_isfinite(xi) == 0) xi = eps;
  
    for (np = 0; np < Npolar; np++) {
      M_out[np][2*col] = M_in[np][2*col]*xr - M_in[np][2*col+1]*xi;
      M_out[np][2*col + 1] = M_in[np][2*col]*xi + M_in[np][2*col+1]*xr;

      M_out[np+4][2*col] = M_in[np+4][2*col]*xr + M_in[np+4][2*col+1]*xi;
      M_out[np+4][2*col + 1] = -M_in[np+4][2*col]*xi + M_in[np+4][2*col+1]*xr;
      }
    }
  for (np = 0; np < Npolar; np++) fwrite(&M_out[np][0], sizeof(float), 2 * Ncol, out_file1[np]);
  for (np = 0; np < Npolar; np++) fwrite(&M_out[np+4][0], sizeof(float), 2 * Ncol, out_file2[np]);
  }

for (np = 0; np < Npolar; np++)  fclose(in_file1[np]);
for (np = 0; np < Npolar; np++)  fclose(out_file1[np]);
for (np = 0; np < Npolar; np++)  fclose(in_file2[np]);
for (np = 0; np < Npolar; np++)  fclose(out_file2[np]);
fclose(flatearth_file);

free_matrix_float(M_out, Npolar);
free_matrix_float(M_in, Npolar);
free_vector_float(FlatEarth);

return 1;
}
