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

File  : surface_inversion_dubois.c
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

Description :  Surface Parameter Data Inversion : Dubois Procedure

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
void dubois(float **valid,float **theta,float F,int Nlig,int Ncol,float **Shhhh,float **Svvvv,float **Shvhv,float **er_dub,float **mv_dub,float **ks_dub,float **msk_out,float **msk_valid,int Calib_Flag, float Coeff_Calib, float thres1, float thres2);

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{

#define NPolType 5
/* LOCAL VARIABLES */
  FILE *in_file_angle;
  FILE *out_er, *out_mv, *out_ks, *out_maskout, *out_maskin, *out_maskinout;
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C3", "C4", "T3", "T4"};
  char file_name[FilePathLength], anglefile[FilePathLength];
  
/* Internal variables */
  int ii, lig, col;
  int ligDone = 0;
  int Calib_Flag, Unit;
  float Coeff_Calib, Freq;
  float threshold1,threshold2;

/* Matrix arrays */
  float ***M_in;
  float **M_avg;

  float **Shhhh;
  float **Shvhv;
  float **Svvvv;
  float **er;
  float **ks;
  float **mv;
  float **mask_in;
  float **mask_out;
  float **mask_in_out;
  float **angle;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nsurface_inversion_dubois.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (string)	-ang 	incidence angle file\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (float) 	-fr  	Central Frequency (GHz)\n");
strcat(UsageHelp," (int)   	-un  	Angle Unit (0: deg, 1: rad)\n");
strcat(UsageHelp," (int)   	-caf 	Calibration Flag\n");
strcat(UsageHelp," (float) 	-cac 	Calibration Coefficient\n");
strcat(UsageHelp," (float) 	-th1 	Threshold - HHHH/VVVV\n");
strcat(UsageHelp," (float) 	-th2 	Threshold - HVHV/VVVV\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
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

if(argc < 29) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ang",str_cmd_prm,anglefile,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fr",flt_cmd_prm,&Freq,1,UsageHelp);
  get_commandline_prm(argc,argv,"-un",int_cmd_prm,&Unit,1,UsageHelp);
  get_commandline_prm(argc,argv,"-caf",int_cmd_prm,&Calib_Flag,1,UsageHelp);
  get_commandline_prm(argc,argv,"-cac",flt_cmd_prm,&Coeff_Calib,1,UsageHelp);
  get_commandline_prm(argc,argv,"-th1",flt_cmd_prm,&threshold1,1,UsageHelp);
  get_commandline_prm(argc,argv,"-th2",flt_cmd_prm,&threshold2,1,UsageHelp);

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

  if (strcmp(PolType,"S2")==0) strcpy(PolType,"S2C3");

/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);
  check_file(anglefile);

  NwinL = 1; NwinC = 1;
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

  if ((in_file_angle = fopen(anglefile, "rb")) == NULL)
  edit_error("Could not open input file : ", anglefile);

/* OUTPUT FILE OPENING*/
  sprintf(file_name, "%s%s", out_dir, "dubois_er.bin");
  if ((out_er = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "dubois_mv.bin");
  if ((out_mv = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "dubois_ks.bin");
  if ((out_ks = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "dubois_mask_out.bin");
  if ((out_maskout = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "dubois_mask_in.bin");
  if ((out_maskin = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "dubois_mask_valid_in_out.bin");
  if ((out_maskinout = fopen(file_name, "wb")) == NULL)
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
  NBlockA += Sub_Ncol+NwinC; NBlockB += NwinL*(Sub_Ncol+NwinC);

  /* angle = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* shhhh = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* shvhv = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* svvvv = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* er = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* mv = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* ks = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* maskin = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* maskout = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* maskinout = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Min = NpolarOut*Nlig*Sub_Ncol */
  NBlockA += NpolarOut*(Ncol+NwinC); NBlockB += NpolarOut*NwinL*(Ncol+NwinC);
  /* Mavg = NpolarOut */
  NBlockA += 0; NBlockB += NpolarOut*Sub_Ncol;
  
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

  M_in = matrix3d_float(NpolarOut, NligBlock[0] + NwinL, Ncol + NwinC);
  //M_avg = matrix_float(NpolarOut, Sub_Ncol);
  angle = matrix_float(NligBlock[0], Sub_Ncol);
  Shhhh = matrix_float(NligBlock[0], Sub_Ncol);
  Shvhv = matrix_float(NligBlock[0], Sub_Ncol);
  Svvvv = matrix_float(NligBlock[0], Sub_Ncol);
  er = matrix_float(NligBlock[0], Sub_Ncol);
  mv = matrix_float(NligBlock[0], Sub_Ncol);
  ks = matrix_float(NligBlock[0], Sub_Ncol);
  mask_in = matrix_float(NligBlock[0], Sub_Ncol);
  mask_out = matrix_float(NligBlock[0], Sub_Ncol);
  mask_in_out = matrix_float(NligBlock[0], Sub_Ncol);

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
/* DATA PROCESSING */
for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}
 
  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
    read_block_S2_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
  /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }
  if (strcmp(PolTypeOut,"T3")==0) T3_to_C3(M_in, NligBlock[Nb], Sub_Ncol + NwinC, 0, 0);
  if (strcmp(PolTypeOut,"T4")==0) T4_to_C3(M_in, NligBlock[Nb], Sub_Ncol + NwinC, 0, 0);
  if (strcmp(PolTypeOut,"C4")==0) C4_to_C3(M_in, NligBlock[Nb], Sub_Ncol + NwinC, 0, 0);

  read_block_matrix_float(in_file_angle, angle, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

#pragma omp parallel for private(col, M_avg) shared(ligDone)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        Shhhh[lig][col] = M_avg[C311][col];
        Shvhv[lig][col] = M_avg[C322][col]/2.;
        Svvvv[lig][col] = M_avg[C333][col];
        if (Unit == 0) angle[lig][col]=angle[lig][col]*pi/180;
        } else {
        Shhhh[lig][col] = 0.;
        Shvhv[lig][col] = 0.;
        Svvvv[lig][col] = 0.;
        }
      }
    free_matrix_float(M_avg,NpolarOut);
    }

  dubois(Valid,angle,Freq,NligBlock[Nb],Sub_Ncol,Shhhh,Svvvv,Shvhv,er,mv,ks,mask_out,mask_in,Calib_Flag,Coeff_Calib,threshold1,threshold2);

  write_block_matrix_float(out_er, er, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_mv, mv, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_ks, ks, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_maskin, mask_in, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_maskout, mask_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  for (lig = 0; lig < NligBlock[Nb]; lig++) 
    for (col = 0; col < Sub_Ncol; col++) 
      mask_in_out[lig][col] = mask_in[lig][col] * mask_out[lig][col] * Valid[lig][col];
  write_block_matrix_float(out_maskinout, mask_in_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  
  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_avg, NpolarOut, NligBlock[0]);
  free_matrix_float(angle, NligBlock[0]);
  free_matrix_float(Shhhh, NligBlock[0]);
  free_matrix_float(Shvhv, NligBlock[0]);
  free_matrix_float(Svvvv, NligBlock[0]);
  free_matrix_float(er, NligBlock[0]);
  free_matrix_float(mv, NligBlock[0]);
  free_matrix_float(ks, NligBlock[0]);
  free_matrix_float(mask_in, NligBlock[0]);
  free_matrix_float(mask_out, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  fclose(out_er); fclose(out_mv); fclose(out_ks);
  fclose(out_maskin); fclose(out_maskout); fclose(in_file_angle);
  fclose(out_maskinout);
  
/********************************************************************
********************************************************************/

  return 1;
}


/*******************************************************************************
*******************************************************************************/

void dubois(float **valid,float **theta,float F,int Nlig,int Ncol,float **Shhhh,float **Svvvv,float **Shvhv,float **er_dub,float **mv_dub,float **ks_dub,float **msk_out,float **msk_valid,int Calib_Flag, float Coeff_Calib, float thres1, float thres2)

/* Modele d'inversion de Dubois
% theta  : angle incidence radar en radians
% F  : frequence emission en GHz
% Shhhh  : coeff retrodiff HH 
% Svvvv  : coeff retrodiff VV 
% epsilon : constante dielectrique
% s  : hauteur de la surface en m
% theta>30---1.5GHz<F<11GHz*/

{
 int ii, jj; 
 float lambda,er_inv,ks_inv,mv_inv;
 int msk_mv,msk_er,msk_ks; 
 int ligDone = 0;
 
if (Calib_Flag == 1) {
  for(ii=0;ii<Nlig;ii++) {  
  for(jj=0;jj<Ncol;jj++) {  
    Shhhh[ii][jj] = Shhhh[ii][jj]*sin(theta[ii][jj])/Coeff_Calib;
    Svvvv[ii][jj] = Svvvv[ii][jj]*sin(theta[ii][jj])/Coeff_Calib;
    Shvhv[ii][jj] = Shvhv[ii][jj]*sin(theta[ii][jj])/Coeff_Calib;
    }
  }
  }

lambda= 100*0.3/F;
er_inv = ks_inv = mv_inv = 0.;
msk_mv = msk_er = msk_ks = 0; 
#pragma omp parallel for private(jj) firstprivate(er_inv,ks_inv,mv_inv,msk_mv,msk_er,msk_ks) shared(ligDone)
for(ii=0;ii<Nlig;ii++) {  
  ligDone++;
  if (omp_get_thread_num() == 0) PrintfLine(ligDone,Nlig);
  for(jj=0;jj<Ncol;jj++) {
    if (valid[ii][jj] == 1.) {  
      if (((Shvhv[ii][jj]/Svvvv[ii][jj])<pow(10.,thres1/10.))&&((Shhhh[ii][jj]/Svvvv[ii][jj])<pow(10.,thres2/10.))) {
        msk_valid[ii][jj] = 1;
        ks_inv =exp(1.36905*log(Shhhh[ii][jj])-0.83333*log(Svvvv[ii][jj])+
        0.446425*log(cos(theta[ii][jj]))+3.34525*log(sin(theta[ii][jj]))-0.375*log(lambda)+1.78989*log(10));
    
//        if ((ks_inv<0)||(ks_inv>(2*M_PI/3))) msk_ks = 0;
        if ((ks_inv<0)||(ks_inv>pi)) msk_ks = 0;
        else  msk_ks = 1;
        ks_dub[ii][jj]=ks_inv*msk_ks*msk_valid[ii][jj];
    
        /* Computation of the dilectric constant*/    
//        er_inv = (log10(Shhhh[ii][jj]*exp(2.75*log(10)+5*log(sin(theta[ii][jj]))-1.5*log(cos(theta[ii][jj]))-1.4*log(ks_dub[ii][jj]*sin(theta[ii][jj])+eps)-0.7*log(lambda))+eps))/(0.028*tan(theta[ii][jj])+eps);
        er_inv = (log10(Shhhh[ii][jj])+log10(Svvvv[ii][jj]) + 5.12 - 4.5*log10(cos(theta[ii][jj])) + 5.5*log10(cos(theta[ii][jj])) - 2.5*log10(ks_dub[ii][jj]+eps) - 1.4*log10(lambda)) / (0.074*tan(theta[ii][jj])+eps);
    
//        if ((er_inv>20)||(er_inv<0)) msk_er = 0;
        if ((er_inv>100)||(er_inv<0)) msk_er = 0;
        else msk_er = 1;
        er_dub[ii][jj]=er_inv*msk_er*msk_valid[ii][jj];
  
        /* Computation of the moisture content*/
        mv_inv =(-5.3e-2+2.92e-2*er_dub[ii][jj]-5.5e-4*exp(2*log(er_dub[ii][jj]))+4.3e-6*exp(3*log(er_dub[ii][jj])))*100;
//        if (mv_inv<0) msk_mv = 0;
        if ((mv_inv>100)||(mv_inv<0)) msk_mv = 0;
        else msk_mv = 1;
        mv_dub[ii][jj] = mv_inv*msk_mv;
        msk_out[ii][jj] = msk_mv*msk_er*msk_ks;
        } else {
        msk_valid[ii][jj] = 0;
        ks_dub[ii][jj] = 0;
        er_dub[ii][jj] = 0;
        mv_dub[ii][jj] = 0;
        msk_out[ii][jj] = 0;
        }
      } else {
      msk_valid[ii][jj] = 0;
      ks_dub[ii][jj] = 0;
      er_dub[ii][jj] = 0;
      mv_dub[ii][jj] = 0;
      msk_out[ii][jj] = 0;
      }
    }
  }
}



