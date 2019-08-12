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

File   : float_tools.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2011
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

Description :  Float data file processing

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

/* ACCESS FILE */
FILE *fileinput;
FILE *fileoutput;

/* GLOBAL ARRAYS */
float *bufferdata;
float **datatmp;

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
  char DirInput[FilePathLength], DirOutput[FilePathLength];
  char FileInput[FilePathLength], FileOutput[FilePathLength];
  char Operation[FilePathLength];

  int lig, col;

  char *pc;
  float fl1;
  float *v;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nfloat_tools.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-if  	input file\n");
strcat(UsageHelp," (string)	-of  	output file\n");
strcat(UsageHelp," (string)	-op  	operation (ieee, extract, rot90l, rot90r, rot180, fliplr, flipud, fliplrud, transp)\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 19) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,DirInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,DirOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,FileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-op",str_cmd_prm,Operation,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_dir(DirInput);
  check_dir(DirOutput);
  check_file(FileInput);
  check_file(FileOutput);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

  read_config(DirInput, &Nlig, &Ncol, PolarCase, PolarType);

  datatmp = matrix_float(Sub_Nlig, Sub_Ncol);

  if (Nlig >= Ncol) bufferdata = vector_float(Nlig);
  if (Ncol >= Nlig) bufferdata = vector_float(Ncol);

/*******************************************************************/
/* INPUT BINARY DATA FILE */
/*******************************************************************/

  if ((fileinput = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  rewind(fileinput);

/* READ INPUT DATA FILE AND CREATE DATATMP */
  for (lig = 0; lig < Off_lig; lig++)
    fread(&bufferdata[0], sizeof(float), Ncol, fileinput);


  for (lig = 0; lig < Sub_Nlig; lig++) {
    if (strcmp(Operation, "ieee") == 0) {
      for (col = 0; col < Ncol; col++) {
        v = &fl1;
        pc = (char *) v;
        pc[3] = getc(fileinput); pc[2] = getc(fileinput);
        pc[1] = getc(fileinput); pc[0] = getc(fileinput);
        bufferdata[col] = fl1;
        }
      }
    if (strcmp(Operation, "ieee") != 0)
      fread(&bufferdata[0], sizeof(float), Ncol, fileinput);

    for (col = 0; col < Sub_Ncol; col++) {
      datatmp[lig][col] = bufferdata[col + Off_col];
      }
    }

  fclose(fileinput);

/*******************************************************************/
/* WRITE OUTPUT DATA FILE */
  if ((fileoutput = fopen(FileOutput, "wb")) == NULL)
    edit_error("Could not open input file : ", FileOutput);

  if (strcmp(Operation, "ieee") == 0) {
    for (lig = 0; lig < Sub_Nlig; lig++) {
      PrintfLine(lig,Sub_Nlig);
      for (col = 0; col < Sub_Ncol; col++) {
        bufferdata[col] = datatmp[lig][col];
        }
      fwrite(&bufferdata[0], sizeof(float), Sub_Ncol, fileoutput);
      }
    write_config(DirOutput, Sub_Nlig, Sub_Ncol, PolarCase, PolarType);
    }

  if (strcmp(Operation, "extract") == 0) {
    for (lig = 0; lig < Sub_Nlig; lig++) {
      PrintfLine(lig,Sub_Nlig);
      for (col = 0; col < Sub_Ncol; col++) {
        bufferdata[col] = datatmp[lig][col];
        }
      fwrite(&bufferdata[0], sizeof(float), Sub_Ncol, fileoutput);
      }
    write_config(DirOutput, Sub_Nlig, Sub_Ncol, PolarCase, PolarType);
    }

  if (strcmp(Operation, "rot90l") == 0) {
    for (col = 0; col < Sub_Ncol; col++) {
      PrintfLine(col,Sub_Ncol);
      for (lig = 0; lig < Sub_Nlig; lig++) {
        bufferdata[lig] = datatmp[lig][Sub_Ncol - 1 - col];
        }
      fwrite(&bufferdata[0], sizeof(float), Sub_Nlig, fileoutput);
      }
    write_config(DirOutput, Sub_Ncol, Sub_Nlig, PolarCase, PolarType);
    }  

  if (strcmp(Operation, "rot90r") == 0) {
    for (col = 0; col < Sub_Ncol; col++) {
      PrintfLine(col,Sub_Ncol);
      for (lig = 0; lig < Sub_Nlig; lig++) {
        bufferdata[lig] = datatmp[Sub_Nlig - 1 - lig][col];
        }
      fwrite(&bufferdata[0], sizeof(float), Sub_Nlig, fileoutput);
      }
    write_config(DirOutput, Sub_Ncol, Sub_Nlig, PolarCase, PolarType);
    }

  if (strcmp(Operation, "rot180") == 0) {
    for (lig = 0; lig < Sub_Nlig; lig++) {
      PrintfLine(lig,Sub_Nlig);
      for (col = 0; col < Sub_Ncol; col++) {
        bufferdata[col] = datatmp[Sub_Nlig - 1 - lig][Sub_Ncol - 1 - col];
        }
      fwrite(&bufferdata[0], sizeof(float), Sub_Ncol, fileoutput);
      }
    write_config(DirOutput, Sub_Nlig, Sub_Ncol, PolarCase, PolarType);
    }

  if (strcmp(Operation, "fliplr") == 0) {
    for (lig = 0; lig < Sub_Nlig; lig++) {
      PrintfLine(lig,Sub_Nlig);
      for (col = 0; col < Sub_Ncol; col++) {
        bufferdata[col] = datatmp[lig][Sub_Ncol - 1 - col];
        }
      fwrite(&bufferdata[0], sizeof(float), Sub_Ncol, fileoutput);
      }
    write_config(DirOutput, Sub_Nlig, Sub_Ncol, PolarCase, PolarType);
    }

  if (strcmp(Operation, "flipud") == 0) {
    for (lig = 0; lig < Sub_Nlig; lig++) {
      PrintfLine(lig,Sub_Nlig);
      for (col = 0; col < Sub_Ncol; col++) {
        bufferdata[col] = datatmp[Sub_Nlig - 1 - lig][col];
        }
      fwrite(&bufferdata[0], sizeof(float), Sub_Ncol, fileoutput);
      }
    write_config(DirOutput, Sub_Nlig, Sub_Ncol, PolarCase, PolarType);
    }

  if (strcmp(Operation, "fliplrud") == 0) {
    for (lig = 0; lig < Sub_Nlig; lig++) {
      PrintfLine(lig,Sub_Nlig);
      for (col = 0; col < Sub_Ncol; col++) {
        bufferdata[col] = datatmp[Sub_Nlig - 1 - lig][Sub_Ncol - 1 - col];
        }
      fwrite(&bufferdata[0], sizeof(float), Sub_Ncol, fileoutput);
      }
    write_config(DirOutput, Sub_Nlig, Sub_Ncol, PolarCase, PolarType);
    }
    
  if (strcmp(Operation, "transp") == 0) {
    for (col = 0; col < Sub_Ncol; col++) {
      PrintfLine(col,Sub_Ncol);
      for (lig = 0; lig < Sub_Nlig; lig++) {
        bufferdata[lig] = datatmp[lig][col];
        }
      fwrite(&bufferdata[0], sizeof(float), Sub_Nlig, fileoutput);
      }
    write_config(DirOutput, Sub_Ncol, Sub_Nlig, PolarCase, PolarType);
    }

  fclose(fileoutput);
  return 1;
}
