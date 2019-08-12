/*******************************************************************************
PolSARpro v4.0 is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 (1991) of the License, or any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. 

See the GNU General Public License (Version 2, 1991) for more details.

********************************************************************************

File     : tiff_2_bin.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Version  : 1.0
Creation : 01/2003
Update   :

*-------------------------------------------------------------------------------
INSTITUT D'ELECTRONIQUE et de TELECOMMUNICATIONS de RENNES (I.E.T.R)
UMR CNRS 6164
Groupe Image et Teledetection
Equipe SAPHIR (SAr Polarimetrie Holographie Interferometrie Radargrammetrie)
UNIVERSITE DE RENNES I
Pôle Micro-Ondes Radar
Bât. 11D - Campus de Beaulieu
263 Avenue Général Leclerc
35042 RENNES Cedex
Tel :(+33) 2 23 23 57 63
Fax :(+33) 2 23 23 69 63
e-mail : eric.pottier@univ-rennes1.fr, laurent.ferro-famil@univ-rennes1.fr
*-------------------------------------------------------------------------------
Description :  Recreate a bin file

*-------------------------------------------------------------------------------
Routines    :
void edit_error(char *s1,char *s2);
void check_file(char *file);
char *vector_char(int nrh);
void free_vector_char(char *v);
void bmp_8bit_char(int nlig,int ncol,float Max,float Min,char *ColorMap,char *DataBmp,char *name);

*******************************************************************************/
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
void read_tiff_strip(char FileInput[FilePathLength]);

/* GLOBAL VARIABLES */
int Rstrip, Nstrip;
int NNlig, NNcol;

/* GLOBAL ARRAYS */
int *Strip_Bytes;
int *Strip_Offset;

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
	FILE *fileinput, *fileoutput;
    char FileTiff[1024], FileBin[1024];
	
	char buffer[4];
	int IEEE,Strip,Bytes;
	char *charbuffer;
	float *bmpimage;
    long PointerPositionAv, PointerPositionAp;

/******************************************************************************/
/* INPUT PARAMETERS */
/******************************************************************************/

    if (argc < 3) {
	printf("TYPE: tiff_2_bin FileTiff FileBin\n");
	exit(1);
    } else {
	strcpy(FileTiff, argv[1]);
	strcpy(FileBin, argv[2]);
    }

    check_file(FileTiff);
    check_file(FileBin);
  
  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/******************************************************************************/

    if ((fileinput = fopen(FileTiff, "r")) == NULL)
	edit_error("Could not open configuration file : ", FileTiff);

    if ((fileoutput = fopen(FileBin, "wb")) == NULL)
	edit_error("Could not open configuration file : ", FileBin);

	fread(buffer, 1, 4, fileinput);
	IEEE = 2;
	if(buffer[0] == 0x49 && buffer[1] == 0x49 && buffer[2] == 0x2a && buffer[3] == 0x00) IEEE = 0;
	if(buffer[0] == 0x4d && buffer[1] == 0x4d && buffer[2] == 0x00 && buffer[3] == 0x2a) IEEE = 1;

	if (IEEE != 2) {
	  //Read_tiff_header
      read_tiff_strip(FileTiff);
printf("Nlig %i Ncol %i\n",NNlig,NNcol);      
printf("Nstrip %i Strip_Bytes %i\n",Nstrip,Strip_Bytes[0]);      

      charbuffer = vector_char(Strip_Bytes[0]);
      bmpimage = vector_float(2*Strip_Bytes[0]);

      for(Strip=0; Strip<Nstrip; Strip++) {
        rewind(fileinput);
        fseek(fileinput, Strip_Offset[Strip], SEEK_SET);
        PointerPositionAv = ftell(fileinput);
        fread(&charbuffer[0], sizeof(char), Strip_Bytes[Strip], fileinput);
        PointerPositionAp = ftell(fileinput); 
        for(Bytes=0; Bytes<(PointerPositionAp-PointerPositionAv); Bytes++) {
          bmpimage[2*Bytes] = charbuffer[Bytes];
          if (bmpimage[2*Bytes] < 0) bmpimage[2*Bytes] = bmpimage[2*Bytes] + 256;
          bmpimage[2*Bytes] = bmpimage[2*Bytes]/sqrt(2.);        
          bmpimage[2*Bytes+1] = bmpimage[2*Bytes];               
          }     
        for(Bytes=(PointerPositionAp-PointerPositionAv); Bytes<Strip_Bytes[Strip]; Bytes++) {
          bmpimage[2*Bytes] = charbuffer[Bytes-NNcol];
          if (bmpimage[2*Bytes] < 0) bmpimage[2*Bytes] = bmpimage[2*Bytes] + 256;
          bmpimage[2*Bytes] = bmpimage[2*Bytes]/sqrt(2.);        
          bmpimage[2*Bytes+1] = bmpimage[2*Bytes];               
          }     
        fwrite(&bmpimage[0], sizeof(float), 2*Strip_Bytes[Strip], fileoutput);         
        }
      fclose(fileinput);
      fclose(fileoutput);
      } else {
      edit_error(FileTiff, " is not a TIFF file");
      }
    return 1;
}	

/******************************************************************************/
/******************************************************************************/
/*******************************************************************************
*
*   read_tiff_header(...
*
*   This function reads the header of a TIFF 
*   file and places the needed information into
*   the struct tiff_header_struct.
*
*******************************************************************************/
void read_tiff_strip (char FileInput[FilePathLength])
{
  FILE *fileinput;

  unsigned char buffer[4];
  int i, k;
  long unsigned int offset;
  long unsigned int offset_strip;
  long unsigned int offset_strip_byte;
  short int Ndir, Flag, Type;
  int Nlg, Count, Value, IEEEFormat;

  char *pc;
  int il;
  int *vl;
  short int is;
  short int *v;

  if ((fileinput = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  rewind(fileinput);

/* Tiff File Header */

  /* Little / Big endian & TIFF identifier */
  fread(buffer, 1, 4, fileinput);
  if(buffer[0] == 0x49 && buffer[1] == 0x49 && buffer[2] == 0x2a && buffer[3] == 0x00) IEEEFormat = 0;
  if(buffer[0] == 0x4d && buffer[1] == 0x4d && buffer[2] == 0x00 && buffer[3] == 0x2a) IEEEFormat = 1;
  
  if (IEEEFormat == 0) fread(&offset, sizeof(int), 1, fileinput);
  if (IEEEFormat == 1) {
      vl = &il;pc = (char *) vl;
      pc[3] = getc(fileinput);pc[2] = getc(fileinput);
      pc[1] = getc(fileinput);pc[0] = getc(fileinput);
    offset = il;
  }

  rewind(fileinput);
  fseek(fileinput, offset, SEEK_SET);

  if (IEEEFormat == 0) fread(&Ndir, sizeof(short int), 1, fileinput);
  if (IEEEFormat == 1) {
    v = &is;pc = (char *) v;
    pc[1] = getc(fileinput);pc[0] = getc(fileinput);
    Ndir = is;
  }

  for (i=0; i<Ndir; i++) {
    Flag = 0; Type = 0; Count = 0; Value = 0;
    if (IEEEFormat == 0) {
      fread(&Flag, sizeof(short int), 1, fileinput);
      fread(&Type, sizeof(short int), 1, fileinput);
      fread(&Count, sizeof(int), 1, fileinput);
      if (Type == 3) {
        fread(&Value, sizeof(short int), 1, fileinput);
        fread(&k, sizeof(short int), 1, fileinput);
      }
      if (Type == 4) fread(&Value, sizeof(int), 1, fileinput);
      if ((Type != 3) && (Type != 4)) fread(&Value, sizeof(int), 1, fileinput);
    }
    if (IEEEFormat == 1) {
      v = &is;pc = (char *) v;
      pc[1] = getc(fileinput);pc[0] = getc(fileinput);
      Flag = is;
      v = &is;pc = (char *) v;
      pc[1] = getc(fileinput);pc[0] = getc(fileinput);
      Type = is;
      vl = &il;pc = (char *) vl;
      pc[3] = getc(fileinput);pc[2] = getc(fileinput);
      pc[1] = getc(fileinput);pc[0] = getc(fileinput);
      Count = il;
      if (Type == 3) {
        v = &is;pc = (char *) v;
        pc[1] = getc(fileinput);pc[0] = getc(fileinput);
        Value = is;
        fread(&k, sizeof(short int), 1, fileinput);
      }
      if (Type == 4) {
        vl = &il;pc = (char *) vl;
        pc[3] = getc(fileinput);pc[2] = getc(fileinput);
        pc[1] = getc(fileinput);pc[0] = getc(fileinput);
        Value = il;
      }
      if ((Type != 3) && (Type != 4)) fread(&Value, sizeof(int), 1, fileinput);
    }
    if (Flag == 257) Nlg = Value;

    if (Flag == 256) NNcol = Value;
    if (Flag == 257) NNlig = Value;

    if (Flag == 273) Nstrip = Count;
    if (Flag == 278) Rstrip = Value;

    if (Flag == 273) offset_strip = Value;
    if (Flag == 279) offset_strip_byte = Value;
    }

  Strip_Offset = vector_int(Nlg);
  Strip_Bytes = vector_int(Nlg);

  rewind(fileinput);
  fseek(fileinput, offset_strip, SEEK_SET);
  for (i=0; i<Nstrip; i++) {
    if (IEEEFormat == 0) fread(&Value, sizeof(int), 1, fileinput);
    if (IEEEFormat == 1) {
      vl = &il;pc = (char *) vl;
      pc[3] = getc(fileinput);pc[2] = getc(fileinput);
      pc[1] = getc(fileinput);pc[0] = getc(fileinput);
      Value = il;
    }
    Strip_Offset[i] = Value;
  }

  rewind(fileinput);
  fseek(fileinput, offset_strip_byte, SEEK_SET);
  for (i=0; i<Nstrip; i++) {
    if (IEEEFormat == 0) fread(&Value, sizeof(int), 1, fileinput);
    if (IEEEFormat == 1) {
      vl = &il;pc = (char *) vl;
      pc[3] = getc(fileinput);pc[2] = getc(fileinput);
      pc[1] = getc(fileinput);pc[0] = getc(fileinput);
      Value = il;
    }
    Strip_Bytes[i] = Value;
  }

  fclose(fileinput);
}
