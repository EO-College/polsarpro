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

File  : unified_huynen_classification.c
Project  : ESA_POLSARPRO-SATIM
Authors  : Eric POTTIER, Jacek STRZELCZYK, Dong LI, Yunhua ZHANG
Version  : 1.0
Creation : 01/2017
Update  :
*--------------------------------------------------------------------
Dong Li, Yunhua Zhang
Key Lab of Microwave Remote Sensing, Chinese Academy of Sciences
National Space Science Center, Chinese Academy of Sciences
{lidong, zhangyunhua}@mirslab.cn, Dec. 30, 2016

*--------------------------------------------------------------------

Description :  
1st part : CHD decomposition
It performs canonical Huynen dichotomy for the T3 data from the input 
directory (in_dir). 
It uses UHD-1, UHD-4 and UHD-7 to calculate the three SDoP (Scattering 
Degree of Preference) parameters, i.e. SDoPs (the SDoP for surface
scatterer), SDoPd (the SDoP for dihedral scatterer), and SDoPv (the 
SDoP for volume scatterer). The weighted average of SDoPs, SDoPd, and 
SDoPv, i.e. the SDoP3 parameter is also obtained, which can be used to 
characterize the scattering randomness of the target.

Output Parameters:
'SDoPs'               The SDoP for surface scatterer.
'SDoPd'               The SDoP for dihedral scatterer.              
'SDoPv'               The SDoP for volume scatterer.
'SDoP3'               The weighted average of SDoPs, SDoPd, and SDoPv.

2nd part : CHD classification
It performs the CHD scattering preference-based classification of 
PolSAR data. It first uses function canonical_Huynen_dichotomy to 
calculate parameters SDoPs, SDoPd, SDoPv, and SDoP3, and then
classify the target into ten classes:
 
Classes            Boundaries 

S                  2/3 =< SDoP3 & SDoPs >= SDoPd & SDoPs > SDoPv
D                  2/3 =< SDoP3 & SDoPd > SDoPs & SDoPd >= SDoPv
V                  2/3 =< SDoP3 & SDoPv >= SDoPs & SDoPv > SDoPd
SD                 2/5 =< SDoP3 < 2/3 & SDoPs >= SDoPd >= SDoPv
SV                 2/5 =< SDoP3 < 2/3 & SDoPs > SDoPv > SDoPd
DS                 2/5 =< SDoP3 < 2/3 & SDoPd > SDoPs > SDoPv
DV                 2/5 =< SDoP3 < 2/3 & SDoPd >= SDoPv >= SDoPs
VS                 2/5 =< SDoP3 < 2/3 & SDoPv >= SDoPs >= SDoPd
VD                 2/5 =< SDoP3 < 2/3 & SDoPv > SDoPd > SDoPs
R                  SDoP3 < 2/5
 
Output Parameters:
'class'                  Each pixel position of 'class' is an integer
                         within the interval [1, 10] corresponding 
                         to the above ten classes, respectively.
                         
*--------------------------------------------------------------------
For more information about this function, please refer to
D. Li and Y. Zhang, "Unified Huynen phenomenological decomposition of
radar targets and its classification applications," IEEE TGRS, vol 54,
no 2, pp 723-743, 2016.
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

#define NPolType 3
/* LOCAL VARIABLES */
  FILE *out_PS, *out_PD, *out_PV, *out_P3, *out_class;
  int Config;
  char *PolTypeConf[NPolType] = {"S2T3", "C3", "T3"};
  char file_name[FilePathLength];
  
/* Internal variables */
  int ii, lig, col;
  int ligDone = 0;

  float M2A0, MB0pB, MB0mB;
  float MC, MD, ME, MF, MG, MH;

  float rot, SPAN;
  float T11, T12_real, T12_imag, T13_real, T13_imag, T22, T23_real, T23_imag, T33;
  float Td11, Td12_real, Td12_imag, Td13_real, Td13_imag, Td22, Td23_real, Td23_imag, Td33;
  float c1, c2, r1, r2, r3;
  float s, d, v, sd, sv, ds, dv, vs, vd, r;

/* Matrix arrays */
  float ***M_in;
  float **M_avg;
  float **M_out_PS;
  float **M_out_PD;
  float **M_out_PV;
  float **M_out_P3;
  float **M_out_class;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nunified_huynen_classification.exe\n");
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
strcat(UsageHelp," (string)	-errf	memory error file\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");
strcat(UsageHelp," (noarg) 	-data	displays the help concerning Data Format parameter\n");

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
  sprintf(file_name, "%s%s", out_dir, "SDoPs.bin");
  if ((out_PS = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  
  sprintf(file_name, "%s%s", out_dir, "SDoPd.bin");
  if ((out_PD = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "SDoPv.bin");
  if ((out_PV = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "SDoP3.bin");
  if ((out_P3 = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "SDoP_class.bin");
  if ((out_class = fopen(file_name, "wb")) == NULL)
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

  /* MoutPS = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* MoutPD = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* MoutPV = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* MoutP3 = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* MoutClass = Nlig*Sub_Ncol */
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
  M_out_PS = matrix_float(NligBlock[0], Sub_Ncol);
  M_out_PD = matrix_float(NligBlock[0], Sub_Ncol);
  M_out_PV = matrix_float(NligBlock[0], Sub_Ncol);
  M_out_P3 = matrix_float(NligBlock[0], Sub_Ncol);
  M_out_class = matrix_float(NligBlock[0], Sub_Ncol);
  
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
  if (strcmp(PolTypeOut,"C3")==0) C3_to_T3(M_in, NligBlock[Nb], Sub_Ncol + NwinC, 0, 0);

M2A0 = MB0pB = MB0mB = 0.;
MC = MD = ME = MF = MG = MH = 0.;
rot = SPAN = 0.;
T11 = T12_real = T12_imag = T13_real = T13_imag = T22 = T23_real = T23_imag = T33 = 0.;
Td11 = Td12_real = Td12_imag = Td13_real = Td13_imag = Td22 = Td23_real = Td23_imag = Td33 = 0.;
c1 = c2 = r1 = r2 = r3 = 0.;
s = d = v = sd = sv = ds = dv = vs = vd = r = 0.;
#pragma omp parallel for private(col, Np, M_avg) firstprivate(M2A0, MB0pB, MB0mB, MC, MD, ME, MF, MG, MH, rot, SPAN, T11, T12_real, T12_imag, T13_real, T13_imag, T22, T23_real, T23_imag, T33, Td11, Td12_real, Td12_imag, Td13_real, Td13_imag, Td22, Td23_real, Td23_imag, Td33, c1, c2, r1, r2, r3, s, d, v, sd, sv, ds, dv, vs, vd, r) shared(ligDone)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        T11 = eps + M_avg[T311][col]; T22 = eps + M_avg[T322][col]; T33 = eps + M_avg[T333][col];
        T12_real = eps + M_avg[T312_re][col]; T12_imag = eps + M_avg[T312_im][col];
        T23_real = eps + M_avg[T323_re][col]; T23_imag = eps + M_avg[T323_im][col];
        T13_real = eps + M_avg[T313_re][col]; T13_imag = eps + M_avg[T313_im][col];

        rot = atan2(T13_real, T12_real) / 2.;

        Td11 = T11;
        Td12_real = T12_real * cos(2. * rot) + T13_real * sin(2. * rot);
        Td12_imag = T12_imag * cos(2. * rot) + T13_imag * sin(2. * rot);
        Td13_real = -T12_real * sin(2. * rot) + T13_real * cos(2. * rot);
        Td13_imag = -T12_imag * sin(2. * rot) + T13_imag * cos(2. * rot);
        Td22 = T22 * cos(2. * rot) * cos(2. * rot) + T33 * sin(2. * rot) * sin(2. * rot) + T23_real * sin(4. * rot);
        Td23_real = (T33 - T22) * sin(4. * rot) / 2. + T23_real * cos(4. * rot);
        Td23_imag = T23_imag;
        Td33 = T22 * sin(2. * rot) * sin(2. * rot) + T33 * cos(2. * rot) * cos(2. * rot) - T23_real * sin(4. * rot);

        //Calculate the Huynen parameters
        M2A0 = eps + Td11;
        MB0pB = eps + Td22;
        MB0mB = eps + Td33;
        MC = eps + Td12_real;
        MD = eps - Td12_imag;
        ME = eps + Td23_real;
        MF = eps + Td23_imag;
        MG = eps + Td13_imag;
        MH = eps + Td13_real;

        // Base on UHD-1, UHD-4, and UHD-7 to calculate SDoPs, SDoPd, SDoPv, and
        // SDoP3, respectively.
        SPAN = Td11 + Td22 + Td33 + eps;
        M_out_PS[lig][col] = (M2A0*M2A0 + MC*MC + MD*MD + MH*MH + MG*MG) / M2A0 / SPAN;
        M_out_PD[lig][col] = (MC*MC + MD*MD + MB0pB*MB0pB + ME*ME + MF*MF) / MB0pB / SPAN;
        M_out_PV[lig][col] = (MH*MH + MG*MG + ME*ME + MF*MF + MB0mB*MB0mB) / MB0mB / SPAN;
        M_out_P3[lig][col] = (M_out_PS[lig][col]*M_out_PS[lig][col] + M_out_PD[lig][col]*M_out_PD[lig][col] + M_out_PV[lig][col]*M_out_PV[lig][col])/(M_out_PS[lig][col] + M_out_PD[lig][col] + M_out_PV[lig][col]);
              
        c1 = (2./3. < M_out_P3[lig][col]); c2 = (2./5. < M_out_P3[lig][col]);
        r1 = (M_out_PD[lig][col] < M_out_PS[lig][col]);
        r2 = (M_out_PV[lig][col] < M_out_PD[lig][col]);
        r3 = (M_out_PS[lig][col] < M_out_PV[lig][col]);
        s = (c1 * r1 * !r3);
        d = (c1 * !r1 * r2);
        v = (c1 * r3 * !r2);
        sd = (c2 * !c1 * r1 * r2);
        sv = (c2 * !c1 * !r3 * !r2);
        ds = (c2 * !c1 * !r1 * !r3);
        dv = (c2 * !c1 * r2 * r3);
        vs = (c2 * !c1 * r3 * r1);
        vd = (c2 * !c1 * !r2 * !r1);
        r = (!c2);
        M_out_class[lig][col] = s*1. + d*2. + v*3. + sd*4. + sv*5. + ds*6. + dv*7. + vs*8. + vd*9. + r*10.;    
        } else {
        M_out_PS[lig][col] = 0.;
        M_out_PD[lig][col] = 0.;
        M_out_PV[lig][col] = 0.;
        M_out_P3[lig][col] = 0.;
        M_out_class[lig][col] = 0.;
        }
      }
    free_matrix_float(M_avg,NpolarOut);
    }
  write_block_matrix_float(out_PS, M_out_PS, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_PD, M_out_PD, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_PV, M_out_PV, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_P3, M_out_P3, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_class, M_out_class, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_avg, NpolarOut, NligBlock[0]);
  free_matrix3d_float(M_out, NpolarOut, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarOut; Np++) fclose(out_datafile[Np]);
  
/********************************************************************
********************************************************************/

  return 1;
}


