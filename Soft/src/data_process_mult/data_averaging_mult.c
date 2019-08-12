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

File  : data_averaging_mult.c
Project  : ESA_POLSARPRO-SATIM
Authors  : Eric POTTIER, Jacek STRZELCZYK
Version  : 2.0
Creation : 07/2015
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

Description :  Calculates the mean of multi time / freq data

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
/* S matrix */
#define hh 0
#define hv 1
#define vh 2
#define vv 3

#define chx0 0
#define chx1 1

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

#define NPolType 4
/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = {"S2T3", "SPPC2", "C2", "T3"};
  FILE *infile, *fileinput[100], *fileoutput;
  FILE *fileinput1[100], *fileinput2[100];
  FILE *fileinput3[100], *fileinput4[100];

  char DirInit[FilePathLength], DirName[FilePathLength], DirNameTmp[FilePathLength], DirOutput[FilePathLength];
  char FileName[FilePathLength];
  char Tmp[10], Polar[5];
  
  char *file_name_in_out_T3[9] =
  { "T11.bin", "T12_real.bin", "T12_imag.bin",
  "T13_real.bin", "T13_imag.bin", "T22.bin",
  "T23_real.bin", "T23_imag.bin", "T33.bin"
  };
  char *file_name_in_out_C2[4] =
  { "C11.bin", "C12_real.bin", "C12_imag.bin", "C22.bin" };

  int lig, col, k, l, ii;
  int Npolar, lenfile;
  int Nligoffset, Ncoloffset;
  int Nligfin, Ncolfin;
  int Np, Nd, Ndir;
  float k1r, k1i, k2r, k2i, k3r, k3i;

  float ***M_in;
  float *M_out;
  float **S_in;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ndata_averaging_mult.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
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
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,DirInit,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,DirOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,Polar,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Nligoffset,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Ncoloffset,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Nligfin,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Ncolfin,1,UsageHelp);

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

  Config = 0;
  for (ii=0; ii<NPolType; ii++) if (strcmp(PolTypeConf[ii],Polar) == 0) Config = 1;
  if (Config == 0) edit_error("\nWrong argument in the Polarimetric Data Format\n",UsageHelpDataFormat);
  }

/********************************************************************
********************************************************************/

  check_dir(DirInit);
  check_dir(DirOutput);
  if (FlagValid == 1) check_file(file_valid);

  /* INPUT/OUPUT CONFIGURATIONS */
  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/********************************************************************
********************************************************************/
if ((strcmp(Polar,"T3") == 0)||(strcmp(Polar,"C2") == 0)) {
/********************************************************************
********************************************************************/
  if (strcmp(Polar,"T3") == 0) Npolar = 9; 
  if (strcmp(Polar,"C2") == 0) Npolar = 4;
  
/* INPUT/OUPUT CONFIGURATIONS */
  if (strcmp(Polar,"T3") == 0) sprintf(DirName, "%s%s", DirInit, "T3");
  if (strcmp(Polar,"C2") == 0) sprintf(DirName, "%s%s", DirInit, "C2");
  check_dir(DirName);
  read_config(DirName, &Nlig, &Ncol, PolarCase, PolarType);

/*******************************************************************/
  sprintf(FileName, "%s%s", DirInit, "config_mult.txt");
  if ((infile = fopen(FileName, "r")) == NULL)
    edit_error("Could not open input file : ", FileName);
  fscanf(infile, "%i\n", &Ndir);
  fclose(infile);

  M_in = matrix3d_float(Ndir, NwinL, Ncol + NwinC);
  M_out = vector_float(Ncolfin);
  Valid = matrix_float(NwinL, Ncol + NwinC);
  
/*******************************************************************/
  
for (Np = 0; Np < Npolar; Np++) {
  
  sprintf(FileName, "%s%s", DirInit, "config_mult.txt");
  if ((infile = fopen(FileName, "r")) == NULL)
    edit_error("Could not open input file : ", FileName);
  fscanf(infile, "%i\n", &Ndir);
  fscanf(infile, "%s\n", Tmp);
  for (Nd = 0; Nd < Ndir; Nd++) {
    fgets (DirNameTmp , 1024 , infile);
    lenfile = strlen(DirNameTmp);
    strcpy(DirName, ""); strncat(DirName,&DirNameTmp[0],lenfile-1);
    check_dir(DirName);
    if (strcmp(Polar,"T3") == 0) sprintf(FileName, "%s%s%s", DirName, "T3/", file_name_in_out_T3[Np]);
    if (strcmp(Polar,"C2") == 0) sprintf(FileName, "%s%s%s", DirName, "C2/", file_name_in_out_C2[Np]);
    check_file(FileName);
    if ((fileinput[Nd] = fopen(FileName, "rb")) == NULL)
      edit_error("Could not open input file : ", FileName);
    }
  fclose(infile);

  if (strcmp(Polar,"T3") == 0) sprintf(FileName, "%s%s", DirOutput, file_name_in_out_T3[Np]);
  if (strcmp(Polar,"C2") == 0) sprintf(FileName, "%s%s", DirOutput, file_name_in_out_C2[Np]);
  if ((fileoutput = fopen(FileName, "wb")) == NULL)
    edit_error("Could not open input file : ", FileName);  

/*******************************************************************/

for (Nd = 0; Nd < Ndir; Nd++) {
  rewind(fileinput[Nd]);
/* READ INPUT DATA FILE AND CREATE DATATMP CORRESPONDING
   TO OUTPUTFORMAT */
  for (lig = 0; lig < Nligoffset; lig++) {
    fread(&M_in[0][0][0], sizeof(float), Ncol, fileinput[Nd]);
    }
  }

if (FlagValid == 1) 
  for (lig = 0; lig < Nligoffset; lig++)
    fread(&Valid[0][0], sizeof(float), Ncol, in_valid);
  
/*******************************************************************/

for (Nd = 0; Nd < Ndir; Nd++) {
  for (lig = (NwinL - 1) / 2; lig < NwinL - 1; lig++) {
  
    fread(&M_in[Nd][lig][(NwinC - 1) / 2], sizeof(float), Ncol, fileinput[Nd]);
    for (col = Ncoloffset; col < Ncolfin + Ncoloffset; col++) 
      M_in[Nd][lig][col - Ncoloffset + (NwinC - 1) / 2] = M_in[Nd][lig][col + (NwinC - 1) / 2];
    for (col = Ncolfin; col < Ncolfin + (NwinC - 1) / 2; col++)
      M_in[Nd][lig][col + (NwinC - 1) / 2] = 0.;
    } /* lig */
  } /* Nd */

/*******************************************************************/

if (FlagValid == 1) {
  for (lig = (NwinL - 1) / 2; lig < NwinL - 1; lig++) {
    fread(&Valid[lig][(NwinC - 1) / 2], sizeof(float), Ncol, in_valid);
    for (col = Ncoloffset; col < Ncolfin + Ncoloffset; col++)
      Valid[lig][col - Ncoloffset + (NwinC - 1) / 2] = Valid[lig][col + (NwinC - 1) / 2];
    for (col = Ncolfin; col < Ncolfin + (NwinC - 1) / 2; col++)
      Valid[lig][col + (NwinC - 1) / 2] = 0.;
    }
  }
  
/*******************************************************************/
  
for (lig = 0; lig < Nligfin; lig++) {
  PrintfLine(lig,Nligfin);

  if (FlagValid == 1) fread(&Valid[NwinL-1][(NwinC - 1) / 2], sizeof(float), Ncol, in_valid);
  for (col = Ncoloffset; col < Ncolfin + Ncoloffset; col++)
    Valid[NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = Valid[NwinL-1][col + (NwinC - 1) / 2];
  for (col = Ncolfin; col < Ncolfin + (NwinC - 1) / 2; col++)
    Valid[NwinL-1][col + (NwinC - 1) / 2] = 0.;

  for (Nd = 0; Nd < Ndir; Nd++) {
    fread(&M_in[Nd][NwinL-1][(NwinC - 1) / 2], sizeof(float), Ncol, fileinput[Nd]);
    for (col = Ncoloffset; col < Ncolfin + Ncoloffset; col++)
      M_in[Nd][NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = M_in[Nd][NwinL-1][col + (NwinC - 1) / 2];
    for (col = Ncolfin; col < Ncolfin + (NwinC - 1) / 2; col++)
      M_in[Nd][NwinL-1][col + (NwinC - 1) / 2] = 0.;
    } /* Nd */

  for (col = 0; col < Ncolfin; col++) {
    /*Within window statistics*/
    M_out[col] = 0.;
    if (Valid[(NwinL - 1) / 2][(NwinC - 1) / 2 + col] == 1.) {
      for (Nd = 0; Nd < Ndir; Nd++) 
        for (k = -(NwinL - 1) / 2; k < 1 + (NwinL - 1) / 2; k++)
          for (l = -(NwinC - 1) / 2; l < 1 + (NwinC - 1) / 2; l++) 
            M_out[col] +=  M_in[Nd][(NwinL - 1) / 2 + k][(NwinC - 1) / 2 + col + l]/(Ndir*Nwin*Nwin);
      }
    }

/* DATA WRITING */
  fwrite(&M_out[0], sizeof(float), Ncolfin, fileoutput);

/* Line-wise shift */
  if (FlagValid == 1) {
    for (l = 0; l < (NwinL - 1); l++)
      for (col = 0; col < Ncolfin; col++)
        Valid[l][(NwinC - 1) / 2 + col] =  Valid[l + 1][(NwinC - 1) / 2 + col];
    }
  for (Nd = 0; Nd < Ndir; Nd++) 
    for (l = 0; l < (NwinL - 1); l++)
      for (col = 0; col < Ncolfin; col++)
        M_in[Nd][l][(NwinC - 1) / 2 + col] =  M_in[Nd][l + 1][(NwinC - 1) / 2 + col];
  } /* lig */

  for (Nd = 0; Nd < Ndir; Nd++) fclose(fileinput[Nd]);
  fclose(fileoutput);
} /* Np */

free_vector_float(M_out);
free_matrix3d_float(M_in, Ndir, NwinL);

/*******************************************************************/
} /* Polar = T3 or C2*/

/********************************************************************
********************************************************************/
if ((strcmp(Polar,"S2T3") == 0)||(strcmp(Polar,"SPPC2") == 0)) {
/********************************************************************
********************************************************************/
  if (strcmp(Polar,"S2T3") == 0) Npolar = 9; 
  if (strcmp(Polar,"SPPC2") == 0) Npolar = 4;
  
/* INPUT/OUPUT CONFIGURATIONS */
  read_config(DirInit, &Nlig, &Ncol, PolarCase, PolarType);

/*******************************************************************/
  sprintf(FileName, "%s%s", DirInit, "config_mult.txt");
  if ((infile = fopen(FileName, "r")) == NULL)
    edit_error("Could not open input file : ", FileName);
  fscanf(infile, "%i\n", &Ndir);
  fclose(infile);

  M_in = matrix3d_float(Ndir, NwinL, Ncol + NwinC);
  M_out = vector_float(Ncolfin);
  Valid = matrix_float(NwinL, Ncol + NwinC);
  if (strcmp(Polar,"S2T3") == 0) S_in = matrix_float(4, 2*Ncol);
  if (strcmp(Polar,"SPPC2") == 0) S_in = matrix_float(2, 2*Ncol);

/*******************************************************************/

  sprintf(FileName, "%s%s", DirInit, "config_mult.txt");
  if ((infile = fopen(FileName, "r")) == NULL)
    edit_error("Could not open input file : ", FileName);
  fscanf(infile, "%i\n", &Ndir);
  fscanf(infile, "%s\n", Tmp);
  for (Nd = 0; Nd < Ndir; Nd++) {
    fgets (DirNameTmp , 1024 , infile);
    lenfile = strlen(DirNameTmp);
    strcpy(DirName, ""); strncat(DirName,&DirNameTmp[0],lenfile-1);
    if (strcmp(Polar,"S2T3") == 0) {
      sprintf(FileName, "%s/s11.bin", DirName); check_file(FileName);
      if ((fileinput1[Nd] = fopen(FileName, "rb")) == NULL)
        edit_error("Could not open input file : ", FileName);
      sprintf(FileName, "%s/s12.bin", DirName); check_file(FileName);
      if ((fileinput2[Nd] = fopen(FileName, "rb")) == NULL)
        edit_error("Could not open input file : ", FileName);
      sprintf(FileName, "%s/s21.bin", DirName); check_file(FileName);
      if ((fileinput3[Nd] = fopen(FileName, "rb")) == NULL)
        edit_error("Could not open input file : ", FileName);
      sprintf(FileName, "%s/s22.bin", DirName); check_file(FileName);
      if ((fileinput4[Nd] = fopen(FileName, "rb")) == NULL)
        edit_error("Could not open input file : ", FileName);
      }
    if (strcmp(Polar,"SPPC2") == 0) {
      if (strcmp(PolarType, "pp1") == 0) {
        sprintf(FileName, "%s/s11.bin", DirName); check_file(FileName);
        if ((fileinput1[Nd] = fopen(FileName, "rb")) == NULL)
          edit_error("Could not open input file : ", FileName);
        sprintf(FileName, "%s/s21.bin", DirName); check_file(FileName);
        if ((fileinput2[Nd] = fopen(FileName, "rb")) == NULL)
          edit_error("Could not open input file : ", FileName);
        }
      if (strcmp(PolarType, "pp2") == 0) {
        sprintf(FileName, "%s/s22.bin", DirName); check_file(FileName);
        if ((fileinput1[Nd] = fopen(FileName, "rb")) == NULL)
          edit_error("Could not open input file : ", FileName);
        sprintf(FileName, "%s/s12.bin", DirName); check_file(FileName);
        if ((fileinput2[Nd] = fopen(FileName, "rb")) == NULL)
          edit_error("Could not open input file : ", FileName);
        }
      if (strcmp(PolarType, "pp3") == 0) {
        sprintf(FileName, "%s/s11.bin", DirName); check_file(FileName);
        if ((fileinput1[Nd] = fopen(FileName, "rb")) == NULL)
          edit_error("Could not open input file : ", FileName);
        sprintf(FileName, "%s/s22.bin", DirName); check_file(FileName);
        if ((fileinput2[Nd] = fopen(FileName, "rb")) == NULL)
          edit_error("Could not open input file : ", FileName);
        }
      }
    }
  fclose(infile);
  
for (Np = 0; Np < Npolar; Np++) {
  if (strcmp(Polar,"S2T3") == 0) sprintf(FileName, "%s%s", DirOutput, file_name_in_out_T3[Np]);
  if (strcmp(Polar,"SPPC2") == 0) sprintf(FileName, "%s%s", DirOutput, file_name_in_out_C2[Np]);
  if ((fileoutput = fopen(FileName, "wb")) == NULL)
    edit_error("Could not open input file : ", FileName);  

/*******************************************************************/

for (Nd = 0; Nd < Ndir; Nd++) {
  rewind(fileinput1[Nd]);
  rewind(fileinput2[Nd]);
  if (strcmp(Polar,"S2T3") == 0) {
    rewind(fileinput3[Nd]);
    rewind(fileinput4[Nd]);
    }
/* READ INPUT DATA FILE AND CREATE DATATMP CORRESPONDING
   TO OUTPUTFORMAT */
  for (lig = 0; lig < Nligoffset; lig++) {
    fread(&S_in[0][0], sizeof(float), 2*Ncol, fileinput1[Nd]);
    fread(&S_in[0][0], sizeof(float), 2*Ncol, fileinput2[Nd]);
    if (strcmp(Polar,"S2T3") == 0) {
      fread(&S_in[0][0], sizeof(float), 2*Ncol, fileinput3[Nd]);
      fread(&S_in[0][0], sizeof(float), 2*Ncol, fileinput4[Nd]);
      }
    }
  }

if (FlagValid == 1) 
  for (lig = 0; lig < Nligoffset; lig++)
    fread(&Valid[0][0], sizeof(float), Ncol, in_valid);
  
/*******************************************************************/

for (Nd = 0; Nd < Ndir; Nd++) {
  for (lig = (NwinL - 1) / 2; lig < NwinL - 1; lig++) {
  
    if (strcmp(Polar,"S2T3") == 0) {
      fread(&S_in[hh][0], sizeof(float), 2*Ncol, fileinput1[Nd]);
      fread(&S_in[hv][0], sizeof(float), 2*Ncol, fileinput2[Nd]);
      fread(&S_in[vh][0], sizeof(float), 2*Ncol, fileinput3[Nd]);
      fread(&S_in[vv][0], sizeof(float), 2*Ncol, fileinput4[Nd]);

      for (col = Ncoloffset; col < Ncolfin + Ncoloffset; col++) {
        k1r = (S_in[hh][2*col] + S_in[vv][2*col]) / sqrt(2.);
        k1i = (S_in[hh][2*col+1] + S_in[vv][2*col+1]) / sqrt(2.);
        k2r = (S_in[hh][2*col] - S_in[vv][2*col]) / sqrt(2.);
        k2i = (S_in[hh][2*col+1] - S_in[vv][2*col+1]) / sqrt(2.);
        k3r = (S_in[hv][2*col] + S_in[vh][2*col]) / sqrt(2.);
        k3i = (S_in[hv][2*col+1] + S_in[vh][2*col+1]) / sqrt(2.);

        if (Np == 0) M_in[Nd][lig][col - Ncoloffset + (NwinC - 1) / 2] = k1r * k1r + k1i * k1i;
        if (Np == 1) M_in[Nd][lig][col - Ncoloffset + (NwinC - 1) / 2] = k1r * k2r + k1i * k2i;
        if (Np == 2) M_in[Nd][lig][col - Ncoloffset + (NwinC - 1) / 2] = k1i * k2r - k1r * k2i;
        if (Np == 3) M_in[Nd][lig][col - Ncoloffset + (NwinC - 1) / 2] = k1r * k3r + k1i * k3i;
        if (Np == 4) M_in[Nd][lig][col - Ncoloffset + (NwinC - 1) / 2] = k1i * k3r - k1r * k3i;
        if (Np == 5) M_in[Nd][lig][col - Ncoloffset + (NwinC - 1) / 2] = k2r * k2r + k2i * k2i;
        if (Np == 6) M_in[Nd][lig][col - Ncoloffset + (NwinC - 1) / 2] = k2r * k3r + k2i * k3i;
        if (Np == 7) M_in[Nd][lig][col - Ncoloffset + (NwinC - 1) / 2] = k2i * k3r - k2r * k3i;
        if (Np == 8) M_in[Nd][lig][col - Ncoloffset + (NwinC - 1) / 2] = k3r * k3r + k3i * k3i;
        }  
      }
    if (strcmp(Polar,"SPPC2") == 0) {
      fread(&S_in[chx0][0], sizeof(float), 2*Ncol, fileinput1[Nd]);
      fread(&S_in[chx1][0], sizeof(float), 2*Ncol, fileinput2[Nd]);

      for (col = Ncoloffset; col < Ncolfin + Ncoloffset; col++) {
        k1r = (S_in[chx0][2*col] + S_in[chx1][2*col]) / sqrt(2.);
        k1i = (S_in[chx0][2*col+1] + S_in[chx1][2*col+1]) / sqrt(2.);
        k2r = (S_in[chx0][2*col] - S_in[chx1][2*col]) / sqrt(2.);
        k2i = (S_in[chx0][2*col+1] - S_in[chx1][2*col+1]) / sqrt(2.);

        if (Np == 0) M_in[Nd][lig][col - Ncoloffset + (NwinC - 1) / 2] = k1r * k1r + k1i * k1i;
        if (Np == 1) M_in[Nd][lig][col - Ncoloffset + (NwinC - 1) / 2] = k1r * k2r + k1i * k2i;
        if (Np == 2) M_in[Nd][lig][col - Ncoloffset + (NwinC - 1) / 2] = k1i * k2r - k1r * k2i;
        if (Np == 3) M_in[Nd][lig][col - Ncoloffset + (NwinC - 1) / 2] = k2r * k2r + k2i * k2i;
        }  
      }
  
  for (col = Ncolfin; col < Ncolfin + (Nwin - 1) / 2; col++)
  M_in[Nd][lig][col + (Nwin - 1) / 2] = 0.;
    } /* lig */
  } /* Nd */

/*******************************************************************/

if (FlagValid == 1) {
  for (lig = (NwinL - 1) / 2; lig < NwinL - 1; lig++) {
    fread(&Valid[lig][(NwinC - 1) / 2], sizeof(float), Ncol, in_valid);
    for (col = Ncoloffset; col < Ncolfin + Ncoloffset; col++)
      Valid[lig][col - Ncoloffset + (NwinC - 1) / 2] = Valid[lig][col + (NwinC - 1) / 2];
    for (col = Ncolfin; col < Ncolfin + (NwinC - 1) / 2; col++)
      Valid[lig][col + (NwinC - 1) / 2] = 0.;
    }
  }
  
/*******************************************************************/
  
for (lig = 0; lig < Nligfin; lig++) {
  PrintfLine(lig,Nligfin);

  if (FlagValid == 1) fread(&Valid[NwinL-1][(NwinC - 1) / 2], sizeof(float), Ncol, in_valid);
  for (col = Ncoloffset; col < Ncolfin + Ncoloffset; col++)
    Valid[NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = Valid[NwinL-1][col + (NwinC - 1) / 2];
  for (col = Ncolfin; col < Ncolfin + (NwinC - 1) / 2; col++)
    Valid[NwinL-1][col + (NwinC - 1) / 2] = 0.;

  for (Nd = 0; Nd < Ndir; Nd++) {
  
    if (strcmp(Polar,"S2T3") == 0) {
      fread(&S_in[hh][0], sizeof(float), 2*Ncol, fileinput1[Nd]);
      fread(&S_in[hv][0], sizeof(float), 2*Ncol, fileinput2[Nd]);
      fread(&S_in[vh][0], sizeof(float), 2*Ncol, fileinput3[Nd]);
      fread(&S_in[vv][0], sizeof(float), 2*Ncol, fileinput4[Nd]);

      for (col = Ncoloffset; col < Ncolfin + Ncoloffset; col++) {
        k1r = (S_in[hh][2*col] + S_in[vv][2*col]) / sqrt(2.);
        k1i = (S_in[hh][2*col+1] + S_in[vv][2*col+1]) / sqrt(2.);
        k2r = (S_in[hh][2*col] - S_in[vv][2*col]) / sqrt(2.);
        k2i = (S_in[hh][2*col+1] - S_in[vv][2*col+1]) / sqrt(2.);
        k3r = (S_in[hv][2*col] + S_in[vh][2*col]) / sqrt(2.);
        k3i = (S_in[hv][2*col+1] + S_in[vh][2*col+1]) / sqrt(2.);

        if (Np == 0) M_in[Nd][NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = k1r * k1r + k1i * k1i;
        if (Np == 1) M_in[Nd][NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = k1r * k2r + k1i * k2i;
        if (Np == 2) M_in[Nd][NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = k1i * k2r - k1r * k2i;
        if (Np == 3) M_in[Nd][NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = k1r * k3r + k1i * k3i;
        if (Np == 4) M_in[Nd][NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = k1i * k3r - k1r * k3i;
        if (Np == 5) M_in[Nd][NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = k2r * k2r + k2i * k2i;
        if (Np == 6) M_in[Nd][NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = k2r * k3r + k2i * k3i;
        if (Np == 7) M_in[Nd][NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = k2i * k3r - k2r * k3i;
        if (Np == 8) M_in[Nd][NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = k3r * k3r + k3i * k3i;
        }
      }        
    if (strcmp(Polar,"SPPC2") == 0) {
      fread(&S_in[chx0][0], sizeof(float), 2*Ncol, fileinput1[Nd]);
      fread(&S_in[chx1][0], sizeof(float), 2*Ncol, fileinput2[Nd]);

      for (col = Ncoloffset; col < Ncolfin + Ncoloffset; col++) {
        k1r = (S_in[chx0][2*col] + S_in[chx1][2*col]) / sqrt(2.);
        k1i = (S_in[chx0][2*col+1] + S_in[chx1][2*col+1]) / sqrt(2.);
        k2r = (S_in[chx0][2*col] - S_in[chx1][2*col]) / sqrt(2.);
        k2i = (S_in[chx0][2*col+1] - S_in[chx1][2*col+1]) / sqrt(2.);

        if (Np == 0) M_in[Nd][NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = k1r * k1r + k1i * k1i;
        if (Np == 1) M_in[Nd][NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = k1r * k2r + k1i * k2i;
        if (Np == 2) M_in[Nd][NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = k1i * k2r - k1r * k2i;
        if (Np == 3) M_in[Nd][NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = k2r * k2r + k2i * k2i;
        }
      }        

    for (col = Ncolfin; col < Ncolfin + (NwinC - 1) / 2; col++)
      M_in[Nd][NwinL-1][col + (NwinC - 1) / 2] = 0.;
    } /* Nd */

  for (col = 0; col < Ncolfin; col++) {
    /*Within window statistics*/
    M_out[col] = 0.;
    if (Valid[(NwinL - 1) / 2][(NwinC - 1) / 2 + col] == 1.) {
      for (Nd = 0; Nd < Ndir; Nd++) 
        for (k = -(NwinL - 1) / 2; k < 1 + (NwinL - 1) / 2; k++)
          for (l = -(NwinC - 1) / 2; l < 1 + (NwinC - 1) / 2; l++) 
            M_out[col] +=  M_in[Nd][(NwinL - 1) / 2 + k][(NwinC - 1) / 2 + col + l]/(Ndir*Nwin*Nwin);
      }
    }

/* DATA WRITING */
  fwrite(&M_out[0], sizeof(float), Ncolfin, fileoutput);

/* Line-wise shift */
  if (FlagValid == 1) {
    for (l = 0; l < (NwinL - 1); l++)
      for (col = 0; col < Ncolfin; col++)
        Valid[l][(NwinC - 1) / 2 + col] =  Valid[l + 1][(NwinC - 1) / 2 + col];
    }
  for (Nd = 0; Nd < Ndir; Nd++) 
    for (l = 0; l < (NwinL - 1); l++)
      for (col = 0; col < Ncolfin; col++)
        M_in[Nd][l][(NwinC - 1) / 2 + col] =  M_in[Nd][l + 1][(NwinC - 1) / 2 + col];
  } /* lig */

  if (strcmp(Polar,"S2T3") == 0) {
    for (Nd = 0; Nd < Ndir; Nd++) fclose(fileinput1[Nd]);
    for (Nd = 0; Nd < Ndir; Nd++) fclose(fileinput2[Nd]);
    for (Nd = 0; Nd < Ndir; Nd++) fclose(fileinput3[Nd]);
    for (Nd = 0; Nd < Ndir; Nd++) fclose(fileinput4[Nd]);
    }
  if (strcmp(Polar,"SPPC2") == 0) {
    for (Nd = 0; Nd < Ndir; Nd++) fclose(fileinput1[Nd]);
    for (Nd = 0; Nd < Ndir; Nd++) fclose(fileinput2[Nd]);
    }
  fclose(fileoutput);
} /* Np */

free_vector_float(M_out);
free_matrix3d_float(M_in, Ndir, NwinL);
if (strcmp(Polar,"S2T3") == 0) free_matrix_float(S_in, 4);
if (strcmp(Polar,"SPPC2") == 0) free_matrix_float(S_in, 2);

/*******************************************************************/
} /* Polar = S2T3 or SPPC2 */

  return 1;
}
