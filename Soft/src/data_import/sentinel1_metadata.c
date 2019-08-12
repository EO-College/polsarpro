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

File     : sentinel1_metadata.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 11/2017
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

Description :  extract information from Sentinel1 metadata file

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
  char str[65536], buf[65536];
  char *p1;

  int AzLook, RgLook;
  
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nsentinel1_metadata.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input metadata file\n");
strcat(UsageHelp," (string)	-of  	output metadata file\n");
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
    fgets(&str[0], 1024, ftmp); 
    if (strstr(str, "azimuth_looks") != NULL) {
        p1 = strstr(str,"value=\"");
        strcpy(buf, ""); strncat(buf, &p1[7], 3);      
		AzLook = floor(atof(buf));
        }
    if (strstr(str, "range_looks") != NULL) {
        p1 = strstr(str,"value=\"");
        strcpy(buf, ""); strncat(buf, &p1[7], 3);      
		RgLook = floor(atof(buf));
        }
    }
	
  fclose(ftmp);
/*******************************************************************/
/*******************************************************************/

  if ((fconfig = fopen(FileConfig, "w")) == NULL)
    edit_error("Could not open configuration file : ", FileConfig);
  fprintf(fconfig,"%i\n",AzLook);
  fprintf(fconfig,"%i\n",RgLook);
  fclose(fconfig);
   
  return 1;
}
 
