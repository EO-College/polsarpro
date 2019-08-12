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

File  : wishart_opt_coh_classifier_all.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2012
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

Description :  Merging the results of the three unsupervised maximum
               likelihood classifications of a dual polarimetric
               interferometric image data set

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
/* Input/Output file pointer arrays */
  FILE  *in_mask[3], *in_class[3], *out_file;

/* Strings */
  char  nom_fich[FilePathLength];
  char  mask_dbl[FilePathLength], mask_vol[FilePathLength], mask_sgl[FilePathLength];
  char  class_dbl[FilePathLength], class_vol[FilePathLength], class_sgl[FilePathLength];
  char  ColorMap27[FilePathLength];

/* Input variables */
  int  nlig,ncol,i,j,k;
  int  coh_avg;
  int  dbl,vol,sgl;

  float **M_Class;
  float **M_Mask;
  float **M_out;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nwishart_opt_coh_classifier_all.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-ms  	input mask file : single bounce scattering\n");
strcat(UsageHelp," (string)	-md  	input mask file : double bounce scattering\n");
strcat(UsageHelp," (string)	-mv  	input mask file : volume scattering\n");
strcat(UsageHelp," (string)	-cs  	input class file : single bounce scattering\n");
strcat(UsageHelp," (string)	-cd  	input class file : double bounce scattering\n");
strcat(UsageHelp," (string)	-cv  	input class file : volume scattering\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (string)	-co27	input colormap27 file\n");
strcat(UsageHelp," (int)   	-avg 	coherence averaging (1/0)\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
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
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ms",str_cmd_prm,mask_sgl,1,UsageHelp);
  get_commandline_prm(argc,argv,"-md",str_cmd_prm,mask_dbl,1,UsageHelp);
  get_commandline_prm(argc,argv,"-mv",str_cmd_prm,mask_vol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-cs",str_cmd_prm,class_sgl,1,UsageHelp);
  get_commandline_prm(argc,argv,"-cd",str_cmd_prm,class_dbl,1,UsageHelp);
  get_commandline_prm(argc,argv,"-cv",str_cmd_prm,class_vol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-co27",str_cmd_prm,ColorMap27,1,UsageHelp);
  get_commandline_prm(argc,argv,"-avg",int_cmd_prm,&coh_avg,1,UsageHelp);
  }

/********************************************************************
********************************************************************/
 
 check_dir(in_dir);
 check_dir(out_dir);
 check_file(mask_dbl);
 check_file(mask_vol);
 check_file(mask_sgl);
 check_file(class_dbl);
 check_file(class_vol);
 check_file(class_sgl);
 check_file(ColorMap27);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/********************************************************************
********************************************************************/
/* INPUT/OUPUT CONFIGURATIONS */

  M_Class  = matrix_float(3,ncol);
  M_Mask  = matrix_float(3,ncol);
  M_out  = matrix_float(nlig,ncol);

  dbl = 0; vol = 1; sgl = 2;

/*******************************************************************/
/* Mask and Class reading then merging */  
/*******************************************************************/
  
 if ((in_mask[dbl] = fopen(mask_dbl,"rb"))==NULL)
  edit_error("Could not open input file : ", nom_fich);

 if ((in_mask[vol] = fopen(mask_vol,"rb"))==NULL)
  edit_error("Could not open input file : ", nom_fich);

 if ((in_mask[sgl] = fopen(mask_sgl,"rb"))==NULL)
  edit_error("Could not open input file : ", nom_fich);

 if ((in_class[dbl] = fopen(class_dbl,"rb"))==NULL)
  edit_error("Could not open input file : ", nom_fich);

 if ((in_class[vol] = fopen(class_vol,"rb"))==NULL)
  edit_error("Could not open input file : ", nom_fich);

 if ((in_class[sgl] = fopen(class_sgl,"rb"))==NULL)
  edit_error("Could not open input file : ", nom_fich);

 for (i=0; i<nlig; i++) {
   PrintfLine(i,nlig);
   for(k=0;k<3;k++) fread(&M_Mask[k][0],sizeof(float),ncol,in_mask[k]);
   for (j=0; j<ncol; j++) 
     for(k=0;k<3;k++) if (M_Mask[k][j] > 0) M_Mask[k][j] = 1.;
   for(k=0;k<3;k++) fread(&M_Class[k][0],sizeof(float),ncol,in_class[k]);
   for (j=0; j<ncol; j++) M_out[i][j] = M_Mask[dbl][j]*M_Class[dbl][j] + M_Mask[vol][j]*(9 + M_Class[vol][j]) + M_Mask[sgl][j]*(18 + M_Class[sgl][j]);
 } 
 for(i=0;i<3;i++) fclose(in_mask[i]);
 for(i=0;i<3;i++) fclose(in_class[i]);

/*******************************************************************/
/* Writing */  
/*******************************************************************/
 if (coh_avg == 0) sprintf(nom_fich,"%swishart_coh_opt_class.bin", out_dir);
 if (coh_avg == 1) sprintf(nom_fich,"%swishart_coh_avg_opt_class.bin", out_dir);
 if ((out_file = fopen(nom_fich,"wb"))==NULL)
  edit_error("Could not open input file : ", nom_fich);

 for (i=0; i<nlig; i++) {
   PrintfLine(i,nlig);
   fwrite(&M_out[i][0], sizeof(float), ncol, out_file);
   } 
 fclose(out_file);

 if (coh_avg == 0) sprintf(nom_fich,"%swishart_coh_opt_class", out_dir);
 if (coh_avg == 1) sprintf(nom_fich,"%swishart_coh_avg_opt_class", out_dir);
 bmp_wishart(M_out,nlig,ncol,nom_fich,ColorMap27);

/********************************************************************
********************************************************************/
 free_matrix_float(M_out,nlig);
 free_matrix_float(M_Mask,3);
 free_matrix_float(M_Class,3);

return 1;
} /*main*/

