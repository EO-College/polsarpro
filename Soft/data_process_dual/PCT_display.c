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

File  : PCT_display.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 2.0
Creation : 12/2007
Update  : 08/2012
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

Description :  Polarization Coherence Tomography representation

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

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"

/* GLOBAL VARIABLES */

/* Input/Output file pointer arrays */
/* Matrix arrays */
  float ***Tomo;
  float **TomoBMP;

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

/* Strings */
  FILE *file;
  char file_name[FilePathLength];
  char Tmp[FilePathLength], TomoAsc[FilePathLength], TomoBin[FilePathLength];
  char TomoBmp[FilePathLength], ColorMap[FilePathLength];
  char Operation[20];

/* Internal variables */
  int Nligg, Ncoll;
  int Naz, Nrg, Nz;
  int lig, col, zz, az;
  int FlagExit, FlagRead;
  int PixLig, PixCol, PixZ;
  int load_tomo, bmp_tomo;
  float xx, Min, Max, TmpFlt;

/********************************************************************
********************************************************************/
/* USAGE */

if (argc == 5) {
  strcpy(TomoAsc, argv[1]);
  strcpy(TomoBin, argv[2]);
  strcpy(TomoBmp, argv[3]);
  strcpy(ColorMap, argv[4]);
  } else
  edit_error("PCT_display TomoAsc TomoBin TomoBmp\n","");

/***********************************************************************
***********************************************************************/

  check_file(TomoAsc);
  check_file(TomoBin);
  check_file(TomoBmp);
  check_file(ColorMap);

/***********************************************************************
***********************************************************************/
/* PROCESS */
  load_tomo = 0;
  bmp_tomo = 0;

  Min = -1.0; Max = +1.0;

  FlagExit = 0;
  while (FlagExit == 0) {
    scanf("%s",Operation);
    if (strcmp(Operation, "") != 0) {
    if (strcmp(Operation, "exit") == 0) {
    FlagExit = 1;
    printf("OKexit\r");fflush(stdout);
    }

    if (strcmp(Operation, "load") == 0) {
    if (load_tomo == 1) free_matrix3d_float(Tomo,Nz,Naz);
    
    sprintf(file_name, "%s", TomoAsc);
    if ((file = fopen(file_name, "r")) == NULL)
      edit_error("Could not open configuration file : ", file_name);
    fscanf(file, "%s\n", Tmp);
    fscanf(file, "%i\n", &Naz);
    fscanf(file, "%s\n", Tmp);
    fscanf(file, "%s\n", Tmp);
    fscanf(file, "%i\n", &Nrg);
    fscanf(file, "%s\n", Tmp);
    fscanf(file, "%s\n", Tmp);
    fscanf(file, "%i\n", &Nz);
    fscanf(file, "%s\n", Tmp);
    fscanf(file, "%s\n", Tmp);
    fscanf(file, "%f\n", &TmpFlt);
    fscanf(file, "%s\n", Tmp);
    fscanf(file, "%s\n", Tmp);
    fscanf(file, "%f\n", &TmpFlt);
    fscanf(file, "%s\n", Tmp);
    fscanf(file, "%s\n", Tmp);
    fscanf(file, "%f\n", &Min);
    fscanf(file, "%s\n", Tmp);
    fscanf(file, "%s\n", Tmp);
    fscanf(file, "%f\n", &Max);
    fclose(file);

    Tomo = matrix3d_float(Nz,Naz,Nrg);
    sprintf(file_name, "%s", TomoBin);
    if ((file = fopen(file_name, "rb")) == NULL)
      edit_error("Could not open configuration file : ", file_name);
    for (zz = 0; zz < Nz; zz++) 
      for (az = 0; az < Naz; az++)
      fread(&Tomo[zz][az][0], sizeof(float), Nrg, file);
    fclose(file);
    load_tomo = 1;
    printf("OKload\r");fflush(stdout);
    }

    if (strcmp(Operation, "azimut") == 0) {
    printf("OKazimut\r");fflush(stdout);
    FlagRead = 0;
    while (FlagRead == 0) {
     scanf("%s",Operation);
     if (strcmp(Operation, "") != 0) {
      PixCol = atoi(Operation);
      FlagRead = 1;
      printf("OKreadcol\r");fflush(stdout);
      }
     }

    if (bmp_tomo == 1) free_matrix_float(TomoBMP,Nligg);
    Nligg = Nz; Ncoll = Naz;
    TomoBMP = matrix_float(Nligg,Ncoll);
    for (lig = 0; lig < Nligg; lig++)
      for (col = 0; col < Ncoll; col++)
      TomoBMP[Nligg-1-lig][col] = Tomo[lig][col][PixCol];
    
    for (lig = 0; lig < Nligg; lig++) {
      for (col = 0; col < Ncoll; col++) {
      if (TomoBMP[lig][col] == 0.) TomoBMP[lig][col] = Min;
      xx = (TomoBMP[lig][col] - Min) / (Max - Min);
      if (xx < 0.) xx = 0.; if (xx > 1.) xx = 1.;
      TomoBMP[lig][col] = 255. * xx;
      }
    }
    for (col = 0; col < Ncoll; col++) TomoBMP[(int)(Nligg/4)][col] = 1.;
    for (col = 0; col < Ncoll; col++) TomoBMP[(int)(Nligg/2)][col] = 1.;
    for (col = 0; col < Ncoll; col++) TomoBMP[(int)(3*Nligg/4)][col] = 1.;
    for (lig = 0; lig < Nligg; lig++) TomoBMP[lig][(int)(Ncoll/4)] = 1.;
    for (lig = 0; lig < Nligg; lig++) TomoBMP[lig][(int)(Ncoll/2)] = 1.;
    for (lig = 0; lig < Nligg; lig++) TomoBMP[lig][(int)(3*Ncoll/4)] = 1.;

    /* CREATE THE BMP FILE */
    bmp_8bit(Nligg, Ncoll, Max, Min, ColorMap, TomoBMP, TomoBmp);

    bmp_tomo = 1;
    printf("OKazimutOK\r");fflush(stdout);
    }

    if (strcmp(Operation, "range") == 0) {
    printf("OKrange\r");fflush(stdout);
    FlagRead = 0;
    while (FlagRead == 0) {
     scanf("%s",Operation);
     if (strcmp(Operation, "") != 0) {
      PixLig = atoi(Operation);
      FlagRead = 1;
      printf("OKreadlig\r");fflush(stdout);
      }
     }

    if (bmp_tomo == 1) free_matrix_float(TomoBMP,Nligg);
    Nligg = Nz; Ncoll = Nrg;
    TomoBMP = matrix_float(Nligg,Ncoll);
    for (lig = 0; lig < Nligg; lig++)
      for (col = 0; col < Ncoll; col++)
      TomoBMP[Nligg-1-lig][col] = Tomo[lig][PixLig][col];

    for (lig = 0; lig < Nligg; lig++) {
      for (col = 0; col < Ncoll; col++) {
      if (TomoBMP[lig][col] == 0.) TomoBMP[lig][col] = Min;
      xx = (TomoBMP[lig][col] - Min) / (Max - Min);
      if (xx < 0.) xx = 0.; if (xx > 1.) xx = 1.;
      TomoBMP[lig][col] = 255. * xx;
      }
    }
    for (col = 0; col < Ncoll; col++) TomoBMP[(int)(Nligg/4)][col] = 1.;
    for (col = 0; col < Ncoll; col++) TomoBMP[(int)(Nligg/2)][col] = 1.;
    for (col = 0; col < Ncoll; col++) TomoBMP[(int)(3*Nligg/4)][col] = 1.;
    for (lig = 0; lig < Nligg; lig++) TomoBMP[lig][(int)(Ncoll/4)] = 1.;
    for (lig = 0; lig < Nligg; lig++) TomoBMP[lig][(int)(Ncoll/2)] = 1.;
    for (lig = 0; lig < Nligg; lig++) TomoBMP[lig][(int)(3*Ncoll/4)] = 1.;
    /* CREATE THE BMP FILE */
    bmp_8bit(Nligg, Ncoll, Max, Min, ColorMap, TomoBMP, TomoBmp);

    bmp_tomo = 1;
    printf("OKrangeOK\r");fflush(stdout);
    }

    if (strcmp(Operation, "height") == 0) {
    printf("OKheight\r");fflush(stdout);
    FlagRead = 0;
    while (FlagRead == 0) {
     scanf("%s",Operation);
     if (strcmp(Operation, "") != 0) {
      PixZ = atoi(Operation);
      PixZ = PixZ -1;
      if (PixZ < 0) PixZ = 0;
      if (PixZ > (Nz-1)) PixZ = (Nz-1);
      FlagRead = 1;
      printf("OKreadz\r");fflush(stdout);
      }
     }

    if (bmp_tomo == 1) free_matrix_float(TomoBMP,Nligg);
    Nligg = Naz; Ncoll = Nrg;
    TomoBMP = matrix_float(Nligg,Ncoll);
    for (lig = 0; lig < Nligg; lig++)
      for (col = 0; col < Ncoll; col++)
      TomoBMP[lig][col] = Tomo[PixZ][lig][col];

    for (lig = 0; lig < Nligg; lig++) {
      for (col = 0; col < Ncoll; col++) {
      if (TomoBMP[lig][col] == 0.) TomoBMP[lig][col] = Min;
      xx = (TomoBMP[lig][col] - Min) / (Max - Min);
      if (xx < 0.) xx = 0.; if (xx > 1.) xx = 1.;
      TomoBMP[lig][col] = 255. * xx;
      }
    }
    for (col = 0; col < Ncoll; col++) TomoBMP[(int)(Nligg/4)][col] = 1.;
    for (col = 0; col < Ncoll; col++) TomoBMP[(int)(Nligg/2)][col] = 1.;
    for (col = 0; col < Ncoll; col++) TomoBMP[(int)(3*Nligg/4)][col] = 1.;
    for (lig = 0; lig < Nligg; lig++) TomoBMP[lig][(int)(Ncoll/4)] = 1.;
    for (lig = 0; lig < Nligg; lig++) TomoBMP[lig][(int)(Ncoll/2)] = 1.;
    for (lig = 0; lig < Nligg; lig++) TomoBMP[lig][(int)(3*Ncoll/4)] = 1.;
    /* CREATE THE BMP FILE */
    bmp_8bit(Nligg, Ncoll, Max, Min, ColorMap, TomoBMP, TomoBmp);
    
    bmp_tomo = 1;
    printf("OKheightOK\r");fflush(stdout);
    }
    }
    } /*while */

return 1;
}

