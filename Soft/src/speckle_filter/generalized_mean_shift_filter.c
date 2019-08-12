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

File   : generalized_mean_shift_filter.c
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

Description :  Generalized Mean Shift speckle filter
               
*--------------------------------------------------------------------
Adapted from c routine "generalized_mean_shift_filter_T3.c"
written by : Fengkai Lang 
Mean-Shift-Based Speckle Filtering of Polarimetric SAR Data
IEEE TGRS vol 52, n°7, july 2014
Fengkai Lang (1,2), Jie Yang (2), Deren Li (2), Lei Shi (2), Jujie Wei (2,3)
(1).School of Environment Science and Spatial Informatics, China
    University of Mining and Technology (CUMT), China
(2).State Key Laboratory of Information Engineering in Surveying,
    Mapping, and Remote Sensing (LIESMARS), Wuhan University, China
(3).Satellite Surveying and Mapping Application Center, NASG, China

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

/* FUNCTIONS */
#define GAUSS_INCREMENT ((GAUSS_LIMIT)/(NUM_ELEMENTS))
#define ZeroMemory(Destination,Length) memset((Destination),0,(Length))

/* ALIASES  */
//kernel flag
#define Kernel_Flat 0
#define Kernel_Epan 1
#define Kernel_Gauss 2

//center pixel estimation methods
#define CE_NONE 0
#define CE_MEAN 1
#define CE_MMSE 2
#define CE_MEAN_MS  3 //Mean+Meanshift
#define CE_MMSE_MS  4 //MMSE+Meanshift

/* CONSTANTS  */
#define InitMax 1.0e30f
#define nMaxIter 4
#define FLAT_LIMIT 1.0f
#define EPAN_LIMIT 1.0f
#define GAUSS_LIMIT 1.0f
#define NUM_ELEMENTS  100

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"
float GetWeight(float* weightList, float xmod2, int flagkernel /*=Kernel_Gauss*/, float limit /*=3.0f*/);
void EstCenter(float *center, int nCWin, int nLook, float ***mData, int nLig, int nCol, int lig, int col, int nDim, float *mHxi, float * weightList, int flagSK /*=Kernel_Gauss*/, int flagRK /*=Kernel_Gauss*/, int flagCE/*=CE_MMSE*/);
void MMSE(float *center, float ***mData, int nDim, int height, int width, int lig, int col, int nLook, int nWin/*=3*/);
void Mean(float *center, float ***mData, int nDim, int height, int width, int lig, int col, int nWin/*=3*/);
void MeanShift_UH(float *center, float ***mData, int nDim, int height, int width, int lig, int col, float * weightList, float* sigma, int nWin/*=5*/, int flagSK /*=Kernel_Gauss*/, int flagRK /*=Kernel_Gauss*/);

int NINPUT, NT2MOD, NT3MOD, NT4MOD, NOFFDIAG;

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{

#define NPolType 11
/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = {
    "S2C3", "S2C4", "S2T3", "S2T4", "C2", "C3",
    "C4", "T2", "T3", "T4", "SPP"};
  
/* Internal variables */
  int ii, lig, col, k, l;
  int ligDone = 0;

/* Input variables */
  int nLook;       /* Input data number of looks */
  int nWin;        /* Filter window width */
  int nLig, nCol;  /* image number of lines and rows */
  int nCWin;       /* Center pixel estimating window */
  float fCT;       /* Convergence Threshold, usually set 0.001-0.1 */
  float fSigma;    /* sigma: 5/6/7/8/9 */
  int flag_space_kernel; /*space kernel flag*/
  int flag_range_kernel; /*range kernel flag*/
  int flagCE;      /* Center pixel estimation method */
  float fGamma;    /* gamma in gauss kernel */
  float fLimitS;   /* space limit */
  float fLimitR;   /* range limit */

  /* Internal variables */
  float A1,A2,sigmaV,sigmaV0;
  float tt;
  int ninit;
  float curx,cury;
  float newx;
  float newy;
  float *fA;
  float * weightList;
  float se;
  float total_weight=0.f;
  float temp_x=0.f, temp_y=0.f;
  float biasx, biasy;
  float smod2, rmod2;
  float weight;
  
/* Matrix arrays */
  float ***M_in;
  float ***M_out;
  float **fHxi; /* bandwidth */
  float *mh;
  float *total_value;
  float *centervalue;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ngeneralized_mean_shift_filter.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)  -id    input directory\n");
strcat(UsageHelp," (string)  -od    output directory\n");
strcat(UsageHelp," (string)  -iodf  input-output data format\n");
strcat(UsageHelp," (int)     -nlk   Nlook\n");
strcat(UsageHelp," (int)     -nw    Nwin\n");
strcat(UsageHelp," (int)     -ncw   Center pixel estimating window\n");
strcat(UsageHelp," (float)   -ct    Convergence Threshold, usually set 0.001-0.1\n");
strcat(UsageHelp," (float)   -sig   sigma: 5/6/7/8/9\n");
strcat(UsageHelp," (int)     -sk    space kernel flag\n");
strcat(UsageHelp," (int)     -rk    range kernel flag\n");
strcat(UsageHelp," (int)     -ce    Center pixel estimation method\n");
strcat(UsageHelp," (float)   -gam   gamma in gauss kernel\n");
strcat(UsageHelp," (float)   -ls    space limit\n");
strcat(UsageHelp," (float)   -lr    range limit \n");
strcat(UsageHelp," (int)     -ofr   Offset Row\n");
strcat(UsageHelp," (int)     -ofc   Offset Col\n");
strcat(UsageHelp," (int)     -fnr   Final Number of Row\n");
strcat(UsageHelp," (int)     -fnc   Final Number of Col\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)  -mask  mask file (valid pixels)\n");
strcat(UsageHelp," (noarg)   -help  displays this message\n");
strcat(UsageHelp," (noarg)   -data  displays the help concerning Data Format parameter\n");

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

if(argc < 37) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nlk",int_cmd_prm,&nLook,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nw",int_cmd_prm,&nWin,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ncw",int_cmd_prm,&nCWin,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ct",flt_cmd_prm,&fCT,1,UsageHelp);
  get_commandline_prm(argc,argv,"-sig",flt_cmd_prm,&fSigma,1,UsageHelp);
  get_commandline_prm(argc,argv,"-sk",int_cmd_prm,&flag_space_kernel,1,UsageHelp);
  get_commandline_prm(argc,argv,"-rk",int_cmd_prm,&flag_range_kernel,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ce",int_cmd_prm,&flagCE,1,UsageHelp);
  get_commandline_prm(argc,argv,"-gam",flt_cmd_prm,&fGamma,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ls",flt_cmd_prm,&fLimitS,1,UsageHelp);
  get_commandline_prm(argc,argv,"-lr",flt_cmd_prm,&fLimitR,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);

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

  nLig = Sub_Nlig;
  nCol = Sub_Ncol;
  
/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);

/* POLAR TYPE CONFIGURATION */
  if (strcmp(PolType,"SPP")==0) strcpy(PolType, "SPPC2");
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);

  file_name_in = matrix_char(NpolarIn,1024); 
  file_name_out = matrix_char(NpolarOut,1024); 
  
  if (NpolarOut == 4) {
    NOFFDIAG = 1;
    NINPUT = NpolarOut + NOFFDIAG;
    NT2MOD = 3;
    }
  if (NpolarOut == 9) {
    NOFFDIAG = 3;
    NINPUT = NpolarOut + NOFFDIAG;
    NT3MOD = 6;
    }
  if (NpolarOut == 16) {
    NOFFDIAG = 6;
    NINPUT = NpolarOut + NOFFDIAG;
    NT4MOD = 10;
    } 

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

/* OUTPUT FILE OPENING*/
  for (Np = 0; Np < NpolarOut; Np++)
    if ((out_datafile[Np] = fopen(file_name_out[Np], "wb")) == NULL)
      edit_error("Could not open input file : ", file_name_out[Np]);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  _VC_in = vector_float(2*Ncol);
  _VF_in = vector_float(Ncol);
  _MC_in = matrix_float(4,2*Ncol);
  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   

  Valid = matrix_float(Sub_Nlig, Sub_Ncol);

  M_in = matrix3d_float(NINPUT, Sub_Nlig, Ncol);
  M_out = matrix3d_float(NpolarOut, Sub_Nlig, Sub_Ncol);

/*
  fHxi = matrix_float(2, NINPUT);
  mh = vector_float(NINPUT);
  total_value = vector_float(NINPUT);
  centervalue = vector_float(NINPUT);
  fA = vector_float(2);
  
  for (Np = 0; Np < NINPUT; Np++) {
    mh[Np] = 0.f;
    total_value[Np] = 0.f;
    }
*/
/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
#pragma omp parallel for private(col)
    for (lig = 0; lig < Sub_Nlig; lig++) 
      for (col = 0; col < Sub_Ncol; col++) 
        Valid[lig][col] = 1.;

/********************************************************************
********************************************************************/
  if (nLook <= 0) nLook = 1;
  if (nLook > 4) nLook = 4;
/* Sigma range calculation parameters */
  if (nLook == 1) {
    if (fSigma == 5 ) { A1 = 0.436f; A2 = 1.920f; sigmaV = 0.4057f; }
    if (fSigma == 6 ) { A1 = 0.343f; A2 = 2.210f; sigmaV = 0.4954f; }
    if (fSigma == 7 ) { A1 = 0.254f; A2 = 2.582f; sigmaV = 0.5911f; }
    if (fSigma == 8 ) { A1 = 0.168f; A2 = 3.094f; sigmaV = 0.6966f; }
    if (fSigma == 9 ) { A1 = 0.084f; A2 = 3.941f; sigmaV = 0.8191f; }
    }
  if (nLook == 2) {
    if (fSigma == 5 ) { A1 = 0.582f; A2 = 1.584f; sigmaV = 0.2763f; }
    if (fSigma == 6 ) { A1 = 0.501f; A2 = 1.755f; sigmaV = 0.3388f; }
    if (fSigma == 7 ) { A1 = 0.418f; A2 = 1.972f; sigmaV = 0.4062f; }
    if (fSigma == 8 ) { A1 = 0.327f; A2 = 2.260f; sigmaV = 0.4810f; }
    if (fSigma == 9 ) { A1 = 0.221f; A2 = 2.744f; sigmaV = 0.5699f; }
    }
  if (nLook == 3) {
    if (fSigma == 5 ) { A1 = 0.652f; A2 = 1.458f; sigmaV = 0.2222f; }
    if (fSigma == 6 ) { A1 = 0.580f; A2 = 1.586f; sigmaV = 0.2736f; }
    if (fSigma == 7 ) { A1 = 0.505f; A2 = 1.751f; sigmaV = 0.3280f; }
    if (fSigma == 8 ) { A1 = 0.419f; A2 = 1.965f; sigmaV = 0.3892f; }
    if (fSigma == 9 ) { A1 = 0.313f; A2 = 2.320f; sigmaV = 0.4624f; }
    }
  if (nLook == 4) {
    if (fSigma == 5 ) { A1 = 0.694f; A2 = 1.385f; sigmaV = 0.1921f; }
    if (fSigma == 6 ) { A1 = 0.630f; A2 = 1.495f; sigmaV = 0.2348f; }
    if (fSigma == 7 ) { A1 = 0.560f; A2 = 1.627f; sigmaV = 0.2825f; }
    if (fSigma == 8 ) { A1 = 0.480f; A2 = 1.804f; sigmaV = 0.3354f; }
    if (fSigma == 9 ) { A1 = 0.378f; A2 = 2.094f; sigmaV = 0.3991f; }
    }
  sigmaV0 = sigmaV; sigmaV = sigmaV0; //to avoid warning on variable

/* Create WeightList for Gauss kernel */
  if (flag_space_kernel == Kernel_Gauss || flag_range_kernel == Kernel_Gauss)
  {
    weightList = vector_float(NUM_ELEMENTS);
    for(k = 0; k < NUM_ELEMENTS; k++)
    {
      weightList[k] = exp(-(float)(k)*GAUSS_INCREMENT*fGamma);
    }
  }

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

  if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {

    if (strcmp(PolTypeIn,"S2")==0) {
      read_block_S2_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, 0, 1, Sub_Nlig, Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
      } else {
      read_block_SPP_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, 0, 1, Sub_Nlig, Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
      }

    } else {

    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, 0, 1, Sub_Nlig, Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    }

  ligDone = 0;
#pragma omp parallel for private(col) shared(ligDone) schedule(dynamic)
  for (lig = 0; lig < Sub_Nlig; lig++) {
	ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (NpolarOut == 4) {
        M_in[X212][lig][col] = sqrt(M_in[X212_re][lig][col]*M_in[X212_re][lig][col]+M_in[X212_im][lig][col]*M_in[X212_im][lig][col]);
        }
      if (NpolarOut == 9) {
        M_in[X312][lig][col] = sqrt(M_in[X312_re][lig][col]*M_in[X312_re][lig][col]+M_in[X312_im][lig][col]*M_in[X312_im][lig][col]);
        M_in[X313][lig][col] = sqrt(M_in[X313_re][lig][col]*M_in[X313_re][lig][col]+M_in[X313_im][lig][col]*M_in[X313_im][lig][col]);
        M_in[X323][lig][col] = sqrt(M_in[X323_re][lig][col]*M_in[X323_re][lig][col]+M_in[X323_im][lig][col]*M_in[X323_im][lig][col]);
        }
      if (NpolarOut == 16) {
        M_in[X412][lig][col] = sqrt(M_in[X412_re][lig][col]*M_in[X412_re][lig][col]+M_in[X412_im][lig][col]*M_in[X412_im][lig][col]);
        M_in[X413][lig][col] = sqrt(M_in[X413_re][lig][col]*M_in[X413_re][lig][col]+M_in[X413_im][lig][col]*M_in[X413_im][lig][col]);
        M_in[X414][lig][col] = sqrt(M_in[X414_re][lig][col]*M_in[X414_re][lig][col]+M_in[X414_im][lig][col]*M_in[X414_im][lig][col]);
        M_in[X423][lig][col] = sqrt(M_in[X423_re][lig][col]*M_in[X423_re][lig][col]+M_in[X423_im][lig][col]*M_in[X423_im][lig][col]);
        M_in[X424][lig][col] = sqrt(M_in[X424_re][lig][col]*M_in[X424_re][lig][col]+M_in[X424_im][lig][col]*M_in[X424_im][lig][col]);
        M_in[X434][lig][col] = sqrt(M_in[X434_re][lig][col]*M_in[X434_re][lig][col]+M_in[X434_im][lig][col]*M_in[X434_im][lig][col]);
        }
      }
    } // lig

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, 0, 1, Sub_Nlig, Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  ligDone = 0;
#pragma omp parallel for private(col,ninit,newx,newy,se,curx,cury,total_weight,temp_x,temp_y,k,l,biasx,biasy,smod2,rmod2,tt,weight,Np,fA,mh,centervalue,total_value,fHxi) shared(ligDone) schedule(dynamic)
  for (lig = 0; lig < Sub_Nlig; lig++) {
	ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    fHxi = matrix_float(2, NINPUT);
    mh = vector_float(NINPUT);
    total_value = vector_float(NINPUT);
    centervalue = vector_float(NINPUT);
    fA = vector_float(2);
    for (Np = 0; Np < NINPUT; Np++) {
      mh[Np] = 0.f;
      total_value[Np] = 0.f;
      }
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        ninit=0; 
        newx = (float)col;
        newy = (float)lig;
        fA[0]=A1;
        fA[1]=A2;
        for (k=0; k<NINPUT; k++)
        {
          mh[k]=0.f;
        }
        EstCenter(mh,nCWin,nLook,M_in,nLig,nCol,lig,col,NINPUT,fA,weightList,flag_space_kernel,flag_range_kernel,flagCE);
        se = InitMax;
        while (se>=fCT*fCT && ninit<nMaxIter) 
        {
          curx = newx;
          cury = newy;
          for (Np=0; Np<NINPUT; Np++)
          {
            centervalue[Np] = mh[Np];
          }
          ninit++;
          total_weight=0.f;
          for (k=0; k<NINPUT; k++)
          {
            total_value[k]=0.f;
          }
          temp_x=0.f;
          temp_y=0.f;

          for (Np=0; Np<NINPUT; Np++)
          {
            fHxi[0][Np] = mh[Np]*(1-A1);
            fHxi[1][Np] = mh[Np]*(A2-1);
          }
          
          for (k=-nWin; k<=nWin; k++)
          {
            for (l=-nWin; l<=nWin; l++)
            {
              if ((int)(cury+0.5)+k<0 || (int)(cury+0.5)+k>=nLig || (int)(curx+0.5)+l<0 || (int)(curx+0.5)+l>=nCol)
              {
                continue;
              }
              biasx=(int)(curx+0.5)+l-curx;
              biasy=(int)(cury+0.5)+k-cury;
              smod2 = (biasx*biasx+biasy*biasy)/(int)(nWin*nWin);
              
              rmod2 = 0;
              if (NpolarOut == 4)
              {
                tt = centervalue[X211]-M_in[X211][((int)(cury+0.5)+k)][(int)(curx+0.5)+l];
                rmod2 += pow(tt / (tt>0?fHxi[0][X211]:fHxi[1][X211]), 2);
                tt = centervalue[X222]-M_in[X222][((int)(cury+0.5)+k)][(int)(curx+0.5)+l];
                rmod2 += pow(tt / (tt>0?fHxi[0][X222]:fHxi[1][X222]), 2);
                for (Np=0; Np<1; Np++)
                {
                  tt = centervalue[Np+NpolarOut]-M_in[Np+NpolarOut][((int)(cury+0.5)+k)][(int)(curx+0.5)+l];
                  rmod2 += pow(tt / (tt>0?fHxi[0][Np+NpolarOut]:fHxi[1][Np+NpolarOut]), 2);
                }
              }
              if (NpolarOut == 9)
              {
                tt = centervalue[X311]-M_in[X311][((int)(cury+0.5)+k)][(int)(curx+0.5)+l];
                rmod2 += pow(tt / (tt>0?fHxi[0][X311]:fHxi[1][X311]), 2);
                tt = centervalue[X322]-M_in[X322][((int)(cury+0.5)+k)][(int)(curx+0.5)+l];
                rmod2 += pow(tt / (tt>0?fHxi[0][X322]:fHxi[1][X322]), 2);
                tt = centervalue[X333]-M_in[X333][((int)(cury+0.5)+k)][(int)(curx+0.5)+l];
                rmod2 += pow(tt / (tt>0?fHxi[0][X333]:fHxi[1][X333]), 2);
                for (Np=0; Np<3; Np++)
                {
                  tt = centervalue[Np+NpolarOut]-M_in[Np+NpolarOut][((int)(cury+0.5)+k)][(int)(curx+0.5)+l];
                  rmod2 += pow(tt / (tt>0?fHxi[0][Np+NpolarOut]:fHxi[1][Np+NpolarOut]), 2);
                }
              }
              if (NpolarOut == 16)
              {
                tt = centervalue[X411]-M_in[X411][((int)(cury+0.5)+k)][(int)(curx+0.5)+l];
                rmod2 += pow(tt / (tt>0?fHxi[0][X411]:fHxi[1][X411]), 2);
                tt = centervalue[X422]-M_in[X422][((int)(cury+0.5)+k)][(int)(curx+0.5)+l];
                rmod2 += pow(tt / (tt>0?fHxi[0][X422]:fHxi[1][X422]), 2);
                tt = centervalue[X433]-M_in[X433][((int)(cury+0.5)+k)][(int)(curx+0.5)+l];
                rmod2 += pow(tt / (tt>0?fHxi[0][X433]:fHxi[1][X433]), 2);
                tt = centervalue[X444]-M_in[X444][((int)(cury+0.5)+k)][(int)(curx+0.5)+l];
                rmod2 += pow(tt / (tt>0?fHxi[0][X444]:fHxi[1][X444]), 2);
                for (Np=0; Np<6; Np++)
                {
                  tt = centervalue[Np+NpolarOut]-M_in[Np+NpolarOut][((int)(cury+0.5)+k)][(int)(curx+0.5)+l];
                  rmod2 += pow(tt / (tt>0?fHxi[0][Np+NpolarOut]:fHxi[1][Np+NpolarOut]), 2);
                }
              }
              
              weight=GetWeight(weightList,smod2,flag_space_kernel,fLimitS)*GetWeight(weightList,rmod2,flag_range_kernel,fLimitR);
              total_weight += weight;
              for (Np=0; Np<NINPUT; Np++)
              {
                total_value[Np] += weight * M_in[Np][((int)(cury+0.5)+k)][(int)(curx+0.5)+l];
              }
              temp_x += weight*(curx+l);
              temp_y += weight*(cury+k);
            }
          }
          if (total_weight==0)
          {
            break; //
          }
          for (Np=0; Np<NINPUT; Np++)
          {
            mh[Np] = total_value[Np]/total_weight;
          }
          newx = (temp_x/total_weight);
          newy = (temp_y/total_weight);
          se=0.f;
          
          if (NpolarOut == 4)
          {
            se += pow(mh[X211]-centervalue[X211],2);
            se += pow(mh[X222]-centervalue[X222],2);
            for (Np=0; Np<1; Np++)
            {
              se += pow(mh[Np+NpolarOut]-centervalue[Np+NpolarOut],2);
            }
            se /= NT2MOD;
          }
          if (NpolarOut == 9)
          {
            se += pow(mh[X311]-centervalue[X311],2);
            se += pow(mh[X322]-centervalue[X322],2);
            se += pow(mh[X333]-centervalue[X333],2);
            for (Np=0; Np<3; Np++)
            {
              se += pow(mh[Np+NpolarOut]-centervalue[Np+NpolarOut],2);
            }
            se /= NT3MOD;
          }
          if (NpolarOut == 16)
          {
            se += pow(mh[X411]-centervalue[X411],2);
            se += pow(mh[X422]-centervalue[X422],2);
            se += pow(mh[X433]-centervalue[X433],2);
            se += pow(mh[X444]-centervalue[X444],2);
            for (Np=0; Np<6; Np++)
            {
              se += pow(mh[Np+NpolarOut]-centervalue[Np+NpolarOut],2);
            }
            se /= NT4MOD;
          }
        } // while
        
        for (Np=0; Np<NpolarOut; Np++) M_out[Np][lig][col] = mh[Np];

        } else {
        for (Np = 0; Np < NpolarOut; Np++) M_out[Np][lig][col] = 0.;
        }
      }
    free_matrix_float(fHxi,2);
    free_vector_float(mh);
    free_vector_float(total_value);
    free_vector_float(centervalue);
    free_vector_float(fA);
    } // lig
    
  write_block_matrix3d_float(out_datafile, NpolarOut, M_out, Sub_Nlig, Sub_Ncol, 0, 0, Sub_Ncol);

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0] + NwinL);

  free_matrix3d_float(M_in, NpolarOut, NligBlock[0] + NwinL);
  free_matrix3d_float(M_out, NpolarOut, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarOut; Np++) fclose(out_datafile[Np]);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);

/********************************************************************
********************************************************************/

  return 1;
}

/********************************************************************
********************************************************************/
/********************************************************************
********************************************************************/
/*********************************************************************
Routine  : GetWeight
Authors  : Fengkai Lang
Creation : 08/2014
Update   :
*---------------------------------------------------------------------
Description :  Get weight from the premade weightList
*---------------------------------------------------------------------
Inputs arguments :
Returned values  : float
*********************************************************************/
float GetWeight(float* weightList, float xmod2, int flagkernel, float limit)
{
  float weight;
  
  if(flagkernel == Kernel_Flat) //flat kernel
  {
    weight = xmod2>limit ? 0.f:1.f;
  }
  if(flagkernel == Kernel_Epan) //Epan kernel
  {
    weight = 1.f - 1.f/limit*xmod2;
    weight = my_max(weight,0);
  }
  else if (flagkernel == Kernel_Gauss) //gauss kernel
  {
    if (xmod2 >= limit*(NUM_ELEMENTS-0.5)/NUM_ELEMENTS) //GAUSS_LIMIT,xmod2>=2.985
    {
      return 0;
    }
    weight = weightList[(int)(xmod2*NUM_ELEMENTS/limit+0.5)];
  }
  
  return weight;
}

/*********************************************************************
Routine  : EstCenter
Authors  : Fengkai Lang
Creation : 08/2014
Update   :
*---------------------------------------------------------------------
Description :  Estimate the center pixel
*---------------------------------------------------------------------
Inputs arguments :
Returned values  : void
*********************************************************************/
void EstCenter(float *center, int nCWin, int nLook, float ***mData, int nLig, int nCol, int lig, int col, int nDim, float *mHxi, float * weightList, int flagSK, int flagRK, int flagCE)
{
  int i;
  switch (flagCE)
  {
    case CE_NONE:
    {
      for (i=0; i<nDim; i++)
      {
        center[i] = mData[i][lig][col];
      }
      break;
    }
    case CE_MEAN:
    {
      Mean(center,mData,nDim,nLig,nCol,lig,col,nCWin);
      break;
    }
    case CE_MMSE:
    {  
      MMSE(center,mData,nDim,nLig,nCol,lig,col,nLook,nCWin);
      break;
    }
    case CE_MEAN_MS:
    { 
      Mean(center,mData,nDim,nLig,nCol,lig,col,3);
      MeanShift_UH(center,mData,nDim,nLig,nCol,lig,col,weightList,mHxi,nCWin,flagSK,flagRK);
      break;
    }
    case CE_MMSE_MS:
    {
      MMSE(center,mData,nDim,nLig,nCol,lig,col,nLook,3);
      MeanShift_UH(center,mData,nDim,nLig,nCol,lig,col,weightList,mHxi,nCWin,flagSK,flagRK);
      break;
    }
//   default:
  }
}

/*********************************************************************
Routine  : MMSE
Authors  : Fengkai Lang
Creation : 08/2014
Update   :
*---------------------------------------------------------------------
Inputs arguments :
Returned values  : void
*********************************************************************/
void MMSE(float *center, float ***mData, int nDim, int height, int width, int lig, int col, int nLook, int nWin)
{
  int i,k,l;
  float sigmaV0 = 1.0f/sqrt(nLook);
  float mz2x2 = 0.f;
  float mx2x2;
  float varX2x2;
  float b2x2;
  float varZ2x2 = 0.f;

  float mz3x3 = 0.f;
  float mx3x3;
  float varX3x3;
  float b3x3;
  float varZ3x3 = 0.f;

  float mz4x4 = 0.f;
  float mx4x4;
  float varX4x4;
  float b4x4;
  float varZ4x4 = 0.f;

  if (nDim == 5)
  {
    for (k = -nWin/2; k <= nWin/2; k++) 
    {  
      for (l = -nWin/2; l <= nWin/2; l++) 
      {
        if (lig+k<0 || lig+k>=height || col+l<0 || col+l>=width)
        {
          continue;
        }
        mz2x2 += (mData[X211][(lig + k)][col + l]+mData[X222][(lig + k)][col + l]) / (nWin * nWin);
      }
    }
    for (k = -nWin/2; k <= nWin/2; k++) 
    {  
      for (l = -nWin/2; l <= nWin/2; l++) 
      {
        if (lig+k<0 || lig+k>=height || col+l<0 || col+l>=width)
        {
        continue;
        }
      varZ2x2 += pow((mData[X211][(lig + k)][col + l]+mData[X222][(lig + k)][col + l] - mz2x2),2);
      }
    }
    varZ2x2 /= nWin*nWin;
  
    varX2x2 = (varZ2x2 - (mz2x2*sigmaV0)*(mz2x2*sigmaV0)) / (1.f + sigmaV0*sigmaV0);
  
    if (varX2x2 <= 0.0) b2x2 = 0.0f;
    else b2x2 = varX2x2 / varZ2x2;
  
    for (i=0; i<nDim; i++)
    {
      mx2x2 = 0.f;
      for (k = -nWin/2; k <= nWin/2; k++) 
      {
        for (l = -nWin/2; l <= nWin/2; l++) 
        {
          if (lig+k<0 || lig+k>=height || col+l<0 || col+l>=width)
          {
          continue;
          }
        mx2x2 += (mData[i][(lig + k)][col + l]) / (nWin * nWin);
        }
      }
      center[i] = (1.f - b2x2)*mx2x2 + b2x2*mData[i][lig][col];
    }
  }

  if (nDim == 12)
  {
    for (k = -nWin/2; k <= nWin/2; k++) 
    {  
      for (l = -nWin/2; l <= nWin/2; l++) 
      {
        if (lig+k<0 || lig+k>=height || col+l<0 || col+l>=width)
        {
          continue;
        }
        mz3x3 += (mData[X311][(lig + k)][col + l]+mData[X322][(lig + k)][col + l]+mData[X333][(lig + k)][col + l]) / (nWin * nWin);
      }
    }
    for (k = -nWin/2; k <= nWin/2; k++) 
    {  
      for (l = -nWin/2; l <= nWin/2; l++) 
      {
        if (lig+k<0 || lig+k>=height || col+l<0 || col+l>=width)
        {
        continue;
        }
      varZ3x3 += pow((mData[X311][(lig + k)][col + l]+mData[X322][(lig + k)][col + l]+mData[X333][(lig + k)][col + l] - mz3x3),2);
      }
    }
    varZ3x3 /= nWin*nWin;
  
    varX3x3 = (varZ3x3 - (mz3x3*sigmaV0)*(mz3x3*sigmaV0)) / (1.f + sigmaV0*sigmaV0);
  
    if (varX3x3 <= 0.0) b3x3 = 0.0f;
    else b3x3 = varX3x3 / varZ3x3;
  
    for (i=0; i<nDim; i++)
    {
      mx3x3 = 0.f;
      for (k = -nWin/2; k <= nWin/2; k++) 
      {
        for (l = -nWin/2; l <= nWin/2; l++) 
        {
          if (lig+k<0 || lig+k>=height || col+l<0 || col+l>=width)
          {
          continue;
          }
        mx3x3 += (mData[i][(lig + k)][col + l]) / (nWin * nWin);
        }
      }
      center[i] = (1.f - b3x3)*mx3x3 + b3x3*mData[i][lig][col];
    }
  }

  if (nDim == 22)
  {
    for (k = -nWin/2; k <= nWin/2; k++) 
    {  
      for (l = -nWin/2; l <= nWin/2; l++) 
      {
        if (lig+k<0 || lig+k>=height || col+l<0 || col+l>=width)
        {
          continue;
        }
        mz4x4 += (mData[X411][(lig + k)][col + l]+mData[X422][(lig + k)][col + l]+mData[X433][(lig + k)][col + l]+mData[X444][(lig + k)][col + l]) / (nWin * nWin);
      }
    }
    for (k = -nWin/2; k <= nWin/2; k++) 
    {  
      for (l = -nWin/2; l <= nWin/2; l++) 
      {
        if (lig+k<0 || lig+k>=height || col+l<0 || col+l>=width)
        {
        continue;
        }
      varZ4x4 += pow((mData[X411][(lig + k)][col + l]+mData[X422][(lig + k)][col + l]+mData[X433][(lig + k)][col + l]+mData[X444][(lig + k)][col + l] - mz4x4),2);
      }
    }
    varZ4x4 /= nWin*nWin;
  
    varX4x4 = (varZ4x4 - (mz4x4*sigmaV0)*(mz4x4*sigmaV0)) / (1.f + sigmaV0*sigmaV0);
  
    if (varX4x4 <= 0.0) b4x4 = 0.0f;
    else b4x4 = varX4x4 / varZ4x4;
  
    for (i=0; i<nDim; i++)
    {
      mx4x4 = 0.f;
      for (k = -nWin/2; k <= nWin/2; k++) 
      {
        for (l = -nWin/2; l <= nWin/2; l++) 
        {
          if (lig+k<0 || lig+k>=height || col+l<0 || col+l>=width)
          {
          continue;
          }
        mx4x4 += (mData[i][(lig + k)][col + l]) / (nWin * nWin);
        }
      }
      center[i] = (1.f - b4x4)*mx4x4 + b4x4*mData[i][lig][col];
    }
  }
  
}

/*********************************************************************
Routine  : Mean
Authors  : Fengkai Lang
Creation : 08/2014
Update   :
*---------------------------------------------------------------------
Inputs arguments :
Returned values  : void
*********************************************************************/
void Mean(float *center, float ***mData, int nDim, int height, int width, int lig, int col, int nWin)
{
  int i,k,l;
  for (k=-nWin/2; k<=nWin/2; k++)
  {
    for (l=-nWin/2; l<=nWin/2; l++)
    {
      if (lig+k<0 || lig+k>=height || col+l<0 || col+l>=width)
      {
        continue;
      }
      for (i=0; i<nDim; i++)
      {
        center[i] += mData[i][(lig+k)][col+l];
      }
    }
  }
  for (i=0; i<nDim; i++)
  {
    center[i] /= nWin*nWin;
  }
}

/*********************************************************************
Routine  : MeanShift_UH
Authors  : Fengkai Lang
Creation : 08/2014
Update   :
*---------------------------------------------------------------------
Inputs arguments :
Returned values  : void
*********************************************************************/
void MeanShift_UH(float *center, float ***mData, int nDim, int height, int width, int lig, int col, float * weightList, float* sigma, int nWin, int flagSK, int flagRK)
{
  int i,k,l;
  float fHxi[2]={0.f};
  float curx = (float)col;
  float cury = (float)lig;
  float total_weight=0.f;
  float biasx, biasy;
  float smod2, rmod2;
  float weight;
  float tt;
  
  if (nDim == 5)
  {
    fHxi[0] += pow(center[X211]*(1-sigma[0]),2);
    fHxi[1] += pow(center[X211]*(sigma[1]-1),2);
    fHxi[0] += pow(center[X222]*(1-sigma[0]),2);
    fHxi[1] += pow(center[X222]*(sigma[1]-1),2);
    for (i=0; i<1; i++)
    {
      fHxi[0] += pow(center[i+4]*(1-sigma[0]),2);
      fHxi[1] += pow(center[i+4]*(sigma[1]-1),2);
    }
    fHxi[0] = sqrt(fHxi[0]/NT2MOD);
    fHxi[1] = sqrt(fHxi[1]/NT2MOD);
  }
  if (nDim == 12)
  {
    fHxi[0] += pow(center[X311]*(1-sigma[0]),2);
    fHxi[1] += pow(center[X311]*(sigma[1]-1),2);
    fHxi[0] += pow(center[X322]*(1-sigma[0]),2);
    fHxi[1] += pow(center[X322]*(sigma[1]-1),2);
    fHxi[0] += pow(center[X333]*(1-sigma[0]),2);
    fHxi[1] += pow(center[X333]*(sigma[1]-1),2);
    for (i=0; i<3; i++)
    {
      fHxi[0] += pow(center[i+9]*(1-sigma[0]),2);
      fHxi[1] += pow(center[i+9]*(sigma[1]-1),2);
    }
    fHxi[0] = sqrt(fHxi[0]/NT3MOD);
    fHxi[1] = sqrt(fHxi[1]/NT3MOD);
  }
  if (nDim == 22)
  {
    fHxi[0] += pow(center[X411]*(1-sigma[0]),2);
    fHxi[1] += pow(center[X411]*(sigma[1]-1),2);
    fHxi[0] += pow(center[X422]*(1-sigma[0]),2);
    fHxi[1] += pow(center[X422]*(sigma[1]-1),2);
    fHxi[0] += pow(center[X433]*(1-sigma[0]),2);
    fHxi[1] += pow(center[X433]*(sigma[1]-1),2);
    fHxi[0] += pow(center[X444]*(1-sigma[0]),2);
    fHxi[1] += pow(center[X444]*(sigma[1]-1),2);
    for (i=0; i<6; i++)
    {
      fHxi[0] += pow(center[i+16]*(1-sigma[0]),2);
      fHxi[1] += pow(center[i+16]*(sigma[1]-1),2);
    }
    fHxi[0] = sqrt(fHxi[0]/NT4MOD);
    fHxi[1] = sqrt(fHxi[1]/NT4MOD);
  }
  
  ZeroMemory(center,nDim*sizeof(float));

  for (k=-(int)nWin; k<=(int)nWin; k++)
  {
    for (l=-(int)nWin; l<=(int)nWin; l++)
    {
      if ((int)(cury+0.5)+k<0 || (int)(cury+0.5)+k>=height || (int)(curx+0.5)+l<0 || (int)(curx+0.5)+l>=width)
      {
        continue;
      }
      biasx=(int)(curx+0.5)+l-curx;
      biasy=(int)(cury+0.5)+k-cury;
      smod2 = (biasx*biasx+biasy*biasy)/(nWin*nWin);
      rmod2 = 0;
      
      if (nDim == 5)
      {
        tt = mData[X211][lig][col]-mData[X211][((int)(cury+0.5)+k)][(int)(curx+0.5)+l];
        rmod2 += pow(tt / (tt>0?fHxi[0]:fHxi[1]), 2);
        tt = mData[X222][lig][col]-mData[X222][((int)(cury+0.5)+k)][(int)(curx+0.5)+l];
        rmod2 += pow(tt / (tt>0?fHxi[0]:fHxi[1]), 2);
        for (i=0; i<1; i++)
        {
          tt = mData[i+4][lig][col]-mData[i+4][((int)(cury+0.5)+k)][(int)(curx+0.5)+l];
          rmod2 += pow(tt / (tt>0?fHxi[0]:fHxi[1]), 2);
        }
      }
      if (nDim == 12)
      {
        tt = mData[X311][lig][col]-mData[X311][((int)(cury+0.5)+k)][(int)(curx+0.5)+l];
        rmod2 += pow(tt / (tt>0?fHxi[0]:fHxi[1]), 2);
        tt = mData[X322][lig][col]-mData[X322][((int)(cury+0.5)+k)][(int)(curx+0.5)+l];
        rmod2 += pow(tt / (tt>0?fHxi[0]:fHxi[1]), 2);
        tt = mData[X333][lig][col]-mData[X333][((int)(cury+0.5)+k)][(int)(curx+0.5)+l];
        rmod2 += pow(tt / (tt>0?fHxi[0]:fHxi[1]), 2);
        for (i=0; i<3; i++)
        {
          tt = mData[i+9][lig][col]-mData[i+9][((int)(cury+0.5)+k)][(int)(curx+0.5)+l];
          rmod2 += pow(tt / (tt>0?fHxi[0]:fHxi[1]), 2);
        }
      }
      if (nDim == 22)
      {
        tt = mData[X411][lig][col]-mData[X411][((int)(cury+0.5)+k)][(int)(curx+0.5)+l];
        rmod2 += pow(tt / (tt>0?fHxi[0]:fHxi[1]), 2);
        tt = mData[X422][lig][col]-mData[X422][((int)(cury+0.5)+k)][(int)(curx+0.5)+l];
        rmod2 += pow(tt / (tt>0?fHxi[0]:fHxi[1]), 2);
        tt = mData[X433][lig][col]-mData[X433][((int)(cury+0.5)+k)][(int)(curx+0.5)+l];
        rmod2 += pow(tt / (tt>0?fHxi[0]:fHxi[1]), 2);
        tt = mData[X444][lig][col]-mData[X444][((int)(cury+0.5)+k)][(int)(curx+0.5)+l];
        rmod2 += pow(tt / (tt>0?fHxi[0]:fHxi[1]), 2);
        for (i=0; i<6; i++)
        {
          tt = mData[i+16][lig][col]-mData[i+16][((int)(cury+0.5)+k)][(int)(curx+0.5)+l];
          rmod2 += pow(tt / (tt>0?fHxi[0]:fHxi[1]), 2);
        }
      }
      
      weight=GetWeight(weightList,smod2,flagSK,3.0f)*GetWeight(weightList,rmod2,flagRK,3.0f);
      total_weight += weight;
      for (i=0; i<nDim; i++)
      {
        center[i] += weight * mData[i][((int)(cury+0.5)+k)][(int)(curx+0.5)+l];
      }
    }
  }
  if (total_weight==0)
  {
    for (i=0; i<nDim; i++)
    {
      center[i] = mData[i][lig][col];
    }
  }
  else
  {
    for (i=0; i<nDim; i++)
    {
      center[i] = center[i]/total_weight;
    }
  }
}
