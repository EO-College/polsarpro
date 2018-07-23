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

File  : data_analysis_mult.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 06/2012
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

Description :  Calculates the mean, standard deviation and 
coefficient of variation of multi time / freq data
The input format of the binary file can be: cmplx,float,int
The output format can be: Real part, Imaginary part, Modulus, 
Modulus Square or Phase of the input data

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

#define Avg  0
#define Std  1
#define CV   2

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
  char *PolTypeConf[NPolType] = {"S2", "SPP", "C2", "T3"};

  FILE *infile, *fileinput[100], *fileoutput[3];

  char DirInit[FilePathLength], DirName[FilePathLength], DirNameTmp[FilePathLength];
  char FileInit[FilePathLength], FileName[FilePathLength];
  char InputFormat[10], OutputFormat[10];
  char Tmp[10], Polar[5];
  
  int lig, col, k, l, ii;
  int Nligoffset, Ncoloffset;
  int Nligfin, Ncolfin;
  int Nd, Ndir;
  int ParaAvg, ParaStd, ParaCV;
  int lenfile;

  float mean, mean2;
  float xr, xi;

  float *bufferdatacmplx;
  float *bufferdatafloat;
  int *bufferdataint;

  float ***data;
  float **data_out;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ndata_analysis_mult.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (string)	-if  	input file\n");
strcat(UsageHelp," (string)	-idf 	input data format (cmplx, float, int)\n");
strcat(UsageHelp," (string)	-odf 	output data format (real, imag, mod, mod2, pha)\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (int)   	-fl1 	Flag Mean (0/1)\n");
strcat(UsageHelp," (int)   	-fl2 	Flag STD (0/1)\n");
strcat(UsageHelp," (int)   	-fl3 	Flag CV (0/1)\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 29) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,DirInit,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,Polar,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,FileInit,1,UsageHelp);
  get_commandline_prm(argc,argv,"-idf",str_cmd_prm,InputFormat,1,UsageHelp);
  get_commandline_prm(argc,argv,"-odf",str_cmd_prm,OutputFormat,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Nligoffset,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Ncoloffset,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Nligfin,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Ncolfin,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl1",int_cmd_prm,&ParaAvg,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl2",int_cmd_prm,&ParaStd,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl3",int_cmd_prm,&ParaCV,1,UsageHelp);

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
  check_file(FileInit);
  if (FlagValid == 1) check_file(file_valid);

/* INPUT/OUPUT CONFIGURATIONS */
  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

  sprintf(DirName, "%s", DirInit);
  if (strcmp(Polar, "T3") == 0) sprintf(DirName, "%s%s", DirInit, "T3");
  if (strcmp(Polar, "C2") == 0) sprintf(DirName, "%s%s", DirInit, "C2");
  check_dir(DirName);
  read_config(DirName, &Nlig, &Ncol, PolarCase, PolarType);
  
  sprintf(FileName, "%s%s", DirInit, "config_mult.txt");
  if ((infile = fopen(FileName, "r")) == NULL)
    edit_error("Could not open input file : ", FileName);
  fscanf(infile, "%i\n", &Ndir);
  fscanf(infile, "%s\n", Tmp);
  for (k = 0; k < Ndir; k++) {
    fgets (DirNameTmp , 1024 , infile);
    lenfile = strlen(DirNameTmp);
    strcpy(DirName, ""); strncat(DirName,&DirNameTmp[0],lenfile-1);
    check_dir(DirName);
    sprintf(FileName, "%s%s", DirName, FileInit);
    if (strcmp(Polar, "T3") == 0) sprintf(FileName, "%s%s%s", DirName, "T3/", FileInit);
    if (strcmp(Polar, "C2") == 0) sprintf(FileName, "%s%s%s", DirName, "C2/", FileInit);
    check_file(FileName);
    if ((fileinput[k] = fopen(FileName, "rb")) == NULL)
      edit_error("Could not open input file : ", FileName);
    }
  fclose(infile);
  
  strcpy(FileName,"");
  lenfile = strlen(FileInit);
  strncat(FileName,&FileInit[0],lenfile-4);
  if (ParaAvg == 1) {
    sprintf(FileInit, "%s%s_mean.bin", DirInit, FileName);
    if (strcmp(Polar, "T3") == 0) sprintf(FileInit, "%s%s%s_mean.bin", DirInit, "T3/", FileName);
    if (strcmp(Polar, "C2") == 0) sprintf(FileInit, "%s%s%s_mean.bin", DirInit, "C2/", FileName);
    check_file(FileInit);
    if ((fileoutput[Avg] = fopen(FileInit, "wb")) == NULL)
      edit_error("Could not open input file : ", FileInit);  
    }
  if (ParaStd == 1) {
    sprintf(FileInit, "%s%s_std.bin", DirInit, FileName);
    if (strcmp(Polar, "T3") == 0) sprintf(FileInit, "%s%s%s_std.bin", DirInit, "T3/", FileName);
    if (strcmp(Polar, "C2") == 0) sprintf(FileInit, "%s%s%s_std.bin", DirInit, "C2/", FileName);
    check_file(FileInit);
    if ((fileoutput[Std] = fopen(FileInit, "wb")) == NULL)
      edit_error("Could not open input file : ", FileInit);  
    }
  if (ParaCV == 1) {
    sprintf(FileInit, "%s%s_CV.bin", DirInit, FileName);
    if (strcmp(Polar, "T3") == 0) sprintf(FileInit, "%s%s%s_CV.bin", DirInit, "T3/", FileName);
    if (strcmp(Polar, "C2") == 0) sprintf(FileInit, "%s%s%s_CV.bin", DirInit, "C2/", FileName);
    check_file(FileInit);
    if ((fileoutput[CV] = fopen(FileInit, "wb")) == NULL)
      edit_error("Could not open input file : ", FileInit);  
    }

/*******************************************************************/
  data = matrix3d_float(Ndir, NwinL, Ncol + NwinC);
  data_out = matrix_float(3, Ncolfin);

  if (strcmp(InputFormat, "cmplx") == 0) bufferdatacmplx = vector_float(2 * Ncol);
  if (strcmp(InputFormat, "float") == 0) bufferdatafloat = vector_float(Ncol);
  if (strcmp(InputFormat, "int") == 0) bufferdataint = vector_int(Ncol);

  Valid = matrix_float(NwinL, Ncol + NwinC);

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
    for (lig = 0; lig < NwinL; lig++) 
      for (col = 0; col < Ncol + NwinC; col++) 
        Valid[lig][col] = 1.;
 
/********************************************************************
********************************************************************/

for (Nd = 0; Nd < Ndir; Nd++) {
  rewind(fileinput[Nd]);
/* READ INPUT DATA FILE AND CREATE DATATMP CORRESPONDING
   TO OUTPUTFORMAT */
  for (lig = 0; lig < Nligoffset; lig++) {
    if (strcmp(InputFormat, "cmplx") == 0) fread(&bufferdatacmplx[0], sizeof(float), 2 * Ncol, fileinput[Nd]);
    if (strcmp(InputFormat, "float") == 0) fread(&bufferdatafloat[0], sizeof(float), Ncol, fileinput[Nd]);
    if (strcmp(InputFormat, "int") == 0) fread(&bufferdataint[0], sizeof(int), Ncol, fileinput[Nd]);
    }
  }

if (FlagValid == 1) 
  for (lig = 0; lig < Nligoffset; lig++)
    fread(&Valid[0][0], sizeof(float), Ncol, in_valid);
  
/*******************************************************************/

for (Nd = 0; Nd < Ndir; Nd++) {
  
for (lig = (NwinL - 1) / 2; lig < NwinL - 1; lig++) {
  if (strcmp(InputFormat, "cmplx") == 0) fread(&bufferdatacmplx[0], sizeof(float), 2 * Ncol, fileinput[Nd]);
  if (strcmp(InputFormat, "float") == 0) fread(&bufferdatafloat[0], sizeof(float), Ncol, fileinput[Nd]);
  if (strcmp(InputFormat, "int") == 0) fread(&bufferdataint[0], sizeof(int), Ncol, fileinput[Nd]);

  for (col = Ncoloffset; col < Ncolfin + Ncoloffset; col++) {
    if (strcmp(OutputFormat, "real") == 0) {
      if (strcmp(InputFormat, "cmplx") == 0) data[Nd][lig][col - Ncoloffset + (NwinC - 1) / 2] = bufferdatacmplx[2 * (col + (NwinC - 1) / 2)];
      if (strcmp(InputFormat, "float") == 0) data[Nd][lig][col - Ncoloffset + (NwinC - 1) / 2] = bufferdatafloat[col + (NwinC - 1) / 2];
      if (strcmp(InputFormat, "int") == 0) data[Nd][lig][col - Ncoloffset + (NwinC - 1) / 2] = (float) bufferdataint[col + (NwinC - 1) / 2];
      }

    if (strcmp(OutputFormat, "imag") == 0) {
      if (strcmp(InputFormat, "cmplx") == 0) data[Nd][lig][col - Ncoloffset + (NwinC - 1) / 2] = bufferdatacmplx[2 * (col + (NwinC - 1) / 2) + 1];
      if (strcmp(InputFormat, "float") == 0) data[Nd][lig][col - Ncoloffset + (NwinC - 1) / 2] = 0.;
      if (strcmp(InputFormat, "int") == 0) data[Nd][lig][col - Ncoloffset + (NwinC - 1) / 2] = 0.;
      }

    if (strcmp(OutputFormat, "mod") == 0) {
      if (strcmp(InputFormat, "cmplx") == 0) {
        xr = bufferdatacmplx[2 * (col + (NwinC - 1) / 2)];
        xi = bufferdatacmplx[2 * (col + (NwinC - 1) / 2) + 1];
        data[Nd][lig][col - Ncoloffset + (NwinC - 1) / 2] = sqrt(xr * xr + xi * xi);
        }
      if (strcmp(InputFormat, "float") == 0) data[Nd][lig][col - Ncoloffset + (NwinC - 1) / 2] = fabs(bufferdatafloat[col + (NwinC - 1) / 2]);
      if (strcmp(InputFormat, "int") == 0) data[Nd][lig][col - Ncoloffset + (NwinC - 1) / 2] = fabs((float) bufferdataint[col + (NwinC - 1) / 2]);
      }

    if (strcmp(OutputFormat, "mod2") == 0) {
      if (strcmp(InputFormat, "cmplx") == 0) {
        xr = bufferdatacmplx[2 * (col + (NwinC - 1) / 2)];
        xi = bufferdatacmplx[2 * (col + (NwinC - 1) / 2) + 1];
        data[Nd][lig][col - Ncoloffset + (NwinC - 1) / 2] = xr * xr + xi * xi;
        }
      if (strcmp(InputFormat, "float") == 0) data[Nd][lig][col - Ncoloffset + (NwinC - 1) / 2] = fabs(bufferdatafloat[col + (NwinC - 1) / 2]*bufferdatafloat[col + (NwinC - 1) / 2]);
      if (strcmp(InputFormat, "int") == 0) data[Nd][lig][col - Ncoloffset + (NwinC - 1) / 2] = fabs((float) bufferdataint[col + (NwinC - 1) / 2]*bufferdataint[col + (NwinC - 1) / 2]);
      }

    if (strcmp(OutputFormat, "pha") == 0) {
      if (strcmp(InputFormat, "cmplx") == 0) {
        xr = bufferdatacmplx[2 * (col + (NwinC - 1) / 2)];
        xi = bufferdatacmplx[2 * (col + (NwinC - 1) / 2) + 1];
        data[Nd][lig][col - Ncoloffset + (NwinC - 1) / 2] = atan2(xi, xr + eps) * 180. / pi;
        }
      if (strcmp(InputFormat, "float") == 0) data[Nd][lig][col - Ncoloffset + (NwinC - 1) / 2] = 0.;
      if (strcmp(InputFormat, "int") == 0) data[Nd][lig][col - Ncoloffset + (NwinC - 1) / 2] = 0.;
      }
    } /* col */
  for (col = Ncolfin; col < Ncolfin + (NwinC - 1) / 2; col++) data[Nd][lig][col + (NwinC - 1) / 2] = 0.;
  } /* lig */

} /* Nd */

/*******************************************************************/

if (FlagValid == 1) {
  for (lig = (NwinL - 1) / 2; lig < NwinL - 1; lig++) {
    fread(&bufferdatafloat[0], sizeof(float), Ncol, in_valid);
    for (col = Ncoloffset; col < Ncolfin + Ncoloffset; col++) 
      Valid[lig][col - Ncoloffset + (NwinC - 1) / 2] = bufferdatafloat[col + (NwinC - 1) / 2];
    for (col = Ncolfin; col < Ncolfin + (NwinC - 1) / 2; col++) Valid[lig][col + (NwinC - 1) / 2] = 0.;
    }
  }
  
/*******************************************************************/
  
for (lig = 0; lig < Nligfin; lig++) {
  PrintfLine(lig,Nligfin);

  if (FlagValid == 1) fread(&bufferdatafloat[0], sizeof(float), Ncol, in_valid);
  for (col = Ncoloffset; col < Ncolfin + Ncoloffset; col++) 
    Valid[NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = bufferdatafloat[col + (NwinC - 1) / 2];
  for (col = Ncolfin; col < Ncolfin + (NwinC - 1) / 2; col++) Valid[NwinL-1][col + (NwinC - 1) / 2] = 0.;

  for (Nd = 0; Nd < Ndir; Nd++) {
    if (strcmp(InputFormat, "cmplx") == 0) fread(&bufferdatacmplx[0], sizeof(float), 2 * Ncol, fileinput[Nd]);
    if (strcmp(InputFormat, "float") == 0) fread(&bufferdatafloat[0], sizeof(float), Ncol, fileinput[Nd]);
    if (strcmp(InputFormat, "int") == 0) fread(&bufferdataint[0], sizeof(int), Ncol, fileinput[Nd]);

    for (col = Ncoloffset; col < Ncolfin + Ncoloffset; col++) {
      if (strcmp(OutputFormat, "real") == 0) {
        if (strcmp(InputFormat, "cmplx") == 0) data[Nd][NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = bufferdatacmplx[2 * (col + (NwinC - 1) / 2)];
        if (strcmp(InputFormat, "float") == 0) data[Nd][NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = bufferdatafloat[col + (NwinC - 1) / 2];
        if (strcmp(InputFormat, "int") == 0) data[Nd][NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = (float) bufferdataint[col + (NwinC - 1) / 2];
        }

      if (strcmp(OutputFormat, "imag") == 0) {
        if (strcmp(InputFormat, "cmplx") == 0) data[Nd][NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = bufferdatacmplx[2 * (col + (NwinC - 1) / 2) + 1];
        if (strcmp(InputFormat, "float") == 0) data[Nd][NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = 0.;
        if (strcmp(InputFormat, "int") == 0) data[Nd][NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = 0.;
        }

      if (strcmp(OutputFormat, "mod") == 0) {
        if (strcmp(InputFormat, "cmplx") == 0) {
          xr = bufferdatacmplx[2 * (col + (NwinC - 1) / 2)];
          xi = bufferdatacmplx[2 * (col + (NwinC - 1) / 2) + 1];
          data[Nd][NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = sqrt(xr * xr + xi * xi);
          }
        if (strcmp(InputFormat, "float") == 0) data[Nd][NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = fabs(bufferdatafloat[col + (NwinC - 1) / 2]);
        if (strcmp(InputFormat, "int") == 0) data[Nd][NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = fabs((float) bufferdataint[col + (NwinC - 1) / 2]);
        }

      if (strcmp(OutputFormat, "mod2") == 0) {
        if (strcmp(InputFormat, "cmplx") == 0) {
          xr = bufferdatacmplx[2 * (col + (NwinC - 1) / 2)];
          xi = bufferdatacmplx[2 * (col + (NwinC - 1) / 2) + 1];
          data[Nd][NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = xr * xr + xi * xi;
          }
        if (strcmp(InputFormat, "float") == 0) data[Nd][NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = fabs(bufferdatafloat[col + (NwinC - 1) / 2]*bufferdatafloat[col + (NwinC - 1) / 2]);
        if (strcmp(InputFormat, "int") == 0) data[Nd][NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = fabs((float) bufferdataint[col + (NwinC - 1) / 2]*bufferdataint[col + (NwinC - 1) / 2]);
        }

      if (strcmp(OutputFormat, "pha") == 0) {
        if (strcmp(InputFormat, "cmplx") == 0) {
          xr = bufferdatacmplx[2 * (col + (NwinC - 1) / 2)];
          xi = bufferdatacmplx[2 * (col + (NwinC - 1) / 2) + 1];
          data[Nd][NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = atan2(xi, xr + eps) * 180. / pi;
          }
        if (strcmp(InputFormat, "float") == 0) data[Nd][NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = 0.;
        if (strcmp(InputFormat, "int") == 0) data[Nd][NwinL-1][col - Ncoloffset + (NwinC - 1) / 2] = 0.;
        }
      } /* col */
    for (col = Ncolfin; col < Ncolfin + (NwinC - 1) / 2; col++) data[Nd][NwinL-1][col + (NwinC - 1) / 2] = 0.;
    } /* Nd */

  for (col = 0; col < Ncolfin; col++) {
    data_out[Avg][col] = 0.;
    data_out[Std][col] = 0.;
    data_out[CV][col] = 0.;
    if (Valid[(NwinL - 1) / 2][(NwinC - 1) / 2 + col] == 1.) {
      /*Within window statistics*/
      mean = 0.;
      mean2 = 0.;
      for (Nd = 0; Nd < Ndir; Nd++) 
        for (k = -(NwinL - 1) / 2; k < 1 + (NwinL - 1) / 2; k++)
          for (l = -(NwinC - 1) / 2; l < 1 + (NwinC - 1) / 2; l++) {
            mean +=  data[Nd][(NwinL - 1) / 2 + k][(NwinC - 1) / 2 + col + l]/(Ndir*NwinC*NwinC);
            mean2 += data[Nd][(NwinL - 1) / 2 + k][(NwinC - 1) / 2 + col + l] * data[Nd][(NwinL - 1) / 2 + k][(NwinC - 1) / 2 + col + l]/(Ndir*NwinC*NwinC);
            }
      data_out[Avg][col] = mean;
      data_out[Std][col] = mean2 - mean * mean;
      data_out[CV][col] = sqrt(mean2 - mean * mean) / (eps + mean);
      }
    }

/* DATA WRITING */
  if (ParaAvg == 1) fwrite(&data_out[Avg][0], sizeof(float), Ncolfin, fileoutput[Avg]);
  if (ParaStd == 1) fwrite(&data_out[Std][0], sizeof(float), Ncolfin, fileoutput[Std]);
  if (ParaCV == 1) fwrite(&data_out[CV][0], sizeof(float), Ncolfin, fileoutput[CV]);

/* Line-wise shift */
  if (FlagValid == 1) {
    for (l = 0; l < (NwinL - 1); l++)
      for (col = 0; col < Ncolfin; col++)
        Valid[l][(NwinC - 1) / 2 + col] =  Valid[l + 1][(NwinC - 1) / 2 + col];
    }
  for (Nd = 0; Nd < Ndir; Nd++) 
    for (l = 0; l < (NwinL - 1); l++)
      for (col = 0; col < Ncolfin; col++)
        data[Nd][l][(NwinC - 1) / 2 + col] =  data[Nd][l + 1][(NwinC - 1) / 2 + col];

  } /* lig */

/*******************************************************************/

  for (Nd = 0; Nd < Ndir; Nd++) fclose(fileinput[Nd]);
  if (ParaAvg == 1) fclose(fileoutput[Avg]);
  if (ParaStd == 1) fclose(fileoutput[Std]);
  if (ParaCV == 1) fclose(fileoutput[CV]);
  if (FlagValid == 1) fclose(in_valid);

  free_matrix_float(data_out, 3);
  free_matrix3d_float(data, Ndir, NwinL);

/*******************************************************************/

  return 1;
}
