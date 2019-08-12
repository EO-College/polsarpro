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

File   : alos2_header.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 11/2014
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

Description :  Read Headers of ALOS-PALSAR Data Files

This software is extracted and adapted from the SIR-C GDPS OPS
ceos_rd.c software
Copyright (c) 1993, California Institute of Technology. U.S.
Government Sponsorship under NASA Contract NAS7-918 is acknowledged.
Author:  P. Barrett, Initiated: 11-FEB-93

*--------------------------------------------------------------------
*
* Abstract:   Read ALOS-PALSAR Data Files
*
* Description:  This stand-alone task reads CEOS formatted ALOS
*               -PALSAR files from disk and creates ASCII readable
*               files of the contents.
*
* Input Files:  The following CEOS formatted files are read by this
*               task:
*
*           leader file
*           image file
*           trailer file
*
* Output Files:  The following files are created by this task:
*
*           DirOutput / ceos_leader.txt
*           DirOutput / ceos_image.txt
*           DirOutput / ceos_trailer.txt
*
********************************************************************/
#define ALOS_CEOS_READER

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include  <time.h>

#include "omp.h"

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* ROUTINES DECLARATION */
#include "../lib/alos_ceos.h"      /* CEOS file definitions */
#include "../lib/alos_header.h"    /* Constants, output strings */
#include "../lib/PolSARproLib.h"

/********************************************************************
*
*            -- Function Prototypes --
*
********************************************************************/

  void            /* Read SAR Leader File */
Rd_SAR_Leader();

  void            /* Read Imagery Options File */
Rd_SAR_Image();

  void            /* Read SAR Trailer File */
Rd_SAR_Trailer();

  void            /* Create boxed title */
Title_Box(char *filename, char *rec_name, FILE *fp, int record_no, int n_records, char *pol_string, int strsize);

  void            /* Write header data */
Write_Header(FILE *fp_wr, hdr_t *p_hdr);

  void            /* SARL: Write Leader File Descriptor */
Wr_Leader_Descript(leader_file_struct *fs, FILE *fp_wr);

  void             /* SARL: Write data set summary record */
Wr_Leader_Data_Summary(leader_file_struct *fs, FILE *fp_wr);

  void            /* SARL: Write map projection record  */
Wr_Leader_Map_Proj(leader_file_struct *fs, FILE *fp_wr);

  void            /* SARL: Write platform position record */
Wr_Leader_Platform(leader_file_struct *fs, FILE *fp_wr);

  void            /* SARL: Write attitude data record */
Wr_Leader_Attitude(leader_file_struct *fs, FILE *fp_wr);

  void            /* SARL: Write radiometric data record */
Wr_Leader_Radiometric(leader_file_struct *fs, FILE *fp_wr);

  void            /* SARL: Write data quality summary record */
Wr_Leader_Data_Quality(leader_file_struct *fs, FILE *fp_wr);

  void            /* SARL: Write facility data record */
Wr_Leader_Facility(leader_file_struct *fs, FILE *fp_wr, int index);

  void            /* SARL: Write facility data record 11 */
Wr_Leader_Facility11(leader_file_struct *fs, FILE *fp_wr);

  void            /* IMAGE : Write file descriptor */
Wr_Image_Descript(image_file_struct *fs, FILE *fp_wr);

  void            /* IMAGE :  Write data signal record*/
Wr_Image_Signal(image_file_struct *fs, FILE *fp_wr);


  void            /* IMAGE :  Write data signal record*/
Wr_Image_Signal_Tiny(image_file_struct *fs, FILE *fp_wr);
  
  void            /* IMAGE :  Write processed data record*/
Wr_Image_Process(image_file_struct *fs, FILE *fp_wr);

  void            /* SART: Write file descriptor */
Wr_Trailer_Descript(trailer_file_struct *rp, FILE *fp_wr);

  void            /* left-justify a string */
justify(char *src, int length, char *dest);

  unsigned long         /* Convert long word integer */
htonl( unsigned long x );

  unsigned short         /* Convert short word integer */
htonc( unsigned short x );

  void            /* Read Imagery Options File */
PolSARproConfigFile();

  void            /* PolSARpro File Descriptor */
PolSARproCreateConfigFile(image_file_struct *fs,leader_file_struct *fl, FILE *fp_wr);

/********************************************************************
*
*            -- Global Definitions --
*
********************************************************************/

  /* filenames */

  /* ...Input files */

  char  leader_in[NAME_LEN];    /* CEOS formatted SAR Leader File */
  char  trailer_in[NAME_LEN];   /* CEOS formatted SAR Trailer File */
  char  image_in[NAME_LEN];    /* CEOS formatted Imagery Options File */

  /* ...Output files */

  char  leader_ascii[NAME_LEN];  /* SAR Leader ascii file */
  char  trailer_ascii[NAME_LEN];  /* SAR Trailer ascii file */
  char  image_ascii[NAME_LEN];   /* Imagery Options ascii file */
  char  lowresimg_ascii[NAME_LEN]; /* Low Resolution BMP Image file */

  /* other */

  char  dest[LONG_NAME_LEN];
  char  PSPConfigFile[NAME_LEN];  /* PolSARpro Config File */
  char  Data_Level[3];      /* Data Level 1.1 or 1.5 */

  /* pointers to file structures */
  leader_file_struct    leader;    /* SAR Leader file structure */
  trailer_file_struct    trailer;    /* SAR Trailer file structure */
  image_file_struct    image;     /* Imagery Options file structure */

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/

  int main(int argc, char *argv[]) {

/* LOCAL VARIABLES */
  char DirOutput[NAME_LEN];

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nalos2_header.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-ilf 	input leader file\n");
strcat(UsageHelp," (string)	-iif 	input image file\n");
strcat(UsageHelp," (string)	-itf 	input trailer file\n");
strcat(UsageHelp," (string)	-ocf 	output PolSARpro config file\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 11) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,DirOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ilf",str_cmd_prm,leader_in,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iif",str_cmd_prm,image_in,1,UsageHelp);
  get_commandline_prm(argc,argv,"-itf",str_cmd_prm,trailer_in,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ocf",str_cmd_prm,PSPConfigFile,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_dir(DirOutput);
  check_file(leader_in);
  check_file(image_in);
  check_file(trailer_in);
  check_file(PSPConfigFile);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/*******************************************************************/
/* OUTPUT DATA FILES CONFIG */
/*******************************************************************/

  /* SAR Leader ascii filename */
  sprintf(leader_ascii, "%s%s", DirOutput,"ceos_leader.txt");
  check_file(leader_ascii);

  /* SAR Trailer ascii filename */
  sprintf(trailer_ascii, "%s%s", DirOutput,"ceos_trailer.txt");
  check_file(trailer_ascii);

  /* Imagery Options ascii filename */
  sprintf(image_ascii, "%s%s", DirOutput,"ceos_image.txt");
  check_file(image_ascii);

  /* Low Resolution BMP Image filename */
  sprintf(lowresimg_ascii, "%s%s", DirOutput,"low_resol_quicklook.bmp");
  check_file(lowresimg_ascii);

/*******************************************************************/
/* READ HEADER DATA FILES */
/*******************************************************************/

  /* Read SAR Leader File */
  Rd_SAR_Leader();

  /* Read Imagery Options File */
  Rd_SAR_Image();

  /* Read SAR Trailer File */
  Rd_SAR_Trailer();

  /* PolSARpro create Config File */
  PolSARproConfigFile();

  /* Exit task, showing no errors */
  return 1;

} /* main */

/********************************************************************
*                             
* Function:    Title_Box                
*                             
* Abstract:    Supply a boxed title for the data record 
*                             
* Description:  This routine prints the filename and record name of
*               the data to be displayed below.          
*                             
* Inputs:    filename:  CEOS filename        
*            rec name:  CEOS record name      
*            file ptr:  file to output to      
*           record_no:  record sequence number    
*           n_records:  total number of records in sequence
*                 pol:  band and polarization (LHH, etc.) 
*             strsize:  length of band/pol string  
*                             
* Return Value:  void                      
*                                
********************************************************************/

void Title_Box(char *filename, char *rec_name, FILE *fp, int record_no, int n_records, char *pol_string, int strsize)
{

  char  string[LONG_NAME_LEN];
  char  sstring[LONG_NAME_LEN];
  char  strfmt[LONG_NAME_LEN];

  sprintf( strfmt, "%%-%ds*\n", (int)strlen(STARS1)-1 );

  fprintf(fp, "\f\n%s\n", STARS1);
  fprintf(fp, "%s\n", STARS2);
  fprintf(fp, strfmt, filename );
  fprintf(fp, strfmt, rec_name );

  /* if more than one record of this kind print "1 of 4: LVV" */
  if (record_no !=0) {
    memset(sstring, 0, sizeof(sstring));
    strncat(sstring, pol_string, strsize);
    sprintf(string, "*  %d of %d: %s", record_no, n_records, sstring);
    fprintf(fp, strfmt, string);
  }
  fprintf(fp, "%s\n", STARS2);
  fprintf(fp, "%s\n\n", STARS1);

} /* Title_Box() */

/********************************************************************
*                                
* Function:    Write_Header                  
*                                
* Abstract:    Format and write the header data to output file 
*                                
* Description:  This routine prints the header info (sequence number,
*               subtypes 1, 2, 3, etc.             
*                                
* Inputs:    file ptr:  file to write to         
*            hdr ptr:   pointer to header structure    
*                                
* Outputs:    header to disk file               
*                                
* Return Value:  void                      
*                                
********************************************************************/

void Write_Header(FILE *fp_wr, hdr_t *p_hdr)
{

  char  string[LONG_NAME_LEN];
  unsigned toto;

  toto = htonl(p_hdr->record_seq_no);
  sprintf(string, "%-45s%d\n", HDR_SEQ, toto);
  fprintf(fp_wr, "%s", string);

  sprintf(string, "%-45s%d\n", HDR_1SUB, p_hdr->first_rec_subtype);
  fprintf(fp_wr, "%s", string);

  sprintf(string, "%-45s%d\n", HDR_TYPE, p_hdr->record_type_code);
  fprintf(fp_wr, "%s", string);

  sprintf(string, "%-45s%d\n", HDR_2SUB, p_hdr->second_rec_subtype);
  fprintf(fp_wr, "%s", string);

  sprintf(string, "%-45s%d\n", HDR_3SUB, p_hdr->third_rec_subtype);
  fprintf(fp_wr, "%s", string);

  toto = htonl(p_hdr->rec_length);
  sprintf(string, "%-45s%d\n\n", HDR_LEN, toto);
  fprintf(fp_wr, "%s", string);

} /* Write_Header() */

/********************************************************************
*                                
* Function:    Rd_SAR_Leader                 
*                                
* Abstract:    Read CEOS formatted SAR Leader File       
*                                
* Description:  This routine reads each record in the CEOS SAR
*               Leader File and outputs the data to an ascii file.     
*                                
*        Records include:                
*                                
*          File Descriptor Record            
*          Data Set Summary Record           
*          Map Projection Data Record (only level 1.5) 
*          Platform Position Data Record         
*          Attitude Data Record             
*          Radiometric Data Record           
*          Data Quality Summary Record         
*          Facility Related Data #01 Record       
*          Facility Related Data #02 Record       
*          Facility Related Data #03 Record       
*          Facility Related Data #04 Record       
*          Facility Related Data #05 Record       
*          Facility Related Data #06 Record       
*          Facility Related Data #07 Record       
*          Facility Related Data #08 Record       
*          Facility Related Data #09 Record       
*          Facility Related Data #10 Record       
*          Facility Related Data #11 Record       
*                                
* Inputs:    filename:  filename of SAR Leader file to read from  
*                                
* Outputs:    filename_"ascii"  ascii file          
*                                
* Return Value:  none                      
*                                
********************************************************************/

void Rd_SAR_Leader()
{

  FILE  *fp_rd;       /* file pointer to file to read */
  FILE  *fp_wr;       /* file pointer to file to write */

  int   nread;        /* number of elements read from disk */
  int   i;          /* loop counters */
  int   facility_flag[10];
  unsigned  facility_data[10];
  char  *input_string;

/*******************************************************************/
/*******************************************************************/
  
  /* open the SAR Leader file for reading */
  if ((fp_rd = fopen(leader_in, "rb")) == NULL) {
    edit_error("Unable to open SAR Leader File : ", leader_in);
  }

  /* open/create an output file for writing */
  if ((fp_wr = fopen(leader_ascii, "w+")) == NULL) {
    edit_error("Unable to open/create : ", leader_ascii);
  }

/*******************************************************************/
/*******************************************************************/

  /*
   * Read each record of the SAR Leader file.  Format the data and
   * write the contents of each record, in ascii, to the output file.
   */

  /* read in file descriptor record */
  if ((nread = fread(&leader.descript, sizeof(leader.descript), 1, fp_rd)) < 1)
    {
    edit_error("Unable to read : File Descriptor Record", leader_in);
  } else {
    /* --- Write File Descriptor Record */
    Wr_Leader_Descript(&leader, fp_wr);
  }

  if (atoi(leader.descript.n_data_set_recs) !=0)
  {
    /* read in data set summary record */
    if ((nread = fread(&leader.data_set, sizeof(leader.data_set), 1, fp_rd)) < 1)
      {
      edit_error("Unable to read : Data Set Summary Record ", leader_in);
    } else {
      /* --- Write Data Set Summary Record */
      Wr_Leader_Data_Summary(&leader, fp_wr);
    }
  }

  if (atoi(leader.descript.n_map_proj_recs) !=0)
  {
    /* read in map projection record */
    if ((nread = fread(&leader.map_proj, sizeof(leader.map_proj), 1, fp_rd)) < 1) {
      edit_error("Unable to read : Map Projection Record ", leader_in);
    } else {
      /* --- Write Map Projection Record  */
      Wr_Leader_Map_Proj(&leader, fp_wr);
    }
  }

  if (atoi(leader.descript.n_platf_recs) !=0)
  {
    /* read in platform position record */
    if ((nread = fread(&leader.platform, sizeof(leader.platform), 1, fp_rd)) < 1) {
      edit_error("Unable to read : Platform Position Record ", leader_in);
    } else {
      /* --- Write Platform Position Record  */
      Wr_Leader_Platform(&leader, fp_wr);
    }
  }
  
  if (atoi(leader.descript.n_att_recs) !=0)
  {
    /* read in attitude record */
    if ((nread = fread(&leader.attitude, sizeof(leader.attitude), 1, fp_rd)) < 1) {
      edit_error("Unable to read : Attitude Record ", leader_in);
    } else {
      /* --- Write Attitude Record  */
      Wr_Leader_Attitude(&leader, fp_wr);
    }
  }
  
  if (atoi(leader.descript.n_radio_recs) !=0)
  {
    /* read in radiometric record */
    if ((nread = fread(&leader.radio, sizeof(leader.radio), 1, fp_rd)) < 1) {
      edit_error("Unable to read : Radiometric Record ", leader_in);
    } else {
      /* --- Write Radiometric Record  */
      Wr_Leader_Radiometric(&leader, fp_wr);
    }
  }

  if (atoi(leader.descript.n_qual_recs) !=0)
  {
    /* read in data quality record */
    if ((nread = fread(&leader.data_qual, sizeof(leader.data_qual), 1, fp_rd)) < 1) {
      edit_error("Unable to read : Data Quality Record ", leader_in);
    } else {
      /* --- Write Data Quality Record  */
      Wr_Leader_Data_Quality(&leader, fp_wr);
    }
  }

  facility_flag[0] = atoi(leader.descript.n_facil_recs1);
  facility_flag[1] = atoi(leader.descript.n_facil_recs2);
  facility_flag[2] = atoi(leader.descript.n_facil_recs3);
  facility_flag[3] = atoi(leader.descript.n_facil_recs4);
  facility_flag[4] = atoi(leader.descript.n_facil_recs5);
  facility_flag[5] = atoi(leader.descript.n_facil_recs6);
  facility_flag[6] = atoi(leader.descript.n_facil_recs7);
  facility_flag[7] = atoi(leader.descript.n_facil_recs8);
  facility_flag[8] = atoi(leader.descript.n_facil_recs9);
  facility_flag[9] = atoi(leader.descript.n_facil_recs10);

  facility_data[0] = atoi(leader.descript.len_facil1);
  facility_data[1] = atoi(leader.descript.len_facil2);
  facility_data[2] = atoi(leader.descript.len_facil3);
  facility_data[3] = atoi(leader.descript.len_facil4);
  facility_data[4] = atoi(leader.descript.len_facil5);
  facility_data[5] = atoi(leader.descript.len_facil6);
  facility_data[6] = atoi(leader.descript.len_facil7);
  facility_data[7] = atoi(leader.descript.len_facil8);
  facility_data[8] = atoi(leader.descript.len_facil9);
  facility_data[9] = atoi(leader.descript.len_facil10);

  for (i=0; i<10; i++)
  {
    if (facility_flag[i] !=0)
    {
      /* read in facility data record */
      if ((nread = fread(&leader.facility, sizeof(leader.facility), 1, fp_rd))
          < 1) {
        edit_error("Unable to read : Facility Data Record ", leader_in);
      } else {
        /* --- Write Facility Data Record  */
        Wr_Leader_Facility(&leader, fp_wr, i+1);
        input_string = (char *) malloc((unsigned)(facility_data[i]-sizeof(leader.facility)) * sizeof(char));
        if ((nread = fread(&input_string[0], sizeof(char), (unsigned)(facility_data[i]-sizeof(leader.facility)), fp_rd))  < 1)
          {
          edit_error("Unable to read : Data Facility Record ", leader_in);
        }
        free((char *) input_string);
      }
    }
  }

  if (atoi(leader.descript.n_facil_recs11) !=0)
  {
    /* read in facility data record 11 */
    if ((nread = fread(&leader.facility11, sizeof(leader.facility11), 1, fp_rd)) < 1) {
      edit_error("Unable to read : Facility Data Record 11 ", leader_in);
    } else {
      /* --- Write Facility Data Record 11 */
      Wr_Leader_Facility11(&leader, fp_wr);
    }
  }

/*******************************************************************/
/*******************************************************************/

  /* Close input file */
  if (fclose(fp_rd) != 0) {
    edit_error("Error closing file : ", leader_in);
    }

  /* Close output file */
  if (fclose(fp_wr) != 0) {
    edit_error("Error closing file : ", leader_ascii);
  }

} /* Rd_SAR_Leader */

/********************************************************************
*                                
* Function:    Rd_SAR_Image                  
*                                
* Abstract:    Read CEOS formatted Imagery Options File    
*                                
* Description:  This routine reads each record in the CEOS Imagery
*               Options File and outputs the data in each to an
*               ascii file.  
*                                
*        Record in this file:              
*                                
*            File Descriptor Record         
*                                
* Inputs:    filename:  name of Imagery Options file to read from
*                                
* Outputs:    filename_"ascii"  ascii readable file     
*                                
* Return Value:  none                      
*                                
********************************************************************/

void Rd_SAR_Image()
{

  FILE  *fp_rd;       /* pointer to imagery options file */
  FILE  *fp_wr;       /* pointer to ascii file to be created */

  int   nread;        /* number of elements read from disk */
  int   i;

/*******************************************************************/
/*******************************************************************/

  /* open the Imagery Options file for reading */
  if ((fp_rd = fopen(image_in, "rb")) == NULL) {
    edit_error("Unable to open Imagery Options File :", image_in);
  }

  /* open/create an output file for writing file descriptor record to */
  if ((fp_wr = fopen(image_ascii, "w+")) == NULL) {
    edit_error("Unable to create output file : ", image_ascii);
  }

/*******************************************************************/
/*******************************************************************/

  /* read in file descriptor record */
  if ((nread = fread(&image.descript, sizeof(image.descript), 1, fp_rd)) < 1)
    {
    edit_error("Unable to read : Imagery Options File : ", image_in);
  } else {
    /* --- Write File Descriptor Record */
    Wr_Image_Descript(&image, fp_wr);
  }
  
  strncpy(Data_Level, leader.data_set.product_code, 3);

  if ( strcmp(Data_Level,"1.1") == 0 )
  {
    for (i=0; i < atoi(image.descript.n_lines); i++) {
    /* read in signal data record */
    if ((nread = fread(&image.signal, sizeof(image.signal), 1, fp_rd)) < 1)
      {
      edit_error("Unable to read : Signal Data Record ", image_in);
    } else {
      /* --- Write Signal Data Record */
      //if ( (i == 1) || (i == (atoi(image.descript.n_lines)-1)) ) Wr_Image_Signal_Tiny(&image, fp_wr);
      if ( i==0 || i==(atoi(image.descript.n_lines)-1) ) Wr_Image_Signal(&image, fp_wr);
    }
    fseek(fp_rd,  atoi(image.descript.sar_rec_len) - sizeof(image.signal), SEEK_CUR);
  }
  }

  if ( strcmp(Data_Level,"1.5") == 0 )
  {
    /* read in processed data record */
    if ((nread = fread(&image.process, sizeof(image.process), 1, fp_rd)) < 1)
      {
      edit_error("Unable to read : Processed Data Record ", image_in);
    } else {
      /* --- Write Processed Data Record */
      Wr_Image_Process(&image, fp_wr);
    }
  }

/*******************************************************************/
/*******************************************************************/

  /* Close the files */
  if (fclose(fp_wr) != 0) {
    edit_error("Error closing file : ", image_ascii);
  }

  /* Close the file */
  if (fclose(fp_rd) != 0) {
    edit_error("Error closing file : ", image_in);
  }

} /* Rd_SAR_Image() */

/********************************************************************
*                                
* Function:    Rd_SAR_Trailer                 
*                                
* Abstract:    Read CEOS SAR Trailer File           
*                                
* Description:  This routine reads each record in the CEOS SAR 
*               Trailer File and outputs the data in each to an
*               ascii file. 
*                                
* Inputs:    filename:  filename of SAR Trailer file to read from
*                                
* Outputs:   filename_"ascii"  output file         
*                                
* Return Value:  non-zero:  if errors encountered       
*        zero:    if no errors encountered     
*                                
********************************************************************/

void Rd_SAR_Trailer()
{
  FILE  *fp_rd;       /* file pointer to file to read */
  FILE  *fp_wr;       /* file pointer to file to write */
  //FILE  *filebmp;

  int   nread;        /* number of elements read from disk */

  //char *bufferdata;
  //float *databmp;
  //char ColorMap[128];
  //int lig, col, Nlig, Ncol, MS, LS;
  //int NcolBMP, ExtraColBMP, IntCharBMP;
  //float Min, Max, xx;

/*******************************************************************/
/*******************************************************************/

  /* open the SAR Trailer file for reading */
  if ((fp_rd = fopen(trailer_in, "rb")) == NULL) {
    edit_error("Unable to open SAR Trailer File : ", trailer_in);
  }

  /* open/create an output file for writing */
  if ((fp_wr = fopen(trailer_ascii, "w+")) == NULL) {
    edit_error("Unable to open/create file : ", trailer_ascii );
  }

/*******************************************************************/
/*******************************************************************/

  /* read SAR Trailer file in from disk */

  /* read in file descriptor record */
  if ((nread = fread(&trailer, sizeof(trailer_file_struct), 1, fp_rd)) < 1)
    {
    edit_error("Unable to read : File Descriptor Record", trailer_in);
  } else {  
    /* --- Read File Descriptor Record */
/*
    Wr_Trailer_Descript(&trailer, fp_wr);

    Nlig = atoi(trailer.low_lines);
    Ncol = atoi(trailer.low_pixels);
    databmp = vector_float(Nlig*Ncol);
    bufferdata = vector_char(2*Ncol);
    
    strcpy(ColorMap,"gray");
    
    Min = INIT_MINMAX; Max = -Min;
    for (lig = 0; lig < Nlig; lig++) {
      fread(&bufferdata[0], sizeof(char), 2*Ncol, fp_rd);
      for (col = 0; col < Ncol; col++) {
        LS = bufferdata[2*col];
        MS = bufferdata[2*col + 1]; 
        if (LS < 0) LS = LS + 256; if (MS < 0) MS = MS + 256;
        databmp[lig*Ncol+col] =  (float) (256. * LS + MS);
        if (databmp[lig*Ncol+col] > Max) Max = databmp[lig*Ncol+col];
        if (databmp[lig*Ncol+col] < Min) Min = databmp[lig*Ncol+col];
      }
    }

    MinMaxContrastMedian(databmp, &Min, &Max, Nlig*Ncol);

    ExtraColBMP = (int) fmod(4 - (int) fmod(Ncol, 4), 4);
    NcolBMP = Ncol + ExtraColBMP;

  if ((filebmp = fopen(lowresimg_ascii, "wb")) == NULL)
    edit_error("ERREUR DANS L'OUVERTURE DU FICHIER", lowresimg_ascii);
    
    write_header_bmp_8bit(Nlig, Ncol, Max, Min, ColorMap, filebmp);

    for (lig = 0; lig < Nlig; lig++) {
      for (col = 0; col < Ncol; col++) {
        if (xx <= eps) xx = eps;
        xx = (databmp[lig*Ncol+col] - Min) / (Max - Min);
        if (xx < 0.) xx = 0.; if (xx > 1.) xx = 1.;
        databmp[lig*Ncol+col] = 1. + 254.*xx;
        }
      for (col = 0; col < Ncol; col++) {
        IntCharBMP = (int) databmp[lig*Ncol+col];
        bufferdata[col] = (char) IntCharBMP;
        }
      for (col = 0; col < ExtraColBMP; col++) {
        IntCharBMP = 0;
        bufferdata[Ncol + col] = (char) IntCharBMP;
        }
      fwrite(&bufferdata[0], sizeof(char), NcolBMP, filebmp);
      }
  fclose(filebmp);
*/    
  }

/*******************************************************************/
/*******************************************************************/

  /* Close input file */
  if (fclose(fp_rd) != 0) {
    edit_error("Error closing file : ", trailer_in);
    }

  /* Close output file */
  if (fclose(fp_wr) != 0) {
    edit_error("Error closing file : ", trailer_ascii);
  }

} /* Rd_SAR_Trailer */

/********************************************************************
*                                
* Function:    Wr_Leader_Descript               
*                                
* Abstract:    Write File Descriptor Record          
*                                
* Description:  This routine reads and prints the contents of the
*               SAR Leader file descriptor record.       
*                                
* Inputs:    fs:   pointer to structure of input file 
*         fp_wr;   pointer to output file       
*                                
* Return Value:  void                      
*                                
********************************************************************/

void Wr_Leader_Descript(leader_file_struct *fs, FILE *fp_wr)
{
  leader_descript_struct     s;  /* file descriptor structure */
  char  string[LONG_NAME_LEN];
  char  sstring[LONG_NAME_LEN];

  /* First, output a boxed title for the data */
  Title_Box(SARL_TITLE, DESCR_REC, fp_wr, 0, 0, NULL, 0);

  /* Now, output the header info */
  Write_Header(fp_wr, &fs->descript.hdr);

  /* Finally, output record specific data */

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.ascii_flag, sizeof(s.ascii_flag));
  justify(sstring, sizeof(s.ascii_flag), dest);
  sprintf(string, "%-45s%s\n", ASCII_FL, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.doc_format, sizeof(s.doc_format));
  justify(sstring, sizeof(s.doc_format), dest);
  sprintf(string, "%-45s%s\n", DOC_FORM, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.format_rev, sizeof(s.format_rev));
  justify(sstring, sizeof(s.format_rev), dest);
  sprintf(string, "%-45s%s\n", FORM_REV, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.rec_format_rev, sizeof(s.rec_format_rev));
  justify(sstring, sizeof(s.rec_format_rev), dest);
  sprintf(string, "%-45s%s\n", REC_REV, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.software_id, sizeof(s.software_id));
  justify(sstring, sizeof(s.software_id), dest);
  sprintf(string, "%-45s%s\n", SW_VERS, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.file_no, sizeof(s.file_no));
  justify(sstring, sizeof(s.file_no), dest);
  sprintf(string, "%-45s%s\n", FILE_NO, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.filename, sizeof(s.filename));
  justify(sstring, sizeof(s.filename), dest);
  sprintf(string, "%-45s%s\n", FILE_NAME, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.seq_flag, sizeof(s.seq_flag));
  justify(sstring, sizeof(s.seq_flag), dest);
  sprintf(string, "%-45s%s\n", FSEQ, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.seq_location, sizeof(s.seq_location));
  justify(sstring, sizeof(s.seq_location), dest);
  sprintf(string, "%-45s%s\n", LOC_NO, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.seq_field_len, sizeof(s.seq_field_len));
  justify(sstring, sizeof(s.seq_field_len), dest);
  sprintf(string, "%-45s%s\n", SEQ_FLD_L, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.code_flag, sizeof(s.code_flag));
  justify(sstring, sizeof(s.code_flag), dest);
  sprintf(string, "%-45s%s\n", LOC_TYPE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.code_location, sizeof(s.code_location));
  justify(sstring, sizeof(s.code_location), dest);
  sprintf(string, "%-45s%s\n", RCODE_LOC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.code_field_len, sizeof(s.code_field_len));
  justify(sstring, sizeof(s.code_field_len), dest);
  sprintf(string, "%-45s%s\n", RCODE_FLD_L, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_flag, sizeof(s.len_flag));
  justify(sstring, sizeof(s.len_flag), dest);
  sprintf(string, "%-45s%s\n", FLGT, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_location, sizeof(s.len_location));
  justify(sstring, sizeof(s.len_location), dest);
  sprintf(string, "%-45s%s\n", REC_LEN_LOC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_field_len, sizeof(s.len_field_len));
  justify(sstring, sizeof(s.len_field_len), dest);
  sprintf(string, "%-45s%s\n", REC_LEN_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_data_set_recs, sizeof(s.n_data_set_recs));
  justify(sstring, sizeof(s.n_data_set_recs), dest);
  sprintf(string, "%-45s%s\n", DS_FILE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_data_set, sizeof(s.len_data_set));
  justify(sstring, sizeof(s.len_data_set), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_map_proj_recs, sizeof(s.n_map_proj_recs));
  justify(sstring, sizeof(s.n_map_proj_recs), dest);
  sprintf(string, "%-45s%s\n", MP_FILE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_map_proj, sizeof(s.len_map_proj));
  justify(sstring, sizeof(s.len_map_proj), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_platf_recs, sizeof(s.n_platf_recs));
  justify(sstring, sizeof(s.n_platf_recs), dest);
  sprintf(string, "%-45s%s\n", PLATF_FILE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_platf, sizeof(s.len_platf));
  justify(sstring, sizeof(s.len_platf), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_att_recs, sizeof(s.n_att_recs));
  justify(sstring, sizeof(s.n_att_recs), dest);
  sprintf(string, "%-45s%s\n", ATT_FILE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_att, sizeof(s.len_att));
  justify(sstring, sizeof(s.len_att), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_radio_recs, sizeof(s.n_radio_recs));
  justify(sstring, sizeof(s.n_radio_recs), dest);
  sprintf(string, "%-45s%s\n", RADIO_FILE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_radio, sizeof(s.len_radio));
  justify(sstring, sizeof(s.len_radio), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_radio_comp_recs, sizeof(s.n_radio_comp_recs));
  justify(sstring, sizeof(s.n_radio_comp_recs), dest);
  sprintf(string, "%-45s%s\n", RADIOC_FILE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_radio_comp, sizeof(s.len_radio_comp));
  justify(sstring, sizeof(s.len_radio_comp), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_qual_recs, sizeof(s.n_qual_recs));
  justify(sstring, sizeof(s.n_qual_recs), dest);
  sprintf(string, "%-45s%s\n", QUAL_FILE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_qual, sizeof(s.len_qual));
  justify(sstring, sizeof(s.len_qual), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_hist_recs, sizeof(s.n_hist_recs));
  justify(sstring, sizeof(s.n_hist_recs), dest);
  sprintf(string, "%-45s%s\n", HIST_FILE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_hist, sizeof(s.len_hist));
  justify(sstring, sizeof(s.len_hist), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_spectra_recs, sizeof(s.n_spectra_recs));
  justify(sstring, sizeof(s.n_spectra_recs), dest);
  sprintf(string, "%-45s%s\n", SPEC_FILE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_spectra, sizeof(s.len_spectra));
  justify(sstring, sizeof(s.len_spectra), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_elev_recs, sizeof(s.n_elev_recs));
  justify(sstring, sizeof(s.n_elev_recs), dest);
  sprintf(string, "%-45s%s\n", ELEV_FILE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_elev, sizeof(s.len_elev));
  justify(sstring, sizeof(s.len_elev), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_update_recs, sizeof(s.n_update_recs));
  justify(sstring, sizeof(s.n_update_recs), dest);
  sprintf(string, "%-45s%s\n", UPD_FILE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_update, sizeof(s.len_update));
  justify(sstring, sizeof(s.len_update), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_annot_recs, sizeof(s.n_annot_recs));
  justify(sstring, sizeof(s.n_annot_recs), dest);
  sprintf(string, "%-45s%s\n", ANNOT_FILE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_annot, sizeof(s.len_annot));
  justify(sstring, sizeof(s.len_annot), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_proc_recs, sizeof(s.n_proc_recs));
  justify(sstring, sizeof(s.n_proc_recs), dest);
  sprintf(string, "%-45s%s\n", PROC_FILE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_proc, sizeof(s.len_proc));
  justify(sstring, sizeof(s.len_proc), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_calib_recs, sizeof(s.n_calib_recs));
  justify(sstring, sizeof(s.n_calib_recs), dest);
  sprintf(string, "%-45s%s\n", CAL_FILE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_calib, sizeof(s.len_calib));
  justify(sstring, sizeof(s.len_calib), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_ground, sizeof(s.n_ground));
  justify(sstring, sizeof(s.n_ground), dest);
  sprintf(string, "%-45s%s\n", GROUND_FILE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_ground, sizeof(s.len_ground));
  justify(sstring, sizeof(s.len_ground), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_facil_recs1, sizeof(s.n_facil_recs1));
  justify(sstring, sizeof(s.n_facil_recs1), dest);
  sprintf(string, "%-45s%s\n", FAC_FILE1, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_facil1, sizeof(s.len_facil1));
  justify(sstring, sizeof(s.len_facil1), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN1, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_facil_recs2, sizeof(s.n_facil_recs2));
  justify(sstring, sizeof(s.n_facil_recs2), dest);
  sprintf(string, "%-45s%s\n", FAC_FILE2, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_facil2, sizeof(s.len_facil2));
  justify(sstring, sizeof(s.len_facil2), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN2, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_facil_recs3, sizeof(s.n_facil_recs3));
  justify(sstring, sizeof(s.n_facil_recs3), dest);
  sprintf(string, "%-45s%s\n", FAC_FILE3, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_facil3, sizeof(s.len_facil3));
  justify(sstring, sizeof(s.len_facil3), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN3, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_facil_recs4, sizeof(s.n_facil_recs4));
  justify(sstring, sizeof(s.n_facil_recs4), dest);
  sprintf(string, "%-45s%s\n", FAC_FILE4, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_facil4, sizeof(s.len_facil4));
  justify(sstring, sizeof(s.len_facil4), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN4, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_facil_recs5, sizeof(s.n_facil_recs5));
  justify(sstring, sizeof(s.n_facil_recs5), dest);
  sprintf(string, "%-45s%s\n", FAC_FILE5, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_facil5, sizeof(s.len_facil5));
  justify(sstring, sizeof(s.len_facil5), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN5, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_facil_recs6, sizeof(s.n_facil_recs6));
  justify(sstring, sizeof(s.n_facil_recs6), dest);
  sprintf(string, "%-45s%s\n", FAC_FILE6, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_facil6, sizeof(s.len_facil6));
  justify(sstring, sizeof(s.len_facil6), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN6, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_facil_recs7, sizeof(s.n_facil_recs7));
  justify(sstring, sizeof(s.len_facil6), dest);
  sprintf(string, "%-45s%s\n", FAC_FILE7, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_facil7, sizeof(s.len_facil7));
  justify(sstring, sizeof(s.len_facil7), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN7, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_facil_recs8, sizeof(s.n_facil_recs8));
  justify(sstring, sizeof(s.n_facil_recs8), dest);
  sprintf(string, "%-45s%s\n", FAC_FILE8, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_facil8, sizeof(s.len_facil8));
  justify(sstring, sizeof(s.len_facil8), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN8, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_facil_recs9, sizeof(s.n_facil_recs9));
  justify(sstring, sizeof(s.n_facil_recs9), dest);
  sprintf(string, "%-45s%s\n", FAC_FILE9, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_facil9, sizeof(s.len_facil9));
  justify(sstring, sizeof(s.len_facil9), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN9, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_facil_recs10, sizeof(s.n_facil_recs10));
  justify(sstring, sizeof(s.n_facil_recs10), dest);
  sprintf(string, "%-45s%s\n", FAC_FILE10, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_facil10, sizeof(s.len_facil10));
  justify(sstring, sizeof(s.len_facil10), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN10, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_facil_recs11, sizeof(s.n_facil_recs11));
  justify(sstring, sizeof(s.n_facil_recs11), dest);
  sprintf(string, "%-45s%s\n", FAC_FILE11, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_facil11, sizeof(s.len_facil11));
  justify(sstring, sizeof(s.len_facil11), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN11, dest);
  fprintf(fp_wr, "%s", string);
} /* Wr_Leader_Descript */

/********************************************************************
*                                
* Function:    Wr_Leader_Data_Summary             
*                                
* Abstract:    Write Data Set Summary record         
*                                
* Description:  This routine reads and prints the contents of the 
*               data set summary record.            
*                                
* Inputs:    fs:   pointer to structure of input file 
*         fp_wr;   pointer to output file       
*                                
* Return Value:  void                      
*                                
********************************************************************/

void Wr_Leader_Data_Summary(leader_file_struct *fs, FILE *fp_wr)
{
  leader_data_summary_struct   s;  /* data summary structure */
  char  string[LONG_NAME_LEN];
  char  sstring[LONG_NAME_LEN];
  
  /* First, output a boxed title for the data */
  Title_Box(SARL_TITLE, DSS_REC, fp_wr, 0, 0, NULL, 0);

  /* Now, output the header info */
  Write_Header(fp_wr, &fs->data_set.hdr);

  /* Finally, output record specific data */

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.seq_no, sizeof(s.seq_no));
  justify(sstring, sizeof(s.seq_no), dest);
  sprintf(string, "%-45s%s\n", SEQ_NO, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.SAR_channel, sizeof(s.SAR_channel));
  sprintf(string, "%-45s%s\n", SAR_CHAN, sstring);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.site_id, sizeof(s.site_id));
  sprintf(string, "%-45s%s\n", SITE_ID, sstring);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.site_name, sizeof(s.site_name));
  sprintf(string, "%-45s%s\n", SITE_NAME, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.center_GMT, sizeof(s.center_GMT));
  sprintf(string, "%-45s%s\n", CTR_GMT, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.center_MET, sizeof(s.center_MET));
  sprintf(string, "%-45s%s\n", CTR_MET, sstring);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.lat_scene_ctr, sizeof(s.lat_scene_ctr));
  justify(sstring, sizeof(s.lat_scene_ctr), dest);
  sprintf(string, "%-45s%s\n", LAT_CTR, dest);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.long_scene_ctr, sizeof(s.long_scene_ctr));
  justify(sstring, sizeof(s.long_scene_ctr), dest);
  sprintf(string, "%-45s%s\n", LONG_CTR, dest);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.track_angle, sizeof(s.track_angle));
  justify(sstring, sizeof(s.track_angle), dest);
  sprintf(string, "%-45s%s\n", TRK_ANG_CTR, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.ellipsoid_name, sizeof(s.ellipsoid_name));
  sprintf(string, "%-45s%s\n", ELLIPSE_NAME, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.semimajor_axis, sizeof(s.semimajor_axis));
  justify(sstring, sizeof(s.semimajor_axis), dest);
  sprintf(string, "%-45s%s\n", MAJOR_AXIS, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.semiminor_axis, sizeof(s.semiminor_axis));
  justify(sstring, sizeof(s.semiminor_axis), dest);
  sprintf(string, "%-45s%s\n", MINOR_AXIS, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.earth_mass, sizeof(s.earth_mass));
  justify(sstring, sizeof(s.earth_mass), dest);
  sprintf(string, "%-45s%s\n", EARTH_MASS, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.gravit_constant, sizeof(s.gravit_constant));
  justify(sstring, sizeof(s.gravit_constant), dest);
  sprintf(string, "%-45s%s\n", GRAVIT_CST, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.ellipsoid_j2, sizeof(s.ellipsoid_j2));
  justify(sstring, sizeof(s.ellipsoid_j2), dest);
  sprintf(string, "%-45s%s\n", ELLIPSOIDJ2, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.ellipsoid_j3, sizeof(s.ellipsoid_j3));
  justify(sstring, sizeof(s.ellipsoid_j3), dest);
  sprintf(string, "%-45s%s\n", ELLIPSOIDJ3, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.ellipsoid_j4, sizeof(s.ellipsoid_j4));
  justify(sstring, sizeof(s.ellipsoid_j4), dest);
  sprintf(string, "%-45s%s\n", ELLIPSOIDJ4, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.terrain_ht, sizeof(s.terrain_ht));
  justify(sstring, sizeof(s.terrain_ht), dest);
  sprintf(string, "%-45s%s\n", TERR_HT, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.center_line, sizeof(s.center_line));
  justify(sstring, sizeof(s.center_line), dest);
  sprintf(string, "%-45s%s\n", CTR_LINE, dest);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.center_pixel, sizeof(s.center_pixel));
  justify(sstring, sizeof(s.center_pixel), dest);
  sprintf(string, "%-45s%s\n", CTR_PIX, dest);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.image_length_km, sizeof(s.image_length_km));
  justify(sstring, sizeof(s.image_length_km), dest);
  sprintf(string, "%-45s%s\n", IMG_LEN, dest);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.image_width_km, sizeof(s.image_width_km));
  justify(sstring, sizeof(s.image_width_km), dest);
  sprintf(string, "%-45s%s\n", IMG_WID, dest);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.n_channels, sizeof(s.n_channels));
  justify(sstring, sizeof(s.n_channels), dest);
  sprintf(string, "%-45s%s\n", N_CHAN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.platform_id, sizeof(s.platform_id));
  sprintf(string, "%-45s%s\n", PLAT_ID, sstring);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.sensor_id.sensid, sizeof(s.sensor_id.sensid));
  sprintf(string, "%-45s%s\n", SENSE_ID, sstring);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.sensor_id.freq, sizeof(s.sensor_id.freq));
  sprintf(string, "%-45s%s\n", BAND, sstring);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.sensor_id.res, sizeof(s.sensor_id.res));
  sprintf(string, "%-45s%s\n", RESOL, sstring);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.sensor_id.acq, sizeof(s.sensor_id.acq));
  sprintf(string, "%-45s%s\n", ACQ, sstring);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.sensor_id.tx, sizeof(s.sensor_id.tx));
  sprintf(string, "%-45s%s\n", TX_POL, sstring);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.sensor_id.rx, sizeof(s.sensor_id.rx));
  sprintf(string, "%-45s%s\n", RX_POL, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.datatake_id, sizeof(s.datatake_id));
  justify(sstring, sizeof(s.datatake_id), dest);
  sprintf(string, "%-45s%s\n", DT_ID, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.craft_lat, sizeof(s.craft_lat));
  justify(sstring, sizeof(s.craft_lat), dest);
  sprintf(string, "%-45s%s\n", CRAFT_LAT, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.craft_long, sizeof(s.craft_long));
  justify(sstring, sizeof(s.craft_long), dest);
  sprintf(string, "%-45s%s\n", CRAFT_LONG, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.platform_heading, sizeof(s.platform_heading));
  justify(sstring, sizeof(s.platform_heading), dest);
  sprintf(string, "%-45s%s\n", PLAT_HD, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.clock_angle, sizeof(s.clock_angle));
  justify(sstring, sizeof(s.clock_angle), dest);
  sprintf(string, "%-45s%s\n", CLOCK_ANG, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.incid_angle_ctr, sizeof(s.incid_angle_ctr));
  justify(sstring, sizeof(s.incid_angle_ctr), dest);
  sprintf(string, "%-45s%s\n", INC_ANGLE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.wavelength, sizeof(s.wavelength));
  justify(sstring, sizeof(s.wavelength), dest);
  sprintf(string, "%-45s%s\n", WAVE_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.motion_comp, sizeof(s.motion_comp));
  sprintf(string, "%-45s%s\n", MOTION, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.rg_code_spec, sizeof(s.rg_code_spec));
  sprintf(string, "%-45s%s\n", CD_SPEC, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.rg_pulse_amp1, sizeof(s.rg_pulse_amp1));
  justify(sstring, sizeof(s.rg_pulse_amp1), dest);
  sprintf(string, "%-45s%s\n", CHIRP_A1, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.rg_pulse_amp2, sizeof(s.rg_pulse_amp2));
  justify(sstring, sizeof(s.rg_pulse_amp2), dest);
  sprintf(string, "%-45s%s\n", CHIRP_A2, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.rg_pulse_amp3, sizeof(s.rg_pulse_amp3));
  justify(sstring, sizeof(s.rg_pulse_amp3), dest);
  sprintf(string, "%-45s%s\n", CHIRP_A3, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.rg_pulse_amp4, sizeof(s.rg_pulse_amp4));
  justify(sstring, sizeof(s.rg_pulse_amp4), dest);
  sprintf(string, "%-45s%s\n", CHIRP_A4, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.rg_pulse_amp5, sizeof(s.rg_pulse_amp5));
  justify(sstring, sizeof(s.rg_pulse_amp5), dest);
  sprintf(string, "%-45s%s\n", CHIRP_A5, dest);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.rg_pulse_phase1, sizeof(s.rg_pulse_phase1));
  justify(sstring, sizeof(s.rg_pulse_phase1), dest);
  sprintf(string, "%-45s%s\n", CHIRP_P1, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.rg_pulse_phase2, sizeof(s.rg_pulse_phase2));
  justify(sstring, sizeof(s.rg_pulse_phase2), dest);
  sprintf(string, "%-45s%s\n", CHIRP_P2, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.rg_pulse_phase3, sizeof(s.rg_pulse_phase3));
  justify(sstring, sizeof(s.rg_pulse_phase3), dest);
  sprintf(string, "%-45s%s\n", CHIRP_P3, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.rg_pulse_phase4, sizeof(s.rg_pulse_phase4));
  justify(sstring, sizeof(s.rg_pulse_phase4), dest);
  sprintf(string, "%-45s%s\n", CHIRP_P4, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.rg_pulse_phase5, sizeof(s.rg_pulse_phase5));
  justify(sstring, sizeof(s.rg_pulse_phase5), dest);
  sprintf(string, "%-45s%s\n", CHIRP_P5, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.down_link_index, sizeof(s.down_link_index));
  justify(sstring, sizeof(s.down_link_index), dest);
  sprintf(string, "%-45s%s\n", DOWN_LINK, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.rg_sampling_rate, sizeof(s.rg_sampling_rate));
  justify(sstring, sizeof(s.rg_sampling_rate), dest);
  sprintf(string, "%-45s%s\n", RG_SAMPL, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.echo_delay, sizeof(s.echo_delay));
  justify(sstring, sizeof(s.echo_delay), dest);
  sprintf(string, "%-45s%s\n", ECHO_DLAY, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.rg_pulse_len, sizeof(s.rg_pulse_len));
  justify(sstring, sizeof(s.rg_pulse_len), dest);
  sprintf(string, "%-45s%s\n", PULSE_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.base_band_conv, sizeof(s.base_band_conv));
  sprintf(string, "%-45s%s\n", BAND_CONV, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.rg_compressed, sizeof(s.rg_compressed));
  sprintf(string, "%-45s%s\n", COMPR_FLAG, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.rcv_gain_like, sizeof(s.rcv_gain_like));
  justify(sstring, sizeof(s.rcv_gain_like), dest);
  sprintf(string, "%-45s%s\n", LIKE_GAIN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.rcv_gain_cross, sizeof(s.rcv_gain_cross));
  justify(sstring, sizeof(s.rcv_gain_cross), dest);
  sprintf(string, "%-45s%s\n", CROSS_GAIN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.quant_bits, sizeof(s.quant_bits));
  justify(sstring, sizeof(s.quant_bits), dest);
  sprintf(string, "%-45s%s\n", Q_BITS, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.quant_descr, sizeof(s.quant_descr));
  sprintf(string, "%-45s%s\n", QUANT_DES, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.dc_bias_i_comp, sizeof(s.dc_bias_i_comp));
  justify(sstring, sizeof(s.dc_bias_i_comp), dest);
  sprintf(string, "%-45s%s\n", BIAS_I, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.dc_bias_q_comp, sizeof(s.dc_bias_q_comp));
  justify(sstring, sizeof(s.dc_bias_q_comp), dest);
  sprintf(string, "%-45s%s\n", BIAS_Q, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.gain_imbalance, sizeof(s.gain_imbalance));
  justify(sstring, sizeof(s.gain_imbalance), dest);
  sprintf(string, "%-45s%s\n", GAIN_IM, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.elect_boresight, sizeof(s.elect_boresight));
  justify(sstring, sizeof(s.elect_boresight), dest);
  sprintf(string, "%-45s%s\n", ELECT_BORE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.mech_boresight, sizeof(s.mech_boresight));
  justify(sstring, sizeof(s.mech_boresight), dest);
  sprintf(string, "%-45s%s\n", MECH_BORE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.echo_tracker_flag, sizeof(s.echo_tracker_flag));
  sprintf(string, "%-45s%s\n", ECHO_TRK, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.prf, sizeof(s.prf));
  justify(sstring, sizeof(s.prf), dest);
  sprintf(string, "%-45s%s\n", PRF, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.elev_beamwidth, sizeof(s.elev_beamwidth));
  justify(sstring, sizeof(s.elev_beamwidth), dest);
  sprintf(string, "%-45s%s\n", RG_BEAMW, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.az_beamwidth, sizeof(s.az_beamwidth));
  justify(sstring, sizeof(s.az_beamwidth), dest);
  sprintf(string, "%-45s%s\n", AZ_BEAMW, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.satellite_time, sizeof(s.satellite_time));
  justify(sstring, sizeof(s.satellite_time), dest);
  sprintf(string, "%-45s%s\n", SAT_TIME, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.satellite_clock, sizeof(s.satellite_clock));
  justify(sstring, sizeof(s.satellite_clock), dest);
  sprintf(string, "%-45s%s\n", SAT_CLOCK, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.satellite_incr, sizeof(s.satellite_incr));
  justify(sstring, sizeof(s.satellite_incr), dest);
  sprintf(string, "%-45s%s\n", SAT_INCR, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.proc_facility, sizeof(s.proc_facility));
  sprintf(string, "%-45s%s\n", PROC_FAC, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.hw_version, sizeof(s.hw_version));
  sprintf(string, "%-45s%s\n", HW_VERS, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.sw_version, sizeof(s.sw_version));
  justify(sstring, sizeof(s.sw_version), dest);
  sprintf(string, "%-45s%s\n", SW_VERS, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.process_code, sizeof(s.process_code));
  sprintf(string, "%-45s%s\n", PROC_CODE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.product_code, sizeof(s.product_code));
  sprintf(string, "%-45s%s\n", PROD_CODE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.product_type, sizeof(s.product_type));
  sprintf(string, "%-45s%s\n", PROD_TYPE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.proc_algorithm, sizeof(s.proc_algorithm));
  sprintf(string, "%-45s%s\n", PROC_ALG, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.n_looks_az, sizeof(s.n_looks_az));
  justify(sstring, sizeof(s.n_looks_az), dest);
  sprintf(string, "%-45s%s\n", N_LOOKS_AZ, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.n_looks_rg, sizeof(s.n_looks_rg));
  justify(sstring, sizeof(s.n_looks_rg), dest);
  sprintf(string, "%-45s%s\n", N_LOOKS_RG, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.bandwidth_az, sizeof(s.bandwidth_az));
  justify(sstring, sizeof(s.bandwidth_az), dest);
  sprintf(string, "%-45s%s\n", BNDWTH_AZ, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.bandwidth_rg, sizeof(s.bandwidth_rg));
  justify(sstring, sizeof(s.bandwidth_rg), dest);
  sprintf(string, "%-45s%s\n", BNDWTH_RG, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.az_bandwidth, sizeof(s.az_bandwidth));
  justify(sstring, sizeof(s.az_bandwidth), dest);
  sprintf(string, "%-45s%s\n", AZ_BNDWTH, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.rg_bandwidth, sizeof(s.rg_bandwidth));
  justify(sstring, sizeof(s.rg_bandwidth), dest);
  sprintf(string, "%-45s%s\n", RG_BNDWTH, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.az_weighting, sizeof(s.az_weighting));
  sprintf(string, "%-45s%s\n", AZ_WEIGHT, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.rg_weighting, sizeof(s.rg_weighting));
  sprintf(string, "%-45s%s\n", RG_WEIGHT, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.hddc_id, sizeof(s.hddc_id));
  sprintf(string, "%-45s%s\n", HDDC, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.rg_nom_res, sizeof(s.rg_nom_res));
  justify(sstring, sizeof(s.rg_nom_res), dest);
  sprintf(string, "%-45s%s\n", RG_RES, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.az_nom_res, sizeof(s.az_nom_res));
  justify(sstring, sizeof(s.az_nom_res), dest);
  sprintf(string, "%-45s%s\n", AZ_RES, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.gain, sizeof(s.gain));
  justify(sstring, sizeof(s.gain), dest);
  sprintf(string, "%-45s%s\n", GAIN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.bias, sizeof(s.bias));
  justify(sstring, sizeof(s.bias), dest);
  sprintf(string, "%-45s%s\n", BIAS, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.along_Doppler_1, sizeof(s.along_Doppler_1));
  justify(sstring, sizeof(s.along_Doppler_1), dest);
  sprintf(string, "%-45s%s\n", AL_DOPPLER1, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.along_Doppler_2, sizeof(s.along_Doppler_2));
  justify(sstring, sizeof(s.along_Doppler_2), dest);
  sprintf(string, "%-45s%s\n", AL_DOPPLER2, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.along_Doppler_3, sizeof(s.along_Doppler_3));
  justify(sstring, sizeof(s.along_Doppler_3), dest);
  sprintf(string, "%-45s%s\n", AL_DOPPLER3, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.cross_Doppler_1, sizeof(s.cross_Doppler_1));
  justify(sstring, sizeof(s.cross_Doppler_1), dest);
  sprintf(string, "%-45s%s\n", AC_DOPPLER1, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.cross_Doppler_2, sizeof(s.cross_Doppler_2));
  justify(sstring, sizeof(s.cross_Doppler_2), dest);
  sprintf(string, "%-45s%s\n", AC_DOPPLER2, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.cross_Doppler_3, sizeof(s.cross_Doppler_3));
  justify(sstring, sizeof(s.cross_Doppler_3), dest);
  sprintf(string, "%-45s%s\n", AC_DOPPLER3, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.rg_time_dir, sizeof(s.rg_time_dir));
  sprintf(string, "%-45s%s\n", RG_TIME, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.az_time_dir, sizeof(s.az_time_dir));
  sprintf(string, "%-45s%s\n", AZ_TIME, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.along_Doppler_4, sizeof(s.along_Doppler_4));
  justify(sstring, sizeof(s.along_Doppler_4), dest);
  sprintf(string, "%-45s%s\n", AL_DOPPLER4, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.along_Doppler_5, sizeof(s.along_Doppler_5));
  justify(sstring, sizeof(s.along_Doppler_5), dest);
  sprintf(string, "%-45s%s\n", AL_DOPPLER5, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.along_Doppler_6, sizeof(s.along_Doppler_6));
  justify(sstring, sizeof(s.along_Doppler_6), dest);
  sprintf(string, "%-45s%s\n", AL_DOPPLER6, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.cross_Doppler_4, sizeof(s.cross_Doppler_4));
  justify(sstring, sizeof(s.cross_Doppler_4), dest);
  sprintf(string, "%-45s%s\n", AC_DOPPLER4, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.cross_Doppler_5, sizeof(s.cross_Doppler_5));
  justify(sstring, sizeof(s.cross_Doppler_5), dest);
  sprintf(string, "%-45s%s\n", AC_DOPPLER5, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.cross_Doppler_6, sizeof(s.cross_Doppler_6));
  justify(sstring, sizeof(s.cross_Doppler_6), dest);
  sprintf(string, "%-45s%s\n", AC_DOPPLER6, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.line_content, sizeof(s.line_content));
  sprintf(string, "%-45s%s\n", LINE_CON, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.clutter_lock_flag, sizeof(s.clutter_lock_flag));
  sprintf(string, "%-45s%s\n", CLUTTER, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.autofocus_flag, sizeof(s.autofocus_flag));
  sprintf(string, "%-45s%s\n", AUTOFOCUS, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.line_spacing, sizeof(s.line_spacing));
  justify(sstring, sizeof(s.line_spacing), dest);
  sprintf(string, "%-45s%s\n", LINE_SP, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.pixel_spacing, sizeof(s.pixel_spacing));
  justify(sstring, sizeof(s.pixel_spacing), dest);
  sprintf(string, "%-45s%s\n", PIXEL_SP, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.rg_compression, sizeof(s.rg_compression));
  sprintf(string, "%-45s%s\n", RG_COMPR, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.Doppler_freq1, sizeof(s.Doppler_freq1));
  justify(sstring, sizeof(s.Doppler_freq1), dest);
  sprintf(string, "%-45s%s\n", DOPPLER_F1, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.Doppler_freq2, sizeof(s.Doppler_freq2));
  justify(sstring, sizeof(s.Doppler_freq2), dest);
  sprintf(string, "%-45s%s\n", DOPPLER_F2, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.calib_data, sizeof(s.calib_data));
  justify(sstring, sizeof(s.calib_data), dest);
  sprintf(string, "%-45s%s\n", CALIB_DATA, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.calib_line1, sizeof(s.calib_line1));
  justify(sstring, sizeof(s.calib_line1), dest);
  sprintf(string, "%-45s%s\n", CALIB_LINE1, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.calib_line2, sizeof(s.calib_line2));
  justify(sstring, sizeof(s.calib_line2), dest);
  sprintf(string, "%-45s%s\n", CALIB_LINE2, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.calib_line3, sizeof(s.calib_line3));
  justify(sstring, sizeof(s.calib_line3), dest);
  sprintf(string, "%-45s%s\n", CALIB_LINE3, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.calib_line4, sizeof(s.calib_line4));
  justify(sstring, sizeof(s.calib_line4), dest);
  sprintf(string, "%-45s%s\n", CALIB_LINE4, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.prf_indicator, sizeof(s.prf_indicator));
  justify(sstring, sizeof(s.prf_indicator), dest);
  sprintf(string, "%-45s%s\n", PRF_INDIC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.prf_line, sizeof(s.prf_line));
  justify(sstring, sizeof(s.prf_line), dest);
  sprintf(string, "%-45s%s\n", PRF_LINE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.yew_steering, sizeof(s.yew_steering));
  justify(sstring, sizeof(s.yew_steering), dest);
  sprintf(string, "%-45s%s\n", YEW_STEERING, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.para_number, sizeof(s.para_number));
  justify(sstring, sizeof(s.para_number), dest);
  sprintf(string, "%-45s%s\n", PARA_NUMBER, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.offnadir_angle, sizeof(s.offnadir_angle));
  justify(sstring, sizeof(s.offnadir_angle), dest);
  sprintf(string, "%-45s%s\n", OFFNADIR_ANG, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.beam_number, sizeof(s.beam_number));
  justify(sstring, sizeof(s.beam_number), dest);
  sprintf(string, "%-45s%s\n", BEAM_NUMBER, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.inc_angle_a0, sizeof(s.inc_angle_a0));
  justify(sstring, sizeof(s.inc_angle_a0), dest);
  sprintf(string, "%-45s%s\n", INC_ANG_A0, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.inc_angle_a1, sizeof(s.inc_angle_a1));
  justify(sstring, sizeof(s.inc_angle_a1), dest);
  sprintf(string, "%-45s%s\n", INC_ANG_A1, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.inc_angle_a2, sizeof(s.inc_angle_a2));
  justify(sstring, sizeof(s.inc_angle_a2), dest);
  sprintf(string, "%-45s%s\n", INC_ANG_A2, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.inc_angle_a3, sizeof(s.inc_angle_a3));
  justify(sstring, sizeof(s.inc_angle_a3), dest);
  sprintf(string, "%-45s%s\n", INC_ANG_A3, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.inc_angle_a4, sizeof(s.inc_angle_a4));
  justify(sstring, sizeof(s.inc_angle_a4), dest);
  sprintf(string, "%-45s%s\n", INC_ANG_A4, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.inc_angle_a5, sizeof(s.inc_angle_a5));
  justify(sstring, sizeof(s.inc_angle_a5), dest);
  sprintf(string, "%-45s%s\n", INC_ANG_A5, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.annot_pts, sizeof(s.annot_pts));
  justify(sstring, sizeof(s.annot_pts), dest);
  sprintf(string, "%-45s%s\n", N_ANNOT, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.annot_line, sizeof(s.annot_line));
  sprintf(string, "%-45s%s\n", ANNOT_LINE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.annot_pixel, sizeof(s.annot_pixel));
  sprintf(string, "%-45s%s\n", ANNOT_PIXEL, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.annot_text, sizeof(s.annot_text));
  sprintf(string, "%-45s%s\n", ANNOT_TEXT, sstring);
  fprintf(fp_wr, "%s", string);

  //memset(sstring, 0, sizeof(sstring));
  //strncpy(sstring, fs->data_set.annot_text2, sizeof(s.annot_text2));
  //sprintf(string, "%-45s%s\n", ANNOT_TEXT2, sstring);
  //fprintf(fp_wr, "%s", string);

} /* Wr_Leader_Data_Summary */

/********************************************************************
*                                
* Function:    Wr_Leader_Map_Proj               
*                                
* Abstract:    Write Map Projection Record           
*                                
* Description:  This routine reads and prints the contents of the
*               map projection data record.           
*                                
* Inputs:    fs:   pointer to structure of input file 
*         fp_wr;   pointer to output file       
*                                
* Return Value:  void                      
*                                
********************************************************************/

void Wr_Leader_Map_Proj(leader_file_struct *fs, FILE *fp_wr)
{
  leader_map_proj_struct     s;  /* map projection structure */
  char  string[LONG_NAME_LEN];
  char  sstring[LONG_NAME_LEN];

  /* First, output a boxed title for the data */
  Title_Box(SARL_TITLE, MAP_REC, fp_wr, 0, 0, NULL, 0);

  /* Now, output the header info */
  Write_Header(fp_wr, &fs->map_proj.hdr);

  /* Finally, output record specific data */

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.map_proj_descr, sizeof(s.map_proj_descr));
  sprintf(string, "%-45s%s\n", MP_DESCR, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.n_pixels, sizeof(s.n_pixels));
  justify(sstring, sizeof(s.n_pixels), dest);
  sprintf(string, "%-45s%s\n", N_PIXELS, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.n_lines, sizeof(s.n_lines));
  justify(sstring, sizeof(s.n_lines), dest);
  sprintf(string, "%-45s%s\n", N_LINES, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.pix_spacing, sizeof(s.pix_spacing));
  justify(sstring, sizeof(s.pix_spacing), dest);
  sprintf(string, "%-45s%s\n", PIXEL_SP, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.line_spacing, sizeof(s.line_spacing));
  justify(sstring, sizeof(s.line_spacing), dest);
  sprintf(string, "%-45s%s\n", LINE_SP, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.orientation, sizeof(s.orientation));
  justify(sstring, sizeof(s.orientation), dest);
  sprintf(string, "%-45s%s\n", ORIENT, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.platform_incl, sizeof(s.platform_incl));
  justify(sstring, sizeof(s.platform_incl), dest);
  sprintf(string, "%-45s%s\n", PL_INCL, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.ascending_node, sizeof(s.ascending_node));
  justify(sstring, sizeof(s.ascending_node), dest);
  sprintf(string, "%-45s%s\n", AS_NODE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.platform_dist, sizeof(s.platform_dist));
  justify(sstring, sizeof(s.platform_dist), dest);
  sprintf(string, "%-45s%s\n", PL_DIST, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.geodet_alt, sizeof(s.geodet_alt));
  justify(sstring, sizeof(s.geodet_alt), dest);
  sprintf(string, "%-45s%s\n", ALTITUDE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.ground_speed, sizeof(s.ground_speed));
  justify(sstring, sizeof(s.ground_speed), dest);
  sprintf(string, "%-45s%s\n", SPEED, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.platform_heading, sizeof(s.platform_heading));
  justify(sstring, sizeof(s.platform_heading), dest);
  sprintf(string, "%-45s%s\n", PLAT_HD, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.ellipsoid_name, sizeof(s.ellipsoid_name));
  justify(sstring, sizeof(s.ellipsoid_name), dest);
  sprintf(string, "%-45s%s\n", ELLIPSE_NAME, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.semimajor_axis, sizeof(s.semimajor_axis));
  justify(sstring, sizeof(s.semimajor_axis), dest);
  sprintf(string, "%-45s%s\n", MAJOR_AXIS_M, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.semiminor_axis, sizeof(s.semiminor_axis));
  justify(sstring, sizeof(s.semiminor_axis), dest);
  sprintf(string, "%-45s%s\n", MINOR_AXIS_M, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.datum_shift_para1, sizeof(s.datum_shift_para1));
  justify(sstring, sizeof(s.datum_shift_para1), dest);
  sprintf(string, "%-45s%s\n", DATUM_SHIFT1, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.datum_shift_para2, sizeof(s.datum_shift_para2));
  justify(sstring, sizeof(s.datum_shift_para2), dest);
  sprintf(string, "%-45s%s\n", DATUM_SHIFT2, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.datum_shift_para3, sizeof(s.datum_shift_para3));
  justify(sstring, sizeof(s.datum_shift_para3), dest);
  sprintf(string, "%-45s%s\n", DATUM_SHIFT3, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.datum_shift_para4, sizeof(s.datum_shift_para4));
  justify(sstring, sizeof(s.datum_shift_para4), dest);
  sprintf(string, "%-45s%s\n", DATUM_SHIFT4, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.datum_shift_para5, sizeof(s.datum_shift_para5));
  justify(sstring, sizeof(s.datum_shift_para5), dest);
  sprintf(string, "%-45s%s\n", DATUM_SHIFT5, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.datum_shift_para6, sizeof(s.datum_shift_para6));
  justify(sstring, sizeof(s.datum_shift_para6), dest);
  sprintf(string, "%-45s%s\n", DATUM_SHIFT6, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.scale_factor1, sizeof(s.scale_factor1));
  justify(sstring, sizeof(s.scale_factor1), dest);
  sprintf(string, "%-45s%s\n", SCALE1, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.map_projection, sizeof(s.map_projection));
  justify(sstring, sizeof(s.map_projection), dest);
  sprintf(string, "%-45s%s\n", MAP_PROJ, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.utm_descriptor, sizeof(s.utm_descriptor));
  justify(sstring, sizeof(s.utm_descriptor), dest);
  sprintf(string, "%-45s%s\n", UTM_DESC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.utm_zone, sizeof(s.utm_zone));
  justify(sstring, sizeof(s.utm_zone), dest);
  sprintf(string, "%-45s%s\n", UTM_ZONE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.map_origin_fe1, sizeof(s.map_origin_fe1));
  justify(sstring, sizeof(s.map_origin_fe1), dest);
  sprintf(string, "%-45s%s\n", MAP_FE1, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.map_origin_fn1, sizeof(s.map_origin_fn1));
  justify(sstring, sizeof(s.map_origin_fn1), dest);
  sprintf(string, "%-45s%s\n", MAP_FN1, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.center_proj_long1, sizeof(s.center_proj_long1));
  justify(sstring, sizeof(s.center_proj_long1), dest);
  sprintf(string, "%-45s%s\n", CTR_PRJ_LO1, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.center_proj_lat1, sizeof(s.center_proj_lat1));
  justify(sstring, sizeof(s.center_proj_lat1), dest);
  sprintf(string, "%-45s%s\n", CTR_PRJ_LA1, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.stand_para_1, sizeof(s.stand_para_1));
  justify(sstring, sizeof(s.stand_para_1), dest);
  sprintf(string, "%-45s%s\n", STAND_PARA1, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.stand_para_2, sizeof(s.stand_para_2));
  justify(sstring, sizeof(s.stand_para_2), dest);
  sprintf(string, "%-45s%s\n", STAND_PARA2, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.scale_factor2, sizeof(s.scale_factor2));
  justify(sstring, sizeof(s.scale_factor2), dest);
  sprintf(string, "%-45s%s\n", SCALE2, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.ups_descriptor, sizeof(s.ups_descriptor));
  justify(sstring, sizeof(s.ups_descriptor), dest);
  sprintf(string, "%-45s%s\n", UPS_DESC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.center_proj_long2, sizeof(s.center_proj_long2));
  justify(sstring, sizeof(s.center_proj_long2), dest);
  sprintf(string, "%-45s%s\n", CTR_PRJ_LO2, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.center_proj_lat2, sizeof(s.center_proj_lat2));
  justify(sstring, sizeof(s.center_proj_lat2), dest);
  sprintf(string, "%-45s%s\n", CTR_PRJ_LA2, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.scale_factor3, sizeof(s.scale_factor3));
  justify(sstring, sizeof(s.scale_factor3), dest);
  sprintf(string, "%-45s%s\n", SCALE3, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.proj_desc, sizeof(s.proj_desc));
  justify(sstring, sizeof(s.proj_desc), dest);
  sprintf(string, "%-45s%s\n", PROJ_DESC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.map_origin_fe2, sizeof(s.map_origin_fe2));
  justify(sstring, sizeof(s.map_origin_fe2), dest);
  sprintf(string, "%-45s%s\n", MAP_FE2, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.map_origin_fn2, sizeof(s.map_origin_fn2));
  justify(sstring, sizeof(s.map_origin_fn2), dest);
  sprintf(string, "%-45s%s\n", MAP_FN2, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.center_proj_long3, sizeof(s.center_proj_long3));
  justify(sstring, sizeof(s.center_proj_long3), dest);
  sprintf(string, "%-45s%s\n", CTR_PRJ_LO3, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.center_proj_lat3, sizeof(s.center_proj_lat3));
  justify(sstring, sizeof(s.center_proj_lat3), dest);
  sprintf(string, "%-45s%s\n", CTR_PRJ_LA3, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.stand_para_3, sizeof(s.stand_para_3));
  justify(sstring, sizeof(s.stand_para_3), dest);
  sprintf(string, "%-45s%s\n", STAND_PARA3, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.stand_para_4, sizeof(s.stand_para_4));
  justify(sstring, sizeof(s.stand_para_4), dest);
  sprintf(string, "%-45s%s\n", STAND_PARA4, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.near_early_no, sizeof(s.near_early_no));
  justify(sstring, sizeof(s.near_early_no), dest);
  sprintf(string, "%-45s%s\n", NE_NO, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.near_early_ea, sizeof(s.near_early_ea));
  justify(sstring, sizeof(s.near_early_ea), dest);
  sprintf(string, "%-45s%s\n", NE_EA, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.far_early_no, sizeof(s.far_early_no));
  justify(sstring, sizeof(s.far_early_no), dest);
  sprintf(string, "%-45s%s\n", FE_NO, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.far_early_ea, sizeof(s.far_early_ea));
  justify(sstring, sizeof(s.far_early_ea), dest);
  sprintf(string, "%-45s%s\n", FE_EA, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.far_late_no, sizeof(s.far_late_no));
  justify(sstring, sizeof(s.far_late_no), dest);
  sprintf(string, "%-45s%s\n", FL_NO, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.far_late_ea, sizeof(s.far_late_ea));
  justify(sstring, sizeof(s.far_late_ea), dest);
  sprintf(string, "%-45s%s\n", FL_EA, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.near_late_no, sizeof(s.near_late_no));
  justify(sstring, sizeof(s.near_late_no), dest);
  sprintf(string, "%-45s%s\n", NL_NO, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.near_late_ea, sizeof(s.near_late_ea));
  justify(sstring, sizeof(s.near_late_ea), dest);
  sprintf(string, "%-45s%s\n", NL_EA, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.near_early_lat, sizeof(s.near_early_lat));
  justify(sstring, sizeof(s.near_early_lat), dest);
  sprintf(string, "%-45s%s\n", NE_LAT, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.near_early_long, sizeof(s.near_early_long));
  justify(sstring, sizeof(s.near_early_long), dest);
  sprintf(string, "%-45s%s\n", NE_LONG, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.far_early_lat, sizeof(s.far_early_lat));
  justify(sstring, sizeof(s.far_early_lat), dest);
  sprintf(string, "%-45s%s\n", FE_LAT, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.far_early_long, sizeof(s.far_early_long));
  justify(sstring, sizeof(s.far_early_long), dest);
  sprintf(string, "%-45s%s\n", FE_LONG, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.far_late_lat, sizeof(s.far_late_lat));
  justify(sstring, sizeof(s.far_late_lat), dest);
  sprintf(string, "%-45s%s\n", FL_LAT, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.far_late_long, sizeof(s.far_late_long));
  justify(sstring, sizeof(s.far_late_long), dest);
  sprintf(string, "%-45s%s\n", FL_LONG, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.near_late_lat, sizeof(s.near_late_lat));
  justify(sstring, sizeof(s.near_late_lat), dest);
  sprintf(string, "%-45s%s\n", NL_LAT, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.near_late_long, sizeof(s.near_late_long));
  justify(sstring, sizeof(s.near_late_long), dest);
  sprintf(string, "%-45s%s\n", NL_LONG, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.coeff_aij_1, sizeof(s.coeff_aij_1));
  justify(sstring, sizeof(s.coeff_aij_1), dest);
  sprintf(string, "%-45s%s\n", COEFF_A11, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.coeff_aij_2, sizeof(s.coeff_aij_2));
  justify(sstring, sizeof(s.coeff_aij_2), dest);
  sprintf(string, "%-45s%s\n", COEFF_A12, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.coeff_aij_3, sizeof(s.coeff_aij_3));
  justify(sstring, sizeof(s.coeff_aij_3), dest);
  sprintf(string, "%-45s%s\n", COEFF_A13, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.coeff_aij_4, sizeof(s.coeff_aij_4));
  justify(sstring, sizeof(s.coeff_aij_4), dest);
  sprintf(string, "%-45s%s\n", COEFF_A14, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.coeff_aij_5, sizeof(s.coeff_aij_5));
  justify(sstring, sizeof(s.coeff_aij_5), dest);
  sprintf(string, "%-45s%s\n", COEFF_A21, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.coeff_aij_6, sizeof(s.coeff_aij_6));
  justify(sstring, sizeof(s.coeff_aij_6), dest);
  sprintf(string, "%-45s%s\n", COEFF_A22, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.coeff_aij_7, sizeof(s.coeff_aij_7));
  justify(sstring, sizeof(s.coeff_aij_7), dest);
  sprintf(string, "%-45s%s\n", COEFF_A23, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.coeff_aij_8, sizeof(s.coeff_aij_8));
  justify(sstring, sizeof(s.coeff_aij_8), dest);
  sprintf(string, "%-45s%s\n", COEFF_A24, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.coeff_bij_1, sizeof(s.coeff_bij_1));
  justify(sstring, sizeof(s.coeff_bij_1), dest);
  sprintf(string, "%-45s%s\n", COEFF_B11, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.coeff_bij_2, sizeof(s.coeff_bij_2));
  justify(sstring, sizeof(s.coeff_bij_2), dest);
  sprintf(string, "%-45s%s\n", COEFF_B12, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.coeff_bij_3, sizeof(s.coeff_bij_3));
  justify(sstring, sizeof(s.coeff_bij_3), dest);
  sprintf(string, "%-45s%s\n", COEFF_B13, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.coeff_bij_4, sizeof(s.coeff_bij_4));
  justify(sstring, sizeof(s.coeff_bij_4), dest);
  sprintf(string, "%-45s%s\n", COEFF_B14, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.coeff_bij_5, sizeof(s.coeff_bij_5));
  justify(sstring, sizeof(s.coeff_bij_5), dest);
  sprintf(string, "%-45s%s\n", COEFF_B21, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.coeff_bij_6, sizeof(s.coeff_bij_6));
  justify(sstring, sizeof(s.coeff_bij_6), dest);
  sprintf(string, "%-45s%s\n", COEFF_B22, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.coeff_bij_7, sizeof(s.coeff_bij_7));
  justify(sstring, sizeof(s.coeff_bij_7), dest);
  sprintf(string, "%-45s%s\n", COEFF_B23, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring,  fs->map_proj.coeff_bij_8, sizeof(s.coeff_bij_8));
  justify(sstring, sizeof(s.coeff_bij_8), dest);
  sprintf(string, "%-45s%s\n", COEFF_B24, dest);
  fprintf(fp_wr, "%s", string);
} /* Wr_Leader_Map_Proj */

/********************************************************************
*                                
* Function:    Wr_Leader_Platform               
*                                
* Abstract:    Write Platfrom Position Data Record       
*                                
* Description:  This routine reads and prints the contents of the
*               platform data record.  There is one "main" record
*               followed by a variable number of data sets.         
*                                
* Inputs:    fs:   pointer to structure of input file 
*         fp_wr:   pointer to output file       
*                                
* Return Value:  void                      
*                                
********************************************************************/

void Wr_Leader_Platform(leader_file_struct *fs, FILE *fp_wr)
{
  leader_platf_pos_struct  s;    /* platform structure */
  char  string[LONG_NAME_LEN];
  char  sstring[LONG_NAME_LEN];
  char  sstring1[LONG_NAME_LEN];
  char  sstring2[LONG_NAME_LEN];
  int   i, npoints;

  /* First, output a boxed title for the data */
  Title_Box(SARL_TITLE, PLATF_REC, fp_wr, 0, 0, NULL, 0);

  /* Now, output the header info */
  Write_Header(fp_wr, &fs->platform.hdr);

  /* Finally, output record specific data */

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->platform.orbit_design, sizeof(s.orbit_design));
  sprintf(string, "%-45s%s\n", ORBIT_DESIGN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->platform.orbital_elt1, sizeof(s.orbital_elt1));
  justify(sstring, sizeof(s.orbital_elt1), dest);
  sprintf(string, "%-45s%s\n", ORBIT_ELT1, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->platform.orbital_elt2, sizeof(s.orbital_elt2));
  justify(sstring, sizeof(s.orbital_elt2), dest);
  sprintf(string, "%-45s%s\n", ORBIT_ELT2, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->platform.orbital_elt3, sizeof(s.orbital_elt3));
  justify(sstring, sizeof(s.orbital_elt3), dest);
  sprintf(string, "%-45s%s\n", ORBIT_ELT3, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->platform.orbital_elt4, sizeof(s.orbital_elt4));
  justify(sstring, sizeof(s.orbital_elt4), dest);
  sprintf(string, "%-45s%s\n", ORBIT_ELT4, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->platform.orbital_elt5, sizeof(s.orbital_elt5));
  justify(sstring, sizeof(s.orbital_elt5), dest);
  sprintf(string, "%-45s%s\n", ORBIT_ELT5, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->platform.orbital_elt6, sizeof(s.orbital_elt6));
  justify(sstring, sizeof(s.orbital_elt6), dest);
  sprintf(string, "%-45s%s\n", ORBIT_ELT6, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->platform.n_data_sets, sizeof(s.n_data_sets));
  justify(sstring, sizeof(s.n_data_sets), dest);
  sprintf(string, "%-45s%s\n", N_SETS, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->platform.year, sizeof(s.year));
  justify(sstring, sizeof(s.year), dest);
  sprintf(string, "%-45s%s\n", PLAT_YEAR, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->platform.month, sizeof(s.month));
  justify(sstring, sizeof(s.month), dest);
  sprintf(string, "%-45s%s\n", PLAT_MONTH, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->platform.day, sizeof(s.day));
  justify(sstring, sizeof(s.day), dest);
  sprintf(string, "%-45s%s\n", PLAT_DAY, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->platform.day_in_year, sizeof(s.day_in_year));
  justify(sstring, sizeof(s.day_in_year), dest);
  sprintf(string, "%-45s%s\n", PLAT_DIY, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->platform.sec_in_day, sizeof(s.sec_in_day));
  justify(sstring, sizeof(s.sec_in_day), dest);
  sprintf(string, "%-45s%s\n", PLAT_SID, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->platform.interval, sizeof(s.interval));
  justify(sstring, sizeof(s.interval), dest);
  sprintf(string, "%-45s%s\n", PLAT_INT, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->platform.coord_sys, sizeof(s.coord_sys));
  justify(sstring, sizeof(s.coord_sys), dest);
  sprintf(string, "%-45s%s\n", PLAT_COORD, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->platform.hour_angle, sizeof(s.hour_angle));
  justify(sstring, sizeof(s.hour_angle), dest);
  sprintf(string, "%-45s%s\n", PLAT_HOUR, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->platform.along_track_err1, sizeof(s.along_track_err1));
  justify(sstring, sizeof(s.along_track_err1), dest);
  sprintf(string, "%-45s%s\n", AL_TRACK_ERR1, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->platform.across_track_err1, sizeof(s.across_track_err1));
  justify(sstring, sizeof(s.across_track_err1), dest);
  sprintf(string, "%-45s%s\n", AC_TRACK_ERR1, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->platform.radial_track_err1, sizeof(s.radial_track_err1));
  justify(sstring, sizeof(s.sec_in_day), dest);
  sprintf(string, "%-45s%s\n", RD_TRACK_ERR1, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->platform.along_track_err2, sizeof(s.along_track_err2));
  justify(sstring, sizeof(s.radial_track_err1), dest);
  sprintf(string, "%-45s%s\n", AL_TRACK_ERR2, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->platform.across_track_err2, sizeof(s.across_track_err2));
  justify(sstring, sizeof(s.across_track_err2), dest);
  sprintf(string, "%-45s%s\n", AC_TRACK_ERR2, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->platform.radial_track_err2, sizeof(s.radial_track_err2));
  justify(sstring, sizeof(s.radial_track_err2), dest);
  sprintf(string, "%-45s%s\n", RD_TRACK_ERR2, dest);
  fprintf(fp_wr, "%s", string);

  /* Loop through each data set */
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->platform.n_data_sets, sizeof(s.n_data_sets));
  npoints = atoi(sstring);

  for (i = 0; i < npoints; i++) {
    sprintf(string, "\n\n%s %d %s\n\n", DATAS1, i+1, DATAS2);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, fs->platform.pos_vel_vec[i][0],sizeof(fs->platform.pos_vel_vec[i][0]));

    memset(sstring1, 0, sizeof(sstring1));
    strncpy(sstring1, fs->platform.pos_vel_vec[i][1],sizeof(fs->platform.pos_vel_vec[i][1]));

    memset(sstring2, 0, sizeof(sstring2));
    strncpy(sstring2, fs->platform.pos_vel_vec[i][2],sizeof(fs->platform.pos_vel_vec[i][2]));

    sprintf(string, "%-25s\n%s\n%s %s %s\n\n", PLAT_POSV, PLAT_XYZ, sstring, sstring1, sstring2);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, fs->platform.pos_vel_vec[i][3],sizeof(fs->platform.pos_vel_vec[i][3]));

    memset(sstring1, 0, sizeof(sstring1));
    strncpy(sstring1, fs->platform.pos_vel_vec[i][4],sizeof(fs->platform.pos_vel_vec[i][4]));

    memset(sstring2, 0, sizeof(sstring2));
    strncpy(sstring2, fs->platform.pos_vel_vec[i][5],sizeof(fs->platform.pos_vel_vec[i][5]));

    sprintf(string, "%-25s\n%s\n%s %s %s\n\n",PLAT_VEL, PLAT_XYZ,sstring, sstring1, sstring2);
    fprintf(fp_wr, "%s", string);
  } /* for each data set */

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->platform.occ_flag, sizeof(s.occ_flag));
  justify(sstring, sizeof(s.occ_flag), dest);
  sprintf(string, "%-45s%s\n", OCC_FLAG, dest);
  fprintf(fp_wr, "%s", string);
} /* Wr_Leader_Platform */

/********************************************************************
*                                
* Function:    Wr_Leader_Attitude               
*                                
* Abstract:    Write Attitude Data Record           
*                                
* Description:  This routine reads and prints the contents of the 
*               attitude data record.  There is one "main" record
*               followed by a variable number of attitude data sets.     
*                                
* Inputs:    fs:   pointer to structure of input file 
*         fp_wr:   pointer to output file       
*                                
* Return Value:  void                      
*                                
********************************************************************/

void Wr_Leader_Attitude(leader_file_struct *fs, FILE *fp_wr)
{
  leader_attitude_struct   s;    /* attitude structure */
  char  string[LONG_NAME_LEN];
  char  sstring[20];
  char  string1[LONG_NAME_LEN];
  int   i, npoints;

  /* First, output a boxed title for the data */
  Title_Box(SARL_TITLE, ATT_REC, fp_wr, 0, 0, NULL, 0);
        
  /* Now, output the header info */
  Write_Header(fp_wr, &fs->attitude.hdr);

  /* Finally, output record specific data */

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->attitude.n_data_sets, sizeof(s.n_data_sets));
  justify(sstring, sizeof(s.n_data_sets), dest);
  sprintf(string, "%-45s%s\n", N_SETS, dest);
  fprintf(fp_wr, "%s", string);

  /* Loop through each data set */
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->attitude.n_data_sets, sizeof(s.n_data_sets));
  npoints = atoi(sstring);

  for (i = 0; i < npoints; i++) {
    sprintf(string, "\n%s %d\n", "Attitude Data Point #", i+1);
    fprintf(fp_wr, "%s", string);

    memset(string1, 0, sizeof(string1));
    strncpy(string1, fs->attitude.attitude_data[i], sizeof(fs->attitude.attitude_data[i]));

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, &string1[0], 4);
    justify(sstring, sizeof(sstring), dest);
    sprintf(string, "%-45s%s\n", ATT_DAYS, dest);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, &string1[4], 8);
    justify(sstring, sizeof(sstring), dest);
    sprintf(string, "%-45s%s\n", ATT_SECS, dest);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, &string1[12], 4);
    justify(sstring, sizeof(sstring), dest);
    sprintf(string, "%-45s%s\n", PITCH_FLAG, dest);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, &string1[16], 4);
    justify(sstring, sizeof(sstring), dest);
    sprintf(string, "%-45s%s\n", ROLL_FLAG, dest);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, &string1[20], 4);
    justify(sstring, sizeof(sstring), dest);
    sprintf(string, "%-45s%s\n", YAW_FLAG, dest);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, &string1[24], 14);
    justify(sstring, sizeof(sstring), dest);
    sprintf(string, "%-45s%s\n", PITCH_VAL, dest);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, &string1[38], 14);
    justify(sstring, sizeof(sstring), dest);
    sprintf(string, "%-45s%s\n", ROLL_VAL, dest);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, &string1[52], 14);
    justify(sstring, sizeof(sstring), dest);
    sprintf(string, "%-45s%s\n", YAW_VAL, dest);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, &string1[66], 4);
    justify(sstring, sizeof(sstring), dest);
    sprintf(string, "%-45s%s\n", PITCH_QUAL, dest);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, &string1[70], 4);
    justify(sstring, sizeof(sstring), dest);
    sprintf(string, "%-45s%s\n", ROLL_QUAL, dest);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, &string1[74], 4);
    justify(sstring, sizeof(sstring), dest);
    sprintf(string, "%-45s%s\n", YAW_QUAL, dest);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, &string1[78], 14);
    justify(sstring, sizeof(sstring), dest);
    sprintf(string, "%-45s%s\n", PITCH_RATE, dest);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, &string1[82], 14);
    justify(sstring, sizeof(sstring), dest);
    sprintf(string, "%-45s%s\n", ROLL_RATE, dest);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, &string1[106], 14);
    justify(sstring, sizeof(sstring), dest);
    sprintf(string, "%-45s%s\n", YAW_RATE, dest);
    fprintf(fp_wr, "%s", string);
  } /* for each data set */
} /* Wr_Leader_Attitude() */

/********************************************************************
*                                
* Function:    Wr_Leader_Radiometric             
*                                
* Abstract:    Write Radiometric Data Record         
*                                
* Description:  This routine reads and prints the contents of the
*               radiometric data record.            
*                                
* Inputs:    fs:    pointer to structure of input file 
*         fp_wr:    pointer to output file       
*                                
* Return Value:  void                      
*                                
********************************************************************/

void Wr_Leader_Radiometric(leader_file_struct *fs, FILE *fp_wr)
{
  leader_radio_struct    s;    /* radiometric structure */
  char  string[LONG_NAME_LEN];
  char  sstring[LONG_NAME_LEN];

  /* First, output a boxed title for the data */
  Title_Box(SARL_TITLE, RADIO_REC, fp_wr, 0, 0, NULL, 0);
  
  /* Now, output the header info */
  Write_Header(fp_wr, &fs->radio.hdr);
  
  /* Finally, output record specific data */
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio.seq_no, sizeof(s.seq_no));
  justify(sstring, sizeof(s.seq_no), dest);
  sprintf(string, "%-45s%s\n", SEQ_NO, dest);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio.n_data_sets, sizeof(s.n_data_sets));
  justify(sstring, sizeof(s.n_data_sets), dest);
  sprintf(string, "%-45s%s\n", N_SETS, dest);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio.calib_factor, sizeof(s.calib_factor));
  justify(sstring, sizeof(s.calib_factor), dest);
  sprintf(string, "%-45s%s\n", CAL_FAC, dest);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio.dt11_real, sizeof(s.dt11_real));
  justify(sstring, sizeof(s.dt11_real), dest);
  sprintf(string, "%-45s%s\n", DT11_R, dest);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio.dt11_imag, sizeof(s.dt11_imag));
  justify(sstring, sizeof(s.dt11_imag), dest);
  sprintf(string, "%-45s%s\n", DT11_I, dest);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio.dt12_real, sizeof(s.dt12_real));
  justify(sstring, sizeof(s.dt12_real), dest);
  sprintf(string, "%-45s%s\n", DT12_R, dest);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio.dt12_imag, sizeof(s.dt12_imag));
  justify(sstring, sizeof(s.dt12_imag), dest);
  sprintf(string, "%-45s%s\n", DT12_I, dest);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio.dt21_real, sizeof(s.dt21_real));
  justify(sstring, sizeof(s.dt21_real), dest);
  sprintf(string, "%-45s%s\n", DT21_R, dest);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio.dt21_imag, sizeof(s.dt21_imag));
  justify(sstring, sizeof(s.dt21_imag), dest);
  sprintf(string, "%-45s%s\n", DT21_I, dest);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio.dt22_real, sizeof(s.dt22_real));
  justify(sstring, sizeof(s.dt22_real), dest);
  sprintf(string, "%-45s%s\n", DT22_R, dest);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio.dt22_imag, sizeof(s.dt22_imag));
  justify(sstring, sizeof(s.dt22_imag), dest);
  sprintf(string, "%-45s%s\n", DT22_I, dest);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio.dr11_real, sizeof(s.dr11_real));
  justify(sstring, sizeof(s.dr11_real), dest);
  sprintf(string, "%-45s%s\n", DR11_R, dest);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio.dr11_imag, sizeof(s.dr11_imag));
  justify(sstring, sizeof(s.dr11_imag), dest);
  sprintf(string, "%-45s%s\n", DR11_I, dest);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio.dr12_real, sizeof(s.dr12_real));
  justify(sstring, sizeof(s.dr12_real), dest);
  sprintf(string, "%-45s%s\n", DR12_R, dest);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio.dr12_imag, sizeof(s.dr12_imag));
  justify(sstring, sizeof(s.dr12_imag), dest);
  sprintf(string, "%-45s%s\n", DR12_I, dest);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio.dr21_real, sizeof(s.dr21_real));
  justify(sstring, sizeof(s.dr21_real), dest);
  sprintf(string, "%-45s%s\n", DR21_R, dest);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio.dr21_imag, sizeof(s.dr21_imag));
  justify(sstring, sizeof(s.dr21_imag), dest);
  sprintf(string, "%-45s%s\n", DR21_I, dest);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio.dr22_real, sizeof(s.dr22_real));
  justify(sstring, sizeof(s.dr22_real), dest);
  sprintf(string, "%-45s%s\n", DR22_R, dest);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio.dr22_imag, sizeof(s.dr22_imag));
  justify(sstring, sizeof(s.dr22_imag), dest);
  sprintf(string, "%-45s%s\n", DR22_I, dest);
  fprintf(fp_wr, "%s", string);
} /* Wr_Leader_Radiometric */

/********************************************************************
*                                
* Function:    Wr_Leader_Data_Quality             
*                                
* Abstract:    Write Data Quality Summary Record       
*                                
* Description:  This routine reads and prints the contents of the 
*               data quality summary record.          
*                                
* Inputs:    fs:    pointer to structure of input file 
*         fp_wr;    pointer to output file       
*                                
* Return Value:  void                      
*                                
********************************************************************/

void Wr_Leader_Data_Quality(leader_file_struct *fs, FILE *fp_wr)
{
  leader_data_qual_struct s;    /* data quality structure */
  char  string[LONG_NAME_LEN];
  char  sstring[LONG_NAME_LEN];
  int   i, npoints;

  /* First, output a boxed title for the data */
  Title_Box(SARL_TITLE, QUAL_REC, fp_wr, 0, 0, NULL, 0);
  
  /* Now, output the header info */
  Write_Header(fp_wr, &fs->data_qual.hdr);
  
  /* Finally, output record specific data */
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual.seq_no, sizeof(s.seq_no));
  justify(sstring, sizeof(s.seq_no), dest);
  sprintf(string, "%-45s%s\n", SEQ_NO, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual.sar_channel, sizeof(s.sar_channel));
  justify(sstring, sizeof(s.sar_channel), dest);
  sprintf(string, "%-45s%s\n", BAND_POL, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual.calibr_date, sizeof(s.calibr_date));
  justify(sstring, sizeof(s.calibr_date), dest);
  sprintf(string, "%-45s%s\n", CAL_DATE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual.n_channels, sizeof(s.n_channels));
  justify(sstring, sizeof(s.n_channels), dest);
  sprintf(string, "%-45s%s\n", N_CHAN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual.islr, sizeof(s.islr));
  justify(sstring, sizeof(s.islr), dest);
  sprintf(string, "%-45s%s\n", ISLR, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual.pslr, sizeof(s.pslr));
  justify(sstring, sizeof(s.pslr), dest);
  sprintf(string, "%-45s%s\n", PSLR, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual.az_ambig, sizeof(s.az_ambig));
  justify(sstring, sizeof(s.az_ambig), dest);
  sprintf(string, "%-45s%s\n", AZ_AMB, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual.rg_ambig, sizeof(s.rg_ambig));
  justify(sstring, sizeof(s.rg_ambig), dest);
  sprintf(string, "%-45s%s\n", RG_AMB, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual.snr_est, sizeof(s.snr_est));
  justify(sstring, sizeof(s.snr_est), dest);
  sprintf(string, "%-45s%s\n", SNR_EST, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual.ber, sizeof(s.ber));
  justify(sstring, sizeof(s.ber), dest);
  sprintf(string, "%-45s%s\n", BER, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual.slant_rg_res, sizeof(s.slant_rg_res));
  justify(sstring, sizeof(s.slant_rg_res), dest);
  sprintf(string, "%-45s%s\n", SLANT_RES, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual.az_res, sizeof(s.az_res));
  justify(sstring, sizeof(s.az_res), dest);
  sprintf(string, "%-45s%s\n", AZ_RES, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual.radio_res, sizeof(s.radio_res));
  justify(sstring, sizeof(s.radio_res), dest);
  sprintf(string, "%-45s%s\n", RADIO_RES, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual.dynam_rg, sizeof(s.dynam_rg));
  justify(sstring, sizeof(s.dynam_rg), dest);
  sprintf(string, "%-45s%s\n", DYNAMIC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual.abs_radio_unc, sizeof(s.abs_radio_unc));
  justify(sstring, sizeof(s.abs_radio_unc), dest);
  sprintf(string, "%-45s%s\n", ABS_RAD_UNC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual.pha_radio_unc, sizeof(s.pha_radio_unc));
  justify(sstring, sizeof(s.pha_radio_unc), dest);
  sprintf(string, "%-45s%s\n", PHA_RAD_UNC, dest);
  fprintf(fp_wr, "%s", string);

  /* Loop through each data set */
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual.n_channels, sizeof(s.n_channels));
  npoints = atoi(sstring);
  for (i = 0; i < npoints; i++)
    {
    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, fs->data_qual.rad_pha_unc[2*i],sizeof(fs->data_qual.rad_pha_unc[2*i]));
    justify(sstring, sizeof(fs->data_qual.rad_pha_unc[2*i]), dest);
    memset(sstring, 0, sizeof(sstring));
    sprintf(sstring, "%s%d%s", REL_RAD_UNC, i+1, ":");
    sprintf(string, "%-45s%s\n", sstring, dest);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, fs->data_qual.rad_pha_unc[2*i+1],sizeof(fs->data_qual.rad_pha_unc[2*i+1]));
    justify(sstring, sizeof(fs->data_qual.rad_pha_unc[2*i+1]), dest);
    sprintf(sstring, "%s%d%s", REL_PHA_UNC, i+1, ":");
    sprintf(string, "%-45s%s\n", sstring, dest);
    fprintf(fp_wr, "%s", string);
  }

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual.along_track_err, sizeof(s.along_track_err));
  justify(sstring, sizeof(s.along_track_err), dest);
  sprintf(string, "%-45s%s\n", ALOC_E, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual.across_track_err, sizeof(s.across_track_err));
  justify(sstring, sizeof(s.across_track_err), dest);
  sprintf(string, "%-45s%s\n", XLOC_E, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual.scale_line_err, sizeof(s.scale_line_err));
  justify(sstring, sizeof(s.scale_line_err), dest);
  sprintf(string, "%-45s%s\n", ASCALE_E, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual.scale_pix_err, sizeof(s.scale_pix_err));
  justify(sstring, sizeof(s.scale_pix_err), dest);
  sprintf(string, "%-45s%s\n", XSCALE_E, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual.skew_err, sizeof(s.skew_err));
  justify(sstring, sizeof(s.skew_err), dest);
  sprintf(string, "%-45s%s\n", SKEW_E, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual.scene_err, sizeof(s.scene_err));
  justify(sstring, sizeof(s.scene_err), dest);
  sprintf(string, "%-45s%s\n", ORIENT_E, dest);
  fprintf(fp_wr, "%s", string);

  /* Loop through each data set */
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual.n_channels, sizeof(s.n_channels));
  npoints = atoi(sstring);
  for (i = 0; i < npoints; i++)
    {
      memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, fs->data_qual.track_mis[2*i],sizeof(fs->data_qual.track_mis[2*i]));
    justify(sstring, sizeof(fs->data_qual.track_mis[2*i]), dest);
    sprintf(sstring, "%s%d%s", A_TRACK_MIS, i+1, ":");
    sprintf(string, "%-45s%s\n", sstring, dest);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, fs->data_qual.track_mis[2*i+1],sizeof(fs->data_qual.track_mis[2*i+1]));
    justify(sstring, sizeof(fs->data_qual.track_mis[2*i+1]), dest);
    sprintf(sstring, "%s%d%s", X_TRACK_MIS, i+1, ":");
    sprintf(string, "%-45s%s\n", sstring, dest);
    fprintf(fp_wr, "%s", string);
  }
} /* Wr_Leader_Data_Qual */

/********************************************************************
*                                
* Function:    Wr_Leader_Facility               
*                                
* Abstract:    Write Facility Data Record           
*                                
* Description:  This routine reads and prints the contents of the 
*               radiometric data record.            
*                                
* Inputs:    fs:   pointer to structure of input file 
*         fp_wr:   pointer to output file       
*         index:   index into array of pointers to linked lists
*                                 
* Return Value:  void                      
*                                
********************************************************************/

void Wr_Leader_Facility(leader_file_struct *fs, FILE *fp_wr, int index)
{
  leader_facility_struct    s;    /* facility structure */
  char  string[LONG_NAME_LEN];
  char  sstring[LONG_NAME_LEN];

  /* First, output a boxed title for the data */
  memset(string, 0, sizeof(string));
  sprintf(string, "%s%d", FACIL_REC, index);
  Title_Box(SARL_TITLE, string, fp_wr, 0, 0, NULL, 0);
  
  /* Now, output the header info */
  Write_Header(fp_wr, &fs->facility.hdr);
  
  /* Finally, output record specific data */
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->facility.seq_no, sizeof(s.seq_no));
  justify(sstring, sizeof(s.seq_no), dest);
  sprintf(string, "%-45s%s\n", SEQ_NO, dest);
  fprintf(fp_wr, "%s", string);
} /* Wr_Leader_Facility */

/********************************************************************
*                                
* Function:    Wr_Leader_Facility11              
*                                
* Abstract:    Write Facility Data Record 11         
*                                
* Description:  This routine reads and prints the contents of the 
*               radiometric data record.            
*                                
* Inputs:    fs;    pointer to structure of input file 
*         fp_wr;    pointer to output file       
*                                
* Return Value:  void                      
*                                
********************************************************************/

void Wr_Leader_Facility11(leader_file_struct *fs, FILE *fp_wr)
{
  leader_facility11_struct    s;    /* facility structure */
  char  string[LONG_NAME_LEN];
  char  sstring[LONG_NAME_LEN];
  int   i;

  /* First, output a boxed title for the data */
  memset(string, 0, sizeof(string));
  sprintf(string, "%s%s", FACIL_REC, "11");
  Title_Box(SARL_TITLE, string, fp_wr, 0, 0, NULL, 0);
  
  /* Now, output the header info */
  Write_Header(fp_wr, &fs->facility11.hdr);
  
  /* Finally, output record specific data */
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->facility11.seq_no, sizeof(s.seq_no));
  justify(sstring, sizeof(s.seq_no), dest);
  sprintf(string, "%-45s%s\n", SEQ_NO, dest);
  fprintf(fp_wr, "%s", string);

  for (i = 0; i < 20; i++)
    {
      memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, fs->facility11.coefficient[i],sizeof(fs->facility11.coefficient[i]));
    justify(sstring, sizeof(fs->facility11.coefficient[i]), dest);
    sprintf(sstring, "%s%d%s", COEFF_MAP, i+1, ":");
    sprintf(string, "%-45s%s\n", sstring, dest);
    fprintf(fp_wr, "%s", string);
  }

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->facility11.calib_indic, sizeof(s.calib_indic));
  justify(sstring, sizeof(s.calib_indic), dest);
  sprintf(string, "%-45s%s\n", CALIB_INDIC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->facility11.start_line_up, sizeof(s.start_line_up));
  justify(sstring, sizeof(s.start_line_up), dest);
  sprintf(string, "%-45s%s\n", START_UP, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->facility11.stop_line_up, sizeof(s.stop_line_up));
  justify(sstring, sizeof(s.stop_line_up), dest);
  sprintf(string, "%-45s%s\n", STOP_UP, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->facility11.start_line_bo, sizeof(s.start_line_bo));
  justify(sstring, sizeof(s.start_line_bo), dest);
  sprintf(string, "%-45s%s\n", START_BO, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->facility11.stop_line_bo, sizeof(s.stop_line_bo));
  justify(sstring, sizeof(s.stop_line_bo), dest);
  sprintf(string, "%-45s%s\n", STOP_BO, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->facility11.prf_indic, sizeof(s.prf_indic));
  justify(sstring, sizeof(s.prf_indic), dest);
  sprintf(string, "%-45s%s\n", PRF_IND, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->facility11.prf_line, sizeof(s.prf_line));
  justify(sstring, sizeof(s.prf_line), dest);
  sprintf(string, "%-45s%s\n", PRF_LIN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->facility11.sar_process_line, sizeof(s.sar_process_line));
  justify(sstring, sizeof(s.sar_process_line), dest);
  sprintf(string, "%-45s%s\n", SAR_PROC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->facility11.loss_lines, sizeof(s.loss_lines));
  justify(sstring, sizeof(s.loss_lines), dest);
  sprintf(string, "%-45s%s\n", LOSS_LINE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->facility11.loss_lines_rg, sizeof(s.loss_lines_rg));
  justify(sstring, sizeof(s.loss_lines_rg), dest);
  sprintf(string, "%-45s%s\n", LOSS_LINE_RG, dest);
  fprintf(fp_wr, "%s", string);
} /* Wr_Leader_Facility11 */

/********************************************************************
*                                
* Function:    Wr_Image_Descript               
*                                
* Abstract:    Write File Descriptor Record          
*                                
* Description:  This routine reads and prints the contents of the 
*               Imagery Options file descriptor record.     
*                                
* Inputs:    fs;    pointer to file structure     
*         fp_wr;    pointer to output file       
*                                
* Return Value:  void                      
*                                
********************************************************************/

void Wr_Image_Descript(image_file_struct *fs, FILE *fp_wr)
{
  image_descript_struct      s;  /* file descriptor structure */
  char  string[LONG_NAME_LEN];
  char  sstring[LONG_NAME_LEN];

  /* First, output a boxed title for the data */
  Title_Box(IMG_TITLE, DESCR_REC, fp_wr, 0, 0, NULL, 0);

  /* Now, output the header info */
  Write_Header(fp_wr, &fs->descript.hdr);

  /* Finally, output record specific data */

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.ascii_flag, sizeof(s.ascii_flag));
  justify(sstring, sizeof(s.ascii_flag), dest);
  sprintf(string, "%-45s%s\n", ASCII_FL, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.doc_format, sizeof(s.doc_format));
  justify(sstring, sizeof(s.doc_format), dest);
  sprintf(string, "%-45s%s\n", DOC_FORM, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.format_rev, sizeof(s.format_rev));
  justify(sstring, sizeof(s.format_rev), dest);
  sprintf(string, "%-45s%s\n", FORM_REV, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.rec_format_rev, sizeof(s.rec_format_rev));
  justify(sstring, sizeof(s.rec_format_rev), dest);
  sprintf(string, "%-45s%s\n", REC_REV, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.software_id, sizeof(s.software_id));
  justify(sstring, sizeof(s.software_id), dest);
  sprintf(string, "%-45s%s\n", SW_VERS, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.file_no, sizeof(s.file_no));
  justify(sstring, sizeof(s.file_no), dest);
  sprintf(string, "%-45s%s\n", FILE_NO, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.filename, sizeof(s.filename));
  justify(sstring, sizeof(s.filename), dest);
  sprintf(string, "%-45s%s\n", FILE_NAME, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.seq_flag, sizeof(s.seq_flag));
  justify(sstring, sizeof(s.seq_flag), dest);
  sprintf(string, "%-45s%s\n", FSEQ, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.seq_location, sizeof(s.seq_location));
  justify(sstring, sizeof(s.seq_location), dest);
  sprintf(string, "%-45s%s\n", LOC_NO, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.seq_field_len, sizeof(s.seq_field_len));
  justify(sstring, sizeof(s.seq_field_len), dest);
  sprintf(string, "%-45s%s\n", SEQ_FLD_L, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.code_flag, sizeof(s.code_flag));
  justify(sstring, sizeof(s.code_flag), dest);
  sprintf(string, "%-45s%s\n", LOC_TYPE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.code_location, sizeof(s.code_location));
  justify(sstring, sizeof(s.code_location), dest);
  sprintf(string, "%-45s%s\n", RCODE_LOC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.code_field_len, sizeof(s.code_field_len));
  justify(sstring, sizeof(s.code_field_len), dest);
  sprintf(string, "%-45s%s\n", RCODE_FLD_L, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_flag, sizeof(s.len_flag));
  justify(sstring, sizeof(s.len_flag), dest);
  sprintf(string, "%-45s%s\n", FLGT, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_location, sizeof(s.len_location));
  justify(sstring, sizeof(s.len_location), dest);
  sprintf(string, "%-45s%s\n", REC_LEN_LOC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_field_len, sizeof(s.len_field_len));
  justify(sstring, sizeof(s.len_field_len), dest);
  sprintf(string, "%-45s%s\n", REC_LEN_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_sar_recs, sizeof(s.n_sar_recs));
  justify(sstring, sizeof(s.n_sar_recs), dest);
  sprintf(string, "%-45s%s\n", N_SAR_RECS, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.sar_rec_len, sizeof(s.sar_rec_len));
  justify(sstring, sizeof(s.sar_rec_len), dest);
  sprintf(string, "%-45s%s\n", SAR_REC_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.bits_sample, sizeof(s.bits_sample));
  justify(sstring, sizeof(s.bits_sample), dest);
  sprintf(string, "%-45s%s\n", BITS_SPAMP, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.pixels_group, sizeof(s.pixels_group));
  justify(sstring, sizeof(s.pixels_group), dest);
  sprintf(string, "%-45s%s\n", PIX_GP, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.bytes_group, sizeof(s.bytes_group));
  justify(sstring, sizeof(s.bytes_group), dest);
  sprintf(string, "%-45s%s\n", BYTES_GP, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.sar_channels, sizeof(s.sar_channels));
  justify(sstring, sizeof(s.sar_channels), dest);
  sprintf(string, "%-45s%s\n", N_SAR_CHAN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_lines, sizeof(s.n_lines));
  justify(sstring, sizeof(s.n_lines), dest);
  sprintf(string, "%-45s%s\n", N_LINES_IMG, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.left_pixels, sizeof(s.left_pixels));
  justify(sstring, sizeof(s.left_pixels), dest);
  sprintf(string, "%-45s%s\n", LEFT_BD_PIX, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_pixels, sizeof(s.n_pixels));
  justify(sstring, sizeof(s.n_pixels), dest);
  sprintf(string, "%-45s%s\n", N_PIX_LINE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.right_pixels, sizeof(s.right_pixels));
  justify(sstring, sizeof(s.right_pixels), dest);
  sprintf(string, "%-45s%s\n", RIGHT_BD_PIX, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.top_lines, sizeof(s.top_lines));
  justify(sstring, sizeof(s.top_lines), dest);
  sprintf(string, "%-45s%s\n", TOP_LINES, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.bottom_lines, sizeof(s.bottom_lines));
  justify(sstring, sizeof(s.bottom_lines), dest);
  sprintf(string, "%-45s%s\n", BOTTOM_LINES, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.interleave, sizeof(s.interleave));
  justify(sstring, sizeof(s.interleave), dest);
  sprintf(string, "%-45s%s\n", INTERLEAVE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.recs_line, sizeof(s.recs_line));
  justify(sstring, sizeof(s.recs_line), dest);
  sprintf(string, "%-45s%s\n", RECS_LINE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.recs_channel, sizeof(s.recs_channel));
  justify(sstring, sizeof(s.recs_channel), dest);
  sprintf(string, "%-45s%s\n", RECS_CHAN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.prefix_len, sizeof(s.prefix_len));
  justify(sstring, sizeof(s.prefix_len), dest);
  sprintf(string, "%-45s%s\n", LINE_PREFIX, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.bytes_line, sizeof(s.bytes_line));
  justify(sstring, sizeof(s.bytes_line), dest);
  sprintf(string, "%-45s%s\n", BYTES_LINE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.suffix_len, sizeof(s.suffix_len));
  justify(sstring, sizeof(s.suffix_len), dest);
  sprintf(string, "%-45s%s\n", LINE_SUFFIX, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.prefix_flag, sizeof(s.prefix_flag));
  justify(sstring, sizeof(s.prefix_flag), dest);
  sprintf(string, "%-45s%s\n", PREFIX_FLAG, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.line_locator, sizeof(s.line_locator));
  justify(sstring, sizeof(s.line_locator), dest);
  sprintf(string, "%-45s%s\n", LINE_LOC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.sar_locator, sizeof(s.sar_locator));
  justify(sstring, sizeof(s.sar_locator), dest);
  sprintf(string, "%-45s%s\n", SAR_LOC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.time_locator, sizeof(s.time_locator));
  justify(sstring, sizeof(s.time_locator), dest);
  sprintf(string, "%-45s%s\n", TIME_LOC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.left_locator, sizeof(s.left_locator));
  justify(sstring, sizeof(s.left_locator), dest);
  sprintf(string, "%-45s%s\n", LEFT_LOC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.right_locator, sizeof(s.right_locator));
  justify(sstring, sizeof(s.right_locator), dest);
  sprintf(string, "%-45s%s\n", RIGHT_LOC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.pad_pix, sizeof(s.pad_pix));
  justify(sstring, sizeof(s.pad_pix), dest);
  sprintf(string, "%-45s%s\n", PAD_PIX, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.data_locator, sizeof(s.data_locator));
  justify(sstring, sizeof(s.data_locator), dest);
  sprintf(string, "%-45s%s\n", DATA_LOC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.calib_locator, sizeof(s.calib_locator));
  justify(sstring, sizeof(s.calib_locator), dest);
  sprintf(string, "%-45s%s\n", CALIB_LOC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.gain_locator, sizeof(s.gain_locator));
  justify(sstring, sizeof(s.gain_locator), dest);
  sprintf(string, "%-45s%s\n", GAIN_LOC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.bias_locator, sizeof(s.bias_locator));
  justify(sstring, sizeof(s.bias_locator), dest);
  sprintf(string, "%-45s%s\n", BIAS_LOC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.sar_format, sizeof(s.sar_format));
  justify(sstring, sizeof(s.sar_format), dest);
  sprintf(string, "%-45s%s\n", SAR_FORMAT, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.sar_code, sizeof(s.sar_code));
  justify(sstring, sizeof(s.sar_code), dest);
  sprintf(string, "%-45s%s\n", SAR_CODE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_left_fill, sizeof(s.n_left_fill));
  justify(sstring, sizeof(s.n_left_fill), dest);
  sprintf(string, "%-45s%s\n", LT_PIX_FILL, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_right_fill, sizeof(s.n_right_fill));
  justify(sstring, sizeof(s.n_right_fill), dest);
  sprintf(string, "%-45s%s\n", RT_PIX_FILL, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.max_range, sizeof(s.max_range));
  justify(sstring, sizeof(s.max_range), dest);
  sprintf(string, "%-45s%s\n", MAX_RANGE, dest);
  fprintf(fp_wr, "%s", string);
} /* Wr_Image_Descript */

/********************************************************************
*                                
* Function:    Wr_Image_Signal                 
*                                
* Abstract:    Write Data Signal Record            
*                                
* Description:  This routine reads and prints the contents of the  
*               Imagery Options file descriptor record.     
*                                
* Inputs:    fs;    pointer to file structure     
*         fp_wr;    pointer to output file       
*                                
* Return Value:  void                      
*                                
********************************************************************/

void Wr_Image_Signal(image_file_struct *fs, FILE *fp_wr)
{
  image_signal_struct      s;  /* file descriptor structure */
  char  string[LONG_NAME_LEN];
  char  sstring[LONG_NAME_LEN];
  unsigned toto;
  short titi;

  /* First, output a boxed title for the data */
  Title_Box(IMG_TITLE, PREFIX_REC, fp_wr, 0, 0, NULL, 0);

  /* Now, output the header info */
  Write_Header(fp_wr, &fs->signal.hdr);

  /* Finally, output record specific data */
  toto = htonl(fs->signal.sar_line);
  sprintf(string, "%-45s%d\n", SAR_LINE, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.sar_index);
  sprintf(string, "%-45s%d\n", SAR_INDEX, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.left_pix);
  sprintf(string, "%-45s%d\n", LEFT_PIX, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.data_pix);
  sprintf(string, "%-45s%d\n", DATA_PIX, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.right_pix);
  sprintf(string, "%-45s%d\n", RIGHT_PIX, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.sensor_flag);
  sprintf(string, "%-45s%d\n", SENSOR_FLAG, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.sensor_year);
  sprintf(string, "%-45s%d\n", SENSOR_YEAR, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.sensor_day);
  sprintf(string, "%-45s%d\n", SENSOR_DAY, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.sensor_ms);
  sprintf(string, "%-45s%d\n", SENSOR_MS, toto);
  fprintf(fp_wr, "%s", string);

  titi = htonc(fs->signal.sar_channel);
  sprintf(string, "%-45s%d\n", SAR_CHANNEL, titi);
  fprintf(fp_wr, "%s", string);

  titi = htonc(fs->signal.sar_line);
  if (titi == 0) strcpy(dest,"L");
  if (titi == 1) strcpy(dest,"S");
  if (titi == 2) strcpy(dest,"C");
  if (titi == 3) strcpy(dest,"X");
  if (titi == 4) strcpy(dest,"KU");
  if (titi == 5) strcpy(dest,"KA");
  sprintf(string, "%-45s%s\n", SAR_CODE_I, dest);
  fprintf(fp_wr, "%s", string);

  titi = htonc(fs->signal.t_pol);
  if (titi == 0) strcpy(dest,"H");
  if (titi == 1) strcpy(dest,"V");
  sprintf(string, "%-45s%s\n", T_POL, dest);
  fprintf(fp_wr, "%s", string);

  titi = htonc(fs->signal.r_pol);
  if (titi == 0) strcpy(dest,"H");
  if (titi == 1) strcpy(dest,"V");
  sprintf(string, "%-45s%s\n", R_POL, dest);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.prf);
  sprintf(string, "%-45s%d\n", PRF_I, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.scan_id);
  sprintf(string, "%-45s%d\n", SCAN_ID, toto);
  fprintf(fp_wr, "%s", string);

  titi = htonc(fs->signal.range_flag);
  sprintf(string, "%-45s%d\n", RANGE_FLAG, titi);
  fprintf(fp_wr, "%s", string);

  titi = htonc(fs->signal.chirp_des);
  if (titi == 0) strcpy(dest,"LINEAR FM CHIRP");
  if (titi == 1) strcpy(dest,"PHASE MODULATORS");
  sprintf(string, "%-45s%s\n", CHIRP_DES, dest);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.chirp_len);
  sprintf(string, "%-45s%d\n", CHIRP_LEN, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.chirp_coeff1);
  sprintf(string, "%-45s%d\n", CHIRP_COEFF1, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.chirp_coeff2);
  sprintf(string, "%-45s%d\n", CHIRP_COEFF2, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.chirp_coeff3);
  sprintf(string, "%-45s%d\n", CHIRP_COEFF3, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.gain);
  sprintf(string, "%-45s%d\n", GAIN_I, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.line_flag);
  sprintf(string, "%-45s%d\n", LINE_FLAG, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.ant_squint1);
  sprintf(string, "%-45s%d\n", ANT_SQUINT1, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.ant_elev1);
  sprintf(string, "%-45s%d\n", ANT_ELEV1, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.ant_squint2);
  sprintf(string, "%-45s%d\n", ANT_SQUINT2, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.ant_elev2);
  sprintf(string, "%-45s%d\n", ANT_ELEV2, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.slant_data);
  sprintf(string, "%-45s%d\n", SLANT_DATA, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.data_wind);
  sprintf(string, "%-45s%d\n", DATA_WIND, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.platf_pos);
  sprintf(string, "%-45s%d\n", PLATF_POS, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.platf_lat);
  sprintf(string, "%-45s%d\n", PLATF_LAT, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.platf_lon);
  sprintf(string, "%-45s%d\n", PLATF_LON, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.platf_alt);
  sprintf(string, "%-45s%d\n", PLATF_ALT, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.platf_speed);
  sprintf(string, "%-45s%d\n", PLATF_SPEED, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.platf_velx);
  sprintf(string, "%-45s%d\n", PLATF_VELX, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.platf_vely);
  sprintf(string, "%-45s%d\n", PLATF_VELY, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.platf_velz);
  sprintf(string, "%-45s%d\n", PLATF_VELZ, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.platf_accx);
  sprintf(string, "%-45s%d\n", PLATF_ACCX, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.platf_accy);
  sprintf(string, "%-45s%d\n", PLATF_ACCY, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.platf_accz);
  sprintf(string, "%-45s%d\n", PLATF_ACCZ, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.platf_track1);
  sprintf(string, "%-45s%d\n", PLATF_TRACK1, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.platf_track2);
  sprintf(string, "%-45s%d\n", PLATF_TRACK2, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.platf_pitch);
  sprintf(string, "%-45s%d\n", PLATF_PITCH, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.platf_roll);
  sprintf(string, "%-45s%d\n", PLATF_ROLL, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.platf_yaw);
  sprintf(string, "%-45s%d\n", PLATF_YAW, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.counter);
  sprintf(string, "%-45s%d\n", COUNTER, toto);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->signal.aux_data, sizeof(s.aux_data));
  justify(sstring, sizeof(s.aux_data), dest);
  sprintf(string, "%-45s%s\n", AUX_DATA, dest);
  fprintf(fp_wr, "%s", string);
} /* Wr_Image_Signal */

/********************************************************************
*                                
* Function:    Wr_Image_Signal_Tiny                
*                                
* Abstract:    Write Data Signal Record            
*                                
* Description:  This routine reads and prints a Tiny contents of the
*               Imagery Options file descriptor record.     
*                                
* Inputs:    fs;      pointer to file structure     
*         fp_wr;      pointer to output file       
*                                
* Return Value:  void                      
*                                
********************************************************************/

void Wr_Image_Signal_Tiny(image_file_struct *fs, FILE *fp_wr)
{
  image_signal_struct      s;  /* file descriptor structure */
  char  string[LONG_NAME_LEN];
  char  sstring[LONG_NAME_LEN];
  unsigned toto;

  /* First, output a boxed title for the data */
  Title_Box(IMG_TITLE, PREFIX_REC, fp_wr, 0, 0, NULL, 0);

  /* Now, output the header info */
  Write_Header(fp_wr, &fs->signal.hdr);

  toto = htonl(fs->signal.sensor_year);
  sprintf(string, "%-45s%d\n", SENSOR_YEAR, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.sensor_day);
  sprintf(string, "%-45s%d\n", SENSOR_DAY, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->signal.sensor_ms);
  sprintf(string, "%-45s%d\n", SENSOR_MS, toto);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->signal.aux_data, sizeof(s.aux_data));
  justify(sstring, sizeof(s.aux_data), dest);
  sprintf(string, "%-45s%s\n", AUX_DATA, dest);
  fprintf(fp_wr, "%s", string);
} /* Wr_Image_Signal_Tiny */

/********************************************************************
*                                
* Function:    Wr_Image_Process                
*                                
* Abstract:    Write processed Data Record           
*                                
* Description:  This routine reads and prints the contents of the
*               Imagery Options file descriptor record.     
*                                
* Inputs:    fs;      pointer to file structure     
*         fp_wr;      pointer to output file       
*                                
* Return Value:  void                      
*                                
********************************************************************/

void Wr_Image_Process(image_file_struct *fs, FILE *fp_wr)
{
  char  string[LONG_NAME_LEN];
  unsigned toto;
  short titi;

  /* First, output a boxed title for the data */
  Title_Box(IMG_TITLE, PREFIX_REC, fp_wr, 0, 0, NULL, 0);

  /* Now, output the header info */
  Write_Header(fp_wr, &fs->process.hdr);

  /* Finally, output record specific data */
  toto = htonl(fs->process.sar_line);
  sprintf(string, "%-45s%d\n", SAR_LINE, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.sar_index);
  sprintf(string, "%-45s%d\n", SAR_INDEX, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.left_pix);
  sprintf(string, "%-45s%d\n", LEFT_PIX, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.data_pix);
  sprintf(string, "%-45s%d\n", DATA_PIX, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.right_pix);
  sprintf(string, "%-45s%d\n", RIGHT_PIX, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.sensor_flag);
  sprintf(string, "%-45s%d\n", SENSOR_FLAG, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.sensor_year);
  sprintf(string, "%-45s%d\n", SENSOR_YEAR, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.sensor_day);
  sprintf(string, "%-45s%d\n", SENSOR_DAY, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.sensor_ms);
  sprintf(string, "%-45s%d\n", SENSOR_MS, toto);
  fprintf(fp_wr, "%s", string);

  titi = htonc(fs->process.sar_channel);
  sprintf(string, "%-45s%d\n", SAR_CHANNEL, titi);
  fprintf(fp_wr, "%s", string);

  titi = htonc(fs->process.sar_line);
  if (titi == 0) strcpy(dest,"L");
  if (titi == 1) strcpy(dest,"S");
  if (titi == 2) strcpy(dest,"C");
  if (titi == 3) strcpy(dest,"X");
  if (titi == 4) strcpy(dest,"KU");
  if (titi == 5) strcpy(dest,"KA");
  sprintf(string, "%-45s%s\n", SAR_CODE_I, dest);
  fprintf(fp_wr, "%s", string);

  titi = htonc(fs->process.t_pol);
  if (titi == 0) strcpy(dest,"H");
  if (titi == 1) strcpy(dest,"V");
  sprintf(string, "%-45s%s\n", T_POL, dest);
  fprintf(fp_wr, "%s", string);

  titi = htonc(fs->process.r_pol);
  if (titi == 0) strcpy(dest,"H");
  if (titi == 1) strcpy(dest,"V");
  sprintf(string, "%-45s%s\n", R_POL, dest);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.prf);
  sprintf(string, "%-45s%d\n", PRF_I, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.scan_id);
  sprintf(string, "%-45s%d\n", SCAN_ID, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.slant_1st);
  sprintf(string, "%-45s%d\n", SLANT_1ST, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.slant_mid);
  sprintf(string, "%-45s%d\n", SLANT_MID, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.slant_lst);
  sprintf(string, "%-45s%d\n", SLANT_LST, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.doppler_1st);
  sprintf(string, "%-45s%d\n", DOPPLER_1ST, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.doppler_mid);
  sprintf(string, "%-45s%d\n", DOPPLER_MID, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.doppler_lst);
  sprintf(string, "%-45s%d\n", DOPPLER_LST, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.az_fm_1st);
  sprintf(string, "%-45s%d\n", AZ_FM_1ST, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.az_fm_mid);
  sprintf(string, "%-45s%d\n", AZ_FM_MID, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.az_fm_lst);
  sprintf(string, "%-45s%d\n", AZ_FM_LST, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.look_angle);
  sprintf(string, "%-45s%d\n", LOOK_ANGLE, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.az_squint);
  sprintf(string, "%-45s%d\n", AZ_SQUINT, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.geo_ref);
  sprintf(string, "%-45s%d\n", GEO_REF, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.lat_1st);
  sprintf(string, "%-45s%d\n", LAT_1ST, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.lat_mid);
  sprintf(string, "%-45s%d\n", LAT_MID, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.lat_lst);
  sprintf(string, "%-45s%d\n", LAT_LST,toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.lon_1st);
  sprintf(string, "%-45s%d\n", LON_1ST, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.lon_mid);
  sprintf(string, "%-45s%d\n", LON_MID, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.lon_lst);
  sprintf(string, "%-45s%d\n", LON_LST,toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.northing_1st);
  sprintf(string, "%-45s%d\n", NORTHING_1ST, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.northing_lst);
  sprintf(string, "%-45s%d\n", NORTHING_LST, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.easting_1st);
  sprintf(string, "%-45s%d\n", EASTING_1ST, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.easting_lst);
  sprintf(string, "%-45s%d\n", EASTING_LST, toto);
  fprintf(fp_wr, "%s", string);

  toto = htonl(fs->process.line_heading);
  sprintf(string, "%-45s%d\n", LINE_HEADING, toto);
  fprintf(fp_wr, "%s", string);
} /* Wr_Image_Process */

/********************************************************************
*                                
* Function:    Wr_Trailer_Descript               
*                                
* Abstract:    Write File Descriptor Record          
*                                
* Description:  This routine reads and prints the contents of the
*               SAR Trailer file descriptor record.       
*                                
* Inputs:    rp;      pointer to record structure    
*         fp_wr;      pointer to output file       
*                                
* Return Value:  void                      
*                                
********************************************************************/

void Wr_Trailer_Descript(trailer_file_struct *rp, FILE *fp_wr)
{
  char  string[LONG_NAME_LEN];
  char  sstring[LONG_NAME_LEN];

  /* First, output a boxed title for the data */
  Title_Box(SART_TITLE, DESCR_REC, fp_wr, 0, 0, NULL, 0);

  /* Now, output the header info */
  Write_Header(fp_wr, &rp->hdr);

  /* Finally, output record specific data */

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->ascii_flag, sizeof(rp->ascii_flag));
  justify(sstring, sizeof(rp->ascii_flag), dest);
  sprintf(string, "%-45s%s\n", ASCII_FL, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->doc_format, sizeof(rp->doc_format));
  justify(sstring, sizeof(rp->doc_format), dest);
  sprintf(string, "%-45s%s\n", DOC_FORM, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->format_rev, sizeof(rp->format_rev));
  justify(sstring, sizeof(rp->format_rev), dest);
  sprintf(string, "%-45s%s\n", FORM_REV, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->rec_format_rev, sizeof(rp->rec_format_rev));
  justify(sstring, sizeof(rp->rec_format_rev), dest);
  sprintf(string, "%-45s%s\n", REC_REV, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->software_id, sizeof(rp->software_id));
  justify(sstring, sizeof(rp->software_id), dest);
  sprintf(string, "%-45s%s\n", SW_VERS, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->file_no, sizeof(rp->file_no));
  justify(sstring, sizeof(rp->file_no), dest);
  sprintf(string, "%-45s%s\n", FILE_NO, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->filename, sizeof(rp->filename));
  justify(sstring, sizeof(rp->filename), dest);
  sprintf(string, "%-45s%s\n", FILE_NAME, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->seq_flag, sizeof(rp->seq_flag));
  justify(sstring, sizeof(rp->seq_flag), dest);
  sprintf(string, "%-45s%s\n", FSEQ, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->seq_location, sizeof(rp->seq_location));
  justify(sstring, sizeof(rp->seq_location), dest);
  sprintf(string, "%-45s%s\n", LOC_NO, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->seq_field_len, sizeof(rp->seq_field_len));
  justify(sstring, sizeof(rp->seq_field_len), dest);
  sprintf(string, "%-45s%s\n", SEQ_FLD_L, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->code_flag, sizeof(rp->code_flag));
  justify(sstring, sizeof(rp->code_flag), dest);
  sprintf(string, "%-45s%s\n", LOC_TYPE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->code_location, sizeof(rp->code_location));
  justify(sstring, sizeof(rp->code_location), dest);
  sprintf(string, "%-45s%s\n", RCODE_LOC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->code_field_len, sizeof(rp->code_field_len));
  justify(sstring, sizeof(rp->code_field_len), dest);
  sprintf(string, "%-45s%s\n", RCODE_FLD_L, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_flag, sizeof(rp->len_flag));
  justify(sstring, sizeof(rp->len_flag), dest);
  sprintf(string, "%-45s%s\n", FLGT, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_location, sizeof(rp->len_location));
  justify(sstring, sizeof(rp->len_location), dest);
  sprintf(string, "%-45s%s\n", REC_LEN_LOC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_field_len, sizeof(rp->len_field_len));
  justify(sstring, sizeof(rp->len_field_len), dest);
  sprintf(string, "%-45s%s\n", REC_LEN_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_data_set_recs, sizeof(rp->n_data_set_recs));
  justify(sstring, sizeof(rp->n_data_set_recs), dest);
  sprintf(string, "%-45s%s\n", DS_FILE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_data_set, sizeof(rp->len_data_set));
  justify(sstring, sizeof(rp->len_data_set), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_map_proj_recs, sizeof(rp->n_map_proj_recs));
  justify(sstring, sizeof(rp->n_map_proj_recs), dest);
  sprintf(string, "%-45s%s\n", MP_FILE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_map_proj, sizeof(rp->len_map_proj));
  justify(sstring, sizeof(rp->len_map_proj), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_platf_recs, sizeof(rp->n_platf_recs));
  justify(sstring, sizeof(rp->n_platf_recs), dest);
  sprintf(string, "%-45s%s\n", PLATF_FILE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_platf, sizeof(rp->len_platf));
  justify(sstring, sizeof(rp->len_platf), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_att_recs, sizeof(rp->n_att_recs));
  justify(sstring, sizeof(rp->n_att_recs), dest);
  sprintf(string, "%-45s%s\n", ATT_FILE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_att, sizeof(rp->len_att));
  justify(sstring, sizeof(rp->len_att), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_radio_recs, sizeof(rp->n_radio_recs));
  justify(sstring, sizeof(rp->n_radio_recs), dest);
  sprintf(string, "%-45s%s\n", RADIO_FILE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_radio, sizeof(rp->len_radio));
  justify(sstring, sizeof(rp->len_radio), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_radio_comp_recs, sizeof(rp->n_radio_comp_recs));
  justify(sstring, sizeof(rp->n_radio_comp_recs), dest);
  sprintf(string, "%-45s%s\n", RADIOC_FILE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_radio_comp, sizeof(rp->len_radio_comp));
  justify(sstring, sizeof(rp->len_radio_comp), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_qual_recs, sizeof(rp->n_qual_recs));
  justify(sstring, sizeof(rp->n_qual_recs), dest);
  sprintf(string, "%-45s%s\n", QUAL_FILE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_qual, sizeof(rp->len_qual));
  justify(sstring, sizeof(rp->len_qual), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_hist_recs, sizeof(rp->n_hist_recs));
  justify(sstring, sizeof(rp->n_hist_recs), dest);
  sprintf(string, "%-45s%s\n", HIST_FILE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_hist, sizeof(rp->len_hist));
  justify(sstring, sizeof(rp->len_hist), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_spectra_recs, sizeof(rp->n_spectra_recs));
  justify(sstring, sizeof(rp->n_spectra_recs), dest);
  sprintf(string, "%-45s%s\n", SPEC_FILE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_spectra, sizeof(rp->len_spectra));
  justify(sstring, sizeof(rp->len_spectra), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_elev_recs, sizeof(rp->n_elev_recs));
  justify(sstring, sizeof(rp->n_elev_recs), dest);
  sprintf(string, "%-45s%s\n", ELEV_FILE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_elev, sizeof(rp->len_elev));
  justify(sstring, sizeof(rp->len_elev), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_update_recs, sizeof(rp->n_update_recs));
  justify(sstring, sizeof(rp->n_update_recs), dest);
  sprintf(string, "%-45s%s\n", UPD_FILE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_update, sizeof(rp->len_update));
  justify(sstring, sizeof(rp->len_update), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_annot_recs, sizeof(rp->n_annot_recs));
  justify(sstring, sizeof(rp->n_annot_recs), dest);
  sprintf(string, "%-45s%s\n", ANNOT_FILE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_annot, sizeof(rp->len_annot));
  justify(sstring, sizeof(rp->len_annot), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_proc_recs, sizeof(rp->n_proc_recs));
  justify(sstring, sizeof(rp->n_proc_recs), dest);
  sprintf(string, "%-45s%s\n", PROC_FILE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_proc, sizeof(rp->len_proc));
  justify(sstring, sizeof(rp->len_proc), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_calib_recs, sizeof(rp->n_calib_recs));
  justify(sstring, sizeof(rp->n_calib_recs), dest);
  sprintf(string, "%-45s%s\n", CAL_FILE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_calib, sizeof(rp->len_calib));
  justify(sstring, sizeof(rp->len_calib), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_ground, sizeof(rp->n_ground));
  justify(sstring, sizeof(rp->n_ground), dest);
  sprintf(string, "%-45s%s\n", GROUND_FILE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_ground, sizeof(rp->len_ground));
  justify(sstring, sizeof(rp->len_ground), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_facil_recs1, sizeof(rp->n_facil_recs1));
  justify(sstring, sizeof(rp->n_facil_recs1), dest);
  sprintf(string, "%-45s%s\n", FAC_FILE1, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_facil1, sizeof(rp->len_facil1));
  justify(sstring, sizeof(rp->len_facil1), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN1, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_facil_recs2, sizeof(rp->n_facil_recs2));
  justify(sstring, sizeof(rp->n_facil_recs2), dest);
  sprintf(string, "%-45s%s\n", FAC_FILE2, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_facil2, sizeof(rp->len_facil2));
  justify(sstring, sizeof(rp->len_facil2), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN2, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_facil_recs3, sizeof(rp->n_facil_recs3));
  justify(sstring, sizeof(rp->n_facil_recs3), dest);
  sprintf(string, "%-45s%s\n", FAC_FILE3, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_facil3, sizeof(rp->len_facil3));
  justify(sstring, sizeof(rp->len_facil3), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN3, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_facil_recs4, sizeof(rp->n_facil_recs4));
  justify(sstring, sizeof(rp->n_facil_recs4), dest);
  sprintf(string, "%-45s%s\n", FAC_FILE4, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_facil4, sizeof(rp->len_facil4));
  justify(sstring, sizeof(rp->len_facil4), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN4, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_facil_recs5, sizeof(rp->n_facil_recs5));
  justify(sstring, sizeof(rp->n_facil_recs5), dest);
  sprintf(string, "%-45s%s\n", FAC_FILE5, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_facil5, sizeof(rp->len_facil5));
  justify(sstring, sizeof(rp->len_facil5), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN5, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_facil_recs6, sizeof(rp->n_facil_recs6));
  justify(sstring, sizeof(rp->n_facil_recs6), dest);
  sprintf(string, "%-45s%s\n", FAC_FILE6, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_facil6, sizeof(rp->len_facil6));
  justify(sstring, sizeof(rp->len_facil6), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN6, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_facil_recs7, sizeof(rp->n_facil_recs7));
  justify(sstring, sizeof(rp->len_facil6), dest);
  sprintf(string, "%-45s%s\n", FAC_FILE7, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_facil7, sizeof(rp->len_facil7));
  justify(sstring, sizeof(rp->len_facil7), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN7, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_facil_recs8, sizeof(rp->n_facil_recs8));
  justify(sstring, sizeof(rp->n_facil_recs8), dest);
  sprintf(string, "%-45s%s\n", FAC_FILE8, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_facil8, sizeof(rp->len_facil8));
  justify(sstring, sizeof(rp->len_facil8), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN8, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_facil_recs9, sizeof(rp->n_facil_recs9));
  justify(sstring, sizeof(rp->n_facil_recs9), dest);
  sprintf(string, "%-45s%s\n", FAC_FILE9, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_facil9, sizeof(rp->len_facil9));
  justify(sstring, sizeof(rp->len_facil9), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN9, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_facil_recs10, sizeof(rp->n_facil_recs10));
  justify(sstring, sizeof(rp->n_facil_recs10), dest);
  sprintf(string, "%-45s%s\n", FAC_FILE10, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_facil10, sizeof(rp->len_facil10));
  justify(sstring, sizeof(rp->len_facil10), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN10, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_facil_recs11, sizeof(rp->n_facil_recs11));
  justify(sstring, sizeof(rp->n_facil_recs11), dest);
  sprintf(string, "%-45s%s\n", FAC_FILE11, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_facil11, sizeof(rp->len_facil11));
  justify(sstring, sizeof(rp->len_facil11), dest);
  sprintf(string, "%-45s%s\n", RECORD_LEN11, dest);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->low_records, sizeof(rp->low_records));
  justify(sstring, sizeof(rp->low_records), dest);
  sprintf(string, "%-45s%s\n", LOW_RECS, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->low_length, sizeof(rp->low_length));
  justify(sstring, sizeof(rp->low_length), dest);
  sprintf(string, "%-45s%s\n", LOW_LEN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->low_pixels, sizeof(rp->low_pixels));
  justify(sstring, sizeof(rp->low_pixels), dest);
  sprintf(string, "%-45s%s\n", LOW_PIX, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->low_lines, sizeof(rp->low_lines));
  justify(sstring, sizeof(rp->low_lines), dest);
  sprintf(string, "%-45s%s\n", LOW_LINES, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->low_bytes, sizeof(rp->low_bytes));
  justify(sstring, sizeof(rp->low_bytes), dest);
  sprintf(string, "%-45s%s\n", LOW_BYTES, dest);
  fprintf(fp_wr, "%s", string);
} /* Wr_Trailer_Descript */

/********************************************************************
*                                
* Function:    justify                     
*                                
* Abstract:    left-justify blank fill             
*                                
* Description:  This routine left justifies a floating point string.
*        Floating point strings are stored in prXXXXX_ldr_ceos as
*        ".....-99.1234567".               
*        They need to be converted to          
*        "-99.1234567.....".               
*                                
********************************************************************/

void justify(char *src, int length, char *destination)
{
  int i;            /* loop counter */

  /* Get src to point at first non-space */
  while (*src == SPACE) {
    src++;
  }

  /* 
   * Restructure string so that there are no prepended spaces.  Pad
   * spaces at end of string.
   */

  memset(destination, 0, sizeof(dest));
  strcpy(destination, src);
  for (i = strlen(dest); i < length; i++) {
    destination[i] = SPACE;
  }
} /* justify() */

/********************************************************************
*
* Function:    htonl
*
* Abstract:    Convert UNIX long word integer to VAX/VMS format
*
* Description:  This routine re-arrages the byte-order for VAX/VMS long
*     word integer
*
* Include files: none
*
* Inputs:    x:    unsigned long word integer
*
* Outputs:  see return value
*
* Return Value:  converted integer
*
********************************************************************/

unsigned long htonl( unsigned long x )
{
  union {
    unsigned long x;
    unsigned char b[4];
  } y;
  unsigned char tmp;

  y.x = x;

  tmp = y.b[0];
  y.b[0] = y.b[3];
  y.b[3] = tmp;
  tmp = y.b[1];
  y.b[1] = y.b[2];
  y.b[2] = tmp;

  return ( y.x );
} /* End of htonl */

/********************************************************************
*
* Function:    htonc
*
* Abstract:    Convert UNIX short word integer to VAX/VMS format
*
* Description:  This routine re-arrages the byte-order for VAX/VMS
*               short word integer
*
* Include files: none
*
* Inputs:    x:    unsigned short word integer
*
* Outputs:  see return value
*
* Return Value:  converted integer
*
********************************************************************/

unsigned short htonc( unsigned short x )
{
  union {
    unsigned short x;
    unsigned char b[2];
  } y;
  unsigned char tmp;

  y.x = x;

  tmp = y.b[0];
  y.b[0] = y.b[1];
  y.b[1] = tmp;

  return ( y.x );
} /* End of htonc */


/********************************************************************
*                                
* Function:    PolSARproConfigFile               
*                                
* Abstract:    Read CEOS formatted Imagery Options File    
*                                
* Description:  This routine reads each record in the CEOS Imagery
*               Options File and outputs the data in each to a
*               Config file.     
*                                
*        Record in this file:              
*                                
*            File Descriptor Record         
*                                
* Inputs:    filename:  name of Imagery Options file to read from
*                                
* Outputs:    filename_"ascii"  ascii readable file     
*                                
* Return Value:  none                      
*                                
********************************************************************/

void PolSARproConfigFile()
{
  FILE  *fp_rd;       /* pointer to imagery options file */
  FILE  *fp_wr;       /* pointer to ascii file to be created */

  int   nread;        /* number of elements read from disk */

/*******************************************************************/
/*******************************************************************/

  /* open the Imagery Options file for reading */
  if ((fp_rd = fopen(image_in, "rb")) == NULL) {
    edit_error("Unable to open Imagery Options File :", image_in);
  }

  /* open/create an output file for writing file descriptor record to */
  if ((fp_wr = fopen(PSPConfigFile, "w+")) == NULL) {
    edit_error("Unable to create output file : ", PSPConfigFile);
  }

/*******************************************************************/
/*******************************************************************/

  /* read in file descriptor record */
  if ((nread = fread(&image.descript, sizeof(image.descript), 1, fp_rd)) < 1)
    {
    edit_error("Unable to read : Imagery Options File : ", image_in);
  } else {
    /* --- Write File Descriptor Record */
    PolSARproCreateConfigFile(&image, &leader, fp_wr);
  }

/*******************************************************************/
/*******************************************************************/

  /* Close the files */
  if (fclose(fp_wr) != 0) {
    edit_error("Error closing file : ", PSPConfigFile);
  }

  /* Close the file */
  if (fclose(fp_rd) != 0) {
    edit_error("Error closing file : ", image_in);
  }

} /* PolSARproConfigFile */

/********************************************************************
*                                
* Function:    PolSARproCreateConfigFile           
*                                
* Abstract:    Read File Descriptor Record           
*                                
* Description:  This routine creates the Config File      
*                                
* Inputs:    fs;      pointer to file structure     
*        fp_wr;    pointer to output file       
*                                
* Return Value:  void                      
*                                
********************************************************************/

void PolSARproCreateConfigFile(image_file_struct *fs, leader_file_struct *fl, FILE *fp_wr)
{
  char  sstring[6];  

  fprintf(fp_wr, "nlig\n");
  fprintf(fp_wr, "%d\n", atoi(fs->descript.n_lines));
  fprintf(fp_wr, "---------\n");
  fprintf(fp_wr, "ncol\n");
  fprintf(fp_wr, "%d\n", atoi(fs->descript.n_pixels));
  fprintf(fp_wr, "---------\n");
  fprintf(fp_wr, "data_level\n");
//  fprintf(fp_wr, "%f\n", Data_Level);
  fprintf(fp_wr, "%s\n", Data_Level);
  fprintf(fp_wr, "---------\n");
  fprintf(fp_wr, "header_length\n");
  fprintf(fp_wr, "%ld\n", htonl(fs->descript.hdr.rec_length));
  fprintf(fp_wr, "---------\n");
  fprintf(fp_wr, "prefix_length\n");
  fprintf(fp_wr, "%d\n", atoi(fs->descript.prefix_len));
  fprintf(fp_wr, "---------\n");
  fprintf(fp_wr, "record_length\n");
  fprintf(fp_wr, "%d\n", atoi(fs->descript.sar_rec_len));
  fprintf(fp_wr, "---------\n");
  fprintf(fp_wr, "calib_factor\n");
  if (atof(fl->radio.calib_factor) == 0.0) {
    fprintf(fp_wr, "%f\n", -83.0000);
    } else {
    fprintf(fp_wr, "%f\n", atof(fl->radio.calib_factor));
    }
  fprintf(fp_wr, "---------\n");
  memset(sstring, 0, 6);
  strncpy(sstring, fl->data_set.az_time_dir, 6);
  fprintf(fp_wr, "%s\n", sstring);
  fprintf(fp_wr, "%f\n", atof(fl->data_set.incid_angle_ctr));
  fprintf(fp_wr, "%f\n", atof(fl->data_set.line_spacing));
  fprintf(fp_wr, "%f\n", atof(fl->data_set.pixel_spacing));

  if ( strcmp(Data_Level,"1.1") == 0 )
  {
  fprintf(fp_wr, "---------\n");
  fprintf(fp_wr, "tx_matrix\n");
  fprintf(fp_wr, "%f\n", atof(fl->radio.dt11_real));
  fprintf(fp_wr, "%f\n", atof(fl->radio.dt11_imag));
  fprintf(fp_wr, "%f\n", atof(fl->radio.dt12_real));
  fprintf(fp_wr, "%f\n", atof(fl->radio.dt12_imag));
  fprintf(fp_wr, "%f\n", atof(fl->radio.dt21_real));
  fprintf(fp_wr, "%f\n", atof(fl->radio.dt21_imag));
  fprintf(fp_wr, "%f\n", atof(fl->radio.dt22_real));
  fprintf(fp_wr, "%f\n", atof(fl->radio.dt22_imag));
  fprintf(fp_wr, "---------\n");
  fprintf(fp_wr, "rx_matrix\n");
  fprintf(fp_wr, "%f\n", atof(fl->radio.dr11_real));
  fprintf(fp_wr, "%f\n", atof(fl->radio.dr11_imag));
  fprintf(fp_wr, "%f\n", atof(fl->radio.dr12_real));
  fprintf(fp_wr, "%f\n", atof(fl->radio.dr12_imag));
  fprintf(fp_wr, "%f\n", atof(fl->radio.dr21_real));
  fprintf(fp_wr, "%f\n", atof(fl->radio.dr21_imag));
  fprintf(fp_wr, "%f\n", atof(fl->radio.dr22_real));
  fprintf(fp_wr, "%f\n", atof(fl->radio.dr22_imag));
  }

} /* PolSARproCreateConfigFile() */




