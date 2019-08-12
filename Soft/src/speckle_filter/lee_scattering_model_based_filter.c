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

File   : lee_scattering_model_based_filter.c
Project  : ESA_POLSARPRO-SATIM
Authors  : Eric POTTIER, Jacek STRZELCZYK
Version  : 2.0
Creation : 07/2015
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

Description :  J.S. LEE Scattering Model Based speckle filter

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

#define NPolType 4
/* LOCAL VARIABLES */
  FILE *in_file_class;
  int Config;
  char *PolTypeConf[NPolType] = {"S2C3", "S2T3", "C3", "T3"};
  char file_class[FilePathLength], FilterType[10];  
  
/* Internal variables */
  int ii, lig, col, k, l;
  int Nlook, Ncluster;
  float sigma2, Npoints, mean, coeff, Classe;
  float m_span, m_span2, v_span, cv_span;
  int ligDone = 0;

/* Matrix arrays */
  float ***M_in;
  float ***M_out;
  float **Class;
  float **Mask;
  float **span;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nlee_scattering_model_based_filter.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-icf 	input classification file\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (string)	-typ 	speckle filter type : box / mmse\n");
strcat(UsageHelp," (int)   	-nc  	Nunmber of final cluster per scattering type\n");
strcat(UsageHelp," (int)   	-nw  	Nwin Row and Col\n");
strcat(UsageHelp," (int)   	-nlk 	Nlook\n");
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

if(argc < 25) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-icf",str_cmd_prm,file_class,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-typ",str_cmd_prm,FilterType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nc",int_cmd_prm,&Ncluster,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nw",int_cmd_prm,&Nwin,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nlk",int_cmd_prm,&Nlook,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);

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
  check_file(file_class);
  
  NwinM1S2 = (Nwin - 1) / 2;
  NwinL = Nwin; NwinC = Nwin;

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

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

  if ((in_file_class = fopen(file_class, "rb")) == NULL)
    edit_error("Could not open input file : ", file_class);

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
  NBlockA += Sub_Ncol+NwinC; NBlockB += NwinL*(Sub_Ncol+NwinC);
  /* Mout = NpolarOut*Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
  /* Min = NpolarOut*(Nlig+NwinL)*(Ncol+NwinC) */
  NBlockA += NpolarOut*(Ncol+Nwin); NBlockB += NpolarOut*Nwin*(Ncol+Nwin);
  /* Mask = Nwin*Nwin */
  NBlockB += Nwin*Nwin;
  /* span = (Nlig + Nwin)*(Ncol + Nwin) */
  NBlockA += Ncol + Nwin; NBlockB += Nwin*(Ncol + Nwin);

/* Reading Data */
  NBlockB += Ncol + 2*Ncol + NpolarIn*2*Ncol + NpolarOut*NwinL*(Ncol+NwinC);

  memory_alloc(file_memerr, Sub_Nlig, Nwin, &NbBlock, NligBlock, NBlockA, NBlockB, MemoryAlloc);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  _VC_in = vector_float(2*Ncol);
  _VF_in = vector_float(Ncol);
  _MC_in = matrix_float(4,2*Ncol);
  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   

  Valid = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);

  //Mask = matrix_float(Nwin, Nwin);
  Class = matrix_float(NligBlock[0] + Nwin, Ncol + Nwin);
  span = matrix_float(NligBlock[0] + Nwin, Ncol + Nwin);
  M_in = matrix3d_float(NpolarOut, NligBlock[0] + Nwin, Ncol + Nwin);
  M_out = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
#pragma omp parallel for private(col)
    for (lig = 0; lig < NligBlock[0] + NwinL; lig++) 
      for (col = 0; col < Sub_Ncol + NwinC; col++) 
        Valid[lig][col] = 1.;

/********************************************************************
********************************************************************/
/* Speckle variance given by the input data number of looks */
  sigma2 = 1. / (float) Nlook;
  
/********************************************************************
********************************************************************/
/* DATA PROCESSING */

for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (strcmp(PolTypeIn,"S2")==0) {
    read_block_S2_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, Nwin, Nwin, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, Nwin, Nwin, Off_lig, Off_col, Ncol);
    }

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, Nwin, Nwin, Off_lig, Off_col, Ncol);

  read_block_matrix_float(in_file_class, Class, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, Nwin, Nwin, Off_lig, Off_col, Ncol);
  
  /* Span Determination */
  for (lig = 0; lig < NligBlock[Nb]+Nwin; lig++) {
    if (NbBlock <= 2) PrintfLine(lig,NligBlock[Nb]+Nwin);
    for (col = 0; col < Sub_Ncol+Nwin; col++) {
      span[lig][col] = M_in[0][lig][col]+M_in[5][lig][col]+M_in[8][lig][col];
      }
    }
  
  /* Filtering Element per Element */  
#pragma omp parallel for private(col,Np,Classe,Mask,k,l,Npoints,coeff,m_span,m_span2,v_span,cv_span,mean) shared(ligDone) schedule(dynamic)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
	ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    Mask = matrix_float(Nwin, Nwin);
    for (col = 0; col < Sub_Ncol; col++) {
      for (Np = 0; Np < NpolarOut; Np++) M_out[Np][lig][col] = 0.;
      if (Valid[NwinM1S2+lig][NwinM1S2+col] == 1.) {
      
        /* Mask determination */  
        Classe = Class[NwinM1S2+lig][NwinM1S2+col];
        if ((Classe == (float)Ncluster) || (Classe == (float)2.*Ncluster)) {
          /* Case of brightest SB or DB class */
          for (k = 0; k < Nwin; k++) for (l = 0; l < Nwin; l++) Mask[k][l] = 0.;
          Mask[NwinM1S2][NwinM1S2] = 1.;          
          } else {
          Npoints = 0;
          if ((Classe == 1.) || (Classe == 1.+(float)Ncluster) || (Classe == 1.+(float)2.*Ncluster)) {
            /* Case of darkest class */
            for (k = 0; k < Nwin; k++) for (l = 0; l < Nwin; l++) Mask[k][l] = 0.;
            Mask[NwinM1S2][NwinM1S2] = 1.;          
            for (k = -NwinM1S2; k < 1 + NwinM1S2; k++)
              for (l = -NwinM1S2; l < 1 +NwinM1S2; l++) 
                if (Class[NwinM1S2+lig+k][NwinM1S2+col+l] == Classe) {
                  Mask[NwinM1S2 + k][NwinM1S2 + l] = 1.;
                  Npoints++;
                  }
            } else {
            /* General Case */
            for (k = 0; k < Nwin; k++) for (l = 0; l < Nwin; l++) Mask[k][l] = 0.;
            Mask[NwinM1S2][NwinM1S2] = 1.;          
            for (k = -NwinM1S2; k < 1 + NwinM1S2; k++)
              for (l = -NwinM1S2; l < 1 +NwinM1S2; l++) 
                if ((Class[NwinM1S2+lig+k][NwinM1S2+col+l] == Classe-1.) || (Class[NwinM1S2+lig+k][NwinM1S2+col+l] == Classe) || (Class[NwinM1S2+lig+k][NwinM1S2+col+l] == Classe+1.)) {
                  Mask[NwinM1S2 + k][NwinM1S2 + l] = 1.;
                  Npoints++;
                  }
            }
          if (Npoints <= 5) 
            for (k = -1; k <= 1; k++) for (l = -1; l <= 1; l++) Mask[NwinM1S2+k][NwinM1S2+l] = 1.;          
          }

        /* Coeff determination */  
          if (strcmp(FilterType,"box") == 0)
            coeff = 0.;
          else {
            m_span = 0.; m_span2 = 0.; Npoints = 0.;
            for (k = -NwinM1S2; k < 1 + NwinM1S2; k++)
              for (l = -NwinM1S2; l < 1 + NwinM1S2; l++)
                if (Mask[NwinM1S2 + k][NwinM1S2 + l] == 1) {
                  m_span += span[NwinM1S2 + k + lig][NwinM1S2 + l + col];
                  m_span2 += span[NwinM1S2 + k + lig][NwinM1S2 + l + col] * span[NwinM1S2 + k + lig][NwinM1S2 + l + col];
                  Npoints = Npoints + 1.;
                  }
            m_span /= Npoints;
            m_span2 /= Npoints;
            v_span = m_span2 - m_span * m_span;  /* Var(x) = E(x^2)-E(x)^2 */
            cv_span = sqrt(fabs(v_span)) / (eps + m_span);
            coeff = (cv_span * cv_span - sigma2) / (cv_span * cv_span * (1 + sigma2) + eps);
            if (coeff < 0.) coeff = 0.;
            }
          
        /* Averaged Matrix determination */  
        for (Np = 0; Np < NpolarOut; Np++) {
          mean = 0.; Npoints = 0.;
          for (k = -NwinM1S2; k < 1 + NwinM1S2; k++)
            for (l = -NwinM1S2; l < 1 +NwinM1S2; l++) {
              if (Mask[NwinM1S2 + k][NwinM1S2 + l] == 1) {
                mean += M_in[Np][NwinM1S2+lig+k][NwinM1S2+col+l];
                Npoints = Npoints + 1.;
                }
              }
          mean /= Npoints;
          
          /* Filtering f(x)=E(x)+k*(x-E(x)) */
          if (strcmp(FilterType,"box") == 0)
            M_out[Np][lig][col] = mean;
          else
            M_out[Np][lig][col] = mean + coeff * (M_in[Np][NwinM1S2+lig][NwinM1S2+col] - mean);
          }
        }
      }
    free_matrix_float(Mask, Nwin);
    }

  write_block_matrix3d_float(out_datafile, NpolarOut, M_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0] + NwinL);

  free_matrix_float(Mask, Nwin);
  free_matrix_float(span, NligBlock[0] + Nwin);
  free_matrix_float(Class, NligBlock[0] + Nwin);
  free_matrix3d_float(M_in, NpolarOut, NligBlock[0] + Nwin);
  free_matrix3d_float(M_out, NpolarOut, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarOut; Np++) fclose(out_datafile[Np]);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  fclose(in_file_class);
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);

/********************************************************************
********************************************************************/

  return 1;
}
