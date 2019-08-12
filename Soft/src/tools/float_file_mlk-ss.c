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

File   : float_file_MLK-SS.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 04/2017
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

Description :  Apply a multilook/subsampling on a float data file 

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
/* LOCAL VARIABLES */
  FILE *in_file, *out_file;
  char file_name_in[FilePathLength], file_name_out[FilePathLength];
  
/* Internal variables */
  int lig, col, k, l;
  int indlig, indcol;
  int SubSampLig, SubSampCol;
  int NLookLig, NLookCol;
 
  int NligBlockFinal;

/* Matrix arrays */
  float *X_in;
  float **M_in;
  float **M_out;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nfloat_file_MLK-SS.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input data file\n");
strcat(UsageHelp," (string)	-of  	output data file\n");
strcat(UsageHelp," (int)   	-inr 	Initial Number of Row\n");
strcat(UsageHelp," (int)   	-inc 	Initial Number of Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-nlr 	Nlook Row (1 = no multi-looking)\n");
strcat(UsageHelp," (int)   	-nlc 	Nlook Col (1 = no multi-looking)\n");
strcat(UsageHelp," (int)   	-ssr 	Sub-sampling Row (1 = no subsampling)\n");
strcat(UsageHelp," (int)   	-ssc 	Sub-sampling Col (1 = no subsampling)\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-errf	memory error file\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 21) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,file_name_in,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,file_name_out,1,UsageHelp);
  get_commandline_prm(argc,argv,"-inr",int_cmd_prm,&Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-inc",int_cmd_prm,&Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
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

  if (NLookLig == 0) edit_error("\nWrong argument in the Nlook Row parameter\n",UsageHelp);
  if (NLookCol == 0) edit_error("\nWrong argument in the Nlook Col parameter\n",UsageHelp);
  if (SubSampLig == 0) edit_error("\nWrong argument in the Sub Sampling Row parameter\n",UsageHelp);
  if (SubSampCol == 0) edit_error("\nWrong argument in the Sub Sampling Col parameter\n",UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(file_name_in);
  check_file(file_name_out);

/********************************************************************
********************************************************************/

  NwinL = 1; NwinC = 1;
  NpolarIn = 1; NpolarOut = 1;
  Sub_Nlig = Nlig; Sub_Ncol = Ncol;

/* DATA FILES */
  if ((in_file = fopen(file_name_in, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name_in);
    
/* OUTPUT FILE OPENING*/
  if ((out_file = fopen(file_name_out, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name_out);
    
/********************************************************************
********************************************************************/
/* MEMORY ALLOCATION */
/*
MemAlloc = NBlockA*Nlig + NBlockB
*/ 

/* Local Variables */
  NBlockA = 0; NBlockB = 0;

  /* Mout = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Min = Nlig*Ncol */
  NBlockA += Ncol; NBlockB += 0;
  /* Xin = Ncol */
  NBlockA += 0; NBlockB += Ncol;
  
/* Reading Data */
  NBlockB += NpolarIn*2*Ncol + NpolarOut*NwinL*(Ncol+NwinC);

  memory_alloc(file_memerr, Sub_Nlig, 0, &NbBlock, NligBlock, NBlockA, NBlockB, MemoryAlloc);

  if (NbBlock != 1) block_alloc(NligBlock, SubSampLig, NLookLig, Sub_Nlig, &NbBlock);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  X_in = vector_float(Ncol);
  M_in = matrix_float(NligBlock[0], Ncol);
  M_out = matrix_float(NligBlock[0], Sub_Ncol);
  
/********************************************************************
********************************************************************/
/* DATA PROCESSING */

  Sub_Nlig = (int) floor((Sub_Nlig / SubSampLig) / NLookLig);
  Sub_Ncol = (int) floor((Sub_Ncol / SubSampCol) / NLookCol);

/* OFFSET HEADER LINE READING */
    rewind(in_file);

/* Offset Lines Reading */
  for (lig = 0; lig < Off_lig; lig++)
    fread(&X_in[0], sizeof(float), Ncol, in_file);
    
for (Nb = 0; Nb < NbBlock; Nb++) {
  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    fread(&X_in[0], sizeof(float), Ncol, in_file);
    for (col = 0; col < Ncol; col++) {
      if (my_isfinite(X_in[col]) == 0) X_in[col] = eps;
      M_in[lig][col] = X_in[col];
      }
    }
    
    NligBlockFinal = (int) floor(NligBlock[Nb]/ (SubSampLig*NLookLig));
    for (lig = 0; lig < NligBlockFinal; lig++) {
      if (NbBlock <= 2) PrintfLine(lig,NligBlockFinal);
      indlig = lig * SubSampLig * NLookLig;
      for (col = 0; col < Sub_Ncol; col++) {
        indcol = col * SubSampCol * NLookCol;
        M_out[lig][col] = 0.;
        for (k = 0; k < NLookLig; k++)
          for (l = 0; l < NLookCol; l++)
            M_out[lig][col] += M_in[indlig+k][indcol+l+Off_col];
        M_out[lig][col] /= (NLookLig*NLookCol);
        }
      }
      
    write_block_matrix_float(out_file, M_out, NligBlockFinal, Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */

  free_matrix_float(M_in, NligBlock[0]);
  free_matrix_float(M_out, NligBlock[0]);
  
/********************************************************************
********************************************************************/

/* OUTPUT FILE CLOSING*/
  fclose(out_file);
  fclose(in_file);
  
/********************************************************************
********************************************************************/

  write_envi_config(file_name_out, Sub_Nlig, Sub_Ncol, 4);

/********************************************************************
********************************************************************/

  return 1;
}


