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

File   : alos_convert_15_dual.c
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

Description :  Convert ALOS-PALSAR Binary Data Files
               (Format Data Level 1.5)

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
/* LOCAL VARIABLES */
  FILE *in_file[Npol], *headerfile;
  char PolarPP[20], Tmp[FilePathLength], ConfigFile[FilePathLength];
  char File11[FilePathLength],File12[FilePathLength];
  
/* Internal variables */
  int lig, col, k, l;
  int indlig, indcol;
  int SubSampLig, SubSampCol;
  int NLookLig, NLookCol;
  
  int iheader, iprefix, ireclen;
  float calfac;
  int MS, LS;

  int NligBlockFinal;

/* Matrix arrays */
  float ***I_in;
  float ***M_out;
  char *dataread;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nalos_convert_15_dual.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if1 	input data file: s11.bin\n");
strcat(UsageHelp," (string)	-if2 	input data file: s12.bin\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (int)   	-nr  	Number of Row\n");
strcat(UsageHelp," (int)   	-nc  	Number of Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (int)   	-nlr 	Nlook Row (1 = no multi-looking)\n");
strcat(UsageHelp," (int)   	-nlc 	Nlook Col (1 = no multi-looking)\n");
strcat(UsageHelp," (int)   	-ssr 	Sub-sampling Row (1 = no subsampling)\n");
strcat(UsageHelp," (int)   	-ssc 	Sub-sampling Col (1 = no subsampling)\n");
strcat(UsageHelp," (string)	-cf  	input PSP config file\n");
strcat(UsageHelp," (string)	-pp  	polar type (pp5, pp6, pp7)\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-errf	memory error file\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");
strcat(UsageHelp," (noarg) 	-data	displays the help concerning Data Format parameter\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }
if(get_commandline_prm(argc,argv,"-data",no_cmd_prm,NULL,0,UsageHelpDataFormat)) {
  printf("\n Usage:\n%s\n",UsageHelpDataFormat); exit(1);
  }

if(argc < 31) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if1",str_cmd_prm,File11,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if2",str_cmd_prm,File12,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nr",int_cmd_prm,&Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nc",int_cmd_prm,&Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nlr",int_cmd_prm,&NLookLig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nlc",int_cmd_prm,&NLookCol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ssr",int_cmd_prm,&SubSampLig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ssc",int_cmd_prm,&SubSampCol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-cf",str_cmd_prm,ConfigFile,1,UsageHelp);
  get_commandline_prm(argc,argv,"-pp",str_cmd_prm,PolarPP,1,UsageHelp);

  get_commandline_prm(argc,argv,"-errf",str_cmd_prm,file_memerr,0,UsageHelp);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

  MemoryAlloc = -1; MemoryAlloc = CheckFreeMemory();
  MemoryAlloc = my_max(MemoryAlloc,1000);

  if (NLookLig == 0) edit_error("\nWrong argument in the Nlook Row parameter\n",UsageHelp);
  if (NLookCol == 0) edit_error("\nWrong argument in the Nlook Col parameter\n",UsageHelp);
  if (SubSampLig == 0) edit_error("\nWrong argument in the Sub Sampling Row parameter\n",UsageHelp);
  if (SubSampCol == 0) edit_error("\nWrong argument in the Sub Sampling Col parameter\n",UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(File11);
  check_file(File12);
  check_file(ConfigFile);
  check_dir(out_dir);

  NwinL = 1; NwinC = 1;

  strcpy(PolType, "IPP");
  strcpy(PolarCase, "intensities");
  if (strcmp(PolarPP, "PP1") == 0) strcpy(PolarType, "pp5");
  if (strcmp(PolarPP, "pp1") == 0) strcpy(PolarType, "pp5");
  if (strcmp(PolarPP, "PP2") == 0) strcpy(PolarType, "pp6");
  if (strcmp(PolarPP, "pp2") == 0) strcpy(PolarType, "pp6");
  if (strcmp(PolarPP, "PP3") == 0) strcpy(PolarType, "pp7");
  if (strcmp(PolarPP, "pp3") == 0) strcpy(PolarType, "pp7");
  
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
  fscanf(headerfile, "%s\n", Tmp); fscanf(headerfile, "%s\n", Tmp); fscanf(headerfile, "%s\n", Tmp);
  fscanf(headerfile, "%s\n", Tmp); fscanf(headerfile, "%s\n", Tmp); fscanf(headerfile, "%s\n", Tmp);
  fscanf(headerfile, "%s\n", Tmp); fscanf(headerfile, "%i\n", &iheader); fscanf(headerfile, "%s\n", Tmp);
  fscanf(headerfile, "%s\n", Tmp); fscanf(headerfile, "%i\n", &iprefix); fscanf(headerfile, "%s\n", Tmp);
  fscanf(headerfile, "%s\n", Tmp); fscanf(headerfile, "%i\n", &ireclen); fscanf(headerfile, "%s\n", Tmp);
  fscanf(headerfile, "%s\n", Tmp); fscanf(headerfile, "%f\n", &calfac);
  if (calfac != 0.) calfac = sqrt(pow(10.,calfac/10.));
  else calfac = 1.;
  fclose(headerfile);

/* DATA FILES */
  if ((in_file[0] = fopen(File11, "rb")) == NULL)
    edit_error("Could not open input file : ", File11);
  if ((in_file[1] = fopen(File12, "rb")) == NULL)
    edit_error("Could not open input file : ", File12);

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
  /* Iin = NpolarOut*Nlig*Ncol */
  NBlockA += NpolarOut*Ncol; NBlockB += 0;
  
/* Reading Data */
  NBlockB += NpolarIn*2*Ncol + NpolarOut*NwinL*(Ncol+NwinC);

  memory_alloc(file_memerr, Sub_Nlig, 0, &NbBlock, NligBlock, NBlockA, NBlockB, MemoryAlloc);

  if (NbBlock != 1) block_alloc(NligBlock, SubSampLig, NLookLig, Sub_Nlig, &NbBlock);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  I_in = matrix3d_float(NpolarOut, NligBlock[0], Ncol);
  M_out = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);
  dataread =  vector_char(2*Ncol);

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

  Sub_Nlig = (int) floor((Sub_Nlig / SubSampLig) / NLookLig);
  Sub_Ncol = (int) floor((Sub_Ncol / SubSampCol) / NLookCol);

/* OFFSET HEADER DATA READING */
for (Np = 0; Np < Npol; Np++) fseek(in_file[Np], iheader, SEEK_CUR);

  /* Offset Lines Reading */
  for (lig = 0; lig < Off_lig; lig++)
    for (Np = 0; Np < Npol; Np++) 
      fseek(in_file[Np], ireclen, SEEK_CUR);
  
for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (Np = 0; Np < Npol; Np++) {
      my_fseek(in_file[Np], 1, 1, iprefix);
      fread(&dataread[0], sizeof(char), 2*Ncol, in_file[Np]);
      for (col = 0; col < Ncol; col++) {
        MS = dataread[2*col]; if (MS < 0) MS = MS + 256;
        LS = dataread[2*col + 1]; if (LS < 0) LS = LS + 256;
        I_in[Np][lig][col] = (256. * MS + LS) * calfac;
        }
      }
    for (col = 0; col < Ncol; col++) {
      for (Np = 0; Np < Npol; Np++) {
        if (my_isfinite(I_in[Np][lig][col]) == 0) I_in[Np][lig][col] = eps;
        }
      }
    }

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
              M_out[Np][lig][col] += I_in[Np][indlig+k][indcol+l+Off_col]*I_in[Np][indlig+k][indcol+l+Off_col];
          M_out[Np][lig][col] /= (NLookLig*NLookCol);
          }
        }
      }
      
    write_block_matrix3d_float(out_datafile, NpolarOut, M_out, NligBlockFinal, Sub_Ncol, 0, 0, Sub_Ncol);
  
  } // NbBlock

/* OUPUT CONFIGURATIONS */
  write_config(out_dir, Sub_Nlig, Sub_Ncol, PolarCase, PolarType);

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */

  free_matrix3d_float(I_in, NpolarIn, NligBlock[0]);
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


