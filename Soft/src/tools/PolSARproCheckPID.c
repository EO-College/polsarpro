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

File   : PolSARproCheckPID.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 12/2016
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

********************************************************************/
/* C INCLUDES */
/*
#include <io.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <ctype.h>
#include <errno.h>
#include <unistd.h>
#include <time.h>
*/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <time.h>

#include "omp.h"

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"
void wait ( int seconds );

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
  FILE *in;
  FILE *fileinout;
  char FileOutputTL[FilePathLength];
  char FileOutputPID[FilePathLength];
  char Buf[FilePathLength];
  //extern FILE *popen();
  char CmdLine[FilePathLength];
  int PIDValue;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nPolSARproCheckPID.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-oft 	output file tasklist\n");
strcat(UsageHelp," (string)	-ofp 	output file pid\n");
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
  get_commandline_prm(argc,argv,"-oft",str_cmd_prm,FileOutputTL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofp",str_cmd_prm,FileOutputPID,1,UsageHelp);
  }

  check_file(FileOutputTL);
  check_file(FileOutputPID);
  
  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/********************************************************************
********************************************************************/
  if ((fileinout = fopen(FileOutputTL, "wb")) == NULL)
    edit_error("Could not open configuration file : ", FileOutputTL);
  fclose(fileinout);
  
  sprintf(CmdLine, "tasklist /fo LIST > %s",FileOutputTL);    
  in = popen(CmdLine, "r");
  if ( !in ) {
    exit(1);
    }

  wait(3);
  
/*******************************************************************/
/* OUTPUT CHECK RESULT FILE */
/*******************************************************************/
  if ((fileinout = fopen(FileOutputTL, "r")) == NULL)
    edit_error("Could not open configuration file : ", FileOutputTL);

  PIDValue = 0;
  while( !feof(fileinout) ) {
    fgets(&Buf[0], 1024, fileinout); 
    if (strstr(Buf,"map_algebra_gimp.exe") != NULL) {
      fgets(&Buf[0], 1024, fileinout); 
      sscanf(Buf, "PID:                 %i",&PIDValue);
      }
    }  
  fclose(fileinout);
  
  if ((fileinout = fopen(FileOutputPID, "w")) == NULL)
    edit_error("Could not open configuration file : ", FileOutputPID);
  fprintf(fileinout, "%i\n",PIDValue);
  fclose(fileinout);

  return 1;
}

/********************************************************************
*********************************************************************
*********************************************************************
********************************************************************/
void wait ( int seconds )
{
  clock_t endwait;
  endwait = clock () + seconds * CLOCKS_PER_SEC ;
  while (clock() < endwait) {}

}