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

File  : StokesParameters.c
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

Description :  stokes parameters determination

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
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C2", "SPP"};
  char file_name[FilePathLength];
  
/* Flag Parameters */
  int Flag[21], Nout, NPara;
  FILE *OutFile[21];
  char *FileOut[21] = {
  "g0","g1","g2","g3","g0dB","g1dB","g2dB","g3dB",
  "phi","tau",
  "l1","l2","p1","p2","H","A",
  "contrast","DoLP","DoCP","LPR","CPR"};
  
/* Internal variables */
  int ii, lig, col, k;

  int channel;
  float StkG0,StkG1,StkG2,StkG3,Stkl1,Stkl2,Stkp1,Stkp2;

  int G0, G1, G2, G3, Phi, Tau, l1, l2, p1, p2, H, A;
  int Co, DoLP, DoCP, LPR, CPR, G0dB, G1dB, G2dB, G3dB;

  int FlagComp0, FlagComp1, FlagComp2, FlagComp3;
  int FlagAnglePhi, FlagAngleTau, FlagEigen, FlagProba, FlagH, FlagA;
  int FlagWaveC, FlagWaveDoLP, FlagWaveDoCP, FlagWaveLPR, FlagWaveCPR;
  
/* Matrix arrays */
  float ***M_avg;
  float ***M_out;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nStokesParameters.exe\n");
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
strcat(UsageHelp," (int)   	-cha 	Polarimetric channel (S2: 1 or 2, C2: 1)\n");
strcat(UsageHelp," (int)   	-fl1 	Flag Stokes parameters g0 (1 = lin, 2 = dB)\n");
strcat(UsageHelp," (int)   	-fl2 	Flag Stokes parameters g1 (1 = lin, 2 = dB)\n");
strcat(UsageHelp," (int)   	-fl3 	Flag Stokes parameters g2 (1 = lin, 2 = dB)\n");
strcat(UsageHelp," (int)   	-fl4 	Flag Stokes parameters g3 (1 = lin, 2 = dB)\n");
strcat(UsageHelp," (int)   	-fl5 	Flag Stokes angle phi (0/1)\n");
strcat(UsageHelp," (int)   	-fl6 	Flag Stokes angle tau (0/1)\n");
strcat(UsageHelp," (int)   	-fl7 	Flag Eigenvalues (0/1)\n");
strcat(UsageHelp," (int)   	-fl8 	Flag Probabilities (0/1)");
strcat(UsageHelp," (int)   	-fl9 	Flag Entropy H (0/1)");
strcat(UsageHelp," (int)   	-fl10 	Flag Anisotropy A (0/1)");
strcat(UsageHelp," (int)   	-fl11 	Flag Wave Contrast (0/1)\n");
strcat(UsageHelp," (int)   	-fl12 	Flag Wave DoLP (0/1)\n");
strcat(UsageHelp," (int)   	-fl13 	Flag Wave DoCP (0/1)\n");
strcat(UsageHelp," (int)   	-fl14 	Flag Wave LPR (0/1)\n");
strcat(UsageHelp," (int)   	-fl15 	Flag Wave CPR (0/1)\n");
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

if(argc < 51) {
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
  get_commandline_prm(argc,argv,"-cha",int_cmd_prm,&channel,1,UsageHelp);

  get_commandline_prm(argc,argv,"-fl1",int_cmd_prm,&FlagComp0,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl2",int_cmd_prm,&FlagComp1,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl3",int_cmd_prm,&FlagComp2,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl4",int_cmd_prm,&FlagComp3,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl5",int_cmd_prm,&FlagAnglePhi,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl6",int_cmd_prm,&FlagAngleTau,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl7",int_cmd_prm,&FlagEigen,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl8",int_cmd_prm,&FlagProba,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl9",int_cmd_prm,&FlagH,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl10",int_cmd_prm,&FlagA,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl11",int_cmd_prm,&FlagWaveC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl12",int_cmd_prm,&FlagWaveDoLP,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl13",int_cmd_prm,&FlagWaveDoCP,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl14",int_cmd_prm,&FlagWaveLPR,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl15",int_cmd_prm,&FlagWaveCPR,1,UsageHelp);

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
  if (strcmp(PolType,"S2")==0) strcpy(PolType,"S2C4");
  if (strcmp(PolType,"SPP")==0) strcpy(PolType,"SPPC2");

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
  /* Decomposition parameters */
  G0 = 0; G1= 1; G2 = 2; G3 = 3; G0dB = 4; G1dB = 5; G2dB = 6; G3dB = 7;
  Phi = 8; Tau = 9; l1 = 10; l2 = 11; p1 = 12; p2 = 13; H = 14; A = 15;
  Co = 16; DoLP = 17; DoCP = 18; LPR = 19; CPR = 20;
  
  NPara = 21;
  for (k = 0; k < NPara; k++) Flag[k] = -1;
  Nout = 0;

  //Flag Comp
  if (FlagComp0 == 1) {
    if (Flag[G0] == -1) {Flag[G0] = Nout; Nout++;}
    }
  if (FlagComp1 == 1) {
    if (Flag[G1] == -1) {Flag[G1] = Nout; Nout++;}
    }
  if (FlagComp2 == 1) {
    if (Flag[G2] == -1) {Flag[G2] = Nout; Nout++;}
    }
  if (FlagComp3 == 1) {
    if (Flag[G3] == -1) {Flag[G3] = Nout; Nout++;}
    }
  if (FlagComp0 == 2) {
    if (Flag[G0dB] == -1) {Flag[G0dB] = Nout; Nout++;}
    }
  if (FlagComp1 == 2) {
    if (Flag[G1dB] == -1) {Flag[G1dB] = Nout; Nout++;}
    }
  if (FlagComp2 == 2) {
    if (Flag[G2dB] == -1) {Flag[G2dB] = Nout; Nout++;}
    }
  if (FlagComp3 == 2) {
    if (Flag[G3dB] == -1) {Flag[G3dB] = Nout; Nout++;}
    }
  //Flag Angles
  if (FlagAnglePhi == 1) {
    if (Flag[Phi] == -1) {Flag[Phi] = Nout; Nout++;}
    }
  if (FlagAngleTau == 1) {
    if (Flag[Tau] == -1) {Flag[Tau] = Nout; Nout++;}
    }
  //Flag Eigen, Proba, H, A
  if (FlagEigen == 1) {
    if (Flag[l1] == -1) {Flag[l1] = Nout; Nout++;}
    if (Flag[l2] == -1) {Flag[l2] = Nout; Nout++;}
    }
  if (FlagProba == 1) {
    if (Flag[p1] == -1) {Flag[p1] = Nout; Nout++;}
    if (Flag[p2] == -1) {Flag[p2] = Nout; Nout++;}
    }
  if (FlagH == 1) {
    if (Flag[H] == -1) {Flag[H] = Nout; Nout++;}
    }
  if (FlagA == 1) {
    if (Flag[A] == -1) {Flag[A] = Nout; Nout++;}
    }
  //Flag Wave
  if (FlagWaveC == 1) {
    if (Flag[Co] == -1) {Flag[Co] = Nout; Nout++;}
    }
  if (FlagWaveDoLP == 1) {
    if (Flag[DoLP] == -1) {Flag[DoLP] = Nout; Nout++;}
    }
  if (FlagWaveDoCP == 1) {
    if (Flag[DoCP] == -1) {Flag[DoCP] = Nout; Nout++;}
    }
  if (FlagWaveLPR == 1) {
    if (Flag[LPR] == -1) {Flag[LPR] = Nout; Nout++;}
    }
  if (FlagWaveCPR == 1) {
    if (Flag[CPR] == -1) {Flag[CPR] = Nout; Nout++;}
    }

  for (k = 0; k < NPara; k++) {
    if (Flag[k] != -1) {
      sprintf(file_name, "%sStokes%i_%s.bin", out_dir, channel, FileOut[k]);
      if ((OutFile[Flag[k]] = fopen(file_name, "wb")) == NULL)
        edit_error("Could not open input file : ", file_name);
      }
    }

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

  /* Mout = Nout*Nlig*Sub_Ncol */
  NBlockA += Nout*Sub_Ncol; NBlockB += 0;
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
  M_out = matrix3d_float(Nout, NligBlock[0], Sub_Ncol);

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
for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    if (strcmp(PolTypeIn,"S2")==0) {
      read_block_S2_avg(in_datafile, M_avg, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
      // Convert C4 -> C2
      if (channel == 1) {
        for (lig = 0; lig < NligBlock[Nb]; lig++) {
          for (col = 0; col < Sub_Ncol; col++) {
            M_avg[C211][lig][col] = M_avg[C411][lig][col];
            M_avg[C212_re][lig][col] = M_avg[C413_re][lig][col];
            M_avg[C212_im][lig][col] = M_avg[C413_im][lig][col];
            M_avg[C222][lig][col] = M_avg[C433][lig][col];
            }
          }
        }
      if (channel == 2) {
        for (lig = 0; lig < NligBlock[Nb]; lig++) {
          for (col = 0; col < Sub_Ncol; col++) {
            M_avg[C211][lig][col] = M_avg[C444][lig][col];
            M_avg[C212_re][lig][col] = M_avg[C424_re][lig][col];
            M_avg[C212_im][lig][col] = M_avg[C424_im][lig][col];
            M_avg[C222][lig][col] = M_avg[C422][lig][col];
            }
          }
        }
      } else {
      read_block_SPP_avg(in_datafile, M_avg, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
      }
    } else {
    /* Case of C,T or I */
    read_block_TCI_avg(in_datafile, M_avg, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        StkG0 = M_avg[C211][lig][col] + M_avg[C222][lig][col];
        StkG1 = M_avg[C211][lig][col] - M_avg[C222][lig][col];
        StkG2 = M_avg[C212_re][lig][col];
        StkG3 = -M_avg[C212_im][lig][col];

        Stkl1 = 0.5*(StkG0 + sqrt(StkG1*StkG1+StkG2*StkG2+StkG3*StkG3));
        Stkl2 = 0.5*(StkG0 - sqrt(StkG1*StkG1+StkG2*StkG2+StkG3*StkG3));

        Stkp1 = Stkl1 / (eps + Stkl1 + Stkl2);
        Stkp2 = Stkl2 / (eps + Stkl1 + Stkl2);

        if (Flag[G0] != -1) M_out[Flag[G0]][lig][col]  = StkG0;
        if (Flag[G1] != -1) M_out[Flag[G1]][lig][col]  = StkG1;
        if (Flag[G2] != -1) M_out[Flag[G2]][lig][col]  = StkG2;
        if (Flag[G3] != -1) M_out[Flag[G3]][lig][col]  = StkG3;
        if (Flag[Phi] != -1) M_out[Flag[Phi]][lig][col] = 0.5*atan2(StkG2,eps+StkG1) * 180. / pi;
        if (Flag[Tau] != -1) M_out[Flag[Tau]][lig][col] = 0.5*asin(StkG3/(eps+sqrt(StkG1*StkG1+StkG2*StkG2+StkG3*StkG3))) * 180. / pi;
        if (Flag[l1] != -1) M_out[Flag[l1]][lig][col]  = Stkl1;
        if (Flag[l2] != -1) M_out[Flag[l2]][lig][col]  = Stkl2;
        if (Flag[p1] != -1) M_out[Flag[p1]][lig][col]  = Stkp1;
        if (Flag[p2] != -1) M_out[Flag[p2]][lig][col]  = Stkp2;
        if (Flag[H] != -1) M_out[Flag[H]][lig][col]  = -(Stkp1*log(Stkp1 + eps)+Stkp2*log(Stkp2 + eps))/log(2.);
        if (Flag[A] != -1) M_out[Flag[A]][lig][col]  = (Stkp1 - Stkp2) / (Stkp1 + Stkp2 + eps);
        if (Flag[Co] != -1) M_out[Flag[Co]][lig][col]  = StkG1 / (StkG0 + eps);
        if (Flag[DoLP] != -1) M_out[Flag[DoLP]][lig][col]  = sqrt(StkG1*StkG1 + StkG2*StkG2 )/ (StkG0 + eps);
        if (Flag[DoCP] != -1) M_out[Flag[DoCP]][lig][col]  = StkG3 / (StkG0 + eps);
        if (Flag[LPR] != -1) M_out[Flag[LPR]][lig][col]  = (StkG0 - StkG1 )/ (StkG0 + StkG1 + eps);
        if (Flag[CPR] != -1) M_out[Flag[CPR]][lig][col]  = (StkG0 - StkG3 )/ (StkG0 + StkG3 + eps);
        if (Flag[G0dB] != -1) {
          if (StkG0 <= eps) StkG0 = eps;
          M_out[Flag[G0dB]][lig][col]  = 10. * log10(StkG0);
          }
        if (Flag[G1dB] != -1) {
          if (StkG1 <= eps) StkG1 = eps;
          M_out[Flag[G1dB]][lig][col]  = 10. * log10(StkG1);
          }
        if (Flag[G2dB] != -1) {
          if (StkG2 <= eps) StkG2 = eps;
          M_out[Flag[G2dB]][lig][col]  = 10. * log10(StkG2);
          }
        if (Flag[G3dB] != -1) {
          if (StkG3 <= eps) StkG3 = eps;
          M_out[Flag[G3dB]][lig][col]  = 10. * log10(StkG3);
          }
        } else {
        for (k = 0; k < NPara; k++) 
          if (Flag[k] != -1) M_out[Flag[k]][lig][col] = 0.;
        }
      }
    }

  for (k = 0; k < NPara; k++) 
    if (Flag[k] != -1) {
      write_block_matrix_matrix3d_float(OutFile[Flag[k]], M_out, Flag[k], NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
      }

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_avg, NpolarOut, NligBlock[0]);
  free_matrix3d_float(M_out, Nout, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  for (Np = 0; Np < NPara; Np++) 
    if (Flag[Np] != -1) fclose(OutFile[Flag[Np]]);
  
/********************************************************************
********************************************************************/

  return 1;
}


