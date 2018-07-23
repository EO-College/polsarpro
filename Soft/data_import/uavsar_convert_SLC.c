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

File   : uavsar_convert_SLC.c
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
B�t. 11D - Campus de Beaulieu
263 Avenue G�n�ral Leclerc
35042 RENNES Cedex
Tel :(+33) 2 23 23 57 63
Fax :(+33) 2 23 23 69 63
e-mail: eric.pottier@univ-rennes1.fr

*--------------------------------------------------------------------

Description :  Convert UAV-SAR Binary Data Files 
              (Format SLC)

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

#define Npol 4
#define NPolType 5
/* LOCAL VARIABLES */
  FILE *in_file[Npol], *HeaderFile;
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C3", "C4", "T3", "T4"};
  char header_file_name[FilePathLength], str[256], name[256], value[256];
  char filename11[FilePathLength], filename12[FilePathLength], filename21[FilePathLength], filename22[FilePathLength];
  
/* Internal variables */
  int ii, lig, col, k, l, r;
  int indlig, indcol;
  int SubSampLig, SubSampCol;
  int NLookLig, NLookCol;
 
  int IEEE, Symmetrisation;
  
  float xx;

  char *pc;
  float fl1, fl2;
  float *v;

  int NligBlockFinal;

/* Matrix arrays */
  float ***S_in;
  float ***M_in;
  float ***M_out;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nuavsar_convert_SLC.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-hf  	UAVSAR header file\n");
strcat(UsageHelp," (string)	-if1 	input data file: s11.bin\n");
strcat(UsageHelp," (string)	-if2 	input data file: s12.bin\n");
strcat(UsageHelp," (string)	-if3 	input data file: s21.bin\n");
strcat(UsageHelp," (string)	-if4 	input data file: s22.bin\n");
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
strcat(UsageHelp," (int)   	-sym 	symmetrisation (no: 0, yes: 1)\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (int)   	-mem 	Allocated memory for blocksize determination (in Mb)\n");
strcat(UsageHelp," (string)	-errf	memory error file\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");
strcat(UsageHelp," (noarg) 	-data	displays the help concerning Data Format parameter\n");

/*******************************************************************/

strcpy(UsageHelpDataFormat,"\nPolarimetric Output Data Format\n");
strcat(UsageHelpDataFormat," S2 	output : quad-pol S2\n");
strcat(UsageHelpDataFormat,"\n");
strcat(UsageHelpDataFormat," C3 	output : covariance C3\n");
strcat(UsageHelpDataFormat,"\n");
strcat(UsageHelpDataFormat," C4 	output : covariance C4\n");
strcat(UsageHelpDataFormat,"\n");
strcat(UsageHelpDataFormat," T3 	output : coherency T3\n");
strcat(UsageHelpDataFormat,"\n");
strcat(UsageHelpDataFormat," T4 	output : coherency T4\n");
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

if(argc < 37) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-hf",str_cmd_prm,header_file_name,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if1",str_cmd_prm,filename11,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if2",str_cmd_prm,filename12,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if3",str_cmd_prm,filename21,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if4",str_cmd_prm,filename22,1,UsageHelp);
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
  get_commandline_prm(argc,argv,"-sym",int_cmd_prm,&Symmetrisation,1,UsageHelp);

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
  check_file(filename11);
  check_file(filename12);
  check_file(filename21);
  check_file(filename22);
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
  NpolarIn = 4;
  
  file_name_out = matrix_char(NpolarOut,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeOut, out_dir, file_name_out);

/* DATA FILES */
  if ((in_file[0] = fopen(filename11, "rb")) == NULL)
    edit_error("Could not open input file : ", filename11);
  if ((in_file[1] = fopen(filename12, "rb")) == NULL)
    edit_error("Could not open input file : ", filename12);
  if ((in_file[2] = fopen(filename21, "rb")) == NULL)
    edit_error("Could not open input file : ", filename21);
  if ((in_file[3] = fopen(filename22, "rb")) == NULL)
    edit_error("Could not open input file : ", filename22);
    
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

  if (strcmp(PolTypeOut,"S2")==0) {
    /* Mout = NpolarOut*Nlig*2*Sub_Ncol */
    NBlockA += NpolarOut*2*Sub_Ncol; NBlockB += 0;
    } else {
    /* Mout = NpolarOut*Nlig*Sub_Ncol */
    NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
    /* Min = NpolarOut*Nlig*Ncol */
    NBlockA += NpolarOut*Ncol; NBlockB += 0;
    }    
  /* Sin = NpolarIn*Nlig*2*Ncol */
  NBlockA += NpolarIn*2*Ncol; NBlockB += 0;
  
/* Reading Data */
  NBlockB += NpolarIn*2*Ncol + NpolarOut*NwinL*(Ncol+NwinC);

  memory_alloc(file_memerr, Sub_Nlig, 0, &NbBlock, NligBlock, NBlockA, NBlockB, MemoryAlloc);

  if (NbBlock != 1) block_alloc(NligBlock, SubSampLig, NLookLig, Sub_Nlig, &NbBlock);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  S_in = matrix3d_float(NpolarIn, NligBlock[0], 2*Ncol);
  if (strcmp(PolTypeOut,"S2")==0) {
    M_out = matrix3d_float(NpolarOut, NligBlock[0], 2*Sub_Ncol);
    } else {
    M_in = matrix3d_float(NpolarOut, NligBlock[0], Ncol);
    M_out = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);
    }    
  
/********************************************************************
********************************************************************/
/* DATA PROCESSING */

  Sub_Nlig = (int) floor((Sub_Nlig / SubSampLig) / NLookLig);
  Sub_Ncol = (int) floor((Sub_Ncol / SubSampCol) / NLookCol);

  /* Offset Lines Reading */
  for (lig = 0; lig < Off_lig; lig++)
    for (Np = 0; Np < Npol; Np++) 
      fread(&S_in[Np][0][0], sizeof(float), 2 * Ncol, in_file[Np]);
  
for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (Np = 0; Np < Npol; Np++) {
      if (IEEE == 0)
        fread(&S_in[Np][lig][0], sizeof(float), 2 * Ncol, in_file[Np]);
      if (IEEE == 1) {
        for (col = 0; col < Ncol; col++) {
          v = &fl1;pc = (char *) v;
          pc[3] = getc(in_file[Np]);pc[2] = getc(in_file[Np]);
          pc[1] = getc(in_file[Np]);pc[0] = getc(in_file[Np]);
          v = &fl2;pc = (char *) v;
          pc[3] = getc(in_file[Np]);pc[2] = getc(in_file[Np]);
          pc[1] = getc(in_file[Np]);pc[0] = getc(in_file[Np]);
          S_in[Np][lig][2 * col] = fl1;S_in[Np][lig][2 * col + 1] = fl2;
          }
        }
      }
    for (col = 0; col < Ncol; col++) {
      for (Np = 0; Np < Npol; Np++) {
        if (my_isfinite(S_in[Np][lig][2*col]) == 0) S_in[Np][lig][2*col] = eps;
        if (my_isfinite(S_in[Np][lig][2*col + 1]) == 0) S_in[Np][lig][2*col + 1] = eps;
        }
      }
    }

  if (strcmp(PolTypeOut,"S2")==0) {
    /* Symmetrisation */
    if (Symmetrisation == 1) {
      for (lig = 0; lig < NligBlock[Nb]; lig++) {
        PrintfLine(lig,NligBlock[Nb]);
        for (col = 0; col < Ncol; col++) {
          xx = (S_in[s12][lig][2*col]+S_in[s21][lig][2*col])/2.;
          S_in[s12][lig][2*col] = xx; S_in[s21][lig][2*col] = xx;
          xx = (S_in[s12][lig][2*col+1]+S_in[s21][lig][2*col+1])/2.;
          S_in[s12][lig][2*col+1] = xx; S_in[s21][lig][2*col+1] = xx;
          }
        }
      }
    NligBlockFinal = (int) floor(NligBlock[Nb]/ (SubSampLig));
    for (lig = 0; lig < NligBlockFinal; lig++) {
      if (NbBlock <= 2) PrintfLine(lig,NligBlockFinal);
      indlig = lig * SubSampLig;
      for (col = 0; col < Sub_Ncol; col++) {
        indcol = col * SubSampCol;
        for (Np = 0; Np < NpolarOut; Np++) {
          M_out[Np][lig][2*col] = S_in[Np][indlig][2*(indcol+Off_col)];
          M_out[Np][lig][2*col+1] = S_in[Np][indlig][2*(indcol+Off_col)+1];
          }
        }
      }

    write_block_matrix3d_cmplx(out_datafile, NpolarOut, M_out, NligBlockFinal, Sub_Ncol, 0, 0, Sub_Ncol);

    if (Symmetrisation == 1) strcpy(PolarCase, "monostatic");
    if (Symmetrisation == 0) strcpy(PolarCase, "bistatic");
      
    } else {

    if (strcmp(PolTypeOut,"C3")==0) S2_to_C3(S_in, M_in, NligBlock[Nb], Ncol, 0, 0);
    if (strcmp(PolTypeOut,"T3")==0) S2_to_T3(S_in, M_in, NligBlock[Nb], Ncol, 0, 0);
    if (strcmp(PolTypeOut,"C4")==0) S2_to_C4(S_in, M_in, NligBlock[Nb], Ncol, 0, 0);
    if (strcmp(PolTypeOut,"T4")==0) S2_to_T4(S_in, M_in, NligBlock[Nb], Ncol, 0, 0);

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

    if (strcmp(PolTypeOut,"C3")==0) strcpy(PolarCase, "monostatic");
    if (strcmp(PolTypeOut,"C4")==0) strcpy(PolarCase, "bistatic");
    if (strcmp(PolTypeOut,"T3")==0) strcpy(PolarCase, "monostatic");
    if (strcmp(PolTypeOut,"T4")==0) strcpy(PolarCase, "bistatic");
    }
  
  } // NbBlock

/* OUPUT CONFIGURATIONS */
  strcpy(PolarType, "full");
  write_config(out_dir, Sub_Nlig, Sub_Ncol, PolarCase, PolarType);

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */

  free_matrix3d_float(S_in, NpolarIn, NligBlock[0]);
  if (strcmp(PolTypeOut,"S2")!=0) free_matrix3d_float(M_in, NpolarOut, NligBlock[0]);
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


