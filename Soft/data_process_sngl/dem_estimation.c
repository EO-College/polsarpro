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

File  : dem_estimation.c
Project  : ESA_POLSARPRO
Authors  : Yang LI - (Eric POTTIER v2.0)
Version  : 2.0
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

Description :  Polarimetric Orientation Angle Shift Estimation;
    Azimuth and Range Slope Estimation;
    Digital Elevation Map Estimation Using Single-Pass
    POLSAR Data.

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
void orient_circular(float ***MM,int li,int subNcol,float *ori);
void angle_in(float altitu, float r_near, float r_far, float ind_far, int ncol, float *angin);
void orientation2slope(float ***MM, int li, int subNcol, float *ori, float *angin, float *slopea, float *sloper);
void boundcorrection(float **imin, int Nlig_2p, int Ncol_2p);
void laplac(float **imin, int Nlig_2p, int Ncol_2p, float **imout);
void resample(float **imin, int Nlig_2p, int Ncol_2p, float **imout);
void relaxGS(float **imin, float **roun, int Nlig_2p, int Ncol_2p, int v1);
void restriction(float **imin, int Nlig_2p, int Ncol_2p, float **imout);
void prolongation(float **imin, int Nlig_2p, int Ncol_2p, float **imout);
void UMV(float **iheight, float **roun, int v1, int v2, int coarsest_a, int coarsest_r, int Nlig_2p, int Ncol_2p, float **Height);
void UFMG(float **iheight, float **roun, int v1, int v2, int coarsest_a, int coarsest_r, int Nlig_2p, int Ncol_2p, float **height);

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
  FILE *out_orient, *out_slopaz, *out_sloprg, *out_height;
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C3", "C4", "T3", "T4"};
  char file_name[FilePathLength];
  
/* Internal variables */
  int ii, lig, col, i, j;
  int ligg, Nligg;

  int V1, V2, Rr, Rc, Nf;
  int Coarsest_a = 3;
  int Coarsest_r = 3;
  int Sub_Nlig_2p;
  int Sub_Ncol_2p;
  float offset;
  float Altitude, Rmin, Rmax, Indmax, Reso_a, Reso_r, Refp;

/* Matrix arrays */
  float ***M_avg;

  float *Angle_in;
  float *Ori_cir;
  float *Slope_a;
  float *Slope_r;
  float *Slope_a_tmp;
//  float *Slope_r_tmp;
  float **Height;
  float **Iheight;
  float **RouN;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ndem_estimation.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (float) 	-alt 	Altitude\n");
strcat(UsageHelp," (float) 	-rmin	Rmin\n");
strcat(UsageHelp," (float) 	-rmax	Rmax\n");
strcat(UsageHelp," (float) 	-imax	Ind Max\n");
strcat(UsageHelp," (float) 	-resa	Resol azimuth\n");
strcat(UsageHelp," (float) 	-resr	Resol range\n");
strcat(UsageHelp," (float) 	-refp	Refp\n");
strcat(UsageHelp," (int)   	-v1  	V1\n");
strcat(UsageHelp," (int)   	-v2  	V2\n");
strcat(UsageHelp," (int)   	-rr  	Rr\n");
strcat(UsageHelp," (int)   	-rc  	Rc\n");
strcat(UsageHelp," (int)   	-nf  	Nf\n");
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

if(argc < 39) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-alt",flt_cmd_prm,&Altitude,1,UsageHelp);
  get_commandline_prm(argc,argv,"-rmin",flt_cmd_prm,&Rmin,1,UsageHelp);
  get_commandline_prm(argc,argv,"-rmax",flt_cmd_prm,&Rmax,1,UsageHelp);
  get_commandline_prm(argc,argv,"-imax",flt_cmd_prm,&Indmax,1,UsageHelp);
  get_commandline_prm(argc,argv,"-resa",flt_cmd_prm,&Reso_a,1,UsageHelp);
  get_commandline_prm(argc,argv,"-resr",flt_cmd_prm,&Reso_r,1,UsageHelp);
  get_commandline_prm(argc,argv,"-refp",flt_cmd_prm,&Refp,1,UsageHelp);
  get_commandline_prm(argc,argv,"-v1",int_cmd_prm,&V1,1,UsageHelp);
  get_commandline_prm(argc,argv,"-v2",int_cmd_prm,&V2,1,UsageHelp);
  get_commandline_prm(argc,argv,"-rr",int_cmd_prm,&Rr,1,UsageHelp);
  get_commandline_prm(argc,argv,"-rc",int_cmd_prm,&Rc,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nf",int_cmd_prm,&Nf,1,UsageHelp);

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

/* OUTPUT FILE OPENING*/
  sprintf(file_name, "%s%s", out_dir, "orientation_cir.bin");
  if ((out_orient = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "slope_az.bin");
  if ((out_slopaz = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "slope_rg.bin");
  if ((out_sloprg = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "height.bin");
  if ((out_height = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open input file : ", file_name);

/********************************************************************
********************************************************************/
/* MEMORY ALLOCATION */
/*
MemAlloc = NBlockA*Nlig + NBlockB
*/ 
  Sub_Nlig_2p = (int) (pow(2,ceil(log(Sub_Nlig)/log(2))));
  Sub_Ncol_2p = (int) (pow(2,ceil(log(Sub_Nlig)/log(2))));

/* Local Variables */
  NBlockA = 0; NBlockB = 0;
  /* Mask */ 
  NBlockA += Sub_Ncol; NBlockB += 0;

  /* Height = Nlig2p*Sub_Ncol */
  NBlockA += 0; NBlockB += Sub_Nlig_2p*Sub_Ncol_2p;
  /* Iheight = Nlig2p*Sub_Ncol */
  NBlockA += 0; NBlockB += Sub_Nlig_2p*Sub_Ncol_2p;
  /* RouN = Nlig2p*Sub_Ncol2p */
  NBlockA += 0; NBlockB += Sub_Nlig_2p*Sub_Ncol_2p;
  
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

  Ori_cir = vector_float(Ncol);
  Angle_in = vector_float(Ncol);
  Slope_a = vector_float(Ncol);
  Slope_r = vector_float(Ncol);
  Slope_a_tmp = vector_float(Ncol);
//  Slope_r_tmp = vector_float(Ncol);

  Height = matrix_float(Sub_Nlig_2p, Sub_Ncol_2p);
  Iheight = matrix_float(Sub_Nlig_2p, Sub_Ncol_2p);
  RouN = matrix_float(Sub_Nlig_2p, Sub_Ncol_2p);

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

/* INCIDENCE ANGLE COMPUTATION */
angle_in(Altitude, Rmin, Rmax, Indmax, Ncol, Angle_in);

for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
if (FlagValid == 1) rewind(in_valid);

ligg = 0; Nligg = 0;
for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
    read_block_S2_avg(in_datafile, M_avg, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_avg(in_datafile, M_avg, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }
  if (strcmp(PolTypeIn,"C3")==0) C3_to_T3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);
  if (strcmp(PolTypeIn,"T4")==0) T4_to_T3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);
  if (strcmp(PolTypeIn,"C4")==0) C4_to_T3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);

  if (ligg == 0) {
    orient_circular(M_avg, 0, Sub_Ncol, Ori_cir);
    fwrite(&Ori_cir[0], sizeof(float), Sub_Ncol, out_orient);
    orientation2slope(M_avg, 0, Sub_Ncol, Ori_cir, Angle_in, Slope_a_tmp, Slope_r);
    }

/* INITIAL POISSON EQUATION SOURCE MATRIX */
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    ligg = lig + Nligg;
    if ((ligg !=0)&&(lig != 0)) {
      /* POLARIMETRIC ORIENTATION ANGLE SHIFT ESTIMATION USING CIRCULAR POLARIZATION METHOD (CPM) */
      orient_circular(M_avg, lig, Sub_Ncol, Ori_cir);
      fwrite(&Ori_cir[0], sizeof(float), Sub_Ncol, out_orient);

      /* AZIMUTH AND RANGE SLOPE ESTIMATION USING COMPENSATION-LAMBERTIAN METHOD */
      orientation2slope(M_avg, lig, Sub_Ncol, Ori_cir, Angle_in, Slope_a, Slope_r);
    
      for (col = 1; col < Sub_Ncol; col++) {
        if (Valid[lig][col] == 1.) {
          RouN[ligg][col]=(float) (Reso_a*(tan(Slope_a[col]*pi/180)-tan(Slope_a_tmp[col]*pi/180))+Reso_r*(tan(Slope_r[col]*pi/180)-tan(Slope_r[col-1]*pi/180)));
          } else {
          RouN[ligg][col]=0.;
          }
        }
      for (col = 0; col < Sub_Ncol; col++) Slope_a_tmp[col] = Slope_a[col];
      }
    }
  Nligg += NligBlock[Nb];
  } // NbBlock

/* SOURCE MATRIX BOUND CORRECTION */
  boundcorrection(RouN, Sub_Nlig_2p, Sub_Ncol_2p);

/* POISSON EQUATION SOLVING USING UNWEIGHTED FULL MULTI-GRID ALGORITHM Nf TIMES */
  UFMG(Iheight, RouN, V1, V2, Coarsest_a, Coarsest_r, Sub_Nlig_2p, Sub_Ncol_2p, Height);

  for (i=0; i<(Nf-1); i++){
    for (lig = 0; lig < Sub_Nlig; lig++) {
      PrintfLine(lig,Sub_Nlig);
      for (col = 0; col < Sub_Ncol; col++) {
        if (Valid[lig][col] == 1.) {
          Iheight[lig][col] = Height[lig][col];
          } else {
          Iheight[lig][col] = 0.;
          }
        }
      }
    UFMG(Iheight, RouN, V1, V2, Coarsest_a, Coarsest_r, Sub_Nlig_2p, Sub_Ncol_2p, Height);
    }

/* SLOPE AZ ESTIMATION FROM TRAIL HEIGHT */
for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
if (FlagValid == 1) rewind(in_valid);
for (lig=0; lig<Sub_Nlig_2p; lig++)
  for (col=0; col<Sub_Ncol_2p; col++) Iheight[lig][col] = 0.;

ligg = 0; Nligg = 0;
for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
    read_block_S2_avg(in_datafile, M_avg, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_avg(in_datafile, M_avg, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }
  if (strcmp(PolTypeIn,"C3")==0) C3_to_T3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);
  if (strcmp(PolTypeIn,"T4")==0) T4_to_T3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);
  if (strcmp(PolTypeIn,"C4")==0) C4_to_T3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    ligg = lig + Nligg;
    if ((ligg !=0)&&(lig != 0)) {
      for (col = 0; col < Sub_Ncol; col++) {
        if (Valid[lig][col] == 1.) {
          if (M_avg[T333][lig][col] != 0){
            Iheight[ligg][col]=(float) (atan2(Height[ligg][col]-Height[ligg-1][col],Reso_a)*180/pi);
            }
          }
        }
      }
    }
  Nligg += NligBlock[Nb];
  } // NbBlock

/* SLOPE BOUND CORRECTION */
  boundcorrection(Iheight, Sub_Nlig, Sub_Ncol);
  write_block_matrix_float(out_slopaz, Iheight, Sub_Nlig, Sub_Ncol, 0, 0, Sub_Ncol);

/* SLOPE RG ESTIMATION FROM TRAIL HEIGHT */
for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
if (FlagValid == 1) rewind(in_valid);
for (lig=0; lig<Sub_Nlig_2p; lig++)
  for (col=0; col<Sub_Ncol_2p; col++) Iheight[lig][col] = 0.;

ligg = 0; Nligg = 0;
for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
    read_block_S2_avg(in_datafile, M_avg, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_avg(in_datafile, M_avg, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }
  if (strcmp(PolTypeIn,"C3")==0) C3_to_T3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);
  if (strcmp(PolTypeIn,"T4")==0) T4_to_T3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);
  if (strcmp(PolTypeIn,"C4")==0) C4_to_T3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    ligg = lig + Nligg;
    if ((ligg !=0)&&(lig != 0)) {
      for (col = 0; col < Sub_Ncol; col++) {
        if (Valid[lig][col] == 1.) {
          if (M_avg[T333][lig][col] != 0){
            Iheight[ligg][col]=(float) (atan2(Height[ligg][col]-Height[ligg][col-1],Reso_r)*180/pi);
            }
          }
        }
      }
    }
  Nligg += NligBlock[Nb];
  } // NbBlock

/* SLOPE BOUND CORRECTION */
  boundcorrection(Iheight, Sub_Nlig, Sub_Ncol);
  write_block_matrix_float(out_sloprg, Iheight, Sub_Nlig, Sub_Ncol, 0, 0, Sub_Ncol);

/**********************************************************************/

for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
if (FlagValid == 1) rewind(in_valid);
for (lig=0; lig<Sub_Nlig_2p; lig++)
  for (col=0; col<Sub_Ncol_2p; col++) Iheight[lig][col] = 0.;
for (lig=0; lig<Sub_Nlig_2p; lig++)
  for (col=0; col<Sub_Ncol_2p; col++) RouN[lig][col] = 0.;

ligg = 0; Nligg = 0;
for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
    read_block_S2_avg(in_datafile, M_avg, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_avg(in_datafile, M_avg, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }
  if (strcmp(PolTypeIn,"C3")==0) C3_to_T3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);
  if (strcmp(PolTypeIn,"T4")==0) T4_to_T3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);
  if (strcmp(PolTypeIn,"C4")==0) C4_to_T3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);

  if (ligg == 0) 
    for (col = 0; col < Sub_Ncol; col++) 
      Slope_a_tmp[col] = 0;
    
/* INITIAL POISSON EQUATION SOURCE MATRIX */
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    ligg = lig + Nligg;
    if ((ligg !=0)&&(lig != 0)) {
      for (col = 1; col < Sub_Ncol; col++) {
        if (Valid[lig][col] == 1.) {
          if (M_avg[T333][lig][col] != 0){
            Slope_a[col]=(float) (atan2(Height[ligg][col]-Height[ligg-1][col],Reso_a)*180/pi);
            Slope_r[col]=(float) (atan2(Height[ligg][col]-Height[ligg][col-1],Reso_r)*180/pi);
            }
          RouN[ligg][col]=(float) (Reso_a*(tan(Slope_a[col]*pi/180)-tan(Slope_a_tmp[col]*pi/180))+Reso_r*(tan(Slope_r[col]*pi/180)-tan(Slope_r[col-1]*pi/180)));
          } else {
          RouN[ligg][col]=0.;
          }
        }
      for (col = 0; col < Sub_Ncol; col++) Slope_a_tmp[col] = Slope_a[col];
      }
    }
  Nligg += NligBlock[Nb];
  } // NbBlock

/* SOURCE MATRIX BOUND CORRECTION */
  boundcorrection(RouN, Sub_Nlig_2p, Sub_Ncol_2p);

/* POISSON EQUATION SOLVING USING UNWEIGHTED FULL MULTI-GRID ALGORITHM Nf TIMES */
  for (i=0; i<Sub_Nlig_2p; i++)
  for (j=0; j<Sub_Ncol_2p; j++) Iheight[i][j] = 0.;

  UFMG(Iheight, RouN, V1, V2, Coarsest_a, Coarsest_r, Sub_Nlig_2p, Sub_Ncol_2p, Height);

  for (i=0; i<(Nf-1); i++){
    for (lig = 0; lig < Sub_Nlig; lig++) {
      PrintfLine(lig,Sub_Nlig);
      for (col = 0; col < Sub_Ncol; col++) {
        if (Valid[lig][col] == 1.) {
          Iheight[lig][col] = Height[lig][col];
          } else {
          Iheight[lig][col] = 0.;
          }
        }
      }
    UFMG(Iheight, RouN, V1, V2, Coarsest_a, Coarsest_r, Sub_Nlig_2p, Sub_Ncol_2p, Height);
    }

/* ABSOLUTE HEIGHT ESTIMATION USING ONE TIE-POINT  */
  offset = Height[Rr][Rc]-Refp;
  for (lig = 0; lig < Sub_Nlig; lig++) {
    PrintfLine(lig,Sub_Nlig);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        Height[lig][col] -= offset;
        } else {
        Height[lig][col] = 0.;
        }
      }
    }

  write_block_matrix_float(out_height, Height, Sub_Nlig, Sub_Ncol, 0, 0, Sub_Ncol);

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_avg, NpolarOut, NligBlock[0]);
  free_matrix_float(Ori_cir, NligBlock[0]);
  free_matrix_float(Slope_a, NligBlock[0]);
  free_matrix_float(Slope_r, NligBlock[0]);
  free_matrix_float(Height, NligBlock[0]);
  free_vector_float(Angle_in);
  free_matrix_float(Iheight, Sub_Nlig_2p);
  free_matrix_float(RouN, Sub_Nlig_2p);
*/
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  fclose(out_orient); fclose(out_slopaz); fclose(out_sloprg); fclose(out_height);
  
/********************************************************************
********************************************************************/

  return 1;
}


/********************************************************************
********************************************************************/

/********************************************************************
        LOCAL ROUTINES          
********************************************************************/
void orient_circular(float ***MM,int li,int subNcol,float *ori)

/* POLARIMETRIC ORIENTATION ANGLE SHIFT ESTIMATION USING CIRCULAR POLARIZATION METHOD (CPM)
% t22  : polarimetric coherency matrix row2 col2 element
% t23_re  : polarimetric coherency matrix row2 col3 real element 
% t33  : polarimetric coherency matrix row3 col3 element 
% ori  : orientation angle shift, range: -45 degree to 45 degree */

{
  int ii;
  int t22, t23_re,t33;
  t22 = 5;
  t23_re = 6;
  t33 = 8;
  for (ii=0; ii<subNcol; ii++){
    if (MM[t33][li][ii]==0) ori[ii]=0;
    else {
      ori[ii]=(float) (0.25*(atan2(-2*MM[t23_re][li][ii],(MM[t33][li][ii]-MM[t22][li][ii]))+pi));
      if (ori[ii]>0.25*pi) ori[ii]=(float) (ori[ii]-0.5*pi);
      ori[ii]=(float) (ori[ii]*180/pi);
      }
    }
}

/*******************************************************************/
void angle_in(float altitu, float r_near, float r_far, float ind_far, int ncol, float *angin)

/* INCIDENCE ANGLE COMPUTATION
% altitu  : flight altitude
% r_near  : near slant range 
% r_far  : far slant range 
% ind_far  : incidence angle maximum
% angin  : incidence angle vector in a row */

{
  int i;
  float gmin, gmax, d, amax, amin;
//float te;
  gmin=(float) (sqrt(pow(r_near,2)-pow(altitu,2)));
  gmax=(float) (sqrt(pow(r_far,2)-pow(altitu,2)));
  d=(gmax-gmin)/(ncol-1);
  for (i=0; i<ncol; i++){
    angin[i]=(float) (atan((gmin+d*i)/altitu)*180/pi);
    }
  amin=angin[0];
  amax=angin[ncol-1];
  for (i=0; i<ncol; i++){
//    te=(float) ((angin[i]-amin)*(ind_far-amax)/(amax-amin));
    angin[i]=(float) (angin[i]+(angin[i]-amin)*(ind_far-amax)/(amax-amin));
    }
}

/*******************************************************************/
void orientation2slope(float ***MM, int li, int subNcol, float *ori, float *angin, float *slopea, float *sloper)

/* AZIMUTH AND RANGE SLOPE ESTIMATION USING COMPENSATION-LAMBERTIAN METHOD
% t11  : polarimetric coherency matrix row2 col2 element
% t22  : polarimetric coherency matrix row2 col2 element
% t23_re  : polarimetric coherency matrix row2 col3 real element 
% t33  : polarimetric coherency matrix row3 col3 element 
% ori  : orientation angle shift, range: -45 degree to 45 degree
% angin  : incidence angle vector in a row
% slopea  : azimuth slope, range -90 degree to 90 degree
% sloper  : range slope, range -90 degree to 90 degree */


{
  int ii;
  int t11, t22, t23_re, t33;
  float m22, m23, m33;
  //float sr_min = -45;
  //float sr_max = 45;
  float sa_max = 45;
  double temp, temp2;

  t11 = 0;
  t22 = 5;
  t23_re = 6;
  t33 = 8;
  
  for (ii=0; ii<subNcol; ii++){
    if (MM[t33][li][ii] == 0){
      slopea[ii] = 0;
      sloper[ii] = 0;
      } else {  /* COMPENSATION */
      m22 = (float) (0.25*(MM[t11][li][ii]+MM[t22][li][ii]-MM[t33][li][ii]));
      m23 = (float) (0.5*MM[t23_re][li][ii]);
      m33 = (float) (0.25*(MM[t11][li][ii]+MM[t33][li][ii]-MM[t22][li][ii]));

      temp = (float) (0.5*(m22+m33+sqrt(pow(m22-m33,2)+4*pow(m23,2))*sin(pi*ori[ii]/45-atan2(m33-m22,2*m23))));
  
      if (temp == 0) temp = eps;
      /* LAMBERTIAN MODEL */
      slopea[ii] = (float) (acos(m22/temp)*180/pi);

      /* AZIMUTH SLOPE VALUE LIMITATION */
      if (slopea[ii] > sa_max) slopea[ii] = sa_max;
    
      if (ori[ii] < 0) slopea[ii] *= -1;

      temp2=tan(ori[ii]*pi/180);
      if (temp2 == 0) temp2 = eps;
      sloper[ii] = (float) (atan2(sin(angin[ii]*pi/180)-tan(slopea[ii]*pi/180)/temp2,cos(angin[ii]*pi/180))*180/pi);
      }
    }
}

/*******************************************************************/
void boundcorrection(float **imin, int Nlig_2p, int Ncol_2p)

/* NEUMANN BOUNDARY CORRECTION
% imin  : input/output matrix */

{
  int jj,ii;
  for (ii=1; ii<Ncol_2p; ii++)
  imin[0][ii] = -imin[1][ii];

  for (jj=0; jj<Nlig_2p; jj++)
    imin[jj][0] = -imin[jj][1];
}

/*******************************************************************/
void laplac(float **imin, int Nlig_2p, int Ncol_2p, float **imout)

/* LAPLACIAN OPERATOR
% imin  : input matrix
% imout  : output matrix */

{
  int jj,ii;

  for (jj=1; jj<(Nlig_2p-1); jj++){
  
    /* BOUNDARY */
    imout[jj][0]=imin[jj-1][0]+imin[jj+1][0]+imin[jj][1]-4*imin[jj][0];
    imout[jj][Ncol_2p-1]=imin[jj-1][Ncol_2p-1]+imin[jj+1][Ncol_2p-1]+imin[jj][Ncol_2p-2]-4*imin[jj][Ncol_2p-1];
  
    for(ii=1; ii<(Ncol_2p-1); ii++)
      imout[jj][ii]=imin[jj-1][ii]+imin[jj+1][ii]+imin[jj][ii-1]+imin[jj][ii+1]-4*imin[jj][ii];
    }

  /* BOUNDARY */
  imout[0][0] = imin[0][1]+imin[1][0]-4*imin[0][0];
  imout[Nlig_2p-1][0] = imin[Nlig_2p-2][0]+imin[Nlig_2p-1][1]-4*imin[Nlig_2p-1][0];
  imout[Nlig_2p-1][Ncol_2p-1] = imin[Nlig_2p-1][Ncol_2p-2]+imin[Nlig_2p-2][Ncol_2p-1]-4*imin[Nlig_2p-1][Ncol_2p-1];
  imout[0][Ncol_2p-1] = imin[0][Ncol_2p-2]+imin[1][Ncol_2p-1]-4*imin[0][Ncol_2p-1];

  /* BOUNDARY */
  for (ii=1; ii<(Ncol_2p-1); ii++){
    imout[0][ii]=imin[1][ii]+imin[0][ii-1]+imin[0][ii+1]-3*imin[0][ii];
    imout[Nlig_2p-1][ii]=imin[Nlig_2p-2][ii]+imin[Nlig_2p-1][ii-1]+imin[Nlig_2p-1][ii+1]-3*imin[Nlig_2p-1][ii];
    }
}

/*******************************************************************/
void resample(float **imin, int Nlig_2p, int Ncol_2p, float **imout)

/* DOWN SAMPLE RATE
% imin  : input matrix
% imout  : output matrix */

{
  int jj,ii;
  for (jj=0; jj<(Nlig_2p/2); jj++)
    for (ii=0; ii<(Ncol_2p/2); ii++)
      imout[jj][ii]=imin[jj*2+1][ii*2+1];
}

/*******************************************************************/
void relaxGS(float **imin, float **roun, int Nlig_2p, int Ncol_2p, int v1)

/* GAUSS-SEIDEL RELAXATION
% imin  : input/output matrix
% roun  : poisson equation source function matrix 
% v1  : nb of relax */

{
  int i,jj,ii;
  float **La_matrix=matrix_float(Nlig_2p, Ncol_2p);

  if (v1<1)
    edit_error("Relax number v1 is wrong!\n","");
  else {
    for (i=0; i<v1; i++){
      laplac(imin, Nlig_2p, Ncol_2p, La_matrix);
        for (jj=0; jj<Nlig_2p; jj++){
          for (ii=0; ii<Ncol_2p; ii++){
            imin[jj][ii] += (float) (0.25*(La_matrix[jj][ii]-roun[jj][ii]));
            }
          }
      }
    }

  free_matrix_float(La_matrix, Nlig_2p);
}

/******************************************************************/
void restriction(float **imin, int Nlig_2p, int Ncol_2p, float **imout)

/* RESTRICTION OPERATOR
% imin  : input matrix
% imout  : output matrix 0.5 * nb of col and lig */

{
  int jj,ii;
  int Nlig2 = (int) (0.5*Nlig_2p);
  int Ncol2 = (int) (0.5*Ncol_2p);

  for (jj=1; jj<Nlig2; jj++){
    for (ii=1; ii<Ncol2; ii++){
      imout[jj][ii]=(float) (0.25*0.25*(imin[2*jj-2][2*ii-2]+imin[2*jj][2*ii-2]+imin[2*jj-2][2*ii]+imin[2*jj][2*ii]) 
      + 0.125*(imin[2*jj-1][2*ii-2]+imin[2*jj-1][2*ii]+imin[2*jj-2][2*ii-1]+imin[2*jj][2*ii-1]) + 0.25*imin[2*jj-1][2*ii-1]);
      }
    }

  boundcorrection(imout, Nlig2, Ncol2);
}

/*******************************************************************/
void prolongation(float **imin, int Nlig_2p, int Ncol_2p, float **imout)

/* PROLONGATION OPERATOR
% imin  : input matrix
% imout  : output matrix 2 * nb of col and lig */

{
  int jj,ii;
  int Nlig2=2*Nlig_2p;
  int Ncol2=2*Ncol_2p;

  for (jj=0; jj<(Nlig_2p-1); jj++){
    for (ii=0; ii<(Ncol_2p-1); ii++){
      imout[2*jj+1][2*ii+1]=imin[jj][ii];
      imout[2*jj+2][2*ii+1]=(float) (0.5*(imin[jj][ii]+imin[jj+1][ii]));
      imout[2*jj+1][2*ii+2]=(float) (0.5*(imin[jj][ii]+imin[jj][ii+1]));
      imout[2*jj+2][2*ii+2]=(float) (0.25*(imin[jj][ii]+imin[jj+1][ii]+imin[jj][ii+1]+imin[jj+1][ii+1]));
      }
    }

  for (jj=0; jj<Nlig_2p-1; jj++){
    imout[2*jj+1][Ncol2-1]=imin[jj][Ncol_2p-1];
    imout[2*jj+2][Ncol2-1]=(float) (0.5*(imin[jj][Ncol_2p-1]+imin[jj+1][Ncol_2p-1]));
    }

  for (ii=0; ii<Ncol_2p-1; ii++){
    imout[Nlig2-1][2*ii+1]=imin[Nlig_2p-1][ii];
    imout[Nlig2-1][2*ii+2]=(float) (0.5*(imin[Nlig_2p-1][ii]+imin[Nlig_2p-1][ii+1]));
    }

  imout[Nlig2-1][Ncol2-1]=imin[Nlig_2p-1][Ncol_2p-1];

  boundcorrection(imout, Nlig2, Ncol2);
}

/*******************************************************************/
void UMV(float **iheight, float **roun, int v1, int v2, int coarsest_a, int coarsest_r, int Nlig_2p, int Ncol_2p, float **height)
   
/* UNWEIGHTED MULTI-GRID V-SHAPE ALGORITHM
% iheight  : initial zero to height matrix
% roun  : poisson equation source function matrix 
% v1    : nb of relax in the begining 
% v2    : nb of relax in the end
% coarsest_a  : nb of azimuth coarsest grid
% coarsest_r  : nb of range coarsest grid
% height  : output height matrix */


{
  int jj,ii;
  int Nlig2 = (int) (0.5*Nlig_2p);
  int Ncol2 = (int) (0.5*Ncol_2p);

  float **temp_matrix = matrix_float(Nlig_2p, Ncol_2p);
  float **roun2 = matrix_float(Nlig2, Ncol2);
  float **iheight2 = matrix_float(Nlig2, Ncol2);
  float **height2 = matrix_float(Nlig2, Ncol2);

  relaxGS(iheight, roun, Nlig_2p, Ncol_2p, v1);

  if ((Nlig_2p<=coarsest_a) || (Ncol_2p<=coarsest_r))
    relaxGS(iheight, roun, Nlig_2p, Ncol_2p, v2);
    else {
    laplac(iheight, Nlig_2p, Ncol_2p, temp_matrix);

    for (jj=0; jj<Nlig_2p; jj++){
      for (ii=0; ii<Ncol_2p; ii++){
        temp_matrix[jj][ii]=roun[jj][ii]-temp_matrix[jj][ii];
        }
      }

    restriction(temp_matrix, Nlig_2p, Ncol_2p, roun2);
    free_matrix_float(temp_matrix, Nlig_2p); 
  
    UMV(iheight2, roun2, v1, v2, coarsest_a, coarsest_r, Nlig2, Ncol2, height2);

    temp_matrix = matrix_float(Nlig_2p, Ncol_2p);
    prolongation(height2, Nlig2, Ncol2, temp_matrix);

    for (jj=0; jj<Nlig_2p; jj++){
      for (ii=0; ii<Ncol_2p; ii++){
        height[jj][ii]=iheight[jj][ii]+temp_matrix[jj][ii];
        }
      }

    relaxGS(height, roun, Nlig_2p, Ncol_2p, v2);
    }

  free_matrix_float(temp_matrix, Nlig_2p);
  free_matrix_float(roun2, Nlig2);
  free_matrix_float(iheight2, Nlig2);
  free_matrix_float(height2, Nlig2);
}

/*******************************************************************************/
void UFMG(float **iheight, float **roun, int v1, int v2, int coarsest_a, int coarsest_r, int Nlig_2p, int Ncol_2p, float **height)
      
/* UNWEIGHTED FULL MULTI-GRID W-SHAPE ALGORITHM
% iheight  : initial zero to height matrix
% roun  : poisson equation source function matrix 
% v1    : nb of relax in the begining 
% v2    : nb of relax in the end
% coarsest_a  : nb of azimuth coarsest grid
% coarsest_r  : nb of range coarsest grid
% height  : output height matrix */


{
  int jj,ii;
  int Nlig2 = (int) (0.5*Nlig_2p);
  int Ncol2 = (int) (0.5*Ncol_2p);

  float **temp_matrix = matrix_float(Nlig_2p, Ncol_2p);
  float **roun2 = matrix_float(Nlig2, Ncol2);
  float **iheight2 = matrix_float(Nlig2, Ncol2);
  float **height2 = matrix_float(Nlig2, Ncol2);

  if ((Nlig_2p<=coarsest_a) || (Ncol_2p<=coarsest_r))
    UMV(iheight, roun, v1, v2, coarsest_a, coarsest_r, Nlig_2p, Ncol_2p, height);
    else {
    laplac(iheight, Nlig_2p, Ncol_2p, temp_matrix);

    for (jj=0; jj<Nlig_2p; jj++){
      for (ii=0; ii<Ncol_2p; ii++){
        temp_matrix[jj][ii]=roun[jj][ii]-temp_matrix[jj][ii];
        }
      }

    restriction(temp_matrix, Nlig_2p, Ncol_2p, roun2);
    free_matrix_float(temp_matrix, Nlig_2p);

    resample(iheight, Nlig_2p, Ncol_2p, iheight2);

    boundcorrection(iheight2, Nlig2, Ncol2);

    UFMG(iheight2, roun2, v1, v2, coarsest_a, coarsest_r, Nlig2, Ncol2, height2);

    temp_matrix = matrix_float(Nlig_2p, Ncol_2p);
    prolongation(height2, Nlig2, Ncol2, temp_matrix);

    for (jj=0; jj<Nlig_2p; jj++){
      for (ii=0; ii<Ncol_2p; ii++){
        temp_matrix[jj][ii] += iheight[jj][ii];
        }
      }

    UMV(temp_matrix, roun, v1, v2, coarsest_a, coarsest_r, Nlig_2p, Ncol_2p, height);
    }

  free_matrix_float(temp_matrix, Nlig_2p);
  free_matrix_float(roun2, Nlig2);
  free_matrix_float(iheight2, Nlig2);
  free_matrix_float(height2, Nlig2);
}


