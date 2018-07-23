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

File   : complex_plane_extract.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 06/2012
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
    laurent.ferro-famil@univ-rennes1.fr
*--------------------------------------------------------------------

Description :  Extraction of binary data from a data file using
               defined pixel coordinates

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* CONSTANTS  */
#define Nfiles  29

/* ALIASES  */
#define HH  0
#define HV  1
#define VV  2
#define HHpVV  3
#define HHmVV  4
#define HVpVH  5
#define RR  6
#define LR  7
#define LL  8
#define Opt1  9
#define Opt2  10
#define Opt3  11
#define NR1  12
#define NR2  13
#define NR3  14
#define PDH  15
#define PDL  16
#define MaxMag  17
#define MinMag  18
#define MaxPha  19
#define MinPha  20
#define MagHigh  21
#define MagLow  22
#define PhaHigh  23
#define PhaLow  24
#define Ch1 25
#define Ch2 26
#define Ch1pCh2 27
#define Ch1mCh2 28

/* ROUTINES */
#include "../lib/PolSARproLib.h"

void FilePointerPosition(int PixLig,int Ncol,int Length,int Nfich);
void ExtractData(int PixCol,int Ncol,int Length, int Nfich);

/* GLOBAL VARIABLES */
FILE *in_file[Nfiles];
char Representation[Nfiles];
int FlagOpen[Nfiles];
int FlagExtract[Nfiles];
float ***S;
long CurrentPointerPosition;

char file_name[FilePathLength], in_dir[FilePathLength];
char OutputTxt[FilePathLength], name[Nfiles];

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{
/* Input/Output file pointer arrays */
  FILE *out_file;

/* Strings */
  char *FileInput[Nfiles] =  {"cmplx_coh_HH.bin", "cmplx_coh_HV.bin", "cmplx_coh_VV.bin",
        "cmplx_coh_HHpVV.bin", "cmplx_coh_HHmVV.bin", "cmplx_coh_HVpVH.bin",
        "cmplx_coh_RR.bin", "cmplx_coh_LR.bin", "cmplx_coh_LL.bin",
        "cmplx_coh_Opt1.bin", "cmplx_coh_Opt2.bin", "cmplx_coh_Opt3.bin",
        "cmplx_coh_Opt_NR1.bin", "cmplx_coh_Opt_NR2.bin", "cmplx_coh_Opt_NR3.bin",
        "cmplx_coh_PDHigh.bin", "cmplx_coh_PDLow.bin", 
        "cmplx_coh_MaxMag.bin", "cmplx_coh_MinMag.bin",
        "cmplx_coh_MaxPha.bin", "cmplx_coh_MinPha.bin",
        "cmplx_coh_maxdiff_PhaLow.bin", "cmplx_coh_maxdiff_PhaHigh.bin",
        "cmplx_coh_maxdiff_MagLow.bin", "cmplx_coh_maxdiff_MagHigh.bin",
        "cmplx_coh_Ch1.bin", "cmplx_coh_Ch2.bin",
        "cmplx_coh_Ch1pCh2.bin", "cmplx_coh_Ch1mCh2.bin"};
  char *FileInputAvg[Nfiles] = {"cmplx_coh_avg_HH.bin", "cmplx_coh_avg_HV.bin", "cmplx_coh_avg_VV.bin",
        "cmplx_coh_avg_HHpVV.bin", "cmplx_coh_avg_HHmVV.bin", "cmplx_coh_avg_HVpVH.bin",
        "cmplx_coh_avg_RR.bin", "cmplx_coh_avg_LR.bin", "cmplx_coh_avg_LL.bin",
        "cmplx_coh_avg_Opt1.bin", "cmplx_coh_avg_Opt2.bin", "cmplx_coh_avg_Opt3.bin",
        "cmplx_coh_avg_Opt_NR1.bin", "cmplx_coh_avg_Opt_NR2.bin", "cmplx_coh_avg_Opt_NR3.bin",
        "cmplx_coh_avg_PDHigh.bin", "cmplx_coh_avg_PDLow.bin", 
        "cmplx_coh_avg_MaxMag.bin", "cmplx_coh_avg_MinMag.bin",
        "cmplx_coh_avg_MaxPha.bin", "cmplx_coh_avg_MinPha.bin",
        "cmplx_coh_avg_maxdiff_PhaLow.bin", "cmplx_coh_avg_maxdiff_PhaHigh.bin",
        "cmplx_coh_avg_maxdiff_MagLow.bin", "cmplx_coh_avg_maxdiff_MagHigh.bin",
        "cmplx_coh_avg_Ch1.bin", "cmplx_coh_avg_Ch2.bin",
        "cmplx_coh_avg_Ch1pCh2.bin", "cmplx_coh_avg_Ch1mCh2.bin"};
  char PolarCase[Nfiles], PolarType[Nfiles];
  char Operation[Nfiles];

/* Input variables */
  int FlagExit, FlagRead;
  int ii, k, l;
  int PixLig, PixCol;
  int AvgCoh, Length;
  int Nopen, Nextract;
  float xr,xi;

/********************************************************************
********************************************************************/

if (argc == 3) {
  strcpy(in_dir, argv[1]);
  strcpy(OutputTxt, argv[2]);
  } else
  edit_error("cmplx_plane_extract In_Dir File_Txt\n","");

/********************************************************************
********************************************************************/

check_dir(in_dir);
read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);

check_file(OutputTxt);

Length = 0;
S = matrix3d_float(Nfiles,Length+1,2*(Length+1));

/********************************************************************
********************************************************************/
FlagExit = 0;
while (FlagExit == 0) {
scanf("%s",Operation);
if (strcmp(Operation, "") != 0) {

if (strcmp(Operation, "exit") == 0) {
  FlagExit = 1;
  printf("OKexit\r");fflush(stdout);
  }

if (strcmp(Operation, "closefile") == 0) {
  printf("OKclosefile\r");fflush(stdout);
  for (ii = 0; ii < Nopen; ii++) fclose(in_file[FlagOpen[ii]]);
  printf("OKfinclosefile\r");fflush(stdout);
  }

if (strcmp(Operation, "openfile") == 0) {
  printf("OKopenfile\r");fflush(stdout);
  FlagRead = 0;
  while (FlagRead == 0) {
  scanf("%s",Operation);
  if (strcmp(Operation, "") != 0) {
    AvgCoh = atoi(Operation);
    FlagRead = 1;
    printf("OKreadavg\r");fflush(stdout);
    }
  }
  FlagRead = 0;
  while (FlagRead == 0) {
  scanf("%s",Operation);
  if (strcmp(Operation, "") != 0) {
    Nopen = atoi(Operation);
    FlagRead = 1;
    printf("OKreadNopen\r");fflush(stdout);
    }
  }
  for (ii = 0; ii < Nopen; ii++) {
  FlagRead = 0;
  while (FlagRead == 0) {
    scanf("%s",Operation);
    if (strcmp(Operation, "") != 0) {
    strcpy(name,Operation);
    FlagRead = 1;
    printf("OKreadfile\r");fflush(stdout);
    }
    }
  if (strcmp(name, "HH") == 0) FlagOpen[ii] = HH;
  if (strcmp(name, "HV") == 0) FlagOpen[ii] = HV;
  if (strcmp(name, "VV") == 0) FlagOpen[ii] = VV;
  if (strcmp(name, "HHpVV") == 0) FlagOpen[ii] = HHpVV;
  if (strcmp(name, "HHmVV") == 0) FlagOpen[ii] = HHmVV;
  if (strcmp(name, "HVpVH") == 0) FlagOpen[ii] = HVpVH;
  if (strcmp(name, "RR") == 0) FlagOpen[ii] = RR;
  if (strcmp(name, "LR") == 0) FlagOpen[ii] = LR;
  if (strcmp(name, "LL") == 0) FlagOpen[ii] = LL;
  if (strcmp(name, "Opt1") == 0) FlagOpen[ii] = Opt1;
  if (strcmp(name, "Opt2") == 0) FlagOpen[ii] = Opt2;
  if (strcmp(name, "Opt3") == 0) FlagOpen[ii] = Opt3;
  if (strcmp(name, "NR1") == 0) FlagOpen[ii] = NR1;
  if (strcmp(name, "NR2") == 0) FlagOpen[ii] = NR2;
  if (strcmp(name, "NR3") == 0) FlagOpen[ii] = NR3;
  if (strcmp(name, "PDH") == 0) FlagOpen[ii] = PDH;
  if (strcmp(name, "PDL") == 0) FlagOpen[ii] = PDL;
  if (strcmp(name, "MaxMag") == 0) FlagOpen[ii] = MaxMag;
  if (strcmp(name, "MinMag") == 0) FlagOpen[ii] = MinMag;
  if (strcmp(name, "MaxPha") == 0) FlagOpen[ii] = MaxPha;
  if (strcmp(name, "MinPha") == 0) FlagOpen[ii] = MinPha;
  if (strcmp(name, "MagHigh") == 0) FlagOpen[ii] = MagHigh;
  if (strcmp(name, "MagLow") == 0) FlagOpen[ii] = MagLow;
  if (strcmp(name, "PhaHigh") == 0) FlagOpen[ii] = PhaHigh;
  if (strcmp(name, "PhaLow") == 0) FlagOpen[ii] = PhaLow;
  if (strcmp(name, "Ch1") == 0) FlagOpen[ii] = Ch1;
  if (strcmp(name, "Ch2") == 0) FlagOpen[ii] = Ch2;
  if (strcmp(name, "Ch1pCh2") == 0) FlagOpen[ii] = Ch1pCh2;
  if (strcmp(name, "Ch1mCh2") == 0) FlagOpen[ii] = Ch1mCh2;

  sprintf(file_name, "%s%s",in_dir,FileInput[FlagOpen[ii]]);
  if (AvgCoh == 1) sprintf(file_name, "%s%s",in_dir,FileInputAvg[FlagOpen[ii]]);
  if ((in_file[FlagOpen[ii]] = fopen(file_name, "rb")) == NULL) edit_error("Could not open output file : ", file_name);
  }
  FilePointerPosition(Nlig/2,Ncol,0,Nopen);
  printf("OKfinopenfile\r");fflush(stdout);
  }

if (strcmp(Operation, "extract") == 0) {
  printf("OKextract\r");fflush(stdout);
  free_matrix3d_float(S,Nfiles,Length+1);
  FlagRead = 0;
  while (FlagRead == 0) {
  scanf("%s",Operation);
  if (strcmp(Operation, "") != 0) {
    PixCol = atoi(Operation);
    FlagRead = 1;
    printf("OKreadcol\r");fflush(stdout);
    }
  }
  FlagRead = 0;
  while (FlagRead == 0) {
  scanf("%s",Operation);
  if (strcmp(Operation, "") != 0) {
    PixLig = atoi(Operation);
    FlagRead = 1;
    printf("OKreadlig\r");fflush(stdout);
    }
  }
  FlagRead = 0;
  while (FlagRead == 0) {
  scanf("%s",Operation);
  if (strcmp(Operation, "") != 0) {
    strcpy(Representation,Operation);
    FlagRead = 1;
    printf("OKreadrepresentation\r");fflush(stdout);
    }
  }
  FlagRead = 0;
  while (FlagRead == 0) {
  scanf("%s",Operation);
  if (strcmp(Operation, "") != 0) {
    Length = atoi(Operation);
    FlagRead = 1;
    printf("OKreadlength\r");fflush(stdout);
    }
  }
  S = matrix3d_float(Nfiles,Length+1,2*(Length+1));
  FlagRead = 0;
  while (FlagRead == 0) {
  scanf("%s",Operation);
  if (strcmp(Operation, "") != 0) {
    Nextract = atoi(Operation);
    FlagRead = 1;
    printf("OKreadN\r");fflush(stdout);
    }
  }
  for (ii = 0; ii < Nextract; ii++) {
  FlagRead = 0;
  while (FlagRead == 0) {
    scanf("%s",Operation);
    if (strcmp(Operation, "") != 0) {
    strcpy(name,Operation);
    FlagRead = 1;
    printf("OKreadname\r");fflush(stdout);
    }
    }
  if (strcmp(name, "HH") == 0) FlagExtract[ii] = HH;
  if (strcmp(name, "HV") == 0) FlagExtract[ii] = HV;
  if (strcmp(name, "VV") == 0) FlagExtract[ii] = VV;
  if (strcmp(name, "HHpVV") == 0) FlagExtract[ii] = HHpVV;
  if (strcmp(name, "HHmVV") == 0) FlagExtract[ii] = HHmVV;
  if (strcmp(name, "HVpVH") == 0) FlagExtract[ii] = HVpVH;
  if (strcmp(name, "RR") == 0) FlagExtract[ii] = RR;
  if (strcmp(name, "LR") == 0) FlagExtract[ii] = LR;
  if (strcmp(name, "LL") == 0) FlagExtract[ii] = LL;
  if (strcmp(name, "Opt1") == 0) FlagExtract[ii] = Opt1;
  if (strcmp(name, "Opt2") == 0) FlagExtract[ii] = Opt2;
  if (strcmp(name, "Opt3") == 0) FlagExtract[ii] = Opt3;
  if (strcmp(name, "NR1") == 0) FlagExtract[ii] = NR1;
  if (strcmp(name, "NR2") == 0) FlagExtract[ii] = NR2;
  if (strcmp(name, "NR3") == 0) FlagExtract[ii] = NR3;
  if (strcmp(name, "PDH") == 0) FlagExtract[ii] = PDH;
  if (strcmp(name, "PDL") == 0) FlagExtract[ii] = PDL;
  if (strcmp(name, "MaxMag") == 0) FlagExtract[ii] = MaxMag;
  if (strcmp(name, "MinMag") == 0) FlagExtract[ii] = MinMag;
  if (strcmp(name, "MaxPha") == 0) FlagExtract[ii] = MaxPha;
  if (strcmp(name, "MinPha") == 0) FlagExtract[ii] = MinPha;
  if (strcmp(name, "MagHigh") == 0) FlagExtract[ii] = MagHigh;
  if (strcmp(name, "MagLow") == 0) FlagExtract[ii] = MagLow;
  if (strcmp(name, "PhaHigh") == 0) FlagExtract[ii] = PhaHigh;
  if (strcmp(name, "PhaLow") == 0) FlagExtract[ii] = PhaLow;
  if (strcmp(name, "Ch1") == 0) FlagExtract[ii] = Ch1;
  if (strcmp(name, "Ch2") == 0) FlagExtract[ii] = Ch2;
  if (strcmp(name, "Ch1pCh2") == 0) FlagExtract[ii] = Ch1pCh2;
  if (strcmp(name, "Ch1mCh2") == 0) FlagExtract[ii] = Ch1mCh2;
  }
  
  FilePointerPosition(PixLig,Ncol,Length,Nopen);
  ExtractData(PixCol,Ncol,Length,Nopen);

  /* Output file opening */
  if ((out_file = fopen(OutputTxt, "wb")) == NULL)
  edit_error("Could not open input file : ", OutputTxt);

  if (strcmp(Representation,"point") == 0) {
  for(ii=0; ii<Nextract; ii++) {
    fprintf(out_file,"0 ");
    fprintf(out_file,"0 ");
    }
  fprintf(out_file,"\n");
  for(ii=0; ii<Nextract; ii++) {
    xr = S[FlagExtract[ii]][0][0];
    xi = S[FlagExtract[ii]][0][1];
    fprintf(out_file,"%f ",atan2(xi,xr)*180./pi);
    fprintf(out_file,"%f ",sqrt(xr*xr+xi*xi));
    }
  fprintf(out_file,"\n");
  }
  if (strcmp(Representation,"area") == 0) {
  for(l=0; l<Length; l++) {
    for(k=0; k<Length; k++) {
    for(ii=0; ii<Nextract; ii++) {
      xr = S[FlagExtract[ii]][l][2*k];
      xi = S[FlagExtract[ii]][l][2*k+1];
      fprintf(out_file,"%f ",atan2(xi,xr)*180./pi);
      fprintf(out_file,"%f ",sqrt(xr*xr+xi*xi));
      }
    fprintf(out_file,"\n");
    }
    }
  }

  fclose(out_file);
  printf("OKfinextract\r");fflush(stdout);
  } /*Operation Extract*/
  } /*Operation*/
  } /*while */

return 1;
}    /*Fin Main */


/********************************************************************
  Routine  : FilePointerPosition
  Authors  : Eric POTTIER
  Creation : 04/2005
  Update  :
*--------------------------------------------------------------------
  Description :  Update the Pointer position of the data files
*--------------------------------------------------------------------
  Inputs arguments :
  PixLig : Line position of the pixel [0 ... Nlig-1]
  PixCol : Row position of the pixel  [0 ... Ncol-1]
  Ncol  : Number of rows
  Length : RangeLength
  Nfich  : Number of Opened Files
  Returned values  :
  void
********************************************************************/
void FilePointerPosition(int PixLig,int Ncol,int Length,int Nfich)
{
long PointerPosition;
int np;

PointerPosition = 2 * ((PixLig - (int)(Length/2))* Ncol) * sizeof(float);
for (np=0; np < Nfich; np++) {
  CurrentPointerPosition = ftell(in_file[FlagOpen[np]]);
  fseek(in_file[FlagOpen[np]], (PointerPosition - CurrentPointerPosition), SEEK_CUR);
  }
}
/********************************************************************
  Routine  : ExtractData
  Authors  : Eric POTTIER
  Creation : 04/2005
  Update  :
*--------------------------------------------------------------------
  Description :  Extract Calibrator data
*--------------------------------------------------------------------
  Inputs arguments :
  PixLig : Line position of the pixel [0 ... Nlig-1]
  PixCol : Row position of the pixel  [0 ... Ncol-1]
  Ncol  : Number of rows
  Length : RangeLength
  Returned values  :
  void
********************************************************************/
void ExtractData(int PixCol,int Ncol,int Length, int Nfich)
{
int np,k,l;
float *Tmp;

Tmp = vector_float(2*Ncol);

if (strcmp(Representation,"point") == 0)
  {
  for(np=0; np<Nfich; np++)
  {
  fread(&Tmp[0], sizeof(float), 2*Ncol, in_file[FlagOpen[np]]);
  S[FlagOpen[np]][0][0] = Tmp[2*PixCol];
  S[FlagOpen[np]][0][1] = Tmp[2*PixCol+1];
  }
  }
if (strcmp(Representation,"area") == 0)
  {
  for(l=0; l<Length; l++)
  {
  for(np=0; np<Nfich; np++)
   {
   fread(&Tmp[0], sizeof(float), 2*Ncol, in_file[FlagOpen[np]]);
   for(k=0; k<2*Length; k++) S[FlagOpen[np]][l][k] = Tmp[2*(PixCol-(int)(Length/2))+k];
   }
  }
  }
free_vector_float(Tmp);
}

