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

File   : coarse_coregistration.c
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

Description :  Coarse coRegistration of the Master and Slave 
               Directory data sets.

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
  
/* Internal variables */
  int lig, col, np, Np, ii;
  int Nligfin,Ncolfin;
  int ShiftRow, ShiftCol;
  int OffRow, OffCol;

  float *M_in;
  float *M_out;
  
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncoarse_coregistration.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-sr  	Shift Row\n");
strcat(UsageHelp," (int)   	-sc  	Shift Col\n");
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

if(argc < 11) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-sr",int_cmd_prm,&ShiftRow,1,UsageHelp);
  get_commandline_prm(argc,argv,"-sc",int_cmd_prm,&ShiftCol,1,UsageHelp);

  Config = 0;
  for (ii=0; ii<NPolType; ii++) if (strcmp(PolTypeConf[ii],PolType) == 0) Config = 1;
  if (Config == 0) edit_error("\nWrong argument in the Polarimetric Data Format\n",UsageHelpDataFormat);
  }

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_dir(out_dir);

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);

/* POLAR TYPE CONFIGURATION */
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);

  file_name_in = matrix_char(NpolarIn,1024); 
  file_name_out = matrix_char(NpolarOut,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir, file_name_in);
  init_file_name(PolTypeOut, out_dir, file_name_out);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
    if ((in_datafile[Np] = fopen(file_name_in[Np], "rb")) == NULL)
      edit_error("Could not open input file : ", file_name_in[Np]);

/* OUTPUT FILE OPENING*/
  for (Np = 0; Np < NpolarOut; Np++)
    if ((out_datafile[Np] = fopen(file_name_out[Np], "wb")) == NULL)
      edit_error("Could not open output file : ", file_name_out[Np]);
  
/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  if (ShiftRow > 0) OffRow = ShiftRow;
  else OffRow = -ShiftRow;
  if (ShiftCol > 0) OffCol = ShiftCol;
  else OffCol = -ShiftCol;

  Nligfin = Nlig - OffRow;
  Ncolfin = Ncol - OffCol;

  M_in = vector_float(2 * Ncol);
  M_out = vector_float(2 * Ncol);

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

for (np = 0; np < NpolarIn; np++) rewind(in_datafile[np]);
 
for (np = 0; np < NpolarIn; np++) {

  if ((ShiftRow <= 0)&&(ShiftCol <= 0)) {
  //Slave Data
    for (col = 0; col < 2*Ncol; col++) M_out[col] = 0.;
    for (lig = 0; lig < OffRow; lig++) fwrite(&M_out[0], sizeof(float), 2 * Ncol, out_datafile[np]);
    for (lig = 0; lig < Nligfin; lig++) {
      PrintfLine(lig,Nligfin);
      fread(&M_in[0], sizeof(float), 2 * Ncol, in_datafile[np]);
      for (col = 0; col < 2*Ncol; col++) M_out[col] = 0.;
      for (col = 0; col < Ncolfin; col++) {
        M_out[2*(col + OffCol)] = M_in[2*col];
        M_out[2*(col + OffCol)+ 1] = M_in[2*col + 1];
        }
      fwrite(&M_out[0], sizeof(float), 2 * Ncol, out_datafile[np]);
      }
    }

  if ((ShiftRow <= 0)&&(ShiftCol > 0)) {
  //Slave Data
    for (col = 0; col < 2*Ncol; col++) M_out[col] = 0.;
    for (lig = 0; lig < OffRow; lig++) fwrite(&M_out[0], sizeof(float), 2 * Ncol, out_datafile[np]);
    for (lig = 0; lig < Nligfin; lig++) {
      PrintfLine(lig,Nligfin);
      fread(&M_in[0], sizeof(float), 2 * Ncol, in_datafile[np]);
      for (col = 0; col < 2*Ncol; col++) M_out[col] = 0.;
      for (col = 0; col < Ncolfin; col++) {
        M_out[2*col] = M_in[2*(col+OffCol)];
        M_out[2*col + 1] = M_in[2*(col+OffCol) + 1];
        }
      fwrite(&M_out[0], sizeof(float), 2 * Ncol, out_datafile[np]);
      }
    }

  if ((ShiftRow > 0)&&(ShiftCol <= 0)) {
  //Slave Data
    for (lig = 0; lig < OffRow; lig++) fread(&M_in[0], sizeof(float), 2 * Ncol, in_datafile[np]);
    for (lig = 0; lig < Nligfin; lig++) {
      PrintfLine(lig,Nligfin);
      fread(&M_in[0], sizeof(float), 2 * Ncol, in_datafile[np]);
      for (col = 0; col < 2*Ncol; col++) M_out[col] = 0.;
      for (col = 0; col < Ncolfin; col++) {
        M_out[2*(col + OffCol)] = M_in[2*col];
        M_out[2*(col + OffCol)+ 1] = M_in[2*col + 1];
        }
      fwrite(&M_out[0], sizeof(float), 2 * Ncol, out_datafile[np]);
      }
    for (col = 0; col < 2*Ncol; col++) M_out[col] = 0.;
    for (lig = Nligfin; lig < Nlig; lig++) fwrite(&M_out[0], sizeof(float), 2 * Ncol, out_datafile[np]);
    }

  if ((ShiftRow > 0)&&(ShiftCol > 0)) {
  //Slave Data
    for (lig = 0; lig < OffRow; lig++) fread(&M_in[0], sizeof(float), 2 * Ncol, in_datafile[np]);
    for (lig = 0; lig < Nligfin; lig++) {
      PrintfLine(lig,Nligfin);
      fread(&M_in[0], sizeof(float), 2 * Ncol, in_datafile[np]);
      for (col = 0; col < 2*Ncol; col++) M_out[col] = 0.;
      for (col = 0; col < Ncolfin; col++) {
        M_out[2*col] = M_in[2*(col+OffCol)];
        M_out[2*col + 1] = M_in[2*(col+OffCol) + 1];
        }
      fwrite(&M_out[0], sizeof(float), 2 * Ncol, out_datafile[np]);
      }
    for (col = 0; col < 2*Ncol; col++) M_out[col] = 0.;
    for (lig = Nligfin; lig < Nlig; lig++) fwrite(&M_out[0], sizeof(float), 2 * Ncol, out_datafile[np]);
    }
 } // Np

read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);
write_config(out_dir, Nlig, Ncol, PolarCase, PolarType);

for (np = 0; np < NpolarIn; np++)  fclose(in_datafile[np]);
for (np = 0; np < NpolarIn; np++)  fclose(out_datafile[np]);

free_vector_float(M_out);
free_vector_float(M_in);

return 1;
}
