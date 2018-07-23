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

File  : RCSmax.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2011
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

Description :  Sampling of full polar coherency matrices from an image using
user defined pixel coordinates, then apply the RCSmax (Xpoll)
on each pixel
* 
********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

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

#define NPolType 3
/* LOCAL VARIABLES */
  FILE *fphi, *ftau, *frcs;
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C3", "T3"};
  char file_name[FilePathLength];
  
/* Internal variables */
  int ii, lig, col;

  float m_a0pb0, m_a0pb, m_a0mb, m_ma0pb0;
  float m_c, m_d, m_e, m_f, m_g, m_h;

  float graves[2][2][2];
  float aa, bb, ro_r, ro_i;
  float l1, l2, traceG, detG;
  float phi1, phi2, tau1, tau2;
  float g[3], gn[3], grdt[3], step, diff, norme, pow1, pow2;

/* Matrix arrays */
  float ***M_avg;
  float **M_phi;
  float **M_tau;
  float **M_rcs;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nRCSmax.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
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
for (ii=0; ii<NPolType; ii++) CreateUsageHelpDataFormatInput(PolTypeConf[ii]); 
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
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);
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

  if (strcmp(PolType,"S2")==0) strcpy(PolType,"S2T3");

/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);

  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);
  
/* POLAR TYPE CONFIGURATION */
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);
  
  file_name_in = matrix_char(NpolarIn,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir, file_name_in);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
  if ((in_datafile[Np] = fopen(file_name_in[Np], "rb")) == NULL)
    edit_error("Could not open input file : ", file_name_in[Np]);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  sprintf(file_name, "%s%s", out_dir, "RCSmax_phi.bin");
  if ((fphi = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "RCSmax_tau.bin");
  if ((ftau = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "RCSmax.bin");
  if ((frcs = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  
/********************************************************************
********************************************************************/
/* MEMORY ALLOCATION */
/*
MemAlloc = NBlockA*Nlig + NBlockB
*/ 

/* Local Variables */
  NBlockA = 0; NBlockB = 0;
  /* Mask */ 
  NBlockA += Sub_Ncol; NBlockB += 0;

  /* Mphi = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mtau = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mrcs = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mavg = NpolarOut*Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
  
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

  Valid = matrix_float(NligBlock[0], Sub_Ncol);

  M_avg = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);
  M_phi = matrix_float(NligBlock[0], Sub_Ncol);
  M_tau = matrix_float(NligBlock[0], Sub_Ncol);
  M_rcs = matrix_float(NligBlock[0], Sub_Ncol);

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
    for (lig = 0; lig < NligBlock[0]; lig++) 
      for (col = 0; col < Sub_Ncol; col++) 
        Valid[lig][col] = 1.;
 
/********************************************************************
********************************************************************/
/* DATA PROCESSING */
for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
if (FlagValid == 1) rewind(in_valid);

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
  read_block_S2_avg(in_datafile, M_avg, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
  } else {
  /* Case of C,T or I */
  read_block_TCI_avg(in_datafile, M_avg, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
  }
  if (strcmp(PolTypeOut,"C3")==0) C3_to_T3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      M_phi[lig][col] = 0.;
      M_tau[lig][col] = 0.;
      M_rcs[lig][col] = 0.;
      if (Valid[lig][col] == 1.) {
        m_a0pb0 = 0.5 * (M_avg[T311][lig][col] + M_avg[T322][lig][col] + M_avg[T333][lig][col]);
        m_c = M_avg[T312_re][lig][col];
        m_h = M_avg[T313_re][lig][col];
        m_f = M_avg[T323_im][lig][col];
        m_a0pb = 0.5 * (M_avg[T311][lig][col] + M_avg[T322][lig][col] - M_avg[T333][lig][col]);
        m_e = M_avg[T323_re][lig][col];
        m_g = M_avg[T313_im][lig][col];
        m_a0mb = 0.5 * (M_avg[T311][lig][col] - M_avg[T322][lig][col] + M_avg[T333][lig][col]);
        m_d = -M_avg[T312_im][lig][col];
        m_ma0pb0 = 0.5 * (-M_avg[T311][lig][col] + M_avg[T322][lig][col] + M_avg[T333][lig][col]);

        if (m_a0pb0 > eps) {

          /* PSEUDO GRAVES MATRIX DETERMINATION */
          graves[0][0][0] = m_a0pb0 + m_c;
          graves[0][0][1] = 0.;
          graves[1][1][0] = m_a0pb0 - m_c;
          graves[1][1][1] = 0.;
          graves[0][1][0] = m_h;
          graves[0][1][1] = -m_f;
          graves[1][0][0] = m_h;
          graves[1][0][1] = m_f;

          traceG = eps + graves[0][0][0] + graves[1][1][0];
          detG = eps + graves[0][0][0] * graves[1][1][0] - graves[1][0][0] * graves[1][0][0] - graves[1][0][1] * graves[1][0][1];

          /*Maximum Graves Eigenvalue */
          l1 = fabs(traceG + sqrt(eps + fabs(traceG * traceG - 4. * detG))) / 2.;

          /*Associated Polarisation Ratio */
          aa = graves[0][1][0];
          bb = graves[0][1][1];
          ro_r = aa * (l1 - graves[0][0][0]) / (aa * aa + bb * bb);
          ro_i = -bb * (l1 - graves[0][0][0]) / (aa * aa + bb * bb);

          /*Associated Xpoll Stokes Vector which will be used for the initialisation*/
          g[0] = (1 - (ro_r * ro_r + ro_i * ro_i)) / (1 + (ro_r * ro_r + ro_i * ro_i));
          g[1] = 2 * ro_r / (1 + (ro_r * ro_r + ro_i * ro_i));
          g[2] = 2 * ro_i / (1 + (ro_r * ro_r + ro_i * ro_i));

          /* Polarisation Signature 1st Maximum Research : D. Schuler Method */
          step = 20. / m_a0pb0;
          diff = 1.;
          while (diff > 0.0001) {
            grdt[0] = 2. * (m_c + m_a0pb * g[0] + m_e * g[1] + m_g * g[2]);
            grdt[1] = 2. * (m_h + m_e * g[0] + m_a0mb * g[1] + m_d * g[2]);
            grdt[2] = 2. * (m_f + m_g * g[0] + m_d * g[1] + m_ma0pb0 * g[2]);
            gn[0] = g[0] + step * grdt[0];
            gn[1] = g[1] + step * grdt[1];
            gn[2] = g[2] + step * grdt[2];
            norme = sqrt(gn[0] * gn[0] + gn[1] * gn[1] + gn[2] * gn[2]);
            gn[0] = gn[0] / norme;
            gn[1] = gn[1] / norme;
            gn[2] = gn[2] / norme;
            diff = sqrt((gn[0] - g[0]) * (gn[0] - g[0]) + (gn[1] - g[1]) * (gn[1] - g[1]) + (gn[2] - g[2]) * (gn[2] - g[2]));
            g[0] = gn[0];
            g[1] = gn[1];
            g[2] = gn[2];
            }
          phi1 = 0.5 * atan2(g[1], g[0]);
          tau1 = 0.5 * asin(g[2]);
          pow1 = m_a0pb0 + 2. * (m_c * g[0] + m_h * g[1] + m_f * g[2]);
          pow1 = pow1 + g[0] * (m_a0pb * g[0] + m_e * g[1] + m_g * g[2]);
          pow1 = pow1 + g[1] * (m_e * g[0] + m_a0mb * g[1] + m_d * g[2]);
          pow1 = pow1 + g[2] * (m_g * g[0] + m_d * g[1] + m_ma0pb0 * g[2]);
          pow1 = pow1 / 2.;

          /*Minimum Graves Eigenvalue */
          l2 = fabs(traceG - sqrt(eps + fabs(traceG * traceG - 4. * detG))) / 2.;

          /*Associated Polarisation Ratio */
          aa = graves[0][1][0];
          bb = graves[0][1][1];
          ro_r = aa * (l2 - graves[0][0][0]) / (aa * aa + bb * bb);
          ro_i = -bb * (l2 - graves[0][0][0]) / (aa * aa + bb * bb);

          /*Associated Xpoll Stokes Vector which will be used for the initialisation*/
          g[0] = (1 - (ro_r * ro_r + ro_i * ro_i)) / (1 + (ro_r * ro_r + ro_i * ro_i));
          g[1] = 2 * ro_r / (1 + (ro_r * ro_r + ro_i * ro_i));
          g[2] = 2 * ro_i / (1 + (ro_r * ro_r + ro_i * ro_i));

          /* Polarisation Signature 1st Maximum Research : D. Schuler Method */
          step = 20. / m_a0pb0;
          diff = 1.;
          while (diff > 0.0001) {
            grdt[0] = 2. * (m_c + m_a0pb * g[0] + m_e * g[1] + m_g * g[2]);
            grdt[1] = 2. * (m_h + m_e * g[0] + m_a0mb * g[1] + m_d * g[2]);
            grdt[2] = 2. * (m_f + m_g * g[0] + m_d * g[1] + m_ma0pb0 * g[2]);
            gn[0] = g[0] + step * grdt[0];
            gn[1] = g[1] + step * grdt[1];
            gn[2] = g[2] + step * grdt[2];
            norme = sqrt(gn[0] * gn[0] + gn[1] * gn[1] + gn[2] * gn[2]);
            gn[0] = gn[0] / norme;
            gn[1] = gn[1] / norme;
            gn[2] = gn[2] / norme;
            diff = sqrt((gn[0] - g[0]) * (gn[0] - g[0]) + (gn[1] - g[1]) * (gn[1] - g[1]) + (gn[2] - g[2]) * (gn[2] - g[2]));
            g[0] = gn[0];
            g[1] = gn[1];
            g[2] = gn[2];
            }
          phi2 = 0.5 * atan2(g[1], g[0]);
          tau2 = 0.5 * asin(g[2]);
          pow2 = m_a0pb0 + 2. * (m_c * g[0] + m_h * g[1] + m_f * g[2]);
          pow2 = pow2 + g[0] * (m_a0pb * g[0] + m_e * g[1] + m_g * g[2]);
          pow2 = pow2 + g[1] * (m_e * g[0] + m_a0mb * g[1] + m_d * g[2]);
          pow2 = pow2 + g[2] * (m_g * g[0] + m_d * g[1] + m_ma0pb0 * g[2]);
          pow2 = pow2 / 2.;

          if (pow1 >= pow2) {
            M_phi[lig][col] = phi1 * 180. / pi;
            M_tau[lig][col] = tau1 * 180. / pi;
            M_rcs[lig][col] = pow1;
            }
          if (pow1 < pow2) {
            M_phi[lig][col] = phi2 * 180. / pi;
            M_tau[lig][col] = tau2 * 180. / pi;
            M_rcs[lig][col] = pow2;
            }
          }
        }
      }
    }

  write_block_matrix_float(fphi, M_phi, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(ftau, M_tau, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(frcs, M_rcs, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_avg, NpolarOut, NligBlock[0]);
  free_matrix_float(M_phi, NligBlock[0]);
  free_matrix_float(M_tau, NligBlock[0]);
  free_matrix_float(M_rcs, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  fclose(fphi);
  fclose(ftau);
  fclose(frcs);
  
/********************************************************************
********************************************************************/

  return 1;
}


