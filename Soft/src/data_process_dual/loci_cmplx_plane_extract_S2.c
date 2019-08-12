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

File   : loci_cmplx_plane_extract_S2.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2012
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

Description :  Extraction of binary data from a data file using
defined pixel coordinates

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

/* ALIASES  */
#define GHigh  0
#define GLow  1
#define Topo  2
/* S matrix */
#define hh1 0
#define hv1 1
#define vh1 2
#define vv1 3
#define hh2 4
#define hv2 5
#define vh2 6
#define vv2 7

/* ROUTINES */
#include "../lib/PolSARproLib.h"
void FilePointerPosition(int PixLig,int Ncol,int Length);
void ExtractData(int PixCol,int Ncol,int Length);
void ProcessDataLoci(int Length);
void ProcessDataTriplet(int Length);

/* GLOBAL VARIABLES */
FILE *in_fileS[8];
FILE *in_file[3];

float ***S_in;
float TopoPhase[2];
float GHighCoh[2];
float GLowCoh[2];

float gmax1[400],gmax2[400];
float gmin1[400],gmin2[400];

float gopt1[2];
float gopt2[2];
float gopt3[2];

char file_name[FilePathLength], in_dir1[FilePathLength], in_dir2[FilePathLength];
char OutputTxt[FilePathLength], OutputLineTxt[FilePathLength];
char OutputLociTxt[FilePathLength], OutputTripletTxt[FilePathLength];

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{
#define NPolType 1
/* LOCAL VARIABLES */
/* Input/Output file pointer arrays */
  FILE *out_file;

/* Strings */
  char *file_name_in[8] = {
  "s11.bin", "s12.bin", "s21.bin", "s22.bin",
  "s11.bin", "s12.bin", "s21.bin", "s22.bin"
  };
  char PolarCase[20], PolarType[20];
  char Operation[FilePathLength];

/* Input variables */
  int Nlig, Ncol;  /* Initial image nb of lines and rows */
  int FlagExit, FlagRead;
  int ii, k, Np;
  int PixLig, PixCol;
  int Length;
  float xr,xi;

/********************************************************************
********************************************************************/
/* USAGE */

if (argc < 7) {
  edit_error("loci_cmplx_plane_extract_S2 In_Dir1 In_Dir2 File_Txt FileLine_Txt FileLoci_Txt FileTriplet_Txt\n","");
  } else {
  strcpy(in_dir1, argv[1]);
  strcpy(in_dir2, argv[2]);
  strcpy(OutputTxt, argv[3]);
  strcpy(OutputLineTxt, argv[4]);
  strcpy(OutputLociTxt, argv[5]);
  strcpy(OutputTripletTxt, argv[6]);
  }
/********************************************************************
********************************************************************/

check_dir(in_dir1);
check_dir(in_dir2);
check_file(OutputTxt);
check_file(OutputLineTxt);
check_file(OutputLociTxt);
check_file(OutputTripletTxt);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

read_config(in_dir1, &Nlig, &Ncol, PolarCase, PolarType);

/* INPUT/OUTPUT FILE OPENING*/
for (Np = 0; Np < 4; Np++) {
  sprintf(file_name, "%s%s", in_dir1, file_name_in[Np]);
  if ((in_fileS[Np] = fopen(file_name, "rb")) == NULL)
  edit_error("Could not open input file : ", file_name);
  }
for (Np = 4; Np < 8; Np++) {
  sprintf(file_name, "%s%s", in_dir2, file_name_in[Np]);
  if ((in_fileS[Np] = fopen(file_name, "rb")) == NULL)
  edit_error("Could not open input file : ", file_name);
  }

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
  for (ii = 0; ii < 3; ii++) fclose(in_file[ii]);
  printf("OKfinclosefile\r");fflush(stdout);
  }

if (strcmp(Operation, "openfile") == 0) {
  printf("OKopenfile\r");fflush(stdout);
  FlagRead = 0;
  while (FlagRead == 0) {
  scanf("%s",Operation);
  if (strcmp(Operation, "") != 0) {
    strcpy(file_name,Operation);
    check_file(file_name);
    if ((in_file[GHigh] = fopen(file_name, "rb")) == NULL) edit_error("Could not open output file : ", file_name);
    FlagRead = 1;
    printf("OKreadgammahigh\r");fflush(stdout);
    }
  }
  FlagRead = 0;
  while (FlagRead == 0) {
  scanf("%s",Operation);
  if (strcmp(Operation, "") != 0) {
    strcpy(file_name,Operation);
    check_file(file_name);
    if ((in_file[GLow] = fopen(file_name, "rb")) == NULL) edit_error("Could not open output file : ", file_name);
    FlagRead = 1;
    printf("OKreadgammalow\r");fflush(stdout);
    }
  }
  FlagRead = 0;
  while (FlagRead == 0) {
  scanf("%s",Operation);
  if (strcmp(Operation, "") != 0) {
    strcpy(file_name,Operation);
    check_file(file_name);
    if ((in_file[Topo] = fopen(file_name, "rb")) == NULL) edit_error("Could not open output file : ", file_name);
    FlagRead = 1;
    printf("OKreadtopo\r");fflush(stdout);
    }
  }
  for (ii = 0; ii < 3; ii++) rewind(in_file[ii]);
  for (ii = 0; ii < 8; ii++) rewind(in_fileS[ii]);
  FilePointerPosition(Nlig/2,Ncol,0);
  printf("OKfinopenfile\r");fflush(stdout);
  }

if (strcmp(Operation, "extract") == 0) {
  printf("OKextract\r");fflush(stdout);
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
    Length = atoi(Operation);
    FlagRead = 1;
    printf("OKreadlength\r");fflush(stdout);
    }
  }

  S_in = matrix3d_float(8,Length+1,2*(Length+1));

  FilePointerPosition(PixLig,Ncol,Length);

  ExtractData(PixCol,Ncol,Length);

  /* Output file opening */
  if ((out_file = fopen(OutputTxt, "wb")) == NULL)
  edit_error("Could not open input file : ", OutputTxt);
  xr = GLowCoh[0]; xi = GLowCoh[1];
  fprintf(out_file,"%f ",atan2(xi,xr)*180./pi);
  fprintf(out_file,"%f ",sqrt(xr*xr+xi*xi));
  xr = GHighCoh[0]; xi = GHighCoh[1];
  fprintf(out_file,"%f ",atan2(xi,xr)*180./pi);
  fprintf(out_file,"%f ",sqrt(xr*xr+xi*xi));
  xr = TopoPhase[0]; xi = TopoPhase[1];
  fprintf(out_file,"%f ",atan2(xi,xr)*180./pi);
  fprintf(out_file,"%f ",sqrt(xr*xr+xi*xi));
  fprintf(out_file,"\n");
  fclose(out_file);

  if ((out_file = fopen(OutputLineTxt, "wb")) == NULL)
  edit_error("Could not open input file : ", OutputLineTxt);
  xr = GHighCoh[0]; xi = GHighCoh[1];
  fprintf(out_file,"%f ",atan2(xi,xr)*180./pi);
  fprintf(out_file,"%f ",sqrt(xr*xr+xi*xi));
  fprintf(out_file,"\n");
  xr = TopoPhase[0]; xi = TopoPhase[1];
  fprintf(out_file,"%f ",atan2(xi,xr)*180./pi);
  fprintf(out_file,"%f ",sqrt(xr*xr+xi*xi));
  fclose(out_file);

  ProcessDataLoci(Length);

  if ((out_file = fopen(OutputLociTxt, "wb")) == NULL)
  edit_error("Could not open input file : ", OutputLociTxt);
  for(k=0; k<180; k++) {
  xr = gmax1[2*k]; xi = gmax1[2*k+1];
  fprintf(out_file,"%f ",atan2(xi,xr)*180./pi);
  fprintf(out_file,"%f ",sqrt(xr*xr+xi*xi));
  xr = gmax2[2*k]; xi = gmax2[2*k+1];
  fprintf(out_file,"%f ",atan2(xi,xr)*180./pi);
  fprintf(out_file,"%f ",sqrt(xr*xr+xi*xi));
  fprintf(out_file,"\n");
  }
  for(k=0; k<180; k++) {
  xr = gmin1[2*k]; xi = gmin1[2*k+1];
  fprintf(out_file,"%f ",atan2(xi,xr)*180./pi);
  fprintf(out_file,"%f ",sqrt(xr*xr+xi*xi));
  xr = gmin2[2*k]; xi = gmin2[2*k+1];
  fprintf(out_file,"%f ",atan2(xi,xr)*180./pi);
  fprintf(out_file,"%f ",sqrt(xr*xr+xi*xi));
  fprintf(out_file,"\n");
  }
  fclose(out_file);

  ProcessDataTriplet(Length);

  /* Output file opening */
  if ((out_file = fopen(OutputTripletTxt, "wb")) == NULL)
  edit_error("Could not open input file : ", OutputTripletTxt);
  xr = gopt1[0]; xi = gopt1[1];
  fprintf(out_file,"%f ",atan2(xi,xr)*180./pi);
  fprintf(out_file,"%f ",sqrt(xr*xr+xi*xi));
  xr = gopt2[0]; xi = gopt2[1];
  fprintf(out_file,"%f ",atan2(xi,xr)*180./pi);
  fprintf(out_file,"%f ",sqrt(xr*xr+xi*xi));
  xr = gopt3[0]; xi = gopt3[1];
  fprintf(out_file,"%f ",atan2(xi,xr)*180./pi);
  fprintf(out_file,"%f ",sqrt(xr*xr+xi*xi));
  fprintf(out_file,"\n");
  fclose(out_file);

  free_matrix3d_float(S_in,8,Length+1);

  printf("OKfinextract\r");fflush(stdout);
  } /*Operation Extract*/
  } /*Operation*/
  } /*while */

free_matrix3d_float(S_in,8,Length+1);

return 1;
}    /*Fin Main */

/********************************************************************
  Routine  : FilePointerPosition
  Authors  : Eric POTTIER
  Creation : 12/2006
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
void FilePointerPosition(int PixLig,int Ncol,int Length)
{
long int PointerPosition;
int np;

PointerPosition = 2 * ((PixLig - (int)((Length-1)/2))* Ncol) * sizeof(float);
my_fseek_position(in_file[GHigh], PointerPosition);
my_fseek_position(in_file[GLow], PointerPosition);
my_fseek_position(in_file[Topo], PointerPosition);

PointerPosition = 2 * ((PixLig - (int)((Length-1)/2))* Ncol) * sizeof(float);
for (np=0; np < 8; np++) my_fseek_position(in_fileS[np], PointerPosition);

}

/********************************************************************
  Routine  : ExtractData
  Authors  : Eric POTTIER, Laurent FERRO-FAMIL
  Creation : 12/2006
  Update  :
*--------------------------------------------------------------------
  Description :  Extract data
*--------------------------------------------------------------------
  Inputs arguments :
  PixLig : Line position of the pixel [0 ... Nlig-1]
  PixCol : Row position of the pixel  [0 ... Ncol-1]
  Ncol  : Number of rows
  Length : RangeLength
  Returned values  :
  void
********************************************************************/
void ExtractData(int PixCol,int Ncol,int Length)
{
int np,k,l;
float *Tmp;

Tmp = vector_float(2*Ncol);

for(l=0; l<(int)((Length-1)/2); l++) fread(&Tmp[0], sizeof(float), 2*Ncol, in_file[Topo]);
fread(&Tmp[0], sizeof(float), 2*Ncol, in_file[Topo]);
TopoPhase[0] = Tmp[2*PixCol];
TopoPhase[1] = Tmp[2*PixCol+1];

for(l=0; l<(int)((Length-1)/2); l++) fread(&Tmp[0], sizeof(float), 2*Ncol, in_file[GHigh]);
fread(&Tmp[0], sizeof(float), 2*Ncol, in_file[GHigh]);
GHighCoh[0] = Tmp[2*PixCol];
GHighCoh[1] = Tmp[2*PixCol+1];

for(l=0; l<(int)((Length-1)/2); l++) fread(&Tmp[0], sizeof(float), 2*Ncol, in_file[GLow]);
fread(&Tmp[0], sizeof(float), 2*Ncol, in_file[GLow]);
GLowCoh[0] = Tmp[2*PixCol];
GLowCoh[1] = Tmp[2*PixCol+1];

for(l=0; l<Length; l++) {
  for(np=0; np<8; np++) {
  fread(&Tmp[0], sizeof(float), 2*Ncol, in_fileS[np]);
  for(k=0; k<2*Length; k++) S_in[np][l][k] = Tmp[2*(PixCol-(int)(Length/2))+k];
  }
  }

free_vector_float(Tmp);
}

/********************************************************************
  Routine  : ProcessDataLoci
  Authors  : Eric POTTIER, Laurent FERRO-FAMIL
  Creation : 12/2006
  Update  :
*--------------------------------------------------------------------
  Description :  Process data
*--------------------------------------------------------------------
  Inputs arguments :
  Length : RangeLength
  Returned values  :
  void
********************************************************************/
void ProcessDataLoci(int Length)
{
int k,l,i;
float k1r,k1i,k2r,k2i,k3r,k3i,k4r,k4i,k5r,k5i,k6r,k6i;
float phi;
float *Mean, *L;

cplx **TT11,**TT12,**TT22;
cplx **T, **iT;
cplx **OM12, **OM12p, **hOM12p;
cplx **Tmp,**Tmp11,**Tmp12,**Tmp22;
cplx **V, **hV;

Mean  = vector_float(36);
L  = vector_float(3);

T  = cplx_matrix(3,3);
iT  = cplx_matrix(3,3);
TT11  = cplx_matrix(3,3);
TT12  = cplx_matrix(3,3);
TT22  = cplx_matrix(3,3);
OM12  = cplx_matrix(3,3);
OM12p = cplx_matrix(3,3);
hOM12p= cplx_matrix(3,3);
Tmp  = cplx_matrix(3,3);
Tmp11 = cplx_matrix(3,3);
Tmp12 = cplx_matrix(3,3);
Tmp22 = cplx_matrix(3,3);
V  = cplx_matrix(3,3);
hV  = cplx_matrix(3,3);

for(k=0; k<36; k++) Mean[k] = 0.;

for(k=0; k<Length; k++) {
  for(l=0; l<Length; l++) {
  k1r = (S_in[hh1][k][2*l] + S_in[vv1][k][2*l]) / sqrt(2.);
  k1i = (S_in[hh1][k][2*l+1] + S_in[vv1][k][2*l+1]) / sqrt(2.);
  k2r = (S_in[hh1][k][2*l] - S_in[vv1][k][2*l]) / sqrt(2.);
  k2i = (S_in[hh1][k][2*l+1] - S_in[vv1][k][2*l+1]) / sqrt(2.);
  k3r = (S_in[hv1][k][2*l] + S_in[vh1][k][2*l]) / sqrt(2.);
  k3i = (S_in[hv1][k][2*l+1] + S_in[vh1][k][2*l+1]) / sqrt(2.);
  k4r = (S_in[hh2][k][2*l] + S_in[vv2][k][2*l]) / sqrt(2.);
  k4i = (S_in[hh2][k][2*l+1] + S_in[vv2][k][2*l+1]) / sqrt(2.);
  k5r = (S_in[hh2][k][2*l] - S_in[vv2][k][2*l]) / sqrt(2.);
  k5i = (S_in[hh2][k][2*l+1] - S_in[vv2][k][2*l + 1]) / sqrt(2.);
  k6r = (S_in[hv2][k][2*l] + S_in[vh2][k][2*l]) / sqrt(2.);
  k6i = (S_in[hv2][k][2*l+1] + S_in[vh2][k][2*l+1]) / sqrt(2.);

  Mean[0] += k1r * k1r + k1i * k1i;
  Mean[1] += k1r * k2r + k1i * k2i;
  Mean[2] += k1i * k2r - k1r * k2i;
  Mean[3] += k1r * k3r + k1i * k3i;
  Mean[4] += k1i * k3r - k1r * k3i;
  Mean[5] += k1r * k4r + k1i * k4i;
  Mean[6] += k1i * k4r - k1r * k4i;
  Mean[7] += k1r * k5r + k1i * k5i;
  Mean[8] += k1i * k5r - k1r * k5i;
  Mean[9] += k1r * k6r + k1i * k6i;
  Mean[10] += k1i * k6r - k1r * k6i;
  Mean[11] += k2r * k2r + k2i * k2i;
  Mean[12] += k2r * k3r + k2i * k3i;
  Mean[13] += k2i * k3r - k2r * k3i;
  Mean[14] += k2r * k4r + k2i * k4i;
  Mean[15] += k2i * k4r - k2r * k4i;
  Mean[16] += k2r * k5r + k2i * k5i;
  Mean[17] += k2i * k5r - k2r * k5i;
  Mean[18] += k2r * k6r + k2i * k6i;
  Mean[19] += k2i * k6r - k2r * k6i;
  Mean[20] += k3r * k3r + k3i * k3i;
  Mean[21] += k3r * k4r + k3i * k4i;
  Mean[22] += k3i * k4r - k3r * k4i;
  Mean[23] += k3r * k5r + k3i * k5i;
  Mean[24] += k3i * k5r - k3r * k5i;
  Mean[25] += k3r * k6r + k3i * k6i;
  Mean[26] += k3i * k6r - k3r * k6i;
  Mean[27] += k4r * k4r + k4i * k4i;
  Mean[28] += k4r * k5r + k4i * k5i;
  Mean[29] += k4i * k5r - k4r * k5i;
  Mean[30] += k4r * k6r + k4i * k6i;
  Mean[31] += k4i * k6r - k4r * k6i;
  Mean[32] += k5r * k5r + k5i * k5i;
  Mean[33] += k5r * k6r + k5i * k6i;
  Mean[34] += k5i * k6r - k5r * k6i;
  Mean[35] += k6r * k6r + k6i * k6i;
  }
  }

for(k=0; k<36; k++) Mean[k] = Mean[k] / (Length * Length);

TT11[0][0].re = Mean[0];  TT11[0][0].im = 0;
TT11[0][1].re = Mean[1];  TT11[0][1].im = Mean[2];
TT11[0][2].re = Mean[3];  TT11[0][2].im = Mean[4];
TT11[1][1].re = Mean[11]; TT11[1][1].im = 0;
TT11[1][2].re = Mean[12]; TT11[1][2].im = Mean[13];
TT11[2][2].re = Mean[20]; TT11[2][2].im = 0;
TT11[1][0].re = TT11[0][1].re;  TT11[1][0].im = -TT11[0][1].im;
TT11[2][0].re = TT11[0][2].re;  TT11[2][0].im = -TT11[0][2].im;
TT11[2][1].re = TT11[1][2].re;  TT11[2][1].im = -TT11[1][2].im;


TT22[0][0].re = Mean[27]; TT22[0][0].im = 0;
TT22[0][1].re = Mean[28]; TT22[0][1].im = Mean[29];
TT22[0][2].re = Mean[30]; TT22[0][2].im = Mean[31];
TT22[1][1].re = Mean[32]; TT22[1][1].im = 0;
TT22[1][2].re = Mean[33]; TT22[1][2].im = Mean[34];
TT22[2][2].re = Mean[35]; TT22[2][2].im = 0;
TT22[1][0].re = TT22[0][1].re;  TT22[1][0].im = -TT22[0][1].im;
TT22[2][0].re = TT22[0][2].re;  TT22[2][0].im = -TT22[0][2].im;
TT22[2][1].re = TT22[1][2].re;  TT22[2][1].im = -TT22[1][2].im;
  
  
OM12[0][0].re = Mean[5];  OM12[0][0].im = Mean[6];
OM12[0][1].re = Mean[7];  OM12[0][1].im = Mean[8];
OM12[0][2].re = Mean[9];  OM12[0][2].im = Mean[10];
OM12[1][0].re = Mean[14]; OM12[1][0].im = Mean[15];
OM12[1][1].re = Mean[16]; OM12[1][1].im = Mean[17];
OM12[1][2].re = Mean[18]; OM12[1][2].im = Mean[19];
OM12[2][0].re = Mean[21]; OM12[2][0].im = Mean[22];
OM12[2][1].re = Mean[23]; OM12[2][1].im = Mean[24];
OM12[2][2].re = Mean[25]; OM12[2][2].im = Mean[26];

for(k=0; k<3; k++) {
  for(l=0; l<3; l++) {
  T[k][l].re = (TT11[k][l].re + TT22[k][l].re) / 2.;
  T[k][l].im = (TT11[k][l].im + TT22[k][l].im) / 2.;
  }
  }
cplx_inv_mat(T,iT);

for(i=0; i<180; i++) {
  phi = (float)i * pi / 180.;
  for(k=0; k<3; k++) {
  for(l=0; l<3; l++) {
    Tmp[k][l].re = 0.;
    Tmp[k][l].im = 0.;
    }
  Tmp[k][k].re = cos(phi); 
  Tmp[k][k].im = sin(phi); 
  }
  cplx_mul_mat(OM12,Tmp,OM12p,3,3);
  cplx_htransp_mat(OM12p,hOM12p,3,3);  
  for(k=0; k<3; k++) {
  for(l=0; l<3; l++) {
    TT12[k][l].re = (OM12p[k][l].re + hOM12p[k][l].re) / 2.;
    TT12[k][l].im = (OM12p[k][l].im + hOM12p[k][l].im) / 2.;
    }
  }
  cplx_mul_mat(iT,TT12,Tmp,3,3);
  cplx_diag_mat3(Tmp,V,L);

  cplx_htransp_mat(V,hV,3,3);  

  cplx_mul_mat(OM12,V,Tmp,3,3);
  cplx_mul_mat(hV,Tmp,Tmp12,3,3);

  cplx_mul_mat(TT11,V,Tmp,3,3);
  cplx_mul_mat(hV,Tmp,Tmp11,3,3);

  cplx_mul_mat(TT22,V,Tmp,3,3);
  cplx_mul_mat(hV,Tmp,Tmp22,3,3);

  gmax1[2*i] = Tmp12[0][0].re / sqrt(cmod(Tmp11[0][0]) * cmod(Tmp22[0][0]));
  gmax1[2*i+1] = Tmp12[0][0].im / sqrt(cmod(Tmp11[0][0]) * cmod(Tmp22[0][0]));
  gmin1[2*i] = Tmp12[2][2].re / sqrt(cmod(Tmp11[2][2]) * cmod(Tmp22[2][2]));
  gmin1[2*i+1] = Tmp12[2][2].im / sqrt(cmod(Tmp11[2][2]) * cmod(Tmp22[2][2]));

  cplx_mul_mat(T,V,Tmp,3,3);
  cplx_mul_mat(hV,Tmp,Tmp11,3,3);

  gmax2[2*i] = Tmp12[0][0].re / sqrt(cmod(Tmp11[0][0]) * cmod(Tmp11[0][0]));
  gmax2[2*i+1] = Tmp12[0][0].im / sqrt(cmod(Tmp11[0][0]) * cmod(Tmp11[0][0]));
  gmin2[2*i] = Tmp12[2][2].re / sqrt(cmod(Tmp11[2][2]) * cmod(Tmp11[2][2]));
  gmin2[2*i+1] = Tmp12[2][2].im / sqrt(cmod(Tmp11[2][2]) * cmod(Tmp11[2][2]));
  }  

free_vector_float(Mean);
free_vector_float(L);

cplx_free_matrix(T,3);
cplx_free_matrix(iT,3);
cplx_free_matrix(TT11,3);
cplx_free_matrix(TT12,3);
cplx_free_matrix(TT22,3);
cplx_free_matrix(OM12,3);
cplx_free_matrix(OM12p,3);
cplx_free_matrix(hOM12p,3);
cplx_free_matrix(Tmp,3);
cplx_free_matrix(Tmp11,3);
cplx_free_matrix(Tmp12,3);
cplx_free_matrix(Tmp22,3);
cplx_free_matrix(V,3);
cplx_free_matrix(hV,3);
  
}

/********************************************************************
  Routine  : ProcessDataTriplet
  Authors  : Eric POTTIER, Laurent FERRO-FAMIL
  Creation : 12/2006
  Update  :
*--------------------------------------------------------------------
  Description :  Process data
*--------------------------------------------------------------------
  Inputs arguments :
  Length : RangeLength
  Returned values  :
  void
********************************************************************/
void ProcessDataTriplet(int Length)
{
int k,l;
float k1r,k1i,k2r,k2i,k3r,k3i,k4r,k4i,k5r,k5i,k6r,k6i;
float phi[3];
float *Mean, *L;

cplx **TT11,**TT12,**TT22;
cplx **iTT11,**hTT12,**iTT22;
cplx **Tmp,**Tmp11,**Tmp12,**Tmp22;
cplx **V1, **hV1;
cplx **V2, **hV2;

Mean  = vector_float(36);
L  = vector_float(3);

TT11  = cplx_matrix(3,3);
TT12  = cplx_matrix(3,3);
TT22  = cplx_matrix(3,3);
iTT11 = cplx_matrix(3,3);
hTT12 = cplx_matrix(3,3);
iTT22 = cplx_matrix(3,3);
Tmp  = cplx_matrix(3,3);
Tmp11 = cplx_matrix(3,3);
Tmp12 = cplx_matrix(3,3);
Tmp22 = cplx_matrix(3,3);
V1  = cplx_matrix(3,3);
hV1  = cplx_matrix(3,3);
V2  = cplx_matrix(3,3);
hV2  = cplx_matrix(3,3);

for(k=0; k<36; k++) Mean[k] = 0.;

for(k=0; k<Length; k++) {
  for(l=0; l<Length; l++) {
  k1r = (S_in[hh1][k][2*l] + S_in[vv1][k][2*l]) / sqrt(2.);
  k1i = (S_in[hh1][k][2*l+1] + S_in[vv1][k][2*l+1]) / sqrt(2.);
  k2r = (S_in[hh1][k][2*l] - S_in[vv1][k][2*l]) / sqrt(2.);
  k2i = (S_in[hh1][k][2*l+1] - S_in[vv1][k][2*l+1]) / sqrt(2.);
  k3r = (S_in[hv1][k][2*l] + S_in[vh1][k][2*l]) / sqrt(2.);
  k3i = (S_in[hv1][k][2*l+1] + S_in[vh1][k][2*l+1]) / sqrt(2.);
  k4r = (S_in[hh2][k][2*l] + S_in[vv2][k][2*l]) / sqrt(2.);
  k4i = (S_in[hh2][k][2*l+1] + S_in[vv2][k][2*l+1]) / sqrt(2.);
  k5r = (S_in[hh2][k][2*l] - S_in[vv2][k][2*l]) / sqrt(2.);
  k5i = (S_in[hh2][k][2*l+1] - S_in[vv2][k][2*l + 1]) / sqrt(2.);
  k6r = (S_in[hv2][k][2*l] + S_in[vh2][k][2*l]) / sqrt(2.);
  k6i = (S_in[hv2][k][2*l+1] + S_in[vh2][k][2*l+1]) / sqrt(2.);

  Mean[0] += k1r * k1r + k1i * k1i;
  Mean[1] += k1r * k2r + k1i * k2i;
  Mean[2] += k1i * k2r - k1r * k2i;
  Mean[3] += k1r * k3r + k1i * k3i;
  Mean[4] += k1i * k3r - k1r * k3i;
  Mean[5] += k1r * k4r + k1i * k4i;
  Mean[6] += k1i * k4r - k1r * k4i;
  Mean[7] += k1r * k5r + k1i * k5i;
  Mean[8] += k1i * k5r - k1r * k5i;
  Mean[9] += k1r * k6r + k1i * k6i;
  Mean[10] += k1i * k6r - k1r * k6i;
  Mean[11] += k2r * k2r + k2i * k2i;
  Mean[12] += k2r * k3r + k2i * k3i;
  Mean[13] += k2i * k3r - k2r * k3i;
  Mean[14] += k2r * k4r + k2i * k4i;
  Mean[15] += k2i * k4r - k2r * k4i;
  Mean[16] += k2r * k5r + k2i * k5i;
  Mean[17] += k2i * k5r - k2r * k5i;
  Mean[18] += k2r * k6r + k2i * k6i;
  Mean[19] += k2i * k6r - k2r * k6i;
  Mean[20] += k3r * k3r + k3i * k3i;
  Mean[21] += k3r * k4r + k3i * k4i;
  Mean[22] += k3i * k4r - k3r * k4i;
  Mean[23] += k3r * k5r + k3i * k5i;
  Mean[24] += k3i * k5r - k3r * k5i;
  Mean[25] += k3r * k6r + k3i * k6i;
  Mean[26] += k3i * k6r - k3r * k6i;
  Mean[27] += k4r * k4r + k4i * k4i;
  Mean[28] += k4r * k5r + k4i * k5i;
  Mean[29] += k4i * k5r - k4r * k5i;
  Mean[30] += k4r * k6r + k4i * k6i;
  Mean[31] += k4i * k6r - k4r * k6i;
  Mean[32] += k5r * k5r + k5i * k5i;
  Mean[33] += k5r * k6r + k5i * k6i;
  Mean[34] += k5i * k6r - k5r * k6i;
  Mean[35] += k6r * k6r + k6i * k6i;
  }
  }
for(k=0; k<36; k++) Mean[k] = Mean[k] / (Length * Length);

TT11[0][0].re = Mean[0];  TT11[0][0].im = 0;
TT11[0][1].re = Mean[1];  TT11[0][1].im = Mean[2];
TT11[0][2].re = Mean[3];  TT11[0][2].im = Mean[4];
TT11[1][1].re = Mean[11]; TT11[1][1].im = 0;
TT11[1][2].re = Mean[12]; TT11[1][2].im = Mean[13];
TT11[2][2].re = Mean[20]; TT11[2][2].im = 0;
TT11[1][0].re = TT11[0][1].re;  TT11[1][0].im = -TT11[0][1].im;
TT11[2][0].re = TT11[0][2].re;  TT11[2][0].im = -TT11[0][2].im;
TT11[2][1].re = TT11[1][2].re;  TT11[2][1].im = -TT11[1][2].im;

TT22[0][0].re = Mean[27]; TT22[0][0].im = 0;
TT22[0][1].re = Mean[28]; TT22[0][1].im = Mean[29];
TT22[0][2].re = Mean[30]; TT22[0][2].im = Mean[31];
TT22[1][1].re = Mean[32]; TT22[1][1].im = 0;
TT22[1][2].re = Mean[33]; TT22[1][2].im = Mean[34];
TT22[2][2].re = Mean[35]; TT22[2][2].im = 0;
TT22[1][0].re = TT22[0][1].re;  TT22[1][0].im = -TT22[0][1].im;
TT22[2][0].re = TT22[0][2].re;  TT22[2][0].im = -TT22[0][2].im;
TT22[2][1].re = TT22[1][2].re;  TT22[2][1].im = -TT22[1][2].im;
  
TT12[0][0].re = Mean[5];  TT12[0][0].im = Mean[6];
TT12[0][1].re = Mean[7];  TT12[0][1].im = Mean[8];
TT12[0][2].re = Mean[9];  TT12[0][2].im = Mean[10];
TT12[1][0].re = Mean[14]; TT12[1][0].im = Mean[15];
TT12[1][1].re = Mean[16]; TT12[1][1].im = Mean[17];
TT12[1][2].re = Mean[18]; TT12[1][2].im = Mean[19];
TT12[2][0].re = Mean[21]; TT12[2][0].im = Mean[22];
TT12[2][1].re = Mean[23]; TT12[2][1].im = Mean[24];
TT12[2][2].re = Mean[25]; TT12[2][2].im = Mean[26];

cplx_htransp_mat(TT12,hTT12,3,3);
cplx_inv_mat(TT11,iTT11);
cplx_inv_mat(TT22,iTT22);

//Eigenvectors V2
cplx_mul_mat(iTT22,hTT12,Tmp11,3,3);
cplx_mul_mat(Tmp11,iTT11,Tmp22,3,3);
cplx_mul_mat(Tmp22,TT12,Tmp11,3,3);
cplx_diag_mat3(Tmp11,V2,L);

//Eigenvectors V1
cplx_mul_mat(iTT11,TT12,Tmp11,3,3);
cplx_mul_mat(Tmp11,iTT22,Tmp22,3,3);
cplx_mul_mat(Tmp22,hTT12,Tmp11,3,3);
cplx_diag_mat3(Tmp11,V1,L);

//Eigen Phase Correction
cplx_htransp_mat(V1,hV1,3,3);
cplx_mul_mat(hV1,V2,Tmp11,3,3);
for (k=0; k<3; k++)  phi[k] = angle(Tmp11[k][k]);

//Eigen Phase Normalized Eigenvectors V2 with (-phi)
for (k=0; k<3; k++)
  {
  for (l=0; l<3; l++)
  {  
  Tmp22[k][l].re = 0.; Tmp22[k][l].im = 0.;
  }
  Tmp22[k][k].re = cos(phi[k]);
  Tmp22[k][k].im = -sin(phi[k]);
  }
cplx_mul_mat(V2,Tmp22,Tmp11,3,3);
for (k=0; k<3; k++)
  {
  for (l=0; l<3; l++)
  {  
  V2[k][l].re = Tmp11[k][l].re;
  V2[k][l].im = Tmp11[k][l].im;
  }
  }
cplx_htransp_mat(V2,hV2,3,3);

//Interferogram Formation
cplx_mul_mat(TT12,V2,Tmp,3,3);
cplx_mul_mat(hV1,Tmp,Tmp12,3,3);

cplx_mul_mat(TT11,V1,Tmp,3,3);
cplx_mul_mat(hV1,Tmp,Tmp11,3,3);

cplx_mul_mat(TT22,V2,Tmp,3,3);
cplx_mul_mat(hV2,Tmp,Tmp22,3,3);

gopt1[0] = Tmp12[0][0].re / sqrt(cmod(Tmp11[0][0]) * cmod(Tmp22[0][0]));
gopt1[1] = Tmp12[0][0].im / sqrt(cmod(Tmp11[0][0]) * cmod(Tmp22[0][0]));

gopt2[0] = Tmp12[1][1].re / sqrt(cmod(Tmp11[1][1]) * cmod(Tmp22[1][1]));
gopt2[1] = Tmp12[1][1].im / sqrt(cmod(Tmp11[1][1]) * cmod(Tmp22[1][1]));

gopt3[0] = Tmp12[2][2].re / sqrt(cmod(Tmp11[2][2]) * cmod(Tmp22[2][2]));
gopt3[1] = Tmp12[2][2].im / sqrt(cmod(Tmp11[2][2]) * cmod(Tmp22[2][2]));

free_vector_float(Mean);
free_vector_float(L);

cplx_free_matrix(TT11,3);
cplx_free_matrix(TT12,3);
cplx_free_matrix(TT22,3);
cplx_free_matrix(iTT11,3);
cplx_free_matrix(hTT12,3);
cplx_free_matrix(iTT22,3);
cplx_free_matrix(Tmp,3);
cplx_free_matrix(Tmp11,3);
cplx_free_matrix(Tmp12,3);
cplx_free_matrix(Tmp22,3);
cplx_free_matrix(V1,3);
cplx_free_matrix(hV1,3);
cplx_free_matrix(V2,3);
cplx_free_matrix(hV2,3);
  
}


