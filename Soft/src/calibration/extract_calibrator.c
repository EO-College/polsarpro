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

File   : extract_calibrator.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 12/2011
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

Description :  Extract Calibrator Range (X,Y) profiles

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

/* CONSTANTS  */
#define Npolar  4

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"
void FilePointerPosition(int PixLig,int Ncol,int Length);
void ExtractData(int PixCol,int Ncol,int Length);
void WriteCalibrator(char *CalibratorTxt, char *CalibratorBin, int Length, char *format);
void WriteCalibratorVal(char *CalibratorValTxt, char *CalibratorValBin, int Length);
void WriteCalibrator3D(char *Calibrator3Ds11Txt, char *Calibrator3Ds11Bin, char *Calibrator3Ds12Txt, char *Calibrator3Ds12Bin,
     char *Calibrator3Ds21Txt, char *Calibrator3Ds21Bin, char *Calibrator3Ds22Txt, char *Calibrator3Ds22Bin, int Length,char *format);

/* GLOBAL VARIABLES */
/* Input/Output file pointer arrays */
FILE *in_file[16];
/* Matrix arrays */
float ***S;

char file_name[FilePathLength], in_dir[FilePathLength];
char CalibratorTxt[FilePathLength], CalibratorBin[FilePathLength];
char CalibratorValTxt[FilePathLength], CalibratorValBin[FilePathLength];
char Calibrator3Ds11Txt[FilePathLength], Calibrator3Ds11Bin[FilePathLength];
char Calibrator3Ds12Txt[FilePathLength], Calibrator3Ds12Bin[FilePathLength];
char Calibrator3Ds21Txt[FilePathLength], Calibrator3Ds21Bin[FilePathLength];
char Calibrator3Ds22Txt[FilePathLength], Calibrator3Ds22Bin[FilePathLength];

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

/* Strings */
  char *file_name_in[4] =  { "s11.bin", "s12.bin", "s21.bin", "s22.bin" };
  char PolarCase[20], PolarType[20];
  char Operation[FilePathLength],Format[20];

/* Internal variables */
  int Nlig, Ncol;  /* Initial image nb of lines and rows */
  int np;
  int FlagExit, FlagRead;
  int Length, PixLig, PixCol;

/* PROGRAM START */

  if (argc < 14) {
  edit_error("extract_calibrator in_dir CalibratorTxt CalibratorBin CalibratorValTxt CalibratorValBin Calibrator3Ds11Txt Calibrator3Ds11Bin Calibrator3Ds12Txt Calibrator3Ds12Bin Calibrator3Ds21Txt Calibrator3Ds21Bin Calibrator3Ds22Txt Calibrator3Ds22Bin \n","");
  } else {
  strcpy(in_dir, argv[1]);
  strcpy(CalibratorTxt, argv[2]);
  strcpy(CalibratorBin, argv[3]);
  strcpy(CalibratorValTxt, argv[4]);
  strcpy(CalibratorValBin, argv[5]);
  strcpy(Calibrator3Ds11Txt, argv[6]);
  strcpy(Calibrator3Ds11Bin, argv[7]);
  strcpy(Calibrator3Ds12Txt, argv[8]);
  strcpy(Calibrator3Ds12Bin, argv[9]);
  strcpy(Calibrator3Ds21Txt, argv[10]);
  strcpy(Calibrator3Ds21Bin, argv[11]);
  strcpy(Calibrator3Ds22Txt, argv[12]);
  strcpy(Calibrator3Ds22Bin, argv[13]);
  }
  
  check_dir(in_dir);
  check_file(CalibratorTxt);
  check_file(CalibratorBin);
  check_file(CalibratorValTxt);
  check_file(CalibratorValBin);
  check_file(Calibrator3Ds11Txt);
  check_file(Calibrator3Ds11Bin);
  check_file(Calibrator3Ds12Txt);
  check_file(Calibrator3Ds12Bin);
  check_file(Calibrator3Ds21Txt);
  check_file(Calibrator3Ds21Bin);
  check_file(Calibrator3Ds22Txt);
  check_file(Calibrator3Ds22Bin);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);

/* INPUT/OUTPUT FILE OPENING*/
  for (np = 0; np < Npolar; np++) {
  sprintf(file_name, "%s%s", in_dir, file_name_in[np]);
  if ((in_file[np] = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  }

  FilePointerPosition(Nlig/2,Ncol,0);

  FlagExit = 0;
  while (FlagExit == 0) {
      scanf("%s",Operation);
      if (strcmp(Operation, "") != 0) {
      if (strcmp(Operation, "exit") == 0) {
        FlagExit = 1;
        printf("OKexit\r");fflush(stdout);
        }
      if (strcmp(Operation, "plot") == 0) {
        printf("OKplot\r");fflush(stdout);
        FlagRead = 0;
        while (FlagRead == 0) {
         scanf("%s",Operation);
         if (strcmp(Operation, "") != 0) {
          Length = atoi(Operation);
          FlagRead = 1;
          printf("OKrangelength\r");fflush(stdout);
          }
         }
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
          strcpy(Format,Operation);
          FlagRead = 1;
          printf("OKformat\r");fflush(stdout);
          }
         }
        S = matrix3d_float(Npolar,Length,2*Length);
        FilePointerPosition(PixLig,Ncol,Length);
        ExtractData(PixCol,Ncol,Length);
        WriteCalibrator(CalibratorTxt,CalibratorBin,Length,Format);
        WriteCalibratorVal(CalibratorValTxt,CalibratorValBin,Length);
        WriteCalibrator3D(Calibrator3Ds11Txt,Calibrator3Ds11Bin,Calibrator3Ds12Txt,Calibrator3Ds12Bin,Calibrator3Ds21Txt,Calibrator3Ds21Bin,Calibrator3Ds22Txt,Calibrator3Ds22Bin,Length,Format);
        free_matrix3d_float(S,Npolar,Length);
        printf("OKplotOK\r");fflush(stdout);
        }
      }
    } /*while */

return 1;
}
/*******************************************************************
  Routine  : FilePointerPosition
  Authors  : Eric POTTIER, Laurent FERRO-FAMIL
  Creation : 04/2005
  Update  :
*-------------------------------------------------------------------
  Description :  Update the Pointer position of the data files
*-------------------------------------------------------------------
  Inputs arguments :
    PixLig : Line position of the pixel [0 ... Nlig-1]
    PixCol : Row position of the pixel  [0 ... Ncol-1]
    Ncol  : Number of rows
    Length : RangeLength
  Returned values  :
    void
*******************************************************************/
void FilePointerPosition(int PixLig,int Ncol,int Length)
{
long PointerPosition;
int np;

PointerPosition = 2 * ((PixLig - (int)(Length/2))* Ncol) * sizeof(float);
for (np=0; np < Npolar; np++) my_fseek_position(in_file[np], PointerPosition);

}
/*******************************************************************
  Routine  : ExtractData
  Authors  : Eric POTTIER, Laurent FERRO-FAMIL
  Creation : 04/2005
  Update  :
*-------------------------------------------------------------------
  Description :  Extract Calibrator data
*-------------------------------------------------------------------
  Inputs arguments :
    PixLig : Line position of the pixel [0 ... Nlig-1]
    PixCol : Row position of the pixel  [0 ... Ncol-1]
    Ncol  : Number of rows
    Length : RangeLength
  Returned values  :
    void
*******************************************************************/
void ExtractData(int PixCol,int Ncol,int Length)
{
int np,k,l;
float *Tmp;

Tmp = vector_float(2*Ncol);
for(l=0; l<Length; l++) {
  for(np=0; np<Npolar; np++) {
    fread(&Tmp[0], sizeof(float), 2*Ncol, in_file[np]);
    for(k=0; k<2*Length; k++) S[np][l][k] = Tmp[2*(PixCol-(int)(Length/2))+k];
    }
  }
free_vector_float(Tmp);
}
/*******************************************************************
  Routine  : WriteCalibrator
  Authors  : Eric POTTIER, Laurent FERRO-FAMIL
  Creation : 04/2005
  Update  :
*-------------------------------------------------------------------
  Description :  Write the selected area in binary files
*-------------------------------------------------------------------
  Inputs arguments :
  Returned values  :
    void
*******************************************************************/
void WriteCalibrator(char *CalibratorTxt, char *CalibratorBin, int Length, char *format)
{
 FILE *ftmp;
 int np,k;
 float minmodx,maxmodx,minmody,maxmody;

 float **TmpX,**TmpY;
 float **ModArgX,**ModArgY;

 TmpX = matrix_float(Npolar,2*Length);
 TmpY = matrix_float(Npolar,2*Length);
 ModArgX = matrix_float(2*Npolar,Length);
 ModArgY = matrix_float(2*Npolar,Length);

 for(np=0;np<Npolar;np++) {
  for(k=0;k<2*Length;k++) TmpX[np][k] = S[np][(int)(Length/2)][k];
  for(k=0;k<Length;k++) {
    TmpY[np][2*k] = S[np][k][2*(int)(Length/2)];
    TmpY[np][2*k+1] = S[np][k][2*(int)(Length/2)+1];
    }
  }

 for(np=0;np<Npolar;np++) {
  for(k=0;k<Length;k++) {
    ModArgX[np][k] = TmpX[np][2*k]*TmpX[np][2*k]+TmpX[np][2*k+1]*TmpX[np][2*k+1];
    ModArgY[np][k] = TmpY[np][2*k]*TmpY[np][2*k]+TmpY[np][2*k+1]*TmpY[np][2*k+1];
    }
  }
 for(np=0;np<Npolar;np++) {
  for(k=0;k<Length;k++) {
    ModArgX[Npolar+np][k] = atan2(TmpX[np][2*k+1],TmpX[np][2*k]) - atan2(TmpX[0][2*k+1],TmpX[0][2*k]);
    ModArgX[Npolar+np][k] = 180.*atan2(sin(ModArgX[Npolar+np][k]),cos(ModArgX[Npolar+np][k]))/pi;
    ModArgY[Npolar+np][k] = atan2(TmpY[np][2*k+1],TmpY[np][2*k]) - atan2(TmpY[0][2*k+1],TmpY[0][2*k]);
    ModArgY[Npolar+np][k] = 180.*atan2(sin(ModArgY[Npolar+np][k]),cos(ModArgY[Npolar+np][k]))/pi;
    }
  }

minmodx = INIT_MINMAX; maxmodx = -minmodx;
minmody = INIT_MINMAX; maxmody = -minmody;
for(k=0;k<Length;k++)
  for(np=0;np<Npolar;np++) {
    if(maxmodx < ModArgX[np][k]) maxmodx = ModArgX[np][k];
    if(minmodx > ModArgX[np][k]) minmodx = ModArgX[np][k];
    if(maxmody < ModArgY[np][k]) maxmody = ModArgY[np][k];
    if(minmody > ModArgY[np][k]) minmody = ModArgY[np][k];
    }

if (strcmp(format,"dB")==0) {
  minmodx = 10.*log10(minmodx+eps); maxmodx = 10.*log10(maxmodx+eps);
  minmody = 10.*log10(minmody+eps); maxmody = 10.*log10(maxmody+eps);
  for(k=0;k<Length;k++)
  for(np=0;np<Npolar;np++) {
    ModArgX[np][k] = 10.*log10(ModArgX[np][k]+eps);
    ModArgY[np][k] = 10.*log10(ModArgY[np][k]+eps);
    }
  }

if ((ftmp = fopen(CalibratorTxt, "w")) == NULL)
  edit_error("Could not open input file : ", CalibratorTxt);
fprintf(ftmp, "%i\n", Length);
fprintf(ftmp, "%i\n", (int)minmodx);fprintf(ftmp, "%i\n", (int)maxmodx);
fprintf(ftmp, "-180\n");fprintf(ftmp, "180\n");
fprintf(ftmp, "%i\n", (int)minmody);fprintf(ftmp, "%i\n", (int)maxmody);
fprintf(ftmp, "-180\n");fprintf(ftmp, "180\n");
fclose(ftmp);
if ((ftmp = fopen(CalibratorBin, "wb")) == NULL)
  edit_error("Could not open input file : ", CalibratorBin);

for (k=0; k<Length; k++)
  fprintf(ftmp, "%i %f %f %f %f %f %f %f %f %f %f %f %f %f %f\n",k,
  ModArgX[0][k],ModArgX[1][k],ModArgX[2][k],ModArgX[3][k],
  ModArgX[5][k],ModArgX[6][k],ModArgX[7][k],
  ModArgY[0][k],ModArgY[1][k],ModArgY[2][k],ModArgY[3][k],
  ModArgY[5][k],ModArgY[6][k],ModArgY[7][k]);
fclose(ftmp);

free_matrix_float(TmpX,Npolar);
free_matrix_float(TmpY,Npolar);
free_matrix_float(ModArgX,2*Npolar);
free_matrix_float(ModArgY,2*Npolar);
}
/*******************************************************************
  Routine  : WriteCalibratorVal
  Authors  : Eric POTTIER, Laurent FERRO-FAMIL
  Creation : 04/2005
  Update  :
*-------------------------------------------------------------------
  Description :  Write the selected area in binary files
*-------------------------------------------------------------------
  Inputs arguments :
  Returned values  :
    void
*******************************************************************/
void WriteCalibratorVal(char *CalibratorValTxt, char *CalibratorValBin, int Length)
{
 FILE *ftmp;
 int np,k;
 float *Tmp;

 Tmp = vector_float(2*Length);

 if ((ftmp = fopen(CalibratorValBin, "wb")) == NULL)
   edit_error("Could not open input file : ", CalibratorValBin);
 fwrite(&Length,sizeof(int),1,ftmp);
 for(np=0;np<Npolar;np++) {
   for(k=0;k<2*Length;k++) Tmp[k] = S[np][(int)(Length/2)][k];
   fwrite(&Tmp[0],sizeof(float),2*Length,ftmp);
   for(k=0;k<Length;k++) {
     Tmp[2*k] = S[np][k][2*(int)(Length/2)];
     Tmp[2*k+1] = S[np][k][2*(int)(Length/2)+1];
     }
   fwrite(&Tmp[0],sizeof(float),2*Length,ftmp);
   }
 fclose(ftmp);
 free_vector_float(Tmp);
}
/*******************************************************************
  Routine  : WriteCalibrator3D
  Authors  : Eric POTTIER, Laurent FERRO-FAMIL
  Creation : 04/2005
  Update  :
*-------------------------------------------------------------------
  Description :  Write the selected 3D areas in binary files
*-------------------------------------------------------------------
  Inputs arguments :
  Returned values  :
    void
*******************************************************************/
void WriteCalibrator3D(char *Calibrator3Ds11Txt, char *Calibrator3Ds11Bin,
     char *Calibrator3Ds12Txt, char *Calibrator3Ds12Bin,
     char *Calibrator3Ds21Txt, char *Calibrator3Ds21Bin,
     char *Calibrator3Ds22Txt, char *Calibrator3Ds22Bin,
     int Length,char *format)
{
 FILE *ftmp;
 int i,j,np;
 int xmin, xmax,ymin,ymax,zmin,zmax;
 int Nctr = 10;
 float k,min, max;
 float NctrStart, NctrIncr;
 float *XX,*YY;
 float **P;
 
 XX = vector_float(Length);
 YY = vector_float(Length);
 P = matrix_float(Length,Length);

xmin = 0; xmax = Length;
ymin = 0; ymax = Length;

if (strcmp(format,"dB")==0) { zmin = -40; zmax = 0; }
if (strcmp(format,"lin")==0) { zmin = 0; zmax = 1; }
NctrStart = (float)zmin;
NctrIncr = (float)(zmax-zmin)/((float)Nctr-1);

for(i=0;i<Length;i++) XX[i]=i;
for(i=0;i<Length;i++) YY[i]=i;

np=0;
for(i=0;i<Length;i++)
  for(j=0;j<Length;j++)
    P[i][j] = S[np][i][2*j]*S[np][i][2*j]+S[np][i][2*j+1]*S[np][i][2*j+1];

min = INIT_MINMAX; max = -min;
for(i=0;i<Length;i++)
  for(j=0;j<Length;j++) {
    if(max < P[i][j]) max = P[i][j];
    if(min > P[i][j]) min = P[i][j];
    }
  
for(i=0;i<Length;i++)
  for(j=0;j<Length;j++)
    P[i][j] = P[i][j] / max;

if (strcmp(format,"dB")==0) {
  min = 10.*log10(min); max = 10.*log10(max);
  for(i=0;i<Length;i++)
    for(j=0;j<Length;j++) {
      P[i][j] = 10.*log10(P[i][j]);
      if (P[i][j]<(float)zmin) P[i][j] = (float)zmin + eps;
      }
  }

 if ((ftmp = fopen(Calibrator3Ds11Txt, "w")) == NULL)
   edit_error("Could not open input file : ", Calibrator3Ds11Txt);
 fprintf(ftmp, "%i\n", Length);
 fprintf(ftmp, "%i\n", (int)xmin);fprintf(ftmp, "%i\n", (int)xmax);
 fprintf(ftmp, "%i\n", Length);
 fprintf(ftmp, "%i\n", (int)ymin);fprintf(ftmp, "%i\n", (int)ymax);
 fprintf(ftmp, "%i\n", zmin);fprintf(ftmp, "%i\n", zmax);
 fprintf(ftmp, "%f\n", min);fprintf(ftmp, "%f\n", max);
 fprintf(ftmp, "%i\n", Nctr);
 fprintf(ftmp, "%f\n", NctrStart);fprintf(ftmp, "%f\n", NctrIncr);
 fclose(ftmp);

 if ((ftmp = fopen(Calibrator3Ds11Bin, "wb")) == NULL)
   edit_error("Could not open input file : ", Calibrator3Ds11Bin);
 k = (float)Length;
 fwrite(&k,sizeof(float),1,ftmp);
 fwrite(&XX[0],sizeof(float),Length,ftmp);
 for (i=0 ; i<Length; i++) {
   fwrite(&YY[i],sizeof(float),1,ftmp);
   fwrite(&P[i][0],sizeof(float),Length,ftmp); /* z is ny rows by nx columns */
   }
 fclose(ftmp);


np=1;
for(i=0;i<Length;i++)
  for(j=0;j<Length;j++)
    P[i][j] = S[np][i][2*j]*S[np][i][2*j]+S[np][i][2*j+1]*S[np][i][2*j+1];

min = INIT_MINMAX; max = -min;
for(i=0;i<Length;i++)
  for(j=0;j<Length;j++) {
    if(max < P[i][j]) max = P[i][j];
    if(min > P[i][j]) min = P[i][j];
    }
  
for(i=0;i<Length;i++)
  for(j=0;j<Length;j++)
    P[i][j] = P[i][j] / max;

if (strcmp(format,"dB")==0) {
  min = 10.*log10(min); max = 10.*log10(max);
  for(i=0;i<Length;i++)
    for(j=0;j<Length;j++) {
      P[i][j] = 10.*log10(P[i][j]);
      if(P[i][j]<(float)zmin) P[i][j] = (float)zmin + eps;
      }
  }

 if ((ftmp = fopen(Calibrator3Ds12Txt, "w")) == NULL)
   edit_error("Could not open input file : ", Calibrator3Ds12Txt);
 fprintf(ftmp, "%i\n", Length);
 fprintf(ftmp, "%i\n", (int)xmin);fprintf(ftmp, "%i\n", (int)xmax);
 fprintf(ftmp, "%i\n", Length);
 fprintf(ftmp, "%i\n", (int)ymin);fprintf(ftmp, "%i\n", (int)ymax);
 fprintf(ftmp, "%i\n", zmin);fprintf(ftmp, "%i\n", zmax);
 fprintf(ftmp, "%f\n", min);fprintf(ftmp, "%f\n", max);
 fprintf(ftmp, "%i\n", Nctr);
 fprintf(ftmp, "%f\n", NctrStart);fprintf(ftmp, "%f\n", NctrIncr);
 fclose(ftmp);

 if ((ftmp = fopen(Calibrator3Ds12Bin, "wb")) == NULL)
   edit_error("Could not open input file : ", Calibrator3Ds12Bin);
 k = (float)Length;
 fwrite(&k,sizeof(float),1,ftmp);
 fwrite(&XX[0],sizeof(float),Length,ftmp);
 for (i=0 ; i<Length; i++) {
   fwrite(&YY[i],sizeof(float),1,ftmp);
   fwrite(&P[i][0],sizeof(float),Length,ftmp); /* z is ny rows by nx columns */
   }
 fclose(ftmp);

np=2;
for(i=0;i<Length;i++)
  for(j=0;j<Length;j++)
    P[i][j] = S[np][i][2*j]*S[np][i][2*j]+S[np][i][2*j+1]*S[np][i][2*j+1];

min = INIT_MINMAX; max = -min;
for(i=0;i<Length;i++)
  for(j=0;j<Length;j++) {
    if(max < P[i][j]) max = P[i][j];
    if(min > P[i][j]) min = P[i][j];
    }
  
for(i=0;i<Length;i++)
  for(j=0;j<Length;j++)
    P[i][j] = P[i][j] / max;

if (strcmp(format,"dB")==0) {
  min = 10.*log10(min); max = 10.*log10(max);
  for(i=0;i<Length;i++)
    for(j=0;j<Length;j++) {
      P[i][j] = 10.*log10(P[i][j]);
      if(P[i][j]<(float)zmin) P[i][j] = (float)zmin + eps;
      }
  }

 if ((ftmp = fopen(Calibrator3Ds21Txt, "w")) == NULL)
   edit_error("Could not open input file : ", Calibrator3Ds21Txt);
 fprintf(ftmp, "%i\n", Length);
 fprintf(ftmp, "%i\n", (int)xmin);fprintf(ftmp, "%i\n", (int)xmax);
 fprintf(ftmp, "%i\n", Length);
 fprintf(ftmp, "%i\n", (int)ymin);fprintf(ftmp, "%i\n", (int)ymax);
 fprintf(ftmp, "%i\n", zmin);fprintf(ftmp, "%i\n", zmax);
 fprintf(ftmp, "%f\n", min);fprintf(ftmp, "%f\n", max);
 fprintf(ftmp, "%i\n", Nctr);
 fprintf(ftmp, "%f\n", NctrStart);fprintf(ftmp, "%f\n", NctrIncr);
 fclose(ftmp);

 if ((ftmp = fopen(Calibrator3Ds21Bin, "wb")) == NULL)
   edit_error("Could not open input file : ", Calibrator3Ds21Bin);
 k = (float)Length;
 fwrite(&k,sizeof(float),1,ftmp);
 fwrite(&XX[0],sizeof(float),Length,ftmp);
 for (i=0 ; i<Length; i++) {
   fwrite(&YY[i],sizeof(float),1,ftmp);
   fwrite(&P[i][0],sizeof(float),Length,ftmp); /* z is ny rows by nx columns */
   }
 fclose(ftmp);

np=3;
for(i=0;i<Length;i++)
  for(j=0;j<Length;j++)
    P[i][j] = S[np][i][2*j]*S[np][i][2*j]+S[np][i][2*j+1]*S[np][i][2*j+1];

min = INIT_MINMAX; max = -min;
for(i=0;i<Length;i++)
  for(j=0;j<Length;j++) {
    if(max < P[i][j]) max = P[i][j];
    if(min > P[i][j]) min = P[i][j];
    }
  
for(i=0;i<Length;i++)
  for(j=0;j<Length;j++)
    P[i][j] = P[i][j] / max;

if (strcmp(format,"dB")==0) {
  min = 10.*log10(min); max = 10.*log10(max);
  for(i=0;i<Length;i++)
    for(j=0;j<Length;j++) {
      P[i][j] = 10.*log10(P[i][j]);
      if(P[i][j]<(float)zmin) P[i][j] = (float)zmin + eps;
      }
  }

 if ((ftmp = fopen(Calibrator3Ds22Txt, "w")) == NULL)
   edit_error("Could not open input file : ", Calibrator3Ds22Txt);
 fprintf(ftmp, "%i\n", Length);
 fprintf(ftmp, "%i\n", (int)xmin);fprintf(ftmp, "%i\n", (int)xmax);
 fprintf(ftmp, "%i\n", Length);
 fprintf(ftmp, "%i\n", (int)ymin);fprintf(ftmp, "%i\n", (int)ymax);
 fprintf(ftmp, "%i\n", zmin);fprintf(ftmp, "%i\n", zmax);
 fprintf(ftmp, "%f\n", min);fprintf(ftmp, "%f\n", max);
 fprintf(ftmp, "%i\n", Nctr);
 fprintf(ftmp, "%f\n", NctrStart);fprintf(ftmp, "%f\n", NctrIncr);
 fclose(ftmp);

 if ((ftmp = fopen(Calibrator3Ds22Bin, "wb")) == NULL)
   edit_error("Could not open input file : ", Calibrator3Ds22Bin);
 k = (float)Length;
 fwrite(&k,sizeof(float),1,ftmp);
 fwrite(&XX[0],sizeof(float),Length,ftmp);
 for (i=0 ; i<Length; i++) {
   fwrite(&YY[i],sizeof(float),1,ftmp);
   fwrite(&P[i][0],sizeof(float),Length,ftmp); /* z is ny rows by nx columns */
   }
 fclose(ftmp);

 free_vector_float(XX);
 free_vector_float(YY);
 free_matrix_float(P,Length);
}


