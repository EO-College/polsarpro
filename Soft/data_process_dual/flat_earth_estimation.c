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

File   : flat_earth_estimation.c
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
    laurent.ferro-famil@univ-rennes1.fr
*--------------------------------------------------------------------

Description :  FFT Estimation the Flat Earth from the Master
               and Slave data sets.

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

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
float **M_in;
float **Interf;
float *px, *py, *FE;
float *Tmp;

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
  FILE *in_master, *in_slave, *out_file;

  char MasterFile[FilePathLength],SlaveFile[FilePathLength];
  char DirOutput[FilePathLength], file_name[FilePathLength];
  char OutputFormat[10];

  int lig, col, ii, jj;
  int NwinLig, NwinCol;
  int OffLig, OffCol;
  int NfftLig, NfftLigs2, NfftCol, NfftCols2;
  int LigMax, ColMax;

  float Max, iimax, jjmax;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nflat_earth_estimation.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-ifm 	input master file\n");
strcat(UsageHelp," (string)	-ifs 	input slave file\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-nr  	Number of Row\n");
strcat(UsageHelp," (int)   	-nc  	Number of Col\n");
strcat(UsageHelp," (string)	-fmt 	Output Format (cmplx / realdeg / realrad)\n");
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
  get_commandline_prm(argc,argv,"-ifm",str_cmd_prm,MasterFile,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifs",str_cmd_prm,SlaveFile,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,DirOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinLig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinCol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nr",int_cmd_prm,&Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nc",int_cmd_prm,&Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fmt",str_cmd_prm,OutputFormat,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(MasterFile);
  check_file(SlaveFile);
  check_dir(DirOutput);

/* INPUT/OUPUT CONFIGURATIONS */
  NfftLig = ceil(pow(2.,ceil(log(4*NwinLig)/log(2))));
  NfftCol = ceil(pow(2.,ceil(log(4*NwinCol)/log(2))));
  NfftLigs2 = NfftLig / 2;
  NfftCols2 = NfftCol / 2;

  M_in = matrix_float(2, 2 * Ncol);
  Interf = matrix_float(NfftLig, 2 * NfftCol);
  px = vector_float(2 * Nlig);
  py = vector_float(2 * Ncol);
  FE = vector_float(2 * Ncol);
  if (NfftLig > NfftCol) Tmp = vector_float(2*NfftLig);
  else Tmp = vector_float(2*NfftCol);

/*******************************************************************/
/* INPUT / OUTPUT BINARY DATA FILES */
/*******************************************************************/
  if ((in_master = fopen(MasterFile, "rb")) == NULL)
  edit_error("Could not open input file : ", MasterFile);

  if ((in_slave = fopen(SlaveFile, "rb")) == NULL)
  edit_error("Could not open input file : ", SlaveFile);

/*******************************************************************/
rewind(in_master);
rewind(in_slave);
 
  for (ii = 0; ii < NfftLig; ii++) for (jj = 0; jj < 2*NfftCol; jj++) Interf[ii][jj] = 0.;

  OffLig = floor ((Nlig - NwinLig) / 2); OffCol = floor ((Ncol - NwinCol) / 2);

  for (lig = 0; lig < OffLig; lig++) {
    PrintfLine(lig,OffLig);
    fread(&M_in[0][0], sizeof(float), 2 * Ncol, in_master);
    fread(&M_in[1][0], sizeof(float), 2 * Ncol, in_slave);
    }

  for (lig = 0; lig < NwinLig; lig++) {
    PrintfLine(lig,NwinLig);
    fread(&M_in[0][0], sizeof(float), 2 * Ncol, in_master);
    fread(&M_in[1][0], sizeof(float), 2 * Ncol, in_slave);
    for (col = 0; col < NwinCol; col++) {
      Interf[lig][2*col] = M_in[0][2*(col + OffCol)]*M_in[1][2*(col + OffCol)] + M_in[0][2*(col + OffCol)+1]*M_in[1][2*(col + OffCol)+1];
      Interf[lig][2*col+1] = M_in[0][2*(col + OffCol)+1]*M_in[1][2*(col + OffCol)] - M_in[0][2*(col + OffCol)]*M_in[1][2*(col + OffCol)+1];
      }
    }
  
  /* FFT-2 */
  for (ii = 0; ii < NwinLig; ii++) {
    for (jj = 0; jj < 2*NfftCol; jj++) Tmp[jj] = Interf[ii][jj];
    Fft(Tmp,NfftCol,+1);
    for (jj = 0; jj < 2*NfftCol; jj++) Interf[ii][jj] = Tmp[jj];
    }

  for (ii = 0; ii < NfftCol; ii++) {
    for (jj = 0; jj < NfftLig; jj++) {
      Tmp[2*jj] = Interf[jj][2*ii];
      Tmp[2*jj+1] = Interf[jj][2*ii+1];
      }
    Fft(Tmp,NfftLig,+1);
    for (jj = 0; jj < NfftLig; jj++) {
      Interf[jj][2*ii] = Tmp[2*jj];
      Interf[jj][2*ii+1] = Tmp[2*jj+1];
      }
    }

  /*FFTSHIFT*/
/*  for (ii = 0; ii < NfftLigs2; ii++)
  {
  for (jj = 0; jj < NfftCols2; jj++) 
  {
    xr=Interf[ii][2*jj]; xi=Interf[ii][2*jj+1];
    Interf[ii][2*jj] = Interf[ii+NfftLigs2][2*(jj+NfftCols2)]; Interf[ii][2*jj+1] = Interf[ii+NfftLigs2][2*(jj+NfftCols2)+1];
    Interf[ii+NfftLigs2][2*(jj+NfftCols2)]=xr; Interf[ii+NfftLigs2][2*(jj+NfftCols2)+1]=xi;
    xr=Interf[ii+NfftLigs2][2*jj]; xi=Interf[ii+NfftLigs2][2*jj+1];
    Interf[ii+NfftLigs2][2*jj] = Interf[ii][2*(jj+NfftCols2)]; Interf[ii+NfftLigs2][2*jj+1] = Interf[ii][2*(jj+NfftCols2)+1];
    Interf[ii][2*(jj+NfftCols2)]=xr; Interf[ii][2*(jj+NfftCols2)+1]=xi;
  }
  }
*/
  /* SEARCH FOR THE MAX */
  LigMax = 0; ColMax = 0;
  Max = Interf[0][0]*Interf[0][0] + Interf[0][1]*Interf[0][1];
  for (ii = 0; ii < NfftLig; ii++) {
    for (jj = 0; jj < NfftCol; jj++) {
      if (Max <= Interf[ii][2*jj]*Interf[ii][2*jj] + Interf[ii][2*jj+1]*Interf[ii][2*jj+1]) {
        Max = Interf[ii][2*jj]*Interf[ii][2*jj] + Interf[ii][2*jj+1]*Interf[ii][2*jj+1];
        LigMax = ii;
        ColMax = jj;
        }
      }
    }

  /* FLAT EARTH ESTIMATION */
  iimax = ((float)(LigMax) / (float)NfftLig);
  if (LigMax > NfftLigs2) iimax = ((float)(LigMax - NfftLig) / (float)NfftLig);

  jjmax = ((float)(ColMax) / (float)NfftCol);
  if (ColMax > NfftCols2) jjmax = ((float)(ColMax - NfftCol) / (float)NfftCol);

  for (lig = 0; lig < Nlig; lig ++) {
    px[2*lig] = cos(2.*pi*iimax*(float)lig);
    px[2*lig+1] = sin(2.*pi*iimax*(float)lig);
    }
  for (col = 0; col < Ncol; col ++) {
    py[2*col] = cos(2.*pi*jjmax*(float)col);
    py[2*col+1] = sin(2.*pi*jjmax*(float)col);
    }

  sprintf(file_name, "%sflat_earth_fft.bin", DirOutput);
  if ((out_file = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  for (lig = 0; lig < Nlig; lig ++) {
    PrintfLine(lig,Nlig);
    for (col = 0; col < Ncol; col ++) {
      FE[2*col] = px[2*lig]*py[2*col]-px[2*lig+1]*py[2*col+1];
      FE[2*col+1] = px[2*lig]*py[2*col+1]+px[2*lig+1]*py[2*col];
      }
    if (strcmp(OutputFormat,"cmplx") == 0 ) {
      fwrite(&FE[0], sizeof(float), 2*Ncol, out_file);
      } else {
      for (col = 0; col < Ncol; col ++) FE[col] = atan2(FE[2*col+1],FE[2*col]);
      if (strcmp(OutputFormat,"realdeg") == 0 ) for (col = 0; col < Ncol; col ++) FE[col] = FE[col]*180. / pi;
      fwrite(&FE[0], sizeof(float), Ncol, out_file);
      }
    }

  fclose(out_file);

  fclose(in_master);
  fclose(in_slave);

  free_matrix_float(M_in,2);
  free_matrix_float(Interf, NfftLig);
  free_vector_float(px);
  free_vector_float(py);
  free_vector_float(FE);
  free_vector_float(Tmp);

  return 1;
}

