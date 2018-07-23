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

File   : file_operand.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2012
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

Description :  File (operand) = File

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

/* LOCAL VARIABLES */
  FILE *in_file, *out_file;
  char file_in[FilePathLength], file_out[FilePathLength];  
  char type_in[10], type_out[10];  
  char operand[10];
  
/* Internal variables */
  int lig, col;
  float mod, arg;
  
/* Matrix arrays */
  float **M_in;
  float **M_out;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nfile_operand.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input file name\n");
strcat(UsageHelp," (string)	-it  	input file type\n");
strcat(UsageHelp," (string)	-of  	output file name\n");
strcat(UsageHelp," (string)	-ot  	output file type\n");
strcat(UsageHelp," (string)	-op  	operand\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
strcat(UsageHelp," (int)   	-mem 	Allocated memory for blocksize determination (in Mb)\n");
strcat(UsageHelp," (string)	-errf	memory error file\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 19) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,file_in,1,UsageHelp);
  get_commandline_prm(argc,argv,"-it",str_cmd_prm,type_in,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,file_out,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ot",str_cmd_prm,type_out,1,UsageHelp);
  get_commandline_prm(argc,argv,"-op",str_cmd_prm,operand,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);

  get_commandline_prm(argc,argv,"-errf",str_cmd_prm,file_memerr,0,UsageHelp);

  MemoryAlloc = -1;
  get_commandline_prm(argc,argv,"-mem",int_cmd_prm,&MemoryAlloc,0,UsageHelp);
  MemoryAlloc = my_max(MemoryAlloc,1000);

  FlagValid = 0;strcpy(file_valid,"");
  get_commandline_prm(argc,argv,"-mask",str_cmd_prm,file_valid,0,UsageHelp);
  if (strcmp(file_valid,"") != 0) FlagValid = 1;
  }

/********************************************************************
********************************************************************/

  check_file(file_in);
  check_file(file_out);
  if (FlagValid == 1) check_file(file_valid);

  NwinL = 1; NwinC = 1;
  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

  NpolarIn = 1; NpolarOut = 1;
  Nlig = Sub_Nlig; Ncol = Sub_Ncol;
  
/********************************************************************
********************************************************************/
/* INPUT FILE OPENING*/
  if ((in_file = fopen(file_in, "rb")) == NULL)
    edit_error("Could not open input file : ", file_in);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  if ((out_file = fopen(file_out, "wb")) == NULL)
    edit_error("Could not open input file : ", file_out);
  
/********************************************************************
********************************************************************/
/* MEMORY ALLOCATION */
/*
MemAlloc = NBlockA*Nlig + NBlockB
*/ 

/* Local Variables */
  NBlockA = 0; NBlockB = 0;
  /* Mask = (Nlig+NwinL)*(Ncol+NwinC) */ 
  NBlockA += Ncol+NwinC; NBlockB += NwinL*(Ncol+NwinC);

  if (strcmp(type_in,"cmplx") == 0 ) {
    /* Min1 = 2*(Nlig+NwinL)*(Ncol+NwinC) */
    NBlockA += 2*(Ncol+NwinC); NBlockB += 2*NwinL*(Ncol+NwinC);
    } else {
    /* Min1 = (Nlig+NwinL)*(Ncol+NwinC) */
    NBlockA += (Ncol+NwinC); NBlockB += 2*NwinL*(Ncol+NwinC);
    }

  if (strcmp(type_out,"cmplx") == 0 ) {
    /* Mout = 2*Sub_Nlig*Sub_Ncol */
    NBlockA += 2*Sub_Ncol; NBlockB += 0;
    } else {
    /* Mout = Sub_Nlig*Sub_Ncol */
    NBlockA += Sub_Ncol; NBlockB += 0;
    }
  
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

  Valid = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);

  if (strcmp(type_in,"cmplx") == 0 ) 
    M_in = matrix_float(NligBlock[0] + NwinL, 2*(Ncol + NwinC));
  if (strcmp(type_in,"float") == 0 ) 
    M_in = matrix_float(NligBlock[0] + NwinL, (Ncol + NwinC));
    
  if (strcmp(type_out,"cmplx") == 0 ) 
    M_out = matrix_float(NligBlock[0] + NwinL, 2*(Ncol + NwinC));
  if (strcmp(type_out,"float") == 0 ) 
    M_out = matrix_float(NligBlock[0] + NwinL, (Ncol + NwinC));

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
    for (lig = 0; lig < NligBlock[0] + NwinL; lig++) 
      for (col = 0; col < Sub_Ncol + NwinC; col++) 
        Valid[lig][col] = 1.;

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) PrintfLine(Nb,NbBlock);

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  if (strcmp(type_in,"cmplx") == 0 ) 
    read_block_matrix_cmplx(in_file, M_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
  if (strcmp(type_in,"float") == 0 ) 
    read_block_matrix_float(in_file, M_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        if (strcmp(type_in,"cmplx") == 0 ) {
          if (strcmp(operand,"real") == 0 ) {
            M_out[lig][col] = M_in[lig][2*col];
            }
          if (strcmp(operand,"imag") == 0 ) {
            M_out[lig][col] = M_in[lig][2*col+1];
            }
          if (strcmp(operand,"arg") == 0 ) {
            M_out[lig][col] = atan2(M_in[lig][2*col+1],M_in[lig][2*col])*180./pi;
            }
          if (strcmp(operand,"argrad") == 0 ) {
            M_out[lig][col] = atan2(M_in[lig][2*col+1],M_in[lig][2*col]);
            }
          if (strcmp(operand,"abs") == 0 ) {
            M_out[lig][col] = sqrt(M_in[lig][2*col]*M_in[lig][2*col]+M_in[lig][2*col+1]*M_in[lig][2*col+1]);
            }
          if (strcmp(operand,"cos") == 0 ) {
            M_out[lig][2*col] = cos(M_in[lig][2*col])*cosh(M_in[lig][2*col+1]);
            M_out[lig][2*col+1] = -sin(M_in[lig][2*col])*sinh(M_in[lig][2*col+1]);
            }
          if (strcmp(operand,"sin") == 0 ) {
            M_out[lig][2*col] = sin(M_in[lig][2*col])*cosh(M_in[lig][2*col+1]);
            M_out[lig][2*col+1] = cos(M_in[lig][2*col])*sinh(M_in[lig][2*col+1]);
            }
          if (strcmp(operand,"tan") == 0 ) {
            M_out[lig][2*col] = (tan(M_in[lig][2*col])*(1.-tanh(M_in[lig][2*col+1])*tanh(M_in[lig][2*col+1])))/(1.+tan(M_in[lig][2*col])*tan(M_in[lig][2*col])*tanh(M_in[lig][2*col+1])*tanh(M_in[lig][2*col+1]));
            M_out[lig][2*col+1] = (tanh(M_in[lig][2*col+1])*(1.+tan(M_in[lig][2*col])*tan(M_in[lig][2*col])))/(1.+tan(M_in[lig][2*col])*tan(M_in[lig][2*col])*tanh(M_in[lig][2*col+1])*tanh(M_in[lig][2*col+1]));
            }
          if (strcmp(operand,"conj") == 0 ) {
            M_out[lig][2*col] = M_in[lig][2*col];
            M_out[lig][2*col+1] = -M_in[lig][2*col+1];
            }
          if (strcmp(operand,"sqrt") == 0 ) {
            mod = sqrt(M_in[lig][2*col]*M_in[lig][2*col]+M_in[lig][2*col+1]*M_in[lig][2*col+1]);
            arg = atan2(M_in[lig][2*col+1],M_in[lig][2*col]);
            M_out[lig][2*col] = sqrt(mod)*cos(arg/2.);
            M_out[lig][2*col+1] = sqrt(mod)*sin(arg/2.);          
            }
          if (strcmp(operand,"x2") == 0 ) {
            mod = sqrt(M_in[lig][2*col]*M_in[lig][2*col]+M_in[lig][2*col+1]*M_in[lig][2*col+1]);
            arg = atan2(M_in[lig][2*col+1],M_in[lig][2*col]);
            M_out[lig][2*col] = mod*mod*cos(2.*arg);
            M_out[lig][2*col+1] = mod*mod*sin(2.*arg);          
            }
          if (strcmp(operand,"x3") == 0 ) {
            mod = sqrt(M_in[lig][2*col]*M_in[lig][2*col]+M_in[lig][2*col+1]*M_in[lig][2*col+1]);
            arg = atan2(M_in[lig][2*col+1],M_in[lig][2*col]);
            M_out[lig][2*col] = mod*mod*mod*cos(3.*arg);
            M_out[lig][2*col+1] = mod*mod*mod*sin(3.*arg);          
            }
          if (strcmp(operand,"log") == 0 ) {
            mod = sqrt(M_in[lig][2*col]*M_in[lig][2*col]+M_in[lig][2*col+1]*M_in[lig][2*col+1]);
            M_out[lig][col] = log10(mod);
            }
          if (strcmp(operand,"ln") == 0 ) {
            mod = sqrt(M_in[lig][2*col]*M_in[lig][2*col]+M_in[lig][2*col+1]*M_in[lig][2*col+1]);
            M_out[lig][col] = log(mod);
            }
          if (strcmp(operand,"10x") == 0 ) {
            M_out[lig][2*col] = exp(M_in[lig][2*col]*log(10.))*cos(M_in[lig][2*col+1]*log(10.));
            M_out[lig][2*col+1] = exp(M_in[lig][2*col]*log(10.))*sin(M_in[lig][2*col+1]*log(10.));
            }
          if (strcmp(operand,"exp") == 0 ) {
            M_out[lig][2*col] = exp(M_in[lig][2*col])*cos(M_in[lig][2*col+1]);
            M_out[lig][2*col+1] = exp(M_in[lig][2*col])*sin(M_in[lig][2*col+1]);
            }
          if (strcmp(operand,"10log") == 0 ) {
            mod = sqrt(M_in[lig][2*col]*M_in[lig][2*col]+M_in[lig][2*col+1]*M_in[lig][2*col+1]);
            M_out[lig][col] = 10.*log10(mod);
            }
          if (strcmp(operand,"20log") == 0 ) {
            mod = sqrt(M_in[lig][2*col]*M_in[lig][2*col]+M_in[lig][2*col+1]*M_in[lig][2*col+1]);
            M_out[lig][col] = 20.*log10(mod);
            }
          }
          
        if (strcmp(type_in,"float") == 0 ) {
          if (strcmp(operand,"real") == 0 ) {
            M_out[lig][col] = M_in[lig][col];
            }
          if (strcmp(operand,"imag") == 0 ) {
            M_out[lig][col] = 0.;
            }
          if (strcmp(operand,"arg") == 0 ) {
            M_out[lig][col] = 0.;
            }
          if (strcmp(operand,"argrad") == 0 ) {
            M_out[lig][col] = 0.;
            }
          if (strcmp(operand,"abs") == 0 ) {
            M_out[lig][col] = fabs(M_in[lig][col]);
            }
          if (strcmp(operand,"cos") == 0 ) {
            M_out[lig][col] = cos(M_in[lig][col]);
            }
          if (strcmp(operand,"sin") == 0 ) {
            M_out[lig][col] = sin(M_in[lig][col]);
            }
          if (strcmp(operand,"tan") == 0 ) {
            M_out[lig][col] = tan(M_in[lig][col]);
            }
          if (strcmp(operand,"conj") == 0 ) {
            M_out[lig][col] = M_in[lig][col];
            }
          if (strcmp(operand,"acos") == 0 ) {
            if ((-1.0 < M_in[lig][col])&&(M_in[lig][col] < 1.0)) M_out[lig][col] = acos(M_in[lig][col]);
            else M_out[lig][col] = 0.;
            }
          if (strcmp(operand,"asin") == 0 ) {
            if ((-1.0 < M_in[lig][col])&&(M_in[lig][col] < 1.0)) M_out[lig][col] = asin(M_in[lig][col]);
            else M_out[lig][col] = 0.;
            }
          if (strcmp(operand,"atan") == 0 ) {
            M_out[lig][col] = atan(M_in[lig][col]);
            }
          if (strcmp(operand,"sqrt") == 0 ) {
            if (0.0 <= M_in[lig][col]) M_out[lig][col] = sqrt(M_in[lig][col]);
            else M_out[lig][col] = 0.;
            }
          if (strcmp(operand,"x2") == 0 ) {
            M_out[lig][col] = M_in[lig][col]*M_in[lig][col];
            }
          if (strcmp(operand,"x3") == 0 ) {
            M_out[lig][col] = M_in[lig][col]*M_in[lig][col]*M_in[lig][col];
            }
          if (strcmp(operand,"log") == 0 ) {
            M_out[lig][col] = log10(fabs(M_in[lig][col]));
            }
          if (strcmp(operand,"ln") == 0 ) {
            M_out[lig][col] = log(fabs(M_in[lig][col]));
            }
          if (strcmp(operand,"10x") == 0 ) {
            M_out[lig][col] = exp(10.*log(fabs(M_in[lig][col])));
            }
          if (strcmp(operand,"exp") == 0 ) {
            M_out[lig][col] = exp(M_in[lig][col]);
            }
          if (strcmp(operand,"10log") == 0 ) {
            M_out[lig][col] = 10.*log10(fabs(M_in[lig][col]));
            }
          if (strcmp(operand,"20log") == 0 ) {
            M_out[lig][col] = 20.*log10(fabs(M_in[lig][col]));
            }
          }
     
        } else {
        if (strcmp(type_out,"cmplx") == 0 ) {M_out[lig][2*col] = 0.; M_out[lig][2*col+1] = 0.;}
        if (strcmp(type_out,"float") == 0 ) {M_out[lig][col] = 0.;}
        }
      }
    }
  
  if (strcmp(type_out,"cmplx") == 0 ) write_block_matrix_cmplx(out_file, M_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  if (strcmp(type_out,"float") == 0 ) write_block_matrix_float(out_file, M_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(M_in, NligBlock[0] + NwinL);
  free_matrix_float(M_out, NligBlock[0]);
  free_matrix_float(Valid, NligBlock[0] + NwinL);
*/  
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  fclose(out_file);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  fclose(in_file);
/********************************************************************
********************************************************************/

  return 1;
}


