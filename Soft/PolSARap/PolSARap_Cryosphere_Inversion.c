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

File  : PolSARap_Cryosphere_Inversion.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 10/2014
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

Description :  PolSARap Cryosphere Showcase - Inversion

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
int MedianFilteringGroundToVolumeRatio(float **M, int Nlig, int Ncol, int Nwin, int iteration, float threshold);
float MedianArrayCryo(float array[], int n);

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
  FILE *in_file_coh, *in_file_kz, *in_file_theta, *in_file_cohsnr;
  FILE *in_file_surfvol;
  FILE *out_file_kappa, *out_file_depth;
  char file_coh[FilePathLength], file_kz[FilePathLength], file_theta[FilePathLength];
  char file_cohsnr[FilePathLength], file_surfvol[FilePathLength];
  char file_name[FilePathLength];
  
/* Internal variables */
  char channel[2];

  int lig, col;
  int ligg, Nligg;
  int FlagCohSnr, FlagDr;
  int Unit, iteration, NwinMedian;

  float threshold, dielectric, Dr;
  float coh_surf, coh_snr;
  float coh_vol_re, coh_vol_im, coh_vol_mod;
  float theta_r_ice, kz_vol;
  
/* Matrix arrays */
  float **M_theta;
  float **M_surfvol;
  float **M_coh;
  float **M_kz;
  float **M_cohsnr;
  float **M_kappa;
  float **M_depth;
  
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nPolSARap_Cryosphere_Inversion.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-ikz 	input kz file\n");
strcat(UsageHelp," (string)	-ico 	input complex coherence file\n");
strcat(UsageHelp," (string)	-itt 	input theta file\n");
strcat(UsageHelp," (string)	-isv 	input surface to volume ratio file\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-ch  	channel (HH, HV, VV)\n");
strcat(UsageHelp," (int)   	-un  	Angle Unit (0: deg, 1: rad)\n");
strcat(UsageHelp," (float) 	-die 	ice dielectric constant\n");
strcat(UsageHelp," (float) 	-thr 	threshold\n");
strcat(UsageHelp," (int)   	-it  	number of iteration\n");
strcat(UsageHelp," (int)   	-nw  	Nwin Median filter\n");
strcat(UsageHelp," (int)   	-inc 	Initial Number of Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (float) 	-dr  	range pixel spacing (if not : Dr = -1)\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-snr 	input snr coherence file\n");
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
if(get_commandline_prm(argc,argv,"-data",no_cmd_prm,NULL,0,UsageHelpDataFormat)) {
  printf("\n Usage:\n%s\n",UsageHelpDataFormat); exit(1);
  }

if(argc < 35) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-ikz",str_cmd_prm,file_kz,1,UsageHelp);
  get_commandline_prm(argc,argv,"-itt",str_cmd_prm,file_theta,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ico",str_cmd_prm,file_coh,1,UsageHelp);
  get_commandline_prm(argc,argv,"-isv",str_cmd_prm,file_surfvol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ch",str_cmd_prm,channel,1,UsageHelp);
  get_commandline_prm(argc,argv,"-un",int_cmd_prm,&Unit,1,UsageHelp);
  get_commandline_prm(argc,argv,"-die",flt_cmd_prm,&dielectric,1,UsageHelp);
  get_commandline_prm(argc,argv,"-thr",flt_cmd_prm,&threshold,1,UsageHelp);
  get_commandline_prm(argc,argv,"-it",int_cmd_prm,&iteration,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nw",int_cmd_prm,&NwinMedian,1,UsageHelp);
  get_commandline_prm(argc,argv,"-inc",int_cmd_prm,&Ncol,1,UsageHelp);
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

  FlagCohSnr = 0;strcpy(file_cohsnr,"");
  get_commandline_prm(argc,argv,"-snr",str_cmd_prm,file_cohsnr,0,UsageHelp);
  if (strcmp(file_cohsnr,"") != 0) FlagCohSnr = 1;
  
  FlagDr = 0;
  get_commandline_prm(argc,argv,"-dr",flt_cmd_prm,&Dr,1,UsageHelp);
  if (Dr != -1.) FlagDr = 1;
  }

/********************************************************************
********************************************************************/

  check_file(file_kz);
  check_file(file_theta);
  check_file(file_coh);
  check_file(file_surfvol);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);
  if (FlagCohSnr == 1) check_file(file_cohsnr);
   
  NwinL = 1; NwinC = 1;
  
/* INPUT FILE OPENING*/
  if ((in_file_coh = fopen(file_coh, "rb")) == NULL)
    edit_error("Could not open input file : ", file_coh);

  if ((in_file_kz = fopen(file_kz, "rb")) == NULL)
    edit_error("Could not open input file : ", file_kz);

  if ((in_file_theta = fopen(file_theta, "rb")) == NULL)
    edit_error("Could not open input file : ", file_theta);
  
  if ((in_file_surfvol = fopen(file_surfvol, "rb")) == NULL)
    edit_error("Could not open input file : ", file_surfvol);

  if (FlagCohSnr == 1) 
    if ((in_file_cohsnr = fopen(file_cohsnr, "rb")) == NULL)
      edit_error("Could not open input file : ", file_cohsnr);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  sprintf(file_name, "%s%s%s%s", out_dir, "showcase_cryo_kappa_",channel,".bin");
  if ((out_file_kappa = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  
  sprintf(file_name, "%s%s%s%s", out_dir, "showcase_cryo_depth_",channel,".bin");
  if ((out_file_depth = fopen(file_name, "wb")) == NULL)
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

  /* Msurfvol = Sub_Nlig*Sub_Ncol */
  NBlockA += 0; NBlockB += Sub_Nlig*Sub_Ncol;
  /* Mcoh = Nlig*2*Sub_Ncol */
  NBlockA += 2*Sub_Ncol; NBlockB += 0;
  /* Mkz = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mtheta = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mkappa = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mdepth = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;

  if (FlagCohSnr == 1) {
    /* Mcohsnr = Nlig*Sub_Ncol */
    NBlockA += Sub_Ncol; NBlockB += 0;
    }
  
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

  M_surfvol = matrix_float(Sub_Nlig, Sub_Ncol);
  M_coh = matrix_float(NligBlock[0], 2*Sub_Ncol);
  M_kz = matrix_float(NligBlock[0], Sub_Ncol);
  M_theta = matrix_float(NligBlock[0], Sub_Ncol);
  M_kappa = matrix_float(NligBlock[0], Sub_Ncol);
  M_depth = matrix_float(NligBlock[0], Sub_Ncol);
  if (FlagCohSnr == 1) M_cohsnr = matrix_float(NligBlock[0], Sub_Ncol);

/********************************************************************
********************************************************************/

  read_block_matrix_float(in_file_surfvol, M_surfvol, 0, 1, Sub_Nlig, Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  MedianFilteringGroundToVolumeRatio(M_surfvol, Sub_Nlig, Sub_Ncol, NwinMedian, iteration, threshold);

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
ligg = 0; Nligg = 0;

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}
  read_block_matrix_float(in_file_kz, M_kz, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(in_file_theta, M_theta, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_cmplx(in_file_coh, M_coh, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  if (FlagCohSnr == 1) read_block_matrix_cmplx(in_file_cohsnr, M_cohsnr, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligg = lig + Nligg;
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        if (Unit == 0) M_theta[lig][col] = M_theta[lig][col]*pi/180.;
        if (FlagDr == 1) {
          coh_surf = 1. - (fabs(M_kz[lig][col]) * Dr * cos(M_theta[lig][col])) / (2.*pi);
          } else {
          coh_surf = 1.; 
          }
        if (FlagCohSnr == 1) {
          coh_snr = M_cohsnr[lig][col];
          } else {
          coh_snr = 1.; 
          }

        coh_vol_re = M_coh[lig][2*col] / coh_surf / coh_snr; 
        coh_vol_im = M_coh[lig][2*col+1] / coh_surf / coh_snr; 
        coh_vol_mod = sqrt(coh_vol_re*coh_vol_re+coh_vol_im*coh_vol_im);
        if (coh_vol_mod > 1.) coh_vol_mod = 0.f/0.f;

        theta_r_ice = asin(1/sqrt(dielectric) * sin(M_theta[lig][col]));
        kz_vol = M_kz[lig][col] * sqrt(dielectric) * (cos(M_theta[lig][col])/cos(theta_r_ice));
        
        M_kappa[lig][col] = cos(theta_r_ice)*fabs(kz_vol)*sqrt((M_surfvol[ligg][col]*M_surfvol[ligg][col] - coh_vol_mod*coh_vol_mod*(1.+M_surfvol[ligg][col])*(1.+M_surfvol[ligg][col]))/(coh_vol_mod*coh_vol_mod - 1.));
        M_kappa[lig][col] = M_kappa[lig][col] / (2.*(1.+M_surfvol[ligg][col]));
        
        if (M_kappa[lig][col] < 0.01) M_kappa[lig][col] = 0.f/0.f;
        if (M_kappa[lig][col] > 0.1) M_kappa[lig][col] = 0.f/0.f;

        M_depth[lig][col] = -cos(theta_r_ice)/M_kappa[lig][col];
        
        //kappa in dBm    
        M_kappa[lig][col] = M_kappa[lig][col] * 4.343;
        } else {
        M_kappa[lig][col] = 0.;
        M_depth[lig][col] = 0.;
        } // valid
      } // col
    } // lig
  Nligg += NligBlock[Nb];
  write_block_matrix_float(out_file_kappa, M_kappa, Sub_Nlig, Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_file_depth, M_depth, Sub_Nlig, Sub_Ncol, 0, 0, Sub_Ncol);
  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_vector_float(M_theta);
  free_matrix_float(Valid, NligBlock[0]);
  free_matrix_float(M_kz, NligBlock[0]);
  free_matrix_float(M_coh, NligBlock[0]);
  free_matrix_float(M_surfvol, NligBlock[0]);
  if (FlagCohSnr == 1) free_matrix_float(M_cohsnr, NligBlock[0]);
  free_matrix_float(M_kappa, NligBlock[0]);
  free_matrix_float(M_depth, NligBlock[0]);
  
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  if (FlagCohSnr == 1) fclose(in_file_cohsnr);
  fclose(in_file_kz);
  fclose(in_file_coh);
  fclose(in_file_theta);
  fclose(in_file_surfvol);

/* OUTPUT FILE CLOSING*/
  fclose(out_file_kappa);
  fclose(out_file_depth);
  
/********************************************************************
********************************************************************/

  return 1;
}

/********************************************************************
********************************************************************/
/********************************************************************
********************************************************************/
int MedianFilteringGroundToVolumeRatio(float **M, int Nlig, int Ncol, int Nwin, int iteration, float threshold)
{
  int ii, k, l, lig, col;
  int MinMaxNum, iter;
  int FlagMedian, Npts;
  int NwinMedian, NwinMedianMax;
  int NwinMedianM1S2, NwinMedianMaxM1S2;
  int NwinMedianP1S2, NwinMedianMaxP1S2;

/* Matrix arrays */
  float **M_filt;
  float **M_fillnan;
  
  int *MinMaxLig;
  int *MinMaxCol;
  float *datamedian;

  NwinMedian = Nwin;
  NwinMedianMax = NwinMedian*ceil(pow(2.,(float)iteration));
  if (NwinMedian & 1) {
    NwinMedianM1S2 = (NwinMedian - 1) / 2;
    NwinMedianP1S2 = (NwinMedian + 1) / 2;
    NwinMedianMaxM1S2 = (NwinMedianMax - 1) / 2;
    NwinMedianMaxP1S2 = (NwinMedianMax + 1) / 2;
    } else {
    NwinMedianM1S2 = NwinMedian / 2;
    NwinMedianP1S2 = NwinMedian / 2;
    NwinMedianMaxM1S2 = NwinMedianMax / 2;
    NwinMedianMaxP1S2 = NwinMedianMax / 2;
    }

  M_filt = matrix_float(Nlig + NwinMedianMax, Ncol + NwinMedianMax);
  M_fillnan = matrix_float(Nlig, Ncol);
  datamedian = vector_float(NwinMedianMax*NwinMedianMax);

  MinMaxNum = 0;
  for (lig = 0; lig < Nlig; lig++) {
    if (lig%(int)(Nlig/20) == 0) {printf("%f\r", 100. * lig / Nlig);fflush(stdout);}
    for (col = 0; col < Ncol; col++) {
      if ((my_isfinite(M[lig][col]) == 0) || (M[lig][col] > threshold)) {
        M[lig][col] = 0.f/0.f;
        MinMaxNum++;
        }
      M_filt[NwinMedianMaxM1S2+lig][NwinMedianMaxM1S2+col] = M[lig][col];
      }
    }

  MinMaxLig = vector_int(MinMaxNum);
  MinMaxCol = vector_int(MinMaxNum);
  MinMaxNum = 0;
  for (lig = 0; lig < Nlig; lig++) {
    if (lig%(int)(Nlig/20) == 0) {printf("%f\r", 100. * lig / Nlig);fflush(stdout);}
    for (col = 0; col < Ncol; col++) {
      if (my_isfinite(M[lig][col]) == 0) {
        MinMaxLig[MinMaxNum] = lig;
        MinMaxCol[MinMaxNum] = col;
        MinMaxNum++;      
        }
      }
    }

  /* Median Filtering */
  iter = 0;
  FlagMedian = 0;
  
  while (FlagMedian == 0) {
    for (lig = 0; lig < Nlig; lig++) {
      if (lig%(int)(Nlig/20) == 0) {printf("%f\r", 100. * lig / Nlig);fflush(stdout);}
      for (col = 0; col < Ncol; col++) {
        Npts = -1;
        for (k = -NwinMedianM1S2; k < NwinMedianP1S2; k++) 
          for (l = -NwinMedianM1S2; l < NwinMedianP1S2; l++) {
            Npts++;
            datamedian[Npts] = M_filt[NwinMedianMaxM1S2+lig+k][NwinMedianMaxM1S2+col+l];
            }
        M_fillnan[lig][col] = MedianArrayCryo(datamedian,Npts);
        }
      }

    for (ii = 0; ii < MinMaxNum; ii++) {
      M[MinMaxLig[ii]][MinMaxCol[ii]] = M_fillnan[MinMaxLig[ii]][MinMaxCol[ii]];
      }

    MinMaxNum = 0;
    for (lig = 0; lig < Nlig; lig++) {
      if (lig%(int)(Nlig/20) == 0) {printf("%f\r", 100. * lig / Nlig);fflush(stdout);}
      for (col = 0; col < Ncol; col++) {
        if (my_isfinite(M[lig][col]) == 0) {
          MinMaxLig[MinMaxNum] = lig;
          MinMaxCol[MinMaxNum] = col;
          MinMaxNum++;      
          }
        M_filt[NwinMedianMaxM1S2+lig][NwinMedianMaxM1S2+col] = M_fillnan[lig][col];
        }
      }

    if (MinMaxNum ==0) {
      FlagMedian = 1;
      } else {
      iter++;
      if (iter >= iteration) {
        FlagMedian = 1;
        } else {
        FlagMedian = 0;
        NwinMedian = 2*NwinMedian;
        if (NwinMedian & 1) {
          NwinMedianM1S2 = (NwinMedian - 1) / 2;
          NwinMedianP1S2 = (NwinMedian + 1) / 2;
          } else {
          NwinMedianM1S2 = NwinMedian / 2;
          NwinMedianP1S2 = NwinMedian / 2;
          }
        }
      }
    } // while

  free_matrix_float(M_fillnan, Nlig);
  free_matrix_float(M_filt, Nlig + NwinMedianMax);
  
return 1;
}

float MedianArrayCryo(float arr[], int npts)
{
  int low, high ;
  int median;
  int middle, ll, hh;
  float medianval;

  low = 0 ; high = npts-1 ; median = (low + high) / 2;
  for (;;) {
    if (high <= low) {/* One element only */
      if (npts & 1) {
        medianval = arr[median];
        } else {
        medianval = (arr[median]+arr[median+1])/2;
        }
      return medianval ;
      }

    if (high == low + 1) {  /* Two elements only */
      if (arr[low] > arr[high])
        ELEM_SWAP(arr[low], arr[high]) ;
      if (npts & 1) {
        medianval = arr[median];
        } else {
        medianval = (arr[median]+arr[median+1])/2;
        }
      return medianval ;
    }

  /* Find median of low, middle and high items; swap into position low */
  middle = (low + high) / 2;
  if (arr[middle] > arr[high])  ELEM_SWAP(arr[middle], arr[high]) ;
  if (arr[low] > arr[high])    ELEM_SWAP(arr[low], arr[high]) ;
  if (arr[middle] > arr[low])   ELEM_SWAP(arr[middle], arr[low]) ;

  /* Swap low item (now in position middle) into position (low+1) */
  ELEM_SWAP(arr[middle], arr[low+1]) ;

  /* Nibble from each end towards middle, swapping items when stuck */
  ll = low + 1;
  hh = high;
  for (;;) {
    do ll++; while (arr[low] > arr[ll]) ;
    do hh--; while (arr[hh]  > arr[low]) ;

    if (hh < ll)
    break;

    ELEM_SWAP(arr[ll], arr[hh]) ;
  }

  /* Swap middle item (in position low) back into correct position */
  ELEM_SWAP(arr[low], arr[hh]) ;

  /* Re-set active partition */
  if (hh <= median) low = ll;
  if (hh >= median) high = hh - 1;
  
  }
  free_vector_float(arr);
}