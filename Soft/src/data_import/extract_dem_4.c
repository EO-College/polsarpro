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

File   : extract_dem_4.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 2.0
Creation : 05/2011
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

Description :  Extract a DEM from 4 SRTM or an ASTER Files

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

/* CONSTANTS  */
#define  TopLeftFile   0
#define TopRightFile  1
#define BottomLeftFile  2
#define BottomRightFile 3

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"
void read_tiff0(char FileInput[FilePathLength]);
void read_tiff1(char FileInput[FilePathLength]);
void read_tiff2(char FileInput[FilePathLength]);
void read_tiff3(char FileInput[FilePathLength]);

/* GLOBAL VARIABLES */
int Rstrip0;
int Rstrip1;
int Rstrip2;
int Rstrip3;

/* GLOBAL ARRAYS */
int NligDEM, NcolDEM, IEEE;
int *Strip_Bytes0;
int *Strip_Offset0;
int *Strip_Bytes1;
int *Strip_Offset1;
int *Strip_Bytes2;
int *Strip_Offset2;
int *Strip_Bytes3;
int *Strip_Offset3;

double DeltaX,DeltaY;
double LonTopLeftImg0, LatTopLeftImg0;
double LonTopLeftImg1, LatTopLeftImg1;
double LonTopLeftImg2, LatTopLeftImg2;
double LonTopLeftImg3, LatTopLeftImg3;

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

  FILE *in_file[4], *out_file;

  char File1[FilePathLength],File2[FilePathLength],File3[FilePathLength],File4[FilePathLength];
  char DirOutput[FilePathLength],file_name[FilePathLength];

  int i, lig, col, np;
  int Nligoffset, Ncoloffset;
  int Nligfin, Ncolfin;
  int Strip0, Strip1, Strip2, Strip3;
  int Nfile;

  int Nlig1, Nlig2, Ncol1, Ncol2;

  char *pc;
  short int fl1;
  short int *v;

  long PointerPosition, CurrentPointerPosition;

  float Lat[5],Lon[5];
  float LatNorth,LatSouth,LonWest,LonEast;

  short int *M_in;
  float *M_out;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nextract_dem_4.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-if1  	input file 1 : Top Left\n");
strcat(UsageHelp," (string)	-if2  	input file 2 : Top Right\n");
strcat(UsageHelp," (string)	-if3  	input file 3 : Bottom Left\n");
strcat(UsageHelp," (string)	-if4  	input file 4 : Bottom Right\n");
strcat(UsageHelp," (float) 	-la00	latitude top left\n");
strcat(UsageHelp," (float) 	-lo00	longitude top left\n");
strcat(UsageHelp," (float) 	-la0N	latitude top right\n");
strcat(UsageHelp," (float) 	-lo0N	longitude top right\n");
strcat(UsageHelp," (float) 	-laN0	latitude bottom left\n");
strcat(UsageHelp," (float) 	-loN0	longitude bottom left\n");
strcat(UsageHelp," (float) 	-laNN	latitude bottom right\n");
strcat(UsageHelp," (float) 	-loNN	longitude bottom right\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 27) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,DirOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if1",str_cmd_prm,File1,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if2",str_cmd_prm,File2,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if3",str_cmd_prm,File3,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if4",str_cmd_prm,File4,1,UsageHelp);
  get_commandline_prm(argc,argv,"-la00",flt_cmd_prm,&Lat[0],1,UsageHelp);
  get_commandline_prm(argc,argv,"-lo00",flt_cmd_prm,&Lon[0],1,UsageHelp);
  get_commandline_prm(argc,argv,"-la0N",flt_cmd_prm,&Lat[1],1,UsageHelp);
  get_commandline_prm(argc,argv,"-lo0N",flt_cmd_prm,&Lon[1],1,UsageHelp);
  get_commandline_prm(argc,argv,"-laN0",flt_cmd_prm,&Lat[2],1,UsageHelp);
  get_commandline_prm(argc,argv,"-loN0",flt_cmd_prm,&Lon[2],1,UsageHelp);
  get_commandline_prm(argc,argv,"-laNN",flt_cmd_prm,&Lat[3],1,UsageHelp);
  get_commandline_prm(argc,argv,"-loNN",flt_cmd_prm,&Lon[3],1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  Nfile = 4;

  check_file(File1);
  check_file(File2);
  check_file(File3);
  check_file(File4);
  check_dir(DirOutput);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/*******************************************************************/
/* READ TIFF HEADER */
/*******************************************************************/
  
  read_tiff0(File1);
  read_tiff1(File2);
  read_tiff2(File3);
  read_tiff3(File4);

/*******************************************************************/
/* INPUT / OUTPUT BINARY DATA FILES */
/*******************************************************************/

  if ((in_file[0] = fopen(File1, "rb")) == NULL)
    edit_error("Could not open input file : ", File1);
  if ((in_file[1] = fopen(File2, "rb")) == NULL)
    edit_error("Could not open input file : ", File2);
  if ((in_file[2] = fopen(File3, "rb")) == NULL)
    edit_error("Could not open input file : ", File3);
  if ((in_file[3] = fopen(File4, "rb")) == NULL)
    edit_error("Could not open input file : ", File4);

  sprintf(file_name, "%s%s", DirOutput, "DEM.bin");
  if ((out_file = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open output file : ", file_name);

/*******************************************************************/
/* DEM CONFIGURATION FILE*/
/*******************************************************************/

  LonWest = Lon[0];
  for (i=0; i<4; i++)  if (Lon[i] <= LonWest) LonWest = Lon[i];
  
  LonEast = Lon[0];
  for (i=0; i<4; i++)  if (LonEast <= Lon[i]) LonEast = Lon[i];

  LatNorth = Lat[0];
  for (i=0; i<4; i++)  if (LatNorth <= Lat[i]) LatNorth = Lat[i];

  LatSouth = Lat[0];
  for (i=0; i<4; i++)  if (Lat[i] <= LatSouth) LatSouth = Lat[i];
  
/*******************************************************************/

  Nligoffset = (int)(fabs((LatTopLeftImg0-LatNorth)/DeltaY));
  Nligfin = 1 + (int)((LatNorth-LatSouth)/DeltaY);
  Nlig1 = NligDEM - Nligoffset;
  Nlig2 = Nligfin - Nlig1;
  Ncoloffset = (int)(fabs((LonTopLeftImg0-LonWest)/DeltaX));
  Ncolfin = 1 + (int)((LonEast-LonWest)/DeltaX);
  Ncol1 = NcolDEM - Ncoloffset;
  Ncol2 = Ncolfin - Ncol1;
    
/*******************************************************************/

  M_in = vector_short_int(NcolDEM);
  M_out = vector_float(Ncolfin);

/*******************************************************************/

for (np = 0; np < Nfile; np++) rewind(in_file[np]);

fseek(in_file[0], Strip_Offset0[0], SEEK_SET);
fseek(in_file[1], Strip_Offset1[0], SEEK_SET);
fseek(in_file[2], Strip_Offset2[0], SEEK_SET);
fseek(in_file[3], Strip_Offset3[0], SEEK_SET);

  Strip0 = 1; Strip1 = 1;
  //TOPLEFTFILE - TOPRIGHTFILE
  for (lig = 0; lig < Nligoffset; lig++) {
    fread(&M_in[0], sizeof(short int), NcolDEM, in_file[TopLeftFile]);
    if (fmod(lig+1,Rstrip0) == 0) {
      CurrentPointerPosition = ftell(in_file[TopLeftFile]);
      PointerPosition = Strip_Offset0[Strip0]; Strip0++;
      fseek(in_file[TopLeftFile], (PointerPosition - CurrentPointerPosition), SEEK_CUR);
      }
    fread(&M_in[0], sizeof(short int), NcolDEM, in_file[TopRightFile]);
    if (fmod(lig+1,Rstrip1) == 0) {
      CurrentPointerPosition = ftell(in_file[TopRightFile]);
      PointerPosition = Strip_Offset1[Strip1]; Strip1++;
      fseek(in_file[TopRightFile], (PointerPosition - CurrentPointerPosition), SEEK_CUR);
      }
    }

  for (lig = 0; lig < Nlig1; lig++) {
    if (lig%(int)(Nligfin/20) == 0) {printf("%f\r", 100. * lig / (Nligfin - 1));fflush(stdout);}
    //TOPLEFTFILE
    if (IEEE == 0) fread(&M_in[0], sizeof(short int), NcolDEM, in_file[TopLeftFile]);
    if (IEEE == 1) {
      for (col = 0; col < NcolDEM; col++) {
        v = &fl1;pc = (char *) v;
        pc[1] = getc(in_file[TopLeftFile]);pc[0] = getc(in_file[TopLeftFile]);
        M_in[col] = fl1; 
        }
      }
    for (col = 0; col < Ncol1; col++) {
      M_out[col] = (float)(M_in[Ncoloffset + col]);
      if (M_out[col] == -32768.0) M_out[col] = -0.1;
      if (M_out[col] == -9999.0) M_out[col] = -0.1;
      }

    //TOPRIGHTFILE
    if (IEEE == 0) fread(&M_in[0], sizeof(short int), NcolDEM, in_file[TopRightFile]);
    if (IEEE == 1) {
      for (col = 0; col < NcolDEM; col++) {
        v = &fl1;pc = (char *) v;
        pc[1] = getc(in_file[TopRightFile]);pc[0] = getc(in_file[TopRightFile]);
        M_in[col] = fl1; 
        }
      }
    for (col = 0; col < Ncol2; col++) {
      M_out[col+Ncol1] = (float)(M_in[col]);
      if (M_out[col+Ncol1] == -32768.0) M_out[col+Ncol1] = -0.1;
      if (M_out[col+Ncol1] == -9999.0) M_out[col+Ncol1] = -0.1;
      }

    if (fmod(lig+1+Nligoffset,Rstrip0) == 0) {
      CurrentPointerPosition = ftell(in_file[TopLeftFile]);
      PointerPosition = Strip_Offset0[Strip0]; Strip0++;
      fseek(in_file[TopLeftFile], (PointerPosition - CurrentPointerPosition), SEEK_CUR);
      }
    if (fmod(lig+1+Nligoffset,Rstrip1) == 0) {
      CurrentPointerPosition = ftell(in_file[TopRightFile]);
      PointerPosition = Strip_Offset1[Strip1]; Strip1++;
      fseek(in_file[TopRightFile], (PointerPosition - CurrentPointerPosition), SEEK_CUR);
      }

    fwrite(&M_out[0], sizeof(float), Ncolfin, out_file);
    }

  //BOTTOMLEFTFILE - BOTTOMRIGHTFILE
  Strip2 = 1; Strip3 = 1;
  for (lig = 0; lig < Nlig2; lig++) {
    if ((lig+Nlig1)%(int)(Nligfin/20) == 0) {printf("%f\r", 100. * (lig+Nlig1) / (Nligfin - 1));fflush(stdout);}
    //BOTTOMLEFTFILE
    if (IEEE == 0) fread(&M_in[0], sizeof(short int), NcolDEM, in_file[BottomLeftFile]);
    if (IEEE == 1) {
      for (col = 0; col < NcolDEM; col++) {
        v = &fl1;pc = (char *) v;
        pc[1] = getc(in_file[BottomLeftFile]);pc[0] = getc(in_file[BottomLeftFile]);
        M_in[col] = fl1; 
        }
      }
    for (col = 0; col < Ncol1; col++) {
      M_out[col] = (float)(M_in[Ncoloffset + col]);
      if (M_out[col] == -32768.0) M_out[col] = -0.1;
      if (M_out[col] == -9999.0) M_out[col] = -0.1;
      }

    //BOTTOMRIGHTFILE
    if (IEEE == 0) fread(&M_in[0], sizeof(short int), NcolDEM, in_file[BottomRightFile]);
    if (IEEE == 1) {
      for (col = 0; col < NcolDEM; col++) {
        v = &fl1;pc = (char *) v;
        pc[1] = getc(in_file[BottomRightFile]);pc[0] = getc(in_file[BottomRightFile]);
        M_in[col] = fl1; 
        }
      }
    for (col = 0; col < Ncol2; col++) {
      M_out[col+Ncol1] = (float)(M_in[col]);
      if (M_out[col+Ncol1] == -32768.0) M_out[col+Ncol1] = -0.1;
      if (M_out[col+Ncol1] == -9999.0) M_out[col+Ncol1] = -0.1;
      }

    if (fmod(lig+1+Nligoffset,Rstrip2) == 0) {
      CurrentPointerPosition = ftell(in_file[BottomLeftFile]);
      PointerPosition = Strip_Offset2[Strip2]; Strip2++;
      fseek(in_file[BottomLeftFile], (PointerPosition - CurrentPointerPosition), SEEK_CUR);
      }
    if (fmod(lig+1+Nligoffset,Rstrip3) == 0) {
      CurrentPointerPosition = ftell(in_file[BottomRightFile]);
      PointerPosition = Strip_Offset3[Strip3]; Strip3++;
      fseek(in_file[BottomRightFile], (PointerPosition - CurrentPointerPosition), SEEK_CUR);
      }

    fwrite(&M_out[0], sizeof(float), Ncolfin, out_file);
    }
  
  for (np = 0; np < Nfile; np++) fclose(in_file[np]);
  fclose(out_file);

/*******************************************************************/

  sprintf(file_name, "%s%s", DirOutput, "DEM.txt");
  if ((out_file = fopen(file_name, "w")) == NULL)
    edit_error("Could not open output file : ", file_name);
  fprintf(out_file,"Nlig\n");
  fprintf(out_file,"%i\n",Nligfin);
  fprintf(out_file,"Ncol\n");
  fprintf(out_file,"%i\n",Ncolfin);
  fprintf(out_file,"LatCenter\n");
  fprintf(out_file,"%f\n",LatSouth+(Ncolfin-1)*DeltaY/2.);
  fprintf(out_file,"LonCenter\n");
  fprintf(out_file,"%f\n",LonWest+(Nligfin-1)*DeltaX/2.);
  fprintf(out_file,"LatTopLeft\n");
  fprintf(out_file,"%f\n",LatNorth);
  fprintf(out_file,"LonTopLeft\n");
  fprintf(out_file,"%f\n",LonWest);
  fprintf(out_file,"LatTopRight\n");
  fprintf(out_file,"%f\n",LatNorth);
  fprintf(out_file,"LonTopRight\n");
  fprintf(out_file,"%f\n",LonEast);
  fprintf(out_file,"LatBottomLeft\n");
  fprintf(out_file,"%f\n",LatSouth);
  fprintf(out_file,"LonBottomLeft\n");
  fprintf(out_file,"%f\n",LonWest);
  fprintf(out_file,"LatBottomRight\n");
  fprintf(out_file,"%f\n",LatSouth);
  fprintf(out_file,"LonBottomRight\n");
  fprintf(out_file,"%f\n",LonEast);
  fprintf(out_file,"LonWest\n");
  fprintf(out_file,"%f\n",LonWest);
  fprintf(out_file,"LonEast\n");
  fprintf(out_file,"%f\n",LonEast);
  fprintf(out_file,"LatNorth\n");
  fprintf(out_file,"%f\n",LatNorth);
  fprintf(out_file,"LatSouth\n");
  fprintf(out_file,"%f\n",LatSouth);
  fclose(out_file);


/*******************************************************************/

  free_vector_float(M_out);
  free_vector_short_int(M_in);

  return 1;
}

/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/

void read_tiff0(char FileInput[FilePathLength])
{
  FILE *fileinput;

  unsigned char buffer[4];
  int i, k;
  long unsigned int offset, Value;
  long unsigned int offset_strip;
  long unsigned int offset_strip_byte;
  long unsigned int ModelPixelScaleOff;
  long unsigned int ModelTiePointOff;
  short int Ndir, Type;
  int Flag, Nstrip, Count;
//  int ModelPixelScaleN, ModelTiePointN;
  double FloatValue;

  char *pc;
  int il, *vl;
  short int is, *v;
  float ifl, *vfl;

  if ((fileinput = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  rewind(fileinput);
/*Tiff File Header*/
  /* Little / Big endian & TIFF identifier */
  fread(buffer, 1, 4, fileinput);
  if(buffer[0] == 0x49 && buffer[1] == 0x49 && buffer[2] == 0x2a && buffer[3] == 0x00) IEEE = 0;
  if(buffer[0] == 0x4d && buffer[1] == 0x4d && buffer[2] == 0x00 && buffer[3] == 0x2a) IEEE = 1;
  
  if (IEEE == 0) fread(&offset, sizeof(int), 1, fileinput);
  if (IEEE == 1) {
      vl = &il;pc = (char *) vl;
      pc[3] = getc(fileinput);pc[2] = getc(fileinput);
      pc[1] = getc(fileinput);pc[0] = getc(fileinput);
    offset = il;
    }

  rewind(fileinput);
  fseek(fileinput, offset, SEEK_SET);

  if (IEEE == 0) fread(&Ndir, sizeof(short int), 1, fileinput);
  if (IEEE == 1) {
    v = &is;pc = (char *) v;
    pc[1] = getc(fileinput);pc[0] = getc(fileinput);
    Ndir = is;
    }

  for (i=0; i<Ndir; i++) {
    Flag = 0; Type = 0; Count = 0; Value = 0;
    if (IEEE == 0) {
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
    if (IEEE == 1) {
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
    if (Flag == 256) NligDEM = Value;
    if (Flag == 257) NcolDEM = Value;

    if (Flag == 273) Nstrip = Count;
    if (Flag == 278) Rstrip0 = Value;

    if (Flag == 273) offset_strip = Value;
    if (Flag == 279) offset_strip_byte = Value;

    if (Flag == 33550) {
//      ModelPixelScaleN = Count;
      ModelPixelScaleOff = Value;
      }
    if (Flag == 33922) {
//      ModelTiePointN = Count;
      ModelTiePointOff = Value;
      }
    }

  Strip_Offset0 = vector_int(NligDEM);
  Strip_Bytes0 = vector_int(NligDEM);

  rewind(fileinput);
  fseek(fileinput, offset_strip, SEEK_SET);
  for (i=0; i<Nstrip; i++) {
    if (IEEE == 0) fread(&Value, sizeof(int), 1, fileinput);
    if (IEEE == 1) {
      vl = &il;pc = (char *) vl;
      pc[3] = getc(fileinput);pc[2] = getc(fileinput);
      pc[1] = getc(fileinput);pc[0] = getc(fileinput);
      Value = il;
    }
    Strip_Offset0[i] = Value;
  }

  rewind(fileinput);
  fseek(fileinput, offset_strip_byte, SEEK_SET);
  for (i=0; i<Nstrip; i++) {
    if (IEEE == 0) fread(&Value, sizeof(int), 1, fileinput);
    if (IEEE == 1) {
      vl = &il;pc = (char *) vl;
      pc[3] = getc(fileinput);pc[2] = getc(fileinput);
      pc[1] = getc(fileinput);pc[0] = getc(fileinput);
      Value = il;
    }
    Strip_Bytes0[i] = Value;
  }

  rewind(fileinput);
  fseek(fileinput, ModelPixelScaleOff, SEEK_SET);
  if (IEEE == 0) {
    fread(&DeltaX, sizeof(double), 1, fileinput);
    fread(&DeltaY, sizeof(double), 1, fileinput);
    }
  if (IEEE == 1) {
    vfl = &ifl;pc = (char *) vfl;
    pc[7] = getc(fileinput);pc[6] = getc(fileinput);
    pc[5] = getc(fileinput);pc[4] = getc(fileinput);
    pc[3] = getc(fileinput);pc[2] = getc(fileinput);
    pc[1] = getc(fileinput);pc[0] = getc(fileinput);
    DeltaX = ifl;
    vfl = &ifl;pc = (char *) vfl;
    pc[7] = getc(fileinput);pc[6] = getc(fileinput);
    pc[5] = getc(fileinput);pc[4] = getc(fileinput);
    pc[3] = getc(fileinput);pc[2] = getc(fileinput);
    pc[1] = getc(fileinput);pc[0] = getc(fileinput);
    DeltaY = ifl;
    }
      
  rewind(fileinput);
  fseek(fileinput, ModelTiePointOff, SEEK_SET);
  if (IEEE == 0) {
    fread(&FloatValue, sizeof(double), 1, fileinput);
    fread(&FloatValue, sizeof(double), 1, fileinput);
    fread(&FloatValue, sizeof(double), 1, fileinput);
    fread(&LonTopLeftImg0, sizeof(double), 1, fileinput);
    fread(&LatTopLeftImg0, sizeof(double), 1, fileinput);
    }
  if (IEEE == 1) {
    fread(&FloatValue, sizeof(double), 1, fileinput);
    fread(&FloatValue, sizeof(double), 1, fileinput);
    fread(&FloatValue, sizeof(double), 1, fileinput);
    vfl = &ifl;pc = (char *) vfl;
    pc[7] = getc(fileinput);pc[6] = getc(fileinput);
    pc[5] = getc(fileinput);pc[4] = getc(fileinput);
    pc[3] = getc(fileinput);pc[2] = getc(fileinput);
    pc[1] = getc(fileinput);pc[0] = getc(fileinput);
    LonTopLeftImg0 = ifl;
    vfl = &ifl;pc = (char *) vfl;
    pc[7] = getc(fileinput);pc[6] = getc(fileinput);
    pc[5] = getc(fileinput);pc[4] = getc(fileinput);
    pc[3] = getc(fileinput);pc[2] = getc(fileinput);
    pc[1] = getc(fileinput);pc[0] = getc(fileinput);
    LatTopLeftImg0 = ifl;
    }
  
  fclose(fileinput);
}

/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/

void read_tiff1(char FileInput[FilePathLength])
{
  FILE *fileinput;

  unsigned char buffer[4];
  int i, k;
  long unsigned int offset, Value;
  long unsigned int offset_strip;
  long unsigned int offset_strip_byte;
  long unsigned int ModelPixelScaleOff;
  long unsigned int ModelTiePointOff;
  short int Ndir, Type;
  int Flag, Nstrip, Count;
//  int ModelPixelScaleN, ModelTiePointN;
  double FloatValue;

  char *pc;
  int il, *vl;
  short int is, *v;
  float ifl, *vfl;

  if ((fileinput = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  rewind(fileinput);
/*Tiff File Header*/
  /* Little / Big endian & TIFF identifier */
  fread(buffer, 1, 4, fileinput);
  if(buffer[0] == 0x49 && buffer[1] == 0x49 && buffer[2] == 0x2a && buffer[3] == 0x00) IEEE = 0;
  if(buffer[0] == 0x4d && buffer[1] == 0x4d && buffer[2] == 0x00 && buffer[3] == 0x2a) IEEE = 1;
  
  if (IEEE == 0) fread(&offset, sizeof(int), 1, fileinput);
  if (IEEE == 1) {
      vl = &il;pc = (char *) vl;
      pc[3] = getc(fileinput);pc[2] = getc(fileinput);
      pc[1] = getc(fileinput);pc[0] = getc(fileinput);
    offset = il;
    }

  rewind(fileinput);
  fseek(fileinput, offset, SEEK_SET);

  if (IEEE == 0) fread(&Ndir, sizeof(short int), 1, fileinput);
  if (IEEE == 1) {
    v = &is;pc = (char *) v;
    pc[1] = getc(fileinput);pc[0] = getc(fileinput);
    Ndir = is;
    }

  for (i=0; i<Ndir; i++) {
    Flag = 0; Type = 0; Count = 0; Value = 0;
    if (IEEE == 0) {
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
    if (IEEE == 1) {
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
    if (Flag == 256) NligDEM = Value;
    if (Flag == 257) NcolDEM = Value;

    if (Flag == 273) Nstrip = Count;
    if (Flag == 278) Rstrip1 = Value;

    if (Flag == 273) offset_strip = Value;
    if (Flag == 279) offset_strip_byte = Value;

    if (Flag == 33550) {
//      ModelPixelScaleN = Count;
      ModelPixelScaleOff = Value;
      }
    if (Flag == 33922) {
//      ModelTiePointN = Count;
      ModelTiePointOff = Value;
      }
    }

  Strip_Offset1 = vector_int(NligDEM);
  Strip_Bytes1 = vector_int(NligDEM);

  rewind(fileinput);
  fseek(fileinput, offset_strip, SEEK_SET);
  for (i=0; i<Nstrip; i++) {
    if (IEEE == 0) fread(&Value, sizeof(int), 1, fileinput);
    if (IEEE == 1) {
      vl = &il;pc = (char *) vl;
      pc[3] = getc(fileinput);pc[2] = getc(fileinput);
      pc[1] = getc(fileinput);pc[0] = getc(fileinput);
      Value = il;
    }
    Strip_Offset1[i] = Value;
  }

  rewind(fileinput);
  fseek(fileinput, offset_strip_byte, SEEK_SET);
  for (i=0; i<Nstrip; i++) {
    if (IEEE == 0) fread(&Value, sizeof(int), 1, fileinput);
    if (IEEE == 1) {
      vl = &il;pc = (char *) vl;
      pc[3] = getc(fileinput);pc[2] = getc(fileinput);
      pc[1] = getc(fileinput);pc[0] = getc(fileinput);
      Value = il;
    }
    Strip_Bytes1[i] = Value;
  }

  rewind(fileinput);
  fseek(fileinput, ModelPixelScaleOff, SEEK_SET);
  if (IEEE == 0) {
    fread(&DeltaX, sizeof(double), 1, fileinput);
    fread(&DeltaY, sizeof(double), 1, fileinput);
    }
  if (IEEE == 1) {
    vfl = &ifl;pc = (char *) vfl;
    pc[7] = getc(fileinput);pc[6] = getc(fileinput);
    pc[5] = getc(fileinput);pc[4] = getc(fileinput);
    pc[3] = getc(fileinput);pc[2] = getc(fileinput);
    pc[1] = getc(fileinput);pc[0] = getc(fileinput);
    DeltaX = ifl;
    vfl = &ifl;pc = (char *) vfl;
    pc[7] = getc(fileinput);pc[6] = getc(fileinput);
    pc[5] = getc(fileinput);pc[4] = getc(fileinput);
    pc[3] = getc(fileinput);pc[2] = getc(fileinput);
    pc[1] = getc(fileinput);pc[0] = getc(fileinput);
    DeltaY = ifl;
    }
      
  rewind(fileinput);
  fseek(fileinput, ModelTiePointOff, SEEK_SET);
  if (IEEE == 0) {
    fread(&FloatValue, sizeof(double), 1, fileinput);
    fread(&FloatValue, sizeof(double), 1, fileinput);
    fread(&FloatValue, sizeof(double), 1, fileinput);
    fread(&LonTopLeftImg1, sizeof(double), 1, fileinput);
    fread(&LatTopLeftImg1, sizeof(double), 1, fileinput);
    }
  if (IEEE == 1) {
    fread(&FloatValue, sizeof(double), 1, fileinput);
    fread(&FloatValue, sizeof(double), 1, fileinput);
    fread(&FloatValue, sizeof(double), 1, fileinput);
    vfl = &ifl;pc = (char *) vfl;
    pc[7] = getc(fileinput);pc[6] = getc(fileinput);
    pc[5] = getc(fileinput);pc[4] = getc(fileinput);
    pc[3] = getc(fileinput);pc[2] = getc(fileinput);
    pc[1] = getc(fileinput);pc[0] = getc(fileinput);
    LonTopLeftImg1 = ifl;
    vfl = &ifl;pc = (char *) vfl;
    pc[7] = getc(fileinput);pc[6] = getc(fileinput);
    pc[5] = getc(fileinput);pc[4] = getc(fileinput);
    pc[3] = getc(fileinput);pc[2] = getc(fileinput);
    pc[1] = getc(fileinput);pc[0] = getc(fileinput);
    LatTopLeftImg1 = ifl;
    }
  
  fclose(fileinput);
}

/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/

void read_tiff2(char FileInput[FilePathLength])
{
  FILE *fileinput;

  unsigned char buffer[4];
  int i, k;
  long unsigned int offset, Value;
  long unsigned int offset_strip;
  long unsigned int offset_strip_byte;
  long unsigned int ModelPixelScaleOff;
  long unsigned int ModelTiePointOff;
  short int Ndir, Type;
  int Flag, Nstrip, Count;
//  int ModelPixelScaleN, ModelTiePointN;
  double FloatValue;

  char *pc;
  int il, *vl;
  short int is, *v;
  float ifl, *vfl;

  if ((fileinput = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  rewind(fileinput);
/*Tiff File Header*/
  /* Little / Big endian & TIFF identifier */
  fread(buffer, 1, 4, fileinput);
  if(buffer[0] == 0x49 && buffer[1] == 0x49 && buffer[2] == 0x2a && buffer[3] == 0x00) IEEE = 0;
  if(buffer[0] == 0x4d && buffer[1] == 0x4d && buffer[2] == 0x00 && buffer[3] == 0x2a) IEEE = 1;
  
  if (IEEE == 0) fread(&offset, sizeof(int), 1, fileinput);
  if (IEEE == 1) {
      vl = &il;pc = (char *) vl;
      pc[3] = getc(fileinput);pc[2] = getc(fileinput);
      pc[1] = getc(fileinput);pc[0] = getc(fileinput);
    offset = il;
    }

  rewind(fileinput);
  fseek(fileinput, offset, SEEK_SET);

  if (IEEE == 0) fread(&Ndir, sizeof(short int), 1, fileinput);
  if (IEEE == 1) {
    v = &is;pc = (char *) v;
    pc[1] = getc(fileinput);pc[0] = getc(fileinput);
    Ndir = is;
    }

  for (i=0; i<Ndir; i++) {
    Flag = 0; Type = 0; Count = 0; Value = 0;
    if (IEEE == 0) {
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
    if (IEEE == 1) {
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
    if (Flag == 256) NligDEM = Value;
    if (Flag == 257) NcolDEM = Value;

    if (Flag == 273) Nstrip = Count;
    if (Flag == 278) Rstrip2 = Value;

    if (Flag == 273) offset_strip = Value;
    if (Flag == 279) offset_strip_byte = Value;

    if (Flag == 33550) {
//      ModelPixelScaleN = Count;
      ModelPixelScaleOff = Value;
      }
    if (Flag == 33922) {
//      ModelTiePointN = Count;
      ModelTiePointOff = Value;
      }
    }

  Strip_Offset2 = vector_int(NligDEM);
  Strip_Bytes2 = vector_int(NligDEM);

  rewind(fileinput);
  fseek(fileinput, offset_strip, SEEK_SET);
  for (i=0; i<Nstrip; i++) {
    if (IEEE == 0) fread(&Value, sizeof(int), 1, fileinput);
    if (IEEE == 1) {
      vl = &il;pc = (char *) vl;
      pc[3] = getc(fileinput);pc[2] = getc(fileinput);
      pc[1] = getc(fileinput);pc[0] = getc(fileinput);
      Value = il;
    }
    Strip_Offset2[i] = Value;
  }

  rewind(fileinput);
  fseek(fileinput, offset_strip_byte, SEEK_SET);
  for (i=0; i<Nstrip; i++) {
    if (IEEE == 0) fread(&Value, sizeof(int), 1, fileinput);
    if (IEEE == 1) {
      vl = &il;pc = (char *) vl;
      pc[3] = getc(fileinput);pc[2] = getc(fileinput);
      pc[1] = getc(fileinput);pc[0] = getc(fileinput);
      Value = il;
    }
    Strip_Bytes2[i] = Value;
  }

  rewind(fileinput);
  fseek(fileinput, ModelPixelScaleOff, SEEK_SET);
  if (IEEE == 0) {
    fread(&DeltaX, sizeof(double), 1, fileinput);
    fread(&DeltaY, sizeof(double), 1, fileinput);
    }
  if (IEEE == 1) {
    vfl = &ifl;pc = (char *) vfl;
    pc[7] = getc(fileinput);pc[6] = getc(fileinput);
    pc[5] = getc(fileinput);pc[4] = getc(fileinput);
    pc[3] = getc(fileinput);pc[2] = getc(fileinput);
    pc[1] = getc(fileinput);pc[0] = getc(fileinput);
    DeltaX = ifl;
    vfl = &ifl;pc = (char *) vfl;
    pc[7] = getc(fileinput);pc[6] = getc(fileinput);
    pc[5] = getc(fileinput);pc[4] = getc(fileinput);
    pc[3] = getc(fileinput);pc[2] = getc(fileinput);
    pc[1] = getc(fileinput);pc[0] = getc(fileinput);
    DeltaY = ifl;
    }
      
  rewind(fileinput);
  fseek(fileinput, ModelTiePointOff, SEEK_SET);
  if (IEEE == 0) {
    fread(&FloatValue, sizeof(double), 1, fileinput);
    fread(&FloatValue, sizeof(double), 1, fileinput);
    fread(&FloatValue, sizeof(double), 1, fileinput);
    fread(&LonTopLeftImg2, sizeof(double), 1, fileinput);
    fread(&LatTopLeftImg2, sizeof(double), 1, fileinput);
    }
  if (IEEE == 1) {
    fread(&FloatValue, sizeof(double), 1, fileinput);
    fread(&FloatValue, sizeof(double), 1, fileinput);
    fread(&FloatValue, sizeof(double), 1, fileinput);
    vfl = &ifl;pc = (char *) vfl;
    pc[7] = getc(fileinput);pc[6] = getc(fileinput);
    pc[5] = getc(fileinput);pc[4] = getc(fileinput);
    pc[3] = getc(fileinput);pc[2] = getc(fileinput);
    pc[1] = getc(fileinput);pc[0] = getc(fileinput);
    LonTopLeftImg2 = ifl;
    vfl = &ifl;pc = (char *) vfl;
    pc[7] = getc(fileinput);pc[6] = getc(fileinput);
    pc[5] = getc(fileinput);pc[4] = getc(fileinput);
    pc[3] = getc(fileinput);pc[2] = getc(fileinput);
    pc[1] = getc(fileinput);pc[0] = getc(fileinput);
    LatTopLeftImg2 = ifl;
    }
  
  fclose(fileinput);
}

/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/

void read_tiff3(char FileInput[FilePathLength])
{
  FILE *fileinput;

  unsigned char buffer[4];
  int i, k;
  long unsigned int offset, Value;
  long unsigned int offset_strip;
  long unsigned int offset_strip_byte;
  long unsigned int ModelPixelScaleOff;
  long unsigned int ModelTiePointOff;
  short int Ndir, Type;
  int Flag, Nstrip, Count;
//  int ModelPixelScaleN, ModelTiePointN;
  double FloatValue;

  char *pc;
  int il, *vl;
  short int is, *v;
  float ifl, *vfl;

  if ((fileinput = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  rewind(fileinput);
/*Tiff File Header*/
  /* Little / Big endian & TIFF identifier */
  fread(buffer, 1, 4, fileinput);
  if(buffer[0] == 0x49 && buffer[1] == 0x49 && buffer[2] == 0x2a && buffer[3] == 0x00) IEEE = 0;
  if(buffer[0] == 0x4d && buffer[1] == 0x4d && buffer[2] == 0x00 && buffer[3] == 0x2a) IEEE = 1;
  
  if (IEEE == 0) fread(&offset, sizeof(int), 1, fileinput);
  if (IEEE == 1) {
      vl = &il;pc = (char *) vl;
      pc[3] = getc(fileinput);pc[2] = getc(fileinput);
      pc[1] = getc(fileinput);pc[0] = getc(fileinput);
    offset = il;
    }

  rewind(fileinput);
  fseek(fileinput, offset, SEEK_SET);

  if (IEEE == 0) fread(&Ndir, sizeof(short int), 1, fileinput);
  if (IEEE == 1) {
    v = &is;pc = (char *) v;
    pc[1] = getc(fileinput);pc[0] = getc(fileinput);
    Ndir = is;
    }

  for (i=0; i<Ndir; i++) {
    Flag = 0; Type = 0; Count = 0; Value = 0;
    if (IEEE == 0) {
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
    if (IEEE == 1) {
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
    if (Flag == 256) NligDEM = Value;
    if (Flag == 257) NcolDEM = Value;

    if (Flag == 273) Nstrip = Count;
    if (Flag == 278) Rstrip3 = Value;

    if (Flag == 273) offset_strip = Value;
    if (Flag == 279) offset_strip_byte = Value;

    if (Flag == 33550) {
//      ModelPixelScaleN = Count;
      ModelPixelScaleOff = Value;
      }
    if (Flag == 33922) {
//      ModelTiePointN = Count;
      ModelTiePointOff = Value;
      }
    }

  Strip_Offset3 = vector_int(NligDEM);
  Strip_Bytes3 = vector_int(NligDEM);

  rewind(fileinput);
  fseek(fileinput, offset_strip, SEEK_SET);
  for (i=0; i<Nstrip; i++) {
    if (IEEE == 0) fread(&Value, sizeof(int), 1, fileinput);
    if (IEEE == 1) {
      vl = &il;pc = (char *) vl;
      pc[3] = getc(fileinput);pc[2] = getc(fileinput);
      pc[1] = getc(fileinput);pc[0] = getc(fileinput);
      Value = il;
    }
    Strip_Offset3[i] = Value;
  }

  rewind(fileinput);
  fseek(fileinput, offset_strip_byte, SEEK_SET);
  for (i=0; i<Nstrip; i++) {
    if (IEEE == 0) fread(&Value, sizeof(int), 1, fileinput);
    if (IEEE == 1) {
      vl = &il;pc = (char *) vl;
      pc[3] = getc(fileinput);pc[2] = getc(fileinput);
      pc[1] = getc(fileinput);pc[0] = getc(fileinput);
      Value = il;
    }
    Strip_Bytes3[i] = Value;
  }

  rewind(fileinput);
  fseek(fileinput, ModelPixelScaleOff, SEEK_SET);
  if (IEEE == 0) {
    fread(&DeltaX, sizeof(double), 1, fileinput);
    fread(&DeltaY, sizeof(double), 1, fileinput);
    }
  if (IEEE == 1) {
    vfl = &ifl;pc = (char *) vfl;
    pc[7] = getc(fileinput);pc[6] = getc(fileinput);
    pc[5] = getc(fileinput);pc[4] = getc(fileinput);
    pc[3] = getc(fileinput);pc[2] = getc(fileinput);
    pc[1] = getc(fileinput);pc[0] = getc(fileinput);
    DeltaX = ifl;
    vfl = &ifl;pc = (char *) vfl;
    pc[7] = getc(fileinput);pc[6] = getc(fileinput);
    pc[5] = getc(fileinput);pc[4] = getc(fileinput);
    pc[3] = getc(fileinput);pc[2] = getc(fileinput);
    pc[1] = getc(fileinput);pc[0] = getc(fileinput);
    DeltaY = ifl;
    }
      
  rewind(fileinput);
  fseek(fileinput, ModelTiePointOff, SEEK_SET);
  if (IEEE == 0) {
    fread(&FloatValue, sizeof(double), 1, fileinput);
    fread(&FloatValue, sizeof(double), 1, fileinput);
    fread(&FloatValue, sizeof(double), 1, fileinput);
    fread(&LonTopLeftImg3, sizeof(double), 1, fileinput);
    fread(&LatTopLeftImg3, sizeof(double), 1, fileinput);
    }
  if (IEEE == 1) {
    fread(&FloatValue, sizeof(double), 1, fileinput);
    fread(&FloatValue, sizeof(double), 1, fileinput);
    fread(&FloatValue, sizeof(double), 1, fileinput);
    vfl = &ifl;pc = (char *) vfl;
    pc[7] = getc(fileinput);pc[6] = getc(fileinput);
    pc[5] = getc(fileinput);pc[4] = getc(fileinput);
    pc[3] = getc(fileinput);pc[2] = getc(fileinput);
    pc[1] = getc(fileinput);pc[0] = getc(fileinput);
    LonTopLeftImg3 = ifl;
    vfl = &ifl;pc = (char *) vfl;
    pc[7] = getc(fileinput);pc[6] = getc(fileinput);
    pc[5] = getc(fileinput);pc[4] = getc(fileinput);
    pc[3] = getc(fileinput);pc[2] = getc(fileinput);
    pc[1] = getc(fileinput);pc[0] = getc(fileinput);
    LatTopLeftImg3 = ifl;
    }
  
  fclose(fileinput);
}
