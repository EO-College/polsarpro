/********************************************************************
PolSARpro v5.0 is free software; you can valistribute it and/or 
modify it under the terms of the GNU General Public License as 
published by the Free Software Foundation; either version 2 (1991) of
the License, or any later version. This program is distributed in the
hope that it will be useful, but WITHOUT ANY WARRANTY; without even 
the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE. 

See the GNU General Public License (Version 2, 1991) for more details

*********************************************************************

File   : create_hsv_cce_file.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 07/2011
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

Description :  Creation of a HSV BMP file from 3 binary files
The input format of the binary file must be float

********************************************************************/
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
  FILE *filebmp;
  FILE *huefileinput;
  FILE *satfileinput;
  FILE *valfileinput;
  char HueFileInput[FilePathLength], SatFileInput[FilePathLength];
  char ValFileInput[FilePathLength], FileOutput[FilePathLength];
  
/* Internal variables */
  int lig, col, l, Npts;
  float minmin, maxmax;
  float minval, maxval;
  float minsat, maxsat;
  float minhue, maxhue;
  float hue, sat, val, red, green, blue;
  float m1, m2, h;
  int automatic;
  int extracol;

/* Matrix arrays */
  float *datatmp;
  char *dataimg;
  float *bufferdatahue;
  float *bufferdatasat;
  float *bufferdataval;
  float *ValidMask;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncreate_hsv_cce_file.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-ifh 	input binary file: hue channel\n");
strcat(UsageHelp," (string)	-ifv 	input binary file: val channel\n");
strcat(UsageHelp," (string)	-ifs 	input binary file: sat channel\n");
strcat(UsageHelp," (string)	-of  	output RGB BMP file\n");
strcat(UsageHelp," (int)   	-inc 	Initial Number of Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (int)   	-auto	Automatic color enhancement (1 / 0)\n");
strcat(UsageHelp," if automatic = 0\n");
strcat(UsageHelp," (float) 	-minh	hue channel : min value\n");
strcat(UsageHelp," (float) 	-maxh	hue channel : max value\n");
strcat(UsageHelp," (float) 	-minv	val channel : min value\n");
strcat(UsageHelp," (float) 	-maxv	val channel : max value\n");
strcat(UsageHelp," (float) 	-mins	sat channel : min value\n");
strcat(UsageHelp," (float) 	-maxs	sat channel : max value\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
strcat(UsageHelp," (int)   	-mem 	Allocated memory for blocksize determination (in Mb)\n");
strcat(UsageHelp," (string)	-errf	memory error file\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

automatic = 1;

if(argc < 21) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-ifh",str_cmd_prm,HueFileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifv",str_cmd_prm,ValFileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifs",str_cmd_prm,SatFileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-inc",int_cmd_prm,&Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-auto",int_cmd_prm,&automatic,1,UsageHelp);
  if (automatic == 0) {
    get_commandline_prm(argc,argv,"-minh",flt_cmd_prm,&minhue,1,UsageHelp);
    get_commandline_prm(argc,argv,"-maxh",flt_cmd_prm,&maxhue,1,UsageHelp);
    get_commandline_prm(argc,argv,"-minv",flt_cmd_prm,&minval,1,UsageHelp);
    get_commandline_prm(argc,argv,"-maxv",flt_cmd_prm,&maxval,1,UsageHelp);
    get_commandline_prm(argc,argv,"-mins",flt_cmd_prm,&minsat,1,UsageHelp);
    get_commandline_prm(argc,argv,"-maxs",flt_cmd_prm,&maxsat,1,UsageHelp);
    }

  get_commandline_prm(argc,argv,"-errf",str_cmd_prm,file_memerr,0,UsageHelp);

  MemoryAlloc = -1;
  get_commandline_prm(argc,argv,"-mem",int_cmd_prm,&MemoryAlloc,0,UsageHelp);
  MemoryAlloc = my_max(MemoryAlloc,1000);

  FlagValid = 0;strcpy(file_valid,"");
  get_commandline_prm(argc,argv,"-mask",str_cmd_prm,file_valid,0,UsageHelp);
  if (strcmp(file_valid,"") != 0) FlagValid = 1;
  }

/********************************************************************
********************************************************************/

  check_file(HueFileInput);
  check_file(SatFileInput);
  check_file(ValFileInput);
  check_file(FileOutput);
  if (FlagValid == 1) check_file(file_valid);

  NwinL = 1; NwinC = 1;

  extracol = (int) fmod(4 - (int) fmod(3*Sub_Ncol, 4), 4);
  //Sub_Ncol = Sub_Ncol - (int) fmod((float) Sub_Ncol, 4.);
  NcolBMP = 3*Sub_Ncol + extracol;

/* INPUT FILE OPENING */
  if ((huefileinput = fopen(HueFileInput, "rb")) == NULL)
    edit_error("Could not open input file : ", HueFileInput);
  if ((valfileinput = fopen(ValFileInput, "rb")) == NULL)
    edit_error("Could not open input file : ", ValFileInput);
  if ((satfileinput = fopen(SatFileInput, "rb")) == NULL)
    edit_error("Could not open input file : ", SatFileInput);

  if (FlagValid == 1) {
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);
    }
  
/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  bufferdatahue = vector_float(Ncol);
  bufferdatasat = vector_float(Ncol);
  bufferdataval = vector_float(Ncol);

  ValidMask = vector_float(Ncol);

  datatmp = vector_float(Sub_Nlig*Sub_Ncol);

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0)  
    for (col = 0; col < Sub_Ncol; col++) ValidMask[col] = 1.;
/********************************************************************
********************************************************************/
if (automatic == 1) {
/********************************************************************
********************************************************************/
/* DATA PROCESSING HUE CHANNEL */

rewind(huefileinput);
if (FlagValid == 1) rewind(in_valid);

/* OFFSET READING */
  for (lig = 0; lig < Off_lig; lig++) {
    fread(&bufferdatahue[0], sizeof(float), Ncol, huefileinput);
    if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    }

  Npts = -1;

for (lig = 0; lig < Sub_Nlig; lig++) {
  if (lig%(int)(Sub_Nlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_Nlig - 1));fflush(stdout);}
  fread(&bufferdatahue[0], sizeof(float), Ncol, huefileinput);
  if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);

  for (col = 0; col < Sub_Ncol; col++) {

    if (ValidMask[col+ Off_col] == 1.) {
      Npts++;
      datatmp[Npts] = fabs(bufferdatahue[col + Off_col]);
      if (datatmp[Npts] > eps) datatmp[Npts] = 10. * log10(datatmp[Npts]);
      else Npts--;
      } /* valid */
    } /* col */
  } /* lig */

  Npts++;

  minhue = INIT_MINMAX; maxhue = -minhue;

/* DETERMINATION OF THE MIN / MAX OF THE HUE CHANNEL */
  MinMaxContrastMedian(datatmp, &minhue, &maxhue, Npts);

/********************************************************************
********************************************************************/
/* DATA PROCESSING VAL CHANNEL */

rewind(valfileinput);
if (FlagValid == 1) rewind(in_valid);

/* OFFSET READING */
  for (lig = 0; lig < Off_lig; lig++) {
    fread(&bufferdataval[0], sizeof(float), Ncol, valfileinput);
    if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    }

  Npts = -1;

for (lig = 0; lig < Sub_Nlig; lig++) {
  if (lig%(int)(Sub_Nlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_Nlig - 1));fflush(stdout);}
  fread(&bufferdataval[0], sizeof(float), Ncol, valfileinput);
  if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);

  for (col = 0; col < Sub_Ncol; col++) {

    if (ValidMask[col+ Off_col] == 1.) {
      Npts++;
      datatmp[Npts] = fabs(bufferdataval[col + Off_col]);
      if (datatmp[Npts] > eps) datatmp[Npts] = 10. * log10(datatmp[Npts]);
      else Npts--;
      } /* valid */
    } /* col */
  } /* lig */

  Npts++;

  minval = INIT_MINMAX; maxval = -minval;

/* DETERMINATION OF THE MIN / MAX OF THE VAL CHANNEL */
  MinMaxContrastMedian(datatmp, &minval, &maxval, Npts);

/********************************************************************
********************************************************************/
/* DATA PROCESSING SAT CHANNEL */

rewind(satfileinput);
if (FlagValid == 1) rewind(in_valid);

/* OFFSET READING */
  for (lig = 0; lig < Off_lig; lig++) {
    fread(&bufferdatasat[0], sizeof(float), Ncol, satfileinput);
    if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    }

  Npts = -1;

for (lig = 0; lig < Sub_Nlig; lig++) {
  if (lig%(int)(Sub_Nlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_Nlig - 1));fflush(stdout);}
  fread(&bufferdatasat[0], sizeof(float), Ncol, satfileinput);
  if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);

  for (col = 0; col < Sub_Ncol; col++) {

    if (ValidMask[col+ Off_col] == 1.) {
      Npts++;
      datatmp[Npts] = fabs(bufferdatasat[col + Off_col]);
      if (datatmp[Npts] > eps) datatmp[Npts] = 10. * log10(datatmp[Npts]);
      else Npts--;
      } /* valid */
    } /* col */
  } /* lig */

  Npts++;

  minsat = INIT_MINMAX; maxsat = -minsat;

/* DETERMINATION OF THE MIN / MAX OF THE SAT CHANNEL */
  MinMaxContrastMedian(datatmp, &minsat, &maxsat, Npts);
/********************************************************************
********************************************************************/
}
/*******************************************************************/
/* OUTPUT BMP FILE CREATION */
/*******************************************************************/
  minmin = INIT_MINMAX; maxmax = -minmin;

  if (minhue <= minmin) minmin = minhue;
  if (minval <= minmin) minmin = minval;
  if (minsat <= minmin) minmin = minsat;
  if (maxhue <= minmin) minmin = maxhue;
  if (maxval <= minmin) minmin = maxval;
  if (maxsat <= minmin) minmin = maxsat;
  
  if (maxmax <= minhue) maxmax = minhue;
  if (maxmax <= minval) maxmax = minval;
  if (maxmax <= minsat) maxmax = minsat;
  if (maxmax <= maxhue) maxmax = maxhue;
  if (maxmax <= maxval) maxmax = maxval;
  if (maxmax <= maxsat) maxmax = maxsat;

  minhue = minmin; minval = minmin; minsat = minmin;
  maxhue = maxmax; maxval = maxmax; maxsat = maxmax;

  dataimg = vector_char(NcolBMP);

  if ((filebmp = fopen(FileOutput, "wb")) == NULL)
    edit_error("ERREUR DANS L'OUVERTURE DU FICHIER", FileOutput);

/* BMP HEADER */
  //write_header_bmp_24bit(Sub_Nlig, NcolBMP, filebmp);
  write_header_bmp_24bit(Sub_Nlig, Sub_Ncol, filebmp);

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

rewind(huefileinput);
rewind(valfileinput);
rewind(satfileinput);
if (FlagValid == 1) rewind(in_valid);

/* OFFSET READING */
  for (lig = 0; lig < Off_lig; lig++) {
    fread(&bufferdatahue[0], sizeof(float), Ncol, huefileinput);
    fread(&bufferdataval[0], sizeof(float), Ncol, valfileinput);
    fread(&bufferdatasat[0], sizeof(float), Ncol, satfileinput);
    if (FlagValid == 1) fread(&datatmp[0], sizeof(float), Ncol, in_valid);
    }

/* READ INPUT DATA FILE AND CREATE DATATMP 
   CORRESPONDING TO OUTPUTFORMAT */
     
  fseek(huefileinput, Sub_Nlig*Ncol*sizeof(float), SEEK_CUR);
  fseek(valfileinput, Sub_Nlig*Ncol*sizeof(float), SEEK_CUR);
  fseek(satfileinput, Sub_Nlig*Ncol*sizeof(float), SEEK_CUR);
  if (FlagValid == 1) fseek(in_valid, Sub_Nlig*Ncol*sizeof(float), SEEK_CUR);

/********************************************************************
********************************************************************/

for (lig = 0; lig < Sub_Nlig; lig++) {
  if (lig%(int)(Sub_Nlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_Nlig - 1));fflush(stdout);}
  
  fseek(huefileinput, -Ncol*sizeof(float), SEEK_CUR);
  fread(&bufferdatahue[0], sizeof(float), Ncol, huefileinput);
  fseek(huefileinput, -Ncol*sizeof(float), SEEK_CUR);

  fseek(valfileinput, -Ncol*sizeof(float), SEEK_CUR);
  fread(&bufferdataval[0], sizeof(float), Ncol, valfileinput);
  fseek(valfileinput, -Ncol*sizeof(float), SEEK_CUR);

  fseek(satfileinput, -Ncol*sizeof(float), SEEK_CUR);
  fread(&bufferdatasat[0], sizeof(float), Ncol, satfileinput);
  fseek(satfileinput, -Ncol*sizeof(float), SEEK_CUR);

  if (FlagValid == 1) {
    fseek(in_valid, -Ncol*sizeof(float), SEEK_CUR);
    fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    fseek(in_valid, -Ncol*sizeof(float), SEEK_CUR);
    }
    
  for (col = 0; col < Sub_Ncol; col++) {
    if (ValidMask[col+ Off_col] == 1.) {
      hue = fabs(bufferdatahue[col + Off_col]);
      if (hue <= eps) hue = eps;
      hue = 10 * log10(hue);
      if (hue > maxhue) hue = maxhue;
      if (hue < minhue) hue = minhue;
      hue = (hue - minhue) / (maxhue - minhue);
      if (hue > 1.) hue = 1.;
      if (hue < 0.) hue = 0.;
      hue = 360. * hue;

      sat = fabs(bufferdatasat[col + Off_col]);
      if (sat <= eps) sat = eps;
      sat = 10 * log10(sat);
      if (sat > maxsat) sat = maxsat;
      if (sat < minsat) sat = minsat;
      sat = (sat - minsat) / (maxsat - minsat);
      if (sat > 1.) sat = 1.;
      if (sat < 0.) sat = 0.;

      val = fabs(bufferdataval[col + Off_col]);
      if (val <= eps) val = eps;
      val = 10 * log10(val);
      if (val > maxval) val = maxval;
      if (val < minval) val = minval;
      val = (val - minval) / (maxval - minval);
      if (val > 1.) val = 1.;
      if (val < 0.) val = 0.;
 
      /* CONVERSION HSL TO RGB */
      if (val <= 0.5) m2 = val * (1. + sat);
      else m2 = val + sat - val * sat;

      m1 = 2 * val - m2;

      if (sat == 0.) {
        red = val;
        green = val;
        blue = val;
        } else {
        h = hue + 120;
        if (h > 360.) h = h - 360.;
        else if (h < 0.) h = h + 360.;
        if (h < 60.) red = m1 + (m2 - m1) * h / 60.;
        else if (h < 180.) red = m2;
        else if (h < 240.) red = m1 + (m2 - m1) * (240. - h) / 60.;
        else red = m1;

        h = hue;
        if (h > 360.) h = h - 360.;
        else if (h < 0.) h = h + 360.;
        if (h < 60.) green = m1 + (m2 - m1) * h / 60.;
        else if (h < 180.) green = m2;
        else if (h < 240.) green = m1 + (m2 - m1) * (240. - h) / 60.;
        else green = m1;

        h = hue - 120;
        if (h > 360.) h = h - 360.;
        else if (h < 0.) h = h + 360.;
        if (h < 60.) blue = m1 + (m2 - m1) * h / 60.;
        else if (h < 180.) blue = m2;
        else if (h < 240.) blue = m1 + (m2 - m1) * (240. - h) / 60.;
        else blue = m1;
        }

      if (blue > 1.) blue = 1.;
      if (blue < 0.) blue = 0.;
      l = (int) (floor(255 * blue));
      dataimg[3 * col + 0] = (char) (l);
      if (green > 1.) green = 1.;
      if (green < 0.) green = 0.;
      l = (int) (floor(255 * green));
      dataimg[3 * col + 1] = (char) (l);
      if (red > 1.) red = 1.;
      if (red < 0.) red = 0.;
      l = (int) (floor(255 * red));
      dataimg[3 * col + 2] = (char) (l);

      } else {

      l = (int) (floor(255 * 0.));
      dataimg[3 * col + 0] = (char) (l);
      dataimg[3 * col + 1] = (char) (l);
      dataimg[3 * col + 2] = (char) (l);
      } /* valid */
    } /*col*/
  for (col = 0; col < extracol; col++) {
    l = (int) (floor(255 * 0.));
    dataimg[3 * Sub_Ncol + col] = (char) (l);
    } /*col*/
  fwrite(&dataimg[0], sizeof(char), NcolBMP, filebmp);
  } /*lig*/

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_vector_char(dataimg);
  free_vector_float(datatmp);
  free_vector_float(bufferdatahue);
  free_vector_float(bufferdataval);
  free_vector_float(bufferdatasat);
  free_vector_float(ValidMask);
*/
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  fclose(filebmp);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  fclose(huefileinput);
  fclose(valfileinput);
  fclose(satfileinput);

/********************************************************************
********************************************************************/

  return 1;
}


