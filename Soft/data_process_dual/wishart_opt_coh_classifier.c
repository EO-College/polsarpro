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

File  : wishart_opt_coh_classifier.c
Project  : ESA_POLSARPRO
Authors  : Laurent FERRO-FAMIL
Version  : 2.0
Creation : 12/2006
Update  : 08/2012 (v2.0 Eric POTTIER)
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

Description :  Unsupervised maximum likelihood classification of 
a dual polarimetric interferometric image data set based on the use
of the Wishart PDF of its coherency matrices

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
/* S matrix */
#define hh1 0
#define hv1 1
#define vh1 2
#define vv1 3
#define hh2 4
#define hv2 5
#define vh2 6
#define vv2 7

/* CONSTANTS  */
#define Npolar 36
#define nparam_out 36
#define Npolar_in 8

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"

void cplx_det_inv_coh(cplx ***mat,cplx ***res,float *det,int nb_class);
float num_classe(cplx ***icoh_moy,float *det,cplx **T,int nb_class);

/* GLOBAL VARIABLES */
cplx **nT, **nV, **nmat1, **nmat2;
float *nL;

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
  char *PolTypeConf[NPolType] = {"S2T6", "T6"};

/* Input/Output file pointer arrays */
  FILE  *fich_classe, *fich_mask, *fich_classe_in;
  FILE  *in_file[Npolar];

/* Strings */
  char  nom_fich[FilePathLength],file_name[256];
  char  mask_file_name[256], class_file_name[256];
  char  ColorMap9[FilePathLength];
  char *file_name_in[Npolar_in] = {
        "s11.bin", "s12.bin", "s21.bin", "s22.bin",
        "s11.bin", "s12.bin", "s21.bin", "s22.bin"};

/* Input variables */
  int  nlig,ncol,l,c;
  int  i,j,li,co,ii,jj;
  int  nb_it,critere,nb_it_max,nb_class,OK,cl,np;
  int  mask_type, coh_avg;
  float k1r,k1i,k2r,k2i,k3r,k3i,k4r,k4i,k5r,k5i,k6r,k6i;
  
  float **S_in;
  float **classe,**mask,**M_in;
  float *cpt_cl,*det;
//  float **coh;
  float nb_ch,pct_ch,pct_min;

  cplx  ***coh_moy,***icoh_moy;
  cplx  **T;
//  cplx  **V;
//  cplx  *k;

/* Pointers ****/

 nT  = cplx_matrix(6,6);
 nV  = cplx_matrix(6,6);
 nmat1 = cplx_matrix(6,6);
 nmat2 = cplx_matrix(6,6);
 nL  = vector_float(6);

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nwishart_opt_coh_classifier.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," if iodf = S2T6\n");
strcat(UsageHelp," (string)	-idm 	input master directory\n");
strcat(UsageHelp," (string)	-ids 	input slave directory\n");
strcat(UsageHelp," if iodf = T6\n");
strcat(UsageHelp," (string)	-id  	input master-slave directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (string)	-msk 	input mask file\n");
strcat(UsageHelp," (string)	-cls 	input class file\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (int)   	-nit 	maximum interation number\n");
strcat(UsageHelp," (float) 	-pct 	maximum of pixel switching classes\n");
strcat(UsageHelp," (string)	-col 	input colormap file\n");
strcat(UsageHelp," (int)   	-mt  	mask type : 1=sgl, 2=dbl, 3=vol, 0=other\n");
strcat(UsageHelp," (int)   	-avg 	coherence averaging (1/0)\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
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
  
if(argc < 25) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  if (strcmp(PolType, "S2T6") == 0) {
    get_commandline_prm(argc,argv,"-idm",str_cmd_prm,in_dir1,1,UsageHelp);
    get_commandline_prm(argc,argv,"-ids",str_cmd_prm,in_dir2,1,UsageHelp);
    }
  if (strcmp(PolType, "T6") == 0) {
    get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir1,1,UsageHelp);
    strcpy(in_dir2,in_dir1);
    }
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-msk",str_cmd_prm,mask_file_name,1,UsageHelp);
  get_commandline_prm(argc,argv,"-cls",str_cmd_prm,class_file_name,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nit",int_cmd_prm,&nb_it_max,1,UsageHelp);
  get_commandline_prm(argc,argv,"-pct",flt_cmd_prm,&pct_min,1,UsageHelp);
  get_commandline_prm(argc,argv,"-col",str_cmd_prm,ColorMap9,1,UsageHelp);
  get_commandline_prm(argc,argv,"-mt",int_cmd_prm,&mask_type,1,UsageHelp);
  get_commandline_prm(argc,argv,"-avg",int_cmd_prm,&coh_avg,1,UsageHelp);

  Config = 0;
  for (ii=0; ii<NPolType; ii++) if (strcmp(PolTypeConf[ii],PolType) == 0) Config = 1;
  if (Config == 0) edit_error("\nWrong argument in the Polarimetric Data Format\n",UsageHelpDataFormat);
  }

/********************************************************************
********************************************************************/

 nb_class = 30;
 OK = 0;
 pct_min = pct_min/100;

 check_dir(in_dir1);
 if (strcmp(PolType, "S2T6") == 0) check_dir(in_dir2);
 check_dir(out_dir);
 check_file(mask_file_name);
 check_file(class_file_name);
 check_file(ColorMap9);

/********************************************************************
********************************************************************/
 if (strcmp(PolType, "S2T6") == 0) {
  for (np = 0; np < 4; np++) {
   sprintf(file_name, "%s%s", in_dir1, file_name_in[np]);
   if ((in_file[np] = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name);
   }
  for (np = 4; np < Npolar_in; np++) {
   sprintf(file_name, "%s%s", in_dir2, file_name_in[np]);
   if ((in_file[np] = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name);
    }
  }
 if (strcmp(PolType, "T6") == 0) {
  np=0;
  for(li=0;li<6;li++) {
   sprintf(file_name, "%sT%d%d.bin", in_dir,li+1,li+1);
   if ((in_file[np] = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name);
   np++;
   for(co=li+1;co<6;co++) {
    sprintf(file_name, "%sT%d%d_real.bin",in_dir,li+1,co+1);
    if ((in_file[np] = fopen(file_name, "rb")) == NULL)
     edit_error("Could not open input file : ", file_name);
    np++;
    sprintf(file_name, "%sT%d%d_imag.bin", in_dir,li+1,co+1);
    if ((in_file[np] = fopen(file_name, "rb")) == NULL)
     edit_error("Could not open input file : ", file_name);
    np++;  
    }
   } 
  }
  
/********************************************************************
********************************************************************/
 strcpy(nom_fich,mask_file_name);
 if ((fich_mask=fopen(nom_fich, "rb"))==NULL)
  edit_error("Could not open input file : ", nom_fich);

 strcpy(nom_fich,class_file_name);
 if ((fich_classe_in=fopen(nom_fich,"rb"))==NULL)
  edit_error("Could not open input file : ", nom_fich);
 
/********************************************************************
********************************************************************/
/* INPUT/OUPUT CONFIGURATIONS */

  coh_moy  = cplx_matrix3d(6,6,nb_class);
  icoh_moy  = cplx_matrix3d(6,6,nb_class);
//  coh  = matrix_float(nlig,ncol);
  classe  = matrix_float(nlig,ncol);
  mask  = matrix_float(nlig,ncol);
  M_in  = matrix_float(Npolar,ncol);
  cpt_cl  = vector_float(nb_class);
  det  = vector_float(nb_class);
  T    = cplx_matrix(6,6);
//  V    = cplx_matrix(6,6);
//  k    = cplx_vector(6);
  if (strcmp(PolType, "S2T6") == 0) S_in = matrix_float(Npolar_in, 2 * ncol);

/*******************************************************************/
/* Classes reading */  
/*******************************************************************/
 for (i=0; i<nlig; i++) {
  fread(&mask[i][0],sizeof(float),ncol,fich_mask);
  fread(&classe[i][0],sizeof(float),ncol,fich_classe_in);
  }
 fclose(fich_mask);
 fclose(fich_classe_in);

 for(cl=1;cl<nb_class;cl++) cpt_cl[cl] = 0;

/*******************************************************************/
/* Bi-Dim Classes Initialisation */
/*******************************************************************/

 for (i=0; i<nlig; i++) {
  PrintfLine(i,nlig);
  
  if (strcmp(PolType, "S2T6") == 0) {
   for (np = 0; np < Npolar_in; np++) fread(&S_in[np][0], sizeof(float), 2 * ncol, in_file[np]);
   for (j = 0; j < ncol; j++) {
    k1r = (S_in[hh1][2*j] + S_in[vv1][2*j]) / sqrt(2.);k1i = (S_in[hh1][2*j + 1] + S_in[vv1][2*j + 1]) / sqrt(2.);
    k2r = (S_in[hh1][2*j] - S_in[vv1][2*j]) / sqrt(2.);k2i = (S_in[hh1][2*j + 1] - S_in[vv1][2*j + 1]) / sqrt(2.);
    k3r = (S_in[hv1][2*j] + S_in[vh1][2*j]) / sqrt(2.);k3i = (S_in[hv1][2*j + 1] + S_in[vh1][2*j + 1]) / sqrt(2.);
    k4r = (S_in[hh2][2*j] + S_in[vv2][2*j]) / sqrt(2.);k4i = (S_in[hh2][2*j + 1] + S_in[vv2][2*j + 1]) / sqrt(2.);
    k5r = (S_in[hh2][2*j] - S_in[vv2][2*j]) / sqrt(2.);k5i = (S_in[hh2][2*j + 1] - S_in[vv2][2*j + 1]) / sqrt(2.);
    k6r = (S_in[hv2][2*j] + S_in[vh2][2*j]) / sqrt(2.);k6i = (S_in[hv2][2*j + 1] + S_in[vh2][2*j + 1]) / sqrt(2.);

    M_in[0][j] = k1r * k1r + k1i * k1i;  M_in[1][j] = k1r * k2r + k1i * k2i;  M_in[2][j] = k1i * k2r - k1r * k2i;
    M_in[3][j] = k1r * k3r + k1i * k3i;  M_in[4][j] = k1i * k3r - k1r * k3i;  M_in[5][j] = k1r * k4r + k1i * k4i;
    M_in[6][j] = k1i * k4r - k1r * k4i;  M_in[7][j] = k1r * k5r + k1i * k5i;  M_in[8][j] = k1i * k5r - k1r * k5i;
    M_in[9][j] = k1r * k6r + k1i * k6i;  M_in[10][j] = k1i * k6r - k1r * k6i; M_in[11][j] = k2r * k2r + k2i * k2i;
    M_in[12][j] = k2r * k3r + k2i * k3i; M_in[13][j] = k2i * k3r - k2r * k3i; M_in[14][j] = k2r * k4r + k2i * k4i;
    M_in[15][j] = k2i * k4r - k2r * k4i; M_in[16][j] = k2r * k5r + k2i * k5i; M_in[17][j] = k2i * k5r - k2r * k5i;
    M_in[18][j] = k2r * k6r + k2i * k6i; M_in[19][j] = k2i * k6r - k2r * k6i; M_in[20][j] = k3r * k3r + k3i * k3i;
    M_in[21][j] = k3r * k4r + k3i * k4i; M_in[22][j] = k3i * k4r - k3r * k4i; M_in[23][j] = k3r * k5r + k3i * k5i;
    M_in[24][j] = k3i * k5r - k3r * k5i; M_in[25][j] = k3r * k6r + k3i * k6i; M_in[26][j] = k3i * k6r - k3r * k6i;
    M_in[27][j] = k4r * k4r + k4i * k4i; M_in[28][j] = k4r * k5r + k4i * k5i; M_in[29][j] = k4i * k5r - k4r * k5i;
    M_in[30][j] = k4r * k6r + k4i * k6i; M_in[31][j] = k4i * k6r - k4r * k6i; M_in[32][j] = k5r * k5r + k5i * k5i;
    M_in[33][j] = k5r * k6r + k5i * k6i; M_in[34][j] = k5i * k6r - k5r * k6i; M_in[35][j] = k6r * k6r + k6i * k6i;
    }
   }
  if (strcmp(PolType, "T6") == 0) {
   for(np=0;np<Npolar;np++) fread(M_in[np],sizeof(float),ncol,in_file[np]);
   }

  for (j=0; j<ncol; j++) {
   if(mask[i][j]>0) {
    np = 0;
    for(ii=0;ii<6;ii++) {
     T[ii][ii].re = M_in[np][j]; T[ii][ii].im = 0;
     np++;
     for(jj=ii+1;jj<6;jj++) {
      T[ii][jj].re = M_in[np][j]; np++;
      T[ii][jj].im = M_in[np][j]; np++;
      }
     } 

    cl = (int)classe[i][j];
    cpt_cl[cl]++;

/* Mean matrix affected to class cl*/
    for(l=0;l<6;l++) {
     coh_moy[l][l][cl].re += T[l][l].re;
     coh_moy[l][l][cl].im += T[l][l].im;
     for(c=l+1;c<6;c++) {
      coh_moy[l][c][cl].re += T[l][c].re;
      coh_moy[l][c][cl].im += T[l][c].im;
      coh_moy[c][l][cl].re += T[l][c].re;
      coh_moy[c][l][cl].im += -T[l][c].im;
      }
     }
    } else
    classe[i][j]=0;
   }/*j*/
  }/*i*/

 while(OK!=1) {
  OK=1;
  for(cl=1;cl<nb_class;cl++) {
   if(cpt_cl[cl]==0) {
    OK=0;
    nb_class--;
    if(cl != nb_class-1) {
     for(np=cl;np<nb_class;np++) {
      cpt_cl[np] = cpt_cl[np+1];
      for(l=0;l<6;l++)
       for(c=0;c<6;c++) {
        coh_moy[l][c][np].re = coh_moy[l][c][np+1].re;
        coh_moy[l][c][np].im = coh_moy[l][c][np+1].im;
        }
      for(l=0;l<nlig;l++)
       for(c=0;c<ncol;c++)
        if(classe[l][c]==(np+1)) classe[l][c]=np;
      }
     }
    }
   }
  }
 OK = 0;

/* Mean matrices */
 for(l=0;l<6;l++)
  for(c=0;c<6;c++)
   for(cl=1;cl<nb_class;cl++) {
    coh_moy[l][c][cl].re = coh_moy[l][c][cl].re/cpt_cl[cl];
    coh_moy[l][c][cl].im = coh_moy[l][c][cl].im/cpt_cl[cl];
    }

/* Reset */
 critere = 0;
 nb_it = 0;

 for(cl=1;cl<nb_class;cl++) cpt_cl[cl] = 0;
 
/* CLASSIFICATION */
 while(critere==0) {
  pct_ch = 0;
  nb_ch = 0;
  for(cl=0;cl<nb_class;cl++) cpt_cl[cl]=0;
  nb_it++;
  
  if (strcmp(PolType, "S2T6") == 0) for(np=0;np<Npolar_in;np++) rewind(in_file[np]);
  if (strcmp(PolType, "T6") == 0) for(np=0;np<Npolar;np++) rewind(in_file[np]);

  cplx_det_inv_coh(coh_moy,icoh_moy,det,nb_class);

/* Mean matrices Reset */
  for(l=0;l<6;l++)
   for(c=0;c<6;c++)
    for(cl=1;cl<nb_class;cl++) {
     coh_moy[l][c][cl].re = 0;
     coh_moy[l][c][cl].im = 0;
     }

/**********************************************************************/
/**********************************************************************/

  for (i=0; i<nlig; i++) {
   PrintfLine(i,nlig);

   if (strcmp(PolType, "S2T6") == 0) {
    for (np = 0; np < Npolar_in; np++) fread(&S_in[np][0], sizeof(float), 2 * ncol, in_file[np]);
    for (j = 0; j < ncol; j++) {
     k1r = (S_in[hh1][2*j] + S_in[vv1][2*j]) / sqrt(2.);k1i = (S_in[hh1][2*j + 1] + S_in[vv1][2*j + 1]) / sqrt(2.);
     k2r = (S_in[hh1][2*j] - S_in[vv1][2*j]) / sqrt(2.);k2i = (S_in[hh1][2*j + 1] - S_in[vv1][2*j + 1]) / sqrt(2.);
     k3r = (S_in[hv1][2*j] + S_in[vh1][2*j]) / sqrt(2.);k3i = (S_in[hv1][2*j + 1] + S_in[vh1][2*j + 1]) / sqrt(2.);
     k4r = (S_in[hh2][2*j] + S_in[vv2][2*j]) / sqrt(2.);k4i = (S_in[hh2][2*j + 1] + S_in[vv2][2*j + 1]) / sqrt(2.);
     k5r = (S_in[hh2][2*j] - S_in[vv2][2*j]) / sqrt(2.);k5i = (S_in[hh2][2*j + 1] - S_in[vv2][2*j + 1]) / sqrt(2.);
     k6r = (S_in[hv2][2*j] + S_in[vh2][2*j]) / sqrt(2.);k6i = (S_in[hv2][2*j + 1] + S_in[vh2][2*j + 1]) / sqrt(2.);

     M_in[0][j] = k1r * k1r + k1i * k1i;  M_in[1][j] = k1r * k2r + k1i * k2i;  M_in[2][j] = k1i * k2r - k1r * k2i;
     M_in[3][j] = k1r * k3r + k1i * k3i;  M_in[4][j] = k1i * k3r - k1r * k3i;  M_in[5][j] = k1r * k4r + k1i * k4i;
     M_in[6][j] = k1i * k4r - k1r * k4i;  M_in[7][j] = k1r * k5r + k1i * k5i;  M_in[8][j] = k1i * k5r - k1r * k5i;
     M_in[9][j] = k1r * k6r + k1i * k6i;  M_in[10][j] = k1i * k6r - k1r * k6i; M_in[11][j] = k2r * k2r + k2i * k2i;
     M_in[12][j] = k2r * k3r + k2i * k3i; M_in[13][j] = k2i * k3r - k2r * k3i; M_in[14][j] = k2r * k4r + k2i * k4i;
     M_in[15][j] = k2i * k4r - k2r * k4i; M_in[16][j] = k2r * k5r + k2i * k5i; M_in[17][j] = k2i * k5r - k2r * k5i;
     M_in[18][j] = k2r * k6r + k2i * k6i; M_in[19][j] = k2i * k6r - k2r * k6i; M_in[20][j] = k3r * k3r + k3i * k3i;
     M_in[21][j] = k3r * k4r + k3i * k4i; M_in[22][j] = k3i * k4r - k3r * k4i; M_in[23][j] = k3r * k5r + k3i * k5i;
     M_in[24][j] = k3i * k5r - k3r * k5i; M_in[25][j] = k3r * k6r + k3i * k6i; M_in[26][j] = k3i * k6r - k3r * k6i;
     M_in[27][j] = k4r * k4r + k4i * k4i; M_in[28][j] = k4r * k5r + k4i * k5i; M_in[29][j] = k4i * k5r - k4r * k5i;
     M_in[30][j] = k4r * k6r + k4i * k6i; M_in[31][j] = k4i * k6r - k4r * k6i; M_in[32][j] = k5r * k5r + k5i * k5i;
     M_in[33][j] = k5r * k6r + k5i * k6i; M_in[34][j] = k5i * k6r - k5r * k6i; M_in[35][j] = k6r * k6r + k6i * k6i;
     }
    }
   if (strcmp(PolType, "T6") == 0) {
    for(np=0;np<Npolar;np++) fread(M_in[np],sizeof(float),ncol,in_file[np]);
    }
   for (j=0; j<ncol; j++) {
    if(mask[i][j]>0) {
     np = 0;
     for(ii=0;ii<6;ii++) {
      T[ii][ii].re = M_in[np][j]; T[ii][ii].im = 0;
      np++;
      for(jj=ii+1;jj<6;jj++) {
       T[ii][jj].re = M_in[np][j]; np++;
       T[ii][jj].im = M_in[np][j]; np++;
       }
      } 

  /* Appartenance du pixel traite */
     cl = num_classe(icoh_moy,det,T,nb_class);

/* incrementation des compteurs*/
     if(classe[i][j]!=cl) nb_ch++;
     classe[i][j] = cl;
     cpt_cl[cl]++;

     for(l=0;l<6;l++) {
      coh_moy[l][l][cl].re += T[l][l].re;
      coh_moy[l][l][cl].im += T[l][l].im;
      for(c=l+1;c<6;c++) {
       coh_moy[l][c][cl].re += T[l][c].re;
       coh_moy[l][c][cl].im += T[l][c].im;
       coh_moy[c][l][cl].re += T[l][c].re;
       coh_moy[c][l][cl].im += -T[l][c].im;
       }
      }
     } 
    }/*j*/
   }/*i*/

  while(OK!=1) {
   OK=1;
   for(cl=1;cl<nb_class;cl++) {
    if(cpt_cl[cl]==0) {
     OK=0;
     nb_class--;
     if(cl != nb_class-1) {
      for(np=cl;np<nb_class;np++) {
       cpt_cl[np] = cpt_cl[np+1];
       for(l=0;l<6;l++)
        for(c=0;c<6;c++) coh_moy[l][c][np] = coh_moy[l][c][np+1];
       for(l=0;l<nlig;l++)
        for(c=0;c<ncol;c++) if(classe[l][c]==(np+1)) classe[l][c]=np;
       }
      }
     }
    }
   }
  OK = 0;
 
  for(l=0;l<6;l++)
   for(c=0;c<6;c++)
    for(cl=1;cl<nb_class;cl++) {
     if(cpt_cl[cl]!=0) {
      coh_moy[l][c][cl].re /= cpt_cl[cl];
      coh_moy[l][c][cl].im /= cpt_cl[cl];
      }
     }
  for(cl=1;cl<nb_class;cl++) pct_ch += cpt_cl[cl];

  pct_ch = nb_ch/pct_ch;

  if(nb_it>nb_it_max) critere = 1;
  if(pct_ch<pct_min) critere = 1;

  }/* while */

/* SAVE CLASSIFICATION */
 if (coh_avg == 0) {
  if (mask_type == 0) sprintf(nom_fich,"%swishart_coh_opt_xxx_class.bin", out_dir);
  if (mask_type == 1) sprintf(nom_fich,"%swishart_coh_opt_sgl_class.bin", out_dir);
  if (mask_type == 2) sprintf(nom_fich,"%swishart_coh_opt_dbl_class.bin", out_dir);
  if (mask_type == 3) sprintf(nom_fich,"%swishart_coh_opt_vol_class.bin", out_dir);
  }
 if (coh_avg == 1) {
  if (mask_type == 0) sprintf(nom_fich,"%swishart_coh_avg_opt_xxx_class.bin", out_dir);
  if (mask_type == 1) sprintf(nom_fich,"%swishart_coh_avg_opt_sgl_class.bin", out_dir);
  if (mask_type == 2) sprintf(nom_fich,"%swishart_coh_avg_opt_dbl_class.bin", out_dir);
  if (mask_type == 3) sprintf(nom_fich,"%swishart_coh_avg_opt_vol_class.bin", out_dir);
  }
 if ((fich_classe=fopen(nom_fich,"wb"))==NULL)
  edit_error("Could not open input file : ", nom_fich);
 for(i=0;i<nlig;i++) fwrite(&classe[i][0], sizeof(float), ncol, fich_classe);
 fclose(fich_classe);

 if (coh_avg == 0) {
  if (mask_type == 0) sprintf(nom_fich,"%swishart_coh_opt_xxx_class", out_dir);
  if (mask_type == 1) sprintf(nom_fich,"%swishart_coh_opt_sgl_class", out_dir);
  if (mask_type == 2) sprintf(nom_fich,"%swishart_coh_opt_dbl_class", out_dir);
  if (mask_type == 3) sprintf(nom_fich,"%swishart_coh_opt_vol_class", out_dir);
  }
 if (coh_avg == 1) {
  if (mask_type == 0) sprintf(nom_fich,"%swishart_coh_avg_opt_xxx_class", out_dir);
  if (mask_type == 1) sprintf(nom_fich,"%swishart_coh_avg_opt_sgl_class", out_dir);
  if (mask_type == 2) sprintf(nom_fich,"%swishart_coh_avg_opt_dbl_class", out_dir);
  if (mask_type == 3) sprintf(nom_fich,"%swishart_coh_avg_opt_vol_class", out_dir);
  }
 bmp_wishart(classe,nlig,ncol,nom_fich,ColorMap9);

/*******************************************************************/
/*******************************************************************/

 if (strcmp(PolType, "S2T6") == 0) for(np=0;np<Npolar_in;np++) fclose(in_file[np]);

 free_vector_float(cpt_cl);
 free_vector_float(det);
 free_matrix_float(classe,nlig);
 free_matrix_float(mask,nlig);

  return 1;
} /*main*/

/*******************************************************************/
/*******************************************************************/
/*        LOCAL ROUTINES          */
/*******************************************************************/
/*******************************************************************/
void cplx_det_inv_coh(cplx ***mat,cplx ***res,float *det,int nb_class)
{
 int cl,l,c;

 for(cl=1;cl<nb_class;cl++) {
  for(l=0;l<6;l++)
   for(c=0;c<6;c++) {
    nT[l][c].re = mat[l][c][cl].re;
    nT[l][c].im = mat[l][c][cl].im;
    nmat1[l][c].re = 0;
    nmat1[l][c].im = 0;
    }

  cplx_diag_mat6(nT,nV,nL);

  det[cl]=1;
  for(l=0;l<6;l++) {
   det[cl] *= fabs(nL[l]);
   nmat1[l][l].re = 1/nL[l];
   }
  cplx_htransp_mat(nV,nT,6,6);
  cplx_mul_mat(nmat1,nT,nmat2,6,6);
  cplx_mul_mat(nV,nmat2,nmat1,6,6);

  for(l=0;l<6;l++)
   for(c=0;c<6;c++) {
    res[l][c][cl].re = nmat1[l][c].re;
    res[l][c][cl].im = nmat1[l][c].im;
    }
  }

}

/*******************************************************************/
/*******************************************************************/
float num_classe(cplx ***icoh_moy,float *det,cplx **T,int nb_class)
{
 float min,dist,r;
 int cl;
/* int l,c;*/

 min=INIT_MINMAX;
 for(cl=1;cl<nb_class;cl++) {
  dist = log(det[cl])
  +icoh_moy[0][0][cl].re*T[0][0].re
  +icoh_moy[1][1][cl].re*T[1][1].re
  +icoh_moy[2][2][cl].re*T[2][2].re
  +icoh_moy[3][3][cl].re*T[3][3].re
  +icoh_moy[4][4][cl].re*T[4][4].re
  +icoh_moy[5][5][cl].re*T[5][5].re
  +2*(icoh_moy[0][1][cl].re*T[0][1].re+icoh_moy[0][1][cl].im*T[0][1].im)
  +2*(icoh_moy[0][2][cl].re*T[0][2].re+icoh_moy[0][2][cl].im*T[0][2].im)
  +2*(icoh_moy[0][3][cl].re*T[0][3].re+icoh_moy[0][3][cl].im*T[0][3].im)
  +2*(icoh_moy[0][4][cl].re*T[0][4].re+icoh_moy[0][4][cl].im*T[0][4].im)
  +2*(icoh_moy[0][5][cl].re*T[0][5].re+icoh_moy[0][5][cl].im*T[0][5].im)
  +2*(icoh_moy[1][2][cl].re*T[1][2].re+icoh_moy[1][2][cl].im*T[1][2].im)
  +2*(icoh_moy[1][3][cl].re*T[1][3].re+icoh_moy[1][3][cl].im*T[1][3].im)
  +2*(icoh_moy[1][4][cl].re*T[1][4].re+icoh_moy[1][4][cl].im*T[1][4].im)
  +2*(icoh_moy[1][5][cl].re*T[1][5].re+icoh_moy[1][5][cl].im*T[1][5].im)
  +2*(icoh_moy[2][3][cl].re*T[2][3].re+icoh_moy[2][3][cl].im*T[2][3].im)
  +2*(icoh_moy[2][4][cl].re*T[2][4].re+icoh_moy[2][4][cl].im*T[2][4].im)
  +2*(icoh_moy[2][5][cl].re*T[2][5].re+icoh_moy[2][5][cl].im*T[2][5].im)
  +2*(icoh_moy[3][4][cl].re*T[3][4].re+icoh_moy[3][4][cl].im*T[3][4].im)
  +2*(icoh_moy[3][5][cl].re*T[3][5].re+icoh_moy[3][5][cl].im*T[3][5].im)
  +2*(icoh_moy[4][5][cl].re*T[4][5].re+icoh_moy[4][5][cl].im*T[4][5].im);
  if(dist<min) {
   min = dist;
   r = cl;
   }
  }
 return(r);
}


