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

File   : create_rgb_kml_file.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 2.0
Creation : 07/2011
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

Description :  Creation of the RGB KML file

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

/* ACCESS FILE */
FILE *fileoutputblue, *fileoutputgreen, *fileoutputred;
FILE *T11input, *T22input, *T33input, *T12input;
FILE *C11input, *C22input, *C33input, *C44input;
FILE *C13input, *C14input, *C23input;
FILE *S11input, *S12input, *S21input, *S22input;

/* GLOBAL ARRAYS */
float *bufferBlue, *bufferGreen, *bufferRed;
float *bufferT11, *bufferT22, *bufferT33, *bufferT12;
float *bufferC11, *bufferC22, *bufferC33, *bufferC44;
float *bufferC13, *bufferC14, *bufferC23;
float *bufferS11, *bufferS12, *bufferS21, *bufferS22;

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

  char RGBDirInput[FilePathLength], FileOutputBlue[FilePathLength], FileOutputGreen[FilePathLength], FileOutputRed[FilePathLength];
  char FileInput[FilePathLength], PolarFormat[10], OutputFormat[10];

  int lig, col;
  float xr,xi;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncreate_rgb_kml_file.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-ofb 	output blue file\n");
strcat(UsageHelp," (string)	-ofg 	output green file\n");
strcat(UsageHelp," (string)	-ofr 	output red file\n");
strcat(UsageHelp," (string)	-ift 	input data format\n");
strcat(UsageHelp," (string)	-oft 	output data format\n");
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

if(argc < 23) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,RGBDirInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofb",str_cmd_prm,FileOutputBlue,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofg",str_cmd_prm,FileOutputGreen,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",str_cmd_prm,FileOutputRed,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ift",str_cmd_prm,PolarFormat,1,UsageHelp);
  get_commandline_prm(argc,argv,"-oft",str_cmd_prm,OutputFormat,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nc",int_cmd_prm,&Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_dir(RGBDirInput);
  check_file(FileOutputBlue);
  check_file(FileOutputGreen);
  check_file(FileOutputRed);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/*******************************************************************/
/*******************************************************************/

  bufferBlue = vector_float(Ncol);
  bufferGreen = vector_float(Ncol);
  bufferRed = vector_float(Ncol);

/*******************************************************************/
/*******************************************************************/

  if ((fileoutputblue = fopen(FileOutputBlue, "wb")) == NULL)
  edit_error("Could not open output file : ", FileOutputBlue);
  if ((fileoutputgreen = fopen(FileOutputGreen, "wb")) == NULL)
  edit_error("Could not open output file : ", FileOutputGreen);
  if ((fileoutputred = fopen(FileOutputRed, "wb")) == NULL)
  edit_error("Could not open output file : ", FileOutputRed);

/*******************************************************************/
/*******************************************************************/

  if ((strcmp(PolarFormat,"T3") == 0)||(strcmp(PolarFormat,"T4") == 0)) {
  strcpy(FileInput, RGBDirInput);
  strcat(FileInput, "T11.bin");
  if ((T11input = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  strcpy(FileInput, RGBDirInput);
  strcat(FileInput, "T22.bin");
  if ((T22input = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  strcpy(FileInput, RGBDirInput);
  strcat(FileInput, "T33.bin");
  if ((T33input = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  strcpy(FileInput, RGBDirInput);
  strcat(FileInput, "T12_real.bin");
  if ((T12input = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  bufferT11 = vector_float(Ncol);
  bufferT22 = vector_float(Ncol);
  bufferT33 = vector_float(Ncol);
  bufferT12 = vector_float(Ncol);

  if (strcmp(OutputFormat,"sinclair") == 0) {
    bufferC11 = vector_float(Ncol);
    bufferC22 = vector_float(Ncol);
    bufferC33 = vector_float(Ncol);
    }
    
  for (lig = 0; lig < Off_lig; lig++) {
    fread(&bufferT11[0], sizeof(float), Ncol, T11input);
    fread(&bufferT22[0], sizeof(float), Ncol, T22input);
    fread(&bufferT33[0], sizeof(float), Ncol, T33input);
    fread(&bufferT12[0], sizeof(float), Ncol, T12input);
    }

  for (lig = 0; lig < Sub_Nlig; lig++) {
    if (lig%(int)(Sub_Nlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_Nlig - 1));fflush(stdout);}

    fread(&bufferT11[0], sizeof(float), Ncol, T11input);
    fread(&bufferT22[0], sizeof(float), Ncol, T22input);
    fread(&bufferT33[0], sizeof(float), Ncol, T33input);
    fread(&bufferT12[0], sizeof(float), Ncol, T12input);
    
    if (strcmp(OutputFormat,"pauli") == 0) {
    fwrite(&bufferT11[Off_col], sizeof(float), Sub_Ncol, fileoutputblue);
    fwrite(&bufferT33[Off_col], sizeof(float), Sub_Ncol, fileoutputgreen);
    fwrite(&bufferT22[Off_col], sizeof(float), Sub_Ncol, fileoutputred);
    }
    
    if (strcmp(OutputFormat,"sinclair") == 0) {
    for (col = 0; col < Ncol; col++) {
      bufferC11[col] = 0.5 * fabs(bufferT11[col] + bufferT22[col] + bufferT12[col]);
      bufferC22[col] = 0.5 * fabs(bufferT33[col]);
      bufferC33[col] = 0.5 * fabs(bufferT11[col] + bufferT22[col] - bufferT12[col]);
      }  /* fin col */
    fwrite(&bufferC11[Off_col], sizeof(float), Sub_Ncol, fileoutputblue);
    fwrite(&bufferC22[Off_col], sizeof(float), Sub_Ncol, fileoutputgreen);
    fwrite(&bufferC33[Off_col], sizeof(float), Sub_Ncol, fileoutputred);
    }
    
    }  /*fin lig */
  }

/*******************************************************************/
/*******************************************************************/

  if (strcmp(PolarFormat,"C3") == 0) {
  strcpy(FileInput, RGBDirInput);
  strcat(FileInput, "C11.bin");
  if ((C11input = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  strcpy(FileInput, RGBDirInput);
  strcat(FileInput, "C22.bin");
  if ((C22input = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  strcpy(FileInput, RGBDirInput);
  strcat(FileInput, "C33.bin");
  if ((C33input = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  strcpy(FileInput, RGBDirInput);
  strcat(FileInput, "C13_real.bin");
  if ((C13input = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  bufferC11 = vector_float(Ncol);
  bufferC22 = vector_float(Ncol);
  bufferC33 = vector_float(Ncol);
  bufferC13 = vector_float(Ncol);

  if (strcmp(OutputFormat,"pauli") == 0) {
    bufferT11 = vector_float(Ncol);
    bufferT22 = vector_float(Ncol);
    bufferT33 = vector_float(Ncol);
    }

  for (lig = 0; lig < Off_lig; lig++) {
    fread(&bufferC11[0], sizeof(float), Ncol, C11input);
    fread(&bufferC22[0], sizeof(float), Ncol, C22input);
    fread(&bufferC33[0], sizeof(float), Ncol, C33input);
    fread(&bufferC13[0], sizeof(float), Ncol, C13input);
    }

  for (lig = 0; lig < Sub_Nlig; lig++) {
    if (lig%(int)(Sub_Nlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_Nlig - 1));fflush(stdout);}

    fread(&bufferC11[0], sizeof(float), Ncol, C11input);
    fread(&bufferC22[0], sizeof(float), Ncol, C22input);
    fread(&bufferC33[0], sizeof(float), Ncol, C33input);
    fread(&bufferC13[0], sizeof(float), Ncol, C13input);
    
    if (strcmp(OutputFormat,"sinclair") == 0) {
    for (col = 0; col < Ncol; col++) bufferC22[col] = 0.5 * bufferC22[col];
    fwrite(&bufferC11[Off_col], sizeof(float), Sub_Ncol, fileoutputblue);
    fwrite(&bufferC22[Off_col], sizeof(float), Sub_Ncol, fileoutputgreen);
    fwrite(&bufferC33[Off_col], sizeof(float), Sub_Ncol, fileoutputred);
    }
    
    if (strcmp(OutputFormat,"pauli") == 0) {
    for (col = 0; col < Ncol; col++) {
      bufferT11[col] = 0.5 * fabs(bufferC11[col] +  2. * bufferC13[col] + bufferC33[col]);
      bufferT33[col] = 0.5 * fabs(bufferC22[col]);
      bufferT22[col] = 0.5 * fabs(bufferC11[col] - 2. * bufferC13[col] + bufferC33[col]);
      }  /* fin col */
    fwrite(&bufferT11[Off_col], sizeof(float), Sub_Ncol, fileoutputblue);
    fwrite(&bufferT33[Off_col], sizeof(float), Sub_Ncol, fileoutputgreen);
    fwrite(&bufferT22[Off_col], sizeof(float), Sub_Ncol, fileoutputred);
    }
    
    }  /*fin lig */
  }

/*******************************************************************/
/*******************************************************************/

  if (strcmp(PolarFormat,"C4") == 0) {
  strcpy(FileInput, RGBDirInput);
  strcat(FileInput, "C11.bin");
  if ((C11input = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  strcpy(FileInput, RGBDirInput);
  strcat(FileInput, "C22.bin");
  if ((C22input = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  strcpy(FileInput, RGBDirInput);
  strcat(FileInput, "C33.bin");
  if ((C33input = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  strcpy(FileInput, RGBDirInput);
  strcat(FileInput, "C44.bin");
  if ((C44input = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  strcpy(FileInput, RGBDirInput);
  strcat(FileInput, "C14_real.bin");
  if ((C14input = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  strcpy(FileInput, RGBDirInput);
  strcat(FileInput, "C23_real.bin");
  if ((C23input = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  bufferC11 = vector_float(Ncol);
  bufferC22 = vector_float(Ncol);
  bufferC33 = vector_float(Ncol);
  bufferC44 = vector_float(Ncol);
  bufferC14 = vector_float(Ncol);
  bufferC23 = vector_float(Ncol);

  if (strcmp(OutputFormat,"pauli") == 0) {
    bufferT11 = vector_float(Ncol);
    bufferT22 = vector_float(Ncol);
    bufferT33 = vector_float(Ncol);
    }

  for (lig = 0; lig < Off_lig; lig++) {
    fread(&bufferC11[0], sizeof(float), Ncol, C11input);
    fread(&bufferC22[0], sizeof(float), Ncol, C22input);
    fread(&bufferC33[0], sizeof(float), Ncol, C33input);
    fread(&bufferC44[0], sizeof(float), Ncol, C44input);
    fread(&bufferC14[0], sizeof(float), Ncol, C14input);
    fread(&bufferC23[0], sizeof(float), Ncol, C23input);
    }

  for (lig = 0; lig < Sub_Nlig; lig++) {
    if (lig%(int)(Sub_Nlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_Nlig - 1));fflush(stdout);}

    fread(&bufferC11[0], sizeof(float), Ncol, C11input);
    fread(&bufferC22[0], sizeof(float), Ncol, C22input);
    fread(&bufferC33[0], sizeof(float), Ncol, C33input);
    fread(&bufferC44[0], sizeof(float), Ncol, C44input);
    fread(&bufferC14[0], sizeof(float), Ncol, C14input);
    fread(&bufferC23[0], sizeof(float), Ncol, C23input);
    
    if (strcmp(OutputFormat,"sinclair") == 0) {
    for (col = 0; col < Ncol; col++) bufferC22[col] = 0.25 * fabs(bufferC22[col] + 2. * bufferC23[col] + bufferC33[col]);
    fwrite(&bufferC11[Off_col], sizeof(float), Sub_Ncol, fileoutputblue);
    fwrite(&bufferC22[Off_col], sizeof(float), Sub_Ncol, fileoutputgreen);
    fwrite(&bufferC44[Off_col], sizeof(float), Sub_Ncol, fileoutputred);
    }
    
    if (strcmp(OutputFormat,"pauli") == 0) {
    for (col = 0; col < Ncol; col++) {
      bufferT11[col] = 0.5 * fabs(bufferC11[col] + 2. * bufferC14[col] + bufferC44[col]);
      bufferT33[col] = 0.5 * fabs(bufferC22[col] + 2. * bufferC23[col] + bufferC33[col]);
      bufferT22[col] = 0.5 * fabs(bufferC11[col] - 2. * bufferC14[col] + bufferC44[col]);
      }  /* fin col */
    fwrite(&bufferT11[Off_col], sizeof(float), Sub_Ncol, fileoutputblue);
    fwrite(&bufferT33[Off_col], sizeof(float), Sub_Ncol, fileoutputgreen);
    fwrite(&bufferT22[Off_col], sizeof(float), Sub_Ncol, fileoutputred);
    }
    
    }  /*fin lig */
  }

/*******************************************************************/
/*******************************************************************/

  if (strcmp(PolarFormat,"S2") == 0) {
  strcpy(FileInput, RGBDirInput);
  strcat(FileInput, "s11.bin");
  if ((S11input = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  strcpy(FileInput, RGBDirInput);
  strcat(FileInput, "s12.bin");
  if ((S12input = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  strcpy(FileInput, RGBDirInput);
  strcat(FileInput, "s21.bin");
  if ((S21input = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  strcpy(FileInput, RGBDirInput);
  strcat(FileInput, "s22_real.bin");
  if ((S22input = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  bufferS11 = vector_float(2*Ncol);
  bufferS12 = vector_float(2*Ncol);
  bufferS21 = vector_float(2*Ncol);
  bufferS22 = vector_float(2*Ncol);

  if (strcmp(OutputFormat,"pauli") == 0) {
    bufferT11 = vector_float(Ncol);
    bufferT22 = vector_float(Ncol);
    bufferT33 = vector_float(Ncol);
    }

  if (strcmp(OutputFormat,"sinclair") == 0) {
    bufferC11 = vector_float(Ncol);
    bufferC22 = vector_float(Ncol);
    bufferC33 = vector_float(Ncol);
    }

  for (lig = 0; lig < Off_lig; lig++) {
    fread(&bufferS11[0], sizeof(float), 2*Ncol, S11input);
    fread(&bufferS12[0], sizeof(float), 2*Ncol, S12input);
    fread(&bufferS21[0], sizeof(float), 2*Ncol, S21input);
    fread(&bufferS22[0], sizeof(float), 2*Ncol, S22input);
    }

  for (lig = 0; lig < Sub_Nlig; lig++) {
    if (lig%(int)(Sub_Nlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_Nlig - 1));fflush(stdout);}

    fread(&bufferS11[0], sizeof(float), 2*Ncol, S11input);
    fread(&bufferS12[0], sizeof(float), 2*Ncol, S12input);
    fread(&bufferS21[0], sizeof(float), 2*Ncol, S21input);
    fread(&bufferS22[0], sizeof(float), 2*Ncol, S22input);

    if (strcmp(OutputFormat,"sinclair") == 0) {
    for (col = 0; col < Ncol; col++) {
      xr = bufferS11[2 * col]; xi = bufferS11[2 * col + 1];
      bufferC11[col] = fabs(xr * xr + xi * xi);
      xr = bufferS12[2 * col] + bufferS21[2 * col]; xi = bufferS12[2 * col + 1] + bufferS21[2 * col + 1];
      bufferC22[col] = 0.25 * fabs(xr * xr + xi * xi);
      xr = bufferS22[2 * col]; xi = bufferS22[2 * col + 1];
      bufferC33[col] = fabs(xr * xr + xi * xi);
      }  /* fin col */
    fwrite(&bufferC11[Off_col], sizeof(float), Sub_Ncol, fileoutputblue);
    fwrite(&bufferC22[Off_col], sizeof(float), Sub_Ncol, fileoutputgreen);
    fwrite(&bufferC33[Off_col], sizeof(float), Sub_Ncol, fileoutputred);
    }
    
    if (strcmp(OutputFormat,"pauli") == 0) {
    for (col = 0; col < Ncol; col++) {
      xr = bufferS11[2 * col] + bufferS22[2 * col]; xi = bufferS11[2 * col + 1] + bufferS22[2 * col + 1];
      bufferT11[col] = 0.5 * fabs(xr * xr + xi * xi);
      xr = bufferS12[2 * col] + bufferS21[2 * col]; xi = bufferS12[2 * col + 1] + bufferS21[2 * col + 1];
      bufferT33[col] = 0.5 * fabs(xr * xr + xi * xi);
      xr = bufferS11[2 * col] - bufferS22[2 * col]; xi = bufferS11[2 * col + 1] - bufferS22[2 * col + 1];
      bufferT22[col] = 0.5 * fabs(xr * xr + xi * xi);
      }  /* fin col */
    fwrite(&bufferT11[Off_col], sizeof(float), Sub_Ncol, fileoutputblue);
    fwrite(&bufferT33[Off_col], sizeof(float), Sub_Ncol, fileoutputgreen);
    fwrite(&bufferT22[Off_col], sizeof(float), Sub_Ncol, fileoutputred);
    }
    
    }  /*fin lig */
  }

/*******************************************************************/
/*******************************************************************/

  fclose(fileoutputblue);
  fclose(fileoutputgreen);
  fclose(fileoutputred);
  return 1;
}
