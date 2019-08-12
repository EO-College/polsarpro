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

File   : coarse_coregistration_estimation.c
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
    laurent.ferro-famil@univ-rennes1.fr
*--------------------------------------------------------------------

Description :  Estimation of the Row / Col shifts to proceed for a
               coarse co-registration

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
#define TL 0
#define TR 1
#define BL 2
#define BR 3
#define CC 4

/* CONSTANTS  */
#define Nchannel  5

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"
int Create_Intensity(int Channel, int Npolar_in, int OffLig, int OffCol, int NwinLig, int NwinCol, int Ncol, int NfftLig, int NfftCol);
int Shift_Estimation(int Channel, int NwinLig, int NfftLig, int NfftCol, int NfftLigs2, int NfftCols2);

/* GLOBAL ARRAYS */
FILE *in_master[4], *in_slave[4];

int *Shift_Row;
int *Shift_Col;
float *Tmp;
float **I1;
float **I2;
float **S1;
float **S2;

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{

#define NPolType 2
/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = { "S2", "SPP"};
  char DirMaster[FilePathLength], DirSlave[FilePathLength];
  char FileOutput[FilePathLength];

  
/* Internal variables */
  int NfftLig, NfftLigs2, NfftCol, NfftCols2;
  int OffLig, OffCol;
  int ii, Np, Nc, Ntotal;
  
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncoarse_coregistration_estimation.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-imd 	input master directory\n");
strcat(UsageHelp," (string)	-isd 	input slave directory\n");
strcat(UsageHelp," (string)	-of  	output file\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");
strcat(UsageHelp," (noarg) 	-data	displays the help concerning Data Format parameter\n");

/********************************************************************
********************************************************************/

strcpy(UsageHelpDataFormat,"\nPolarimetric Input-Output Data Format\n\n");
for (ii=0; ii<NPolType; ii++) CreateUsageHelpDataFormat(PolTypeConf[ii]); 
strcat(UsageHelpDataFormat,"\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }
if(get_commandline_prm(argc,argv,"-data",no_cmd_prm,NULL,0,UsageHelpDataFormat)) {
  printf("\n Usage:\n%s\n",UsageHelpDataFormat); exit(1);
  }

if(argc < 13) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-imd",str_cmd_prm,DirMaster,1,UsageHelp);
  get_commandline_prm(argc,argv,"-isd",str_cmd_prm,DirSlave,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

  Config = 0;
  for (ii=0; ii<NPolType; ii++) if (strcmp(PolTypeConf[ii],PolType) == 0) Config = 1;
  if (Config == 0) edit_error("\nWrong argument in the Polarimetric Data Format\n",UsageHelpDataFormat);
  }

/********************************************************************
********************************************************************/

  check_dir(DirMaster);
  check_dir(DirSlave);
  check_file(FileOutput);

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(DirMaster, &Nlig, &Ncol, PolarCase, PolarType);

/* POLAR TYPE CONFIGURATION */
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);

  file_name_in = matrix_char(NpolarIn,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, DirMaster, file_name_in);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
    if ((in_master[Np] = fopen(file_name_in[Np], "rb")) == NULL)
      edit_error("Could not open input file : ", file_name_in[Np]);

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, DirSlave, file_name_in);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
    if ((in_slave[Np] = fopen(file_name_in[Np], "rb")) == NULL)
      edit_error("Could not open input file : ", file_name_in[Np]);
  
/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  NfftLig = ceil(pow(2.,ceil(log(NwinL)/log(2))));
  NfftCol = ceil(pow(2.,ceil(log(NwinC)/log(2))));
  NfftLigs2 = NfftLig / 2;
  NfftCols2 = NfftCol / 2;

  Shift_Row = vector_int(Nchannel);
  Shift_Col = vector_int(Nchannel);
  I1 = matrix_float(NfftLig, 2 * NfftCol);
  I2 = matrix_float(NfftLig, 2 * NfftCol);
  if (NfftLig > NfftCol) Tmp = vector_float(2*NfftLig);
  else Tmp = vector_float(2*NfftCol);
  S1 = matrix_float(NpolarIn, 2*Ncol);
  S2 = matrix_float(NpolarIn, 2*Ncol);

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

for (Np = 0; Np < NpolarIn; Np++) rewind(in_master[Np]);
for (Np = 0; Np < NpolarIn; Np++) rewind(in_slave[Np]);


/* Center */
  OffLig = floor ((Nlig - NwinL) / 2); OffCol = floor ((Ncol - NwinC) / 2);
  Create_Intensity(CC, NpolarIn, OffLig, OffCol, NwinL, NwinC, Ncol, NfftLig, NfftCol);
  Shift_Estimation(CC, NwinL, NfftLig, NfftCol, NfftLigs2, NfftCols2);
  printf("20\r");fflush(stdout);
  
#pragma omp parallel sections
{
  #pragma omp section
  {
/* Top Left */
  OffLig = 0; OffCol = 0;
  Create_Intensity(TL, NpolarIn, OffLig, OffCol, NwinL, NwinC, Ncol, NfftLig, NfftCol);
  Shift_Estimation(TL, NwinL, NfftLig, NfftCol, NfftLigs2, NfftCols2);
  printf("40\r");fflush(stdout);
  }
  #pragma omp section
  {
/* Top Right */
  OffLig = 0; OffCol = Ncol - NwinC;
  Create_Intensity(TR, NpolarIn, OffLig, OffCol, NwinL, NwinC, Ncol, NfftLig, NfftCol);
  Shift_Estimation(TR, NwinL, NfftLig, NfftCol, NfftLigs2, NfftCols2);
  printf("60\r");fflush(stdout);
  }
  #pragma omp section
  {
/* Bottom Left */
  OffLig = Nlig - NwinL; OffCol = 0;
  Create_Intensity(BL, NpolarIn, OffLig, OffCol, NwinL, NwinC, Ncol,NfftLig,  NfftCol);
  Shift_Estimation(BL, NwinL, NfftLig, NfftCol, NfftLigs2, NfftCols2);
  printf("80\r");fflush(stdout);
  }
  #pragma omp section
  {
/* Bottom Right */
  OffLig = Nlig - NwinL; OffCol = Ncol - NwinC;
  Create_Intensity(BR, NpolarIn, OffLig, OffCol, NwinL, NwinC, Ncol, NfftLig, NfftCol);
  Shift_Estimation(BR, NwinL, NfftLig, NfftCol, NfftLigs2, NfftCols2);
  printf("100\r");fflush(stdout);
  }
}

  for (Np = 0; Np < NpolarIn; Np++) {
    fclose(in_master[Np]); fclose(in_slave[Np]);
    }

  if ((in_master[0] = fopen(FileOutput, "w")) == NULL)
    edit_error("Could not open input file : ", FileOutput);
  for (Nc = 0; Nc < Nchannel; Nc++) {
    fprintf(in_master[0],"%i\n",Shift_Row[Nc]);
    fprintf(in_master[0],"%i\n",Shift_Col[Nc]);
    }
  Ntotal = Shift_Row[0]+Shift_Row[1]+Shift_Row[2]+Shift_Row[3]+Shift_Row[4];
  Ntotal = floor ((float)Ntotal / 5.);
  fprintf(in_master[0],"%i\n",Ntotal);
  Ntotal = Shift_Col[0]+Shift_Col[1]+Shift_Col[2]+Shift_Col[3]+Shift_Col[4];
  Ntotal = floor ((float)Ntotal / 5.);
  fprintf(in_master[0],"%i\n",Ntotal);
  fclose(in_master[0]);

  return(1);
}

/********************************************************************
********************************************************************/
int Create_Intensity(int Channel, int Npolar_in, int OffLig, int OffCol, int NwinLig, int NwinCol, int Ncol, int NfftLig, int NfftCol)
{
  int Np, lig, col;
  long int PointerPosition;
  
  PointerPosition = 2 * OffLig* Ncol * sizeof(float);
  for (Np = 0; Np < Npolar_in; Np++) {
    my_fseek_position(in_master[Np], PointerPosition);
    my_fseek_position(in_slave[Np], PointerPosition);
    }

  for (lig = 0; lig < NfftLig; lig++)
    for (col = 0; col < 2* NfftCol; col++) {
      I1[lig][col] = 0.0; I2[lig][col] = 0.0;
      }

  for (lig = 0; lig < NwinLig; lig++) {
    for (Np = 0; Np < Npolar_in; Np++) {
      fread(&S1[Np][0], sizeof(float), 2*Ncol, in_master[Np]);
      fread(&S2[Np][0], sizeof(float), 2*Ncol, in_slave[Np]);
      for (col = 0; col < NwinCol; col++) {
        I1[lig][2*col] += S1[Np][2*(col + OffCol)]*S1[Np][2*(col + OffCol)]+S1[Np][2*(col + OffCol)+1]*S1[Np][2*(col + OffCol)+1];
        I2[lig][2*col] += S2[Np][2*(col + OffCol)]*S2[Np][2*(col + OffCol)]+S2[Np][2*(col + OffCol)+1]*S2[Np][2*(col + OffCol)+1];
        }
      }
    }

  return(1);
}

/********************************************************************
********************************************************************/
int Shift_Estimation(int Channel, int NwinLig, int NfftLig, int NfftCol, int NfftLigs2, int NfftCols2)
{

  int ii,jj;
  int LigMax, ColMax;
  float xr, xi, Max;
  /* FFT2(I1) */
  for (ii = 0; ii < NwinLig; ii++) {
    for (jj = 0; jj < 2*NfftCol; jj++) Tmp[jj] = I1[ii][jj];
    Fft(Tmp,NfftCol,+1);
    for (jj = 0; jj < 2*NfftCol; jj++) I1[ii][jj] = Tmp[jj];
    }

  for (ii = 0; ii < NfftCol; ii++) {
    for (jj = 0; jj < NfftLig; jj++) {
      Tmp[2*jj] = I1[jj][2*ii];
      Tmp[2*jj+1] = I1[jj][2*ii+1];
      }
    Fft(Tmp,NfftLig,+1);
    for (jj = 0; jj < NfftLig; jj++) {
      I1[jj][2*ii] = Tmp[2*jj];
      I1[jj][2*ii+1] = Tmp[2*jj+1];
      }
    }

  /* FFT2(I2) */
  for (ii = 0; ii < NwinLig; ii++) {
    for (jj = 0; jj < 2*NfftCol; jj++) Tmp[jj] = I2[ii][jj];
    Fft(Tmp,NfftCol,+1);
    for (jj = 0; jj < 2*NfftCol; jj++) I2[ii][jj] = Tmp[jj];
    }

  for (ii = 0; ii < NfftCol; ii++) {
    for (jj = 0; jj < NfftLig; jj++) {
      Tmp[2*jj] = I2[jj][2*ii];
      Tmp[2*jj+1] = I2[jj][2*ii+1];
      }
    Fft(Tmp,NfftLig,+1);
    for (jj = 0; jj < NfftLig; jj++) {
      I2[jj][2*ii] = Tmp[2*jj];
      I2[jj][2*ii+1] = Tmp[2*jj+1];
      }
    }

  /* FFT2(I1) * FFT2(I2) */
  for (ii = 0; ii < NfftLig; ii++) {
    for (jj = 0; jj < NfftCol; jj++) {
      xr = I1[ii][2*jj];
      xi = I1[ii][2*jj+1];
      I1[ii][2*jj] = xr * I2[ii][2*jj] + xi * I2[ii][2*jj+1];
      I1[ii][2*jj+1] = -xr * I2[ii][2*jj+1] + xi * I2[ii][2*jj];
      }
    }

  /* IFFT2 (FFT2(I1) * FFT2(I2)) */
  for (ii = 0; ii < NfftLig; ii++) {
    for (jj = 0; jj < 2*NfftCol; jj++) Tmp[jj] = I1[ii][jj];
    Fft(Tmp,NfftCol,-1);
    for (jj = 0; jj < 2*NfftCol; jj++) I1[ii][jj] = Tmp[jj];
    }

  for (ii = 0; ii < NfftCol; ii++) {
    for (jj = 0; jj < NfftLig; jj++) {
      Tmp[2*jj] = I1[jj][2*ii];
      Tmp[2*jj+1] = I1[jj][2*ii+1];
      }
    Fft(Tmp,NfftLig,-1);
    for (jj = 0; jj < NfftLig; jj++) {
      I1[jj][2*ii] = Tmp[2*jj];
      I1[jj][2*ii+1] = Tmp[2*jj+1];
      }
    }

  /* FFTSHIFT(IFFT2 (FFT2(I1) * FFT2(I2))) */
  for (ii = 0; ii < NfftLigs2; ii++) {
    for (jj = 0; jj < NfftCols2; jj++) {
      xr=I1[ii][2*jj]; xi=I1[ii][2*jj+1];
      I1[ii][2*jj] = I1[ii+NfftLigs2][2*(jj+NfftCols2)];
      I1[ii][2*jj+1] = I1[ii+NfftLigs2][2*(jj+NfftCols2)+1];
      I1[ii+NfftLigs2][2*(jj+NfftCols2)]=xr;
      I1[ii+NfftLigs2][2*(jj+NfftCols2)+1]=xi;

      xr=I1[ii+NfftLigs2][2*jj]; xi=I1[ii+NfftLigs2][2*jj+1];
      I1[ii+NfftLigs2][2*jj] = I1[ii][2*(jj+NfftCols2)];
      I1[ii+NfftLigs2][2*jj+1] = I1[ii][2*(jj+NfftCols2)+1];
      I1[ii][2*(jj+NfftCols2)]=xr; I1[ii][2*(jj+NfftCols2)+1]=xi;
      }
    }

  /* SEARCH FOR THE MAX */
  LigMax = 0; ColMax = 0;
  Max = I1[0][0]*I1[0][0] + I1[0][1]*I1[0][1];
  for (ii = 0; ii < NfftLig; ii++) {
    for (jj = 0; jj < NfftCol; jj++) {
      if (Max <= I1[ii][2*jj]*I1[ii][2*jj] + I1[ii][2*jj+1]*I1[ii][2*jj+1]) {
        Max = I1[ii][2*jj]*I1[ii][2*jj] + I1[ii][2*jj+1]*I1[ii][2*jj+1];
        LigMax = ii;
        ColMax = jj;
        }
      }
    }

  Shift_Row[Channel] = NfftLigs2 - LigMax;
  Shift_Col[Channel] = NfftCols2 - ColMax;

  return(1);
}

