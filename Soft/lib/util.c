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

File   : util.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Version  : 1.0
Creation : 09/2003
Update  : 12/2006 (Stephane MERIC)

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

Description :  UTIL Routines

*--------------------------------------------------------------------
Routines  :
struct Pix
struct Pix *Create_Pix(struct Pix *P, float x,float y);
struct Pix *Remove_Pix(struct Pix *P_top, struct Pix *P);
float my_round(float v);
void edit_error(char *s1,char *s2)
void check_file(char *file);
void check_dir(char *dir);
void read_config(char *dir, int *Nlig, int *Ncol, char *PolarCase, char *PolarType);
void write_config(char *dir, int Nlig, int Ncol, char *PolarCase, char *PolarType);
void my_randomize (void);
float my_random (float num);
float my_eps_random (void);

struct cplx;
cplx  cadd(cplx a,cplx b);
cplx  csub(cplx a,cplx b);
cplx  cmul(cplx a,cplx b);
cplx  cdiv(cplx a,cplx b);
cplx  cpwr(cplx a,float b);
cplx  cconj(cplx a);
float  cimg(cplx a);
float  crel(cplx a);
float  cmod(cplx a);
float  cmod2(cplx a);
float  angle(cplx a);
cplx  cplx_sinc(cplx a);

int PolTypeConfig(char *PolType, int *NpolarIn, char *PolTypeIn, int *NpolarOut, char *PolTypeOut, char *PolarType)
int init_file_name(char *PolType, char *Dir, char **FileName);
int memory_alloc(char *filememerr, int Nlig, int Nwin, int *NbBlock, int *NligBlock, int NBlockA, int NBlockB, int MemoryAlloc)
int PrintfLine(int lig, int NNlig);
int CreateUsageHelpDataFormat(char *PolTypeConf); 
int CreateUsageHelpDataFormatInput(char *PolTypeConf);
int init_matrix_block(int NNcol, int NNpolar, int NNwinLig, int NNwinCol);
int block_alloc(int *NNligBlock, int SSubSampLig, int NNLookLig, int SSub_Nlig, int *NNbBlock);

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <time.h>

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

#include "PolSARproLib.h"

/********************************************************************
Structure: Create_Pix
Authors  : Laurent FERRO-FAMIL
Creation : 07/2003
Update  :
*--------------------------------------------------------------------
Description :
********************************************************************/
struct Pix *Create_Pix(struct Pix *P, float x, float y)
{
  if (P == NULL) {
  P = (struct Pix *) malloc(sizeof(struct Pix));
  P->x = x;
  P->y = y;
  P->next = NULL;
  } else
  edit_error("Error Create Pix", "");
  return P;
}

/********************************************************************
Structure: Remove_Pix
Authors  : Laurent FERRO-FAMIL
Creation : 07/2003
Update  :
*--------------------------------------------------------------------
Description :
********************************************************************/
struct Pix *Remove_Pix(struct Pix *P_top, struct Pix *P)
{
  struct Pix *P_current;

  if (P == NULL)
  edit_error("Error Create Pix", "");
  if (P == P_top) {
  P_current = P_top;
  P = P->next;
  free((struct Pix *) P_current);
  } else {
  if (P->next == NULL) {
    P_current = P_top;
    while (P_current->next != P)
    P_current = P_current->next;
    P = P_current;
    P_current = P_current->next;
    free((struct Pix *) P_current);

  } else {
    P_current = P_top;
    while (P_current->next != P)
    P_current = P_current->next;
    P = P_current;
    P_current = P_current->next;
    P->next = P_current->next;
    free((struct Pix *) P_current);
  }
  }
  P_current = NULL;
  return P;
}

/********************************************************************
Routine  : my_round
Authors  : Laurent FERRO-FAMIL
Creation : 07/2003
Update  : 12/2006 (Stephane MERIC)
*--------------------------------------------------------------------
Description : Round function
********************************************************************/
float my_round(float v)
{
#if defined(__sun) || defined(__sun__)
  static inline float floorf (float x) { return floor (x);}
#endif

#ifndef _WIN32
  return (floorf(v + 0.5));
#endif
#ifdef _WIN32
  return (floor(v + 0.5));
#endif

}

/********************************************************************
Routine  : edit_error
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*--------------------------------------------------------------------
Description :  Displays an error message and exits the program
********************************************************************/
void edit_error(char *s1, char *s2)
{
  printf("\n A processing error occured ! \n %s%s\n", s1, s2);
  exit(1);
}

/********************************************************************
Routine  : check_file
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*--------------------------------------------------------------------
Description :  Checks and corrects slashes in file string
********************************************************************/
void check_file(char *file)
{
#ifdef _WIN32
  int i;
  i = 0;
  while (file[i] != '\0') {
  if (file[i] == '/')
    file[i] = '\\';
  i++;
  }
#endif
}

/********************************************************************
Routine  : check_dir
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*--------------------------------------------------------------------
Description :  Checks and corrects slashes in directory string
********************************************************************/
void check_dir(char *dir)
{
#ifndef _WIN32
  strcat(dir, "/");
#else
  int i;
  i = 0;
  while (dir[i] != '\0') {
  if (dir[i] == '/')
    dir[i] = '\\';
  i++;
  }
  strcat(dir, "\\");
#endif
}

/********************************************************************
Routine  : read_config
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*--------------------------------------------------------------------
Description :  Read a configuration file
********************************************************************/
void read_config(char *dir, int *Nlig, int *Ncol, char *PolarCase, char *PolarType)
{
  char file_name[FilePathLength];
  char Tmp[FilePathLength];
  FILE *file;

  sprintf(file_name, "%sconfig.txt", dir);
  if ((file = fopen(file_name, "r")) == NULL)
  edit_error("Could not open configuration file : ", file_name);

  fscanf(file, "%s\n", Tmp);
  fscanf(file, "%i\n", &*Nlig);
  fscanf(file, "%s\n", Tmp);
  fscanf(file, "%s\n", Tmp);
  fscanf(file, "%i\n", &*Ncol);
  fscanf(file, "%s\n", Tmp);
  fscanf(file, "%s\n", Tmp);
  fscanf(file, "%s\n", PolarCase);
  fscanf(file, "%s\n", Tmp);
  fscanf(file, "%s\n", Tmp);
  fscanf(file, "%s\n", PolarType);

  fclose(file);
}

/********************************************************************
Routine  : write_config
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*--------------------------------------------------------------------
Description :  Writes a configuration file
********************************************************************/
void write_config(char *dir, int Nlig, int Ncol, char *PolarCase, char *PolarType)
{
  char file_name[FilePathLength];
  FILE *file;

  sprintf(file_name, "%sconfig.txt", dir);
  if ((file = fopen(file_name, "w")) == NULL)
  edit_error("Could not open configuration file : ", file_name);

  fprintf(file, "Nrow\n");
  fprintf(file, "%i\n", Nlig);
  fprintf(file, "---------\n");
  fprintf(file, "Ncol\n");
  fprintf(file, "%i\n", Ncol);
  fprintf(file, "---------\n");
  fprintf(file, "PolarCase\n");
  fprintf(file, "%s\n", PolarCase);
  fprintf(file, "---------\n");
  fprintf(file, "PolarType\n");
  fprintf(file, "%s\n", PolarType);
  fclose(file);
}

/********************************************************************
Routine  : my_randomize
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*--------------------------------------------------------------------
Description :  Initialisation of the Random generator
********************************************************************/
void my_randomize(void)
{
  srand((unsigned) time(NULL));
}

/********************************************************************
Routine  : my_random
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*--------------------------------------------------------------------
Description :  Random value
********************************************************************/
float my_random(float num)
{
  float res;
  res = (float) ((rand() * num) / (RAND_MAX + 1.0));
  return (res);
}

/********************************************************************
Routine  : my_eps_random
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*--------------------------------------------------------------------
Description :  eps/20 < Random value < 19*eps / 20
********************************************************************/
float my_eps_random(void)
{
  float res;
  res = (float) ((rand() * 1.0) / (RAND_MAX + 1.0));
  res = eps * (1. + 9. * res) / 10.;
  res = res - eps / 20.;
  return (res);
}

/********************************************************************
Routine  : cconj
Authors  : Laurent FERRO-FAMIL
Creation : 08/2005
Update  :
*--------------------------------------------------------------------
Description :  Complex Conjugate
********************************************************************/
cplx cconj(cplx a)
{
  cplx res;

  res.re= a.re;
  res.im=-a.im;

  return(res);
}

/********************************************************************
Routine  : cadd
Authors  : Laurent FERRO-FAMIL
Creation : 08/2005
Update  :
*--------------------------------------------------------------------
Description :  Complex Addition
********************************************************************/
cplx cadd(cplx a,cplx b)
{
  cplx res;

  res.re=a.re+b.re;
  res.im=a.im+b.im;

  return(res);
}

/********************************************************************
Routine  : csub
Authors  : Laurent FERRO-FAMIL
Creation : 08/2005
Update  :
*--------------------------------------------------------------------
Description :  Complex Substraction
********************************************************************/
cplx csub(cplx a,cplx b)
{
  cplx res;

  res.re=a.re-b.re;
  res.im=a.im-b.im;

  return(res);
}

/********************************************************************
Routine  : cmul
Authors  : Laurent FERRO-FAMIL
Creation : 08/2005
Update  :
*--------------------------------------------------------------------
Description :  Complex Multiplication
********************************************************************/
cplx cmul(cplx a,cplx b)
{
  cplx res;

  res.re=a.re*b.re-a.im*b.im;
  res.im=a.re*b.im+a.im*b.re;

  return(res);
}

/********************************************************************
Routine  : cdiv
Authors  : Laurent FERRO-FAMIL
Creation : 08/2005
Update  :
*--------------------------------------------------------------------
Description :  Complex Division
********************************************************************/
cplx cdiv(cplx a,cplx b)
{
  cplx res;
  float val;

  if ((val=cmod(b))<eps)
 {
  b.re = eps;
  b.im = eps;
 }  

  res=cmul(a,cconj(b));
  res.re=res.re /(val*val);
  res.im=res.im /(val*val);

  return(res);
}

/********************************************************************
Routine  : cpwr
Authors  : Eric POTTIER
Creation : 08/2014
Update  :
*--------------------------------------------------------------------
Description :  Complex raised to a power
********************************************************************/
cplx cpwr(cplx a,float b)
{
  cplx res;
  float ro, teta;

  ro = cmod(a);
  teta = angle(a);
  
  res.re=pow(ro,b)*cos(teta*b);
  res.im=pow(ro,b)*sin(teta*b);

  return(res);
}

/********************************************************************
Routine  : cimg
Authors  : Laurent FERRO-FAMIL
Creation : 08/2005
Update  :
*--------------------------------------------------------------------
Description :  Imaginary Part of a Complex Number
********************************************************************/
float cimg(cplx a)
{
  return(a.im);
}

/********************************************************************
Routine  : crel
Authors  : Laurent FERRO-FAMIL
Creation : 08/2005
Update  :
*--------------------------------------------------------------------
Description :  Real Part of a Complex Number
********************************************************************/
float crel(cplx a)
{
  return(a.re);
}

/********************************************************************
Routine  : cmod
Authors  : Laurent FERRO-FAMIL
Creation : 08/2005
Update  :
*--------------------------------------------------------------------
Description :  Complex Modulus
********************************************************************/
float cmod(cplx a)
{
  float res;

  res=sqrt(a.re*a.re+a.im*a.im);

  return(res);
}

/********************************************************************
Routine  : cmod2
Authors  : Laurent FERRO-FAMIL
Creation : 08/2005
Update  :
*--------------------------------------------------------------------
Description :  Complex Modulus
********************************************************************/
float cmod2(cplx a)
{
  float res;

  res=(a.re*a.re+a.im*a.im);

  return(res);
}

/********************************************************************
Routine  : angle
Authors  : Laurent FERRO-FAMIL
Creation : 08/2005
Update  :
*--------------------------------------------------------------------
Description :  Argument of a Complex
********************************************************************/
float angle(cplx a)
{
  float ang;

  if((fabs(a.re)<eps)&&(fabs(a.im)<eps))
    ang=0;
  else
    ang=atan2(a.im,a.re);

  return(ang);
}

/********************************************************************
Routine  : cplx_sinc
Authors  : Laurent FERRO-FAMIL
Creation : 08/2005
Update  :
*--------------------------------------------------------------------
Description : Sinc Function of a Complex
********************************************************************/
cplx cplx_sinc(cplx a)
{
  cplx cplx_dum1,cplx_dum2,res;

  cplx_dum1.re= exp(-a.im)*cos(a.re); cplx_dum1.im= exp(-a.im)*sin(a.re);
  cplx_dum2.re= exp(a.im)*cos(a.re); cplx_dum2.im= -exp(a.im)*sin(a.re);

  cplx_dum1= csub(cplx_dum1,cplx_dum2);
  cplx_dum2.re= 0.0; cplx_dum2.im= -1.0/2.0;

  cplx_dum1= cmul(cplx_dum1,cplx_dum2);

  res= cdiv(cplx_dum1,a);

  return(res);
}

/********************************************************************
Routine  : PolTypeConfig
Authors  : Eric POTTIER
Creation : 08/2010
Update  :
*--------------------------------------------------------------------
Description :  Check the polarimetric format configuration
********************************************************************/
int PolTypeConfig(char *PolType, int *NpolarIn, char *PolTypeIn, int *NpolarOut, char *PolTypeOut, char *PolarType)
{
  int Config, ii;  
  char PolTypeTmp[20];
  char *PolTypeConfig[92] = {"C2", "C2T2","C3", "C3T3", "C4", "C4T4", "C4C3", "C4T3", 
               "T2", "T2C2", "T3", "T3C3", "T4", "T4C4", "T4C3", "T4T3", "T6", 
               "S2SPPpp1", "S2SPPpp2", "S2SPPpp3", "S2IPPpp4", 
               "S2IPPpp5", "S2IPPpp6", "S2IPPpp7", "S2IPPfull", "S2", "S2C3", 
               "S2C4", "S2T3", "S2T4", "S2T6", "SPP", "SPPC2", "SPPT2","SPPT4",
               "SPPIPP", "IPP", "Ixx",
               "S2C2pp1", "S2C2pp2", "S2C2pp3",
               "S2SPPlhv", "S2SPPrhv", "S2SPPpi4",
               "S2C2lhv", "S2C2rhv", "S2C2pi4",
               "C2IPPpp5", "C2IPPpp6", "C2IPPpp7",
               "C3C2pp1", "C3C2pp2", "C3C2pp3",
               "C3C2lhv", "C3C2rhv", "C3C2pi4",
               "C3IPPpp4", "C3IPPpp5", "C3IPPpp6", "C3IPPpp7",
               "C4C2pp1", "C4C2pp2", "C4C2pp3",
               "C4C2lhv", "C4C2rhv", "C4C2pi4",
               "C4IPPpp4", "C4IPPpp5", "C4IPPpp6", "C4IPPpp7", "C4IPPfull",
               "T3C2pp1", "T3C2pp2", "T3C2pp3",
               "T3C2lhv", "T3C2rhv", "T3C2pi4",
               "T3IPPpp4", "T3IPPpp5", "T3IPPpp6", "T3IPPpp7",
               "T4C2pp1", "T4C2pp2", "T4C2pp3",
               "T4C2lhv", "T4C2rhv", "T4C2pi4",
               "T4IPPpp4", "T4IPPpp5", "T4IPPpp6", "T4IPPpp7", "T4IPPfull"
               };
  Config = 0;
  for (ii=0; ii<87; ii++) if (strcmp(PolTypeConfig[ii],PolType) == 0) Config = 1;
  if (Config == 0) edit_error("Wrong Input / Output Polarimetric Data Format\n","UsageHelpDataFormat");

  strcpy(PolTypeTmp,PolType);

  if (strcmp(PolTypeTmp,"C2") == 0) { 
    *NpolarIn = 4; *NpolarOut = 4;
    strcpy(PolTypeIn,"C2"); strcpy(PolTypeOut,"C2"); }
    
  if (strcmp(PolTypeTmp,"C2T2") == 0) { 
    *NpolarIn = 4; *NpolarOut = 4;
    strcpy(PolType,"C2"); strcpy(PolTypeIn,"C2"); strcpy(PolTypeOut,"T2"); }

  if (strcmp(PolTypeTmp,"C2IPPpp5") == 0) { 
    *NpolarIn = 4; *NpolarOut = 2;
    strcpy(PolType,"C2"); strcpy(PolTypeIn,"C2"); strcpy(PolTypeOut,"IPPpp5"); }

  if (strcmp(PolTypeTmp,"C2IPPpp6") == 0) { 
    *NpolarIn = 4; *NpolarOut = 2;
    strcpy(PolTypeTmp,"C2"); strcpy(PolTypeIn,"C2"); strcpy(PolTypeOut,"IPPpp6"); }

  if (strcmp(PolTypeTmp,"C2IPPpp7") == 0) { 
    *NpolarIn = 4; *NpolarOut = 2;
    strcpy(PolType,"C2"); strcpy(PolTypeIn,"C2"); strcpy(PolTypeOut,"IPPpp7"); }

  if (strcmp(PolTypeTmp,"C3") == 0) { 
    *NpolarIn = 9; *NpolarOut = 9;
    strcpy(PolTypeIn,"C3"); strcpy(PolTypeOut,"C3"); }

  if (strcmp(PolTypeTmp,"C3T3") == 0) { 
    *NpolarIn = 9; *NpolarOut = 9;
    strcpy(PolType,"C3"); strcpy(PolTypeIn,"C3"); strcpy(PolTypeOut,"T3"); }
    
  if (strcmp(PolTypeTmp,"C3C2pp1") == 0) { 
    *NpolarIn = 9; *NpolarOut = 4;
    strcpy(PolType,"C3"); strcpy(PolTypeIn,"C3"); strcpy(PolTypeOut,"C2pp1"); }

  if (strcmp(PolTypeTmp,"C3C2pp2") == 0) { 
    *NpolarIn = 9; *NpolarOut = 4;
    strcpy(PolType,"C3"); strcpy(PolTypeIn,"C3"); strcpy(PolTypeOut,"C2pp2"); }

  if (strcmp(PolTypeTmp,"C3C2pp3") == 0) { 
    *NpolarIn = 9; *NpolarOut = 4;
    strcpy(PolType,"C3"); strcpy(PolTypeIn,"C3"); strcpy(PolTypeOut,"C2pp3"); }
    
  if (strcmp(PolTypeTmp,"C3C2lhv") == 0) { 
    *NpolarIn = 9; *NpolarOut = 4;
    strcpy(PolType,"C3"); strcpy(PolTypeIn,"C3"); strcpy(PolTypeOut,"C2lhv"); }

  if (strcmp(PolTypeTmp,"C3C2rhv") == 0) { 
    *NpolarIn = 9; *NpolarOut = 4;
    strcpy(PolType,"C3"); strcpy(PolTypeIn,"C3"); strcpy(PolTypeOut,"C2rhv"); }

  if (strcmp(PolTypeTmp,"C3C2pi4") == 0) { 
    *NpolarIn = 9; *NpolarOut = 4;
    strcpy(PolType,"C3"); strcpy(PolTypeIn,"C3"); strcpy(PolTypeOut,"C2pi4"); }
    
  if (strcmp(PolTypeTmp,"C3IPPpp4") == 0) { 
    *NpolarIn = 9; *NpolarOut = 3;
    strcpy(PolType,"C3"); strcpy(PolTypeIn,"C3"); strcpy(PolTypeOut,"IPPpp4"); }

  if (strcmp(PolTypeTmp,"C3IPPpp5") == 0) { 
    *NpolarIn = 9; *NpolarOut = 2;
    strcpy(PolType,"C3"); strcpy(PolTypeIn,"C3"); strcpy(PolTypeOut,"IPPpp5"); }

  if (strcmp(PolTypeTmp,"C3IPPpp6") == 0) { 
    *NpolarIn = 9; *NpolarOut = 2;
    strcpy(PolType,"C3"); strcpy(PolTypeIn,"C3"); strcpy(PolTypeOut,"IPPpp6"); }

  if (strcmp(PolTypeTmp,"C3IPPpp7") == 0) { 
    *NpolarIn = 9; *NpolarOut = 2;
    strcpy(PolType,"C3"); strcpy(PolTypeIn,"C3"); strcpy(PolTypeOut,"IPPpp7"); }
 
  if (strcmp(PolTypeTmp,"C4") == 0) { 
    *NpolarIn = 16; *NpolarOut = 16;
    strcpy(PolTypeIn,"C4"); strcpy(PolTypeOut,"C4"); }

  if (strcmp(PolTypeTmp,"C4T4") == 0) { 
    *NpolarIn = 16; *NpolarOut = 16;
    strcpy(PolType,"C4"); strcpy(PolTypeIn,"C4"); strcpy(PolTypeOut,"T4"); }

  if (strcmp(PolTypeTmp,"C4C3") == 0) { 
    *NpolarIn = 16; *NpolarOut = 9;
    strcpy(PolType,"C4"); strcpy(PolTypeIn,"C4"); strcpy(PolTypeOut,"C3"); }

  if (strcmp(PolTypeTmp,"C4T3") == 0) { 
    *NpolarIn = 16; *NpolarOut = 9;
    strcpy(PolType,"C4"); strcpy(PolTypeIn,"C4"); strcpy(PolTypeOut,"T3"); }

  if (strcmp(PolTypeTmp,"C4C2pp1") == 0) { 
    *NpolarIn = 16; *NpolarOut = 4;
    strcpy(PolType,"C4"); strcpy(PolTypeIn,"C4"); strcpy(PolTypeOut,"C2pp1"); }

  if (strcmp(PolTypeTmp,"C4C2pp2") == 0) { 
    *NpolarIn = 16; *NpolarOut = 4;
    strcpy(PolType,"C4"); strcpy(PolTypeIn,"C4"); strcpy(PolTypeOut,"C2pp2"); }

  if (strcmp(PolTypeTmp,"C4C2pp3") == 0) { 
    *NpolarIn = 16; *NpolarOut = 4;
    strcpy(PolType,"C4"); strcpy(PolTypeIn,"C4"); strcpy(PolTypeOut,"C2pp3"); }

  if (strcmp(PolTypeTmp,"C4C2lhv") == 0) { 
    *NpolarIn = 16; *NpolarOut = 4;
    strcpy(PolType,"C4"); strcpy(PolTypeIn,"C4"); strcpy(PolTypeOut,"C2lhv"); }

  if (strcmp(PolTypeTmp,"C4C2rhv") == 0) { 
    *NpolarIn = 16; *NpolarOut = 4;
    strcpy(PolType,"C4"); strcpy(PolTypeIn,"C4"); strcpy(PolTypeOut,"C2rhv"); }

  if (strcmp(PolTypeTmp,"C4C2pi4") == 0) { 
    *NpolarIn = 16; *NpolarOut = 4;
    strcpy(PolType,"C4"); strcpy(PolTypeIn,"C4"); strcpy(PolTypeOut,"C2pi4"); }

  if (strcmp(PolTypeTmp,"C4IPPpp4") == 0) { 
    *NpolarIn = 16; *NpolarOut = 3;
    strcpy(PolType,"C4"); strcpy(PolTypeIn,"C4"); strcpy(PolTypeOut,"IPPpp4"); }

  if (strcmp(PolTypeTmp,"C4IPPpp5") == 0) { 
    *NpolarIn = 16; *NpolarOut = 2;
    strcpy(PolType,"C4"); strcpy(PolTypeIn,"C4"); strcpy(PolTypeOut,"IPPpp5"); }

  if (strcmp(PolTypeTmp,"C4IPPpp6") == 0) { 
    *NpolarIn = 16; *NpolarOut = 2;
    strcpy(PolType,"C4"); strcpy(PolTypeIn,"C4"); strcpy(PolTypeOut,"IPPpp6"); }

  if (strcmp(PolTypeTmp,"C4IPPpp7") == 0) { 
    *NpolarIn = 16; *NpolarOut = 2;
    strcpy(PolType,"C4"); strcpy(PolTypeIn,"C4"); strcpy(PolTypeOut,"IPPpp7"); }

  if (strcmp(PolTypeTmp,"C4IPPfull") == 0) { 
    *NpolarIn = 16; *NpolarOut = 4;
    strcpy(PolType,"C4"); strcpy(PolTypeIn,"C4"); strcpy(PolTypeOut,"IPPfull"); }

  if (strcmp(PolTypeTmp,"T2") == 0) { 
    *NpolarIn = 4; *NpolarOut = 4;
    strcpy(PolTypeIn,"T2"); strcpy(PolTypeOut,"T2"); }

  if (strcmp(PolTypeTmp,"T2C2") == 0) { 
    *NpolarIn = 4; *NpolarOut = 4;
    strcpy(PolType,"T2"); strcpy(PolTypeIn,"T2"); strcpy(PolTypeOut,"C2"); }

  if (strcmp(PolTypeTmp,"T3") == 0) { 
    *NpolarIn = 9; *NpolarOut = 9;
    strcpy(PolTypeIn,"T3"); strcpy(PolTypeOut,"T3"); }

  if (strcmp(PolTypeTmp,"T3C3") == 0) { 
    *NpolarIn = 9; *NpolarOut = 9;
    strcpy(PolType,"T3"); strcpy(PolTypeIn,"T3"); strcpy(PolTypeOut,"C3"); }

  if (strcmp(PolTypeTmp,"T3C2pp1") == 0) { 
    *NpolarIn = 9; *NpolarOut = 4;
    strcpy(PolType,"T3"); strcpy(PolTypeIn,"T3"); strcpy(PolTypeOut,"C2pp1"); }

  if (strcmp(PolTypeTmp,"T3C2pp2") == 0) { 
    *NpolarIn = 9; *NpolarOut = 4;
    strcpy(PolType,"T3"); strcpy(PolTypeIn,"T3"); strcpy(PolTypeOut,"C2pp2"); }

  if (strcmp(PolTypeTmp,"T3C2pp3") == 0) { 
    *NpolarIn = 9; *NpolarOut = 4;
    strcpy(PolType,"T3"); strcpy(PolTypeIn,"T3"); strcpy(PolTypeOut,"C2pp3"); }

  if (strcmp(PolTypeTmp,"T3C2lhv") == 0) { 
    *NpolarIn = 9; *NpolarOut = 4;
    strcpy(PolType,"T3"); strcpy(PolTypeIn,"T3"); strcpy(PolTypeOut,"C2lhv"); }

  if (strcmp(PolTypeTmp,"T3C2rhv") == 0) { 
    *NpolarIn = 9; *NpolarOut = 4;
    strcpy(PolType,"T3"); strcpy(PolTypeIn,"T3"); strcpy(PolTypeOut,"C2rhv"); }

  if (strcmp(PolTypeTmp,"T3C2pi4") == 0) { 
    *NpolarIn = 9; *NpolarOut = 4;
    strcpy(PolType,"T3"); strcpy(PolTypeIn,"T3"); strcpy(PolTypeOut,"C2pi4"); }

  if (strcmp(PolTypeTmp,"T3IPPpp4") == 0) { 
    *NpolarIn = 9; *NpolarOut = 3;
    strcpy(PolType,"T3"); strcpy(PolTypeIn,"T3"); strcpy(PolTypeOut,"IPPpp4"); }

  if (strcmp(PolTypeTmp,"T3IPPpp5") == 0) { 
    *NpolarIn = 9; *NpolarOut = 2;
    strcpy(PolType,"T3"); strcpy(PolTypeIn,"T3"); strcpy(PolTypeOut,"IPPpp5"); }

  if (strcmp(PolTypeTmp,"T3IPPpp6") == 0) { 
    *NpolarIn = 9; *NpolarOut = 2;
    strcpy(PolType,"T3"); strcpy(PolTypeIn,"T3"); strcpy(PolTypeOut,"IPPpp6"); }

  if (strcmp(PolTypeTmp,"T3IPPpp7") == 0) { 
    *NpolarIn = 9; *NpolarOut = 2;
    strcpy(PolType,"T3"); strcpy(PolTypeIn,"T3"); strcpy(PolTypeOut,"IPPpp7"); }

  if (strcmp(PolTypeTmp,"T4") == 0) { 
    *NpolarIn = 16; *NpolarOut = 16;
    strcpy(PolTypeIn,"T4"); strcpy(PolTypeOut,"T4"); }

  if (strcmp(PolTypeTmp,"T4C4") == 0) { 
    *NpolarIn = 16; *NpolarOut = 16;
    strcpy(PolType,"T4"); strcpy(PolTypeIn,"T4"); strcpy(PolTypeOut,"C4"); }

  if (strcmp(PolTypeTmp,"T4C3") == 0) { 
    *NpolarIn = 16; *NpolarOut = 9;
    strcpy(PolType,"T4"); strcpy(PolTypeIn,"T4"); strcpy(PolTypeOut,"C3"); }

  if (strcmp(PolTypeTmp,"T4T3") == 0) { 
    *NpolarIn = 16; *NpolarOut = 9;
    strcpy(PolType,"T4"); strcpy(PolTypeIn,"T4"); strcpy(PolTypeOut,"T3"); }

  if (strcmp(PolTypeTmp,"T4C2pp1") == 0) { 
    *NpolarIn = 16; *NpolarOut = 4;
    strcpy(PolType,"T4"); strcpy(PolTypeIn,"T4"); strcpy(PolTypeOut,"C2pp1"); }

  if (strcmp(PolTypeTmp,"T4C2pp2") == 0) { 
    *NpolarIn = 16; *NpolarOut = 4;
    strcpy(PolType,"T4"); strcpy(PolTypeIn,"T4"); strcpy(PolTypeOut,"C2pp2"); }

  if (strcmp(PolTypeTmp,"T4C2pp3") == 0) { 
    *NpolarIn = 16; *NpolarOut = 4;
    strcpy(PolType,"T4"); strcpy(PolTypeIn,"T4"); strcpy(PolTypeOut,"C2pp3"); }

  if (strcmp(PolTypeTmp,"T4C2lhv") == 0) { 
    *NpolarIn = 16; *NpolarOut = 4;
    strcpy(PolType,"T4"); strcpy(PolTypeIn,"T4"); strcpy(PolTypeOut,"C2lhv"); }

  if (strcmp(PolTypeTmp,"T4C2rhv") == 0) { 
    *NpolarIn = 16; *NpolarOut = 4;
    strcpy(PolType,"T4"); strcpy(PolTypeIn,"T4"); strcpy(PolTypeOut,"C2rhv"); }

  if (strcmp(PolTypeTmp,"T4C2pi4") == 0) { 
    *NpolarIn = 16; *NpolarOut = 4;
    strcpy(PolType,"T4"); strcpy(PolTypeIn,"T4"); strcpy(PolTypeOut,"C2pi4"); }

  if (strcmp(PolTypeTmp,"T4IPPpp4") == 0) { 
    *NpolarIn = 16; *NpolarOut = 3;
    strcpy(PolType,"T4"); strcpy(PolTypeIn,"T4"); strcpy(PolTypeOut,"IPPpp4"); }

  if (strcmp(PolTypeTmp,"T4IPPpp5") == 0) { 
    *NpolarIn = 16; *NpolarOut = 2;
    strcpy(PolType,"T4"); strcpy(PolTypeIn,"T4"); strcpy(PolTypeOut,"IPPpp5"); }

  if (strcmp(PolTypeTmp,"T4IPPpp6") == 0) { 
    *NpolarIn = 16; *NpolarOut = 2;
    strcpy(PolType,"T4"); strcpy(PolTypeIn,"T4"); strcpy(PolTypeOut,"IPPpp6"); }

  if (strcmp(PolTypeTmp,"T4IPPpp7") == 0) { 
    *NpolarIn = 16; *NpolarOut = 2;
    strcpy(PolType,"T4"); strcpy(PolTypeIn,"T4"); strcpy(PolTypeOut,"IPPpp7"); }

  if (strcmp(PolTypeTmp,"T4IPPfull") == 0) { 
    *NpolarIn = 16; *NpolarOut = 4;
    strcpy(PolType,"T4"); strcpy(PolTypeIn,"T4"); strcpy(PolTypeOut,"IPPfull"); }

  if (strcmp(PolTypeTmp,"T6") == 0) { 
    *NpolarIn = 36; *NpolarOut = 36;
    strcpy(PolTypeIn,"T6"); strcpy(PolTypeOut,"T6"); }

  if (strcmp(PolTypeTmp,"S2SPPpp1") == 0) { 
    *NpolarIn = 4; *NpolarOut = 2;
    strcpy(PolType,"S2"); strcpy(PolTypeIn,"S2"); strcpy(PolTypeOut,"SPPpp1"); }

  if (strcmp(PolTypeTmp,"S2SPPpp2") == 0) { 
    *NpolarIn = 4; *NpolarOut = 2;
    strcpy(PolType,"S2"); strcpy(PolTypeIn,"S2"); strcpy(PolTypeOut,"SPPpp2"); }

  if (strcmp(PolTypeTmp,"S2SPPpp3") == 0) { 
    *NpolarIn = 4; *NpolarOut = 2; 
    strcpy(PolType,"S2"); strcpy(PolTypeIn,"S2"); strcpy(PolTypeOut,"SPPpp3"); }

  if (strcmp(PolTypeTmp,"S2C2pp1") == 0) { 
    *NpolarIn = 4; *NpolarOut = 4;
    strcpy(PolType,"S2"); strcpy(PolTypeIn,"S2"); strcpy(PolTypeOut,"C2pp1"); }

  if (strcmp(PolTypeTmp,"S2C2pp2") == 0) { 
    *NpolarIn = 4; *NpolarOut = 4;
    strcpy(PolType,"S2"); strcpy(PolTypeIn,"S2"); strcpy(PolTypeOut,"C2pp2"); }

  if (strcmp(PolTypeTmp,"S2C2pp3") == 0) { 
    *NpolarIn = 4; *NpolarOut = 4; 
    strcpy(PolType,"S2"); strcpy(PolTypeIn,"S2"); strcpy(PolTypeOut,"C2pp3"); }

  if (strcmp(PolTypeTmp,"S2SPPlhv") == 0) { 
    *NpolarIn = 4; *NpolarOut = 2;
    strcpy(PolType,"S2"); strcpy(PolTypeIn,"S2"); strcpy(PolTypeOut,"SPPlhv"); }

  if (strcmp(PolTypeTmp,"S2SPPrhv") == 0) { 
    *NpolarIn = 4; *NpolarOut = 2;
    strcpy(PolType,"S2"); strcpy(PolTypeIn,"S2"); strcpy(PolTypeOut,"SPPrhv"); }

  if (strcmp(PolTypeTmp,"S2SPPpi4") == 0) { 
    *NpolarIn = 4; *NpolarOut = 2; 
    strcpy(PolType,"S2"); strcpy(PolTypeIn,"S2"); strcpy(PolTypeOut,"SPPpi4"); }

  if (strcmp(PolTypeTmp,"S2C2lhv") == 0) { 
    *NpolarIn = 4; *NpolarOut = 4;
    strcpy(PolType,"S2"); strcpy(PolTypeIn,"S2"); strcpy(PolTypeOut,"C2lhv"); }

  if (strcmp(PolTypeTmp,"S2C2rhv") == 0) { 
    *NpolarIn = 4; *NpolarOut = 4;
    strcpy(PolType,"S2"); strcpy(PolTypeIn,"S2"); strcpy(PolTypeOut,"C2rhv"); }

  if (strcmp(PolTypeTmp,"S2C2pi4") == 0) { 
    *NpolarIn = 4; *NpolarOut = 4; 
    strcpy(PolType,"S2"); strcpy(PolTypeIn,"S2"); strcpy(PolTypeOut,"C2pi4"); }

  if (strcmp(PolTypeTmp,"S2IPPpp4") == 0) { 
    *NpolarIn = 4; *NpolarOut = 3;
    strcpy(PolType,"S2"); strcpy(PolTypeIn,"S2"); strcpy(PolTypeOut,"IPPpp4"); }

  if (strcmp(PolTypeTmp,"S2IPPpp5") == 0) { 
    *NpolarIn = 4; *NpolarOut = 2;
    strcpy(PolType,"S2"); strcpy(PolTypeIn,"S2"); strcpy(PolTypeOut,"IPPpp5"); }

  if (strcmp(PolTypeTmp,"S2IPPpp6") == 0) { 
    *NpolarIn = 4; *NpolarOut = 2; 
    strcpy(PolType,"S2"); strcpy(PolTypeIn,"S2"); strcpy(PolTypeOut,"IPPpp6"); }

  if (strcmp(PolTypeTmp,"S2IPPpp7") == 0) { 
    *NpolarIn = 4; *NpolarOut = 2;
    strcpy(PolType,"S2"); strcpy(PolTypeIn,"S2"); strcpy(PolTypeOut,"IPPpp7"); }

  if (strcmp(PolTypeTmp,"S2IPPfull") == 0) { 
    *NpolarIn = 4; *NpolarOut = 4;
    strcpy(PolType,"S2"); strcpy(PolTypeIn,"S2"); strcpy(PolTypeOut,"IPPfull"); }

  if (strcmp(PolTypeTmp,"S2") == 0) { 
    *NpolarIn = 4; *NpolarOut = 4;
    strcpy(PolType,"S2"); strcpy(PolTypeIn,"S2"); strcpy(PolTypeOut,"S2"); }

  if (strcmp(PolTypeTmp,"S2C3") == 0) { 
    *NpolarIn = 4; *NpolarOut = 9;
    strcpy(PolType,"S2"); strcpy(PolTypeIn,"S2"); strcpy(PolTypeOut,"C3"); }

  if (strcmp(PolTypeTmp,"S2C4") == 0) { 
    *NpolarIn = 4; *NpolarOut = 16;
    strcpy(PolType,"S2"); strcpy(PolTypeIn,"S2"); strcpy(PolTypeOut,"C4"); }

  if (strcmp(PolTypeTmp,"S2T3") == 0) { 
    *NpolarIn = 4; *NpolarOut = 9;
    strcpy(PolType,"S2"); strcpy(PolTypeIn,"S2"); strcpy(PolTypeOut,"T3"); }

  if (strcmp(PolTypeTmp,"S2T4") == 0) { 
    *NpolarIn = 4; *NpolarOut = 16;
    strcpy(PolType,"S2"); strcpy(PolTypeIn,"S2"); strcpy(PolTypeOut,"T4"); }

  if (strcmp(PolTypeTmp,"S2T6") == 0) { 
    *NpolarIn = 4; *NpolarOut = 36;
    strcpy(PolType,"S2"); strcpy(PolTypeIn,"S2"); strcpy(PolTypeOut,"T6"); }

  if (strcmp(PolTypeTmp,"SPP") == 0) { 
    *NpolarIn = 2; *NpolarOut = 2;
    strcpy(PolType,"SPP");
    strcpy(PolTypeIn,"SPP"); strcat(PolTypeIn, PolarType); strcpy(PolTypeOut,"SPP"); strcat(PolTypeOut, PolarType);}

  if (strcmp(PolTypeTmp,"SPPC2") == 0) { 
    *NpolarIn = 2; *NpolarOut = 4;
    strcpy(PolType,"SPP");
    strcpy(PolTypeIn,"SPP"); strcat(PolTypeIn, PolarType); strcpy(PolTypeOut,"C2"); strcat(PolTypeOut, PolarType);}

  if (strcmp(PolTypeTmp,"SPPT2") == 0) { 
    *NpolarIn = 2; *NpolarOut = 4;
    strcpy(PolType,"SPP");
    strcpy(PolTypeIn,"SPP"); strcat(PolTypeIn, PolarType); strcpy(PolTypeOut,"T2"); strcat(PolTypeOut, PolarType);}

  if (strcmp(PolTypeTmp,"SPPT4") == 0) { 
    *NpolarIn = 2; *NpolarOut = 16;
    strcpy(PolType,"SPP");
    strcpy(PolTypeIn,"SPP"); strcat(PolTypeIn, PolarType); strcpy(PolTypeOut,"T4");}
    
  if (strcmp(PolTypeTmp,"SPPIPP") == 0) { 
    *NpolarIn = 2; *NpolarOut = 2;
    strcpy(PolType,"SPP");
    strcpy(PolTypeIn,"SPP"); strcat(PolTypeIn, PolarType);
    strcpy(PolTypeOut,"IPP"); 
    if (strcmp(PolarType,"pp1") == 0) { strcat(PolTypeOut, "pp5"); }
    if (strcmp(PolarType,"pp2") == 0) { strcat(PolTypeOut, "pp6"); }
    if (strcmp(PolarType,"pp3") == 0) { strcat(PolTypeOut, "pp7"); }
    }

  if (strcmp(PolTypeTmp,"IPP") == 0) { 
    if (strcmp(PolarType,"full") == 0) { *NpolarIn = 4; *NpolarOut = 4; }
    if (strcmp(PolarType,"pp4") == 0) { *NpolarIn = 3; *NpolarOut = 3; }
    if (strcmp(PolarType,"pp5") == 0) { *NpolarIn = 2; *NpolarOut = 2; }
    if (strcmp(PolarType,"pp6") == 0) { *NpolarIn = 2; *NpolarOut = 2; }
    if (strcmp(PolarType,"pp7") == 0) { *NpolarIn = 2; *NpolarOut = 2; }
    strcpy(PolTypeIn,"IPP"); strcat(PolTypeIn, PolarType);
    strcpy(PolTypeOut,"IPP"); strcat(PolTypeOut, PolarType);}

  if (strcmp(PolTypeTmp,"Ixx") == 0) {
    *NpolarIn = 1; *NpolarOut = 1;
    strcpy(PolTypeIn,"Ixx"); strcpy(PolTypeOut,"Ixx"); }
   
  return 1;
}

/********************************************************************
Routine  : init_file_name
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : Initialisation of the binary file names
********************************************************************/
int init_file_name(char *PolType, char *Dir, char **FileName)
{
  int ii;
  char *file_name_C2[4] = 
  {"C11.bin", "C12_real.bin", "C12_imag.bin", "C22.bin" };
  char *file_name_C3[9] = 
  {"C11.bin", "C12_real.bin", "C12_imag.bin",
  "C13_real.bin", "C13_imag.bin", "C22.bin",
  "C23_real.bin", "C23_imag.bin", "C33.bin"};
  char *file_name_C4[16] =
  {"C11.bin", "C12_real.bin", "C12_imag.bin",
  "C13_real.bin", "C13_imag.bin",  "C14_real.bin", "C14_imag.bin", 
  "C22.bin", "C23_real.bin", "C23_imag.bin", "C24_real.bin", "C24_imag.bin",
  "C33.bin", "C34_real.bin", "C34_imag.bin", "C44.bin"};
  
  char *file_name_T2[4] = 
  {"T11.bin", "T12_real.bin", "T12_imag.bin", "T22.bin" };
  char *file_name_T3[9] =
  {"T11.bin", "T12_real.bin", "T12_imag.bin",
  "T13_real.bin", "T13_imag.bin", "T22.bin",
  "T23_real.bin", "T23_imag.bin", "T33.bin"};
  char *file_name_T4[16] =
  {"T11.bin", "T12_real.bin", "T12_imag.bin",
  "T13_real.bin", "T13_imag.bin",  "T14_real.bin", "T14_imag.bin", 
  "T22.bin", "T23_real.bin", "T23_imag.bin", "T24_real.bin", "T24_imag.bin",
  "T33.bin", "T34_real.bin", "T34_imag.bin", "T44.bin"};


  char *file_name_T6[36] = 
  {"T11.bin", "T12_real.bin", "T12_imag.bin", "T13_real.bin", "T13_imag.bin",
  "T14_real.bin", "T14_imag.bin", "T15_real.bin", "T15_imag.bin",
  "T16_real.bin", "T16_imag.bin",
  "T22.bin", "T23_real.bin", "T23_imag.bin", "T24_real.bin", "T24_imag.bin",
  "T25_real.bin", "T25_imag.bin", "T26_real.bin", "T26_imag.bin",
  "T33.bin", "T34_real.bin", "T34_imag.bin",
  "T35_real.bin", "T35_imag.bin", "T36_real.bin", "T36_imag.bin",
  "T44.bin", "T45_real.bin", "T45_imag.bin", "T46_real.bin", "T46_imag.bin",
  "T55.bin", "T56_real.bin", "T56_imag.bin", "T66.bin"};

  char *file_name_S2[4] = 
  {"s11.bin", "s12.bin", "s21.bin", "s22.bin" };

  char *file_name_I[4] = 
  {"I11.bin", "I12.bin", "I21.bin", "I22.bin" };

  if (strcmp(PolType,"C2") == 0) 
    for (ii =0; ii<4; ii++)
      sprintf(&FileName[ii][0], "%s%s", Dir, file_name_C2[ii]);

  if (strcmp(PolType,"C2pp1") == 0) 
    for (ii =0; ii<4; ii++)
      sprintf(&FileName[ii][0], "%s%s", Dir, file_name_C2[ii]);
  if (strcmp(PolType,"C2pp2") == 0) 
    for (ii =0; ii<4; ii++)
      sprintf(&FileName[ii][0], "%s%s", Dir, file_name_C2[ii]);
  if (strcmp(PolType,"C2pp3") == 0) 
    for (ii =0; ii<4; ii++)
      sprintf(&FileName[ii][0], "%s%s", Dir, file_name_C2[ii]);
  if (strcmp(PolType,"C2lhv") == 0) 
    for (ii =0; ii<4; ii++)
      sprintf(&FileName[ii][0], "%s%s", Dir, file_name_C2[ii]);
  if (strcmp(PolType,"C2rhv") == 0) 
    for (ii =0; ii<4; ii++)
      sprintf(&FileName[ii][0], "%s%s", Dir, file_name_C2[ii]);
  if (strcmp(PolType,"C2pi4") == 0) 
    for (ii =0; ii<4; ii++)
      sprintf(&FileName[ii][0], "%s%s", Dir, file_name_C2[ii]);

  if (strcmp(PolType,"C3") == 0) 
    for (ii =0; ii<9; ii++)
      sprintf(&FileName[ii][0], "%s%s", Dir, file_name_C3[ii]);
  if (strcmp(PolType,"C4") == 0) 
    for (ii =0; ii<16; ii++)
      sprintf(&FileName[ii][0], "%s%s", Dir, file_name_C4[ii]);

  if (strcmp(PolType,"T2") == 0)
    for (ii =0; ii<4; ii++)
      sprintf(&FileName[ii][0], "%s%s", Dir, file_name_T2[ii]);

  if (strcmp(PolType,"T2pp1") == 0) 
    for (ii =0; ii<4; ii++)
      sprintf(&FileName[ii][0], "%s%s", Dir, file_name_T2[ii]);
  if (strcmp(PolType,"T2pp2") == 0) 
    for (ii =0; ii<4; ii++)
      sprintf(&FileName[ii][0], "%s%s", Dir, file_name_T2[ii]);
  if (strcmp(PolType,"T2pp3") == 0) 
    for (ii =0; ii<4; ii++)
      sprintf(&FileName[ii][0], "%s%s", Dir, file_name_T2[ii]);
  if (strcmp(PolType,"T2lhv") == 0) 
    for (ii =0; ii<4; ii++)
      sprintf(&FileName[ii][0], "%s%s", Dir, file_name_T2[ii]);
  if (strcmp(PolType,"T2rhv") == 0) 
    for (ii =0; ii<4; ii++)
      sprintf(&FileName[ii][0], "%s%s", Dir, file_name_T2[ii]);
  if (strcmp(PolType,"T2pi4") == 0) 
    for (ii =0; ii<4; ii++)
      sprintf(&FileName[ii][0], "%s%s", Dir, file_name_T2[ii]);

  if (strcmp(PolType,"T3") == 0)
    for (ii =0; ii<9; ii++)
      sprintf(&FileName[ii][0], "%s%s", Dir, file_name_T3[ii]);
  if (strcmp(PolType,"T4") == 0) 
    for (ii =0; ii<16; ii++)
      sprintf(&FileName[ii][0], "%s%s", Dir, file_name_T4[ii]);
  if (strcmp(PolType,"T6") == 0) 
    for (ii =0; ii<36; ii++)
      sprintf(&FileName[ii][0], "%s%s", Dir, file_name_T6[ii]);

  if (strcmp(PolType,"S2") == 0) 
    for (ii =0; ii<4; ii++) 
      sprintf(&FileName[ii][0], "%s%s", Dir, file_name_S2[ii]);

  if (strcmp(PolType, "SPPpp1") == 0) {
    sprintf(&FileName[0][0], "%s%s", Dir, file_name_S2[0]);
    sprintf(&FileName[1][0], "%s%s", Dir, file_name_S2[2]);
    }
  if (strcmp(PolType, "SPPpp2") == 0) {
    sprintf(&FileName[0][0], "%s%s", Dir, file_name_S2[1]);
    sprintf(&FileName[1][0], "%s%s", Dir, file_name_S2[3]);
    }
  if (strcmp(PolType, "SPPpp3") == 0) {
    sprintf(&FileName[0][0], "%s%s", Dir, file_name_S2[0]);
    sprintf(&FileName[1][0], "%s%s", Dir, file_name_S2[3]);
    }

  if (strcmp(PolType, "SPPlhv") == 0) {
    sprintf(&FileName[0][0], "%s%s", Dir, file_name_S2[0]);
    sprintf(&FileName[1][0], "%s%s", Dir, file_name_S2[2]);
    }
  if (strcmp(PolType, "SPPrhv") == 0) {
    sprintf(&FileName[0][0], "%s%s", Dir, file_name_S2[0]);
    sprintf(&FileName[1][0], "%s%s", Dir, file_name_S2[2]);
    }
  if (strcmp(PolType, "SPPpi4") == 0) {
    sprintf(&FileName[0][0], "%s%s", Dir, file_name_S2[0]);
    sprintf(&FileName[1][0], "%s%s", Dir, file_name_S2[2]);
    }

  if (strcmp(PolType,"IPPfull") == 0) 
    for (ii =0; ii<4; ii++)
      sprintf(&FileName[ii][0], "%s%s", Dir, file_name_I[ii]);
  if (strcmp(PolType, "IPPpp4") == 0) {
    sprintf(&FileName[0][0], "%s%s", Dir, file_name_I[0]);
    sprintf(&FileName[1][0], "%s%s", Dir, file_name_I[1]);
    sprintf(&FileName[2][0], "%s%s", Dir, file_name_I[3]);
    }
  if (strcmp(PolType, "IPPpp5") == 0) {
    sprintf(&FileName[0][0], "%s%s", Dir, file_name_I[0]);
    sprintf(&FileName[1][0], "%s%s", Dir, file_name_I[2]);
    }
  if (strcmp(PolType, "IPPpp6") == 0) {
    sprintf(&FileName[0][0], "%s%s", Dir, file_name_I[1]);
    sprintf(&FileName[1][0], "%s%s", Dir, file_name_I[3]);
    }
  if (strcmp(PolType, "IPPpp7") == 0) {
    sprintf(&FileName[0][0], "%s%s", Dir, file_name_I[0]);
    sprintf(&FileName[1][0], "%s%s", Dir, file_name_I[3]);
    }

  return(1);
}

/********************************************************************
Routine  : memory_alloc
Authors  : Eric POTTIER
Creation : 08/2010
Update  :
*--------------------------------------------------------------------
Description : BlockSize and Number of Blocks determination
********************************************************************/
int memory_alloc(char *filememerr, int Nlig, int Nwin, int *NbBlock, int *NligBlock, int NBlockA, int NBlockB, int MemAlloc)
{
  FILE *fileerr;
  int ii, NligBlockSize, NligBlockRem;

  NligBlockSize = (int) floor( (250000 * MemAlloc - NBlockB) / NBlockA);

  if (NligBlockSize <= 1) {
    if ((fileerr = fopen(filememerr, "w")) == NULL) {
      printf("ERROR : NOT ENOUGH MEMORY SPACE\n");
      printf("THE AVALAIBLE PROCESSING MEMORY\n");
      printf("MUST BE HIGHER THAN %i Mb\n", MemAlloc);
      printf("NligBlockSize = %i\n", NligBlockSize);
      edit_error("Could not open configuration file : ", filememerr);
      }
    fprintf(fileerr, "ERROR : NOT ENOUGH MEMORY SPACE\n");
    fprintf(fileerr, "THE AVALAIBLE PROCESSING MEMORY\n");
    fprintf(fileerr, "MUST BE HIGHER THAN %i Mb\n", MemAlloc);
    fclose(fileerr);
    edit_error("ERROR : NOT ENOUGH MEMORY SPACE", "");
    }
  
  if (NligBlockSize >= Nlig) {
    *NbBlock = 1;
    NligBlock[0] = Nlig;
    } else {
    *NbBlock = (int) floor(Nlig / NligBlockSize);
    NligBlockRem = Nlig - (*NbBlock) * NligBlockSize;
    for (ii = 0; ii < (*NbBlock); ii++) NligBlock[ii] = NligBlockSize;
    if ( NligBlockRem < Nwin ) {
      NligBlock[0] += NligBlockRem;
      } else { 
      NligBlock[(*NbBlock)] = NligBlockRem;
      (*NbBlock)++;
      }
    }
  return 1;
}

/********************************************************************
Routine  : PrintfLine
Authors  : Eric POTTIER
Creation : 08/2010
Update  :
*--------------------------------------------------------------------
Description : 
********************************************************************/
int PrintfLine(int lig, int NNlig)
{
if (NNlig > 20) {
   if (lig%(int)(NNlig/20) == 0) {printf("%f\r", 100. * lig / (NNlig - 1));fflush(stdout);}
   } else {
   if (NNlig > 1) {printf("%f\r", 100. * (lig+1) / NNlig);fflush(stdout);}
   }
return 1;
}

/********************************************************************
Routine  : CreateUsageHelpDataFormat
Authors  : Eric POTTIER
Creation : 06/2011
Update  :
*--------------------------------------------------------------------
Description : 
********************************************************************/
int CreateUsageHelpDataFormat(char *PolTypeConf)
{

    if (strcmp(PolTypeConf,"S2") == 0)  		strcat(UsageHelpDataFormat," S2         input : quad-pol S2     output : quad-pol S2\n");
    if (strcmp(PolTypeConf,"S2C3") == 0)		strcat(UsageHelpDataFormat," S2C3       input : quad-pol S2     output : covariance C3\n");
    if (strcmp(PolTypeConf,"S2C4") == 0)		strcat(UsageHelpDataFormat," S2C4       input : quad-pol S2     output : covariance C4\n");
    if (strcmp(PolTypeConf,"S2T3") == 0)		strcat(UsageHelpDataFormat," S2T3       input : quad-pol S2     output : coherency T3\n");
    if (strcmp(PolTypeConf,"S2T4") == 0)		strcat(UsageHelpDataFormat," S2T4       input : quad-pol S2     output : coherency T4\n");
    if (strcmp(PolTypeConf,"S2T6") == 0)		strcat(UsageHelpDataFormat," S2T6       input : 2*quad-pol S2   output : coherency T6\n");

    if (strcmp(PolTypeConf,"S2SPPpp1") == 0)	strcat(UsageHelpDataFormat," S2SPPpp1   input : quad-pol S2     output : dual-pol SPP mode pp1\n");
    if (strcmp(PolTypeConf,"S2SPPpp2") == 0)	strcat(UsageHelpDataFormat," S2SPPpp2   input : quad-pol S2     output : dual-pol SPP mode pp2\n");
    if (strcmp(PolTypeConf,"S2SPPpp3") == 0)	strcat(UsageHelpDataFormat," S2SPPpp3   input : quad-pol S2     output : dual-pol SPP mode pp3\n");

    if (strcmp(PolTypeConf,"S2IPPpp4") == 0)	strcat(UsageHelpDataFormat," S2IPPpp4   input : quad-pol S2     output : intensities IPP mode pp4\n");
    if (strcmp(PolTypeConf,"S2IPPpp5") == 0)	strcat(UsageHelpDataFormat," S2IPPpp5   input : quad-pol S2     output : intensities IPP mode pp5\n");
    if (strcmp(PolTypeConf,"S2IPPpp6") == 0)	strcat(UsageHelpDataFormat," S2IPPpp6   input : quad-pol S2     output : intensities IPP mode pp6\n");
    if (strcmp(PolTypeConf,"S2IPPpp7") == 0)	strcat(UsageHelpDataFormat," S2IPPpp7   input : quad-pol S2     output : intensities IPP mode pp7\n");
    if (strcmp(PolTypeConf,"S2IPPfull") == 0)	strcat(UsageHelpDataFormat," S2IPPfull  input : quad-pol S2     output : intensities IPP mode full\n");

    if (strcmp(PolTypeConf,"S2C2pp1") == 0)		strcat(UsageHelpDataFormat," S2C2pp1    input : quad-pol S2     output : covariance C2 mode pp1\n");
    if (strcmp(PolTypeConf,"S2C2pp2") == 0)		strcat(UsageHelpDataFormat," S2C2pp2    input : quad-pol S2     output : covariance C2 mode pp2\n");
    if (strcmp(PolTypeConf,"S2C2pp3") == 0)		strcat(UsageHelpDataFormat," S2C2pp3    input : quad-pol S2     output : covariance C2 mode pp3\n");

    if (strcmp(PolTypeConf,"S2SPPlhv") == 0)	strcat(UsageHelpDataFormat," S2SPPlhv   input : quad-pol S2     output : dual-pol Compact mode Left-HV\n");
    if (strcmp(PolTypeConf,"S2SPPrhv") == 0)	strcat(UsageHelpDataFormat," S2SPPrhv   input : quad-pol S2     output : dual-pol Compact mode Right-HV\n");
    if (strcmp(PolTypeConf,"S2SPPpi4") == 0)	strcat(UsageHelpDataFormat," S2SPPpi4   input : quad-pol S2     output : dual-pol Compact mode Pi/4\n");

    if (strcmp(PolTypeConf,"S2C2lhv") == 0)		strcat(UsageHelpDataFormat," S2C2lhv    input : quad-pol S2     output : covariance C2 Compact mode Left-HV\n");
    if (strcmp(PolTypeConf,"S2C2rhv") == 0)		strcat(UsageHelpDataFormat," S2C2rhv    input : quad-pol S2     output : covariance C2 Compact mode Right-HV\n");
    if (strcmp(PolTypeConf,"S2C2pi4") == 0)		strcat(UsageHelpDataFormat," S2C2pi4    input : quad-pol S2     output : covariance C2 Compact mode Pi/4\n");

    if (strcmp(PolTypeConf,"C2") == 0)  		strcat(UsageHelpDataFormat," C2         input : covariance C2   output : covariance C2\n");
    if (strcmp(PolTypeConf,"C2IPPpp5") == 0)	strcat(UsageHelpDataFormat," C2IPPpp5   input : covariance C2   output : intensities IPP mode pp5\n");
    if (strcmp(PolTypeConf,"C2IPPpp6") == 0)	strcat(UsageHelpDataFormat," C2IPPpp6   input : covariance C2   output : intensities IPP mode pp6\n");
    if (strcmp(PolTypeConf,"C2IPPpp7") == 0)	strcat(UsageHelpDataFormat," C2IPPpp7   input : covariance C2   output : intensities IPP mode pp7\n");
    if (strcmp(PolTypeConf,"C2T2") == 0)		strcat(UsageHelpDataFormat," C2T2       input : covariance C2   output : coherency T2\n");

    if (strcmp(PolTypeConf,"C3") == 0)  		strcat(UsageHelpDataFormat," C3         input : covariance C3   output : covariance C3\n");
    if (strcmp(PolTypeConf,"C3T3") == 0)		strcat(UsageHelpDataFormat," C3T3       input : covariance C3   output : coherency T3\n");

    if (strcmp(PolTypeConf,"C3C2pp1") == 0)		strcat(UsageHelpDataFormat," C3C2pp1    input : covariance C3   output : covariance C2 mode pp1\n");
    if (strcmp(PolTypeConf,"C3C2pp2") == 0)		strcat(UsageHelpDataFormat," C3C2pp2    input : covariance C3   output : covariance C2 mode pp2\n");
    if (strcmp(PolTypeConf,"C3C2pp3") == 0)		strcat(UsageHelpDataFormat," C3C2pp3    input : covariance C3   output : covariance C2 mode pp3\n");

    if (strcmp(PolTypeConf,"C3C2lhv") == 0)		strcat(UsageHelpDataFormat," C3C2lhv    input : covariance C3   output : covariance C2 Compact mode Left-HV\n");
    if (strcmp(PolTypeConf,"C3C2rhv") == 0)		strcat(UsageHelpDataFormat," C3C2rhv    input : covariance C3   output : covariance C2 Compact mode Right-HV\n");
    if (strcmp(PolTypeConf,"C3C2pi4") == 0)		strcat(UsageHelpDataFormat," C3C2pi4    input : covariance C3   output : covariance C2 Compact mode Pi/4\n");

    if (strcmp(PolTypeConf,"C3IPPpp4") == 0)	strcat(UsageHelpDataFormat," C3IPPpp4   input : covariance C3   output : intensities IPP mode pp4\n");
    if (strcmp(PolTypeConf,"C3IPPpp5") == 0)	strcat(UsageHelpDataFormat," C3IPPpp5   input : covariance C3   output : intensities IPP mode pp5\n");
    if (strcmp(PolTypeConf,"C3IPPpp6") == 0)	strcat(UsageHelpDataFormat," C3IPPpp6   input : covariance C3   output : intensities IPP mode pp6\n");
    if (strcmp(PolTypeConf,"C3IPPpp7") == 0)	strcat(UsageHelpDataFormat," C3IPPpp7   input : covariance C3   output : intensities IPP mode pp7\n");

    if (strcmp(PolTypeConf,"C4") == 0)  		strcat(UsageHelpDataFormat," C4         input : covariance C4   output : covariance C4\n");
    if (strcmp(PolTypeConf,"C4T4") == 0)		strcat(UsageHelpDataFormat," C4T4       input : covariance C4   output : coherency T4\n");
    if (strcmp(PolTypeConf,"C4C3") == 0)		strcat(UsageHelpDataFormat," C4C3       input : covariance C4   output : covariance C3\n");
    if (strcmp(PolTypeConf,"C4T3") == 0)		strcat(UsageHelpDataFormat," C4T3       input : covariance C4   output : coherency T3\n");

    if (strcmp(PolTypeConf,"C4C2pp1") == 0)		strcat(UsageHelpDataFormat," C4C2pp1    input : covariance C4   output : covariance C2 mode pp1\n");
    if (strcmp(PolTypeConf,"C4C2pp2") == 0)		strcat(UsageHelpDataFormat," C4C2pp2    input : covariance C4   output : covariance C2 mode pp2\n");
    if (strcmp(PolTypeConf,"C4C2pp3") == 0)		strcat(UsageHelpDataFormat," C4C2pp3    input : covariance C4   output : covariance C2 mode pp3\n");

    if (strcmp(PolTypeConf,"C4C2lhv") == 0)		strcat(UsageHelpDataFormat," C4C2lhv    input : covariance C4   output : covariance C2 Compact mode Left-HV\n");
    if (strcmp(PolTypeConf,"C4C2rhv") == 0)		strcat(UsageHelpDataFormat," C4C2rhv    input : covariance C4   output : covariance C2 Compact mode Right-HV\n");
    if (strcmp(PolTypeConf,"C4C2pi4") == 0)		strcat(UsageHelpDataFormat," C4C2pi4    input : covariance C4   output : covariance C2 Compact mode Pi/4\n");

    if (strcmp(PolTypeConf,"C4IPPpp4") == 0)	strcat(UsageHelpDataFormat," C4IPPpp4   input : covariance C4   output : intensities IPP mode pp4\n");
    if (strcmp(PolTypeConf,"C4IPPpp5") == 0)	strcat(UsageHelpDataFormat," C4IPPpp5   input : covariance C4   output : intensities IPP mode pp5\n");
    if (strcmp(PolTypeConf,"C4IPPpp6") == 0)	strcat(UsageHelpDataFormat," C4IPPpp6   input : covariance C4   output : intensities IPP mode pp6\n");
    if (strcmp(PolTypeConf,"C4IPPpp7") == 0)	strcat(UsageHelpDataFormat," C4IPPpp7   input : covariance C4   output : intensities IPP mode pp7\n");
    if (strcmp(PolTypeConf,"C4IPPfull") == 0)	strcat(UsageHelpDataFormat," C4IPPfull  input : covariance C4   output : intensities IPP mode full\n");

    if (strcmp(PolTypeConf,"T2") == 0)  		strcat(UsageHelpDataFormat," T2         input : coherency T2    output : coherency T2\n");
    if (strcmp(PolTypeConf,"T2C2") == 0)		strcat(UsageHelpDataFormat," T2C2       input : coherency T2    output : covariance C2\n");

    if (strcmp(PolTypeConf,"T3") == 0)  		strcat(UsageHelpDataFormat," T3         input : coherency T3    output : coherency T3\n");
    if (strcmp(PolTypeConf,"T3C3") == 0)		strcat(UsageHelpDataFormat," T3C3       input : coherency T3    output : covariance C3\n");

    if (strcmp(PolTypeConf,"T3C2pp1") == 0)		strcat(UsageHelpDataFormat," T3C2pp1    input : coherency T3    output : covariance C2 mode pp1\n");
    if (strcmp(PolTypeConf,"T3C2pp2") == 0)		strcat(UsageHelpDataFormat," T3C2pp2    input : coherency T3    output : covariance C2 mode pp2\n");
    if (strcmp(PolTypeConf,"T3C2pp3") == 0)		strcat(UsageHelpDataFormat," T3C2pp3    input : coherency T3    output : covariance C2 mode pp3\n");

    if (strcmp(PolTypeConf,"T3C2lhv") == 0)		strcat(UsageHelpDataFormat," T3C2lhv    input : coherency T3    output : covariance C2 Compact mode Left-HV\n");
    if (strcmp(PolTypeConf,"T3C2rhv") == 0)		strcat(UsageHelpDataFormat," T3C2rhv    input : coherency T3    output : covariance C2 Compact mode Right-HV\n");
    if (strcmp(PolTypeConf,"T3C2pi4") == 0)		strcat(UsageHelpDataFormat," T3C2pi4    input : coherency T3    output : covariance C2 Compact mode Pi/4\n");

    if (strcmp(PolTypeConf,"T3IPPpp4") == 0)	strcat(UsageHelpDataFormat," T3IPPpp4   input : coherency T3    output : intensities IPP mode pp4\n");
    if (strcmp(PolTypeConf,"T3IPPpp5") == 0)	strcat(UsageHelpDataFormat," T3IPPpp5   input : coherency T3    output : intensities IPP mode pp5\n");
    if (strcmp(PolTypeConf,"T3IPPpp6") == 0)	strcat(UsageHelpDataFormat," T3IPPpp6   input : coherency T3    output : intensities IPP mode pp6\n");
    if (strcmp(PolTypeConf,"T3IPPpp7") == 0)	strcat(UsageHelpDataFormat," T3IPPpp7   input : coherency T3    output : intensities IPP mode pp7\n");

    if (strcmp(PolTypeConf,"T4") == 0)  		strcat(UsageHelpDataFormat," T4         input : coherency T4    output : coherency T4\n");
    if (strcmp(PolTypeConf,"T4C4") == 0)		strcat(UsageHelpDataFormat," T4C4       input : coherency T4    output : covariance C4\n");
    if (strcmp(PolTypeConf,"T4C3") == 0)		strcat(UsageHelpDataFormat," T4C3       input : coherency T4    output : covariance C3\n");
    if (strcmp(PolTypeConf,"T4T3") == 0)		strcat(UsageHelpDataFormat," T4T3       input : coherency T4    output : coherency T3\n");

    if (strcmp(PolTypeConf,"T4C2pp1") == 0)		strcat(UsageHelpDataFormat," T4C2pp1    input : coherency T4    output : covariance C2 mode pp1\n");
    if (strcmp(PolTypeConf,"T4C2pp2") == 0)		strcat(UsageHelpDataFormat," T4C2pp2    input : coherency T4    output : covariance C2 mode pp2\n");
    if (strcmp(PolTypeConf,"T4C2pp3") == 0)		strcat(UsageHelpDataFormat," T4C2pp3    input : coherency T4    output : covariance C2 mode pp3\n");

    if (strcmp(PolTypeConf,"T4C2lhv") == 0)		strcat(UsageHelpDataFormat," T4C2lhv    input : coherency T4    output : covariance C2 Compact mode Left-HV\n");
    if (strcmp(PolTypeConf,"T4C2rhv") == 0)		strcat(UsageHelpDataFormat," T4C2rhv    input : coherency T4    output : covariance C2 Compact mode Right-HV\n");
    if (strcmp(PolTypeConf,"T4C2pi4") == 0)		strcat(UsageHelpDataFormat," T4C2pi4    input : coherency T4    output : covariance C2 Compact mode Pi/4\n");

    if (strcmp(PolTypeConf,"T4IPPpp4") == 0)	strcat(UsageHelpDataFormat," T4IPPpp4   input : coherency T4    output : intensities IPP mode pp4\n");
    if (strcmp(PolTypeConf,"T4IPPpp5") == 0)	strcat(UsageHelpDataFormat," T4IPPpp5   input : coherency T4    output : intensities IPP mode pp5\n");
    if (strcmp(PolTypeConf,"T4IPPpp6") == 0)	strcat(UsageHelpDataFormat," T4IPPpp6   input : coherency T4    output : intensities IPP mode pp6\n");
    if (strcmp(PolTypeConf,"T4IPPpp7") == 0)	strcat(UsageHelpDataFormat," T4IPPpp7   input : coherency T4    output : intensities IPP mode pp7\n");
    if (strcmp(PolTypeConf,"T4IPPfull") == 0)	strcat(UsageHelpDataFormat," T4IPPfull  input : coherency T4    output : intensities IPP mode full\n");

    if (strcmp(PolTypeConf,"T6") == 0)  		strcat(UsageHelpDataFormat," T6         input : coherency T6    output : coherency T6\n");

    if (strcmp(PolTypeConf,"SPP") == 0) 		strcat(UsageHelpDataFormat," SPP        input : dual-pol SPP    output : dual-pol SPP\n");
    if (strcmp(PolTypeConf,"SPPC2") == 0)		strcat(UsageHelpDataFormat," SPPC2      input : dual-pol SPP    output : covariance C2\n");
    if (strcmp(PolTypeConf,"SPPT2") == 0)		strcat(UsageHelpDataFormat," SPPT2      input : dual-pol SPP    output : coherency T2\n");
    if (strcmp(PolTypeConf,"SPPIPP") == 0)		strcat(UsageHelpDataFormat," SPPIPP     input : dual-pol SPP    output : intensities IPP\n");
    if (strcmp(PolTypeConf,"SPPT4") == 0)		strcat(UsageHelpDataFormat," SPPT4      input : 2*dual-pol SPP  output : coherency T4\n");

    if (strcmp(PolTypeConf,"IPP") == 0) 		strcat(UsageHelpDataFormat," IPP        input : intensities IPP output : intensities IPP\n");
    if (strcmp(PolTypeConf,"Ixx") == 0) 		strcat(UsageHelpDataFormat," Ixx        input : intensity Ixx   output : intensity Ixx\n");
    
return 1;
}

/********************************************************************
Routine  : CreateUsageHelpDataFormatInput
Authors  : Eric POTTIER
Creation : 06/2011
Update  :
*--------------------------------------------------------------------
Description : 
********************************************************************/
int CreateUsageHelpDataFormatInput(char *PolTypeConf)
{

    if (strcmp(PolTypeConf,"S2") == 0)  		strcat(UsageHelpDataFormat," S2    input : quad-pol S2      output parameters derived from C3 or T3\n");
    if (strcmp(PolTypeConf,"S2m") == 0) 		strcat(UsageHelpDataFormat," S2m   input : quad-pol S2      output parameters derived from C3 or T3\n");
    if (strcmp(PolTypeConf,"S2b") == 0) 		strcat(UsageHelpDataFormat," S2b   input : quad-pol S2      output parameters derived from C4 or T4\n");
    if (strcmp(PolTypeConf,"S2C3") == 0)		strcat(UsageHelpDataFormat," S2C3  input : quad-pol S2      output parameters derived from covariance C3\n");
    if (strcmp(PolTypeConf,"S2T3") == 0)		strcat(UsageHelpDataFormat," S2T3  input : quad-pol S2      output parameters derived from coherency T3\n");
    if (strcmp(PolTypeConf,"S2C4") == 0)		strcat(UsageHelpDataFormat," S2C4  input : quad-pol S2      output parameters derived from covariance C4\n");
    if (strcmp(PolTypeConf,"S2T4") == 0)		strcat(UsageHelpDataFormat," S2T4  input : quad-pol S2      output parameters derived from coherency T4\n");
    if (strcmp(PolTypeConf,"S2T6") == 0)		strcat(UsageHelpDataFormat," S2T6  input : 2*quad-pol S2    output parameters derived from coherency T6\n");
    if (strcmp(PolTypeConf,"C2") == 0)  		strcat(UsageHelpDataFormat," C2    input : covariance C2    output parameters derived from covariance C2\n");
    if (strcmp(PolTypeConf,"C2T2") == 0)		strcat(UsageHelpDataFormat," C2T2  input : covariance C2    output parameters derived from coherency T2\n");
    if (strcmp(PolTypeConf,"C3") == 0)  		strcat(UsageHelpDataFormat," C3    input : covariance C3    output parameters derived from covariance C3\n");
    if (strcmp(PolTypeConf,"C3T3") == 0)		strcat(UsageHelpDataFormat," C3T3  input : covariance C3    output parameters derived from coherency T3\n");
    if (strcmp(PolTypeConf,"C4") == 0)  		strcat(UsageHelpDataFormat," C4    input : covariance C4    output parameters derived from covariance C4\n");
    if (strcmp(PolTypeConf,"C4T4") == 0)		strcat(UsageHelpDataFormat," C4T4  input : covariance C4    output parameters derived from coherency T4\n");
    if (strcmp(PolTypeConf,"T2") == 0)  		strcat(UsageHelpDataFormat," T2    input : coherency T2     output parameters derived from coherency T2\n");
    if (strcmp(PolTypeConf,"T3") == 0)  		strcat(UsageHelpDataFormat," T3    input : coherency T3     output parameters derived from coherency T3\n");
    if (strcmp(PolTypeConf,"T4") == 0)  		strcat(UsageHelpDataFormat," T4    input : coherency T4     output parameters derived from coherency T4\n");
    if (strcmp(PolTypeConf,"T6") == 0)  		strcat(UsageHelpDataFormat," T6    input : coherency T6     output parameters derived from coherency T6\n");
    if (strcmp(PolTypeConf,"SPP") == 0) 		strcat(UsageHelpDataFormat," SPP   input : dual-pol SPP     output parameters derived from C3\n");
    if (strcmp(PolTypeConf,"SPPT4") == 0)		strcat(UsageHelpDataFormat," SPPT4 input : 2*dual-pol SPP   output parameters derived from coherency T4\n");
    if (strcmp(PolTypeConf,"IPP") == 0) 		strcat(UsageHelpDataFormat," IPP   input : intensities IPP  output parameters derived from IPP\n");
    if (strcmp(PolTypeConf,"Ixx") == 0) 		strcat(UsageHelpDataFormat," Ixx   input : intensity Ixx    output parameters derived from Ixx\n");
    
return 1;
}

/********************************************************************
Routine  : init_matrix_block
Authors  : Eric POTTIER
Creation : 06/2011
Update  :
*--------------------------------------------------------------------
Description : Init global matrix used in util_block.c
********************************************************************/
int init_matrix_block(int NNcol, int NNpolar, int NNwinLig, int NNwinCol)
{

_VC_in = vector_float(2*NNcol);
_VF_in = vector_float(NNcol);
_MC_in = matrix_float(4,2*NNcol);
_MF_in = matrix3d_float(NNpolar,NNwinLig, NNcol+NNwinCol);
return 1;
}

/********************************************************************
Routine  : block_alloc
Authors  : Eric POTTIER
Creation : 10/2012
Update  :
*--------------------------------------------------------------------
Description : BlockSize and Number of Blocks determination
********************************************************************/
int block_alloc(int *NNligBlock, int SSubSampLig, int NNLookLig, int SSub_Nlig, int *NNbBlock)
{
    int ii, NligRem, NligNew;

    NligRem = (int) floor ( fmod(NNligBlock[0], SSubSampLig*NNLookLig));
    if (NligRem != 0) {
      NligNew = (int) floor(NNligBlock[0] / (SSubSampLig*NNLookLig));
      NligNew = NligNew*SSubSampLig*NNLookLig;
      (*NNbBlock) = floor(SSub_Nlig / NligNew);
      NligRem = SSub_Nlig - (*NNbBlock)*NligNew;
      for (ii = 0; ii < (*NNbBlock); ii++) NNligBlock[ii] = NligNew;
      //NligBlock[NbBlock] = NligRem;
      NligNew = (int) floor(NligRem / (SSubSampLig*NNLookLig));
      NligNew = NligNew*SSubSampLig*NNLookLig;
      NNligBlock[(*NNbBlock)] = NligNew;
      (*NNbBlock)++;
      }
  return 1;
}
