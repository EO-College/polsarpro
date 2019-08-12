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

File  : height_estimation_inversion_procedure_RVOG.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2012
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

Description :  Height Estimation from Inversion Procedures

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

/* LOCAL VARIABLES */

/* Input/Output file pointer arrays */
  FILE *gamma_high_file, *gamma_low_file, *Kz_file;
  FILE *in_file, *out_file, *out_file_topo, *out_file_Hp, *out_file_Hest;

/* Strings */
  char file_name[FilePathLength], file_kz[FilePathLength], file_gamma_high[FilePathLength], file_gamma_low[FilePathLength];

/* Internal variables */
  int lig, col, k, l, index;
  float coeff,x,y, min;
  float dg_re, dg_im, a, b, c, mu, rat_re, rat_im;

/* Matrix arrays */
  float *M_out;
  float *Gh;
  float *Gl;
  float *Kz;
  float *Gv;
  float **Phi;
  float *Topo;
  float *Hp;
  float *Hcoh;
  float *Hest;
  float *PhiM;
  float *Pvar;
  float *Gref;
  
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nheight_estimation_inversion_procedure_RVOG.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-kz  	input kz file\n");
strcat(UsageHelp," (string)	-ifgh	input file : gamma high\n");
strcat(UsageHelp," (string)	-ifgl	input file : gamma low\n");
strcat(UsageHelp," (float) 	-coef	coefficient\n");
strcat(UsageHelp," (int)   	-nc  	Number of Col\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 27) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-kz",str_cmd_prm,file_kz,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifgh",str_cmd_prm,file_gamma_high,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifgl",str_cmd_prm,file_gamma_low,1,UsageHelp);
  get_commandline_prm(argc,argv,"-coef",flt_cmd_prm,&coeff,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nc",int_cmd_prm,&Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  }

/********************************************************************
********************************************************************/
  
  check_dir(in_dir);
  check_dir(out_dir);
  check_file(file_gamma_high);
  check_file(file_gamma_low);
  check_file(file_kz);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;
  
/********************************************************************
********************************************************************/

/* MATRIX DECLARATION */
  Gh = vector_float(2*Sub_Ncol);
  Gl = vector_float(2*Sub_Ncol);
  Gv = vector_float(Sub_Ncol);
  Kz = vector_float(Sub_Ncol);
  M_out = vector_float(Sub_Ncol);
  Phi = matrix_float(NwinL, Sub_Ncol + NwinC);
  PhiM = vector_float(NwinL * NwinC);
  Topo = vector_float(2 * Sub_Ncol);
  Hp = vector_float(Sub_Ncol);
  Hcoh = vector_float(Sub_Ncol);
  Hest = vector_float(Sub_Ncol);
  Pvar = vector_float(1001);
  Gref = vector_float(1001);

/*******************************************************************/
/*******************************************************************/

/* INPUT/OUTPUT FILE OPENING*/
  sprintf(file_name, "%s", file_gamma_high);
  if ((gamma_high_file = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s", file_gamma_low);
  if ((gamma_low_file = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s", file_kz);
  if ((Kz_file = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name);

/*******************************************************************/
/*******************************************************************/
/* GROUND PHASE ESTIMATION */
  sprintf(file_name, "%s%s", out_dir, "Ground_phase.bin");
  if ((out_file = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  rewind(gamma_high_file);
  rewind(gamma_low_file);
  rewind(Kz_file);
  
/* OFFSET LINES READING */
  for (lig = 0; lig < Off_lig; lig++)
  {  
  fread(&Gh[0], sizeof(float), 2*Ncol, gamma_high_file);
  fread(&Gl[0], sizeof(float), 2*Ncol, gamma_low_file);
  fread(&Kz[0], sizeof(float), Ncol, Kz_file);
  }

/* FILES READING */
  for (lig = 0; lig < Sub_Nlig; lig++) {
    PrintfLine(lig,Sub_Nlig);  
    fread(&Gh[0], sizeof(float), 2*Ncol, gamma_high_file);
    fread(&Gl[0], sizeof(float), 2*Ncol, gamma_low_file);
    fread(&Kz[0], sizeof(float), Ncol, Kz_file);
    for (col = 0; col < Sub_Ncol; col++) {
      Gh[2*col] = Gh[2*(col + Off_col)]; Gh[2*col+1] = Gh[2*(col + Off_col)+1];
      Gl[2*col] = Gl[2*(col + Off_col)]; Gl[2*col+1] = Gl[2*(col + Off_col)+1];
      Kz[col] = Kz[col + Off_col];
      }
    for (col = 0; col < Sub_Ncol; col++) {
      dg_re = Gl[2*col] - Gh[2*col];
      dg_im = Gl[2*col+1] - Gh[2*col+1];
      a = Gh[2*col]*Gh[2*col]+Gh[2*col+1]*Gh[2*col+1] - 1.;
      b = 2. * (Gh[2*col]*dg_re+Gh[2*col+1]*dg_im);
      c = dg_re*dg_re + dg_im*dg_im;
      mu = -b -sqrt(b*b-4.*a*c); mu = fabs(mu / (2.*a + eps));
      rat_re = (Gl[2*col] - Gh[2*col]*(1. - mu)) / (mu + eps);
      rat_im = (Gl[2*col+1] - Gh[2*col+1]*(1. - mu)) / (mu + eps);
      M_out[col] = atan2(rat_im, rat_re + eps) * 180. /pi;
      }
    fwrite(&M_out[0], sizeof(float), Sub_Ncol, out_file);
    }
  fclose(out_file);

/*******************************************************************/
/*******************************************************************/
/* GROUND PHASE MEDIAN FILTERED ESTIMATION */
  sprintf(file_name, "%s%s", out_dir, "Ground_phase_median.bin");
  if ((out_file = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "Ground_phase.bin");
  if ((in_file = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name);

/* Set the input matrix to 0 */
  for (lig = 0; lig < NwinL; lig++)
    for (col = 0; col < Sub_Ncol + NwinC; col++) Phi[0][col] = 0.;

/* FIRST (Nwin+1)/2 LINES READING */
  for (lig = NwinLM1S2; lig < NwinL - 1; lig++) {
    for (col = 0; col < Sub_Ncol + NwinC; col++) Phi[lig][col] = 0.;
    fread(&Phi[lig][NwinCM1S2], sizeof(float), Sub_Ncol, in_file);
    }

  for (lig = 0; lig < Sub_Nlig; lig++) {
    PrintfLine(lig,Sub_Nlig);  

/* 1 line reading with zero padding */
  if (lig < Sub_Nlig - NwinLM1S2) {
    for (col = 0; col < Sub_Ncol + NwinC; col++)  Phi[NwinL - 1][col] = 0.;
    fread(&Phi[NwinL - 1][NwinCM1S2], sizeof(float), Sub_Ncol, in_file);
    } else {
    for (col = 0; col < Sub_Ncol + NwinC; col++)  Phi[NwinL - 1][col] = 0.;
    }

  for (col = 0; col < Sub_Ncol; col++) {
    M_out[col] = 0.;
/* (Nwin*Nwin) window calculation */
    for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++)
      for (l = -NwinCM1S2; l < 1 + NwinCM1S2; l++) {
        PhiM[(k + NwinLM1S2) * NwinC + (l + NwinCM1S2)] = Phi[NwinLM1S2 + k][NwinCM1S2 + col + l];
        if ((lig+k<0)||(lig+k>Sub_Nlig-1)||(col+l<0)||(col+l>Sub_Ncol-1)) PhiM[(k + NwinLM1S2) * NwinC + (l + NwinCM1S2)] = 0.f/0.f;
        }
    M_out[col] = MedianArray(PhiM, NwinL*NwinC);
    }    /*col */

  fwrite(&M_out[0], sizeof(float), Sub_Ncol, out_file);

/* Line-wise shift */
  for (l = 0; l < (NwinL - 1); l++)
    for (col = 0; col < Sub_Ncol; col++)
      Phi[l][NwinCM1S2 + col] = Phi[l + 1][NwinCM1S2 + col];
  }    /*lig */
  fclose(in_file);
  fclose(out_file);

/*******************************************************************/
/*******************************************************************/
/* GROUND PHASE ESTIMATION */
  sprintf(file_name, "%s%s", out_dir, "Topographic_phase.bin");
  if ((out_file_topo = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "RVOG_phase_heights.bin");
  if ((out_file_Hp = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "RVOG_heights.bin");
  if ((out_file_Hest = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "Ground_phase_median.bin");
  if ((in_file = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  rewind(gamma_high_file);
  rewind(gamma_low_file);
  rewind(Kz_file);

  for (k = 1; k < 1001; k++) {
    x = (float)k/1000.;
    Gref[k] = sin(pi*x) / (pi*x);
    Pvar[k] = x;
    }
  Pvar[0] = 0.; Gref[0] = 1.;

/* OFFSET LINES READING */
  for (lig = 0; lig < Off_lig; lig++)
  {  
  fread(&Gh[0], sizeof(float), 2*Ncol, gamma_high_file);
  fread(&Gl[0], sizeof(float), 2*Ncol, gamma_low_file);
  fread(&Kz[0], sizeof(float), Ncol, Kz_file);
  }

/* FILES READING */
  for (lig = 0; lig < Sub_Nlig; lig++) {
    PrintfLine(lig,Sub_Nlig);  
    fread(&Gh[0], sizeof(float), 2*Ncol, gamma_high_file);
    fread(&Gl[0], sizeof(float), 2*Ncol, gamma_low_file);
    fread(&Kz[0], sizeof(float), Ncol, Kz_file);
    fread(&Phi[0][0], sizeof(float), Sub_Ncol, in_file);
    for (col = 0; col < Sub_Ncol; col++) {
      Gh[2*col] = Gh[2*(col + Off_col)]; Gh[2*col+1] = Gh[2*(col + Off_col)+1];
      Gl[2*col] = Gl[2*(col + Off_col)]; Gl[2*col+1] = Gl[2*(col + Off_col)+1];
      Kz[col] = Kz[col + Off_col];
      }
    for (col = 0; col < Sub_Ncol; col++)
      Gv[col] = sqrt(Gh[2*col]*Gh[2*col]+Gh[2*col+1]*Gh[2*col+1]);
    for (col = 0; col < Sub_Ncol; col++) {
      Topo[2*col]  = cos(Phi[0][col] * pi / 180.);
      Topo[2*col+1] = sin(Phi[0][col] * pi / 180.);
      index = 0; min = fabs(Gref[0]-Gv[col]);
      for (k = 0; k < 1001; k++) {
        if(min > fabs(Gref[k]-Gv[col])) {
          min = fabs(Gref[k]-Gv[col]);
          index = k;
          }
        }
      Hcoh[col] = Pvar[index] * 2. * pi / (Kz[col] + eps);
      x = Gh[2*col]*Topo[2*col]+Gh[2*col+1]*Topo[2*col+1];
      y = -Gh[2*col]*Topo[2*col+1]+Gh[2*col+1]*Topo[2*col];
      Hp[col] = atan2(y,x) / (Kz[col] + eps);
      Hest[col] = Hp[col] + Hcoh[col] * coeff;
      }
    fwrite(&Topo[0], sizeof(float), Sub_Ncol, out_file_topo);
    fwrite(&Hp[0], sizeof(float), Sub_Ncol, out_file_Hp);
    fwrite(&Hest[0], sizeof(float), Sub_Ncol, out_file_Hest);
    }
  fclose(out_file_topo);
  fclose(out_file_Hp);
  fclose(out_file_Hest);

  fclose(gamma_high_file);
  fclose(gamma_low_file);
  fclose(Kz_file);
  fclose(in_file);

return 1;
}


