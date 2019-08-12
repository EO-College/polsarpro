#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>


#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

#ifndef FlagDecomp
#define FlagDecomp

#define eps 1.E-15
#define pi 3.14159265358979323846
#define M_C 299792458 

#define INIT_MINMAX 1.E+30
#define DATA_NULL 9999999.99

#define FilePathLength 1024

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

#define my_square(x) ((x)*(x)) 
#define my_max(a,b) ((a)>(b) ? (a):(b))
#define my_min(a,b) ((a)<(b) ? (a):(b))
#define my_wrap_int(a,b)  (((a)>=0) ? ((a)%(int)(b)):((b)+((a)%(int)(b))))

/* Return nonzero value if X is not +-Inf or NaN.  */
#define my_isfinite(x) ((x == x && (x - x == 0.0)) ? 1 : 0)

/*******************************************************************/

/* Common Variables */
FILE *in_datafile[FilePathLength];
FILE *in_datafile1[FilePathLength];
FILE *in_datafile2[FilePathLength];
FILE *out_datafile[FilePathLength];
FILE *out_datafile1[FilePathLength];
FILE *out_datafile2[FilePathLength];
FILE *out_datafile3[FilePathLength];
FILE *out_datafile4[FilePathLength];
FILE *in_valid;
FILE *tmp_datafile[FilePathLength];

char in_dir[FilePathLength], out_dir[FilePathLength];
char in_dir1[FilePathLength], in_dir2[FilePathLength];
char out_dir1[FilePathLength], out_dir2[FilePathLength];
char out_dir3[FilePathLength], out_dir4[FilePathLength];
char tmp_dir[FilePathLength];
char PolarCase[20], PolarType[20];
char PolType[20], PolTypeIn[20], PolTypeOut[20];
char file_valid[FilePathLength];
char file_memerr[FilePathLength];
char **file_name_in; 
char **file_name_in1, **file_name_in2; 
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

/* MATRIX */
char **matrix_char(int nrh, int nch);
float *vector_float (int nrh);
void free_vector_float (float *m);
float **matrix_float (int nrh, int nch);
void free_matrix_float (float **m, int nrh);
float ***matrix3d_float (int nz, int nrh, int nch);
void free_matrix3d_float (float ***m, int nz, int nrh);

/* UTIL_BLOCK */
int read_block_matrix_float(FILE *in_file, float **M_in, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);
int write_block_matrix_float(FILE *outfile, float **M_out, int Sub_NNlig, int Sub_NNcol, int OffLig, int OffCol, int NNcol);
int read_block_S2_avg(FILE *datafile[], float ***M_out, char *PolType, int NNpolar, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);

/* PROCESSING */
void Diagonalisation(int MatrixDim, float ***HM, float ***EigenVect, float *EigenVal);

/* UTIL */
void edit_error (char *s1, char *s2);
void check_file(char *file);
void check_dir(char *dir);
void read_config (char *dir, int *Nlig, int *Ncol, char *PolarCase, char *PolarType);

int PolTypeConfig(char *PolType, int *NpolarIn, char *PolTypeIn, int *NpolarOut, char *PolTypeOut, char *PolarType);
int init_file_name(char *PolType, char *Dir, char **FileName);
int memory_alloc(char *filememerr, int Nlig, int Nwin, int *NbBlock, int *NligBlock, int NBlockA, int NBlockB, int MemAlloc);
int PrintfLine(int lig, int NNlig);
int CreateUsageHelpDataFormat(char *PolTypeConf); 
int CreateUsageHelpDataFormatInput(char *PolTypeConf);
int init_matrix_block(int NNcol, int NNpolar, int NNwinLig, int NNwinCol);
int block_alloc(int *NNligBlock, int SSubSampLig, int NNLookLig, int SSub_Nlig, int *NNbBlock);
int CheckFreeMemory(void);
int CheckFreeMemoryWin32(void);
int CheckFreeMemoryLinux(void);

/* MY_UTILS */
typedef enum {no_cmd_prm,int_cmd_prm,flt_cmd_prm,str_cmd_prm} cmd_prm;

int get_commandline_prm(int argc, char *argv[], char *keyword, cmd_prm type, void *ptr, int required, char *usage);
int get_one_char_only(void);

int my_fseek(FILE *in_file, int fseek_sign, long int fseek_arg1, long int fseek_arg2);

#endif
