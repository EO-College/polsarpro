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

File  : PCT_engine.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 2.0
Creation : 12/2007
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

*--------------------------------------------------------------------

Description :  Polarization Coherence Tomography procedure

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


/* Input/Output file pointer arrays */
  FILE *gamma_file, *height_file, *topo_file, *Kz_file, *Kv_file;
  FILE *out_f0, *out_f1, *out_f2, *out_a10, *out_a20;
  FILE *out_file, *out_q1, *out_q2, *out_q3;
  FILE *in_q1, *in_q2, *in_q3;

/* Strings */
  char file_name[FilePathLength];
  char file_height[FilePathLength], file_kv[FilePathLength], file_kz[FilePathLength];
  char file_gamma[FilePathLength], file_topo[FilePathLength];
  char file_tomo_asc[FilePathLength], file_tomo_bin[FilePathLength];

/* Input variables */
  int Ncol;  /* Initial image nb of lines and rows */
  int Off_lig, Off_col;  /* Lines and rows offset values */
  int Sub_Nlig, Sub_Ncol;  /* Sub-image nb of lines and rows */

  int lig, col, szt, zdex;
  float dh, zp, mask, Hmax;
  float tomomin, tomomax;
  cplx gamk, gam, top, kv;

/* Matrix arrays */
  float *q1, *q2, *q3;
  float *f0b, *f1b, *f2b;
  float *a10b, *a20b;
  float *Gamma;
  float *Height;
  float *Topo;
  float *Kz, *Kv;
  float ***tom;
  
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nheight_estimation_inversion_procedure_RVOG.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-ifg 	input gamma file\n");
strcat(UsageHelp," (string)	-ifh 	input height file\n");
strcat(UsageHelp," (string)	-ift 	input topo file\n");
strcat(UsageHelp," (string)	-ifkv	input kv file\n");
strcat(UsageHelp," (string)	-ifkz	input kz file\n");
strcat(UsageHelp," (int)   	-nc  	Number of Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (string)	-oasc	output asc file\n");
strcat(UsageHelp," (string)	-obin	output bin file\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 27) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifg",str_cmd_prm,file_gamma,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifh",str_cmd_prm,file_height,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ift",str_cmd_prm,file_topo,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifkv",str_cmd_prm,file_kv,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifkz",str_cmd_prm,file_kz,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nc",int_cmd_prm,&Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-oasc",str_cmd_prm,file_tomo_asc,1,UsageHelp);
  get_commandline_prm(argc,argv,"-obin",str_cmd_prm,file_tomo_bin,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_dir(out_dir);
  check_file(file_gamma);
  check_file(file_height);
  check_file(file_topo);
  check_file(file_kv);
  check_file(file_kz);
  check_file(file_tomo_asc);
  check_file(file_tomo_bin);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/********************************************************************
********************************************************************/
/* MATRIX DECLARATION */
  Gamma = vector_float(2*Ncol);
  Topo = vector_float(Ncol);
  Height = vector_float(Ncol);
  Kz = vector_float(Ncol);
  Kv = vector_float(Ncol);
  f0b = vector_float(Sub_Ncol);
  f1b = vector_float(Sub_Ncol);
  f2b = vector_float(Sub_Ncol);
  a10b = vector_float(Sub_Ncol);
  a20b = vector_float(Sub_Ncol);
  q1 = vector_float(Sub_Ncol);
  q2 = vector_float(Sub_Ncol);
  q3 = vector_float(Sub_Ncol);

/*******************************************************************/
/*******************************************************************/

/* INPUT/OUTPUT FILE OPENING*/
  sprintf(file_name, "%s", file_gamma);
  if ((gamma_file = fopen(file_name, "rb")) == NULL)
  edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s", file_height);
  if ((height_file = fopen(file_name, "rb")) == NULL)
  edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s", file_topo);
  if ((topo_file = fopen(file_name, "rb")) == NULL)
  edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s", file_kv);
  if ((Kv_file = fopen(file_name, "rb")) == NULL)
  edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s", file_kz);
  if ((Kz_file = fopen(file_name, "rb")) == NULL)
  edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "PCT_f0.bin");
  if ((out_f0 = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open output file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "PCT_f1.bin");
  if ((out_f1 = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open output file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "PCT_f2.bin");
  if ((out_f2 = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open output file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "PCT_a10.bin");
  if ((out_a10 = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open output file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "PCT_a20.bin");
  if ((out_a20 = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open output file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "PCT_q1.bin");
  if ((out_q1 = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open output file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "PCT_q2.bin");
  if ((out_q2 = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open output file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "PCT_q3.bin");
  if ((out_q3 = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open output file : ", file_name);

/*******************************************************************/
/*******************************************************************/
/* OFFSET LINES READING */
  for (lig = 0; lig < Off_lig; lig++)
  {  
  fread(&Gamma[0], sizeof(float), 2*Ncol, gamma_file);
  fread(&Height[0], sizeof(float), Ncol, height_file);
  fread(&Topo[0], sizeof(float), Ncol, topo_file);
  fread(&Kv[0], sizeof(float), Ncol, Kv_file);
  fread(&Kz[0], sizeof(float), Ncol, Kz_file);
  }

/*******************************************************************/
/*******************************************************************/

  Hmax = 0.;

/* FILES READING */
for (lig = 0; lig < Sub_Nlig; lig++) {
  PrintfLine(lig,Sub_Nlig);
  fread(&Gamma[0], sizeof(float), 2*Ncol, gamma_file);
  fread(&Height[0], sizeof(float), Ncol, height_file);
  fread(&Topo[0], sizeof(float), Ncol, topo_file);
  fread(&Kv[0], sizeof(float), Ncol, Kv_file);
  fread(&Kz[0], sizeof(float), Ncol, Kz_file);
  for (col = 0; col < Sub_Ncol; col++) {
    Gamma[2*col] = Gamma[2*(col+ Off_col)];
    Gamma[2*col+1] = Gamma[2*(col+ Off_col)+1];
    Height[col] = Height[col+ Off_col] + eps;
    Topo[col] = Topo[col+ Off_col];
    Kv[col] = Kv[col+ Off_col];
    Kz[col] = Kz[col+ Off_col];
    }

  for (col = 0; col < Sub_Ncol; col++) {
    if (Hmax <= Height[col]) Hmax = Height[col];

    //Calculate Legendre Functions for each pixel
    f0b[col] = sin(Kv[col])/(Kv[col]+eps);
    f1b[col] = (sin(Kv[col])/(Kv[col]+eps)-cos(Kv[col]))/(Kv[col]+eps);
    f2b[col] = 3.*cos(Kv[col])/(Kv[col]*Kv[col]+eps);
    f2b[col] += -sin(Kv[col])*(3.-1.5*Kv[col]*Kv[col])/(Kv[col]*Kv[col]*Kv[col]+eps);
    f2b[col] += -sin(Kv[col])/(2.*Kv[col]+eps);
    
    //Phase shifting of coherence
    gam.re = Gamma[2*col]; gam.im = Gamma[2*col+1];
    top.re = cos(Topo[col]*pi/180.); top.im = sin(Topo[col]*pi/180.);
    kv.re = cos(Kv[col]); kv.im = -sin(Kv[col]);
    gamk = cmul(gam, cconj(top));
    gamk = cmul(gamk,kv);
    
    //Calculation of Legendre Coefficients
    a10b[col] = cimg(gamk)/(f1b[col]+eps);
    a20b[col] = (crel(gamk)-f0b[col])/(f2b[col]+eps);

    //Tomographic Reconstruction
    q1[col] = 1.-a10b[col]+a20b[col];
    q2[col] = (2.*a10b[col]-6.*a20b[col])/Height[col];
    q3[col] = (6.*a20b[col])/(Height[col]*Height[col]+eps);
    } /* col */

  fwrite(&f0b[0], sizeof(float), Sub_Ncol, out_f0);
  fwrite(&f1b[0], sizeof(float), Sub_Ncol, out_f1);
  fwrite(&f2b[0], sizeof(float), Sub_Ncol, out_f2);
  fwrite(&a10b[0], sizeof(float), Sub_Ncol, out_a10);
  fwrite(&a20b[0], sizeof(float), Sub_Ncol, out_a20);
  fwrite(&q1[0], sizeof(float), Sub_Ncol, out_q1);
  fwrite(&q2[0], sizeof(float), Sub_Ncol, out_q2);
  fwrite(&q3[0], sizeof(float), Sub_Ncol, out_q3);
  } /* lig */

  fclose(out_f0);
  fclose(out_f1);
  fclose(out_f2);
  fclose(out_a10);
  fclose(out_a20);
  fclose(out_q1);
  fclose(out_q2);
  fclose(out_q3);

/*******************************************************************/
/*******************************************************************/
/* HEIGHT MAX EVALUATION */
  
  //set up maximum height and height increment for tomography
  Hmax = Hmax + 2.; //add a 2m margin at the top
  dh = 0.2; //height increment
  szt = floor(0.5 + Hmax/dh); //size of vertical array used for tomography

/*******************************************************************/
/*******************************************************************/
/* HEIGHT INVERSION */
  sprintf(file_name, "%s%s", out_dir, "PCT_q1.bin");
  if ((in_q1 = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open output file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "PCT_q2.bin");
  if ((in_q2 = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open output file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "PCT_q3.bin");
  if ((in_q3 = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open output file : ", file_name);

  tom = matrix3d_float(szt,Sub_Nlig, Sub_Ncol);
  tomomin = INIT_MINMAX;
  tomomax = -INIT_MINMAX;

  for (zdex = 0; zdex < szt; zdex++) {
    PrintfLine(zdex,szt);
    zp = ((float)zdex + 1.) * dh;
    rewind(height_file);
    rewind(in_q1); rewind(in_q2); rewind(in_q3);
    for (lig = 0; lig < Off_lig; lig++) fread(&Height[0], sizeof(float), Ncol, height_file);
    for (lig = 0; lig < Sub_Nlig; lig++) {
      fread(&Height[0], sizeof(float), Ncol, height_file);
      fread(&q1[0], sizeof(float), Sub_Ncol, in_q1);
      fread(&q2[0], sizeof(float), Sub_Ncol, in_q2);
      fread(&q3[0], sizeof(float), Sub_Ncol, in_q3);
      for (col = 0; col < Sub_Ncol; col++) Height[col] = Height[col+ Off_col] + eps;
      for (col = 0; col < Sub_Ncol; col++) {
        mask = 0.; if (zp <= Height[col]) mask = 1.;
        tom[zdex][lig][col]=mask*(q1[col]+q2[col]*zp+q3[col]*zp*zp)/Height[col]; //quadratic approximation
        if (tom[zdex][lig][col] <= tomomin) tomomin = tom[zdex][lig][col];
        if (tomomax < tom[zdex][lig][col]) tomomax = tom[zdex][lig][col];
        } /* col */
      } /* lig */
    } /* zdex */

/*******************************************************************/
/*******************************************************************/
/* SAVING FILES */

  sprintf(file_name, "%s", file_tomo_asc);
  if ((out_file = fopen(file_name, "w")) == NULL)
  edit_error("Could not open input file : ", file_name);

  fprintf(out_file, "Nrow\n");
  fprintf(out_file, "%i\n", Sub_Nlig);
  fprintf(out_file, "---------\n");
  fprintf(out_file, "Ncol\n");
  fprintf(out_file, "%i\n", Sub_Ncol);
  fprintf(out_file, "---------\n");
  fprintf(out_file, "Nz\n");
  fprintf(out_file, "%i\n", szt);
  fprintf(out_file, "---------\n");
  fprintf(out_file, "Dh\n");
  fprintf(out_file, "%f\n", dh);
  fprintf(out_file, "---------\n");
  fprintf(out_file, "Hmax\n");
  fprintf(out_file, "%f\n", Hmax);
  fprintf(out_file, "---------\n");
  fprintf(out_file, "Tomo Min\n");
  fprintf(out_file, "%f\n", tomomin);
  fprintf(out_file, "---------\n");
  fprintf(out_file, "Tomo Max\n");
  fprintf(out_file, "%f\n", tomomax);
  fclose(out_file);

/*******************************************************************/
/*******************************************************************/
  sprintf(file_name, "%s", file_tomo_bin);
  if ((out_file = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open output file : ", file_name);

  for (zdex = 0; zdex < szt; zdex++) {
    PrintfLine(zdex,szt);
    for (lig = 0; lig < Sub_Nlig; lig++)
    fwrite(&tom[zdex][lig][0], sizeof(float), Sub_Ncol, out_file);
    }

  fclose(out_file);

return 1;
}

