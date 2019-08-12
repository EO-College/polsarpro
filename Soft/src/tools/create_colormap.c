#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "omp.h"

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* ALIASES  */


/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"


int main(int argc, char *argv[])
{

/* LOCAL VARIABLES */

/* Input/Output file pointer arrays */
  FILE *out_file;

/* Strings */
  char out_dir[FilePathLength], file_name[FilePathLength];

/* Internal variables */
  int ii;

/* Matrix arrays */
  int red[256], green[256], blue[256];
  
/* PROGRAM START */

  sprintf(out_dir, "D:/PalettesPSP");
  check_dir(out_dir);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/* BLUE*/
  sprintf(file_name, "%sColorMap_BLUE.pal", out_dir);
  if ((out_file = fopen(file_name, "w")) == NULL)
    edit_error("Could not open output file : ", file_name);
  fprintf(out_file, "JASC-PAL\n");
  fprintf(out_file, "0100\n");
  fprintf(out_file, "256\n");
  fprintf(out_file, "125 125 125\n");
  for (ii = 1; ii < 256; ii++) red[ii] = (int)(ii*200/255);
  for (ii = 1; ii < 256; ii++) green[ii] = (int)(ii*210/255);
  for (ii = 1; ii < 100; ii++) blue[ii] = (int)(ii*255/99);
  for (ii = 100; ii < 256; ii++) blue[ii] = 255;
  for (ii = 1; ii < 256; ii++) fprintf(out_file, "%i %i %i\n", red[ii], green[ii], blue[ii]);
  fclose(out_file);

/* BLUE SKY*/
  sprintf(file_name, "%sColorMap_BLUESKY.pal", out_dir);
  if ((out_file = fopen(file_name, "w")) == NULL)
    edit_error("Could not open output file : ", file_name);
  fprintf(out_file, "JASC-PAL\n");
  fprintf(out_file, "0100\n");
  fprintf(out_file, "256\n");
  fprintf(out_file, "125 125 125\n");
  for (ii = 1; ii < 256; ii++) red[ii] = 0;
  for (ii = 1; ii < 256; ii++) green[ii] = (int)(ii*240/255);
  for (ii = 1; ii < 256; ii++) blue[ii] = (int)ii;
  for (ii = 1; ii < 256; ii++) fprintf(out_file, "%i %i %i\n", red[ii], green[ii], blue[ii]);
  fclose(out_file);

/* GREEN*/
  sprintf(file_name, "%sColorMap_GREEN.pal", out_dir);
  if ((out_file = fopen(file_name, "w")) == NULL)
    edit_error("Could not open output file : ", file_name);
  fprintf(out_file, "JASC-PAL\n");
  fprintf(out_file, "0100\n");
  fprintf(out_file, "256\n");
  fprintf(out_file, "125 125 125\n");
  for (ii = 1; ii < 256; ii++) red[ii] = (int)(ii*190/255);
  for (ii = 1; ii < 256; ii++) green[ii] = (int)(ii*230/255);
  for (ii = 1; ii < 256; ii++) blue[ii] = 0;
  for (ii = 1; ii < 256; ii++) fprintf(out_file, "%i %i %i\n", red[ii], green[ii], blue[ii]);
  fclose(out_file);

/* GREEN2*/
  sprintf(file_name, "%sColorMap_GREEN2.pal", out_dir);
  if ((out_file = fopen(file_name, "w")) == NULL)
    edit_error("Could not open output file : ", file_name);
  fprintf(out_file, "JASC-PAL\n");
  fprintf(out_file, "0100\n");
  fprintf(out_file, "256\n");
  fprintf(out_file, "125 125 125\n");
  for (ii = 1; ii < 256; ii++) red[ii] = (int)(ii*30/255);
  for (ii = 1; ii < 256; ii++) green[ii] = (int)(ii);
  for (ii = 1; ii < 256; ii++) blue[ii] = 0;
  for (ii = 1; ii < 256; ii++) fprintf(out_file, "%i %i %i\n", red[ii], green[ii], blue[ii]);
  fclose(out_file);

/* MAGENTA*/
  sprintf(file_name, "%sColorMap_MAGENTA.pal", out_dir);
  if ((out_file = fopen(file_name, "w")) == NULL)
    edit_error("Could not open output file : ", file_name);
  fprintf(out_file, "JASC-PAL\n");
  fprintf(out_file, "0100\n");
  fprintf(out_file, "256\n");
  fprintf(out_file, "125 125 125\n");
  for (ii = 1; ii < 160; ii++) red[ii] = (int)(ii*255/159);
  for (ii = 160; ii < 256; ii++) red[ii] = 255;
  for (ii = 1; ii < 160; ii++) green[ii] = 0;
  for (ii = 160; ii < 256; ii++) green[ii] = (int)((ii-160)*200/(255-160));
  for (ii = 1; ii < 256; ii++) blue[ii] = (int)(ii*240/255);
  for (ii = 1; ii < 256; ii++) fprintf(out_file, "%i %i %i\n", red[ii], green[ii], blue[ii]);
  fclose(out_file);

/* ORANGE*/
  sprintf(file_name, "%sColorMap_ORANGE.pal", out_dir);
  if ((out_file = fopen(file_name, "w")) == NULL)
    edit_error("Could not open output file : ", file_name);
  fprintf(out_file, "JASC-PAL\n");
  fprintf(out_file, "0100\n");
  fprintf(out_file, "256\n");
  fprintf(out_file, "125 125 125\n");
  for (ii = 1; ii < 220; ii++) red[ii] = (int)(ii*255/219);
  for (ii = 221; ii < 256; ii++) red[ii] = 255;
  for (ii = 1; ii < 256; ii++) green[ii] = (int)(ii*200/255);
  for (ii = 1; ii < 120; ii++) blue[ii] = 0;
  for (ii = 120; ii < 256; ii++) blue[ii] = (int)((ii-120)*100/(255-120));
  for (ii = 1; ii < 256; ii++) fprintf(out_file, "%i %i %i\n", red[ii], green[ii], blue[ii]);
  fclose(out_file);

/* PURPLE*/
  sprintf(file_name, "%sColorMap_PURPLE.pal", out_dir);
  if ((out_file = fopen(file_name, "w")) == NULL)
    edit_error("Could not open output file : ", file_name);
  fprintf(out_file, "JASC-PAL\n");
  fprintf(out_file, "0100\n");
  fprintf(out_file, "256\n");
  fprintf(out_file, "125 125 125\n");
  for (ii = 1; ii < 256; ii++) red[ii] = (int)(ii*230/255);
  for (ii = 1; ii < 100; ii++) green[ii] = 0;
  for (ii = 100; ii < 256; ii++) green[ii] = (int)((ii-100)*210/(255-100));
  for (ii = 1; ii < 100; ii++) blue[ii] = (int)(ii*255/99);
  for (ii = 100; ii < 256; ii++) blue[ii] = 255;
  for (ii = 1; ii < 256; ii++) fprintf(out_file, "%i %i %i\n", red[ii], green[ii], blue[ii]);
  fclose(out_file);
  
/* RED*/
  sprintf(file_name, "%sColorMap_RED.pal", out_dir);
  if ((out_file = fopen(file_name, "w")) == NULL)
    edit_error("Could not open output file : ", file_name);
  fprintf(out_file, "JASC-PAL\n");
  fprintf(out_file, "0100\n");
  fprintf(out_file, "256\n");
  fprintf(out_file, "125 125 125\n");
  for (ii = 1; ii < 145; ii++) red[ii] = (int)(ii*255/144);
  for (ii = 145; ii < 256; ii++) red[ii] = 255;
  for (ii = 1; ii < 140; ii++) green[ii] = 0;
  for (ii = 140; ii < 256; ii++) green[ii] = (int)((ii-140)*200/(255-140));
  for (ii = 1; ii < 140; ii++) blue[ii] = 0;
  for (ii = 140; ii < 256; ii++) blue[ii] = (int)((ii-140)*200/(255-140));
  for (ii = 1; ii < 256; ii++) fprintf(out_file, "%i %i %i\n", red[ii], green[ii], blue[ii]);
  fclose(out_file);
  
/* YELLOW*/
  sprintf(file_name, "%sColorMap_YELLOW.pal", out_dir);
  if ((out_file = fopen(file_name, "w")) == NULL)
    edit_error("Could not open output file : ", file_name);
  fprintf(out_file, "JASC-PAL\n");
  fprintf(out_file, "0100\n");
  fprintf(out_file, "256\n");
  fprintf(out_file, "125 125 125\n");
  for (ii = 1; ii < 256; ii++) red[ii] = (int)ii;
  for (ii = 1; ii < 256; ii++) green[ii] = (int)ii;
  for (ii = 1; ii < 256; ii++) blue[ii] = 0;
  for (ii = 1; ii < 256; ii++) fprintf(out_file, "%i %i %i\n", red[ii], green[ii], blue[ii]);
  fclose(out_file);

/* BROWN*/
  sprintf(file_name, "%sColorMap_BROWN.pal", out_dir);
  if ((out_file = fopen(file_name, "w")) == NULL)
    edit_error("Could not open output file : ", file_name);
  fprintf(out_file, "JASC-PAL\n");
  fprintf(out_file, "0100\n");
  fprintf(out_file, "256\n");
  fprintf(out_file, "125 125 125\n");
  for (ii = 1; ii < 200; ii++) red[ii] = (int)(ii*255/199);
  for (ii = 200; ii < 256; ii++) red[ii] = 255;
  for (ii = 1; ii < 256; ii++) green[ii] = (int)(ii*200/255);
  for (ii = 1; ii < 256; ii++) blue[ii] = (int)(ii*128/255);
  for (ii = 1; ii < 256; ii++) fprintf(out_file, "%i %i %i\n", red[ii], green[ii], blue[ii]);
  fclose(out_file);
  
  return 1;
}

