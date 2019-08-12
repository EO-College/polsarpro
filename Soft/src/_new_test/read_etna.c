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

/* ACCESS FILE */
FILE *fileinput;
FILE *fHH, *fHV, *fVH, *fVV;

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/

int main(int argc, char *argv[])
/*                                      */
{

/* LOCAL VARIABLES */

  char FileInput[FilePathLength];
  char DirOutput[FilePathLength];
  char file_name[FilePathLength];

  int Nlig, Ncol;
  int IEEE;
  int lig, col;
  float *S_in;

  int *vv;
  char *pc;

  float fl1, fl2;
  float *v;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nread_etna.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input file\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (int)   	-iee 	IEEE data convert (no: 0, yes: 1)\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 7) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,FileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,DirOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iee",int_cmd_prm,&IEEE,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(FileInput);
  check_dir(DirOutput);

/*******************************************************************/
/* INPUT BINARY STK DATA FILE */
/*******************************************************************/

  if ((fileinput = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  rewind(fileinput);

  if (IEEE == 0) {    /*IEEE Convert */
  vv = &Ncol;
  pc = (char *) vv;
  pc[0] = getc(fileinput);
  pc[1] = getc(fileinput);
  pc[2] = getc(fileinput);
  pc[3] = getc(fileinput);
  vv = &Nlig;
  pc = (char *) vv;
  pc[0] = getc(fileinput);
  pc[1] = getc(fileinput);
  pc[2] = getc(fileinput);
  pc[3] = getc(fileinput);
  }
  if (IEEE == 1) {    /*IEEE Convert */
  vv = &Ncol;
  pc = (char *) vv;
  pc[3] = getc(fileinput);
  pc[2] = getc(fileinput);
  pc[1] = getc(fileinput);
  pc[0] = getc(fileinput);
  vv = &Nlig;
  pc = (char *) vv;
  pc[3] = getc(fileinput);
  pc[2] = getc(fileinput);
  pc[1] = getc(fileinput);
  pc[0] = getc(fileinput);
  }

  printf("nlig = %i\n", Nlig);
  printf("ncol = %i\n", Ncol);

  S_in = vector_float(2*Ncol);

/*******************************************************************/
/*******************************************************************/

  sprintf(file_name, "%s%s", DirOutput, "s11.bin");
  if ((fHH = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%s%s", DirOutput, "s12.bin");
  if ((fHV = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%s%s", DirOutput, "s21.bin");
  if ((fVH = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%s%s", DirOutput, "s22.bin");
  if ((fVV = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  for (lig = 0; lig < Nlig; lig++) {
    if (IEEE == 0)
      fread(&S_in[0], sizeof(float), 2 * Ncol, fileinput);
    if (IEEE == 1) {
      for (col = 0; col < Ncol; col++) {
        v = &fl1;pc = (char *) v;
        pc[3] = getc(fileinput);pc[2] = getc(fileinput);
        pc[1] = getc(fileinput);pc[0] = getc(fileinput);
        v = &fl2;pc = (char *) v;
        pc[3] = getc(fileinput);pc[2] = getc(fileinput);
        pc[1] = getc(fileinput);pc[0] = getc(fileinput);
        S_in[2 * col] = fl1;S_in[2 * col + 1] = fl2;
        }
      }
    fwrite(&S_in[0], sizeof(float), 2 * Ncol, fHH);
    fwrite(&S_in[0], sizeof(float), 2 * Ncol, fHV);
    fwrite(&S_in[0], sizeof(float), 2 * Ncol, fVH);
    fwrite(&S_in[0], sizeof(float), 2 * Ncol, fVV);
    }

  fclose(fHH);
  fclose(fHV);
  fclose(fVH);
  fclose(fVV);
  
  fclose(fileinput);
  
  return 1;
}
