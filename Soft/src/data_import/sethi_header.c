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

File     : sethi_header.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 02/2017
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

Description :  extract information from SETHI header (.ent) file

********************************************************************/
/* C INCLUDES */
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
/*                                                                            */
{

/* LOCAL VARIABLES */
  FILE *ftmp, *fconfig;
  char FileTmp[FilePathLength], FileConfig[FilePathLength];
  char Buf[65536];
  char Tmp[65536];
  char *p1, *p2;

  int NumberOfLines, NumberOfSamples;
  float RangeResol, AzimutResol;
  float DepressionAngle, DistanceRadar, HauteurRadar;
  float Isurf, Wdist, Wazi;
  float ResolDistApod, ResolDoppApod;  
  float PixRow, PixCol, PixSurf;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nsethi_header.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input header file\n");
strcat(UsageHelp," (string)	-of  	output config file\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 5) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,FileTmp,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileConfig,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(FileTmp);
  check_file(FileConfig);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/*******************************************************************/
/*******************************************************************/

  if ((ftmp = fopen(FileTmp, "r")) == NULL)
    edit_error("Could not open input file : ", FileTmp);

  rewind(ftmp);
  while( !feof(ftmp) ) {
    fgets(&Buf[0], 1024, ftmp); 
    if (strstr(Buf,"Nb_case_par_ligne_look") != NULL) {
      p1 = strstr(Buf,"= ");
      strcpy(Tmp, ""); strncat(Tmp, &p1[2], strlen(p1) - 2);
      NumberOfSamples = atoi(Tmp);  
      }
    if (strstr(Buf,"Nb_ligne_look") != NULL) {
      p1 = strstr(Buf,"= ");
      p2 = strstr(Buf," + 1 ");
      strcpy(Tmp, ""); strncat(Tmp, &p1[2], strlen(p1) - strlen(p2) - 2);
      NumberOfLines = atoi(Tmp);  
      }
    if (strstr(Buf,"Intercase_radial_look") != NULL) {
      p1 = strstr(Buf,"= ");
      p2 = strstr(Buf," m ");
      strcpy(Tmp, ""); strncat(Tmp, &p1[2], strlen(p1) - strlen(p2) - 2);
      PixCol = atof(Tmp);  
      }
    if (strstr(Buf,"Interligne_azimut_look") != NULL) {
      p1 = strstr(Buf,"= ");
      p2 = strstr(Buf," m ");
      strcpy(Tmp, ""); strncat(Tmp, &p1[2], strlen(p1) - strlen(p2) - 2);
      PixRow = atof(Tmp);  
      }
    if (strstr(Buf,"Apodisation_distance") != NULL) {
      if (strstr(Buf,"rectangulaire") != NULL) {
        Isurf = 1.00; Wdist = 0.89; Wazi = 0.89;
        } else {
        Isurf = 1.36; Wdist = 1.30; Wazi = 1.30;
        }
      }
    if (strstr(Buf,"Resol_dist_rad_apod") != NULL) {
      p1 = strstr(Buf,"= ");
      p2 = strstr(Buf," m ");
      strcpy(Tmp, ""); strncat(Tmp, &p1[2], strlen(p1) - strlen(p2) - 2);
      ResolDistApod = atof(Tmp);  
      }
    if (strstr(Buf,"Resol_dopp_apod") != NULL) {
      p1 = strstr(Buf,"= ");
      p2 = strstr(Buf," m ");
      strcpy(Tmp, ""); strncat(Tmp, &p1[2], strlen(p1) - strlen(p2) - 2);
      ResolDoppApod = atof(Tmp);  
      }    
    if (strstr(Buf,"Surface_resolution") != NULL) {
      if (strstr(Buf,"non documente") != NULL) {
        PixSurf = (ResolDistApod*ResolDoppApod*Isurf*Isurf)/(Wdist*Wazi);
        } else {    
        p1 = strstr(Buf,"= ");
        p2 = strstr(Buf," m");
        strcpy(Tmp, ""); strncat(Tmp, &p1[2], strlen(p1) - strlen(p2) - 2);
        PixSurf = atof(Tmp);  
        }
      }
    if (strstr(Buf,"Resol_dist_rad") != NULL) {
      p1 = strstr(Buf,"= ");
      p2 = strstr(Buf," m ");
      strcpy(Tmp, ""); strncat(Tmp, &p1[2], strlen(p1) - strlen(p2) - 2);
      RangeResol = atof(Tmp);  
      }
    if (strstr(Buf,"Resol_dopp") != NULL) {
      p1 = strstr(Buf,"= ");
      p2 = strstr(Buf," m ");
      strcpy(Tmp, ""); strncat(Tmp, &p1[2], strlen(p1) - strlen(p2) - 2);
      AzimutResol = atof(Tmp);  
      }
    if (strstr(Buf,"Depression") != NULL) {
      p1 = strstr(Buf,"= ");
      p2 = strstr(Buf," deg");
      strcpy(Tmp, ""); strncat(Tmp, &p1[2], strlen(p1) - strlen(p2) - 2);
      DepressionAngle = atof(Tmp);  
      }
    if (strstr(Buf,"Distance_radar_1ere_case") != NULL) {
      p1 = strstr(Buf,"= ");
      p2 = strstr(Buf," m");
      strcpy(Tmp, ""); strncat(Tmp, &p1[2], strlen(p1) - strlen(p2) - 2);
      DistanceRadar = atof(Tmp);  
      }
    if (strstr(Buf,"Hauteur_radar_sol_moyenne") != NULL) {
      p1 = strstr(Buf,"= ");
      p2 = strstr(Buf," m ");
      strcpy(Tmp, ""); strncat(Tmp, &p1[2], strlen(p1) - strlen(p2) - 2);
      HauteurRadar = atof(Tmp);  
      }
  }
   
/*******************************************************************/
/*******************************************************************/
  if ((fconfig = fopen(FileConfig, "w")) == NULL)
    edit_error("Could not open configuration file : ", FileConfig);
    
  fprintf(fconfig,"%.3f\n",DepressionAngle);
  fprintf(fconfig,"%.3f\n",AzimutResol);
  fprintf(fconfig,"%.3f\n",RangeResol);
  fprintf(fconfig,"%.3f\n",PixRow);
  fprintf(fconfig,"%.3f\n",PixCol);
  fprintf(fconfig,"%.3f\n",PixSurf);
  fprintf(fconfig,"%i\n",NumberOfLines);
  fprintf(fconfig,"%i\n",NumberOfSamples);
  fprintf(fconfig,"%.3f\n",DistanceRadar);
  fprintf(fconfig,"%.3f\n",HauteurRadar);
   
/*******************************************************************/
/*******************************************************************/

  fclose(ftmp);
  fclose(fconfig);
   
  return 1;
}
 
