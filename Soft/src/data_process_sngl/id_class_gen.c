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

File  : id_class_gen.c
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

Description :  Basic identification of the classes resulting of a 
               Unsupervised H / A / Alpha - Wishart segmentation

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

/* ALIASES */
#define nclass_pol  100
#define ent  0
#define anis 1
#define al1  2
#define al2  3
#define be1  4
#define be2  5
#define pr1  6
#define pr2  7
#define cl_H_A 0
#define cl_al1 1
#define cl_al1_al2 2

/* CONSTANTS */
#define lim_H1  0.85
#define lim_H2  0.5
#define lim_A  0.5

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

/* LOCAL VARIABLES */
  FILE *fileH, *fileA, *fileAl1, *fileAl2, *fileBe1, *fileBe2;
  FILE *filep1, *filep2, *fileclass;
  FILE *out_file;
  char filename[FilePathLength], in_class_name[256];
  char Colormap_wishart[FilePathLength];

/* Internal variables */
  int lig, col, n_class;
  int Nligg, ligg;
  int h1,h2,a1,r1,r2,r3,r4,r5,r6;

  float max,bid1,bid2;
  float class_type, class_al1, class_al1_al2, class_H_A;

/* Matrix arrays */
  float **MH_in;
  float **MA_in;
  float **MAl1_in;
  float **MAl2_in;
  float **MBe1_in;
  float **MBe2_in;
  float **Mp1_in;
  float **Mp2_in;
  float **class_in;
  float **class_out;
  
  float **cpt_H_A;
  float **cpt_al1;
  float **cpt_al1_al2;
  float **class_vec;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nid_class_gen.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (string)	-if  	input class file\n");
strcat(UsageHelp," (string)	-clm 	Colormap wishart 16 colors\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
strcat(UsageHelp," (string)	-errf	memory error file\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 17) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,in_class_name,1,UsageHelp);
  get_commandline_prm(argc,argv,"-clm",str_cmd_prm,Colormap_wishart,1,UsageHelp);

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
  }

/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);
  check_file(in_class_name);
  check_file(Colormap_wishart);

  NwinL = 1; NwinC = 1;
  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);

/* INPUT FILE OPENING*/
  sprintf(filename, "%sentropy.bin", in_dir);
  if ((fileH = fopen(filename, "rb")) == NULL)
    edit_error("Could not open input file : ", filename);

  sprintf(filename, "%sanisotropy.bin", in_dir);
  if ((fileA = fopen(filename, "rb")) == NULL)
    edit_error("Could not open input file : ", filename);

  sprintf(filename, "%salpha1.bin", in_dir);
  if ((fileAl1 = fopen(filename, "rb")) == NULL)
    edit_error("Could not open input file : ", filename);

  sprintf(filename, "%salpha2.bin", in_dir);
  if ((fileAl2 = fopen(filename, "rb")) == NULL)
    edit_error("Could not open input file : ", filename);

  sprintf(filename, "%sbeta1.bin", in_dir);
  if ((fileBe1 = fopen(filename, "rb")) == NULL)
    edit_error("Could not open input file : ", filename);

  sprintf(filename, "%sbeta2.bin", in_dir);
  if ((fileBe2 = fopen(filename, "rb")) == NULL)
    edit_error("Could not open input file : ", filename);

  sprintf(filename, "%sp1.bin", in_dir);
  if ((filep1 = fopen(filename, "rb")) == NULL)
    edit_error("Could not open input file : ", filename);

  sprintf(filename, "%sp2.bin", in_dir);
  if ((filep2 = fopen(filename, "rb")) == NULL)
    edit_error("Could not open input file : ", filename);

  if ((fileclass=fopen(in_class_name, "rb"))==NULL)
    edit_error("Could not open input file : ",in_class_name);

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

  /* MHin = Nlig*Ncol */
  NBlockA += Ncol; NBlockB += 0;
  /* MAin = Nlig*Ncol */
  NBlockA += Ncol; NBlockB += 0;
  /* MAl1in = Nlig*Ncol */
  NBlockA += Ncol; NBlockB += 0;
  /* MAl2in = Nlig*Ncol */
  NBlockA += Ncol; NBlockB += 0;
  /* MBe1in = Nlig*Ncol */
  NBlockA += Ncol; NBlockB += 0;
  /* MBe2in = Nlig*Ncol */
  NBlockA += Ncol; NBlockB += 0;
  /* Mp1in = Nlig*Ncol */
  NBlockA += Ncol; NBlockB += 0;
  /* Mp2in = Nlig*Ncol */
  NBlockA += Ncol; NBlockB += 0;
  /* class_in = Nlig*Ncol */
  NBlockA += Ncol; NBlockB += 0;
  
  /* 4*Cpt = 4*nclass_pol*nclass_pol */
  NBlockA += 0; NBlockB += 4*nclass_pol*nclass_pol;

  /* class_out = Sub_Nlig*Sub_Ncol */
  NBlockA += 0; NBlockB += Sub_Nlig*Sub_Ncol;
  
/* Reading Data */
  NBlockB += Ncol + 2*Ncol + NpolarIn*2*Ncol + NpolarOut*NwinL*(Ncol+NwinC);

  memory_alloc(file_memerr, Sub_Nlig, 0, &NbBlock, NligBlock, NBlockA, NBlockB, MemoryAlloc);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  _VC_in = vector_float(2*Ncol);
  _VF_in = vector_float(Ncol);
  _MC_in = matrix_float(4,2*Ncol);
  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   

  Valid = matrix_float(NligBlock[0], Sub_Ncol);

  MH_in = matrix_float(NligBlock[0], Sub_Ncol);
  MA_in = matrix_float(NligBlock[0], Sub_Ncol);
  MAl1_in = matrix_float(NligBlock[0], Sub_Ncol);
  MAl2_in = matrix_float(NligBlock[0], Sub_Ncol);
  MBe1_in = matrix_float(NligBlock[0], Sub_Ncol);
  MBe2_in = matrix_float(NligBlock[0], Sub_Ncol);
  Mp1_in = matrix_float(NligBlock[0], Sub_Ncol);
  Mp2_in = matrix_float(NligBlock[0], Sub_Ncol);
  class_in = matrix_float(NligBlock[0], Sub_Ncol);
  class_out = matrix_float(Sub_Nlig, Sub_Ncol);

  cpt_H_A     = matrix_float(nclass_pol,nclass_pol);
  cpt_al1     = matrix_float(nclass_pol,nclass_pol);
  cpt_al1_al2 = matrix_float(nclass_pol,nclass_pol);
  class_vec   = matrix_float(nclass_pol,nclass_pol);

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
#pragma omp parallel for private(col)
    for (lig = 0; lig < NligBlock[0]; lig++) 
      for (col = 0; col < Sub_Ncol; col++) 
        Valid[lig][col] = 1.;

/********************************************************************
********************************************************************/
/* DATA PROCESSING */
rewind(fileclass);
if (FlagValid == 1) rewind(in_valid);

n_class=-1;
  
for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  read_block_matrix_float(fileclass, class_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        if ((int) class_in[lig][col] > n_class) n_class = (int) class_in[lig][col];
        }
      }
    }
  } // NbBlock


n_class++;
  
/********************************************************************
********************************************************************/
rewind(fileclass);
if (FlagValid == 1) rewind(in_valid);

Nligg = 0; ligg = 0;

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  read_block_matrix_float(fileclass, class_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(fileH, MH_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(fileA, MA_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(fileAl1, MAl1_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(fileAl2, MAl2_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(fileBe1, MBe1_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(fileBe2, MBe2_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(filep1, Mp1_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(filep2, Mp2_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligg = lig + Nligg;
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      class_out[ligg][col] = 0.;
      if (Valid[lig][col] == 1.) {
        h1 = (MH_in[lig][col] <= lim_H1);
        h2 = (MH_in[lig][col] <= lim_H2);
        a1 = (MA_in[lig][col] <= lim_A);

        /* ZONE 1 (top right)*/
        r1 = !h1 * !a1;
        /* ZONE 2 (bottom right)*/
        r2 = !h1 * a1;
        /* ZONE 3 (top center)*/
        r3 = h1 * !h2 * !a1;
        /* ZONE 4 (bottom center)*/
        r4 = h1 * !h2 * a1;
        /* ZONE 1 (top left)*/
        r5 = h2 * !a1;
        /* ZONE 2 (bottom left)*/
        r6 = h2 * a1;

        /* segment values ranging from 1 to 9 */
        class_H_A = (float) r6*11+r5*10+r4*5+r3*6+r2*1+r1*2;
        class_out[ligg][col] = class_H_A;
        MAl1_in[lig][col] *= pi/180;
        MAl2_in[lig][col] *= pi/180;
        MBe1_in[lig][col] *= pi/180;
        MBe2_in[lig][col] *= pi/180;
        class_al1 = (MAl1_in[lig][col] < pi/4.);  
        bid1 = Mp1_in[lig][col]*cos(MAl1_in[lig][col])+Mp2_in[lig][col]*cos(MAl2_in[lig][col]);
        bid2 = Mp1_in[lig][col]*sin(MAl1_in[lig][col])*cos(MBe1_in[lig][col])+Mp2_in[lig][col]*sin(MAl2_in[lig][col])*cos(MBe2_in[lig][col]);
        class_al1_al2 = bid1 > bid2; 

        if (class_H_A == 0) class_H_A = 0;
        if (class_H_A == 1) class_H_A = 2;
        if (class_H_A == 2) class_H_A = 2;
        if (class_H_A == 5) class_H_A = 0;
        if (class_H_A == 6) class_H_A = 1;
        if (class_H_A == 10) class_H_A = 0;
        if (class_H_A == 11) class_H_A = 0;

        cpt_H_A[(int)class_in[lig][col]][(int)class_H_A] = cpt_H_A[(int)class_in[lig][col]][(int)class_H_A] + 1.;
        cpt_al1[(int)class_in[lig][col]][(int)class_al1] = cpt_al1[(int)class_in[lig][col]][(int)class_al1] + 1.;
        cpt_al1_al2[(int)class_in[lig][col]][(int)class_al1_al2] = cpt_al1_al2[(int)class_in[lig][col]][(int)class_al1_al2] + 1.;
        }
      }
    }
  Nligg += NligBlock[Nb];
  } // NbBlock

  sprintf(filename, "%s%s", out_dir, "id_scatt");
  bmp_wishart(class_out,Sub_Nlig,Sub_Ncol,filename,Colormap_wishart);

/********************************************************************
********************************************************************/

  for(lig=0;lig<n_class;lig++) {
    max = -INIT_MINMAX;
    for(col=0;col<nclass_pol;col++) {
      if(cpt_H_A[lig][col]>max) {
        max = cpt_H_A[lig][col];
        class_vec[lig][cl_H_A] = col;
        }
      }
    }

  for(lig=0;lig<n_class;lig++) {
    max = -INIT_MINMAX;
    for(col=0;col<nclass_pol;col++) {
      if(cpt_al1[lig][col]>max) {
        max = cpt_al1[lig][col];
        class_vec[lig][cl_al1] = col;
        }
      }
    }

  for(lig=0;lig<n_class;lig++) {
    max = -INIT_MINMAX;
    for(col=0;col<nclass_pol;col++) {
      if(cpt_al1_al2[lig][col]>max) {
        max = cpt_al1_al2[lig][col];
        class_vec[lig][cl_al1_al2] = col;
        }
      }
    }

/********************************************************************
********************************************************************/
rewind(fileclass);
if (FlagValid == 1) rewind(in_valid);
Nligg = 0; ligg = 0;

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  read_block_matrix_float(fileclass, class_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

#pragma omp parallel for private(col, ligg)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    if (omp_get_thread_num() == 0) PrintfLine(lig,NligBlock[Nb]);
    ligg = lig + Nligg;
    for (col = 0; col < Sub_Ncol; col++) {
      class_out[ligg][col] = 0.;
      if (Valid[lig][col] == 1.) {
        if( class_vec[(int)class_in[lig][col]][cl_H_A]==2) class_type = 1;
        if( class_vec[(int)class_in[lig][col]][cl_H_A]==0) class_type=6-class_vec[(int)class_in[lig][col]][cl_al1];
        if( class_vec[(int)class_in[lig][col]][cl_H_A]==1) class_type=14-2*class_vec[(int)class_in[lig][col]][cl_al1_al2];
        class_out[ligg][col] = class_type;
        }
      }
    }
  Nligg += NligBlock[Nb];
  } // NbBlock

  sprintf(filename, "%s%s", out_dir, "id_class");
  bmp_wishart(class_out,Sub_Nlig,Sub_Ncol,filename,Colormap_wishart);

/********************************************************************
********************************************************************/
rewind(fileclass);
if (FlagValid == 1) rewind(in_valid);
Nligg = 0; ligg = 0;

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  read_block_matrix_float(fileclass, class_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

#pragma omp parallel for private(col, ligg)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    if (omp_get_thread_num() == 0) PrintfLine(lig,NligBlock[Nb]);
    ligg = lig + Nligg;
    for (col = 0; col < Sub_Ncol; col++) {
      class_out[ligg][col] = 0.;
      if (Valid[lig][col] == 1.) {
        if( class_vec[(int)class_in[lig][col]][cl_H_A]==2) class_type = 1;
        if( class_vec[(int)class_in[lig][col]][cl_H_A]==0) class_type=6-class_vec[(int)class_in[lig][col]][cl_al1];
        if( class_vec[(int)class_in[lig][col]][cl_H_A]==1) class_type=14-2*class_vec[(int)class_in[lig][col]][cl_al1_al2];
        class_out[ligg][col] = (class_type == 1)*2;
        }
      }
    }
  Nligg += NligBlock[Nb];
  } // NbBlock

  sprintf(filename, "%s%s", out_dir, "vol_class");
  bmp_wishart(class_out,Sub_Nlig,Sub_Ncol,filename,Colormap_wishart);

/* OUTPUT FILE OPENING*/
  sprintf(filename, "%svol_class.bin", out_dir);
  if ((out_file = fopen(filename, "wb")) == NULL)
    edit_error("Could not open input file : ", filename);

  write_block_matrix_float(out_file, class_out, Sub_Nlig, Sub_Ncol, 0, 0, Sub_Ncol);

/* OUTPUT FILE CLOSING*/
  fclose(out_file);

/********************************************************************
********************************************************************/
rewind(fileclass);
if (FlagValid == 1) rewind(in_valid);
Nligg = 0; ligg = 0;

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  read_block_matrix_float(fileclass, class_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

#pragma omp parallel for private(col, ligg)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    if (omp_get_thread_num() == 0) PrintfLine(lig,NligBlock[Nb]);
    ligg = lig + Nligg;
    for (col = 0; col < Sub_Ncol; col++) {
      class_out[ligg][col] = 0.;
      if (Valid[lig][col] == 1.) {
        if( class_vec[(int)class_in[lig][col]][cl_H_A]==2) class_type = 1;
        if( class_vec[(int)class_in[lig][col]][cl_H_A]==0) class_type=6-class_vec[(int)class_in[lig][col]][cl_al1];
        if( class_vec[(int)class_in[lig][col]][cl_H_A]==1) class_type=14-2*class_vec[(int)class_in[lig][col]][cl_al1_al2];
        class_out[ligg][col] = (class_type == 12)*12 + (class_type == 5)*5;
        }
      }
    }
  Nligg += NligBlock[Nb];
  } // NbBlock

  sprintf(filename, "%s%s", out_dir, "sgl_class");
  bmp_wishart(class_out,Sub_Nlig,Sub_Ncol,filename,Colormap_wishart);

/* OUTPUT FILE OPENING*/
  sprintf(filename, "%ssgl_class.bin", out_dir);
  if ((out_file = fopen(filename, "wb")) == NULL)
    edit_error("Could not open input file : ", filename);

  write_block_matrix_float(out_file, class_out, Sub_Nlig, Sub_Ncol, 0, 0, Sub_Ncol);

/* OUTPUT FILE CLOSING*/
  fclose(out_file);

/********************************************************************
********************************************************************/
rewind(fileclass);
if (FlagValid == 1) rewind(in_valid);
Nligg = 0; ligg = 0;

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  read_block_matrix_float(fileclass, class_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

#pragma omp parallel for private(col, ligg)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    if (omp_get_thread_num() == 0) PrintfLine(lig,NligBlock[Nb]);
    ligg = lig + Nligg;
    for (col = 0; col < Sub_Ncol; col++) {
      class_out[ligg][col] = 0.;
      if (Valid[lig][col] == 1.) {
        if( class_vec[(int)class_in[lig][col]][cl_H_A]==2) class_type = 1;
        if( class_vec[(int)class_in[lig][col]][cl_H_A]==0) class_type=6-class_vec[(int)class_in[lig][col]][cl_al1];
        if( class_vec[(int)class_in[lig][col]][cl_H_A]==1) class_type=14-2*class_vec[(int)class_in[lig][col]][cl_al1_al2];
        class_out[ligg][col] = (class_type == 14)*14 + (class_type == 6)*6;
        }
      }
    }
  Nligg += NligBlock[Nb];
  } // NbBlock

  sprintf(filename, "%s%s", out_dir, "dbl_class");
  bmp_wishart(class_out,Sub_Nlig,Sub_Ncol,filename,Colormap_wishart);

/* OUTPUT FILE OPENING*/
  sprintf(filename, "%sdbl_class.bin", out_dir);
  if ((out_file = fopen(filename, "wb")) == NULL)
    edit_error("Could not open input file : ", filename);

  write_block_matrix_float(out_file, class_out, Sub_Nlig, Sub_Ncol, 0, 0, Sub_Ncol);

/* OUTPUT FILE CLOSING*/
  fclose(out_file);

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix_float(MH_in, NligBlock[0]);
  free_matrix_float(MA_in, NligBlock[0]);
  free_matrix_float(MAl1_in, NligBlock[0]);
  free_matrix_float(MAl2_in, NligBlock[0]);
  free_matrix_float(MBe1_in, NligBlock[0]);
  free_matrix_float(MBe2_in, NligBlock[0]);
  free_matrix_float(Mp1_in, NligBlock[0]);
  free_matrix_float(Mp2_in, NligBlock[0]);
  free_matrix_float(class_in, NligBlock[0]);
  free_matrix_float(class_out, Sub_Nlig);

*/  
/********************************************************************
********************************************************************/

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);

/********************************************************************
********************************************************************/

  return 1;
}


