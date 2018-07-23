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

File   : data_profile_extract.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 12/2006
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

Description :  Extract Raw Binary Data Range (X,Y) profiles

********************************************************************/
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
void FilePointerPosition(int PixLig,int Ncol,int Length);
void ExtractData(int PixCol,int Ncol,int Length);
void WriteDataVal(int Length);
void CreateDataBin(int Length);
void WriteDataBin(int Length, int MinMaxAuto, int MinI, int MaxI, float MinF, float MaxF);

/* GLOBAL VARIABLES */
FILE *in_file;
char inputformat[10];
char outputformat[10];
char ProfileTxt[FilePathLength], Profile3DBin[FilePathLength];
char Profile1DXBin[FilePathLength], Profile1DYBin[FilePathLength];
char ProfileXTxt[FilePathLength], ProfileXBin[FilePathLength];
char ProfileYTxt[FilePathLength], ProfileYBin[FilePathLength];
char ProfileXYTxt[FilePathLength], ProfileXYBin[FilePathLength];
char file_name[FilePathLength], in_dir[FilePathLength];

/* Matrix arrays */
float **M1;
int **M2;
float *TmpX, *TmpY;
int *TmpIX, *TmpIY;

long CurrentPointerPosition;

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
  char PolarCase[20], PolarType[20];
  char Operation[20];

/* Internal variables */
  int FlagExit, FlagRead;
  int Length, PixLig, PixCol;
  int MinMaxAuto, MinI, MaxI;
  int MinF, MaxF;

/* PROGRAM START */

  if (argc == 11) {
    strcpy(ProfileTxt, argv[1]);
    strcpy(ProfileXTxt, argv[2]);
    strcpy(ProfileXBin, argv[3]);
    strcpy(ProfileYTxt, argv[4]);
    strcpy(ProfileYBin, argv[5]);
    strcpy(ProfileXYTxt, argv[6]);
    strcpy(ProfileXYBin, argv[7]);
    strcpy(Profile1DXBin, argv[8]);
    strcpy(Profile1DYBin, argv[9]);
    strcpy(Profile3DBin, argv[10]);
    } else
    edit_error("data_profile_extract File_Txt FileX_Txt FileX_Bin FileY_Txt FileY_Bin FileXY_Txt FileXY_Bin File1DX_Bin File1DY_Bin File3D_Bin\n","");

check_file(ProfileTxt);
check_file(ProfileXTxt);
check_file(ProfileXBin);
check_file(ProfileYTxt);
check_file(ProfileYBin);
check_file(ProfileXYTxt);
check_file(ProfileXYBin);
check_file(Profile1DXBin);
check_file(Profile1DYBin);
check_file(Profile3DBin);

Length = 0;
MinMaxAuto = 0;
MinI = 0; MaxI = 0;
MinF = 0.0; MaxF = 0.0;

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
      FlagRead = 0;
      while (FlagRead == 0) {
        scanf("%s",Operation);
        if (strcmp(Operation, "") != 0) {
          strcpy(inputformat,Operation);
          FlagRead = 1;
          printf("OKreadformat\r");fflush(stdout);
          }
        }
      fclose(in_file);
      printf("OKfinclosefile\r");fflush(stdout);
      }

    if (strcmp(Operation, "openfile") == 0) {
      printf("OKopenfile\r");fflush(stdout);
      FlagRead = 0;
      while (FlagRead == 0) {
        scanf("%s",Operation);
        if (strcmp(Operation, "") != 0) {
          strcpy(in_dir,Operation);
          FlagRead = 1;
          printf("OKreaddir\r");fflush(stdout);
          }
        }
      FlagRead = 0;
      while (FlagRead == 0) {
        scanf("%s",Operation);
        if (strcmp(Operation, "") != 0) {
          strcpy(file_name,Operation);
          FlagRead = 1;
          printf("OKreadfile\r");fflush(stdout);
          }
        }
      FlagRead = 0;
      while (FlagRead == 0) {
        scanf("%s",Operation);
        if (strcmp(Operation, "") != 0) {
          strcpy(inputformat,Operation);
          FlagRead = 1;
          printf("OKreadformat\r");fflush(stdout);
          }
        }
      check_dir(in_dir);
      read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);
      check_file(file_name);
      if ((in_file = fopen(file_name, "rb")) == NULL) edit_error("Could not open input file : ", file_name);
      FilePointerPosition(Nlig/2,Ncol,0);
      printf("OKfinopenfile\r");fflush(stdout);
      }

    if (strcmp(Operation, "extractval") == 0) {
      printf("OKextractval\r");fflush(stdout);
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

      Length = 1;
      if (strcmp(inputformat, "cmplx") == 0) M1 = matrix_float(Length, 2 * Length);
      if (strcmp(inputformat, "float") == 0) M1 = matrix_float(Length, Length);
      if (strcmp(inputformat, "int") == 0) M2 = matrix_int(Length, Length);
      FilePointerPosition(PixLig,Ncol,Length);
      ExtractData(PixCol,Ncol,Length);
      WriteDataVal(Length);
      if (strcmp(inputformat, "cmplx") == 0) free_matrix_float(M1,Length);
      if (strcmp(inputformat, "float") == 0) free_matrix_float(M1,Length);
      if (strcmp(inputformat, "int") == 0) free_matrix_int(M2,Length);

      printf("OKfinextractval\r");fflush(stdout);
      }
      
    if (strcmp(Operation, "extractbin") == 0) {
      printf("OKextractbin\r");fflush(stdout);
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
          strcpy(outputformat,Operation);
          FlagRead = 1;
          printf("OKreadformat\r");fflush(stdout);
          }
        }
      FlagRead = 0;
      while (FlagRead == 0) {
        scanf("%s",Operation);
        if (strcmp(Operation, "") != 0) {
          MinMaxAuto = atoi(Operation);
          FlagRead = 1;
          printf("OKminmaxauto\r");fflush(stdout);
          }
        }
      if (MinMaxAuto == 0) {
        FlagRead = 0;
        while (FlagRead == 0) {
          scanf("%s",Operation);
          if (strcmp(Operation, "") != 0) {
            if (strcmp(inputformat, "int") == 0) {
              MinI = atoi(Operation);
              } else {
              MinF = atof(Operation);
              }
            FlagRead = 1;
            printf("OKmin\r");fflush(stdout);
            }
          }
        FlagRead = 0;
        while (FlagRead == 0) {
          scanf("%s",Operation);
          if (strcmp(Operation, "") != 0) {
            if (strcmp(inputformat, "int") == 0) {
              MaxI = atoi(Operation);
              } else {
              MaxF = atof(Operation);
              }
            FlagRead = 1;
            printf("OKmax\r");fflush(stdout);
            }
          }
        }

      if (strcmp(inputformat, "cmplx") == 0) M1 = matrix_float(Length, 2 * Length);
      if (strcmp(inputformat, "float") == 0) M1 = matrix_float(Length, Length);
      if (strcmp(inputformat, "int") == 0) M2 = matrix_int(Length, Length);
      if (strcmp(inputformat, "int") == 0) M1 = matrix_float(Length, Length);
      if (strcmp(inputformat, "cmplx") == 0) { TmpX = vector_float(2*Length); TmpY = vector_float(2*Length); }
      if (strcmp(inputformat, "float") == 0) { TmpX = vector_float(Length); TmpY = vector_float(Length); }
      if (strcmp(inputformat, "int") == 0) { TmpIX = vector_int(Length); TmpIY = vector_int(Length); }
      FilePointerPosition(PixLig,Ncol,Length);
      ExtractData(PixCol,Ncol,Length);
      CreateDataBin(Length);
      WriteDataBin(Length, MinMaxAuto, MinI, MaxI, MinF, MaxF);
      if (strcmp(inputformat, "cmplx") == 0) free_matrix_float(M1,Length);
      if (strcmp(inputformat, "float") == 0) free_matrix_float(M1,Length);
      if (strcmp(inputformat, "int") == 0) free_matrix_int(M2,Length);
      if (strcmp(inputformat, "int") == 0) free_matrix_float(M1,Length);
      if (strcmp(inputformat, "int") == 0) { 
      free_vector_int(TmpIX);free_vector_int(TmpIY); 
      } else {
      free_vector_float(TmpX);free_vector_float(TmpY); 
      }
  
      printf("OKfinextractbin\r");fflush(stdout);
      }

    } /*Operation*/
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
CurrentPointerPosition = ftell(in_file);
if (strcmp(inputformat, "cmplx") == 0) PointerPosition = 2 * ((PixLig - (int)(Length/2))* Ncol) * sizeof(float);
if (strcmp(inputformat, "float") == 0) PointerPosition = ((PixLig - (int)(Length/2))* Ncol) * sizeof(float);
if (strcmp(inputformat, "int") == 0) PointerPosition = ((PixLig - (int)(Length/2))* Ncol) * sizeof(int);
fseek(in_file, (PointerPosition - CurrentPointerPosition), SEEK_CUR);
}
/*******************************************************************
  Routine  : ExtractData
  Authors  : Eric POTTIER, Laurent FERRO-FAMIL
  Creation : 12/2006
  Update  :
*-------------------------------------------------------------------
  Description :  Extract Raw Binary Data
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
int k,l;
float *Tmp;
int *TmpI;

if (strcmp(inputformat, "cmplx") == 0) {
  Tmp = vector_float(2*Ncol);
  for(l=0; l<Length; l++) {
    fread(&Tmp[0], sizeof(float), 2*Ncol, in_file);
    for(k=0; k<2*Length; k++) M1[l][k] = Tmp[2*(PixCol-(int)(Length/2))+k];
    }
  free_vector_float(Tmp);
  }
if (strcmp(inputformat, "float") == 0) {
  Tmp = vector_float(Ncol);
  for(l=0; l<Length; l++) {
    fread(&Tmp[0], sizeof(float), Ncol, in_file);
    for(k=0; k<Length; k++) M1[l][k] = Tmp[(PixCol-(int)(Length/2))+k];
    }
  free_vector_float(Tmp);
  }
if (strcmp(inputformat, "int") == 0) {
  TmpI = vector_int(Ncol);
  for(l=0; l<Length; l++) {
    fread(&TmpI[0], sizeof(int), Ncol, in_file);
    for(k=0; k<Length; k++) M2[l][k] = TmpI[(PixCol-(int)(Length/2))+k];
    }
  free_vector_int(TmpI);
  }

}
/*******************************************************************
  Routine  : WriteDataVal
  Authors  : Eric POTTIER, Laurent FERRO-FAMIL
  Creation : 12/2006
  Update  :
*-------------------------------------------------------------------
  Description :  Write the Value of the Selected Point
*-------------------------------------------------------------------
  Inputs arguments :
  Returned values  :
    void
*******************************************************************/
void WriteDataVal(int Length)
{
 FILE *ftmp;

 if ((ftmp = fopen(ProfileTxt, "w")) == NULL)
   edit_error("Could not open input file : ", ProfileTxt);
 if (strcmp(inputformat, "cmplx") == 0) {
   fprintf(ftmp,"%f\n",M1[(int)(Length/2)][2*(int)(Length/2)]);
   fprintf(ftmp,"%f\n",M1[(int)(Length/2)][2*(int)(Length/2)+1]);
   }
 if (strcmp(inputformat, "float") == 0) {
   fprintf(ftmp,"%f\n",M1[(int)(Length/2)][(int)(Length/2)]);
   }
 if (strcmp(inputformat, "int") == 0) {
   fprintf(ftmp,"%i\n",M2[(int)(Length/2)][(int)(Length/2)]);
   }
 fclose(ftmp);

}
/*******************************************************************
  Routine  : CreateDataBin
  Authors  : Eric POTTIER, Laurent FERRO-FAMIL
  Creation : 12/2006
  Update  :
*-------------------------------------------------------------------
  Description :  Create the binary data according the output format
*-------------------------------------------------------------------
  Inputs arguments :
  Returned values  :
    void
*******************************************************************/
void CreateDataBin(int Length)
{
 int k,l;

if (strcmp(inputformat, "cmplx") == 0) {
  if (strcmp(outputformat, "mod") == 0) {
     for(l=0; l<Length; l++)  {
       for(k=0;k<Length;k++) {
         M1[l][k] = sqrt(M1[l][2*k]*M1[l][2*k]+M1[l][2*k+1]*M1[l][2*k+1]);
         }
       }
    }
  if (strcmp(outputformat, "db10") == 0) {
    for(l=0; l<Length; l++)  {
      for(k=0;k<Length;k++) {
        M1[l][k] = sqrt(M1[l][2*k]*M1[l][2*k]+M1[l][2*k+1]*M1[l][2*k+1]);
        if (M1[l][k] < eps) M1[l][k] = eps;
        M1[l][k] = 10.0*log10(M1[l][k]);
        }
      }
    }
  if (strcmp(outputformat, "db20") == 0) {
    for(l=0; l<Length; l++)  {
      for(k=0;k<Length;k++) {
        M1[l][k] = sqrt(M1[l][2*k]*M1[l][2*k]+M1[l][2*k+1]*M1[l][2*k+1]);
        if (M1[l][k] < eps) M1[l][k] = eps;
        M1[l][k] = 20.0*log10(M1[l][k]);
        }
      }
    }
  if (strcmp(outputformat, "pha") == 0) {
    for(l=0; l<Length; l++)  {
      for(k=0;k<Length;k++) {
        M1[l][k] = atan2(M1[l][2*k+1],M1[l][2*k]) * 180.0 / pi;
        }
      }
    }
  if (strcmp(outputformat, "real") == 0) {
    for(l=0; l<Length; l++)  {
      for(k=0;k<Length;k++) {
        M1[l][k] = M1[l][2*k];
        }
      }
    }
  if (strcmp(outputformat, "imag") == 0) {
    for(l=0; l<Length; l++)  {
      for(k=0;k<Length;k++) {
        M1[l][k] = M1[l][2*k+1];
        }
      }
    }
  }
  
if (strcmp(inputformat, "float") == 0) {
  if (strcmp(outputformat, "mod") == 0) {
    for(l=0; l<Length; l++)  {
      for(k=0;k<Length;k++) {
      M1[l][k] = fabs(M1[l][k]);
      }
    }
  }
  if (strcmp(outputformat, "db10") == 0) {
    for(l=0; l<Length; l++)  {
      for(k=0;k<Length;k++) {
        M1[l][k] = fabs(M1[l][k]);
        if (M1[l][k] < eps) M1[l][k] = eps;
        M1[l][k] = 10.0*log10(M1[l][k]);
        }
      }
    }
  if (strcmp(outputformat, "db20") == 0) {
    for(l=0; l<Length; l++)  {
      for(k=0;k<Length;k++) {
        M1[l][k] = fabs(M1[l][k]);
        if (M1[l][k] < eps) M1[l][k] = eps;
        M1[l][k] = 20.0*log10(M1[l][k]);
        }
      }
    }
  if (strcmp(outputformat, "real") == 0) {
    for(l=0; l<Length; l++)  {
      for(k=0;k<Length;k++) {
        M1[l][k] = M1[l][k];
        }
      }
    }
  }
 
if (strcmp(inputformat, "int") == 0) {
  if (strcmp(outputformat, "mod") == 0) {
    for(l=0; l<Length; l++)  {
      for(k=0;k<Length;k++) {
        M2[l][k] = fabs(M2[l][k]);
        }
      }
    }
  if (strcmp(outputformat, "db10") == 0) {
    for(l=0; l<Length; l++)  {
      for(k=0;k<Length;k++) {
        M1[l][k] = fabs((float)M2[l][k]);
        if (M1[l][k] < eps) M1[l][k] = eps;
        M2[l][k] = (int)10.0*log10(M1[l][k]);
        }
      }
    }
  if (strcmp(outputformat, "db20") == 0) {
    for(l=0; l<Length; l++)  {
      for(k=0;k<Length;k++) {
        M1[l][k] = fabs((float)M2[l][k]);
        if (M1[l][k] < eps) M1[l][k] = eps;
        M2[l][k] = (int)20.0*log10(M1[l][k]);
        }
      }
    }
  if (strcmp(outputformat, "real") == 0) {
    for(l=0; l<Length; l++)  {
      for(k=0;k<Length;k++) {
        M2[l][k] = M2[l][k];
        }
      }
    }
  }

}

/*******************************************************************
  Routine  : WriteDataBin
  Authors  : Eric POTTIER, Laurent FERRO-FAMIL
  Creation : 12/2006
  Update  :
*-------------------------------------------------------------------
  Description :  Write the selected area in binary files
*-------------------------------------------------------------------
  Inputs arguments :
  Returned values  :
    void
*******************************************************************/
void WriteDataBin(int Length, int MinMaxAuto, int MinI, int MaxI, float MinF, float MaxF)
{
 FILE *ftmp;
 int k,l;
 int xmin, xmax,ymin,ymax,zmin,zmax;
 int Nctr = 10;
 float kk, NctrStart, NctrIncr;
 float *X,*Y;

if ((ftmp = fopen(Profile3DBin, "wb")) == NULL)
  edit_error("Could not open input file : ", Profile3DBin);
if (strcmp(inputformat, "int") == 0) {
  for(l=0; l<Length; l++) fwrite(&M2[l][0],sizeof(int),Length,ftmp);
  } else {
  for(l=0; l<Length; l++) fwrite(&M1[l][0],sizeof(float),Length,ftmp);
  }
fclose(ftmp);

if (strcmp(inputformat, "int") == 0) {

/* X RANGE */  
  for(k=0;k<Length;k++) TmpIX[k] = M2[(int)(Length/2)][k];
  if (MinMaxAuto == 1) {
    MinI = TmpIX[0]; MaxI = TmpIX[0]; 
    for(k=0;k<Length;k++) {
      if (MinI > TmpIX[k]) MinI = TmpIX[k];
      if (MaxI < TmpIX[k]) MaxI = TmpIX[k];
      }
    } else {
    for(k=0;k<Length;k++) {
      if (TmpIX[k] < MinI) TmpIX[k] = MinI;
      if  (TmpIX[k] > MaxI) TmpIX[k] = MaxI;
      }
    }
  
  if ((ftmp = fopen(ProfileXTxt, "w")) == NULL)
    edit_error("Could not open input file : ", ProfileXTxt);
  fprintf(ftmp, "%i\n", Length);
  fprintf(ftmp, "%f\n", MinF);fprintf(ftmp, "%f\n", MaxF);
  fclose(ftmp);
  if ((ftmp = fopen(ProfileXBin, "wb")) == NULL)
    edit_error("Could not open input file : ", ProfileXBin);
  for (k=0; k<Length; k++)
    fprintf(ftmp, "%i %f\n",k,(float)TmpIX[k]);
  fclose(ftmp);
  
/* X-Y RANGE */
  for(k=0;k<Length;k++) TmpIY[k] = M2[k][(int)(Length/2)];
  if (MinMaxAuto == 1) {
    MinI = TmpIY[0]; MaxI = TmpIY[0]; 
    for(k=0;k<Length;k++) {
      if (MinI > TmpIY[k]) MinI = TmpIY[k];
      if (MaxI < TmpIY[k]) MaxI = TmpIY[k];
      }
    } else {
    for(k=0;k<Length;k++) {
      if (TmpIY[k] < MinI) TmpIY[k] = MinI;
      if  (TmpIY[k] > MaxI) TmpIY[k] = MaxI;
      }
    }

  if ((ftmp = fopen(Profile1DXBin, "wb")) == NULL)
    edit_error("Could not open input file : ", Profile1DXBin);
  fwrite(&TmpIX[0],sizeof(int),Length,ftmp);
  fclose(ftmp);

  if ((ftmp = fopen(ProfileYTxt, "w")) == NULL)
    edit_error("Could not open input file : ", ProfileYTxt);
  fprintf(ftmp, "%i\n", Length);
  fprintf(ftmp, "%f\n", MinF);fprintf(ftmp, "%f\n", MaxF);
  fclose(ftmp);
  if ((ftmp = fopen(ProfileYBin, "wb")) == NULL)
    edit_error("Could not open input file : ", ProfileYBin);
  for (k=0; k<Length; k++)
    fprintf(ftmp, "%i %f\n",k,(float)TmpIY[k]);
  fclose(ftmp);

  if ((ftmp = fopen(Profile1DYBin, "wb")) == NULL)
    edit_error("Could not open input file : ", Profile1DYBin);
  fwrite(&TmpIY[0],sizeof(int),Length,ftmp);
  fclose(ftmp);

/* X-Y RANGE */
  if (MinMaxAuto == 1) {
    MinI = M2[0][0]; MaxI = M2[0][0]; 
    for(k=0;k<Length;k++) {
      for(l=0;l<Length;l++) {
        if (MinI > M2[k][l]) MinI = M2[k][l];
        if (MaxI < M2[k][l]) MaxI = M2[k][l];
        }
      }
    } else {
    for(k=0;k<Length;k++) {
      for(l=0;l<Length;l++) {
        if (M2[k][l] < MinI) M2[k][l] = MinI;
        if  (M2[k][l] > MaxI) M2[k][l] = MaxI;
        }
      }
    }

  X = vector_float(Length);
  Y = vector_float(Length);
  xmin = 0; xmax = Length;
  ymin = 0; ymax = Length;
  zmin = MinI; zmax = MaxI;
  NctrStart = MinF;
  NctrIncr = ((float)MaxI-(float)MinI)/((float)Nctr-1);

  for(k=0;k<Length;k++) X[k]=k;
  for(k=0;k<Length;k++) Y[k]=k;
  
  if ((ftmp = fopen(ProfileXYTxt, "w")) == NULL)
    edit_error("Could not open input file : ", ProfileXYTxt);
  fprintf(ftmp, "%i\n", Length);
  fprintf(ftmp, "%i\n", (int)xmin);fprintf(ftmp, "%i\n", (int)xmax);
  fprintf(ftmp, "%i\n", Length);
  fprintf(ftmp, "%i\n", (int)ymin);fprintf(ftmp, "%i\n", (int)ymax);
  fprintf(ftmp, "%i\n", zmin);fprintf(ftmp, "%i\n", zmax);
  fprintf(ftmp, "%f\n", MinF);fprintf(ftmp, "%f\n", MaxF);
  fprintf(ftmp, "%i\n", Nctr);
  fprintf(ftmp, "%f\n", NctrStart);fprintf(ftmp, "%f\n", NctrIncr);
  fclose(ftmp);
  
  if ((ftmp = fopen(ProfileXYBin, "w")) == NULL)
    edit_error("Could not open input file : ", ProfileXYBin);
  k = (float)Length;
  fwrite(&k,sizeof(float),1,ftmp);
  fwrite(&X[0],sizeof(float),Length,ftmp);
  for(k=0;k<Length;k++) {
    for(l=0;l<Length;l++) {
      M1[k][l] = (float)M2[k][l];
      }
    }
  for (k=0 ; k<Length; k++) {
    fwrite(&Y[k],sizeof(float),1,ftmp);
    fwrite(&M1[k][0],sizeof(float),Length,ftmp); /* z is ny rows by nx columns */
    }
  fclose(ftmp);

  } else {

/* X RANGE */
  for(k=0;k<Length;k++) TmpX[k] = M1[(int)(Length/2)][k];
  if (MinMaxAuto == 1) {
    if (strcmp(outputformat, "pha") == 0) {
      MinF = -180.0; MaxF = 180.0; 
      } else {
      MinF = TmpX[0]; MaxF = TmpX[0]; 
      for(k=0;k<Length;k++) {
        if (MinF > TmpX[k]) MinF = TmpX[k];
        if (MaxF < TmpX[k]) MaxF = TmpX[k];
        }
      }
    } else {
    for(k=0;k<Length;k++) {
      if (TmpX[k] < MinF) TmpX[k] = MinF;
      if  (TmpX[k] > MaxF) TmpX[k] = MaxF;
      }
    }
  
  if ((ftmp = fopen(ProfileXTxt, "w")) == NULL)
    edit_error("Could not open input file : ", ProfileXTxt);
  fprintf(ftmp, "%i\n", Length);
  fprintf(ftmp, "%f\n", MinF);fprintf(ftmp, "%f\n", MaxF);
  fclose(ftmp);
  if ((ftmp = fopen(ProfileXBin, "wb")) == NULL)
    edit_error("Could not open input file : ", ProfileXBin);
  for (k=0; k<Length; k++)
    fprintf(ftmp, "%i %f\n",k,TmpX[k]);
  fclose(ftmp);

  if ((ftmp = fopen(Profile1DXBin, "wb")) == NULL)
    edit_error("Could not open input file : ", Profile1DXBin);
  fwrite(&TmpX[0],sizeof(float),Length,ftmp);
  fclose(ftmp);

/* Y RANGE */
  for(k=0;k<Length;k++) TmpY[k] = M1[k][(int)(Length/2)];
  if (MinMaxAuto == 1) {
    if (strcmp(outputformat, "pha") == 0) {
      MinF = -180.0; MaxF = 180.0; 
      } else {
      MinF = TmpY[0]; MaxF = TmpY[0]; 
      for(k=0;k<Length;k++) {
        if (MinF > TmpY[k]) MinF = TmpY[k];
        if (MaxF < TmpY[k]) MaxF = TmpY[k];
        }
      }
    } else {
    for(k=0;k<Length;k++) {
      if (TmpY[k] < MinF) TmpY[k] = MinF;
      if  (TmpY[k] > MaxF) TmpY[k] = MaxF;
      }
    }

  if ((ftmp = fopen(ProfileYTxt, "w")) == NULL)
    edit_error("Could not open input file : ", ProfileYTxt);
  fprintf(ftmp, "%i\n", Length);
  fprintf(ftmp, "%f\n", MinF);fprintf(ftmp, "%f\n", MaxF);
  fclose(ftmp);
  if ((ftmp = fopen(ProfileYBin, "wb")) == NULL)
    edit_error("Could not open input file : ", ProfileYBin);
  for (k=0; k<Length; k++)
    fprintf(ftmp, "%i %f\n",k,TmpY[k]);
  fclose(ftmp);

  if ((ftmp = fopen(Profile1DYBin, "wb")) == NULL)
    edit_error("Could not open input file : ", Profile1DYBin);
  fwrite(&TmpY[0],sizeof(float),Length,ftmp);
  fclose(ftmp);

/* X-Y RANGE */
  if (MinMaxAuto == 1) {
    if (strcmp(outputformat, "pha") == 0) {
      MinF = -180.0; MaxF = 180.0; 
      } else {
      MinF = M1[0][0]; MaxF = M1[0][0]; 
      for(k=0;k<Length;k++) {
        for(l=0;l<Length;l++) {
          if (MinF > M1[k][l]) MinF = M1[k][l];
          if (MaxF < M1[k][l]) MaxF = M1[k][l];
          }
        }
      }
    } else {
    for(k=0;k<Length;k++) {
      for(l=0;l<Length;l++) {
        if (M1[k][l] < MinF) M1[k][l] = MinF;
        if  (M1[k][l] > MaxF) M1[k][l] = MaxF;
        }
      }
    }

  X = vector_float(Length);
  Y = vector_float(Length);
  xmin = 0; xmax = Length;
  ymin = 0; ymax = Length;
  zmin = floor(MinF); zmax = floor(MaxF);
  NctrStart = MinF;
  NctrIncr = (MaxF-MinF)/((float)Nctr-1);
  
  for(k=0;k<Length;k++) X[k]=(float)k;
  for(k=0;k<Length;k++) Y[k]=(float)k;
  
  if ((ftmp = fopen(ProfileXYTxt, "w")) == NULL)
    edit_error("Could not open input file : ", ProfileXYTxt);
  fprintf(ftmp, "%i\n", Length);
  fprintf(ftmp, "%i\n", (int)xmin);fprintf(ftmp, "%i\n", (int)xmax);
  fprintf(ftmp, "%i\n", Length);
  fprintf(ftmp, "%i\n", (int)ymin);fprintf(ftmp, "%i\n", (int)ymax);
  fprintf(ftmp, "%i\n", zmin);fprintf(ftmp, "%i\n", zmax);
  fprintf(ftmp, "%f\n", MinF);fprintf(ftmp, "%f\n", MaxF);
  fprintf(ftmp, "%i\n", Nctr);
  fprintf(ftmp, "%f\n", NctrStart);fprintf(ftmp, "%f\n", NctrIncr);
  fclose(ftmp);
  
  if ((ftmp = fopen(ProfileXYBin, "wb")) == NULL)
    edit_error("Could not open input file : ", ProfileXYBin);
  kk = (float)Length;
  fwrite(&kk,sizeof(float),1,ftmp);
  fwrite(&X[0],sizeof(float),Length,ftmp);
  for (k=0 ; k<Length; k++) {
    fwrite(&Y[k],sizeof(float),1,ftmp);
    fwrite(&M1[k][0],sizeof(float),Length,ftmp); /* z is ny rows by nx columns */
    }
  fclose(ftmp);
  }

}



