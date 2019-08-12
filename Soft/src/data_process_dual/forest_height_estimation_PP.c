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

File  : forest_height_estimation.c
Project  : ESA_POLSARPRO
Authors  : Stefan SAUER
Version  : 2.0
Creation : 08/2005
Update  : 08/2012
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

Description :  Tree height, underlying topograhy (PHI_0) estimation
               and validity mask

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

/* CONSTANTS  */
#define Npolar 36
#define nparam_out 2
#define HvMax 50
#define SigmaMax 10
#define NN 7

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"

void line_fit_v2(cplx **cc_array,float *line_const,float *line_slope,float *line_chisq,int elf,int Ncol);
void Look_Up_RV1(float *height,float *sigma,float kappa_z,int hv_samples,int sigma_samples);
void Look_Up_Sinc(float *height,float kappa_z,int hv_samples);

cplx LU_Table[SigmaMax][HvMax];
float LU_Table_Sinc[HvMax];
float sigma_matrix[SigmaMax][HvMax];
float height_matrix[SigmaMax][HvMax];
cplx AAA[SigmaMax][HvMax];
float BBB[SigmaMax][HvMax];

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{

  /* Open the input-files */

  FILE *file_kz;
  FILE *file_opt1, *file_opt2;
  FILE *file_ch1, *file_ch2;
  FILE *file_pauli1, *file_pauli2;

  FILE *outPut_file0,*outPut_file1,*outPut_file2;
  char filename[FilePathLength];
  float *header;

/* Internal variables */
  int i,j,iii,jjj;
  int pos, pos_sinc;
  float sigma_ttt[SigmaMax],mean_kz1dim,hv_max,hv_samples;
  float flt_dum1,flt_dum2;
  float aux,aux_1,ddd_xv_1[NN],aux_2,ddd_xv_2[NN];
  float aux_sinc;
  cplx cplx_dum;
  cplx ccc_x0_1,ccc_v0_1;
  cplx ccc_x0_2,ccc_v0_2;
  
/* Matrix arrays */
  cplx *opt1,*opt2;
  cplx *ch1,*ch2;
  cplx *pauli1,*pauli2;
  cplx **coh_org,**coh_rot,*ppp;
  cplx *ccc_x1,*ccc_x2;
  cplx **LU_Table_1;
  cplx **LU_Table_2;
  float *kz;
  float *line_const,*line_slope,*line_chisq,*ppp_rot;
  float **int_xxx,**int_yyy;
  float *height_ttt;
  float *val_mask;
  float **ddd_lu_1;
  float **ddd_lu_2;
  float *ppp_x0e;
  float *hhh_est;
/* Line Fit */
  float *ss_x,*ss_y;
  float **ttt,*bbb,*st2,**yfit;

/* Strings */
  char in_dir[FilePathLength], out_dir[FilePathLength], File_kz[FilePathLength];
/* Input variables */
  int CohAvgFlag;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nforest_height_estimation.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-kz  	input kz file\n");
strcat(UsageHelp," (int)   	-avg 	coherence average flag (1/0)\n");
strcat(UsageHelp," (int)   	-nr  	Number of Row\n");
strcat(UsageHelp," (int)   	-nc  	Number of Col\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 13) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-kz",str_cmd_prm,File_kz,1,UsageHelp);
  get_commandline_prm(argc,argv,"-avg",int_cmd_prm,&CohAvgFlag,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nr",int_cmd_prm,&Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nc",int_cmd_prm,&Ncol,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_dir(out_dir);
  check_file(File_kz);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

  /* Array Initialisation */
  coh_org= cplx_matrix(Ncol,NN);
  coh_rot= cplx_matrix(Ncol,NN);
  ppp= cplx_vector(Ncol);
  header= vector_float(2*Ncol*Nlig);
  line_const= vector_float(Ncol);
  line_slope= vector_float(Ncol);
  line_chisq= vector_float(Ncol);
  ppp_rot= vector_float(Ncol);
  int_xxx= matrix_float(Ncol,2);
  int_yyy= matrix_float(Ncol,2);
  ccc_x1= cplx_vector(Ncol);
  ccc_x2= cplx_vector(Ncol);
  val_mask= vector_float(Ncol);
  ppp_x0e= vector_float(Ncol);
  hhh_est= vector_float(Ncol);
  opt1= cplx_vector(Ncol);
  opt2= cplx_vector(Ncol);
  ch1= cplx_vector(Ncol);
  ch2= cplx_vector(Ncol);
  pauli1= cplx_vector(Ncol);
  pauli2= cplx_vector(Ncol);
  kz= vector_float(Ncol);
/* Line Fit */
  ss_x= vector_float(Ncol);
  ss_y= vector_float(Ncol);
  bbb= vector_float(Ncol);
  st2= vector_float(Ncol);
  ttt= matrix_float(Ncol,NN);
  yfit= matrix_float(Ncol,NN);
  
  LU_Table_1= cplx_matrix(SigmaMax,HvMax);
  ddd_lu_1= matrix_float(SigmaMax,HvMax);
  LU_Table_2= cplx_matrix(SigmaMax,HvMax);
  ddd_lu_2= matrix_float(SigmaMax,HvMax);

/********************************************************************
********************************************************************/

  /* Open the input-files */

  /* OPT1 */
  sprintf(filename, "%scmplx_coh_Opt1.bin", in_dir);
  if (CohAvgFlag != 0) sprintf(filename, "%scmplx_coh_avg_Opt1.bin", in_dir);
  if ((file_opt1 = fopen(filename, "rb")) == NULL) edit_error("Could not open input file : ", filename);

  /* OPT2 */
  sprintf(filename, "%scmplx_coh_Opt2.bin", in_dir);
  if (CohAvgFlag != 0) sprintf(filename, "%scmplx_coh_avg_Opt2.bin", in_dir);
  if ((file_opt2 = fopen(filename, "rb")) == NULL) edit_error("Could not open input file : ", filename);

  /* ch1 */
  sprintf(filename, "%scmplx_coh_Ch1.bin", in_dir);
  if (CohAvgFlag != 0) sprintf(filename, "%scmplx_coh_avg_Ch1.bin", in_dir);
  if ((file_ch1 = fopen(filename, "rb")) == NULL) edit_error("Could not open input file : ", filename);

  /* ch2 */
  sprintf(filename, "%scmplx_coh_Ch2.bin", in_dir);
  if (CohAvgFlag != 0) sprintf(filename, "%scmplx_coh_avg_Ch2.bin", in_dir);
  if ((file_ch2 = fopen(filename, "rb")) == NULL) edit_error("Could not open input file : ", filename);

  /* PAULI1 */
  sprintf(filename, "%scmplx_coh_Ch1pCh2.bin", in_dir);
  if (CohAvgFlag != 0) sprintf(filename, "%scmplx_coh_avg_Ch1pCh2.bin", in_dir);
  if ((file_pauli1 = fopen(filename, "rb")) == NULL) edit_error("Could not open input file : ", filename);

  /* PAULI2 */
  sprintf(filename, "%scmplx_coh_Ch1mCh2.bin", in_dir);
  if (CohAvgFlag != 0) sprintf(filename, "%scmplx_coh_avg_Ch1mCh2.bin", in_dir);
  if ((file_pauli2 = fopen(filename, "rb")) == NULL) edit_error("Could not open input file : ", filename);

  /* KZ */
  sprintf(filename, "%s", File_kz);
  if ((file_kz = fopen(filename, "rb")) == NULL) edit_error("Could not open input file : ", filename);

  /* Open the output files */
  sprintf(filename, "%sheight.bin", in_dir);
  if ((outPut_file0 = fopen(filename, "wb")) == NULL) edit_error("Could not open input file : ", filename);
  sprintf(filename, "%sphi_0.bin", in_dir);
  if ((outPut_file1 = fopen(filename, "wb")) == NULL) edit_error("Could not open input file : ", filename);
  sprintf(filename, "%smask.bin", in_dir);
  if ((outPut_file2 = fopen(filename, "wb")) == NULL) edit_error("Could not open input file : ", filename);

/********************************************************************
********************************************************************/

  /* Calculate */

  /* LU-Table Generation */
  sigma_ttt[0]= 0.01/8.68; sigma_ttt[1]= 0.1/8.68; sigma_ttt[2]= 0.2/8.68;
  sigma_ttt[3]= 0.3/8.68; sigma_ttt[4]= 0.4/8.68; sigma_ttt[5]= 0.5/8.68;
  sigma_ttt[6]= 0.65/8.68; sigma_ttt[7]= 0.80/8.68; sigma_ttt[8]= 1.0/8.68;
  sigma_ttt[9]= 1.4/8.68;

for (iii= 0; iii< Nlig; iii++) {
  PrintfLine(iii,Nlig);

  /* OPT1 */
  fread(header,sizeof(float),2*Ncol,file_opt1);
  for (i= 0; i< Ncol; i++) {
    opt1[i].re= header[2*i];
    opt1[i].im= header[2*i+1];
    }

  /* OPT2 */
  fread(header,sizeof(float),2*Ncol,file_opt2);
  for (i= 0; i< Ncol; i++) {
    opt2[i].re= header[2*i];
    opt2[i].im= header[2*i+1];
    }

  /* ch1 */
  fread(header,sizeof(float),2*Ncol,file_ch1);
  for (i= 0; i< Ncol; i++) {
    ch1[i].re= header[2*i];
    ch1[i].im= header[2*i+1];
    }

  /* ch2 */
  fread(header,sizeof(float),2*Ncol,file_ch2);
  for (i= 0; i< Ncol; i++) {
    ch2[i].re= header[2*i];
    ch2[i].im= header[2*i+1];
    }

  /* PAULI1 */
  fread(header,sizeof(float),2*Ncol,file_pauli1);
  for (i= 0; i< Ncol; i++) {
    pauli1[i].re= header[2*i];
    pauli1[i].im= header[2*i+1];
    }

  /* PAULI2 */
  fread(header,sizeof(float),2*Ncol,file_pauli2);
  for (i= 0; i< Ncol; i++) {
    pauli2[i].re= header[2*i];
    pauli2[i].im= header[2*i+1];
    }

  /* KZ */
  fread(&kz[0],sizeof(float),Ncol,file_kz);

  for (i= 0; i< Ncol; i++) {
    coh_org[i][0]= coh_rot[i][0]= opt1[i];
    coh_org[i][1]= coh_rot[i][1]= opt2[i];
    coh_org[i][3]= coh_rot[i][3]= ch2[i];
    coh_org[i][4]= coh_rot[i][4]= ch1[i];
    coh_org[i][5]= coh_rot[i][5]= pauli1[i];
    coh_org[i][6]= coh_rot[i][6]= pauli2[i];
    }

  /* Line Fit */

  cplx_dum.re = 1.0; cplx_dum.im = 0.0;
  for (i = 0; i < Ncol; i++) ppp[i] = cplx_dum;

  for (jjj= 0; jjj< 6; jjj++) {

    for (i= 0; i< Ncol; i++) {
      for (j= 0; j< NN; j++) {
        coh_rot[i][j]= cmul(coh_rot[i][j],ppp[i]);
        }
      }  

/******************************************************************************/
/*  line_fit_v2(coh_rot,line_const,line_slope,line_chisq,NN,Ncol);  */
/******************************************************************************/
    for (i= 0; i< Ncol; i++) {
      ss_x[i]= 0.0; ss_y[i]= 0.0;
      for (j= 0; j< NN; j++) {
        ss_x[i]+= coh_rot[i][j].re;
        ss_y[i]+= coh_rot[i][j].im;
        }
      }

    for (i= 0; i< Ncol; i++) {
      for (j= 0; j< NN; j++) {
        ttt[i][j]= coh_rot[i][j].re - ss_x[i] / ((float)NN+eps);
        }
      }

    for (i= 0; i< Ncol; i++) {
      bbb[i]= st2[i]= 0.0;
      for (j= 0; j< NN; j++) {
        bbb[i]+= (ttt[i][j] * coh_rot[i][j].im);
        st2[i]+= (ttt[i][j] * ttt[i][j]);
        }
      }

    for (i= 0; i< Ncol; i++) {
      line_slope[i]= bbb[i] / (st2[i]+eps);
      line_const[i]= (ss_y[i] - ss_x[i]*line_slope[i]) / ((float)NN+eps);
      }

    for (i= 0; i< Ncol; i++) {
      for (j= 0; j< NN; j++) {
        yfit[i][j]= bbb[i]*coh_rot[i][j].re + line_const[i];
        }
      }
    for (i= 0; i< Ncol; i++) {
      line_chisq[i]= 0.0;
      for (j= 0; j< NN; j++) {
        line_chisq[i]+= ((coh_rot[i][j].im - yfit[i][j])*(coh_rot[i][j].im - yfit[i][j]));
        }
      }
  
/******************************************************************************/
/******************************************************************************/

    for (i= 0; i< Ncol; i++) {
      ppp[i].re= cos(atan(-line_slope[i]));
      ppp[i].im= sin(atan(-line_slope[i]));
      }

    } /* for (jjj= 0; jjj< 6; jjj++) */

  for (i= 0; i< Ncol; i++) {
    cplx_dum= cmul(coh_org[i][0],cconj(coh_rot[i][0]));
    ppp_rot[i]= atan2(cplx_dum.im,cplx_dum.re);
    }

  /* Line Circle Intersections */

  for (i= 0; i< Ncol; i++) {
    flt_dum1= line_slope[i]*line_slope[i];
    flt_dum2= sqrt(line_slope[i]*line_slope[i]-line_const[i]*line_const[i]+1.0);
    int_xxx[i][0]= (-line_const[i]*line_slope[i]-flt_dum2) / (1.0+flt_dum1);
    int_xxx[i][1]= (-line_const[i]*line_slope[i]+flt_dum2) / (1.0+flt_dum1);

    int_yyy[i][0]= line_const[i]+line_slope[i]*int_xxx[i][0];
    int_yyy[i][1]= line_const[i]+line_slope[i]*int_xxx[i][1];

    ccc_x1[i].re= int_xxx[i][0]; ccc_x1[i].im= int_yyy[i][0];
    ccc_x2[i].re= int_xxx[i][1]; ccc_x2[i].im= int_yyy[i][1];
    }

  mean_kz1dim= 0.0;
  for (i= 0; i< Ncol; i++) mean_kz1dim+= kz[i];
  mean_kz1dim/= Ncol;

  if (fabs(2.0*pi/mean_kz1dim) < (float)HvMax)
    hv_max= fabs(2.0*pi/mean_kz1dim);
  else
    hv_max= (float)HvMax;

  hv_samples= (int) (floor(hv_max));
  height_ttt= vector_float(hv_samples);
  for (i= 0; i< hv_samples; i++) height_ttt[i]= i+1;

  for (i= 0; i< Ncol; i++) val_mask[i]= 1.0;
  
  for (jjj= 0; jjj< Ncol; jjj++) {

  /* First X Point */

    ccc_x0_1= ccc_x1[jjj];

    for (i= 0; i< NN; i++) {
      flt_dum1= coh_rot[jjj][i].re - ccc_x0_1.re;
      flt_dum1*= flt_dum1;
      flt_dum2= coh_rot[jjj][i].im - ccc_x0_1.im;
      flt_dum2*= flt_dum2;
      ddd_xv_1[i]= sqrt(flt_dum1 + flt_dum2);
      }

    aux= ddd_xv_1[0]; pos= 0;
    for (i= 1; i< NN; i++) {
      if (ddd_xv_1[i]> aux) {
        aux= ddd_xv_1[i]; pos= i;
        }
      }

  /* First Volume Point */
    ccc_v0_1= coh_rot[jjj][pos];

    Look_Up_RV1(height_ttt,sigma_ttt,kz[jjj],hv_samples,SigmaMax);

  /* Estimate the Height 4 First X Point */
    for (i= 0; i< SigmaMax; i++) {
      for (j= 0; j< hv_samples; j++) {
        LU_Table_1[i][j]= cmul(LU_Table[i][j],ccc_x1[jjj]);
        flt_dum1= LU_Table_1[i][j].re - ccc_v0_1.re;
        flt_dum1*= flt_dum1;
        flt_dum2= LU_Table_1[i][j].im - ccc_v0_1.im;
        flt_dum2*= flt_dum2;
        ddd_lu_1[i][j]= sqrt(flt_dum1 + flt_dum2);
        }
      }
  
    aux_1= ddd_lu_1[0][0];
    for (i= 0; i< SigmaMax; i++) {
      for (j= 0; j< hv_samples; j++) {
        if (ddd_lu_1[i][j]< aux_1) aux_1= ddd_lu_1[i][j];
        }
      }

  /* Second X Point */

    ccc_x0_2= ccc_x2[jjj];

    for (i= 0; i< NN; i++) {
      flt_dum1= coh_rot[jjj][i].re - ccc_x0_2.re;
      flt_dum1*= flt_dum1;
      flt_dum2= coh_rot[jjj][i].im - ccc_x0_2.im;
      flt_dum2*= flt_dum2;
      ddd_xv_2[i]= sqrt(flt_dum1 + flt_dum2);
      }

    aux= ddd_xv_2[0]; pos= 0;
    for (i= 1; i< NN; i++) {
      if (ddd_xv_2[i]> aux) {
        aux= ddd_xv_2[i]; pos= i;
        }
      }

  /* Second Volume Point */
    ccc_v0_2= coh_rot[jjj][pos];

  /* Estimate the Height 4 Second X Point */
    for (i= 0; i< SigmaMax; i++) {
      for (j= 0; j< hv_samples; j++) {
        LU_Table_2[i][j]= cmul(LU_Table[i][j],ccc_x2[jjj]);
        flt_dum1= LU_Table_2[i][j].re - ccc_v0_2.re;
        flt_dum1*= flt_dum1;
        flt_dum2= LU_Table_2[i][j].im - ccc_v0_2.im;
        flt_dum2*= flt_dum2;
        ddd_lu_2[i][j]= sqrt(flt_dum1 + flt_dum2);
        }
      }
  
    aux_2= ddd_lu_2[0][0];
    for (i= 0; i< SigmaMax; i++) {
      for (j= 0; j< hv_samples; j++) {
        if (ddd_lu_2[i][j]< aux_2) aux_2= ddd_lu_2[i][j];
        }
      }

    if (aux_1 < aux_2) {
      cplx_dum.re= cos(ppp_rot[jjj]);
      cplx_dum.im= sin(ppp_rot[jjj]);
      cplx_dum= cmul(cplx_dum,ccc_x1[jjj]);
      ppp_x0e[jjj]= atan2(cplx_dum.im,cplx_dum.re);
    
      Look_Up_Sinc(height_ttt,kz[jjj],hv_samples);
    
      aux_sinc= fabs(LU_Table_Sinc[0] - cmod(ccc_v0_1)); pos_sinc= 0;
      for (i= 1; i< hv_samples; i++) {
        if (aux_sinc> fabs(LU_Table_Sinc[i] - cmod(ccc_v0_1))) {
          aux_sinc= fabs(LU_Table_Sinc[i] - cmod(ccc_v0_1));
          pos_sinc= i;
          }
        }

      hhh_est[jjj]= height_ttt[pos_sinc];

      } else {
      cplx_dum.re= cos(ppp_rot[jjj]);
      cplx_dum.im= sin(ppp_rot[jjj]);
      cplx_dum= cmul(cplx_dum,ccc_x2[jjj]);
      ppp_x0e[jjj]= atan2(cplx_dum.im,cplx_dum.re);
    
      Look_Up_Sinc(height_ttt,kz[jjj],hv_samples);

      aux_sinc= fabs(LU_Table_Sinc[0] - cmod(ccc_v0_2)); pos_sinc= 0;
      for (i= 1; i< hv_samples; i++) {
        if (aux_sinc> fabs(LU_Table_Sinc[i] - cmod(ccc_v0_2))) {
          aux_sinc= fabs(LU_Table_Sinc[i] - cmod(ccc_v0_2));
          pos_sinc= i;
          }
        }
    
      hhh_est[jjj]= height_ttt[pos_sinc];
      }

    if ((aux_1 > 0.1) && (aux_2 > 0.1)) {
      ppp_x0e[jjj]= -999.0;
      hhh_est[jjj]= -999.0;
      val_mask[jjj]= 0.0;
      }

    } /* for (jjj= 0; jjj< Ncol; jjj++) */

  for (i= 0; i< Ncol; i++) ppp_x0e[i] = ppp_x0e[i] * 180.0 / pi;

  /* Output in File */
  fwrite(&hhh_est[0],sizeof(float),Ncol,outPut_file0);
  fwrite(&ppp_x0e[0],sizeof(float),Ncol,outPut_file1);
  fwrite(&val_mask[0],sizeof(float),Ncol,outPut_file2);

  } /* for (iii= 0; iii< Nlig; iii++) */

  fclose(outPut_file0);
  fclose(outPut_file1);
  fclose(outPut_file2);

  /* THIS IS THE END */

  return 0;
}

/*******************************************************************/
/*******************************************************************/
/*        LOCAL ROUTINES          */
/*******************************************************************/
/*******************************************************************/
void Look_Up_RV1(float *height,float *sigma,float kappa_z,int hv_samples,int sigma_samples)
{
  int i,j;
  cplx cplx_dum1,cplx_dum2;
  float flt_dum1,flt_dum2;

  for (i= 0; i< sigma_samples; i++) {
    for (j= 0; j< hv_samples; j++) {  
      sigma_matrix[i][j]= sigma[i];
      height_matrix[i][j]= height[j];
      }
    }

  for (i= 0; i< sigma_samples; i++) {
    for (j= 0; j< hv_samples; j++) {
      flt_dum1= height_matrix[i][j]/2.0 * sigma_matrix[i][j];
      flt_dum2= height_matrix[i][j]/2.0 * kappa_z;

      cplx_dum1.re= exp(flt_dum1) * cos(flt_dum2);
      cplx_dum1.im= exp(flt_dum1) * sin(flt_dum2);

      cplx_dum2.re= height_matrix[i][j]/2.0 * kappa_z;
      cplx_dum2.im= height_matrix[i][j]/2.0 * -sigma_matrix[i][j];

      cplx_dum2= cplx_sinc(cplx_dum2);

      AAA[i][j]= cmul(cplx_dum1,cplx_dum2);

      flt_dum1= exp(sigma_matrix[i][j]*height_matrix[i][j]) - 1.0;
      flt_dum2= sigma_matrix[i][j]*height_matrix[i][j] + eps;
      BBB[i][j]= flt_dum1 / flt_dum2;

      LU_Table[i][j].re= AAA[i][j].re / (BBB[i][j]+eps);
      LU_Table[i][j].im= AAA[i][j].im / (BBB[i][j]+eps);
      }
    }
}

/*******************************************************************/
/*******************************************************************/
void Look_Up_Sinc(float *height,float kappa_z,int hv_samples)
{
  int i;
  float flt_dum;

  for (i= 0; i< hv_samples; i++) {
  flt_dum= kappa_z * height[i] / 2.0;
  LU_Table_Sinc[i]= fabs(sin(flt_dum) / (flt_dum+eps));
  }
}
