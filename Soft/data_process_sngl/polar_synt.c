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

File  : polar_synt.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2011
Update  :
*--------------------------------------------------------------------
INSTITUT D'ELECTRONIQUE et de TELECOMMUNICATIONS de RENNES (I.E.T.R)
UMR CNRS 6164

Image and Remote Sensing Group
SAPHIR Team 
(SAr Polarimetry Holography Interferometry Radargrammetry)

UNIVERSITY OF RENNES I
B�t. 11D - Campus de Beaulieu
263 Avenue G�n�ral Leclerc
35042 RENNES Cedex
Tel :(+33) 2 23 23 57 63
Fax :(+33) 2 23 23 69 63
e-mail: eric.pottier@univ-rennes1.fr

*--------------------------------------------------------------------

Description :  Polarisation Synthesis

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

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{

#define NPolType 3
/* LOCAL VARIABLES */
  FILE *out_blue, *out_red, *out_green, *out_bmp;
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C3", "T3"};
  char SyntRGBFormat[FilePathLength];
  char file_bmp[FilePathLength], file_blue[FilePathLength], file_green[FilePathLength], file_red[FilePathLength];
  
/* Internal variables */
  int ii, lig, col;

  int SyntRGB, SyntBMP;
  float Phi, Tau;
  float T11_phi, T22_phi, T33_phi;
  float T12_re_phi,  T13_im_phi;
//  float T12_im_phi, T13_re_phi, T23_re_phi;
  float T23_im_phi;
  float NewT11, NewT22, NewT33, NewT12re;

/* Matrix arrays */
  float ***M_avg;
  float **SyntBmp;
  float **SyntBlue;
  float **SyntGreen;
  float **SyntRed;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\npolar_synt.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");

strcat(UsageHelp," (float) 	-phi 	Phi angle value (deg)\n");
strcat(UsageHelp," (float) 	-tau 	Tau angle value (deg)\n");
strcat(UsageHelp," (int)   	-rgb 	Flag RGB files creation (0/1)\n");
strcat(UsageHelp," (string)	-rgbf	RGB output format (pauli / sinclair)\n");
strcat(UsageHelp," (string)	-bf  	Blue channel output file (if rgb = 1)\n");
strcat(UsageHelp," (string)	-rf  	Red channel output file (if rgb = 1)\n");
strcat(UsageHelp," (string)	-gf  	Green channel output file (if rgb = 1)\n");
strcat(UsageHelp," (int)   	-bmp 	Flag BMP file creation (0/1)\n");
strcat(UsageHelp," (string)	-bmpf	BMP output file (if bmp=1)\n");

strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
strcat(UsageHelp," (int)   	-mem 	Allocated memory for blocksize determination (in Mb)\n");
strcat(UsageHelp," (string)	-errf	memory error file\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");
strcat(UsageHelp," (noarg) 	-data	displays the help concerning Data Format parameter\n");

/********************************************************************
********************************************************************/

strcpy(UsageHelpDataFormat,"\nPolarimetric Input-Output Data Format\n\n");
for (ii=0; ii<NPolType; ii++) CreateUsageHelpDataFormatInput(PolTypeConf[ii]); 
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

if(argc < 21) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-phi",flt_cmd_prm,&Phi,1,UsageHelp);
  get_commandline_prm(argc,argv,"-tau",flt_cmd_prm,&Tau,1,UsageHelp);
  get_commandline_prm(argc,argv,"-bmp",int_cmd_prm,&SyntBMP,1,UsageHelp);
  if (SyntBMP == 1) {
  get_commandline_prm(argc,argv,"-bmpf",str_cmd_prm,file_bmp,1,UsageHelp);
  }
  get_commandline_prm(argc,argv,"-rgb",int_cmd_prm,&SyntRGB,1,UsageHelp);
  if (SyntRGB == 1) {
  get_commandline_prm(argc,argv,"-rgbf",str_cmd_prm,SyntRGBFormat,1,UsageHelp);
  get_commandline_prm(argc,argv,"-bf",str_cmd_prm,file_blue,1,UsageHelp);
  get_commandline_prm(argc,argv,"-rf",str_cmd_prm,file_red,1,UsageHelp);
  get_commandline_prm(argc,argv,"-gf",str_cmd_prm,file_green,1,UsageHelp);
  }
  Phi = Phi * 4. * atan(1.) / 180.;
  Tau = Tau * 4. * atan(1.) / 180.;

  get_commandline_prm(argc,argv,"-errf",str_cmd_prm,file_memerr,0,UsageHelp);

  MemoryAlloc = -1;
  get_commandline_prm(argc,argv,"-mem",int_cmd_prm,&MemoryAlloc,0,UsageHelp);
  MemoryAlloc = my_max(MemoryAlloc,1000);
  
  FlagValid = 0;strcpy(file_valid,"");
  get_commandline_prm(argc,argv,"-mask",str_cmd_prm,file_valid,0,UsageHelp);
  if (strcmp(file_valid,"") != 0) FlagValid = 1;

  Config = 0;
  for (ii=0; ii<NPolType; ii++) if (strcmp(PolTypeConf[ii],PolType) == 0) Config = 1;
  if (Config == 0) edit_error("\nWrong argument in the Polarimetric Data Format\n",UsageHelpDataFormat);
  }

  if (strcmp(PolType,"S2")==0) strcpy(PolType,"S2T3");

/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);

  NwinL = 1; NwinC = 1;
  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);
  
/* POLAR TYPE CONFIGURATION */
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);
  
  file_name_in = matrix_char(NpolarIn,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir, file_name_in);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
  if ((in_datafile[Np] = fopen(file_name_in[Np], "rb")) == NULL)
    edit_error("Could not open input file : ", file_name_in[Np]);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  if (SyntBMP == 1) {
    check_file(file_bmp);
    if ((out_bmp = fopen(file_bmp, "wb")) == NULL)
      edit_error("Could not open input file : ", file_bmp);
    }
  if (SyntRGB == 1) {
    check_file(file_blue);
    check_file(file_green);
    check_file(file_red);
    
    if ((out_blue = fopen(file_blue, "wb")) == NULL)
      edit_error("Could not open input file : ", file_blue);

    if ((out_red = fopen(file_red, "wb")) == NULL)
      edit_error("Could not open input file : ", file_red);

    if ((out_green = fopen(file_green, "wb")) == NULL)
      edit_error("Could not open input file : ", file_green);
    }
  
/********************************************************************
********************************************************************/
/* MEMORY ALLOCATION */
/*
MemAlloc = NBlockA*Nlig + NBlockB
*/ 

/* Local Variables */
  NBlockA = 0; NBlockB = 0;
  /* Mask */ 
  NBlockA += Sub_Ncol; NBlockB += 0;

  if (SyntBMP == 1) {
    /* Mbmp = Nlig*Sub_Ncol */
    NBlockA += Sub_Ncol; NBlockB += 0;
    }
  if (SyntRGB == 1) {
    /* Mblue = Nlig*Sub_Ncol */
    NBlockA += Sub_Ncol; NBlockB += 0;
    /* Mred = Nlig*Sub_Ncol */
    NBlockA += Sub_Ncol; NBlockB += 0;
    /* Mgreen = Nlig*Sub_Ncol */
    NBlockA += Sub_Ncol; NBlockB += 0;
    }
  /* Mavg = NpolarOut*Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
  
/* Reading Data */
  NBlockB += Ncol + 2*Ncol + NpolarIn*2*Ncol + NpolarOut*NwinL*(Ncol+NwinC);

  memory_alloc(file_memerr, Sub_Nlig, NwinL, &NbBlock, NligBlock, NBlockA, NBlockB, MemoryAlloc);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  _VC_in = vector_float(2*Ncol);
  _VF_in = vector_float(Ncol);
  _MC_in = matrix_float(4,2*Ncol);
  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   

  Valid = matrix_float(NligBlock[0], Sub_Ncol);

  M_avg = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);
  if (SyntBMP == 1) {
    SyntBmp = matrix_float(NligBlock[0], Sub_Ncol);
    }
  if (SyntRGB == 1) {
    SyntBlue = matrix_float(NligBlock[0], Sub_Ncol);
    SyntRed = matrix_float(NligBlock[0], Sub_Ncol);
    SyntGreen = matrix_float(NligBlock[0], Sub_Ncol);
    }
  
/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
    for (lig = 0; lig < NligBlock[0]; lig++) 
      for (col = 0; col < Sub_Ncol; col++) 
        Valid[lig][col] = 1.;
 
/********************************************************************
********************************************************************/
/* DATA PROCESSING */
for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
    read_block_S2_avg(in_datafile, M_avg, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_avg(in_datafile, M_avg, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }
  if (strcmp(PolTypeOut,"C3")==0) C3_to_T3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        /* Real Rotation Phi */
        T11_phi = M_avg[T311][lig][col];
        T12_re_phi = M_avg[T312_re][lig][col] * cos(2 * Phi) + M_avg[T313_re][lig][col] * sin(2 * Phi);
//      T12_im_phi = M_avg[T312_im][lig][col] * cos(2 * Phi) + M_avg[T313_im][lig][col] * sin(2 * Phi);
//      T13_re_phi = -M_avg[T312_re][lig][col] * sin(2 * Phi) + M_avg[T313_re][lig][col] * cos(2 * Phi);
        T13_im_phi = -M_avg[T312_im][lig][col] * sin(2 * Phi) + M_avg[T313_im][lig][col] * cos(2 * Phi);
        T22_phi = M_avg[T322][lig][col] * cos(2 * Phi) * cos(2 * Phi) + M_avg[T323_re][lig][col] * sin(4 * Phi) + M_avg[T333][lig][col] * sin(2 * Phi) * sin(2 * Phi);
//      T23_re_phi = 0.5 * (M_avg[T333][lig][col] - M_avg[T322][lig][col]) * sin(4 * Phi) + M_avg[T323_re][lig][col] * cos(4 * Phi);
        T23_im_phi = M_avg[T323_im][lig][col];
        T33_phi = M_avg[T322][lig][col] * sin(2 * Phi) * sin(2 * Phi) - M_avg[T323_re][lig][col] * sin(4 * Phi) + M_avg[T333][lig][col] * cos(2 * Phi) * cos(2 * Phi);

        /* Elliptical Rotation Tau */
        NewT11 = T11_phi * cos(2 * Tau) * cos(2 * Tau) +  T13_im_phi * sin(4 * Tau);
        NewT11 = NewT11 + T33_phi * sin(2 * Tau) * sin(2 * Tau);

        NewT12re = T12_re_phi * cos(2 * Tau) + T23_im_phi * sin(2 * Tau);

        NewT22 = T22_phi;   

        NewT33 = T11_phi * sin(2 * Tau) * sin(2 * Tau) - T13_im_phi * sin(4 * Tau);
        NewT33 = NewT33 + T33_phi * cos(2 * Tau) * cos(2 * Tau);

        if (SyntRGB == 1) {
          if (strcmp(SyntRGBFormat, "pauli") == 0) {
            SyntBlue[lig][col] = NewT11;
            SyntRed[lig][col] = NewT22;
            SyntGreen[lig][col] = NewT33;
            }
          if (strcmp(SyntRGBFormat, "sinclair") == 0) {
            SyntBlue[lig][col] = 0.5 * (NewT11 + NewT22) + NewT12re;
            SyntRed[lig][col] = 0.5 * (NewT11 + NewT22) - NewT12re;
            SyntGreen[lig][col] = 0.5 * NewT33;
            }
          }

        if (SyntBMP == 1)
          SyntBmp[lig][col] = 0.5 * (NewT11 + NewT22) + NewT12re;
        } else {
        if (SyntRGB == 1) {
          SyntBlue[lig][col] = 0.;
          SyntRed[lig][col] = 0.;
          SyntGreen[lig][col] = 0.;
          }
        if (SyntBMP == 1) SyntBmp[lig][col] = 0.;
        }
      }
    }

  if (SyntBMP == 1) {
    write_block_matrix_float(out_bmp, SyntBmp, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
    }
  if (SyntRGB == 1) {
    write_block_matrix_float(out_blue, SyntBlue, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
    write_block_matrix_float(out_red, SyntRed, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
    write_block_matrix_float(out_green, SyntGreen, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
    }

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_avg, NpolarOut, NligBlock[0]);
  if (SyntBMP == 1) {
    free_matrix_float(SyntBmp, NligBlock[0]);
    }
  if (SyntRGB == 1) {
    free_matrix_float(SyntBlue, NligBlock[0]);
    free_matrix_float(SyntRed, NligBlock[0]);
    free_matrix_float(SyntGreen, NligBlock[0]);
    }
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  if (SyntBMP == 1) {
    fclose(out_bmp);
    }
  if (SyntRGB == 1) {
    fclose(out_blue);
    fclose(out_red);
    fclose(out_green);
    }
/********************************************************************
********************************************************************/

  return 1;
}


