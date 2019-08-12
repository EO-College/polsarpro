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

File  : h_alpha_fuzzy_membership.c
Project  : ESA_POLSARPRO
Authors  : Sang-Eun PARK
Version  : 2.0 - Eric POTTIER (08/2011)
Creation : 12/2008
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

Description :  Fuzzyfication of the alpha and entropy parameters

Inputs  : In in_dir directory
alpha.bin, entropy.bin

Outputs : In out_dir directory

Fuzzyfication results :
Mu_Z1.bin, Mu_Z2.bin, Mu_Z3.bin, Mu_Z4.bin, 
Mu_Z5.bin, Mu_Z6.bin, Mu_Z7.bin, Mu_Z8.bin

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
#define Alpha  0
#define H  1

#define z1 0 // top left
#define z2 1 // mid left
#define z3 2 // bottom left
#define z4 3 // top center
#define z5 4 // mid center
#define z6 5 // bottom center
#define z7 6 // top right
#define z8 7 // mid right

#define Nprm  2 // entropy, alpha
#define Nmem  8 // number of zones 

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"
float cal_member(float sig, float Pixl[], float ar_A[], float ar_B[]);

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
  FILE *prm_file[Nprm], *Mu_G_file[Nmem];
  char file_name[FilePathLength];
  char *file_name_prm[Nprm] = 
  { "alpha.bin", "entropy.bin" };
  char *file_name_mem[Nmem] = 
  { "Mu_Z1.bin", "Mu_Z2.bin", "Mu_Z3.bin", "Mu_Z4.bin", 
  "Mu_Z5.bin", "Mu_Z6.bin", "Mu_Z7.bin", "Mu_Z8.bin" };  
  
/* Internal variables */
  int lig, col;
  float sig;  
  float Ci[Nmem][2];

  float pix_Ha[2], Mu_G[Nmem][Nmem];
  int zone,given,aa,bb,cc;
  float nume, deno[Nmem], sum_deno;

/* Matrix arrays */
  float **in_prm, **out_mem;
  float *ValidMask;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nh_alpha_fuzzy_membership.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input dir\n");
strcat(UsageHelp," (string)	-od  	output dir\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (float) 	-sig 	Crisp value\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help  displays this message\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 15) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-sig",flt_cmd_prm,&sig,1,UsageHelp);

  FlagValid = 0;strcpy(file_valid,"");
  get_commandline_prm(argc,argv,"-mask",str_cmd_prm,file_valid,0,UsageHelp);
  if (strcmp(file_valid,"") != 0) FlagValid = 1;
  }

/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < Nprm; Np++) {
  sprintf(file_name, "%s%s", in_dir,file_name_prm[Np]);
  if ((prm_file[Np] = fopen(file_name, "rb")) == NULL)
    printf("Could not open input file : %s", file_name);
  }

  if (FlagValid == 1) {
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);
    rewind(in_valid);
    }
  
/* OUTPUT FILE OPENING*/
  for (Np = 0; Np < Nmem; Np++) {
  sprintf(file_name, "%s%s", out_dir,file_name_mem[Np]);
  if ((Mu_G_file[Np] = fopen(file_name, "wb")) == NULL)
    printf("Could not open output file : %s", file_name);
  }
  
/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */
  ValidMask = vector_float(Ncol);

  in_prm = matrix_float(Nprm, Ncol);
  out_mem = matrix_float(Nmem, Ncol);
    
/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
    for (col = 0; col < Ncol; col++) ValidMask[col] = 1.;

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

/*pre defined prototype points for each zones, Ci */

  Ci[z1][Alpha]=47.5+2.5; Ci[z1][H]=15;
  Ci[z2][Alpha]=47.5-2.5; Ci[z2][H]=15;
  Ci[z3][Alpha]=42.5-2.5; Ci[z3][H]=15;
          
  Ci[z4][Alpha]=50.0+5.0; Ci[z4][H]=85;
  Ci[z5][Alpha]=50.0-5.0; Ci[z5][H]=85;
  Ci[z6][Alpha]=40.0-5.0; Ci[z6][H]=85;
          
  Ci[z7][Alpha]=55.0+5.0; Ci[z7][H]=95;
  Ci[z8][Alpha]=55.0-5.0; Ci[z8][H]=95;


for (lig = 0; lig < Off_lig; lig++) {
  fread(&in_prm[Alpha][0], sizeof(float), Ncol, prm_file[Alpha]);
  fread(&in_prm[H][0], sizeof(float), Ncol, prm_file[H]);
  if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
  }

for (lig = 0; lig < Sub_Nlig; lig++) {
  PrintfLine(lig,Sub_Nlig);
  fread(&in_prm[Alpha][0], sizeof(float), Ncol, prm_file[Alpha]);
  fread(&in_prm[H][0], sizeof(float), Ncol, prm_file[H]);
  if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);

  for (col = 0; col < Sub_Ncol; col++) {
    for (zone=0;zone<Nmem; zone++) out_mem[zone][col]=0.;

    if (ValidMask[col+ Off_col] == 1.) {

      pix_Ha[Alpha]=in_prm[Alpha][col + Off_col];
      pix_Ha[H]=100*in_prm[H][col + Off_col];

      // calculate conditional membership
      for (zone=0;zone<Nmem; zone++) {
        for (given=0;given<Nmem; given++) {
          if (zone == given) Mu_G[zone][given]=0; 
          else Mu_G[zone][given]=cal_member(sig, pix_Ha, Ci[zone], Ci[given]);
          }
        }

      // calculate membership degree
      for (zone=0;zone<Nmem; zone++) {
        nume=1;
        for (cc = 0; cc<Nmem; cc++) deno[cc]=1;
        sum_deno=0;
        for (aa=0; aa<Nmem; aa++) {
          if (aa != zone) nume=nume*Mu_G[zone][aa];
          for (bb=0; bb<Nmem; bb++) {
            if (aa != bb) deno[aa]=deno[aa]*Mu_G[aa][bb];
            }
          sum_deno=sum_deno+deno[aa];
          }  
        out_mem[zone][col]=nume/sum_deno;
        }
      } /* valid */
    } /* col */

  // Write membership degree to file
  for (Np = 0; Np < Nmem; Np++) fwrite(&out_mem[Np][0], sizeof(float), Sub_Ncol, Mu_G_file[Np]);

  } /* lig */

/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  fclose(prm_file[Alpha]); fclose(prm_file[H]);

/* OUTPUT FILE CLOSING*/
  for (Np = 0; Np < Nmem; Np++) fclose(Mu_G_file[Np]);

/********************************************************************
********************************************************************/

  return 1;
}

/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/

/*******************************************************************************
Routine  : cal_member
Authors  : Sang-Eun PARK
Creation : 12/2008
Update  : 
*******************************************************************************/
float cal_member(float sig, float Pixl[], float ar_A[], float ar_B[])
{
  float dist_xA, dist_xB, dist_AB, dist_BA;
  float rho,vec_BA[2],vec_Bx[2],result;
  
  dist_xA= pow((Pixl[0]-ar_A[0]),2) + pow((Pixl[1]-ar_A[1]),2) ;
  dist_xB= pow((Pixl[0]-ar_B[0]),2) + pow((Pixl[1]-ar_B[1]),2) ;
  dist_AB= pow((ar_A[0]-ar_B[0]),2) + pow((ar_A[1]-ar_B[1]),2) ;
  dist_BA= pow((ar_B[0]-ar_A[0]),2) + pow((ar_B[1]-ar_A[1]),2) ;
  rho=( dist_xA - dist_xB )/dist_AB ;
  
  if (rho > 1-sig) result=0;
  else if (rho < sig-1) result=1;
  else {
  vec_BA[0]=ar_A[0]-ar_B[0]; vec_BA[1]=ar_A[1]-ar_B[1];
  vec_Bx[0]=Pixl[0]-ar_B[0]; vec_Bx[1]=Pixl[1]-ar_B[1];
  result=( (vec_BA[0]*vec_Bx[0]+vec_BA[1]*vec_Bx[1]) - 0.5*sig*dist_BA ) / ( (1-sig)*dist_BA );
  }
  
  return(result);
}


