/********************************************************************
PolSARpro v4.0 is free software; you can redistribute it and/or 
modify it under the terms of the GNU General Public License as 
published by the Free Software Foundation; either version 2 (1991) of
the License, or any later version. This program is distributed in the
hope that it will be useful, but WITHOUT ANY WARRANTY; without even 
the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE. 

See the GNU General Public License (Version 2, 1991) for more details

*********************************************************************

	File	 : util.h
	Project  : ESA_POLSARPRO
	Authors  : Eric POTTIER, Laurent FERRO-FAMIL
	Version  : 2.0
	Creation : 09/2003
	Update	: 01/2010

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
	Routines	:
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
cplx	cadd(cplx a,cplx b);
cplx	csub(cplx a,cplx b);
cplx	cmul(cplx a,cplx b);
cplx	cdiv(cplx a,cplx b);
cplx	cpwr(cplx a,float b);
cplx	cconj(cplx a);
float	cimg(cplx a);
float	crel(cplx a);
float	cmod(cplx a);
float	cmod2(cplx a);
float	angle(cplx a);
cplx	cplx_sinc(cplx a);

int PolTypeConfig(char *PolType, int *NpolarIn, char *PolTypeIn, int *NpolarOut, char *PolTypeOut, char *PolarType);
int init_file_name(char *PolType, char *Dir, char **FileName);
int memory_alloc(char *filememerr, int Nlig, int Nwin, int *NbBlock, int *NligBlock, int NBlockA, int NBlockB, int MemoryAlloc);
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


#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

#ifndef FlagUtil
#define FlagUtil

#define eps 1.E-30
#define pi 3.14159265358979323846
#define M_C 299792458 

#define INIT_MINMAX 1.E+30
#define DATA_NULL 9999999.99

#define FilePathLength 1024

/*******************************************************************/
/* Common Variables */

/* S2 matrix */
#define s11  0
#define s12  1
#define s21  2
#define s22  3

/* IPP Full */
#define I411  0
#define I412  1
#define I421  2
#define I422  3

/* IPP pp4 */
#define I311  0
#define I312  1
#define I322  2

/* IPP pp5-pp6-pp7 */
#define I211  0
#define I212  1

/* C2 matrix */
#define C211     0
#define C212_re  1
#define C212_im  2
#define C222     3

/* C3 matrix */
#define C311     0
#define C312_re  1
#define C312_im  2
#define C313_re  3
#define C313_im  4
#define C322     5
#define C323_re  6
#define C323_im  7
#define C333     8

/* C4 matrix */
#define C411     0
#define C412_re  1
#define C412_im  2
#define C413_re  3
#define C413_im  4
#define C414_re  5
#define C414_im  6
#define C422     7
#define C423_re  8
#define C423_im  9
#define C424_re  10
#define C424_im  11
#define C433     12
#define C434_re  13
#define C434_im  14
#define C444     15

/* T2 matrix */
#define T211     0
#define T212_re  1
#define T212_im  2
#define T222     3

/* T3 matrix */
#define T311     0
#define T312_re  1
#define T312_im  2
#define T313_re  3
#define T313_im  4
#define T322     5
#define T323_re  6
#define T323_im  7
#define T333     8

/* T4 matrix */
#define T411     0
#define T412_re  1
#define T412_im  2
#define T413_re  3
#define T413_im  4
#define T414_re  5
#define T414_im  6
#define T422     7
#define T423_re  8
#define T423_im  9
#define T424_re  10
#define T424_im  11
#define T433     12
#define T434_re  13
#define T434_im  14
#define T444     15

/* C2 or T2 matrix */
#define X211     0
#define X212_re  1
#define X212_im  2
#define X222     3
#define X212     4

/* C3 or T3 matrix */
#define X311     0
#define X312_re  1
#define X312_im  2
#define X313_re  3
#define X313_im  4
#define X322     5
#define X323_re  6
#define X323_im  7
#define X333     8
#define X312     9
#define X313     10
#define X323     11

/* C4 or T4 matrix */
#define X411     0
#define X412_re  1
#define X412_im  2
#define X413_re  3
#define X413_im  4
#define X414_re  5
#define X414_im  6
#define X422     7
#define X423_re  8
#define X423_im  9
#define X424_re  10
#define X424_im  11
#define X433     12
#define X434_re  13
#define X434_im  14
#define X444     15
#define X412     16
#define X413     17
#define X414     18
#define X423     19
#define X424     20
#define X434     21

/* T6 matrix */
#define T611     0
#define T612_re  1
#define T612_im  2
#define T613_re  3
#define T613_im  4
#define T614_re  5
#define T614_im  6
#define T615_re  7
#define T615_im  8
#define T616_re  9
#define T616_im  10
#define T622     11
#define T623_re  12
#define T623_im  13
#define T624_re  14
#define T624_im  15
#define T625_re  16
#define T625_im  17
#define T626_re  18
#define T626_im  19
#define T633     20
#define T634_re  21
#define T634_im  22
#define T635_re  23
#define T635_im  24
#define T636_re  25
#define T636_im  26
#define T644     27
#define T645_re  28
#define T645_im  29
#define T646_re  30
#define T646_im  31
#define T655     32
#define T656_re  33
#define T656_im  34
#define T666     35

/*******************************************************************/

/* Return nonzero value if X is not +-Inf or NaN.  */
#define my_isfinite(x) ((x == x && (x - x == 0.0)) ? 1 : 0)

/*******************************************************************/

/* Common Variables */
FILE *in_datafile[FilePathLength];
FILE *in_datafile1[FilePathLength];
FILE *in_datafile2[FilePathLength];
FILE *in_datafile3[FilePathLength];
FILE *out_datafile[FilePathLength];
FILE *out_datafile1[FilePathLength];
FILE *out_datafile2[FilePathLength];
FILE *out_datafile3[FilePathLength];
FILE *out_datafile4[FilePathLength];
FILE *in_valid;
FILE *tmp_datafile[FilePathLength];

char in_dir[FilePathLength], out_dir[FilePathLength];
char in_dir1[FilePathLength], in_dir2[FilePathLength], in_dir3[FilePathLength];
char out_dir1[FilePathLength], out_dir2[FilePathLength];
char out_dir3[FilePathLength], out_dir4[FilePathLength];
char tmp_dir[FilePathLength];
char PolarCase[20], PolarType[20];
char PolType[20], PolTypeIn[20], PolTypeOut[20];
char file_valid[FilePathLength];
char file_memerr[FilePathLength];
char **file_name_in; 
char **file_name_in1;
char **file_name_in2; 
char **file_name_in3; 
char **file_name_out; 
char **file_name_out1, **file_name_out2; 
char **file_name_out3, **file_name_out4; 
char **file_name_tmp; 

char UsageHelp[2048];
char UsageHelpDataFormat[8192];
int NligBlock[FilePathLength];

int Nlig, Ncol;
int Off_lig, Off_col;
int Sub_Nlig, Sub_Ncol;
int Nwin, NwinM1S2;
int NwinL, NwinLM1S2;
int NwinC, NwinCM1S2;
int Np, NpolarIn, NpolarOut;
int Nb, NbBlock, NBlockA, NBlockB, MemoryAlloc;
int FlagValid;

int NcolBMP, ExtraColBMP, IntCharBMP;

float **Valid;
float Nvalid;
float span;
float k1r, k1i, k2r, k2i, k3r, k3i, k4r, k4i;

/* Global Matrix used in util_block.c */
float *_VC_in;
float *_VF_in;
int *_VI_in;
float **_MC_in;
float **_MC1_in;
float **_MC2_in;
float ***_MF_in;

/*******************************************************************/
struct Pix
{
  float x;
  float y;
  struct Pix *next;
};

struct Pix *Create_Pix (struct Pix *P, float x, float y);
struct Pix *Remove_Pix (struct Pix *P_top, struct Pix *P);

float my_round (float v);

void edit_error (char *s1, char *s2);

void check_file (char *file);
void check_dir (char *dir);

void read_config (char *dir, int *Nlig, int *Ncol, char *PolarCase, char *PolarType);
void write_config (char *dir, int Nlig, int Ncol, char *PolarCase, char *PolarType);

void my_randomize (void);
float my_random (float num);
float my_eps_random (void);

typedef struct
{
  float re;
  float im;
}cplx;

cplx	cadd(cplx a,cplx b);
cplx	csub(cplx a,cplx b);
cplx	cmul(cplx a,cplx b);
cplx	cdiv(cplx a,cplx b);
cplx	cpwr(cplx a,float b);
cplx	cconj(cplx a);
float	cimg(cplx a);
float	crel(cplx a);
float	cmod(cplx a);
float	cmod2(cplx a);
float	angle(cplx a);
cplx	cplx_sinc(cplx a);

int PolTypeConfig(char *PolType, int *NpolarIn, char *PolTypeIn, int *NpolarOut, char *PolTypeOut, char *PolarType);
int init_file_name(char *PolType, char *Dir, char **FileName);
int memory_alloc(char *filememerr, int Nlig, int Nwin, int *NbBlock, int *NligBlock, int NBlockA, int NBlockB, int MemAlloc);
int PrintfLine(int lig, int NNlig);
int CreateUsageHelpDataFormat(char *PolTypeConf); 
int CreateUsageHelpDataFormatInput(char *PolTypeConf);
int init_matrix_block(int NNcol, int NNpolar, int NNwinLig, int NNwinCol);
int block_alloc(int *NNligBlock, int SSubSampLig, int NNLookLig, int SSub_Nlig, int *NNbBlock);

#endif
