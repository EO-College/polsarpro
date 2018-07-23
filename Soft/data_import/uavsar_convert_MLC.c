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

File   : uavsar_convert_MLC.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER, Marco LAVALLE (JPL ipUAVSAR)
Version  : 1.0
Creation : 08/2010
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

Description :  Convert UAV-SAR Binary Data Files 
               (Format MLC et GRD)

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
/* C3 matrix */
#define C11   0
#define C12   1
#define C13   2
#define C22   3
#define C23   4
#define C33   5

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
#define Npol 6
#define NPolType 2
/* LOCAL VARIABLES */
  FILE *in_file[Npol], *HeaderFile;
  int Config;
  char *PolTypeConf[NPolType] = {"C3", "T3"};
  char header_file_name[FilePathLength], str[256], name[256], value[256];
  char filenameHHHH[FilePathLength], filenameHHHV[FilePathLength], filenameHHVV[FilePathLength];
  char filenameHVHV[FilePathLength], filenameHVVV[FilePathLength], filenameVVVV[FilePathLength];
  
/* Internal variables */
  int ii, lig, col, k, l, r;
  int indlig, indcol;
  int SubSampLig, SubSampCol;
  int NLookLig, NLookCol;
 
  int IEEE;
  
  char *pc;
  float fl1, fl2;
  float *v;

  int NligBlockFinal;

/* Matrix arrays */
  float *X_in;
  float ***M_in;
  float ***M_out;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nuavsar_convert_MLC.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-hf  	UAVSAR header file\n");
strcat(UsageHelp," (string)	-if1 	input data file HHHH\n");
strcat(UsageHelp," (string)	-if2 	input data file HHHV\n");
strcat(UsageHelp," (string)	-if3 	input data file HHVV\n");
strcat(UsageHelp," (string)	-if4 	input data file HVHV\n");
strcat(UsageHelp," (string)	-if5 	input data file HVVV\n");
strcat(UsageHelp," (string)	-if6 	input data file VVVV\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-odf 	output data format\n");
strcat(UsageHelp," (int)   	-inr 	Initial Number of Row\n");
strcat(UsageHelp," (int)   	-inc 	Initial Number of Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (int)   	-nlr 	Nlook Row (1 = no multi-looking)\n");
strcat(UsageHelp," (int)   	-nlc 	Nlook Col (1 = no multi-looking)\n");
strcat(UsageHelp," (int)   	-ssr 	Sub-sampling Row (1 = no subsampling)\n");
strcat(UsageHelp," (int)   	-ssc 	Sub-sampling Col (1 = no subsampling)\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (int)   	-mem 	Allocated memory for blocksize determination (in Mb)\n");
strcat(UsageHelp," (string)	-errf	memory error file\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");
strcat(UsageHelp," (noarg) 	-data	displays the help concerning Data Format parameter\n");

/*******************************************************************/

strcpy(UsageHelpDataFormat,"\nPolarimetric Output Data Format\n");
strcat(UsageHelpDataFormat," C3 	output : covariance C3\n");
strcat(UsageHelpDataFormat,"\n");
strcat(UsageHelpDataFormat," T3 	output : coherency T3\n");
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

if(argc < 39) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-hf",str_cmd_prm,header_file_name,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if1",str_cmd_prm,filenameHHHH,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if2",str_cmd_prm,filenameHHHV,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if3",str_cmd_prm,filenameHHVV,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if4",str_cmd_prm,filenameHVHV,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if5",str_cmd_prm,filenameHVVV,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if6",str_cmd_prm,filenameVVVV,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-odf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-inr",int_cmd_prm,&Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-inc",int_cmd_prm,&Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nlr",int_cmd_prm,&NLookLig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nlc",int_cmd_prm,&NLookCol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ssr",int_cmd_prm,&SubSampLig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ssc",int_cmd_prm,&SubSampCol,1,UsageHelp);

  get_commandline_prm(argc,argv,"-errf",str_cmd_prm,file_memerr,0,UsageHelp);

  MemoryAlloc = -1;
  get_commandline_prm(argc,argv,"-mem",int_cmd_prm,&MemoryAlloc,0,UsageHelp);
  MemoryAlloc = my_max(MemoryAlloc,1000);

  Config = 0;
  for (ii=0; ii<NPolType; ii++) if (strcmp(PolTypeConf[ii],PolType) == 0) Config = 1;
  if (Config == 0) edit_error("\nWrong argument in the Polarimetric Data Format\n",UsageHelpDataFormat);

  if (NLookLig == 0) edit_error("\nWrong argument in the Nlook Row parameter\n",UsageHelp);
  if (NLookCol == 0) edit_error("\nWrong argument in the Nlook Col parameter\n",UsageHelp);
  if (SubSampLig == 0) edit_error("\nWrong argument in the Sub Sampling Row parameter\n",UsageHelp);
  if (SubSampCol == 0) edit_error("\nWrong argument in the Sub Sampling Col parameter\n",UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(header_file_name);
  check_file(filenameHHHH);
  check_file(filenameHHHV);
  check_file(filenameHHVV);
  check_file(filenameHVHV);
  check_file(filenameHVVV);
  check_file(filenameVVVV);
  check_dir(out_dir);

/********************************************************************
********************************************************************/

  /* Scan the header file */
  if ((HeaderFile = fopen(header_file_name, "rt")) == NULL)
  edit_error("Could not open input file : ", header_file_name);

  IEEE = 0;
  rewind(HeaderFile);
  while ( !feof(HeaderFile) ) {
    fgets(str, 256, HeaderFile);
    r = sscanf(str,"%s %*s = %s", name, value);
    if (r == 2 && strcmp(name, "val_endi") == 0 && strcmp(value, "LITTLE") == 0)  IEEE = 0;
    if (r == 2 && strcmp(name, "val_endi") == 0 && strcmp(value, "BIG")  == 0)  IEEE = 1;
    }
  fclose(HeaderFile);

/********************************************************************
********************************************************************/

  NwinL = 1; NwinC = 1;

/* POLAR TYPE CONFIGURATION */
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);
  
  file_name_out = matrix_char(NpolarOut,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeOut, out_dir, file_name_out);

/* DATA FILES */
  if ((in_file[0] = fopen(filenameHHHH, "rb")) == NULL)
    edit_error("Could not open input file : ", filenameHHHH);
  if ((in_file[1] = fopen(filenameHHHV, "rb")) == NULL)
    edit_error("Could not open input file : ", filenameHHHV);
  if ((in_file[2] = fopen(filenameHHVV, "rb")) == NULL)
    edit_error("Could not open input file : ", filenameHHVV);
  if ((in_file[3] = fopen(filenameHVHV, "rb")) == NULL)
    edit_error("Could not open input file : ", filenameHVHV);
  if ((in_file[4] = fopen(filenameHVVV, "rb")) == NULL)
    edit_error("Could not open input file : ", filenameHVVV);
  if ((in_file[5] = fopen(filenameVVVV, "rb")) == NULL)
    edit_error("Could not open input file : ", filenameVVVV);
    
/* OUTPUT FILE OPENING*/
  for (Np = 0; Np < NpolarOut; Np++)
    if ((out_datafile[Np] = fopen(file_name_out[Np], "wb")) == NULL)
      edit_error("Could not open input file : ", file_name_out[Np]);
  
/********************************************************************
********************************************************************/
/* MEMORY ALLOCATION */
/*
MemAlloc = NBlockA*Nlig + NBlockB
*/ 

/* Local Variables */
  NBlockA = 0; NBlockB = 0;

  /* Mout = NpolarOut*Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
  /* Min = Npol*Nlig*Ncol */
  NBlockA += NpolarOut*Ncol; NBlockB += 0;
  /* Xin = Npol*Nlig*Ncol */
  NBlockA += 0; NBlockB += 2*Ncol;
  
/* Reading Data */
  NBlockB += NpolarIn*2*Ncol + NpolarOut*NwinL*(Ncol+NwinC);

  memory_alloc(file_memerr, Sub_Nlig, 0, &NbBlock, NligBlock, NBlockA, NBlockB, MemoryAlloc);

  if (NbBlock != 1) block_alloc(NligBlock, SubSampLig, NLookLig, Sub_Nlig, &NbBlock);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  X_in = vector_float(2*Ncol);
  M_in = matrix3d_float(NpolarOut, NligBlock[0], Ncol);
  M_out = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);
  
/********************************************************************
********************************************************************/
/* DATA PROCESSING */

  Sub_Nlig = (int) floor((Sub_Nlig / SubSampLig) / NLookLig);
  Sub_Ncol = (int) floor((Sub_Ncol / SubSampCol) / NLookCol);

  /* Offset Lines Reading */
  for (lig = 0; lig < Off_lig; lig++)
    for (Np = 0; Np < Npol; Np++) {
      if (Np == C11 || Np == C22 || Np == C33)
        fread(&X_in[0], sizeof(float), Ncol, in_file[Np]);
      else
        fread(&X_in[0], sizeof(float), 2*Ncol, in_file[Np]);
      }
  
for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (Np = 0; Np < Npol; Np++) {
      if (IEEE == 0) {
        if (Np == C11 || Np == C22 || Np == C33)
          fread(&X_in[0], sizeof(float), Ncol, in_file[Np]);
        else
          fread(&X_in[0], sizeof(float), 2*Ncol, in_file[Np]);
        }
      if (IEEE == 1) {
        if (Np == C11 || Np == C22 || Np == C33)
          for (col = 0; col < Ncol; col++) {
            v = &fl1;pc = (char *) v;
            pc[3] = getc(in_file[Np]);pc[2] = getc(in_file[Np]);
            pc[1] = getc(in_file[Np]);pc[0] = getc(in_file[Np]);
            X_in[col] = fl1;
            }
        else 
          for (col = 0; col < Ncol; col++) {
            v = &fl1;pc = (char *) v;
            pc[3] = getc(in_file[Np]);pc[2] = getc(in_file[Np]);
            pc[1] = getc(in_file[Np]);pc[0] = getc(in_file[Np]);
            v = &fl2;pc = (char *) v;
            pc[3] = getc(in_file[Np]);pc[2] = getc(in_file[Np]);
            pc[1] = getc(in_file[Np]);pc[0] = getc(in_file[Np]);
            X_in[2 * col] = fl1;X_in[2 * col + 1] = fl2;
            }
        }
      if (Np == C11) for (col = 0; col < Ncol; col++) M_in[0][lig][col] = X_in[col];
      if (Np == C12) for (col = 0; col < Ncol; col++) M_in[1][lig][col] = X_in[2*col];
      if (Np == C12) for (col = 0; col < Ncol; col++) M_in[2][lig][col] = X_in[2*col+1];
      if (Np == C13) for (col = 0; col < Ncol; col++) M_in[3][lig][col] = X_in[2*col];
      if (Np == C13) for (col = 0; col < Ncol; col++) M_in[4][lig][col] = X_in[2*col+1];
      if (Np == C22) for (col = 0; col < Ncol; col++) M_in[5][lig][col] = X_in[col];
      if (Np == C23) for (col = 0; col < Ncol; col++) M_in[6][lig][col] = X_in[2*col];
      if (Np == C23) for (col = 0; col < Ncol; col++) M_in[7][lig][col] = X_in[2*col+1];
      if (Np == C33) for (col = 0; col < Ncol; col++) M_in[8][lig][col] = X_in[col];
      }
    for (col = 0; col < Ncol; col++) {
      for (Np = 0; Np < NpolarOut; Np++) {
        if (my_isfinite(M_in[Np][lig][col]) == 0) M_in[Np][lig][col] = eps;
        }
      }
    }
    
    if (strcmp(PolTypeOut,"T3")==0) C3_to_T3(M_in, NligBlock[Nb], Ncol, 0, 0);

    NligBlockFinal = (int) floor(NligBlock[Nb]/ (SubSampLig*NLookLig));
    for (lig = 0; lig < NligBlockFinal; lig++) {
      if (NbBlock <= 2) PrintfLine(lig,NligBlockFinal);
      indlig = lig * SubSampLig * NLookLig;
      for (col = 0; col < Sub_Ncol; col++) {
        indcol = col * SubSampCol * NLookCol;
        for (Np = 0; Np < NpolarOut; Np++) {
          M_out[Np][lig][col] = 0.;
          for (k = 0; k < NLookLig; k++)
            for (l = 0; l < NLookCol; l++)
              M_out[Np][lig][col] += M_in[Np][indlig+k][indcol+l+Off_col];
          M_out[Np][lig][col] /= (NLookLig*NLookCol);
          }
        }
      }
      
    write_block_matrix3d_float(out_datafile, NpolarOut, M_out, NligBlockFinal, Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/* OUPUT CONFIGURATIONS */
  strcpy(PolarCase, "monostatic");
  strcpy(PolarType, "full");
  write_config(out_dir, Sub_Nlig, Sub_Ncol, PolarCase, PolarType);

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */

  free_matrix3d_float(M_in, Npol, NligBlock[0]);
  free_matrix3d_float(M_out, NpolarOut, NligBlock[0]);
  
/********************************************************************
********************************************************************/

/* OUTPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarOut; Np++) fclose(out_datafile[Np]);
  for (Np = 0; Np < Npol; Np++) fclose(in_file[Np]);
  
/********************************************************************
********************************************************************/

  return 1;
}


