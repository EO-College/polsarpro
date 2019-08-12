
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
  FILE *fileinout;
  char FileName[FilePathLength]; 
  int ii, jj;
  float *dum;

/*******************************************************************/
/*******************************************************************/

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

Nlig = 805; Ncol = 205;
dum = vector_float(2*Nlig*Ncol);

for (ii = 1; ii < 7; ii++) {
printf("ii %i\n",ii);
  sprintf(FileName,"D:/Pol_Tomo_datasets/im%i/s11.bin",ii);
  check_file(FileName);
  printf("File = %s\n",FileName);
  if ((fileinout = fopen(FileName, "rb")) == NULL)
    edit_error("Could not open input file : ", FileName);
  fread(&dum[0],sizeof(float),2*Nlig*Ncol,fileinout);
  fclose(fileinout);
  for (jj = 0; jj < 2*Nlig*Ncol; jj++) dum[jj] = dum[jj] / 1000.;
  if ((fileinout = fopen(FileName, "wb")) == NULL)
    edit_error("Could not open input file : ", FileName);
  fwrite(&dum[0],sizeof(float),2*Nlig*Ncol,fileinout);
  fclose(fileinout);
  
  sprintf(FileName,"D:/Pol_Tomo_datasets/im%i/s12.bin",ii);
  check_file(FileName);
  printf("File = %s\n",FileName);
  if ((fileinout = fopen(FileName, "rb")) == NULL)
    edit_error("Could not open input file : ", FileName);
  fread(&dum[0],sizeof(float),2*Nlig*Ncol,fileinout);
  fclose(fileinout);
  for (jj = 0; jj < 2*Nlig*Ncol; jj++) dum[jj] = dum[jj] / 1000.;
  if ((fileinout = fopen(FileName, "wb")) == NULL)
    edit_error("Could not open input file : ", FileName);
  fwrite(&dum[0],sizeof(float),2*Nlig*Ncol,fileinout);
  fclose(fileinout);

  sprintf(FileName,"D:/Pol_Tomo_datasets/im%i/s21.bin",ii);
  check_file(FileName);
  printf("File = %s\n",FileName);
  if ((fileinout = fopen(FileName, "rb")) == NULL)
    edit_error("Could not open input file : ", FileName);
  fread(&dum[0],sizeof(float),2*Nlig*Ncol,fileinout);
  fclose(fileinout);
  for (jj = 0; jj < 2*Nlig*Ncol; jj++) dum[jj] = dum[jj] / 1000.;
  if ((fileinout = fopen(FileName, "wb")) == NULL)
    edit_error("Could not open input file : ", FileName);
  fwrite(&dum[0],sizeof(float),2*Nlig*Ncol,fileinout);
  fclose(fileinout);

  sprintf(FileName,"D:/Pol_Tomo_datasets/im%i/s22.bin",ii);
  check_file(FileName);
  printf("File = %s\n",FileName);
  if ((fileinout = fopen(FileName, "rb")) == NULL)
    edit_error("Could not open input file : ", FileName);
  fread(&dum[0],sizeof(float),2*Nlig*Ncol,fileinout);
  fclose(fileinout);
  for (jj = 0; jj < 2*Nlig*Ncol; jj++) dum[jj] = dum[jj] / 1000.;
  if ((fileinout = fopen(FileName, "wb")) == NULL)
    edit_error("Could not open input file : ", FileName);
  fwrite(&dum[0],sizeof(float),2*Nlig*Ncol,fileinout);
  fclose(fileinout);
  }

  return 1;
}

