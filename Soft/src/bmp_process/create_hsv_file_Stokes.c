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

File   : create_hsv_file_Stokes.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
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

Description : Creation of a HSV BMP file from Partial Polar Data 
              using the Stokes parameters

Hue = arctg(g2 / g1);
Sat = sqrt( (g1/g0)^2 + (g2/g0)^2 )
Val = 0.5*(1 - g3/g0)

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

/* CONSTANTS  */

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

#define NPolType 2
/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = { "SPP", "C2"};

  FILE *filebmp;
  char FileOutput[FilePathLength];
  
/* Internal variables */
  int lig, col, ii, l;
  float g0, g1, g2, g3;
  float hue, sat, val, red, green, blue;
  float m1, m2, h;

/* Matrix arrays */
  char *dataimg;
  float ***M_in;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncreate_hsv_file_Stokes.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-of  	output BMP file\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
strcat(UsageHelp," (string)	-errf	memory error file\n");
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

if(argc < 15) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);

  get_commandline_prm(argc,argv,"-errf",str_cmd_prm,file_memerr,0,UsageHelp);

  MemoryAlloc = -1; MemoryAlloc = CheckFreeMemory();
  MemoryAlloc = my_max(MemoryAlloc,1000);

  FlagValid = 0;strcpy(file_valid,"");
  get_commandline_prm(argc,argv,"-mask",str_cmd_prm,file_valid,0,UsageHelp);
  if (strcmp(file_valid,"") != 0) FlagValid = 1;

  Config = 0;
  for (ii=0; ii<NPolType; ii++) if (strcmp(PolTypeConf[ii],PolType) == 0) Config = 1;
  if (Config == 0) edit_error("\nWrong argument in the Polarimetric Data Format\n",UsageHelpDataFormat);
  }

/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

  NwinL = 1; NwinC = 1;

  ExtraColBMP = (int) fmod(4 - (int) fmod(3*Sub_Ncol, 4), 4);
  NcolBMP = 3*Sub_Ncol + ExtraColBMP;
  ExtraColBMP = (int) fmod(4 - (int) fmod(Sub_Ncol, 4), 4);
  Sub_NcolBMP = Sub_Ncol + ExtraColBMP;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);

/* POLAR TYPE CONFIGURATION */
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);
  NpolarOut = 4; strcpy(PolTypeOut,"C2");
    
  file_name_in = matrix_char(NpolarIn,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir, file_name_in);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
    if ((in_datafile[Np] = fopen(file_name_in[Np], "rb")) == NULL)
      edit_error("Could not open input file : ", file_name_in[Np]);

  if (FlagValid == 1) {
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);
    }

/* OUTPUT FILE OPENING*/
  if ((filebmp = fopen(FileOutput, "wb")) == NULL)
    edit_error("Could not open output file : ", FileOutput);
  
/********************************************************************
********************************************************************/
/* MEMORY ALLOCATION */
/*
MemAlloc = NBlockA*Nlig + NBlockB
*/ 

/* Local Variables */
  NBlockA = 0; NBlockB = 0;

  /* Mask */ 
  NBlockA += Sub_NcolBMP; NBlockB += 0;

  /* DataTmp = Sub_Nlig*Sub_Ncol */
  NBlockB += Sub_Nlig*Sub_NcolBMP;
  /* DataTmp = Sub_Nlig*Sub_Ncol dans le minmaxcontrastmedian*/
  NBlockB += Sub_Nlig*Sub_NcolBMP;

  /* Min = NpolarOut*Nlig*Ncol */
  NBlockA += NpolarOut*Sub_NcolBMP; NBlockB += 0;

/* Reading Data */
  NBlockB += Ncol + 2*Ncol + NpolarIn*2*Ncol + NpolarOut*NwinL*(Ncol+NwinC);

  memory_alloc(file_memerr, Sub_Nlig, 0, &NbBlock, NligBlock, NBlockA, NBlockB, MemoryAlloc);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  _VC_in = vector_float(2*Ncol);
  _VF_in = vector_float(Ncol);
  _MC_in = matrix_float(4,2*Ncol);
  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   
 
  M_in = matrix3d_float(NpolarOut, NligBlock[0], Sub_NcolBMP);
  Valid = matrix_float(NligBlock[0], Sub_NcolBMP);

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) { 
    for (lig = 0; lig < NligBlock[0]; lig++) 
      for (col = 0; col < Sub_Ncol; col++) 
        Valid[lig][col] = 1.;
    }

/*******************************************************************/
/* OUTPUT BMP FILE CREATION */
/*******************************************************************/

/* BMP HDR FILE */
  write_bmp_hdr(Sub_Nlig, Sub_Ncol, 0., 0., 24, FileOutput);

  dataimg = vector_char(NcolBMP);

/* BMP HEADER */
  write_header_bmp_24bit(Sub_Nlig, Sub_Ncol, filebmp);

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
if (FlagValid == 1) rewind(in_valid);

/* OFFSET READING */
for (Np = 0; Np < NpolarIn; Np++) my_fseek(in_datafile[Np], 1, Off_lig + Sub_Nlig, 2*Ncol*sizeof(float));    
if (FlagValid == 1) my_fseek(in_valid, 1, Off_lig + Sub_Nlig, Ncol*sizeof(float));

/********************************************************************
********************************************************************/

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (FlagValid == 1) {
    my_fseek(in_valid, -1, NligBlock[Nb], Ncol*sizeof(float));
    read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, 0, Off_col, Ncol);
    my_fseek(in_valid, -1, NligBlock[Nb], Ncol*sizeof(float));
    }
    
  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {

    for (Np = 0; Np < NpolarIn; Np++)
      my_fseek(in_datafile[Np], -1, NligBlock[Nb], 2*Ncol*sizeof(float));
      read_block_SPP_noavg(in_datafile, M_in, "C2", 4, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, 0, Off_col, Ncol);
    for (Np = 0; Np < NpolarIn; Np++)
      my_fseek(in_datafile[Np], -1, NligBlock[Nb], 2*Ncol*sizeof(float));

    } else {

    /* Case of C,T or I */
    for (Np = 0; Np < NpolarIn; Np++)
      my_fseek(in_datafile[Np], -1, NligBlock[Nb], Ncol*sizeof(float));
    read_block_TCI_noavg(in_datafile, M_in, NpolarIn, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, 0, Off_col, Ncol);
    for (Np = 0; Np < NpolarIn; Np++)
      my_fseek(in_datafile[Np], -1, NligBlock[Nb], Ncol*sizeof(float));
    }

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NligBlock[Nb] - 1 - lig][col] == 1.) {  
        g0 = M_in[C211][NligBlock[Nb] - 1 - lig][col]+M_in[C222][NligBlock[Nb] - 1 - lig][col];
        g1 = M_in[C211][NligBlock[Nb] - 1 - lig][col]-M_in[C222][NligBlock[Nb] - 1 - lig][col]; g1 = g1 / g0;
        g2 = 2.*M_in[C212_re][NligBlock[Nb] - 1 - lig][col]; g2 = g2 / g0;
        g3 = -2.*M_in[C212_im][NligBlock[Nb] - 1 - lig][col]; g3 = g3 / g0;
        
        hue = 180. + atan2(g2,g1)*180./pi;
        if (hue > 360.) hue = hue - 360.;
        if (hue < 0.) hue = hue + 360.;

        val = 0.5*(1. - g3);
        if (val > 1.) val = 1.;
        if (val < 0.) val = 0.;

        sat = sqrt(g1*g1 + g2*g2);
        if (sat > 1.) sat = 1.;
        if (sat < 0.) sat = 0.;

        /* CONVERSION IHSL TO RGB */

        if (sat == 0.) {
          red = val;
          green = val;
          blue = val;
          } else {
          hue = hue * pi / 180.;
          h = floor(hue / (pi / 3.));
          h = hue - h * (pi / 3.);
          h = sqrt(3.) * sat / (2.*sin(-h + 2.*pi/3.));
          m1 = h*cos(hue);
          m2 = -h*sin(hue);
          red = val + 0.7875*m1 + 0.3714*m2;
          green = val - 0.2125*m1 - 0.2059*m2;
          blue = val - 0.2125*m1 + 0.9488*m2;
          }

        if (blue > 1.) blue = 1.;
        if (blue < 0.) blue = 0.;
        l = (int) (floor(255 * blue));
        dataimg[3 * col + 0] = (char) (l);
        if (green > 1.) green = 1.;
        if (green < 0.) green = 0.;
        l = (int) (floor(255 * green));
        dataimg[3 * col + 1] = (char) (l);
        if (red > 1.) red = 1.;
        if (red < 0.) red = 0.;
        l = (int) (floor(255 * red));
        dataimg[3 * col + 2] = (char) (l);
        } else {
        dataimg[3 * col + 0] = (char) (0);
        dataimg[3 * col + 1] = (char) (1);
        dataimg[3 * col + 2] = (char) (0);
        } /* valid */
      } /*col*/
    for (col = 0; col < ExtraColBMP; col++) {
      l = (int) (floor(255 * 0.));
      dataimg[3 * Sub_Ncol + col] = (char) (l);
      } /*col*/
    fwrite(&dataimg[0], sizeof(char), NcolBMP, filebmp);
    } /*lig*/
  
  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_vector_char(dataimg);
  free_vector_float(datatmp);
  free_matrix3d_float(M_in, NpolarOut, NligBlock[0]);
  free_matrix_float(Valid, NligBlock[0]);
*/
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  fclose(filebmp);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);

/********************************************************************
********************************************************************/

  return 1;
}


