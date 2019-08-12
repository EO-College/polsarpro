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

File  : sub_aperture_anisotropy.c
Project  : ESA_POLSARPRO-SATIM
Authors  : Laurent FERRO-FAMIL, Eric POTTIER, Jacek STRZELCZYK
Version  : 3.0
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

Description :  Determination of the anisotropy (non-stationary 
               scattering mechanisms) along the sub-apertures

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
#define Npolar   4
#define n_remove 1

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

#define NPolType 2
/* LOCAL VARIABLES */
  FILE *out_file;
  int Config;
  char *PolTypeConf[NPolType] = {"SPP", "C2"};
  char file_name[FilePathLength], dir_in[FilePathLength];
  char PolTypeInit[20];
  
/* Internal variables */
  int ii, lig, col, k, l, np, nf, nim;
  int sub_init, sub_number;
  int ok;
  int Nligg, ligg;
  int ligDone = 0;

  float d,min,max,cpt;
  float lambda;
  float Nlook,nt,n_aniso;
  float ok_th,rau;

/* Matrix arrays */
  float ***M_in;
  float **M_avg;
  
  float ***gT;
  float ***T;
  float *deter, **ratio,**sratio,**aniso;
  float *ValidMask;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nsub_aperture_anisotropySPPC2.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-subi	initial sub-aperture number\n");
strcat(UsageHelp," (int)   	-subn	number of sub-apertures\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-nlk 	number of looks\n");
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

if(argc < 21) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-subi",int_cmd_prm,&sub_init,1,UsageHelp);
  get_commandline_prm(argc,argv,"-subn",int_cmd_prm,&sub_number,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nlk",flt_cmd_prm,&Nlook,1,UsageHelp);
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

  if (strcmp(PolType,"SPP")==0) strcpy(PolType,"SPPC2");
  strcpy(PolTypeInit,PolType);
  
/********************************************************************
********************************************************************/

  if (FlagValid == 1) check_file(file_valid);
  
  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

  Off_lig = 0; Off_col = 0;
  Nlook = Nlook * NwinL * NwinC;

/********************************************************************
********************************************************************/

/* INPUT/OUPUT CONFIGURATIONS */
  strcpy(PolType,PolTypeInit);
  if (strcmp(PolType,"SPPC2")==0) sprintf(dir_in, "%s%i", in_dir, sub_init);
  if (strcmp(PolType,"C2")==0) sprintf(dir_in, "%s%i/C2", in_dir, sub_init);
  check_dir(dir_in);
  read_config(dir_in, &Nlig, &Ncol, PolarCase, PolarType);

/* INPUT FILE OPENING*/
  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

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

  /* gt = Npolar*Nlig*Ncol */
  NBlockA += 0; NBlockB += Npolar*Sub_Nlig*Sub_Ncol;
  /* ratio = Npolar*Nlig*Ncol */
  NBlockA += 0; NBlockB += Sub_Nlig*Sub_Ncol;
  /* sratio = Npolar*Nlig*Ncol */
  NBlockA += 0; NBlockB += Sub_Nlig*Sub_Ncol;
  /* aniso = Npolar*Nlig*Ncol */
  NBlockA += 0; NBlockB += Sub_Nlig*Sub_Ncol;
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

  _VI_in = vector_int(Ncol);
  _VC_in = vector_float(2*Ncol);
  _VF_in = vector_float(Ncol);
  _MC_in = matrix_float(4,2*Ncol);
  _MF_in = matrix3d_float(Npolar,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   

  Valid = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);

  M_in = matrix3d_float(NpolarOut, NligBlock[0] + NwinL, Ncol + NwinC);
  gT = matrix3d_float(Npolar, Sub_Nlig, Sub_Ncol);
  ratio = matrix_float(Sub_Nlig, Sub_Ncol);

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

  for(lig=0;lig<Sub_Nlig;lig++)
    for(col=0;col<Sub_Ncol;col++) {
      ratio[lig][col] = 0;
      for(np=0;np<Npolar;np++) gT[np][lig][col] = 0;
      }
  nim = (float)sub_number;
  nt = nim*Nlook;

/********************************************************************
********************************************************************/
  
for(nf=sub_init; nf<sub_number; nf++) {

/********************************************************************
********************************************************************/

/* INPUT/OUPUT CONFIGURATIONS */
  strcpy(PolType,PolTypeInit);
  if (strcmp(PolType,"SPPC2")==0) sprintf(dir_in, "%s%i", in_dir, nf);
  if (strcmp(PolType,"C2")==0) sprintf(dir_in, "%s%i/C2", in_dir, nf);
  check_dir(dir_in);
  read_config(dir_in, &Nlig, &Ncol, PolarCase, PolarType);
  
/* POLAR TYPE CONFIGURATION */
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);
  
  file_name_in = matrix_char(NpolarIn,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, dir_in, file_name_in);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
  if ((in_datafile[Np] = fopen(file_name_in[Np], "rb")) == NULL)
    edit_error("Could not open input file : ", file_name_in[Np]);

/********************************************************************
********************************************************************/
if (FlagValid == 1) rewind(in_valid);
Nligg = 0; ligg = 0;

for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}
 
  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  if ((strcmp(PolType,"SPP") == 0) 
    || (strcmp(PolType,"SPPpp1") == 0)
    || (strcmp(PolType,"SPPpp2") == 0)
    || (strcmp(PolType,"SPPpp3") == 0)) {
    read_block_SPP_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
  /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

d = 0.;
#pragma omp parallel for private(col, Np, T, deter, M_avg) firstprivate(ligg, d) shared(ligDone)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    T = matrix3d_float(2,2,2);
    deter  = vector_float(2);
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    ligg = lig + Nligg;
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {

        T[0][0][0] = eps + M_avg[0][col];
        T[0][0][1] = 0.;
        T[0][1][0] = eps + M_avg[1][col];
        T[0][1][1] = eps + M_avg[2][col];
        T[1][0][0] =  T[0][1][0];
        T[1][0][1] = -T[0][1][1];
        T[1][1][0] = eps + M_avg[3][col];
        T[1][1][1] = 0.;

        DeterminantHermitianMatrix2(T, deter);
        d = deter[0];
        if(d<0) d=0;
        if(d > 1e37) d = 1/eps;
  
        ratio[ligg][col] +=Nlook*log(d+eps);
        for (Np = 0; Np < NpolarOut; Np++) gT[Np][ligg][col] += eps+Nlook*M_avg[Np][col];
        } /*valid*/
      }
    free_matrix3d_float(T,2,2);
    free_vector_float(deter);
    free_matrix_float(M_avg,NpolarOut);
    }
  Nligg += NligBlock[Nb];
  } // NbBlock

/********************************************************************
********************************************************************/

/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);

/* nf */
}

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
  free_matrix_float(Valid, NligBlock[0]);
  free_matrix3d_float(M_in, NpolarOut, NligBlock[0] + NwinL);

/* MATRIX ALLOCATION */
  ValidMask = vector_float(Ncol);
  sratio = matrix_float(Sub_Nlig, Sub_Ncol); 
  aniso = matrix_float(Sub_Nlig, Sub_Ncol); 
  
/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
    for (col = 0; col < Ncol; col++) ValidMask[col] = 1.;

/********************************************************************
********************************************************************/
/* DATA PROCESSING */
  if (FlagValid == 1) rewind(in_valid);

  nt = nim*Nlook;

  for(lig=0;lig<Sub_Nlig;lig++) {
    PrintfLine(lig,Sub_Nlig);
    if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    d = 0.;
#pragma omp parallel for private(col, T, deter) firstprivate(d) shared(ligDone)
    for(col=0;col<Sub_Ncol;col++) {
      T = matrix3d_float(2,2,2);
      deter  = vector_float(2);
      if (ValidMask[col] == 1.) {
        T[0][0][0]=eps+gT[C211][lig][col]/nt;
        T[0][0][1]=0.;
        T[0][1][0]=eps+gT[C212_re][lig][col]/nt;
        T[0][1][1]=eps+gT[C212_im][lig][col]/nt;
        T[1][0][0]=eps+gT[C212_re][lig][col]/nt;
        T[1][0][1]=eps-gT[C212_im][lig][col]/nt;
        T[1][1][0]=eps+gT[C222][lig][col]/nt;
        T[1][1][1]=0.;

        DeterminantHermitianMatrix2(T, deter);
        d = deter[0];
        if(d<0) d = 0;
        ratio[lig][col] = ratio[lig][col]-nt*log(d+eps);
      
        } else {
        ratio[lig][col] = 0.;
        }
      free_matrix3d_float(T,2,2);
      free_vector_float(deter);
      }
    }

  /* 3*3 smoothing of the likelihood ratio */
  if (FlagValid == 1) rewind(in_valid);
  if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);

  for(lig=1;lig<Sub_Nlig-1;lig++) {
    PrintfLine(lig,Sub_Nlig-1);
    if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    for(col=1;col<Sub_Ncol-1;col++) {
      if (ValidMask[col] == 1.) {
        rau = 0;
        for(k=-1;k<2;k++) for(l=-1;l<2;l++) rau +=ratio[lig+l][col+k];
        sratio[lig][col] = rau/9;
        } else {
        sratio[lig][col] = 0.;
        }
      }
    }

  for(lig=1;lig<Sub_Nlig-1;lig++)
    for(col=1;col<Sub_Ncol-1;col++)
      ratio[lig][col] = sratio[lig][col];

  /* Detection des X% de pixels avec ratio le plus bas */
  ok=0;
  ok_th = 13;
  MinMaxArray2D(ratio,&min,&max,Sub_Nlig,Sub_Ncol);

  cpt = 0;
  while(cpt<(Sub_Nlig*Sub_Ncol*ok_th/100)) {
    cpt=0;
    min = min/1.1;
    if (FlagValid == 1) rewind(in_valid);
    for(lig=0;lig<Sub_Nlig;lig++) {
      PrintfLine(lig,Sub_Nlig);
      if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
      for(col=0;col<Sub_Ncol;col++) {
        if (ValidMask[col] == 1.) {
          if(ratio[lig][col]<min) cpt = cpt + 1.0;
          }
        }
      }
    }
  min = min*1.1;

  /* seuil fixe a cette limite  et seuillage */
  if (FlagValid == 1) rewind(in_valid);
  lambda = min;
  n_aniso = 0;
  for(lig=0;lig<Sub_Nlig;lig++) {
    PrintfLine(lig,Sub_Nlig);
    if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    for(col=0;col<Sub_Ncol;col++) {
      if (ValidMask[col] == 1.) {
        if(ratio[lig][col] < lambda) {
          aniso[lig][col] = 1;
          n_aniso++;
          }
          else
          aniso[lig][col] = 0;
        } else {
        aniso[lig][col] = 0.;
        }
      }
    }

/* fin detection des X% de points les plus hauts */

/* Filtrage median BINAIRE (3fois en 3*3) de l'image seuillee */
for( ok=0; ok<3; ok++) {
  if (FlagValid == 1) rewind(in_valid);
  if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
  /* Filtrage median aniso */
  for(lig=1;lig<Sub_Nlig-1;lig++) {
    PrintfLine(lig,Sub_Nlig-1);
    if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    for(col=1;col<Sub_Ncol-1;col++) {
      if (ValidMask[col] == 1.) {
        rau = 0;
        for(k=-1;k<2;k++) for(l=-1;l<2;l++) rau +=aniso[lig+l][col+k];
        if(rau>4) sratio[lig][col] = 1;
        else sratio[lig][col] = 0;
        } else {
        sratio[lig][col] = 0.;
        }
      }
    }
  n_aniso = 0;
  for(lig=0;lig<Sub_Nlig;lig++) {
    PrintfLine(lig,Sub_Nlig);
    for(col=0;col<Sub_Ncol;col++) {
      aniso[lig][col] = sratio[lig][col]*(lig>0)*(col>0)*(lig<Sub_Nlig-1)*(col<Sub_Ncol-1);
      n_aniso += aniso[lig][col];
      }
    }    
  }

/********************************************************************
********************************************************************/
  /* INPUT/OUTPUT FILE OPENING*/
  if (strcmp(PolType,"SPP")==0) sprintf(file_name, "%s_sub_%i/%s", out_dir, sub_init, "TF_anisotropy.bin");
  if (strcmp(PolType,"C2")==0) sprintf(file_name, "%s_sub_%i/C2/%s", out_dir, sub_init, "TF_anisotropy.bin");
  check_file(file_name);
  if ((out_file=fopen(file_name,"wb"))==NULL) edit_error("Could not open output file : ",file_name);
  for(lig=0;lig<Sub_Nlig;lig++) {
    PrintfLine(lig,Sub_Nlig);
    fwrite(&aniso[lig][0],sizeof(float),Sub_Ncol,out_file);
    }
  fclose(out_file);
  printf("0.0\r");fflush(stdout);


  /* INPUT/OUTPUT FILE OPENING*/
  if (strcmp(PolType,"SPP")==0) sprintf(file_name, "%s_sub_%i/%s", out_dir, sub_init, "ratio_log.bin");
  if (strcmp(PolType,"C2")==0) sprintf(file_name, "%s_sub_%i/C2/%s", out_dir, sub_init, "ratio_log.bin");
  check_file(file_name);
  if ((out_file=fopen(file_name,"wb"))==NULL) edit_error("Could not open output file : ",file_name);
  for(lig=0;lig<Sub_Nlig;lig++) {
    PrintfLine(lig,Sub_Nlig);
    fwrite(&ratio[lig][0],sizeof(float),Sub_Ncol,out_file);
    }
  fclose(out_file);

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_vector_float(ValidMask);

  free_matrix3d_float(gT, NpolarOut, Sub_Nlig);
  free_matrix_float(ratio, Sub_Nlig);
  free_matrix_float(sratio, Sub_Nlig);
  free_matrix_float(aniso, Sub_Nlig);

*/  
/********************************************************************
********************************************************************/

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);

/********************************************************************
********************************************************************/

  return 1;
}


