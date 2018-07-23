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

File   : lee_refined_filter_dual_PP.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
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

Description :  J.S. LEE refined fully polarimetric speckle filter

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

#define NPolType 2
/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = {"SPPT4", "T4"};
  
/* Internal variables */
  int ii, lig, col, k, l;
  int Nnwin, Deplct, Nlook;
  float sigma2, Npoints, mean;

/* Matrix arrays */
  float ***S_in1;
  float ***S_in2;
  float ***M_in;
  float ***M_out;
  float ***Mask;
  float **span;
  float **coeff;
  int **Nmax;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nlee_refined_filter_dual_PP.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," if iodf = SPPT4\n");
strcat(UsageHelp," (string)	-idm 	input master directory\n");
strcat(UsageHelp," (string)	-ids 	input slave directory\n");
strcat(UsageHelp," if iodf = T4\n");
strcat(UsageHelp," (string)	-id  	input master-slave directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
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

if(argc < 19) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  if (strcmp(PolType, "SPPT4") == 0) {
    get_commandline_prm(argc,argv,"-idm",str_cmd_prm,in_dir1,1,UsageHelp);
    get_commandline_prm(argc,argv,"-ids",str_cmd_prm,in_dir2,1,UsageHelp);
    }
  if (strcmp(PolType, "T4") == 0) {
    get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir1,1,UsageHelp);
    strcpy(in_dir2,in_dir1);
    }
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
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

  Config = 0;
  for (ii=0; ii<NPolType; ii++) if (strcmp(PolTypeConf[ii],PolType) == 0) Config = 1;
  if (Config == 0) edit_error("\nWrong argument in the Polarimetric Data Format\n",UsageHelpDataFormat);
  }

/********************************************************************
********************************************************************/

  check_dir(in_dir1);
  if (strcmp(PolType, "SPPT4") == 0) check_dir(in_dir2);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);
  
  NwinM1S2 = (Nwin - 1) / 2;
  NwinL = Nwin; NwinC = Nwin;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir1, &Nlig, &Ncol, PolarCase, PolarType);

/* POLAR TYPE CONFIGURATION */
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);

  file_name_in1 = matrix_char(NpolarIn,1024); 
  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) file_name_in2 = matrix_char(NpolarIn,1024); 
  file_name_out = matrix_char(NpolarOut,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir1, file_name_in1);
  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) init_file_name(PolTypeIn, in_dir2, file_name_in2);
  init_file_name(PolTypeOut, out_dir, file_name_out);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
    if ((in_datafile1[Np] = fopen(file_name_in1[Np], "rb")) == NULL)
      edit_error("Could not open input file : ", file_name_in1[Np]);
      
  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0))
    for (Np = 0; Np < NpolarIn; Np++)
      if ((in_datafile2[Np] = fopen(file_name_in2[Np], "rb")) == NULL)
        edit_error("Could not open input file : ", file_name_in2[Np]);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

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
  /* Mask */ 
  NBlockA += Sub_Ncol+Nwin; NBlockB += Nwin*(Sub_Ncol+Nwin);

  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    /* Sin = NpolarIn*Nlig*2*Ncol */
    NBlockA += 2*NpolarIn*2*(Ncol+Nwin); NBlockB += 2*NpolarIn*Nwin*2*(Ncol+Nwin);
    }

  /* Mout = NpolarOut*Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
  /* Min = NpolarOut*(Nlig+NwinL)*(Ncol+NwinC) */
  NBlockA += NpolarOut*(Ncol+Nwin); NBlockB += NpolarOut*Nwin*(Ncol+Nwin);
  /* Mask = 8*Nwin*Nwin */
  NBlockB += 8*Nwin*Nwin;
  /* span = (Nlig + Nwin)*(Ncol + Nwin) */
  NBlockA += Ncol + Nwin; NBlockB += Nwin*(Ncol + Nwin);
  /* coeff = Nlig * Sub_Ncol*/
  NBlockA += Sub_Ncol;
  /* Nmax = (Nlig + Nwin)*(Ncol + Nwin) */
  NBlockA += Ncol + Nwin; NBlockB += Nwin*(Ncol + Nwin);

/* Reading Data */
  NBlockB += Ncol + 2*Ncol + 2*NpolarIn*2*Ncol + 2*NpolarOut*NwinL*(Ncol+NwinC);

  memory_alloc(file_memerr, Sub_Nlig, Nwin, &NbBlock, NligBlock, NBlockA, NBlockB, MemoryAlloc);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  _VC_in = vector_float(2*Ncol);
  _VF_in = vector_float(Ncol);
  _MC_in = matrix_float(4,2*Ncol);
  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   

  Valid = matrix_float(NligBlock[0] + Nwin, Sub_Ncol + Nwin);

  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    S_in1 = matrix3d_float(NpolarIn, NligBlock[0] + Nwin, 2*(Ncol + Nwin));
    S_in2 = matrix3d_float(NpolarIn, NligBlock[0] + Nwin, 2*(Ncol + Nwin));
    }

  Mask = matrix3d_float(8, Nwin, Nwin);
  span = matrix_float(NligBlock[0] + Nwin, Ncol + Nwin);
  coeff = matrix_float(NligBlock[0], Sub_Ncol);
  Nmax = matrix_int(NligBlock[0] + Nwin, Ncol + Nwin);
  M_in = matrix3d_float(NpolarOut, NligBlock[0] + Nwin, Ncol + Nwin);
  M_out = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);

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

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    read_block_SPP_noavg(in_datafile1, S_in1, "SPP", 2, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, Nwin, Nwin, Off_lig, Off_col, Ncol);
    read_block_SPP_noavg(in_datafile2, S_in2, "SPP", 2, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, Nwin, Nwin, Off_lig, Off_col, Ncol);

    SPP_to_T4(S_in1, S_in2, M_in, NligBlock[Nb] + Nwin, Sub_Ncol + Nwin, 0, 0);

    } else {
    /* Case of T4 */
    read_block_TCI_noavg(in_datafile1, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, Nwin, Nwin, Off_lig, Off_col, Ncol);
    }

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, Nwin, Nwin, Off_lig, Off_col, Ncol);

  /* Span Determination */
  for (lig = 0; lig < NligBlock[Nb]+Nwin; lig++) {
    if (NbBlock <= 2) PrintfLine(lig,NligBlock[Nb]+Nwin);
    for (col = 0; col < Sub_Ncol+Nwin; col++) {
      span[lig][col] = (M_in[0][lig][col]+M_in[11][lig][col]+M_in[20][lig][col]+M_in[27][lig][col]+M_in[32][lig][col]+M_in[35][lig][col]) / 2.;
      }
    }

  /* Filtering Coeff determination */
  make_Coeff(sigma2, Deplct, Nnwin, NwinM1S2, NligBlock[Nb], Sub_Ncol, span, Mask, Nmax, coeff);

  /* Filtering Element per Element */  
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      for (Np = 0; Np < NpolarOut; Np++) M_out[Np][lig][col] = 0.;
      if (Valid[NwinM1S2+lig][NwinM1S2+col] == 1.) {
        for (Np = 0; Np < NpolarOut; Np++) {
          mean = 0.; Npoints = 0.;
          for (k = -NwinM1S2; k < 1 + NwinM1S2; k++)
            for (l = -NwinM1S2; l < 1 +NwinM1S2; l++) {
              if (Mask[Nmax[lig][col]][NwinM1S2 + k][NwinM1S2 + l] == 1) {
                mean += M_in[Np][NwinM1S2+lig+k][NwinM1S2+col+l];
                Npoints = Npoints + 1.;
                }
              }
          mean /= Npoints;
          /* Filtering f(x)=E(x)+k*(x-E(x)) */
          M_out[Np][lig][col] = mean + coeff[lig][col] * (M_in[Np][NwinM1S2+lig][NwinM1S2+col] - mean);
          }
        }
      }
    }

  write_block_matrix3d_float(out_datafile, NpolarOut, M_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0] + NwinL);

  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    free_matrix3d_float(S_in1, NpolarIn, NligBlock[0] + Nwin);
    free_matrix3d_float(S_in2, NpolarIn, NligBlock[0] + Nwin);
    }

  free_matrix3d_float(Mask, 8, Nwin);
  free_matrix_float(span, NligBlock[0] + Nwin);
  free_matrix_float(coeff, NligBlock[0]);
  free_matrix_int(Nmax, NligBlock[0]+Nwin);
  free_matrix3d_float(M_in, NpolarOut, NligBlock[0] + Nwin);
  free_matrix3d_float(M_out, NpolarOut, NligBlock[0]);
*/
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarOut; Np++) fclose(out_datafile[Np]);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile1[Np]);
  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile2[Np]);
    }
    
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


