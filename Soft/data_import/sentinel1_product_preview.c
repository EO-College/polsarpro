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

File     : sentinel1_product_preview.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 09/2014
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

Description :  extract information from Sentinel1 product_preview.html

********************************************************************/

/* C INCLUDES */
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
/*                                                                            */
{

/* LOCAL VARIABLES */
  FILE *ftmp, *fconfig;
  char FileTmp[FilePathLength], FileConfig[FilePathLength];
  char Buf[1024];
  char system[5];
  char product[5];
  char mode[5];
  char level[5];
  char polarisation[5];
  char FileAnnotation1[100],FileAnnotation2[100],FileAnnotation3[100];
  char FileAnnotation4[100],FileAnnotation5[100],FileAnnotation6[100];
  char FileAnnotation7[100],FileAnnotation8[100],FileAnnotation9[100];
  char FileAnnotation10[100], Tmp[100];
  char *p1, *p2;
  
  int FlagAnnotation, AnnotationFile;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nsentinel1_product_preview.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input product_preview file\n");
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

/*******************************************************************/
/*******************************************************************/

  if ((ftmp = fopen(FileTmp, "r")) == NULL)
    edit_error("Could not open input file : ", FileTmp);

  FlagAnnotation = 0;
  AnnotationFile = 0;
  strcpy(system,"?");
  strcpy(product,"?");
  strcpy(mode,"?");
  strcpy(level,"?");
  strcpy(polarisation,"?");
  
  while( !feof(ftmp) ) {
    fgets(&Buf[0], 1024, ftmp); 

    if (strstr(Buf,"<title>") != NULL) {
      if ((strstr(Buf,"S1A") != NULL)||(strstr(Buf,"s1a") != NULL)) strcpy(system,"S1A");
      if ((strstr(Buf,"S1B") != NULL)||(strstr(Buf,"s1b") != NULL)) strcpy(system,"S1B");
      if ((strstr(Buf,"SLC") != NULL)||(strstr(Buf,"slc") != NULL)) strcpy(product,"SLC");
      if ((strstr(Buf,"GRD") != NULL)||(strstr(Buf,"grd") != NULL)) strcpy(product,"GRD");
      if ((strstr(Buf,"IW") != NULL)||(strstr(Buf,"iw") != NULL)) strcpy(mode,"IW");
      if ((strstr(Buf,"EW") != NULL)||(strstr(Buf,"ew") != NULL)) strcpy(mode,"EW");
      if ((strstr(Buf,"1SDH") != NULL)||(strstr(Buf,"1sdh") != NULL)) {
        strcpy(level,"1"); strcpy(polarisation,"pp1");
        }
      if ((strstr(Buf,"1SDV") != NULL)||(strstr(Buf,"1sdv") != NULL)) {
        strcpy(level,"1"); strcpy(polarisation,"pp2");
        }
      if ((strstr(Buf,"2SDH") != NULL)||(strstr(Buf,"2sdh") != NULL)) {
        strcpy(level,"2"); strcpy(polarisation,"pp1");
        }
      if ((strstr(Buf,"2SDV") != NULL)||(strstr(Buf,"2sdv") != NULL)) {
        strcpy(level,"2"); strcpy(polarisation,"pp2");
        }
      }

    if (strcmp(product,"SLC") == 0) {	  
      if (FlagAnnotation == 1) {
        if (strstr(Buf,"annotation") != NULL) {
          p1 = strstr(Buf,">s1a"); p2 = strstr(Buf,".xml<");
          strcpy(Tmp, ""); strncat(Tmp, &p1[1], strlen(p1) - strlen(p2) - 1);      
          if (AnnotationFile == 0) strcpy(FileAnnotation1,Tmp);
          if (AnnotationFile == 1) strcpy(FileAnnotation2,Tmp);
          if (AnnotationFile == 2) strcpy(FileAnnotation3,Tmp);
          if (AnnotationFile == 3) strcpy(FileAnnotation4,Tmp);
          if (AnnotationFile == 4) strcpy(FileAnnotation5,Tmp);
          if (AnnotationFile == 5) strcpy(FileAnnotation6,Tmp);
          if (AnnotationFile == 6) strcpy(FileAnnotation7,Tmp);
          if (AnnotationFile == 7) strcpy(FileAnnotation8,Tmp);
          if (AnnotationFile == 8) strcpy(FileAnnotation9,Tmp);
          if (AnnotationFile == 9) strcpy(FileAnnotation10,Tmp);
          AnnotationFile++;
          if ((strcmp(mode,"IW") == 0)&&(AnnotationFile == 6)) FlagAnnotation = 0;
          if ((strcmp(mode,"EW") == 0)&&(AnnotationFile == 10)) FlagAnnotation = 0;    
          }
	    }
      }

    if (strstr(Buf,">annotation<") != NULL) FlagAnnotation = 1;
    }
  fclose(ftmp);
    
/*******************************************************************/
/*******************************************************************/

  if ((fconfig = fopen(FileConfig, "w")) == NULL)
    edit_error("Could not open configuration file : ", FileConfig);

  fprintf(fconfig,"%s\n",system);
  fprintf(fconfig,"%s\n",product);
  if (strcmp(product,"SLC") == 0) {	  
    fprintf(fconfig,"%s\n",mode);
    fprintf(fconfig,"%s\n",level);
    fprintf(fconfig,"%s\n",polarisation);
    if (strcmp(mode,"IW") == 0) AnnotationFile = 6;
    if (strcmp(mode,"EW") == 0) AnnotationFile = 10;
    fprintf(fconfig,"%i\n",AnnotationFile);
    fprintf(fconfig,"%s\n",FileAnnotation1);
    fprintf(fconfig,"%s\n",FileAnnotation2);
    fprintf(fconfig,"%s\n",FileAnnotation3);
    fprintf(fconfig,"%s\n",FileAnnotation4);
    fprintf(fconfig,"%s\n",FileAnnotation5);
    fprintf(fconfig,"%s\n",FileAnnotation6);
    if (strcmp(mode,"EW") == 0) {
      fprintf(fconfig,"%s\n",FileAnnotation7);
      fprintf(fconfig,"%s\n",FileAnnotation8);
      fprintf(fconfig,"%s\n",FileAnnotation9);
      fprintf(fconfig,"%s\n",FileAnnotation10);
      }
    }
  fclose(fconfig);
   
  return 1;
}
