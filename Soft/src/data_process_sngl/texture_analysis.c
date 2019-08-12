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

File   : texture_analysis.c
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

Description :  Calculates the texture analysis of a binary data file

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

/* LOCAL VARIABLES */
  FILE *fileinput, *fileoutput;
  char FileInput[FilePathLength], FileOutput[FilePathLength];
  char InputFormat[10], OutputFormat[10];
  char TextAnal[20];

/* Internal variables */
  int lig, col, k, l;
  int ligDone = 0;
  int idxY, idXy;

  double value, mean, mean2;
  double Mmean, Mmean2;
  float xr, xi;

/* Matrix arrays */
  float **bufferdatacmplx;
  float **bufferdatafloat;
  int **bufferdataint;
  float **M_in;
  float **M_out;
//  float *mediandata;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ntexture_analysis.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input file\n");
strcat(UsageHelp," (string)	-of  	output file\n");
strcat(UsageHelp," (string)	-ta  	texture analysis (VI, VA, VL, U)\n");
strcat(UsageHelp," (string)	-idf 	input data format (cmplx, float, int)\n");
strcat(UsageHelp," (string)	-odf 	output data format (real, imag, mod, mod2, db, pha)\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-inc 	Initial Number of Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
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

if(argc < 25) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,FileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ta",str_cmd_prm,TextAnal,1,UsageHelp);
  get_commandline_prm(argc,argv,"-idf",str_cmd_prm,InputFormat,1,UsageHelp);
  get_commandline_prm(argc,argv,"-odf",str_cmd_prm,OutputFormat,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-inc",int_cmd_prm,&Ncol,1,UsageHelp);
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
  }

/********************************************************************
********************************************************************/

  check_file(FileInput);
  check_file(FileOutput);
  if (FlagValid == 1) check_file(file_valid);
  
  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT FILE OPENING*/
  if ((fileinput = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  if ((fileoutput = fopen(FileOutput, "wb")) == NULL)
  edit_error("Could not open output file : ", FileOutput);

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

  if (strcmp(InputFormat,"cmplx")==0) {
    /* bufferdatacmplx = 2*(Nlig+NwinL)*(Ncol+NwinC) */
    NBlockA += 2*(Ncol+NwinC); NBlockB += 2*NwinL*(Ncol+NwinC);
    }
  if (strcmp(InputFormat,"float")==0) {
    /* bufferdatafloat = (Nlig+NwinL)*(Ncol+NwinC) */
    NBlockA += (Ncol+NwinC); NBlockB += NwinL*(Ncol+NwinC);
    }
  if (strcmp(InputFormat,"int")==0) {
    /* bufferdatacmplx = 2*(Nlig+NwinL)*(Ncol+NwinC) */
    NBlockA += (Ncol+NwinC); NBlockB += NwinL*(Ncol+NwinC);
    }
    
  /* Min = (Nlig+NwinL)*(Ncol+NwinC) */
  NBlockA += (Ncol+NwinC); NBlockB += NwinL*(Ncol+NwinC);
  /* Mout = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  
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
  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   

  Valid = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);

  if (strcmp(InputFormat,"cmplx")==0) bufferdatacmplx = matrix_float(NligBlock[0] + NwinL, 2*(Ncol + NwinC));
  if (strcmp(InputFormat,"float")==0) bufferdatafloat = matrix_float(NligBlock[0] + NwinL, Ncol + NwinC);
  if (strcmp(InputFormat,"int")==0) bufferdataint = matrix_int(NligBlock[0] + NwinL, Ncol + NwinC);
  
  M_in = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);
  M_out = matrix_float(NligBlock[0], Sub_Ncol);
//  mediandata = vector_float(NwinL * NwinC);

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

  if (strcmp(InputFormat,"cmplx")==0) {
    read_block_matrix_cmplx(fileinput, bufferdatacmplx, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    xr = xi = 0.;
#pragma omp parallel for private(col) firstprivate(xr,xi) shared(ligDone)
    for (lig = 0; lig < NligBlock[Nb]+NwinL; lig++) {
      ligDone++;
      if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
      for (col = 0; col < Sub_Ncol+NwinC; col++) {
        M_in[lig][col] = 0.;
        if (Valid[lig][col] == 1.) {
          if (strcmp(OutputFormat,"real")==0) M_in[lig][col] = bufferdatacmplx[lig][2*col];
          if (strcmp(OutputFormat,"imag")==0) M_in[lig][col] = bufferdatacmplx[lig][2*col+1];
          if (strcmp(OutputFormat,"mod")==0) {
            xr = bufferdatacmplx[lig][2*col];
            xi = bufferdatacmplx[lig][2*col+1];
            M_in[lig][col] = sqrt(xr*xr+xi*xi);
            }
          if (strcmp(OutputFormat,"mod2")==0) {
            xr = bufferdatacmplx[lig][2*col];
            xi = bufferdatacmplx[lig][2*col+1];
            M_in[lig][col] = xr*xr+xi*xi;
            }
          if (strcmp(OutputFormat,"pha")==0) {
            xr = bufferdatacmplx[lig][2*col];
            xi = bufferdatacmplx[lig][2*col+1];
            M_in[lig][col] = atan2(xi,xr+eps)*180./pi;
            }
          if (strcmp(OutputFormat,"db")==0) {
            xr = bufferdatacmplx[lig][2*col];
            xi = bufferdatacmplx[lig][2*col+1];
            M_in[lig][col] = sqrt(xr*xr+xi*xi);
            if (M_in[lig][col] < eps) M_in[lig][col] = eps;
            M_in[lig][col] = 20. * log10(M_in[lig][col]);
            }  
          }
        }
      }
    }

  if (strcmp(InputFormat,"float")==0) {
    read_block_matrix_float(fileinput, bufferdatafloat, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    xr = xi = 0.;
#pragma omp parallel for private(col) firstprivate(xr,xi) shared(ligDone)
    for (lig = 0; lig < NligBlock[Nb]+NwinL; lig++) {
      ligDone++;
      if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
      for (col = 0; col < Sub_Ncol+NwinC; col++) {
        M_in[lig][col] = 0.;
        if (Valid[lig][col] == 1.) {
          if (strcmp(OutputFormat,"real")==0) M_in[lig][col] = bufferdatafloat[lig][col];
          if (strcmp(OutputFormat,"imag")==0) M_in[lig][col] = 0.;
          if (strcmp(OutputFormat,"mod")==0) {
            xr = bufferdatafloat[lig][col];
            M_in[lig][col] = sqrt(xr*xr);
            }
          if (strcmp(OutputFormat,"mod2")==0) {
            xr = bufferdatafloat[lig][col];
            M_in[lig][col] = xr*xr;
            }
          if (strcmp(OutputFormat,"pha")==0) M_in[lig][col] = 0.;
          if (strcmp(OutputFormat,"db")==0) {
            xr = bufferdatafloat[lig][col];
            M_in[lig][col] = sqrt(xr*xr);
            if (M_in[lig][col] < eps) M_in[lig][col] = eps;
            M_in[lig][col] = 20. * log10(M_in[lig][col]);
            }  
          }
        }
      }
    }

  if (strcmp(InputFormat,"int")==0) {
    read_block_matrix_int(fileinput, bufferdataint, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    xr = xi = 0.;
#pragma omp parallel for private(col) firstprivate(xr,xi) shared(ligDone)
    for (lig = 0; lig < NligBlock[Nb]+NwinL; lig++) {
      ligDone++;
      if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
      for (col = 0; col < Sub_Ncol+NwinC; col++) {
        M_in[lig][col] = 0.;
        if (Valid[lig][col] == 1.) {
          if (strcmp(OutputFormat,"real")==0) M_in[lig][col] = (float) bufferdataint[lig][col];
          if (strcmp(OutputFormat,"imag")==0) M_in[lig][col] = 0.;
          if (strcmp(OutputFormat,"mod")==0) {
            xr = (float) bufferdataint[lig][col];
            M_in[lig][col] = sqrt(xr*xr);
            }
          if (strcmp(OutputFormat,"mod2")==0) {
            xr = (float) bufferdataint[lig][col];
            M_in[lig][col] = xr*xr;
            }
          if (strcmp(OutputFormat,"pha")==0) M_in[lig][col] = 0.;
          if (strcmp(OutputFormat,"db")==0) {
            xr = (float) bufferdataint[lig][col];
            M_in[lig][col] = sqrt(xr*xr);
            if (M_in[lig][col] < eps) M_in[lig][col] = eps;
            M_in[lig][col] = 20. * log10(M_in[lig][col]);
            }  
          }
        }
      }
    }

value = mean = mean2 = Mmean = Mmean2 = 0.;
#pragma omp parallel for private(col, Nvalid, k, l, idxY, idXy) firstprivate(value, mean, mean2, Mmean, Mmean2) shared(ligDone)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      M_out[lig][col] = 0.;

      if (strcmp(TextAnal,"VI")==0) {
        if (col == 0) {
          Nvalid = 0.; Mmean = 0.; Mmean2 = 0.;
          for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
            idxY = NwinLM1S2+lig+k;
            for (l = -NwinCM1S2; l < 1 +NwinCM1S2; l++) {
              idXy = NwinCM1S2+col+l;
              value = M_in[idxY][idXy]*Valid[idxY][idXy];
              Mmean += value; Mmean2 += value*value;
              Nvalid += Valid[idxY][idXy];
              }
            }
          } else {
          for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
            idxY = NwinLM1S2+lig+k;
            value = M_in[idxY][col-1]*Valid[idxY][col-1];
            Mmean -= value; Mmean2 -= value*value;         
            value = M_in[idxY][NwinC-1+col]*Valid[idxY][NwinC-1+col];
            Mmean += value; Mmean2 += value*value;
            Nvalid = Nvalid - Valid[idxY][col-1] + Valid[idxY][NwinC-1+col];
            }
          }
        if (Nvalid != 0.) mean = Mmean/Nvalid; else mean = INIT_MINMAX;
        if (Nvalid != 0.) mean2 = (Mmean2/Nvalid) - mean*mean; else mean2 = INIT_MINMAX;
        M_out[lig][col] = mean2 / (mean * mean + eps);
        }

      if (strcmp(TextAnal,"VA")==0) {
        if (col == 0) {
          Nvalid = 0.; Mmean = 0.; Mmean2 = 0.;
          for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
            idxY = NwinLM1S2+lig+k;
            for (l = -NwinCM1S2; l < 1 +NwinCM1S2; l++) {
              idXy = NwinCM1S2+col+l;
              value = M_in[idxY][idXy]*Valid[idxY][idXy];
              Mmean += value; Mmean2 += sqrt(fabs(value));
              Nvalid += Valid[idxY][idXy];
              }
            }
          } else {
          for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
            idxY = NwinLM1S2+lig+k;
            value = M_in[idxY][col-1]*Valid[idxY][col-1];
            Mmean -= value; Mmean2 -= sqrt(fabs(value));
            value = M_in[idxY][NwinC-1+col]*Valid[idxY][NwinC-1+col];
            Mmean += value; Mmean2 += sqrt(fabs(value));
            Nvalid = Nvalid - Valid[idxY][col-1] + Valid[idxY][NwinC-1+col];
            }
          }
        if (Nvalid != 0.) mean = Mmean/Nvalid; else mean = INIT_MINMAX;
        if (Nvalid != 0.) mean2 = (Mmean2/Nvalid) - mean*mean; else mean2 = INIT_MINMAX;
        M_out[lig][col] = mean / (mean2 * mean2 + eps);
        }

      if (strcmp(TextAnal,"VL")==0) {
        if (col == 0) {
          Nvalid = 0.; Mmean = 0.; Mmean2 = 0.;
          for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
            idxY = NwinLM1S2+lig+k;
            for (l = -NwinCM1S2; l < 1 +NwinCM1S2; l++) {
              idXy = NwinCM1S2+col+l;
              value = log(fabs(M_in[idxY][idXy]+eps))*Valid[idxY][idXy];
              Mmean += value; Mmean2 += value*value;
              Nvalid += Valid[idxY][idXy];
              }
            }
          } else {
          for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
            idxY = NwinLM1S2+lig+k;
            value = log(fabs(M_in[idxY][col-1]+eps))*Valid[idxY][col-1];
            Mmean -= value; Mmean2 -= value*value;
            value = log(fabs(M_in[idxY][NwinC-1+col]+eps))*Valid[idxY][NwinC-1+col];
            Mmean += value; Mmean2 += value*value;
            Nvalid = Nvalid - Valid[idxY][col-1] + Valid[idxY][NwinC-1+col];
            }
          }
        if (Nvalid != 0.) mean = Mmean/Nvalid; else mean = INIT_MINMAX;
        if (Nvalid != 0.) mean2 = (Mmean2/Nvalid) - mean*mean; else mean2 = INIT_MINMAX;
        M_out[lig][col] = mean2;
        }

      if (strcmp(TextAnal,"U")==0) {
        if (col == 0) {
          Nvalid = 0.; Mmean = 0.; Mmean2 = 0.;
          for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
            idxY = NwinLM1S2+lig+k;
            for (l = -NwinCM1S2; l < 1 +NwinCM1S2; l++) {
              idXy = NwinCM1S2+col+l;
              value = M_in[idxY][idXy];
              Mmean += value*Valid[idxY][idXy]; Mmean2 += log(fabs(value)+eps)*Valid[idxY][idXy];
              Nvalid += Valid[idxY][idXy];
              }
            }
          } else {
          for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
            idxY = NwinLM1S2+lig+k;
            value = M_in[idxY][col-1];
            Mmean -= value*Valid[idxY][col-1]; Mmean2 -= log(fabs(value)+eps)*Valid[idxY][col-1];
            value = M_in[idxY][NwinC-1+col];
            Mmean += value*Valid[idxY][NwinC-1+col]; Mmean2 += log(fabs(value)+eps)*Valid[idxY][NwinC-1+col];
            Nvalid = Nvalid - Valid[idxY][col-1] + Valid[idxY][NwinC-1+col];
            }
          }
        if (Nvalid != 0.) mean = Mmean/Nvalid; else mean = INIT_MINMAX;
        if (Nvalid != 0.) mean2 = Mmean2/Nvalid; else mean2 = INIT_MINMAX;
        M_out[lig][col] = mean2 - log(fabs(mean)+eps);
        }

      }
    }

  write_block_matrix_float(fileoutput, M_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0] + NwinL);

  free_matrix_float(M_in, NligBlock[0] + NwinL);
  free_matrix_float(M_out, NligBlock[0]);
  if (strcmp(InputFormat,"cmplx")==0) free_matrix_float(bufferdatacmplx,NligBlock[0] + NwinL);
  if (strcmp(InputFormat,"float")==0) free_matrix_float(bufferdatafloat,NligBlock[0] + NwinL);
  if (strcmp(InputFormat,"int")==0) free_matrix_int(bufferdataint,NligBlock[0] + NwinL);
  free_vector_float(mediandata);

*/  
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
   fclose(fileoutput);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  fclose(fileinput);

/********************************************************************
********************************************************************/

  return 1;
}


