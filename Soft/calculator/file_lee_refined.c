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

File   : file_lee_refined.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2014
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

Description :  File (lee refined) = File

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

int make_Coeff(float sigma2, int Deplct, int Nnwin, int NwinM1S2, int Sub_Nlig, int Sub_Ncol, float **span, float ***Mask, int **Nmax, float **coeff);
void make_Mask(float ***Mask, int Nwin);

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
  
/* Internal variables */
  int lig, col, k, l;
  int Nnwin, Deplct, Nlook;
  float sigma2, Npoints, mean;
  
/* Matrix arrays */
  float **M_in;
  float **M_out;
  float ***Mask;
  float **span;
  float **coeff;
  int **Nmax;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nfile_lee_refined.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input file name\n");
strcat(UsageHelp," (string)	-of  	output file name\n");
strcat(UsageHelp," (int)   	-nw  	Nwin Row and Col\n");
strcat(UsageHelp," (int)   	-nlk 	Nlook\n");
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

if(argc < 17) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,file_in,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,file_out,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nw",int_cmd_prm,&Nwin,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nlk",int_cmd_prm,&Nlook,1,UsageHelp);
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

  NwinM1S2 = (Nwin - 1) / 2;
  NwinL = Nwin; NwinC = Nwin;

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

  /* Min1 = (Nlig+NwinL)*(Ncol+NwinC) */
  NBlockA += (Ncol+NwinC); NBlockB += NwinL*(Ncol+NwinC);
  /* Mout = Sub_Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  
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

  M_in = matrix_float(NligBlock[0] + NwinL, Ncol + NwinC);
  M_out = matrix_float(NligBlock[0], Sub_Ncol);

  Mask = matrix3d_float(8, Nwin, Nwin);
  span = matrix_float(NligBlock[0] + Nwin, Ncol + Nwin);
  coeff = matrix_float(NligBlock[0], Sub_Ncol);
  Nmax = matrix_int(NligBlock[0] + Nwin, Ncol + Nwin);

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
    for (lig = 0; lig < NligBlock[0] + NwinL; lig++) 
      for (col = 0; col < Sub_Ncol + NwinC; col++) 
        Valid[lig][col] = 1.;

/********************************************************************
********************************************************************/
/* Speckle variance given by the input data number of looks */
  sigma2 = 1. / (float) Nlook;

/* Gradient window calculation parameters */
  switch (Nwin) {
  case 3:
  Nnwin = 1;
  Deplct = 1;
  break;
  case 5:
  Nnwin = 3;
  Deplct = 1;
  break;
  case 7:
  Nnwin = 3;
  Deplct = 2;
  break;
  case 9:
  Nnwin = 5;
  Deplct = 2;
  break;
  case 11:
  Nnwin = 5;
  Deplct = 3;
  break;
  case 13:
  Nnwin = 5;
  Deplct = 4;
  break;
  case 15:
  Nnwin = 7;
  Deplct = 4;
  break;
  case 17:
  Nnwin = 7;
  Deplct = 5;
  break;
  case 19:
  Nnwin = 7;
  Deplct = 6;
  break;
  case 21:
  Nnwin = 9;
  Deplct = 6;
  break;
  case 23:
  Nnwin = 9;
  Deplct = 7;
  break;
  case 25:
  Nnwin = 9;
  Deplct = 8;
  break;
  case 27:
  Nnwin = 11;
  Deplct = 8;
  break;
  case 29:
  Nnwin = 11;
  Deplct = 9;
  break;
  case 31:
  Nnwin = 11;
  Deplct = 10;
  break;
  default:
  edit_error("The window width Nwin must be set to 3 to 31","");
  }
  
/* Create Mask */
  make_Mask(Mask, Nwin);
  
/********************************************************************
********************************************************************/
/* DATA PROCESSING */

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) PrintfLine(Nb,NbBlock);

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  read_block_matrix_float(in_file, M_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  /* Span Determination */
  for (lig = 0; lig < NligBlock[Nb]+Nwin; lig++) {
    if (NbBlock <= 2) PrintfLine(lig,NligBlock[Nb]+Nwin);
    for (col = 0; col < Sub_Ncol+Nwin; col++) {
      span[lig][col] = M_in[lig][col]*M_in[lig][col];
      }
    }
  
  /* Filtering Coeff determination */
  make_Coeff(sigma2, Deplct, Nnwin, NwinM1S2, NligBlock[Nb], Sub_Ncol, span, Mask, Nmax, coeff);

  /* Filtering Element per Element */  
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinM1S2+lig][NwinM1S2+col] == 1.) {
        mean = 0.; Npoints = 0.;
        for (k = -NwinM1S2; k < 1 + NwinM1S2; k++)
          for (l = -NwinM1S2; l < 1 +NwinM1S2; l++) {
            if (Mask[Nmax[lig][col]][NwinM1S2 + k][NwinM1S2 + l] == 1) {
              mean += M_in[NwinM1S2+lig+k][NwinM1S2+col+l];
              Npoints = Npoints + 1.;
              }
            }
        mean /= Npoints;
        /* Filtering f(x)=E(x)+k*(x-E(x)) */
        M_out[lig][col] = mean + coeff[lig][col] * (M_in[NwinM1S2+lig][NwinM1S2+col] - mean);
        }
      }
    }
  
  write_block_matrix_float(out_file, M_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

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

/********************************************************************
Routine  : make_Coeff
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description :  Creates the Filtering Coefficient
*--------------------------------------------------------------------
********************************************************************/
int make_Coeff(float sigma2, int Deplct, int Nnwin, int NwinM1S2,  
        int Sub_Nlig, int Sub_Ncol, float **span, 
        float ***Mask, int **Nmax, float **coeff)
{
/* Internal variables */
  int lig, col, k, l, kk, ll;
  float m_span, m_span2, v_span, cv_span;

  float subwin[3][3];
  float Dist[4], MaxDist, Npoints;

/* FILTERING */
  for (lig = 0; lig < Sub_Nlig; lig++) {
      for (col = 0; col < Sub_Ncol; col++) {

/* 3*3 average SPAN Sub_window calculation for directional gradient determination */
    for (k = 0; k < 3; k++) {
      for (l = 0; l < 3; l++) {
        subwin[k][l] = 0.;
        for (kk = 0; kk < Nnwin; kk++)
          for (ll = 0; ll < Nnwin; ll++)
            subwin[k][l] +=  span[k * Deplct + kk + lig][l * Deplct + ll + col] / (float) (Nnwin * Nnwin);
        }
      }

/* Directional gradient computation */
    Dist[0] = -subwin[0][0] + subwin[0][2] - subwin[1][0] + subwin[1][2] - subwin[2][0] + subwin[2][2];
    Dist[1] =  subwin[0][1] + subwin[0][2] - subwin[1][0] + subwin[1][2] - subwin[2][0] - subwin[2][1];
    Dist[2] =  subwin[0][0] + subwin[0][1] + subwin[0][2] - subwin[2][0] - subwin[2][1] - subwin[2][2];
    Dist[3] =  subwin[0][0] + subwin[0][1] + subwin[1][0] - subwin[1][2] - subwin[2][1] - subwin[2][2];

/* Choice of a directional mask according to the maximum gradient */
    MaxDist = -INIT_MINMAX;
    for (k = 0; k < 4; k++)
      if (MaxDist < fabs(Dist[k])) {
        MaxDist = fabs(Dist[k]);
        Nmax[lig][col] = k;
        }
    if (Dist[Nmax[lig][col]] > 0.) Nmax[lig][col] = Nmax[lig][col] + 4;

/*Within window statistics*/
    m_span = 0.;
    m_span2 = 0.;
    Npoints = 0.;

    for (k = -NwinM1S2; k < 1 + NwinM1S2; k++)
    for (l = -NwinM1S2; l < 1 + NwinM1S2; l++)
      if (Mask[Nmax[lig][col]][NwinM1S2 + k][NwinM1S2 + l] == 1) {
        m_span += span[NwinM1S2 + k + lig][NwinM1S2 + l + col];
        m_span2 += span[NwinM1S2 + k + lig][NwinM1S2 + l + col] * span[NwinM1S2 + k + lig][NwinM1S2 + l + col];
        Npoints = Npoints + 1.;
        }

    m_span /= Npoints;
    m_span2 /= Npoints;

/* SPAN variation coefficient cv_span */
    v_span = m_span2 - m_span * m_span;  /* Var(x) = E(x^2)-E(x)^2 */
    cv_span = sqrt(fabs(v_span)) / (eps + m_span);

/* Linear filter coefficient */
    coeff[lig][col] = (cv_span * cv_span - sigma2) / (cv_span * cv_span * (1 + sigma2) + eps);
    if (coeff[lig][col] < 0.) coeff[lig][col] = 0.;

    }      /*col */
  }        /*lig */
  
  return 1;
}

/********************************************************************
Routine  : make_Mask
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*--------------------------------------------------------------------
Description :  Creates a set of 8 Nwin*Nwin pixel directional mask
        (0 or 1)
*--------------------------------------------------------------------
********************************************************************/
void make_Mask(float ***Mask, int Nwin)
{
  int k, l, Nmax;


  for (k = 0; k < Nwin; k++)
  for (l = 0; l < Nwin; l++)
    for (Nmax = 0; Nmax < 8; Nmax++)
    Mask[Nmax][k][l] = 0.;

  Nmax = 0;
  for (k = 0; k < Nwin; k++)
  for (l = (Nwin - 1) / 2; l < Nwin; l++)
    Mask[Nmax][k][l] = 1.;

  Nmax = 4;
  for (k = 0; k < Nwin; k++)
  for (l = 0; l < 1 + (Nwin - 1) / 2; l++)
    Mask[Nmax][k][l] = 1.;


  Nmax = 1;
  for (k = 0; k < Nwin; k++)
  for (l = k; l < Nwin; l++)
    Mask[Nmax][k][l] = 1.;


  Nmax = 5;
  for (k = 0; k < Nwin; k++)
  for (l = 0; l < k + 1; l++)
    Mask[Nmax][k][l] = 1.;


  Nmax = 2;
  for (k = 0; k < 1 + (Nwin - 1) / 2; k++)
  for (l = 0; l < Nwin; l++)
    Mask[Nmax][k][l] = 1.;


  Nmax = 6;
  for (k = (Nwin - 1) / 2; k < Nwin; k++)
  for (l = 0; l < Nwin; l++)
    Mask[Nmax][k][l] = 1.;


  Nmax = 3;
  for (k = 0; k < Nwin; k++)
  for (l = 0; l < Nwin - k; l++)
    Mask[Nmax][k][l] = 1.;


  Nmax = 7;
  for (k = 0; k < Nwin; k++)
  for (l = Nwin - 1 - k; l < Nwin; l++)
    Mask[Nmax][k][l] = 1.;
}
