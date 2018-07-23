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

File  : Polar_Signature.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2011
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

Description :  Target Polarimetric Signature representation

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* GLOBAL VARIABLES */
long CurrentPointerPosition;
float ***S_in;
float ***M_in;
float *M_out;

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"
void FilePointerPosition(int PixLig,int PixCol,int Ncol,char *TypePol);
void Signature(int Nphi, float *phi, int Ntau, float *tau, float **P_copol, float **P_xpol, char *TypePol);
void WriteSignature(float **Pc, float **Px, int Ntau, float *tau, int Nphi, float *phi, char *CopolTxt, char *CopolBin, char *XpolTxt, char *XpolBin, char *format);

char CopolTxt[FilePathLength], CopolBin[FilePathLength];
char XpolTxt[FilePathLength], XpolBin[FilePathLength];

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{

#define NPolType 3
/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C3", "T3"};
  char Operation[20],Format[20];
  
/* Internal variables */
  int ii, i, Ntau = 90, Nphi = 180;
  int FlagExit, FlagRead;
  int PixLig, PixCol;

/* Matrix arrays */
  float **P_copol,**P_xpol;
  float *phi,*tau;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nPolar_Signature.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (string)	-fct 	output copol txt file\n");
strcat(UsageHelp," (string)	-fcb 	output copol bin file\n");
strcat(UsageHelp," (string)	-fxt 	output xpol txt file\n");
strcat(UsageHelp," (string)	-fxb 	output xpol bin file\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");
strcat(UsageHelp," (noarg) 	-data	displays the help concerning Data Format parameter\n");

/********************************************************************
********************************************************************/

strcpy(UsageHelpDataFormat,"\nPolarimetric Input-Output Data Format\n\n");
for (ii=0; ii<NPolType; ii++) CreateUsageHelpDataFormatInput(PolTypeConf[ii]); 
strcat(UsageHelpDataFormat,"\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }
if(get_commandline_prm(argc,argv,"-data",no_cmd_prm,NULL,0,UsageHelpDataFormat)) {
  printf("\n Usage:\n%s\n",UsageHelpDataFormat); exit(1);
  }

if(argc < 13) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fct",str_cmd_prm,CopolTxt,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fcb",str_cmd_prm,CopolBin,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fxt",str_cmd_prm,XpolTxt,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fxb",str_cmd_prm,XpolBin,1,UsageHelp);

  Config = 0;
  for (ii=0; ii<NPolType; ii++) if (strcmp(PolTypeConf[ii],PolType) == 0) Config = 1;
  if (Config == 0) edit_error("\nWrong argument in the Polarimetric Data Format\n",UsageHelpDataFormat);
  }

/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_file(CopolTxt);
  check_file(CopolBin);
  check_file(XpolTxt);
  check_file(XpolBin);

  NwinL = 1; NwinC = 1;
  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);
  
/* POLAR TYPE CONFIGURATION */
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);
  
  file_name_in = matrix_char(NpolarIn,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir, file_name_in);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
  if ((in_datafile[Np] = fopen(file_name_in[Np], "rb")) == NULL)
    edit_error("Could not open input file : ", file_name_in[Np]);
  
/********************************************************************
********************************************************************/
/* MEMORY ALLOCATION */

  S_in = matrix3d_float(4,1,2);
  M_in = matrix3d_float(9,1,1);
  M_out = vector_float(9);

  phi  = vector_float(Nphi);
  tau  = vector_float(Ntau);
  P_copol  = matrix_float(Nphi,Ntau);
  P_xpol  = matrix_float(Nphi,Ntau);

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

  for(i=0;i<Nphi;i++) phi[i] = -90. + 180./((float)Nphi-1)*(float)i;
  for(i=0;i<Ntau;i++) tau[i] = -45. + 90./((float)Ntau-1)*(float)i;

  FilePointerPosition(Nlig/2,Ncol/2,Ncol,PolType);

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
        FilePointerPosition(PixLig,PixCol,Ncol,PolType);
        Signature(Nphi,phi,Ntau,tau,P_copol,P_xpol,PolType);
        WriteSignature(P_copol,P_xpol,Ntau,tau,Nphi,phi,CopolTxt,CopolBin,XpolTxt,XpolBin,Format);
        printf("OKplotOK\r");fflush(stdout);
        }
      }
      } /*while */

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_vector_float(phi);
  free_vector_float(tau);
  free_matrix_float(P_copol,Ntau);
  free_matrix_float(P_xpol,Ntau);
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  
/********************************************************************
********************************************************************/

  return 1;
}

/*******************************************************************************
  Routine  : FilePointerPosition
  Authors  : Eric POTTIER, Laurent FERRO-FAMIL
  Creation : 04/2005
  Update  :
*-------------------------------------------------------------------------------
  Description :  Update the Pointer position of the data files
*-------------------------------------------------------------------------------
  Inputs arguments :
    PixLig : Line position of the pixel [0 ... Nlig-1]
    PixCol : Row position of the pixel  [0 ... Ncol-1]
    Ncol  : Number of rows
  Returned values  :
    void
*******************************************************************************/
void FilePointerPosition(int PixLig,int PixCol,int Ncol,char *TypePol)
{
long PointerPosition;
int np;
if (strcmp(TypePol,"S2") == 0) {
  PointerPosition = (PixLig * Ncol + PixCol) * 2 * sizeof(float);
  for (np=0; np < 4; np++) {
    CurrentPointerPosition = ftell(in_datafile[np]);
    fseek(in_datafile[np], (PointerPosition - CurrentPointerPosition), SEEK_CUR);
    }
  } else {
  PointerPosition = (PixLig * Ncol + PixCol) * sizeof(float);
  for (np=0; np < 9; np++) {
    CurrentPointerPosition = ftell(in_datafile[np]);
    fseek(in_datafile[np], (PointerPosition - CurrentPointerPosition), SEEK_CUR);
    }
  }
}

/*******************************************************************************
  Routine  : Signature
  Authors  : Eric POTTIER, Laurent FERRO-FAMIL
  Creation : 04/2005
  Update  :
*-------------------------------------------------------------------------------
  Description :  Update the Pointer position of the data files
*-------------------------------------------------------------------------------
  Inputs arguments :
    Nphi : Number of angle phi values
    phi  : Values of the phi angle (in deg)
    Ntau : Number of angle tau values
    tau  : Values of the tau angle (in deg)
  Returned values  :
    P_copol :  Copol Signature
    P_xpol  :  Xpol Signature
    void
*******************************************************************************/
void Signature(int Nphi, float *phi, int Ntau, float *tau, float **P_copol, float **P_xpol, char *TypePol)
{
int np, ind_phi, ind_tau;
float Phi, Tau;
float T11_phi, T22_phi, T33_phi;
float T12_re_phi, T12_im_phi, T13_re_phi, T13_im_phi;
float T23_re_phi, T23_im_phi;

if (strcmp(TypePol,"S2") == 0) {
  for(np=0; np<4; np++) fread(&S_in[np][0][0], sizeof(float), 2, in_datafile[np]);
  S2_to_T3(S_in, M_in, 1, 1, 0, 0);
  } else {
  for(np=0; np<9; np++) fread(&M_in[np][0][0], sizeof(float), 1, in_datafile[np]);
  if (strcmp(TypePol,"C3") == 0) C3_to_T3(M_in, 1, 1, 0, 0);
  }
  
for(ind_phi=0;ind_phi<Nphi;ind_phi++)
{
 Phi = phi[ind_phi]*4*atan(1)/180;
 for(ind_tau=0;ind_tau<Ntau;ind_tau++)
 {
  Tau = tau[ind_tau]*4*atan(1)/180;

/* Real Rotation Phi */
    T11_phi = M_in[T311][0][0];
    T12_re_phi = M_in[T312_re][0][0] * cos(2 * Phi) + M_in[T313_re][0][0] * sin(2 * Phi);
    T12_im_phi = M_in[T312_im][0][0] * cos(2 * Phi) + M_in[T313_im][0][0] * sin(2 * Phi);
    T13_re_phi = -M_in[T312_re][0][0] * sin(2 * Phi) + M_in[T313_re][0][0] * cos(2 * Phi);
    T13_im_phi = -M_in[T312_im][0][0] * sin(2 * Phi) + M_in[T313_im][0][0] * cos(2 * Phi);
    T22_phi = M_in[T322][0][0] * cos(2 * Phi) * cos(2 * Phi) +  M_in[T323_re][0][0] * sin(4 * Phi) + M_in[T333][0][0] * sin(2 * Phi) * sin(2 * Phi);
    T23_re_phi = 0.5 * (M_in[T333][0][0] - M_in[T322][0][0]) * sin(4 * Phi) + M_in[T323_re][0][0] * cos(4 * Phi);
    T23_im_phi = M_in[T323_im][0][0];
    T33_phi = M_in[T322][0][0] * sin(2 * Phi) * sin(2 * Phi) - M_in[T323_re][0][0] * sin(4 * Phi) + M_in[T333][0][0] * cos(2 * Phi) * cos(2 * Phi);

/* Elliptical Rotation Tau */
    M_out[T311] = T11_phi * cos(2 * Tau) * cos(2 * Tau) +  T13_im_phi * sin(4 * Tau);
    M_out[T311] = M_out[T311] + T33_phi * sin(2 * Tau) * sin(2 * Tau);

    M_out[T312_re] = T12_re_phi * cos(2 * Tau) + T23_im_phi * sin(2 * Tau);
    M_out[T312_im] = T12_im_phi * cos(2 * Tau) + T23_re_phi * sin(2 * Tau);

    M_out[T313_re] = T13_re_phi;
    M_out[T313_im] = T13_im_phi * cos(4 * Tau) + 0.5 * (T33_phi - T11_phi) * sin(4 * Tau);

    M_out[T322] = T22_phi;

    M_out[T323_re] = T23_re_phi * cos(2 * Tau) - T12_im_phi * sin(2 * Tau);
    M_out[T323_im] = T23_im_phi * cos(2 * Tau) - T12_re_phi * sin(2 * Tau);

    M_out[T333] = T11_phi * sin(2 * Tau) * sin(2 * Tau) - T13_im_phi * sin(4 * Tau);
    M_out[T333] = M_out[T333] + T33_phi * cos(2 * Tau) * cos(2 * Tau);

  P_copol[ind_phi][ind_tau] = (M_out[T311] + 2 * M_out[T312_re] + M_out[T322]) / 2.;
  P_xpol[ind_phi][ind_tau] = M_out[T333]/2.;
 }
}

}
/*******************************************************************************
  Routine  : WriteSignature
  Authors  : Eric POTTIER, Laurent FERRO-FAMIL
  Creation : 04/2005
  Update  :
*-------------------------------------------------------------------------------
  Description :  Write the Co-Polar and X-Polar Signatures in binary files
*-------------------------------------------------------------------------------
  Inputs arguments :
  Returned values  :
    void
*******************************************************************************/
void WriteSignature(float **Pc, float **Px, int Ntau, float *tau, int Nphi, float *phi, char *CopolTxt, char *CopolBin, char *XpolTxt, char *XpolBin, char *format)
{
 FILE *ftmp;
 int i,j;
 int xmin = -45, xmax = +45;
 int ymin = -90, ymax = +90;
 int zmin, zmax;
 int Nctr = 10;
 float k,min, max;
 float NctrStart, NctrIncr;
 
 if (strcmp(format,"dB")==0) { zmin = -40; zmax = 0; }
 if (strcmp(format,"lin")==0) { zmin = 0; zmax = 1; }

 NctrStart = (float)zmin;
 NctrIncr = (float)(zmax-zmin)/((float)Nctr-1);

 max = Pc[0][0];
 min = Pc[0][0];
 for(i=0;i<Nphi;i++)
  for(j=0;j<Ntau;j++) {
   if(max < Pc[i][j]) max = Pc[i][j];
   if(min > Pc[i][j]) min = Pc[i][j];
   }
  
 for(i=0;i<Nphi;i++)
  for(j=0;j<Ntau;j++)
   Pc[i][j] /= max;

 if (strcmp(format,"dB")==0) {
  min = 10.*log10(min); max = 10.*log10(max);
  for(i=0;i<Nphi;i++)
   for(j=0;j<Ntau;j++) {
    Pc[i][j] = 10.*log10(Pc[i][j]);
    if(Pc[i][j]<(float)zmin) Pc[i][j] = (float)zmin + eps;
    }
  }

 if ((ftmp = fopen(CopolTxt, "w")) == NULL)
  edit_error("Could not open input file : ", CopolTxt);
 fprintf(ftmp, "%i\n", Ntau);
 fprintf(ftmp, "%i\n", xmin);fprintf(ftmp, "%i\n", xmax);
 fprintf(ftmp, "%i\n", Nphi);
 fprintf(ftmp, "%i\n", ymin);fprintf(ftmp, "%i\n", ymax);
 fprintf(ftmp, "%i\n", zmin);fprintf(ftmp, "%i\n", zmax);
 fprintf(ftmp, "%f\n", min);fprintf(ftmp, "%f\n", max);
 fprintf(ftmp, "%i\n", Nctr);
 fprintf(ftmp, "%f\n", NctrStart);fprintf(ftmp, "%f\n", NctrIncr);
 fclose(ftmp);
 if ((ftmp = fopen(CopolBin, "wb")) == NULL)
  edit_error("Could not open input file : ", CopolBin);
 k = (float)Ntau;
 fwrite(&k,sizeof(float),1,ftmp);
 fwrite(&tau[0],sizeof(float),Ntau,ftmp);
 for (i=0 ; i<Nphi; i++) {
  fwrite(&phi[i],sizeof(float),1,ftmp);
  fwrite(&Pc[i][0],sizeof(float),Ntau,ftmp); /* z is ny rows by nx columns */
  }
 fclose(ftmp);

 max = Px[0][0];
 min = Px[0][0];
 for(i=0;i<Nphi;i++)
  for(j=0;j<Ntau;j++) {
   if(max < Px[i][j]) max = Px[i][j];
   if(min > Px[i][j]) min = Px[i][j];
   }
  
 for(i=0;i<Nphi;i++)
  for(j=0;j<Ntau;j++)
   Px[i][j] /= max;

 if (strcmp(format,"dB")==0) {
  min = 10.*log10(min); max = 10.*log10(max);
  for(i=0;i<Nphi;i++)
   for(j=0;j<Ntau;j++) {
    Px[i][j] = 10.*log10(Px[i][j]);
    if(Px[i][j]<(float)zmin) Px[i][j] = (float)zmin + eps;
    }
  }

 if ((ftmp = fopen(XpolTxt, "w")) == NULL)
  edit_error("Could not open input file : ", XpolTxt);
 fprintf(ftmp, "%i\n", Ntau);
 fprintf(ftmp, "%i\n", xmin);fprintf(ftmp, "%i\n", xmax);
 fprintf(ftmp, "%i\n", Nphi);
 fprintf(ftmp, "%i\n", ymin);fprintf(ftmp, "%i\n", ymax);
 fprintf(ftmp, "%i\n", zmin);fprintf(ftmp, "%i\n", zmax);
 fprintf(ftmp, "%f\n", min);fprintf(ftmp, "%f\n", max);
 fprintf(ftmp, "%i\n", Nctr);
 fprintf(ftmp, "%f\n", NctrStart);fprintf(ftmp, "%f\n", NctrIncr);
 fclose(ftmp);
 if ((ftmp = fopen(XpolBin, "wb")) == NULL)
  edit_error("Could not open input file : ", XpolBin);
 k = (float)Ntau;
 fwrite(&k,sizeof(float),1,ftmp);
 fwrite(&tau[0],sizeof(float),Ntau,ftmp);
 for (i=0 ; i<Nphi; i++) {
  fwrite(&phi[i],sizeof(float),1,ftmp);
  fwrite(&Px[i][0],sizeof(float),Ntau,ftmp); /* z is ny rows by nx columns */
  }
 fclose(ftmp);
}


