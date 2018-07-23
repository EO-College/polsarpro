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

	File	 : util_block.h
	Project  : ESA_POLSARPRO
	Authors  : Eric POTTIER
	Version  : 1.0
	Creation : 08/2010
	Update	: 

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
 
	Description :  UTIL Routines for Block Data Reading and Writing

*--------------------------------------------------------------------
	Routines	:

int read_matrix_int(char *file_name, int **M_in, int NNlig, int NNcol, int NNwinLig, int NNwinCol);
int read_matrix_float(char *file_name, float **M_in, int NNlig, int NNcol, int NNwinLig, int NNwinCol);
int read_matrix_cmplx(char *file_name, float **M_in, int NNlig, int NNcol, int NNwinLig, int NNwinCol);
int write_matrix_int(char *file_name, int **M_out, int NNlig, int NNcol, int OOffLig, int OOffCol);
int write_matrix_float(char *file_name, float **M_out, int NNlig, int NNcol, int OffLig, int OffCol);
int write_matrix_cmplx(char *file_name, float **M_out, int NNlig, int NNcol, int OffLig, int OffCol);

int read_matrix3d_float(int NNpolar, char **file_name, float ***M_in, int NNlig, int NNcol, int NNwinLig, int NNwinCol);
int read_matrix3d_cmplx(int NNpolar, char **file_name, float ***M_in, int NNlig, int NNcol, int NNwinLig, int NNwinCol);
int write_matrix3d_float(int NNpolar, char **file_name, float ***M_out, int NNlig, int NNcol, int OffLig, int OffCol);
int write_matrix3d_cmplx(int NNpolar, char **file_name, float ***M_out, int NNlig, int NNcol, int OffLig, int OffCol);

int read_block_matrix_int(FILE *in_file, int **M_in, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);
int read_block_matrix_float(FILE *in_file, float **M_in, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);
int read_block_matrix_matrix3d_float(FILE *in_file, float ***M_in, int NNp, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);
int read_block_matrix_cmplx(FILE *in_file, float **M_in, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);

int write_block_matrix_int(FILE *outfile, int **M_out, int Sub_NNlig, int Sub_NNcol, int OOffLig, int OOffCol, int NNcol);
int write_block_matrix_float(FILE *outfile, float **M_out, int Sub_NNlig, int Sub_NNcol, int OffLig, int OffCol, int NNcol);
int write_block_matrix_matrix3d_float(FILE *out_file, float ***M_out, int NNp, int Sub_NNlig, int Sub_NNcol, int OOffLig, int OOffCol, int NNcol);
int write_block_matrix_cmplx(FILE *outfile, float **M_out, int Sub_NNlig, int Sub_NNcol, int OffLig, int OffCol, int NNcol);

int write_block_matrix3d_float(FILE *datafile[], int NNpolar, float ***M_out, int Sub_NNlig, int Sub_NNcol, int OffLig, int OffCol, int NNcol);
int write_block_matrix3d_cmplx(FILE *datafile[], int NNpolar, float ***M_out, int Sub_NNlig, int Sub_NNcol, int OffLig, int OffCol, int NNcol);

int read_block_S2_avg(FILE *datafile[], float ***M_out, char *PolType, int NNpolar, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);
int read_block_S2_noavg(FILE *datafile[], float ***M_out, char *PolType, int NNpolar, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);
int read_block_S2T6_avg(FILE *datafile1[], FILE *datafile2[], float ***M_out, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);
int read_block_SPP_avg(FILE *datafile[], float ***M_out, char *PolType, int NNpolar, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);
int read_block_SPP_noavg(FILE *datafile[], float ***M_out, char *PolType, int NNpolar, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);
int read_block_TCI_avg(FILE *datafile[], float ***M_out, int NNpolar, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);
int read_block_TCI_noavg(FILE *datafile[], float ***M_out, int NNpolar, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);

int read_block_S2_TCIelt_noavg(FILE *datafile[], float **M_out, char *PolType, int NNp, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol)
int read_block_SPP_TCIelt_noavg(FILE *datafile[], float **M_out, char *PolType, int NNp, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol)

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>


#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

#ifndef FlagUtilBlock
#define FlagUtilBlock

/*******************************************************************/

int read_matrix_int(char *file_name, int **M_in, int NNlig, int NNcol, int NNwinLig, int NNwinCol);
int read_matrix_float(char *file_name, float **M_in, int NNlig, int NNcol, int NNwinLig, int NNwinCol);
int read_matrix_cmplx(char *file_name, float **M_in, int NNlig, int NNcol, int NNwinLig, int NNwinCol);
int write_matrix_int(char *file_name, int **M_out, int NNlig, int NNcol, int OOffLig, int OOffCol);
int write_matrix_float(char *file_name, float **M_out, int NNlig, int NNcol, int OffLig, int OffCol);
int write_matrix_cmplx(char *file_name, float **M_out, int NNlig, int NNcol, int OffLig, int OffCol);

int read_matrix3d_float(int NNpolar, char **file_name, float ***M_in, int NNlig, int NNcol, int NNwinLig, int NNwinCol);
int read_matrix3d_cmplx(int NNpolar, char **file_name, float ***M_in, int NNlig, int NNcol, int NNwinLig, int NNwinCol);
int write_matrix3d_float(int NNpolar, char **file_name, float ***M_out, int NNlig, int NNcol, int OffLig, int OffCol);
int write_matrix3d_cmplx(int NNpolar, char **file_name, float ***M_out, int NNlig, int NNcol, int OffLig, int OffCol);

int read_block_matrix_int(FILE *in_file, int **M_in, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);
int read_block_matrix_float(FILE *in_file, float **M_in, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);
int read_block_matrix_matrix3d_float(FILE *in_file, float ***M_in, int NNp, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);
int read_block_matrix_cmplx(FILE *in_file, float **M_in, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);

int write_block_matrix_int(FILE *outfile, int **M_out, int Sub_NNlig, int Sub_NNcol, int OOffLig, int OOffCol, int NNcol);
int write_block_matrix_float(FILE *outfile, float **M_out, int Sub_NNlig, int Sub_NNcol, int OffLig, int OffCol, int NNcol);
int write_block_matrix_matrix3d_float(FILE *out_file, float ***M_out, int NNp, int Sub_NNlig, int Sub_NNcol, int OOffLig, int OOffCol, int NNcol);
int write_block_matrix_cmplx(FILE *outfile, float **M_out, int Sub_NNlig, int Sub_NNcol, int OffLig, int OffCol, int NNcol);

int write_block_matrix3d_float(FILE *datafile[], int NNpolar, float ***M_out, int Sub_NNlig, int Sub_NNcol, int OffLig, int OffCol, int NNcol);
int write_block_matrix3d_cmplx(FILE *datafile[], int NNpolar, float ***M_out, int Sub_NNlig, int Sub_NNcol, int OffLig, int OffCol, int NNcol);

int read_block_S2_avg(FILE *datafile[], float ***M_out, char *PolType, int NNpolar, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);
int read_block_S2_noavg(FILE *datafile[], float ***M_out, char *PolType, int NNpolar, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);
int read_block_S2T6_avg(FILE *datafile1[], FILE *datafile2[], float ***M_out, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);
int read_block_SPP_avg(FILE *datafile[], float ***M_out, char *PolType, int NNpolar, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);
int read_block_SPP_noavg(FILE *datafile[], float ***M_out, char *PolType, int NNpolar, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);
int read_block_TCI_avg(FILE *datafile[], float ***M_out, int NNpolar, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);
int read_block_TCI_noavg(FILE *datafile[], float ***M_out, int NNpolar, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);

int read_block_S2_TCIelt_noavg(FILE *datafile[], float **M_out, char *PolType, int NNp, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);
int read_block_SPP_TCIelt_noavg(FILE *datafile[], float **M_out, char *PolType, int NNp, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);

#endif
