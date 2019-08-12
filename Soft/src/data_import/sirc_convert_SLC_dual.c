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

File   : sirc_convert_SLC_dual.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 2.0
Creation : 05/2011
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

Description :  Convert SIR-C CEOS format data file

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

#define Npol 2
#define NPolType 3
/* LOCAL VARIABLES */
  FILE *in_file, *headerfile;
  int Config;
  char *PolTypeConf[NPolType] = {"SPP", "SPPC2", "SPPIPP"};
  char file_name[FilePathLength], Tmp[FilePathLength], ConfigFile[FilePathLength];
  
/* Internal variables */
  int ii, lig, col, k, l;
  int indlig, indcol;
  int SubSampLig, SubSampCol;
  int NLookLig, NLookCol;
 
  char b[10];
  int imode, isamp, ibytes, ioffset;
  float ysca;

  int NligBlockFinal;

/* Matrix arrays */
  float ***S_in;
  float ***M_in;
  float ***M_out;
  char *buf;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nsirc_convert_SLC_dual.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input data file\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-odf 	output data format\n");
strcat(UsageHelp," (int)   	-nr  	Number of Row\n");
strcat(UsageHelp," (int)   	-nc  	Number of Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (string)	-cf  	input PSP config file\n");
strcat(UsageHelp," (int)   	-nlr 	Nlook Row (1 = no multi-looking)\n");
strcat(UsageHelp," (int)   	-nlc 	Nlook Col (1 = no multi-looking)\n");
strcat(UsageHelp," (int)   	-ssr 	Sub-sampling Row (1 = no subsampling)\n");
strcat(UsageHelp," (int)   	-ssc 	Sub-sampling Col (1 = no subsampling)\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-errf	memory error file\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");
strcat(UsageHelp," (noarg) 	-data	displays the help concerning Data Format parameter\n");

/*******************************************************************/

strcpy(UsageHelpDataFormat,"\nPolarimetric Output Data Format\n");
strcat(UsageHelpDataFormat," SPP 	output : dual-pol SPP\n");
strcat(UsageHelpDataFormat,"\n");
strcat(UsageHelpDataFormat," SPPC2	output : covariance C2\n");
strcat(UsageHelpDataFormat,"\n");
strcat(UsageHelpDataFormat," SPPIPP	output : intensities IPP\n");
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

if(argc < 29) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,file_name,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-odf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nr",int_cmd_prm,&Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nc",int_cmd_prm,&Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-cf",str_cmd_prm,ConfigFile,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nlr",int_cmd_prm,&NLookLig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nlc",int_cmd_prm,&NLookCol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ssr",int_cmd_prm,&SubSampLig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ssc",int_cmd_prm,&SubSampCol,1,UsageHelp);

  get_commandline_prm(argc,argv,"-errf",str_cmd_prm,file_memerr,0,UsageHelp);

  MemoryAlloc = -1; MemoryAlloc = CheckFreeMemory();
  MemoryAlloc = my_max(MemoryAlloc,1000);

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

  if (NLookLig == 0) edit_error("\nWrong argument in the Nlook Row parameter\n",UsageHelp);
  if (NLookCol == 0) edit_error("\nWrong argument in the Nlook Col parameter\n",UsageHelp);
  if (SubSampLig == 0) edit_error("\nWrong argument in the Sub Sampling Row parameter\n",UsageHelp);
  if (SubSampCol == 0) edit_error("\nWrong argument in the Sub Sampling Col parameter\n",UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(file_name);
  check_dir(out_dir);
  check_file(ConfigFile);

  NwinL = 1; NwinC = 1;

/* POLAR TYPE CONFIGURATION */
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);
  
  file_name_out = matrix_char(NpolarOut,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeOut, out_dir, file_name_out);

/* HEADER FILE */
  if ((headerfile = fopen(ConfigFile, "rb")) == NULL)
  edit_error("Could not open input file : ", ConfigFile);
  rewind(headerfile);
  fscanf(headerfile, "%s\n", Tmp); fscanf(headerfile, "%s\n", Tmp); fscanf(headerfile, "%s\n", Tmp);
  fscanf(headerfile, "%s\n", Tmp); fscanf(headerfile, "%i\n", &isamp); fscanf(headerfile, "%s\n", Tmp);
  fscanf(headerfile, "%s\n", Tmp); fscanf(headerfile, "%s\n", Tmp); fscanf(headerfile, "%s\n", Tmp);
  fscanf(headerfile, "%s\n", Tmp); fscanf(headerfile, "%i\n", &imode); fscanf(headerfile, "%s\n", Tmp);
  fscanf(headerfile, "%s\n", Tmp); fscanf(headerfile, "%i\n", &ibytes); fscanf(headerfile, "%s\n", Tmp);
  fclose(headerfile);
  ioffset = 12;

  if (imode == 1) strcpy(PolarType, "pp3");
  if (imode == 2) strcpy(PolarType, "pp1");
  if (imode == 3) strcpy(PolarType, "pp2");
  if (imode == 7) strcpy(PolarType, "pp2");
  if (imode == 8) strcpy(PolarType, "pp1");

/* DATA FILE */
  if ((in_file = fopen(file_name, "rb")) == NULL)
  edit_error("Could not open input file : ", file_name);

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

  if ((strcmp(PolTypeOut,"SPPpp1")==0) || (strcmp(PolTypeOut,"SPPpp2")==0) ||(strcmp(PolTypeOut,"SPPpp3")==0)){
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
  if ((strcmp(PolTypeOut,"SPPpp1")==0) || (strcmp(PolTypeOut,"SPPpp2")==0) ||(strcmp(PolTypeOut,"SPPpp3")==0)){
    M_out = matrix3d_float(NpolarOut, NligBlock[0], 2*Sub_Ncol);
    } else {
    M_in = matrix3d_float(NpolarOut, NligBlock[0], Ncol);
    M_out = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);
    }    
  
    buf = vector_char(isamp * ibytes + ioffset);

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

  Sub_Nlig = (int) floor((Sub_Nlig / SubSampLig) / NLookLig);
  Sub_Ncol = (int) floor((Sub_Ncol / SubSampCol) / NLookCol);

/* OFFSET HEADER DATA READING */
  rewind(in_file);
  fseek(in_file, (long) (isamp * ibytes + ioffset), 1);

  /* Offset Lines Reading */
  for (lig = 0; lig < Off_lig; lig++) 
    fread(&buf[0], sizeof(char), isamp * ibytes + ioffset , in_file);
  
for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    /* Position file pointer past 12-byte CEOS preamble header */
    fseek(in_file, ioffset, 1);
    for (col = 0; col < Ncol; col++) {
      fread(b, sizeof(char), 6, in_file);
      ysca = (float) sqrt(((double) b[1] / 254.0 + 1.5) *   pow(2.0, (double) b[0]));
      if (strcmp(PolarType,"pp1") == 0) {
        S_in[0][lig][2*col] = (float) b[2] * ysca / 127.0;
        S_in[0][lig][2*col + 1] = (float) b[3] * ysca / 127.0;
        S_in[1][lig][2*col] = (float) b[4] * ysca / 127.0;
        S_in[1][lig][2*col + 1] = (float) b[5] * ysca / 127.0;
        }
      if (strcmp(PolarType,"pp2") == 0) {
        //S_in[0][lig][2*col] = (float) b[2] * ysca / 127.0;
        //S_in[0][lig][2*col + 1] = (float) b[3] * ysca / 127.0;
        //S_in[1][lig][2*col] = (float) b[4] * ysca / 127.0;
        //S_in[1][lig][2*col + 1] = (float) b[5] * ysca / 127.0;
        S_in[1][lig][2*col] = (float) b[2] * ysca / 127.0;
        S_in[1][lig][2*col + 1] = (float) b[3] * ysca / 127.0;
        S_in[0][lig][2*col] = (float) b[4] * ysca / 127.0;
        S_in[0][lig][2*col + 1] = (float) b[5] * ysca / 127.0;
        }
      if (strcmp(PolarType,"pp3") == 0) {
        S_in[0][lig][2*col] = (float) b[2] * ysca / 127.0;
        S_in[0][lig][2*col + 1] = (float) b[3] * ysca / 127.0;
        S_in[1][lig][2*col] = (float) b[4] * ysca / 127.0;
        S_in[1][lig][2*col + 1] = (float) b[5] * ysca / 127.0;
        }
      for (Np = 0; Np < Npol; Np++) {
        if (my_isfinite(S_in[Np][lig][2*col]) == 0) S_in[Np][lig][2*col] = eps;
        if (my_isfinite(S_in[Np][lig][2*col + 1]) == 0) S_in[Np][lig][2*col + 1] = eps;
        }
      }
    }

  if ((strcmp(PolTypeOut,"SPPpp1")==0) || (strcmp(PolTypeOut,"SPPpp2")==0) ||(strcmp(PolTypeOut,"SPPpp3")==0)){
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
      
    } else {

    if ((strcmp(PolTypeOut,"C2pp1")==0) || (strcmp(PolTypeOut,"C2pp2")==0) ||(strcmp(PolTypeOut,"C2pp3")==0)) 
      SPP_to_C2(S_in, M_in, NligBlock[Nb], Ncol, 0, 0);
    else SPP_to_IPP(S_in, M_in, NligBlock[Nb], Ncol, 0, 0);

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

    }
  
  } // NbBlock

/* OUPUT CONFIGURATIONS */
  strcpy(PolarCase, "monostatic");
  if (strcmp(PolTypeOut,"IPPpp5")==0) strcpy(PolarCase, "intensities"); 
  if (strcmp(PolTypeOut,"IPPpp6")==0) strcpy(PolarCase, "intensities"); 
  if (strcmp(PolTypeOut,"IPPpp7")==0) strcpy(PolarCase, "intensities"); 
  write_config(out_dir, Sub_Nlig, Sub_Ncol, PolarCase, PolarType);

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */

  free_matrix3d_float(S_in, NpolarIn, NligBlock[0]);
  if ((strcmp(PolTypeOut,"SPPpp1")!=0) && (strcmp(PolTypeOut,"SPPpp2")!=0) && (strcmp(PolTypeOut,"SPPpp3")!=0)) free_matrix3d_float(M_in, NpolarOut, NligBlock[0]);
  free_matrix3d_float(M_out, NpolarOut, NligBlock[0]);
  
/********************************************************************
********************************************************************/

/* OUTPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarOut; Np++) fclose(out_datafile[Np]);
  fclose(in_file);
  
/********************************************************************
********************************************************************/

  return 1;
}


