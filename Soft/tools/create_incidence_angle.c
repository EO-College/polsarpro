#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>


#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* ALIASES  */

/* CONSTANTS  */

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"

int main(int argc, char *argv[])
{

/* LOCAL VARIABLES */

/* Input/Output file pointer arrays */
  FILE *out_file;


/* Strings */
  char file_name[FilePathLength];

/* Input variables */
  int Nlig, Ncol;

/* Internal variables */
  int i;
  float range_sampling, altitude_above_ground;
  float range_delay, c0, range_bin_first;
  
/* Matrix arrays */
  float *M_out;
  
/* PROGRAM START */

  Nlig = 4000; Ncol = 1473;

/* MATRIX DECLARATION */
  M_out = vector_float(Ncol);

  sprintf(file_name, "D:/incidence_angle.bin");
  check_file(file_name);
  if ((out_file = fopen(file_name, "wb")) == NULL)
      edit_error("Could not open output file : ", file_name);

//Taille du pixel
range_sampling = 1.49854;
//Hauteur du vol en metre
altitude_above_ground = 2974.45;
range_delay = 17.66e-6;
c0 = 2.997e8;
range_bin_first = 425;
      
for (i = 0; i < Ncol; i++) 
  M_out[i]=(acos(altitude_above_ground/((range_delay *c0/2)+((range_bin_first+i)*range_sampling)))); 

/* OUPUT DATA WRITING */
for (i = 0; i < Nlig; i++) 
  fwrite(&M_out[0], sizeof(float), Ncol, out_file);

free_vector_float(M_out);
return 1;
}
