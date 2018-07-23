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

File   : sirc_header.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 2.0
Creation : 05/2011
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

Description :  Read Header of SIR-C Data Files

This software is extracted and adapted from the SIR-C GDPS OPS 
ceos_rd.c software

********************************************************************/

/*******************************************************************
*          
* Copyright (c) 1993, California Institute of Technology. U.S.  
* Government Sponsorship under NASA Contract NAS7-918 is acknowledged.
*                                     
* "This software is provided to you "as is" and without warranty of
*  any kind, expressed or implied, including but not limited to,   
*  warranties of performance, merchantability, or fitness for a        
*  particular purpose.  User bears all risk as to the quality and      
*  performance of the software."                       
*                                      
********************************************************************/

/********************************************************************
*                                   
* Module:  ceos_rd.c   Program:  SIR-C GDPS OPS
*                      Author:  P. Barrett  
*                      Initiated: 11-FEB-93   
* -------------------------------------------------------------------
*                                   
* Abstract:   Read CEOS files                    
*                                   
* Description:  This stand-alone task reads CEOS formatted SIR-C files
*        from disk and creates ASCII readable files of the contents.  
*        The processing run number must be passed in (XXXXX).  
*                                   
* Input Files:  The following CEOS formatted files are read 
*               by this task:   
*                                   
*           prXXXXX_ldr_ceos                
*           prXXXXX_img_ceos                
*           prXXXXX_tlr_ceos                
*                                   
* Output Files:  The following files are created by this task:    
*                                   
*           prXXXXX_leader_ceos.hdr             
*           prXXXXX_image_ceos.hdr              
*           prXXXXX_trailer_ceos.hdr            
*                                   
* NOTE to software developers and others who wish to alter this 
* source code:  
*                                   
* Do not make any code changes between rows of "&&&&&&&"    
*                                   
********************************************************************/

#define SIRC_CEOS_READER


#include  <math.h>
#include  <stdio.h>      /* Standard I/O */
#include  <stdlib.h>      /* Convert to floating point */
#include  <string.h>      /* String formatting */
#include  <time.h>       /* Time/date formatting */

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"
#include "../lib/sirc_ceos.h"      /* CEOS file definitions */
#include "../lib/sirc_header.h"      /* Constants, output strings */

/* --- Software Version # --- */
#define SW_VERSION "1.1   "

/********************************************************************
*                                   
*            -- Function Prototypes --            
*                                     
********************************************************************/

  void            /* Read SAR Leader File */
Rd_SAR_Leader(char *filename, char *diroutput);

  void            /* Read Imagery Options File */
Rd_Img_Opt(char *filename);

  void            /* Read SAR Trailer File */
Rd_SAR_Trailer(char *filename);

  void            /* Create boxed title */
Title_Box(char *filename, char *rec_name, FILE *fp, int record_no,
      int n_records, char *pol_string, int strsize);

  void            /* Write header data */
Write_Header(FILE *fp_wr, hdr_t *p_hdr);

  void            /* SARL: File Descriptor */
Rd_SARL_Descript(sarl_file_t *fs, FILE *fp_wr);

  void             /* SARL: Read data set summary record */
Rd_Data_Summary(sarl_file_t *fs, FILE *fp_wr);

  void            /* SARL: Read map projection record  */
Rd_Map_Proj(sarl_file_t *fs, FILE *fp_wr);

  void            /* SARL: Read platform position record */
Rd_Platform(sarl_file_t *fs, FILE *fp_wr);

  void            /* SARL: Read attitude data record */
Rd_Attitude(sarl_file_t *fs, FILE *fp_wr);

  void            /* SARL: Read radiometric data record */
Rd_Radiometric(sarl_file_t *fs, FILE *fp_wr, int index);

  void             /* SARL: Read radiometric comp record */
Rd_Radio_Comp(sarl_file_t *fs, FILE *fp_wr, int index, char *diroutput);

  void            /* SARL: Read data quality summary record */
Rd_Data_Qual(sarl_file_t *fs, FILE *fp_wr, int index);

  void            /* SARL: Read data histograms record */
Rd_Histogram(sarl_file_t *fs, FILE *fp_wr, int index, char *diroutput);

  void            /* SARL: Read range spectra record */
Rd_Range_Spectra(sarl_file_t *fs, FILE *fp_wr, int index, char *diroutput);

  void            /* SARL: Read parameter update record */
Rd_Update(sarl_file_t *fs, FILE *fp_wr, int index);

  void            /* SARL: Read detailed proc parameters */
Rd_Detailed_Proc(sarl_file_t *fs, FILE *fp_wr);

  void            /* SARL: Read calibration data record */
Rd_Calibration(sarl_file_t *fs, FILE *fp_wr);

  void            /* IMG OPT: File Descriptor */
Rd_IMG_Descript(imgopt_file_t *fs, FILE *fp_wr);

  void            /* SART: Read file descriptor */
Rd_SART_Descript(sart_descript_t *rp, FILE *fp_wr);

  void            /* left-justify a string */
justify(char *src, int length, char *dest);

  unsigned long         /* Convert long word integer */
htonl( unsigned long x );

  void            /* Match Software Id between Reader & Writer*/
MatchSoftwareId();

  void            /* Read Imagery Options File */
PolSARproConfigFile(char *filename, char *fileconfig);

  void            /* IMG OPT: File Descriptor */
PolSARproCreateConfigFile(imgopt_file_t *fs, FILE *fp_wr);

/********************************************************************
*                                     
*             Local Definitions                
*                                     
********************************************************************/

  /* pointers to link lists of data sets */

  radio_data_set    *radio_ptr[MAX_POLS];    /* radiometric */
  radcomp_table    *radioc_ptr[MAX_POLS];   /* radiometric comp */
  hist_data_set    *hist_ptr[MAX_POLS];    /* histogram */
  upd_data_set    *upd_ptr[MAX_POLS + 1];  /* parameter update */
  platf_data_set    *platf_ptr;        /* platform position */
  att_data_set    *att_ptr;          /* attitude */


  /* filenames */

  /* ...Input files */

  char  sarl_in[NAME_LEN];    /* CEOS formatted SAR Leader File */
  char  imgopt_in[NAME_LEN];  /* CEOS formatted Imagery Options File */
  char  sart_in[NAME_LEN];    /* CEOS formatted SAR Trailer File */

  /* ...Output files */

  char  sarl_ascii[NAME_LEN];  /* SAR Leader ascii file */
  char  imgopt_ascii[NAME_LEN]; /* Imagery Options ascii file */
  char  image_data[NAME_LEN];  /* Image data file */
  char  signal_data[NAME_LEN];  /* Reformatted signal data file */
  char  sart_ascii[NAME_LEN];  /* SAR Trailer ascii file */


  /* other */

  char  proc_run[NAME_LEN];  /* processing run number */
  char  dest[LONG_NAME_LEN];

  /* pointers to file structures */
  sarl_file_t    fs;     /* SAR Leader file structure */
  imgopt_file_t   opt;    /* Imagery Options file structure */
  sart_descript_t  rp;     /* SAR Trailer file structure */

/********************************************************************
*                                    
*      RDC External Variables                    
*                                    
********************************************************************/
  /* flag to save decoded stuff into disk file */
  //extern int save_flag;      /* RDC Modification */
  //extern int n_pol;      /* RDC Modification */
  //extern char polar[10][10];  /* RDC Modification */
  int save_flag;    /* RDC Modification */
  int n_pol;      /* RDC Modification */
  char polar[10][10];  /* RDC Modification */

/********************************************************************
*                                     
* Function:    main  (renamed CEOS_RD_main)               
*                                     
* Abstract:    Task execution starts here!                
*                                     
* Description:  This task reads the CEOS files generated by the SIR-C GDPS
*        software.  Specifically, it read files:          
*                                     
*         prXXXXX_ldr_ceos    ;CEOS formatted SAR Leader File  
*         prXXXXX_img_ceos    ;CEOS formatted Imagery Options File
*         prXXXXX_tlr_ceos    ;CEOS formatted SAR Trailer File  
*                                     
*         where XXXXX is the processing run number        
*                                     
*        This task "reads" the above files and outputs the following
*        readable (ascii) text files:               
*                                     
*         prXXXXX_leader_ceos.hdr  ; SAR Leader File        
*         prXXXXX_imgage_ceos.hdr  ; Imagery Options File     
*         prXXXXX_trailer_ceos.hdr ; SAR Trailer File       
*                                     
* NOTE:      This CEOS reader can only read CEOS files generated by the
*        SIR-C Ground Data Processing System.  It cannot read CEOS
*        files generated by X-SAR.                
*                                     
*        Also, this reader does not read the CEOS "Volume Directory
*        File" nor the "Null Volume Directory File"        
*                                     
********************************************************************/

  int main(int argc, char *argv[]) {

/* LOCAL VARIABLES */
  char DirInput[FilePathLength], DirOutput[FilePathLength], ConfigFile[FilePathLength];

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nsirc_header.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-pro 	processing run number\n");
strcat(UsageHelp," (string)	-ocf 	output PolSARpro config file\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 9) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,DirInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,DirOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-pro",str_cmd_prm,proc_run,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ocf",str_cmd_prm,ConfigFile,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_dir(DirInput);
  check_dir(DirOutput);
  check_file(ConfigFile);

/*******************************************************************/
/* INPUT / OUTPUT DATA FILES CONFIG */
/*******************************************************************/
  /* Using the processing run number, construct filenames */
  /* First, input filenames... XXXXX is the processing run number */

  /* CEOS formatted SAR Leader Filename (prXXXXX_ldr_ceos) */
  sprintf(sarl_in, "%s%s%s%s", DirInput,"pr",proc_run,"_ldr_ceos");
  check_file(sarl_in);

  /* CEOS formatted Imagery Options Filename (prXXXXX_img_ceos) */
  sprintf(imgopt_in, "%s%s%s%s", DirInput,"pr",proc_run,"_img_ceos");
  check_file(imgopt_in);

  /* CEOS formatted SAR Trailer Filename (prXXXXX_tlr_ceos) */
  sprintf(sart_in, "%s%s%s%s", DirInput,"pr",proc_run,"_tlr_ceos");
  check_file(sart_in);

  /* ...Now, output filenames */

  /* SAR Leader ascii filename (prXXXXX_leader_ceos.hdr) */
  sprintf(sarl_ascii, "%s%s%s%s", DirOutput,"pr",proc_run,"_leader_ceos.txt");
  check_file(sarl_ascii);

  /* Imagery Options ascii filename (prXXXXX_image_ceos.hdr) */
  sprintf(imgopt_ascii, "%s%s%s%s", DirOutput,"pr",proc_run,"_image_ceos.txt");
  check_file(imgopt_ascii);

  /* SAR Trailer ascii filename (prXXXXX_trailer_ceos.hdr) */
  sprintf(sart_ascii, "%s%s%s%s", DirOutput,"pr",proc_run,"_trailer_ceos.txt");
  check_file(sart_ascii);

/*******************************************************************/
/* READ HEADER DATA FILES */
/*******************************************************************/

  /* Read SAR Leader File */
  Rd_SAR_Leader(sarl_in, DirOutput);

  /* Read Imagery Options File */
  Rd_Img_Opt(imgopt_in);

  /* Read SAR Trailer File */
  Rd_SAR_Trailer(sart_in);

  /* PolSARpro create Config File */
  PolSARproConfigFile(imgopt_in, ConfigFile);

  /* Exit task, showing no errors */
  return 1;

} /* CEOS_RD_main() */


/********************************************************************
*                                     
* Function:    Title_Box                        
*                                     
* Abstract:    Supply a boxed title for the data record         
*                                     
* Description:  This routine prints the filename and record name of the data *
*        to be displayed below.                  
*                                     
* Inputs:    filename:  CEOS filename                
*        rec name:  CEOS record name              
*        file ptr:  file to output to              
*        record_no:  record sequence number            
*        n_records:  total number of records in sequence     
*        pol:     band and polarization (LHH, etc.)      
*        strsize:   length of band/pol string          
*                                     
* Return Value:  void                           
*                                     
********************************************************************/

  void 
Title_Box(char *filename, char *rec_name, FILE *fp, int record_no, 
      int n_records, char *pol_string, int strsize)
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
*        subtypes 1, 2, 3, etc.                  
*                                     
* Inputs:    file ptr:  file to write to              
*        hdr ptr:   pointer to header structure         
*                                     
* Outputs:    header to disk file                    
*                                     
* Return Value:  void                           
*                                     
********************************************************************/

  void
Write_Header(FILE *fp_wr, hdr_t *p_hdr)
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
* Description:  This routine reads each record in the CEOS SAR Leader File
*        and outputs the data to an ascii file.          
*                                     
*        Records include:                     
*                                     
*          File Descriptor Record                 
*          Data Set Summary Record                
*          Map Projection Data Record               
*          Platform Position Data Record              
*          Attitude Data Record                  
*          Radiometric Data Record                
*          Radiometric Compensation Data Record          
*          Data Quality Summary Record              
*          Data Histograms Record                 
*          Range Spectra Record                  
*          Radar Parameter Update Record              
*          Detailed Processing Parameter Record          
*          Calibration Data Record                
*                                     
* Inputs:    filename:  filename of SAR Leader file to read from  
*                                     
* Outputs:    filename_"ascii"  ascii file               
*                                     
* Return Value:  none                           
*                                     
********************************************************************/

  void
Rd_SAR_Leader(char *filename, char *diroutput)
{

  FILE  *fp_rd;       /* file pointer to file to read */
  FILE  *fp_wr;       /* file pointer to file to write */

  int   nread;        /* number of elements read from disk */
  int   i, j;        /* loop counters */

  /* temporary pointers to data sets */
  radio_data_set  *radio_tmpptr;
  radcomp_table   *radioc_tmpptr;
  hist_data_set   *hist_tmpptr;
  upd_data_set    *upd_tmpptr;
  platf_data_set  *platf_tmpptr;
  att_data_set    *att_tmpptr;

/***** NOTE *****  Do not alter code between "&&&&&&" ******/

/** &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
  &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& **/

  /* open the SAR Leader file for reading */
  if ((fp_rd = fopen(filename, "rb")) == NULL) {
    edit_error("Unable to open SAR Leader File : ", sarl_in);
  }

  /* read SAR Leader file in from disk */

  /* read in file descriptor record */
  if ((nread = fread(&fs.descript, sizeof(fs.descript), 1, fp_rd)) < 1) {
    edit_error("Unable to read : File Descriptor Record", filename);
  }

  MatchSoftwareId ( 1, fs.descript.software_id ); /* RDC Modification */

  /* read in data set summary record */
  if ((nread = fread(&fs.data_set, sizeof(fs.data_set), 1, fp_rd)) < 1) {
    edit_error("Unable to read : Data Set Summary Record ", filename);
  }

  n_pol = atoi(fs.data_set.n_channels); /* RDC Modification */

  /* read in map projection record */
  if ((nread = fread(&fs.map_proj, sizeof(fs.map_proj), 1, fp_rd)) < 1) {
    edit_error("Unable to read : Map Projection Record ", filename);
  }

  /* read in platform position record and its data sets */
  if ((nread = fread(&fs.platform, sizeof(fs.platform) - sizeof(fs.platform.data_set), 1, fp_rd)) < 1) {
    edit_error("Unable to read : Platform Data Record ", filename);
  }

  /*
   * Now, read in the platform position data sets.
   * First, allocate memory to hold array of them.
   */
  if (atoi(fs.platform.n_data_sets) != 0) {
    platf_ptr = (platf_data_set *)calloc(atoi(fs.platform.n_data_sets),sizeof(platf_data_set));

    /* Use temp pointer to step thru the data sets */
    platf_tmpptr = platf_ptr;

    /* 
     * Read each data set, but don't read the pointer value at
     * end of the structure.
     */
    for (j = 0; j < atoi(fs.platform.n_data_sets); j++) {
      if ((nread = fread(platf_tmpptr,
        sizeof(platf_data_set) - sizeof(struct platform_dset *),1, fp_rd)) < 1) {
        edit_error("Unable to read : Platform Data Set ", filename);
      }
      platf_tmpptr++;
    } /* for each data set */
  } /* if n_data_sets != 0 */


  /* read in attitude record and its data sets */
  if ((nread = fread(&fs.attitude,sizeof(fs.attitude)  - sizeof(fs.attitude.data_set),1, fp_rd)) < 1) {
    edit_error("Unable to read : Attitude Data Record ", filename);
  }

  /*
   * Now, read in the attitude data sets.
   * First, allocate memory to hold array of them.
   */
  
  if (atoi(fs.attitude.n_data_sets) != 0) {
    att_ptr = (att_data_set *)calloc(atoi(fs.attitude.n_data_sets),sizeof(att_data_set));
    
    att_tmpptr = att_ptr;
    for (j = 0; j < atoi(fs.attitude.n_data_sets); j++) {
  
      if ((nread = fread(att_tmpptr,sizeof(att_data_set) - sizeof(struct attitude_dset *),1, fp_rd)) < 1) {
         edit_error("Unable to read : Attitude Data Set ", filename);
      }
      att_tmpptr++;
    } /* for each data set */
  } /* if n_data_sets != 0 */
  
  /* read in each radiometric record and its data sets */
  for (i = 0; i < atoi(fs.descript.n_radio_recs); i++) {
  
    /* read in the main record */
    if ((nread = fread(&fs.radio[i],sizeof(fs.radio[i]) - sizeof(fs.radio[i].data_set),1, fp_rd)) < 1) {
      edit_error("Unable to read : Radiometric Data Record ", filename);
    }
    
    /* 
     * Now, read in the data sets for radio[i].
     * First, allocate memory to hold array of them.
     */
    
    if (atoi(fs.radio[i].n_data_sets) != 0) {
      radio_ptr[i] = (radio_data_set *)calloc(atoi(fs.radio[i].n_data_sets),sizeof(radio_data_set));

      radio_tmpptr = radio_ptr[i];
      for (j = 0; j < atoi(fs.radio[i].n_data_sets); j++) {
        if ((nread = fread(radio_tmpptr, sizeof(radio_data_set) - sizeof(struct radio_dset *),1, fp_rd)) < 1) {
          edit_error("Unable to read : Radiometric Data Set ", filename);
        }
        radio_tmpptr++;
      } /* for each data set */
    } /* if n_data_sets != 0 */
  } /* for each radio record */


  /* read in each radiometric compensation record and its table entries */
  for (i = 0; i < atoi(fs.descript.n_radio_comp_recs); i++) {

    /* read in the main record */
    if ((nread = fread(&fs.radio_comp[i], sizeof(fs.radio_comp[i]) - sizeof(fs.radio_comp[i].tbl_ptr), 1, fp_rd)) < 1) {
      edit_error("Unable to read : Radiometric Compensation Record ", filename);
    }

    /*
     * Now, read in the table entries for radio_comp[i].
     * First, allocate memory to hold array of them.
     */

    if (atoi(fs.radio_comp[i].n_table_entries) != 0) {
      radioc_ptr[i] = (radcomp_table *)calloc(atoi(fs.radio_comp[i].n_table_entries),sizeof(radcomp_table));

      radioc_tmpptr = radioc_ptr[i];
      for (j = 0; j < atoi(fs.radio_comp[i].n_table_entries); j++) {
        if ((nread = fread(radioc_tmpptr, sizeof(radcomp_table) - sizeof(struct radio_comp_tbl *), 1, fp_rd)) < 1) {
           edit_error("Unable to read : Radiometric Compensation Data Set ", filename);
        }
        radioc_tmpptr++;
      } /* for each table entry */
    } /* if n_table_entries != 0 */
  } /* for each radio compensation record */


  /* read in data quality summary record (one per pol) */
  for (i = 0; i < atoi(fs.descript.n_qual_recs); i++) {
    if ((nread = fread(&fs.data_qual[i], sizeof(fs.data_qual[i]), 1, fp_rd)) < 1) {
      edit_error("Unable to read : Data Quality Record ", filename);
    }
  }



  /* read in each histogram record and its data sets */
  for (i = 0; i < atoi(fs.descript.n_hist_recs); i++) {
  
    /* read the main record for histogram[i] */
    if ((nread = fread(&fs.histogram[i], sizeof(fs.histogram[i]) - sizeof(fs.histogram[i].data_set),1, fp_rd)) < 1) {
        edit_error("Unable to read : Data Histogram Record ", filename);
    }

    /*
     * Now, read in the data sets for histogram[i].
     * First, allocate memory to hold array of them.
     */

    if (atoi(fs.histogram[i].n_data_sets) != 0) {
      hist_ptr[i] = (hist_data_set *)calloc(atoi(fs.histogram[i].n_data_sets), sizeof(hist_data_set));

      hist_tmpptr = hist_ptr[i];
      for (j = 0; j < atoi(fs.histogram[i].n_data_sets); j++) {
        if ((nread = fread(hist_tmpptr, sizeof(hist_data_set) - sizeof(struct histogram_dset *), 1, fp_rd)) < 1) {
            edit_error("Unable to read : Histogram Data Set ", filename);
        }
        hist_tmpptr++;
      } /* for each data set... */
    } /* if n_data_sets != 0 */
  } /* for each histogram record */


  /* read in range spectra record (one per pol) */
  for (i = 0; i < atoi(fs.descript.n_spectra_recs); i++) {
    if ((nread = fread(&fs.spectra[i], sizeof(fs.spectra[i]), 1, fp_rd)) < 1) {
      edit_error("Unable to read : Range Spectra Record ", filename);
    }
  }

  /*
   * Read in radar parameter update record (one dwp record, one
   * receiver gain record per pol).  Read in each one's data set.
   */
    for (i = 0; i < atoi(fs.descript.n_update_recs); i++) {
      
      /* read the main record */
      if ((nread = fread(&fs.update[i], sizeof(fs.update[i]) - sizeof(fs.update[i].data_set), 1, fp_rd)) < 1) {
        edit_error("Unable to read : Radar Parameter Update ", filename);
      }

      /* 
       * Now, read in the data sets for update[i].
       * First, allocate memory to hold array of them.
       */
      
      if (atoi(fs.update[i].n_data_sets) != 0) {
        upd_ptr[i] = (upd_data_set *) calloc(atoi(fs.update[i].n_data_sets), sizeof(upd_data_set));
        upd_tmpptr = upd_ptr[i];
        for (j = 0; j < atoi(fs.update[i].n_data_sets); j++) {
          if ((nread = fread(upd_tmpptr, sizeof(upd_data_set) - sizeof(struct upd_dset *), 1, fp_rd)) < 1) {
              edit_error("Unable to read : Radar Parameter Update Data Set ", filename);
          }
          upd_tmpptr++;
        } /* for each data set... */

      } /* if n_data_sets != 0 */
    } /* for each update record */


  /* read in detailed processing parameters record */
  if ((nread = fread(&fs.detailed, sizeof(fs.detailed), 1, fp_rd)) < 1) {
    edit_error("Unable to read : Detailed Processing Record ", filename);
  }

  sprintf (proc_run, "%.5s", fs.detailed.proc_run); /* RDC Modification */

  /* read in calibration data record */
  if ((nread = fread(&fs.calibration, sizeof(fs.calibration), 1, fp_rd)) < 1) {
      edit_error("Unable to read : Calibration Data Record ", filename);
  }

  /* Close input file */
  if (fclose(fp_rd) != 0) {
    edit_error("Error closing file : ", sarl_in);
    }

  //if ( !save_flag) return;  /* RDC Modification */

/** &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
  &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& **/

/**** NOTE: *** Do not make  changes between "&&&&" ******/

  /* open/create an output file for writing */
  if ((fp_wr = fopen(sarl_ascii, "w+")) == NULL) {
    edit_error("Unable to open/create : ", sarl_ascii);
  }

  /*
   * Read each record of the SAR Leader file.  Format the data and
   * write the contents of each record, in ascii, to the output file.
   */

  /* --- Read File Descriptor Record */
  Rd_SARL_Descript(&fs, fp_wr);

  /* --- Read Data Set Summary Record */
  Rd_Data_Summary(&fs, fp_wr);

  /* --- Read Map Projection Data Record */
  Rd_Map_Proj(&fs, fp_wr);

  /* --- Read Platform Position Record */
  Rd_Platform(&fs, fp_wr);

  /* --- Read Attitude Data Record */
  Rd_Attitude(&fs, fp_wr);

  /* --- Read Radiometric Data Record (one for each polarization) */
  for (i = 0; i < atoi(fs.descript.n_radio_recs); i++) {
    Rd_Radiometric(&fs, fp_wr, i);
  }

  /* --- Read Radiometric Compensation Record (one for each polarization) */
  for (i = 0; i < atoi(fs.descript.n_radio_comp_recs); i++) {
    Rd_Radio_Comp(&fs, fp_wr, i, diroutput);
  }

  /* --- Read Data Quality Summary Record (one for each polarization) */
  for (i = 0; i < atoi(fs.descript.n_qual_recs); i++) {
    Rd_Data_Qual(&fs, fp_wr, i);
  }

  /* --- Read Data Histogram Record (one for each polarization) */
  for (i = 0; i < atoi(fs.descript.n_hist_recs); i++) {
    Rd_Histogram(&fs, fp_wr, i, diroutput);
  }

  /* --- Read Range Spectra Record (one for each polarization) */
  for (i = 0; i < atoi(fs.descript.n_spectra_recs); i++) {
    Rd_Range_Spectra(&fs, fp_wr, i, diroutput);
  }

  /*
   * --- Read Parameter Update Record (one for DWP, one receiver
   * --- gain per pol)
   */
  for (i = 0; i < atoi(fs.descript.n_update_recs); i++) {
    Rd_Update(&fs, fp_wr, i);
  }


  /* --- Read Detailed Processing Parameters Record */
  Rd_Detailed_Proc(&fs, fp_wr);

  /* --- Read Calibration Data Record */
  Rd_Calibration(&fs, fp_wr);

  /* Close output file */
  if (fclose(fp_wr) != 0) {
    edit_error("Error closing file : ", sarl_ascii);
  }

} /* Rd_SAR_Leader() */


/********************************************************************
*                                     
* Function:    Rd_Img_Opt                        
*                                     
* Abstract:    Read CEOS formatted Imagery Options File         
*                                     
* Description:  This routine reads each record in the CEOS Imagery Options
*        File and outputs the data in each to an ascii file.    
*                                     
*        Record in this file:                   
*                                     
*            File Descriptor Record              
*            Image (Signal) Data Record (one per image line)  
*                                     
* Inputs:    filename:  name of Imagery Options file to read from  
*                                     
* Outputs:    filename_"ascii"  ascii readable file          
*                                     
* Return Value:  none                           
*                                     
********************************************************************/

  void
Rd_Img_Opt(char *filename)
{


  FILE  *fp_rd;       /* pointer to imagery options file */
  FILE  *fp_wr;       /* pointer to ascii file to be created */

  int   nread;        /* number of elements read from disk */

  /* open the Imagery Options file for reading */
  if ((fp_rd = fopen(filename, "rb")) == NULL) {
    edit_error("Unable to open Imagery Options File :", imgopt_in);
  }

  /* read Imagery Options file in from disk */

  /*
   * read in file descriptor record.
   *
   * NOTE: The blanks padding the end of this record are not read in.
   *    They are not needed.
   */
  if ((nread = fread(&opt.descript, sizeof(opt.descript), 1, fp_rd)) < 1) {
    edit_error("Unable to read Imagery Options File : ", imgopt_in);
  }

  //if ( !save_flag) return;   /* RDC Modification */

  /* open/create an output file for writing file descriptor record to */
  if ((fp_wr = fopen(imgopt_ascii, "w+")) == NULL) {
    edit_error("Unable to create output file : ", imgopt_ascii);
  }
  /*
   * Read each record of the Imagery Options file.  Format the data and
   * write the contents of each record, in ascii, to the output file.
   */
  /* --- Read File Descriptor Record */
  Rd_IMG_Descript(&opt, fp_wr);
  /*
   * --- Read Each Image Data Record (or Signal Data Record)
   *   Strip the 12 byte CEOS preamble from each record.
   *   Concatenate the CEOS image records into one image file.
   *
   *   If the image is Multi-Look Detected, Multi_Look Complex,
   *   or Single-Look Complex, the resulting image file name will
   *   be "prXXXXX_img_ceos_image" where XXXXX is the processing
   *   run number.
   *
   *   If the image is Reformatted Signal Data, then one file for
   *   each polarization will be created.  For example, in the
   *   case of a quad-pol product, the resulting files will be:
   *   "prXXXXX_img_ceos_rsd_hh", "prXXXXX_img_ceos_rsd_hv",
   *   "prXXXXX_img_ceos_rsd_vv", "prXXXXX_img_ceos_vh".
   */
  /* Close the files */
  if (fclose(fp_wr) != 0) {
    edit_error("Error closing file : ", imgopt_ascii);
  }

  /* Close the file */
  if (fclose(fp_rd) != 0) {
    edit_error("Error closing file : ", imgopt_in);
  }

} /* Rd_Img_Opt() */


/********************************************************************
*                                     
* Function:    Rd_SAR_Trailer                      
*                                     
* Abstract:    Read CEOS SAR Trailer File                
*                                     
* Description:  This routine reads each record in the CEOS SAR Trailer File
*        and outputs the data in each to an ascii file.      
*                                     
* Inputs:    filename:  filename of SAR Trailer file to read from  
*                                     
* Outputs:    filename_"ascii"  output file              
*                                     
* Return Value:  non-zero:  if errors encountered            
*        zero:    if no errors encountered          
*                                     
********************************************************************/

  void
Rd_SAR_Trailer(char *filename)
{


  FILE  *fp_rd;       /* file pointer to file to read */
  FILE  *fp_wr;       /* file pointer to file to write */

  int   nread;        /* number of elements read from disk */

  /* open the SAR Trailer file for reading */
  if ((fp_rd = fopen(filename, "rb")) == NULL) {
    edit_error("Unable to open SAR Trailer File : ", sart_in);
  }

  /* read SAR Trailer file in from disk */

  /* read in file descriptor record */
  if ((nread = fread(&rp, sizeof(sart_descript_t), 1, fp_rd)) < 1) {
    edit_error("Unable to read : ", sart_in);
  }

  /* Close input file */
  if (fclose(fp_rd) != 0) {
    edit_error("Error closing file : ", sart_in);
    }


  //if ( !save_flag) return;  /* RDC Modification */

  /* open/create an output file for writing */
  if ((fp_wr = fopen(sart_ascii, "w+")) == NULL) {
    edit_error("Unable to create file : ", sart_ascii );
  }

  /*
   * Format the data and write the contents of each record, in ascii,
   * to the output file.
   * (NOTE: For SIR-C, the only record in the trailer file is the file
   * descriptor record.
   */

  /* --- Read File Descriptor Record */
  Rd_SART_Descript(&rp, fp_wr);

  /* Close output file */
  if (fclose(fp_wr) != 0) {
    edit_error("Error closing file : ", sart_ascii);
  }

} /* Rd_SAR_Trailer() */


/********************************************************************
*                                     
* Function:    Rd_SARL_Descript                     
*                                     
* Abstract:    Read File Descriptor Record               
*                                     
* Description:  This routine reads and prints the contents of the    
*        SAR Leader file descriptor record.            
*                                     
* Inputs:    fs:      pointer to structure of input file      
*        fp_wr;    pointer to output file            
*                                     
* Return Value:  void                           
*                                     
********************************************************************/

  void
Rd_SARL_Descript(sarl_file_t *fs, FILE *fp_wr)
{

  //hdr_t          hdr; /* header structure */
  sarl_descript_t     s;  /* file descriptor structure */

  char  string[LONG_NAME_LEN];
  char  sstring[LONG_NAME_LEN];

  /* First, output a boxed title for the data */
  Title_Box(SARL_TITLE, DESCR_REC, fp_wr, 0, 0, NULL, 0);

  /* Now, output the header info */
  Write_Header(fp_wr, &fs->descript.hdr);

  /* Finally, output record specific data */

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.ascii_flag, sizeof(s.ascii_flag));
  sprintf(string, "%-45s%s\n", ASCII_FL, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.doc_format, sizeof(s.doc_format));
  sprintf(string, "%-45s%s\n", DOC_FORM, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.format_rev, sizeof(s.format_rev));
  sprintf(string, "%-45s%s\n", FORM_REV, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.rec_format_rev, sizeof(s.rec_format_rev));
  sprintf(string, "%-45s%s\n", REC_REV, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.software_id, sizeof(s.software_id));
  sprintf(string, "%-45s%s\n", SW_VERS, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.file_no, sizeof(s.file_no));
  sprintf(string, "%-45s%s\n", FILE_NO, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.filename, sizeof(s.filename));
  sprintf(string, "%-45s%s\n", FILE_NAME, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.seq_flag, sizeof(s.seq_flag));
  sprintf(string, "%-45s%s\n", FSEQ, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.seq_location, sizeof(s.seq_location));
  sprintf(string, "%-45s%s\n", LOC_NO, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.seq_field_len, sizeof(s.seq_field_len));
  sprintf(string, "%-45s%s\n", SEQ_FLD_L, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.code_flag, sizeof(s.code_flag));
  sprintf(string, "%-45s%s\n", LOC_TYPE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.code_location, sizeof(s.code_location));
  sprintf(string, "%-45s%s\n", RCODE_LOC, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.code_field_len,
      sizeof(s.code_field_len));
  sprintf(string, "%-45s%s\n", RCODE_FLD_L, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_flag, sizeof(s.len_flag));
  sprintf(string, "%-45s%s\n", FLGT, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_location, sizeof(s.len_location));
  sprintf(string, "%-45s%s\n", REC_LEN_LOC, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_field_len, sizeof(s.len_field_len));
  sprintf(string, "%-45s%s\n", REC_LEN_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_data_set_recs, 
      sizeof(s.n_data_set_recs));
  sprintf(string, "%-45s%s\n", DS_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_data_set, sizeof(s.len_data_set));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_map_proj_recs, sizeof(s.n_map_proj_recs));
  sprintf(string, "%-45s%s\n", MP_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_map_proj, sizeof(s.len_map_proj));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_platf_recs, sizeof(s.n_platf_recs));
  sprintf(string, "%-45s%s\n", PLATF_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_platf, sizeof(s.len_platf));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_att_recs, sizeof(s.n_att_recs));
  sprintf(string, "%-45s%s\n", ATT_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_att, sizeof(s.len_att));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_radio_recs, sizeof(s.n_radio_recs));
  sprintf(string, "%-45s%s\n", RADIO_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_radio, sizeof(s.len_radio));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_radio_comp_recs,
      sizeof(s.n_radio_comp_recs));
  sprintf(string, "%-45s%s\n", RADIOC_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_radio_comp, sizeof(s.len_radio_comp));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_qual_recs, sizeof(s.n_qual_recs));
  sprintf(string, "%-45s%s\n", QUAL_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_qual, sizeof(s.len_qual));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_hist_recs, sizeof(s.n_hist_recs));
  sprintf(string, "%-45s%s\n", HIST_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_hist, sizeof(s.len_hist));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_spectra_recs, sizeof(s.n_spectra_recs));
  sprintf(string, "%-45s%s\n", SPEC_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_spectra, sizeof(s.len_spectra));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_elev_recs, sizeof(s.n_elev_recs));
  sprintf(string, "%-45s%s\n", ELEV_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_elev, sizeof(s.len_elev));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_update_recs, sizeof(s.n_update_recs));
  sprintf(string, "%-45s%s\n", UPD_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_update, sizeof(s.len_update));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_annot_recs, sizeof(s.n_annot_recs));
  sprintf(string, "%-45s%s\n", ANNOT_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_annot, sizeof(s.len_annot));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_proc_recs, sizeof(s.n_proc_recs));
  sprintf(string, "%-45s%s\n", PROC_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_proc, sizeof(s.len_proc));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_calib_recs, sizeof(s.n_calib_recs));
  sprintf(string, "%-45s%s\n", CAL_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_calib, sizeof(s.len_calib));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_ground, sizeof(s.n_ground));
  sprintf(string, "%-45s%s\n", GROUND_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_ground, sizeof(s.len_ground));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_facil_recs, sizeof(s.n_facil_recs));
  sprintf(string, "%-45s%s\n", FAC_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_facil, sizeof(s.len_facil));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

} /* Rd_SARL_Descript() */


/********************************************************************
*                                     
* Function:    Rd_Data_Summary                      
*                                     
* Abstract:    Read Data Set Summary record               
*                                     
* Description:  This routine reads and prints the contents of the    
*        data set summary record.                 
*                                     
* Inputs:    fs:      pointer to structure of input file      
*        fp_wr;    pointer to output file            
*                                     
* Return Value:  void                           
*                                     
********************************************************************/

  void
Rd_Data_Summary(sarl_file_t *fs, FILE *fp_wr)
{

  //hdr_t          hdr; /* header structure */
  sarl_data_summary_t   s;  /* data summary structure */
  //sensor_id_t       id;  /* sensor ID structure */

  char  string[LONG_NAME_LEN];
  char  sstring[LONG_NAME_LEN];
  
  /* First, output a boxed title for the data */
  Title_Box(SARL_TITLE, DSS_REC, fp_wr, 0, 0, NULL, 0);

  /* Now, output the header info */
  Write_Header(fp_wr, &fs->data_set.hdr);

  /* Finally, output record specific data */

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.seq_no, sizeof(s.seq_no));
  sprintf(string, "%-45s%s\n", SEQ_NO, sstring);
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
  sprintf(string, "%-45s%s\n", N_CHAN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.platform_id, sizeof(s.platform_id));
  sprintf(string, "%-45s%s\n", PLAT_ID, sstring);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.sensor_id.sensid,
      sizeof(s.sensor_id.sensid));
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
  sprintf(string, "%-45s%s\n", DT_ID, sstring);
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
  strncpy(sstring, fs->data_set.platform_heading,
      sizeof(s.platform_heading));
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
  strncpy(sstring, fs->data_set.frequency, sizeof(s.frequency));
  justify(sstring, sizeof(s.frequency), dest);
  sprintf(string, "%-45s%s\n", FREQ, dest);
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
  strncpy(sstring, fs->data_set.rg_pulse_phase2, sizeof(s.rg_pulse_phase2));
  justify(sstring, sizeof(s.rg_pulse_phase2), dest);
  sprintf(string, "%-45s%s\n", CHIRP_FR, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.rg_pulse_phase3, sizeof(s.rg_pulse_phase3));
  justify(sstring, sizeof(s.rg_pulse_phase3), dest);
  sprintf(string, "%-45s%s\n", CHIRP_RATE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.rg_sampling_rate,
      sizeof(s.rg_sampling_rate));
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
  sprintf(string, "%-45s%s\n", Q_BITS, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.quant_descr, sizeof(s.quant_descr));
  sprintf(string, "%-45s%s\n", QUANT_DES, sstring);
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
  strncpy(sstring, fs->data_set.echo_tracker_flag,
      sizeof(s.echo_tracker_flag));
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
  strncpy(sstring, fs->data_set.proc_facility, sizeof(s.proc_facility));
  sprintf(string, "%-45s%s\n", JPL, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.hw_version, sizeof(s.hw_version));
  sprintf(string, "%-45s%s\n", HW_VERS, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.sw_version, sizeof(s.sw_version));
  sprintf(string, "%-45s%s\n", SW_VERS, sstring);
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
  strncpy(sstring, fs->data_set.n_looks, sizeof(s.n_looks));
  justify(sstring, sizeof(s.n_looks), dest);
  sprintf(string, "%-45s%s\n", N_LOOKS, dest);
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
  strncpy(sstring, fs->data_set.rg_time_dir, sizeof(s.rg_time_dir));
  sprintf(string, "%-45s%s\n", RG_TIME, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.az_time_dir, sizeof(s.az_time_dir));
  sprintf(string, "%-45s%s\n", AZ_TIME, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.electronic_delay, 
      sizeof(s.electronic_delay));
  justify(sstring, sizeof(s.electronic_delay), dest);
  sprintf(string, "%-45s%s\n", ELEC_DELAY, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.line_content, sizeof(s.line_content));
  sprintf(string, "%-45s%s\n", LINE_CON, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.clutter_lock_flag,
      sizeof(s.clutter_lock_flag));
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
  strncpy(sstring, fs->data_set.orbit_dir, sizeof(s.orbit_dir));
  sprintf(string, "%-45s%s\n", ORBIT_DIR, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_set.annot_pts, sizeof(s.annot_pts));
  sprintf(string, "%-45s%s\n", N_ANNOT, sstring);
  fprintf(fp_wr, "%s", string);


} /* Rd_Data_Summary() */


/********************************************************************
*                                     
* Function:    Rd_Map_Proj                        
*                                     
* Abstract:    Read Map Projection Record                
*                                     
* Description:  This routine reads and prints the contents of the    
*        map projection data record.                
*                                     
* Inputs:    fs:      pointer to structure of input file      
*        fp_wr;    pointer to output file            
*                                     
* Return Value:  void                           
*                                     
********************************************************************/

  void
Rd_Map_Proj(sarl_file_t *fs, FILE *fp_wr)
{

  //hdr_t          hdr; /* header structure */
  sarl_map_proj_t     s;  /* map projection structure */

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
  sprintf(string, "%-45s%s\n", N_PIXELS, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.n_lines, sizeof(s.n_lines));
  sprintf(string, "%-45s%s\n", N_LINES, sstring);
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
  strncpy(sstring,  fs->map_proj.platform_heading,
      sizeof(s.platform_heading));
  justify(sstring, sizeof(s.platform_heading), dest);
  sprintf(string, "%-45s%s\n", PLAT_HD, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.ellipsoid_name, sizeof(s.ellipsoid_name));
  sprintf(string, "%-45s%s\n", ELLIPSE_NAME, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.semimajor_axis, sizeof(s.semimajor_axis));
  justify(sstring, sizeof(s.semimajor_axis), dest);
  sprintf(string, "%-45s%s\n", MAJOR_AXIS, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->map_proj.semiminor_axis, sizeof(s.semiminor_axis));
  justify(sstring, sizeof(s.semiminor_axis), dest);
  sprintf(string, "%-45s%s\n", MINOR_AXIS, dest);
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

} /* Rd_Map_Proj() */


/********************************************************************
*                                     
* Function:    Rd_Platform                        
*                                     
* Abstract:    Read Platfrom Position Data Record            
*                                     
* Description:  This routine reads and prints the contents of the platform
*        data record.  There is one "main" record followed by a  
*        variable number of data sets.              
*                                     
* Inputs:    fs:      pointer to structure of input file      
*        fp_wr:    pointer to output file            
*                                     
* Return Value:  void                           
*                                     
********************************************************************/

  void
Rd_Platform(sarl_file_t *fs, FILE *fp_wr)
{

  //hdr_t        hdr;  /* header structure */
  sarl_platf_pos_t  s;    /* platform structure */

  char  string[LONG_NAME_LEN];
  char  sstring[LONG_NAME_LEN];
  char  sstring1[LONG_NAME_LEN];
  char  sstring2[LONG_NAME_LEN];

  int   i;        /* loop counters */

  /* First, output a boxed title for the data */
  Title_Box(SARL_TITLE, PLATF_REC, fp_wr, 0, 0, NULL, 0);

  /* Now, output the header info */
  Write_Header(fp_wr, &fs->platform.hdr);

  /* Finally, output record specific data */

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->platform.n_data_sets, sizeof(s.n_data_sets));
  sprintf(string, "%-45s%s\n", N_SETS, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->platform.year, sizeof(s.year));
  sprintf(string, "%-45s%s\n", PLAT_YEAR, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->platform.month, sizeof(s.month));
  sprintf(string, "%-45s%s\n", PLAT_MONTH, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->platform.day, sizeof(s.day));
  sprintf(string, "%-45s%s\n", PLAT_DAY, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->platform.day_in_year, sizeof(s.day_in_year));
  sprintf(string, "%-45s%s\n", PLAT_DIY, sstring);
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
  sprintf(string, "%-45s%s\n", PLAT_COORD, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->platform.hour_angle, sizeof(s.hour_angle));
  sprintf(string, "%-45s%s\n", PLAT_HOUR, sstring);
  fprintf(fp_wr, "%s", string);

  /* Loop through each data set */
  for (i = 0; i < atoi(fs->platform.n_data_sets); i++) {


    sprintf(string, "\n\n%s %d %s\n\n", DATAS1, i+1, DATAS2);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, platf_ptr->pos_vector[0],sizeof(platf_ptr->pos_vector[0]));

    memset(sstring1, 0, sizeof(sstring1));
    strncpy(sstring1, platf_ptr->pos_vector[1],sizeof(platf_ptr->pos_vector[1]));

    memset(sstring2, 0, sizeof(sstring2));
    strncpy(sstring2, platf_ptr->pos_vector[2],sizeof(platf_ptr->pos_vector[2]));

    sprintf(string, "%-25s\n%s\n%s %s %s\n\n", PLAT_POSV, PLAT_XYZ, sstring, sstring1, sstring2);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, platf_ptr->vel_vector[0],sizeof(platf_ptr->vel_vector[0]));

    memset(sstring1, 0, sizeof(sstring1));
    strncpy(sstring1, platf_ptr->vel_vector[1],sizeof(platf_ptr->vel_vector[1]));

    memset(sstring2, 0, sizeof(sstring2));
    strncpy(sstring2, platf_ptr->vel_vector[2],sizeof(platf_ptr->vel_vector[2]));

    sprintf(string, "%-25s\n%s\n%s %s %s\n\n",PLAT_VEL, PLAT_XYZ,sstring, sstring1, sstring2);
    fprintf(fp_wr, "%s", string);

    /* Update pointer to point to next data set */
    platf_ptr++;

  } /* for each data set */

} /* Rd_Platform() */


/********************************************************************
*                                     
* Function:    Rd_Attitude                        
*                                     
* Abstract:    Read Attitude Data Record                
*                                     
* Description:  This routine reads and prints the contents of the attitude
*        data record.  There is one "main" record followed by a  
*        variable number of attitude data sets.          
*                                     
* Inputs:    fs:      pointer to structure of input file      
*        fp_wr:    pointer to output file            
*                                     
* Return Value:  void                           
*                                     
********************************************************************/

  void
Rd_Attitude(sarl_file_t *fs, FILE *fp_wr)
{

  //hdr_t        hdr;  /* header structure */
  sarl_attitude_t   s;    /* attitude structure */

  char  string[LONG_NAME_LEN];
  char  sstring[LONG_NAME_LEN];

  int   i;        /* loop counters */

  /* First, output a boxed title for the data */
  Title_Box(SARL_TITLE, ATT_REC, fp_wr, 0, 0, NULL, 0);
        
  /* Now, output the header info */
  Write_Header(fp_wr, &fs->attitude.hdr);

  /* Finally, output record specific data */

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->attitude.n_data_sets, sizeof(s.n_data_sets));
  sprintf(string, "%-45s%s\n", N_SETS, sstring);
  fprintf(fp_wr, "%s", string);

  /* Loop through each data set */
  for (i = 0; i < atoi(fs->attitude.n_data_sets); i++) {

    sprintf(string, "\n\n%s %d %s\n\n", DATAS1, i+1, DATAS2);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, att_ptr->days,
        sizeof(att_ptr->days));
    sprintf(string, "%-45s%s\n", ATT_DAYS, sstring);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, att_ptr->millisecs,
        sizeof(att_ptr->millisecs));
    sprintf(string, "%-45s%s\n", ATT_SECS, sstring);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, att_ptr->pitch,
        sizeof(att_ptr->pitch));
    justify(sstring, sizeof(att_ptr->pitch), dest);
    sprintf(string, "%-45s%s\n", ATT_PITCH, dest);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, att_ptr->roll,
        sizeof(att_ptr->roll));
    justify(sstring, sizeof(att_ptr->roll), dest);
    sprintf(string, "%-45s%s\n", ATT_ROLL, dest);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, att_ptr->yaw,
        sizeof(att_ptr->yaw));
    justify(sstring, sizeof(att_ptr->yaw), dest);
    sprintf(string, "%-45s%s\n", ATT_YAW, dest);
    fprintf(fp_wr, "%s", string);

    /* Update pointer to point to next data set */
    att_ptr++;

  } /* for each data set */

} /* Rd_Attitude() */


/********************************************************************
*                                     
* Function:    Rd_Radiometric                      
*                                     
* Abstract:    Read Radiometric Data Record               
*                                     
* Description:  This routine reads and prints the contents of the    
*        radiometric data record.                 
*                                     
* Inputs:    fs:      pointer to structure of input file      
*        fp_wr:    pointer to output file            
*        index:    index into array of pointers to linked lists
*                                     
* Return Value:  void                           
*                                     
********************************************************************/

  void
Rd_Radiometric(sarl_file_t *fs, FILE *fp_wr, int index)
{

  //hdr_t        hdr;  /* header structure */
  sarl_radio_t    s;    /* radiometric structure */

  char  string[LONG_NAME_LEN];
  char  sstring[LONG_NAME_LEN];

  int   i;          /* loop counter */

  /* First, output a boxed title for the data */
  Title_Box(SARL_TITLE, RADIO_REC, fp_wr, 
        atoi(fs->radio[index].seq_no),
        atoi(fs->descript.n_radio_recs),
        radio_ptr[index]->sar_channel,
        sizeof(radio_ptr[index]->sar_channel));
  
  /* Now, output the header info */
  Write_Header(fp_wr, &fs->radio[index].hdr);
  
  /* Finally, output record specific data */
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio[index].seq_no, sizeof(s.seq_no));
  sprintf(string, "%-45s%s\n", SEQ_NO, sstring);
  fprintf(fp_wr, "%s", string);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio[index].n_data_sets, sizeof(s.n_data_sets));
  sprintf(string, "%-45s%s\n", N_SETS, sstring);
  fprintf(fp_wr, "%s", string);
  
  /* Loop through each data set */
  for (i = 0; i < atoi(fs->radio[index].n_data_sets); i++) {
    
    sprintf(string, "\n\n%s %d %s\n\n", DATAS1, i+1, DATAS2);
    fprintf(fp_wr, "%s", string);
    
    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, radio_ptr[index]->data_set_size,
        sizeof(radio_ptr[index]->data_set_size));
    sprintf(string, "%-45s%s\n", DATA_ARRY_SZ, sstring);
    fprintf(fp_wr, "%s", string);
    
    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, radio_ptr[index]->sar_channel,
        sizeof(radio_ptr[index]->sar_channel));
    sprintf(string, "%-45s%s\n", BAND_POL, sstring);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, radio_ptr[index]->calibration_date,
        sizeof(radio_ptr[index]->calibration_date));
    sprintf(string, "%-45s%s\n", CAL_DATE, sstring);
    fprintf(fp_wr, "%s", string);
    
    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, radio_ptr[index]->n_samples,
        sizeof(radio_ptr[index]->n_samples));
    sprintf(string, "%-45s%s\n", N_SAMPLES, sstring);
    fprintf(fp_wr, "%s", string);
    
    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, radio_ptr[index]->sample_type,
        sizeof(radio_ptr[index]->sample_type));
    sprintf(string, "%-45s%s\n", SMPL_TYPE, sstring);
    fprintf(fp_wr, "%s", string);
    
    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, radio_ptr[index]->noise_est,
        sizeof(radio_ptr[index]->noise_est));
    justify(sstring, sizeof(radio_ptr[index]->noise_est), dest);
    sprintf(string, "%-45s%s\n", NOISE_POW, dest);
    fprintf(fp_wr, "%s", string);
    
    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, radio_ptr[index]->linear_conv_fact,
        sizeof(radio_ptr[index]->linear_conv_fact));
    justify(sstring, sizeof(radio_ptr[index]->linear_conv_fact), dest);
    sprintf(string, "%-45s%s\n", LCF, dest);
    fprintf(fp_wr, "%s", string);
    
    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, radio_ptr[index]->proc_gain_noise,
        sizeof(radio_ptr[index]->proc_gain_noise));
    justify(sstring, sizeof(radio_ptr[index]->proc_gain_noise), dest);
    sprintf(string, "%-45s%s\n", OCF, dest);
    fprintf(fp_wr, "%s", string);
    
    /* Update pointer to point to next data set */
    radio_ptr[index]++;

  } /* for each data set */
  
} /* Rd_Radiometric() */


/********************************************************************
*                                     
* Function:    Rd_Radio_Comp                      
*                                     
* Abstract:    Read Radiometric Compensation Data Record        
*                                     
* Description:  This routine reads and prints the contents of the    
*        radiometric compensation data record.          
*                                     
* Inputs:    fs:      pointer to structure of input file      
*        fp_wr:    pointer to output file            
*        index:    index into array of pointers to linked lists
*                                     
* Return Value:  void                           
*                                     
********************************************************************/

  void
Rd_Radio_Comp(sarl_file_t *fs, FILE *fp_wr, int index, char *diroutput)
{

  //hdr_t        hdr;  /* header structure */
  sarl_radio_comp_t  s;    /* radiometric comp structure */

  char  string[LONG_NAME_LEN];
  char  sstring[LONG_NAME_LEN];
  char  plotfile[LONG_NAME_LEN];
  int   i;          /* loop counter */

  FILE  *fp_data;      /* pointer to file of radio comp values */



  /* First, output a boxed title for the data */
  Title_Box(SARL_TITLE, RADIOC_REC, fp_wr,
        atoi(fs->radio_comp[index].seq_no),
        atoi(fs->descript.n_radio_comp_recs),
        fs->radio_comp[index].sar_channel,
        sizeof(s.sar_channel));

  /* Now, output the header info */
  Write_Header(fp_wr, &fs->radio_comp[index].hdr);

  /* Finally, output record specific data */

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio_comp[index].seq_no, sizeof(s.seq_no));
  sprintf(string, "%-45s%s\n", SEQ_NO, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio_comp[index].sar_channel, sizeof(s.sar_channel));
  sprintf(string, "%-45s%s\n", BAND_POL, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio_comp[index].n_data_sets, sizeof(s.n_data_sets));
  sprintf(string, "%-45s%s\n", N_SETS, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio_comp[index].data_set_size,
      sizeof(s.data_set_size));
  sprintf(string, "%-45s%s\n", SET_SIZE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio_comp[index].data_type, sizeof(s.data_type));
  sprintf(string, "%-45s%s\n", DESIGN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio_comp[index].data_descr, sizeof(s.data_descr));
  sprintf(string, "%-45s%s\n", DESCRIPT, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio_comp[index].req_records, sizeof(s.req_records));
  sprintf(string, "%-45s%s\n", REQ_REC, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio_comp[index].table_seq_num,
      sizeof(s.table_seq_num));
  sprintf(string, "%-45s%s\n", TABLE_SEQ, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio_comp[index].first_pixel, sizeof(s.first_pixel));
  sprintf(string, "%-45s%s\n", COMP1, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio_comp[index].last_pixel, sizeof(s.last_pixel));
  sprintf(string, "%-45s%s\n", COMP_LAST, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio_comp[index].pixel_size, sizeof(s.pixel_size));
  sprintf(string, "%-45s%s\n", GROUP_SZ, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio_comp[index].min_samp_index,
      sizeof(s.min_samp_index));
  justify(sstring, sizeof(s.min_samp_index), dest);
  sprintf(string, "%-45s%s\n", MIN_INDEX, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio_comp[index].min_comp_value,
      sizeof(s.min_comp_value));
  justify(sstring, sizeof(s.min_comp_value), dest);
  sprintf(string, "%-45s%s\n", MIN_COMP, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio_comp[index].max_samp_index,
      sizeof(s.max_samp_index));
  justify(sstring, sizeof(s.max_samp_index), dest);
  sprintf(string, "%-45s%s\n", MAX_INDEX, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio_comp[index].max_comp_value,
      sizeof(s.max_comp_value));
  justify(sstring, sizeof(s.max_comp_value), dest);
  sprintf(string, "%-45s%s\n", MAX_COMP, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->radio_comp[index].n_table_entries,
      sizeof(s.n_table_entries));
  sprintf(string, "%-45s%s\n", COMP_N_ENT, sstring);
  fprintf(fp_wr, "%s", string);

  /* Get filename for storing data values */
  memset(string, 0, sizeof(string));
  strncpy(string, fs->radio_comp[index].sar_channel, 3);
  sprintf(plotfile, "%spr%s_radioplot_%s%s", diroutput, proc_run, string, ".txt");
  
  /* Create the data file named above */
  if ((fp_data = fopen(plotfile, "w")) == NULL) {
    edit_error("Unable to create file :  ", plotfile);
  }
  
  /* Write name of plot file to output file */
  fprintf(fp_wr, "\n\nData values stored in file: %s\n", plotfile);
  
  /* Write (x,y) values to file */
  for (i = 0; i < atoi(fs->radio_comp[index].n_table_entries); i++) {
    
    fprintf(fp_data, "%d\t%16.7f\n",
        (i * atoi(fs->radio_comp[index].pixel_size)) + 1,
        atof(radioc_ptr[index]->sample_value));
  }
  
  /* Update pointer to point to next data set */
  radioc_ptr[index]++;
  
} /* Rd_Radio_Comp() */


/********************************************************************
*                                     
* Function:    Rd_Data_Qual                       
*                                     
* Abstract:    Read Data Quality Summary Record             
*                                     
* Description:  This routine reads and prints the contents of the    
*        data quality summary record.               
*                                     
* Inputs:    fs:      pointer to structure of input file      
*        fp_wr;    pointer to output file            
*                                     
* Return Value:  void                           
*                                     
********************************************************************/

  void
Rd_Data_Qual(sarl_file_t *fs, FILE *fp_wr, int index)
{

  //hdr_t          hdr;  /* header structure */
  sarl_data_qual_summary_t s;    /* data quality structure */

  char  string[LONG_NAME_LEN];
  char  sstring[LONG_NAME_LEN];

  /* First, output a boxed title for the data */
  Title_Box(SARL_TITLE, QUAL_REC, fp_wr,
        atoi(fs->data_qual[index].seq_no),
        atoi(fs->descript.n_qual_recs),
        fs->data_qual[index].sar_channel,
        sizeof(fs->data_qual[index].sar_channel));

  /* Now, output the header info */
  Write_Header(fp_wr, &fs->data_qual[index].hdr);

  /* Finally, output record specific data */

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual[index].seq_no, sizeof(s.seq_no));
  sprintf(string, "%-45s%s\n", SEQ_NO, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual[index].sar_channel, sizeof(s.sar_channel));
  sprintf(string, "%-45s%s\n", BAND_POL, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual[index].calibr_date, sizeof(s.calibr_date));
  sprintf(string, "%-45s%s\n", CAL_DATE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual[index].n_channels, sizeof(s.n_channels));
  sprintf(string, "%-45s%s\n", N_CHAN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual[index].islr, sizeof(s.islr));
  justify(sstring, sizeof(s.islr), dest);
  sprintf(string, "%-45s%s\n", ISLR, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual[index].pslr, sizeof(s.pslr));
  justify(sstring, sizeof(s.pslr), dest);
  sprintf(string, "%-45s%s\n", PSLR, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual[index].az_ambig, sizeof(s.az_ambig));
  justify(sstring, sizeof(s.az_ambig), dest);
  sprintf(string, "%-45s%s\n", AZ_AMB, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual[index].rg_ambig, sizeof(s.rg_ambig));
  justify(sstring, sizeof(s.rg_ambig), dest);
  sprintf(string, "%-45s%s\n", RG_AMB, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual[index].snr_est, sizeof(s.snr_est));
  justify(sstring, sizeof(s.snr_est), dest);
  sprintf(string, "%-45s%s\n", SNR_EST, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual[index].ber, sizeof(s.ber));
  justify(sstring, sizeof(s.ber), dest);
  sprintf(string, "%-45s%s\n", BER, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual[index].slant_rg_res,
      sizeof(s.slant_rg_res));
  justify(sstring, sizeof(s.slant_rg_res), dest);
  sprintf(string, "%-45s%s\n", SLANT_RES, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual[index].az_res, sizeof(s.az_res));
  justify(sstring, sizeof(s.az_res), dest);
  sprintf(string, "%-45s%s\n", AZ_RES, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual[index].radio_res, sizeof(s.radio_res));
  justify(sstring, sizeof(s.radio_res), dest);
  sprintf(string, "%-45s%s\n", RADIO_RES, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual[index].dynam_rg, sizeof(s.dynam_rg));
  justify(sstring, sizeof(s.dynam_rg), dest);
  sprintf(string, "%-45s%s\n", DYNAMIC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual[index].abs_radio_unc, 
      sizeof(s.abs_radio_unc));
  justify(sstring, sizeof(s.abs_radio_unc), dest);
  sprintf(string, "%-45s%s\n", ABS_RAD_UNC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual[index].relst_radio_unc,
      sizeof(s.relst_radio_unc));
  justify(sstring, sizeof(s.relst_radio_unc), dest);
  sprintf(string, "%-45s%s\n", SHORT_UNC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual[index].rel_phase_uncert,
      sizeof(s.rel_phase_uncert));
  justify(sstring, sizeof(s.rel_phase_uncert), dest);
  sprintf(string, "%-45s%s\n", PHASE_UNC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual[index].rellt_radio_unc,
      sizeof(s.rellt_radio_unc));
  justify(sstring, sizeof(s.rellt_radio_unc), dest);
  sprintf(string, "%-45s%s\n", LONG_UNC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual[index].st_freq_freq, 
      sizeof(s.st_freq_freq));
  justify(sstring, sizeof(s.st_freq_freq), dest);
  sprintf(string, "%-45s%s\n", SHORT_CL, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual[index].lt_freq_freq,
      sizeof(s.lt_freq_freq));
  justify(sstring, sizeof(s.lt_freq_freq), dest);
  sprintf(string, "%-45s%s\n", LONG_CL, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual[index].along_loc_error,
      sizeof(s.along_loc_error));
  justify(sstring, sizeof(s.along_loc_error), dest);
  sprintf(string, "%-45s%s\n", ALOC_E, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual[index].cross_loc_error,
      sizeof(s.cross_loc_error));
  justify(sstring, sizeof(s.cross_loc_error), dest);
  sprintf(string, "%-45s%s\n", XLOC_E, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual[index].along_scale_err, 
      sizeof(s.along_scale_err));
  justify(sstring, sizeof(s.along_scale_err), dest);
  sprintf(string, "%-45s%s\n", ASCALE_E, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual[index].cross_scale_err,
      sizeof(s.cross_scale_err));
  justify(sstring, sizeof(s.cross_scale_err), dest);
  sprintf(string, "%-45s%s\n", XSCALE_E, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual[index].skew_err, sizeof(s.skew_err));
  justify(sstring, sizeof(s.skew_err), dest);
  sprintf(string, "%-45s%s\n", SKEW_E, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual[index].orient_err, sizeof(s.orient_err));
  justify(sstring, sizeof(s.orient_err), dest);
  sprintf(string, "%-45s%s\n", ORIENT_E, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual[index].along_err_hh,
      sizeof(s.along_err_hh));
  justify(sstring, sizeof(s.along_err_hh), dest);
  sprintf(string, "%-45s%s\n", AREG_E, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual[index].cross_err_hh,
      sizeof(s.cross_err_hh));
  justify(sstring, sizeof(s.cross_err_hh), dest);
  sprintf(string, "%-45s%s\n", XREG_E, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual[index].along_err_lc, 
      sizeof(s.along_err_lc));
  justify(sstring, sizeof(s.along_err_lc), dest);
  sprintf(string, "%-45s%s\n", AREG_CL_E, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->data_qual[index].cross_err_lc, 
      sizeof(s.cross_err_lc));
  justify(sstring, sizeof(s.cross_err_lc), dest);
  sprintf(string, "%-45s%s\n", XREG_CL_E, dest);
  fprintf(fp_wr, "%s", string);

} /* Rd_Data_Qual() */


/********************************************************************
*                                     
* Function:    Rd_Histogram                       
*                                     
* Abstract:    Read Histogram Record                  
*                                     
* Description:  This routine reads and prints the contents of the    
*        histogram record.                    
*                                     
* Inputs:    fs:      pointer to structure of input file      
*        fp_wr;    pointer to output file            
*        index;    index into array of histogram records    
*                                     
* Return Value:  void                           
*                                     
********************************************************************/

  void
Rd_Histogram(sarl_file_t *fs, FILE *fp_wr, int index, char *diroutput)
{

  //hdr_t        hdr;  /* header structure */
  sarl_histogram_t  s;    /* histogram  structure */

  char  string[LONG_NAME_LEN];
  char  sstring[LONG_NAME_LEN];
  char  plotfile[LONG_NAME_LEN];

  int   i,j;        /* loop counters */

  FILE  *fp_data;      /* pointer to file of histogram values */

  /* First, output a boxed title for the data */
  Title_Box(SARL_TITLE, HIST_REC, fp_wr,
        atoi(fs->histogram[index].seq_no),
        atoi(fs->descript.n_hist_recs),
        fs->histogram[index].sar_channel,
        sizeof(fs->histogram[index].sar_channel));

  /* Now, output the header info */
  Write_Header(fp_wr, &fs->histogram[index].hdr);

  /* Finally, output record specific data */

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->histogram[index].seq_no, sizeof(s.seq_no));
  sprintf(string, "%-45s%s\n", SEQ_NO, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->histogram[index].sar_channel, sizeof(s.sar_channel));
  sprintf(string, "%-45s%s\n", BAND_POL, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->histogram[index].n_data_sets, sizeof(s.n_data_sets));
  sprintf(string, "%-45s%s\n", N_SETS, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->histogram[index].data_set_size,
      sizeof(s.data_set_size));
  sprintf(string, "%-45s%s\n", SET_SIZE, sstring);
  fprintf(fp_wr, "%s", string);

  /* Loop through each data set */
  for (i = 0; i < atoi(fs->histogram[index].n_data_sets); i++) {

    sprintf(string, "\n\n%s %d %s\n\n", DATAS1, i+1, DATAS2);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, hist_ptr[index]->descriptor,
        sizeof(hist_ptr[index]->descriptor));
    sprintf(string, "%-45s%s\n", HIST_DESCR, sstring);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, hist_ptr[index]->req_recs,
        sizeof(hist_ptr[index]->req_recs));
    sprintf(string, "%-45s%s\n", HIST_REQ, sstring);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, hist_ptr[index]->table_no,
        sizeof(hist_ptr[index]->table_no));
    sprintf(string, "%-45s%s\n", TABLE_NO, sstring);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, hist_ptr[index]->table_size,
        sizeof(hist_ptr[index]->table_size));
    sprintf(string, "%-45s%s\n", TABLE_SIZE, sstring);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, hist_ptr[index]->n_pixels,
        sizeof(hist_ptr[index]->n_pixels));
    if (strncmp(RAW_DATA_HIST, hist_ptr[index]->descriptor, 3)) {
      sprintf(string, "%-45s%s\n", HIST_PIX, sstring);
    } else {
      sprintf(string, "%-45s%s\n", HIST_SAMP, sstring);
    }
    fprintf(fp_wr, "%s", string);
    
    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, hist_ptr[index]->n_lines,
        sizeof(hist_ptr[index]->n_lines));
    if (strncmp(RAW_DATA_HIST, hist_ptr[index]->descriptor, 3)) {
      sprintf(string, "%-45s%s\n", HIST_LINES, sstring);
    } else {
      sprintf(string, "%-45s%s\n", HIST_RECS, sstring);
    }
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, hist_ptr[index]->cross_pixels,
        sizeof(hist_ptr[index]->cross_pixels));
    sprintf(string, "%-45s%s\n", CROSS_PIX, sstring);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, hist_ptr[index]->along_pixels,
        sizeof(hist_ptr[index]->along_pixels));
    sprintf(string, "%-45s%s\n", ALONG_PIX, sstring);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, hist_ptr[index]->n_groups_cross,
        sizeof(hist_ptr[index]->n_groups_cross));
    sprintf(string, "%-45s%s\n", CROSS_GPS, sstring);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, hist_ptr[index]->n_groups_along,
        sizeof(hist_ptr[index]->n_groups_along));
    sprintf(string, "%-45s%s\n", ALONG_GPS, sstring);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, hist_ptr[index]->min_sample_value,
        sizeof(hist_ptr[index]->min_sample_value));
    justify(sstring, sizeof(hist_ptr[index]->min_sample_value), dest);
    sprintf(string, "%-45s%s\n", MIN_PIXEL, dest);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, hist_ptr[index]->max_sample_value,
        sizeof(hist_ptr[index]->max_sample_value));
    justify(sstring, sizeof(hist_ptr[index]->max_sample_value), dest);
    sprintf(string, "%-45s%s\n", MAX_PIXEL, dest);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, hist_ptr[index]->mean,
        sizeof(hist_ptr[index]->mean));
    justify(sstring, sizeof(hist_ptr[index]->mean), dest);
    sprintf(string, "%-45s%s\n", HIST_MEAN, dest);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, hist_ptr[index]->std_dev,
        sizeof(hist_ptr[index]->std_dev));
    justify(sstring, sizeof(hist_ptr[index]->std_dev), dest);
    sprintf(string, "%-45s%s\n", HIST_ST_DEV, dest);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, hist_ptr[index]->increment,
        sizeof(hist_ptr[index]->increment));
    justify(sstring, sizeof(hist_ptr[index]->increment), dest);
    sprintf(string, "%-45s%s\n", INCREMENT, dest);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, hist_ptr[index]->min_value,
        sizeof(hist_ptr[index]->min_value));
    justify(sstring, sizeof(hist_ptr[index]->min_value), dest);
    sprintf(string, "%-45s%s\n", MIN_TABLE, dest);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, hist_ptr[index]->max_value,
        sizeof(hist_ptr[index]->max_value));
    justify(sstring, sizeof(hist_ptr[index]->max_value), dest);
    sprintf(string, "%-45s%s\n", MAX_TABLE, dest);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, hist_ptr[index]->n_bins,
        sizeof(hist_ptr[index]->n_bins));
    sprintf(string, "%-45s%s\n", HIST_N_BINS, sstring);
    fprintf(fp_wr, "%s", string);

    /* Get filename for storing data values */
    memset(string, 0, sizeof(string));
    memset(sstring, 0, sizeof(sstring));
    strncpy(string, fs->histogram[index].sar_channel, 3);
    strncpy(sstring, hist_ptr[index]->descriptor, 3);
    sprintf(plotfile, "%spr%s_histoplot_%s_%s%s", diroutput, proc_run, sstring, string, ".txt");
    check_file(plotfile);

    strcpy (polar[index], string);   /* RDC Modification */

    /* Create the data file named above */
    if ((fp_data = fopen(plotfile, "w")) == NULL) {
      edit_error("Unable to create file : ", plotfile);
    }

    /* Write name of plot file to output file */
    fprintf(fp_wr, "\n\nData values stored in file: %s\n", plotfile);

    /* Write (x,y) values to file */
    for (j = 0; j < atoi(hist_ptr[index]->n_bins); j++) {
      fprintf(fp_data, "%d\t%16.7f\n",j + 1,atof(hist_ptr[index]->data_values[j]));
    }

    /* close the file containing histogram data */
    fclose(fp_data);

    /* Update pointer to point to next data set */
    hist_ptr[index]++;

  } /* for each data set */

} /* Rd_Histogram() */


/********************************************************************
*                                     
* Function:    Rd_Range_Spectra                     
*                                     
* Abstract:    Read Range Spectra Record                
*                                     
* Description:  This routine reads and prints the contents of the    
*        range spectra record.                  
*                                     
* Inputs:    fs:      pointer to structure of input file      
*        fp_wr;    pointer to output file            
*                                     
* Return Value:  void                           
*                                     
********************************************************************/

  void
Rd_Range_Spectra(sarl_file_t *fs, FILE *fp_wr, int index, char *diroutput)
{

  //hdr_t       hdr;    /* header structure */
  sarl_spectra_t  s;    /* data quality structure */

  char  string[LONG_NAME_LEN];
  char  sstring[LONG_NAME_LEN];

  int   i;          /* loop counter */

  FILE  *fp_data;      /* pointer to file of histogram values */


  /* First, output a boxed title for the data */
  Title_Box(SARL_TITLE, SPECTRA_REC, fp_wr,
        atoi(fs->spectra[index].seq_no),
        atoi(fs->descript.n_spectra_recs),
        fs->spectra[index].sar_channel,
        sizeof(fs->spectra[index].sar_channel));


  /* Now, output the header info */
  Write_Header(fp_wr, &fs->spectra[index].hdr);

  /* Finally, output record specific data */

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->spectra[index].seq_no, sizeof(s.seq_no));
  sprintf(string, "%-45s%s\n", SEQ_NO, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->spectra[index].sar_channel, sizeof(s.sar_channel));
  sprintf(string, "%-45s%s\n", BAND_POL, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->spectra[index].data_set_size,
      sizeof(s.data_set_size));
  sprintf(string, "%-45s%s\n", DATA_ARRY_SZ, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->spectra[index].req_recs, sizeof(s.req_recs));
  sprintf(string, "%-45s%s\n", SP_REC_REQ, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->spectra[index].table_no, sizeof(s.table_no));
  sprintf(string, "%-45s%s\n", SP_TBL_NO, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->spectra[index].n_pixels, sizeof(s.n_pixels));
  sprintf(string, "%-45s%s\n", SP_SAMPS, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->spectra[index].pixel_offset, sizeof(s.pixel_offset));
  sprintf(string, "%-45s%s\n", SP_PIX_OFF, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->spectra[index].n_lines, sizeof(s.n_lines));
  sprintf(string, "%-45s%s\n", SP_INT_LINES, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->spectra[index].first_freq, sizeof(s.first_freq));
  justify(sstring, sizeof(s.first_freq), dest);
  sprintf(string, "%-45s%s\n", FIRST_FREQ, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->spectra[index].last_freq, sizeof(s.last_freq));
  justify(sstring, sizeof(s.last_freq), dest);
  sprintf(string, "%-45s%s\n", LAST_FREQ, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->spectra[index].min_power, sizeof(s.min_power));
  justify(sstring, sizeof(s.min_power), dest);
  sprintf(string, "%-45s%s\n", SP_MINP, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->spectra[index].max_power, sizeof(s.max_power));
  justify(sstring, sizeof(s.max_power), dest);
  sprintf(string, "%-45s%s\n", SP_MAXP, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->spectra[index].n_bins, sizeof(s.n_bins));
  sprintf(string, "%-45s%s\n\n", SP_N_BINS, sstring);
  fprintf(fp_wr, "%s", string);

  /* Get filename for storing data values */
  memset(string, 0, sizeof(string));
  strncpy(string, fs->spectra[index].sar_channel, 3);
  sprintf(sstring, "%spr%s_spectraplot_%s%s", diroutput, proc_run, string, ".txt");

  /* Create the data file named above */
  if ((fp_data = fopen(sstring, "w")) == NULL) {
    edit_error("Unable to create file : ", sstring);
  }
  
  /* Write name of plot file to output file */
  fprintf(fp_wr, "\n\nData values stored in file: %s\n", sstring);
  
    /* Write (x,y) values to file */
    for (i = 0; i < atoi(fs->spectra[index].n_bins); i++) {
      fprintf(fp_data, "%d\t%16.7f\n",i + 1,atof(fs->spectra[index].data_values[i]));
    }

    /* close the file containing histogram data */
    fclose(fp_data);

} /* Rd_Range_Spectra() */


/********************************************************************
*                                     
* Function:    Rd_Update                        
*                                     
* Abstract:    Read Radar Parameter Update Record            
*                                     
* Description:  This routine reads and prints the contents of the    
*        radar parameter update record.              
*                                     
* Inputs:    fs:      pointer to structure of input file      
*        fp_wr:    pointer to output file            
*        index:    index into array of update records      
*                                     
* Return Value:  void                           
*                                     
********************************************************************/

  void
Rd_Update(sarl_file_t *fs, FILE *fp_wr, int index)
{

  //hdr_t        hdr;  /* header structure */
  sarl_param_upd_t  s;    /* histogram structure */

  char  string[LONG_NAME_LEN];
  char  sstring[LONG_NAME_LEN];

  int   i;        /* loop counters */

  /* First, output a boxed title for the data */
  memset(string, 0, sizeof(string));

  if (atoi(fs->update[index].n_data_sets) != 0) {
    if (strncmp(upd_ptr[index]->descr,
          "DATA WINDOW POSITION", 5) == 0) {
      strcpy(string, RDR_DWP_STR);
    }
    if (strncmp(upd_ptr[index]->descr,
          "RECEIVER GAIN", 5) == 0) {
      strcpy(string, RDR_GAIN_STR);
    }
  } else {
    if (index == 0) {
      strcpy(string, RDR_DWP_STR);
    } else {
      strcpy(string, RDR_GAIN_STR);
    }
  }
  Title_Box(SARL_TITLE, UPDATE_REC, fp_wr,
        atoi(fs->update[index].seq_no),
        atoi(fs->descript.n_update_recs),
        string,
        sizeof(string));

  /* Now, output the header info */
  Write_Header(fp_wr, &fs->update[index].hdr);

  /* Finally, output record specific data */

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->update[index].seq_no, sizeof(s.seq_no));
  sprintf(string, "%-45s%s\n", SEQ_NO, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->update[index].n_data_sets, sizeof(s.n_data_sets));
  sprintf(string, "%-45s%s\n", N_SETS, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->update[index].data_set_size,
      sizeof(s.data_set_size));
  sprintf(string, "%-45s%s\n", SET_SIZE, sstring);
  fprintf(fp_wr, "%s", string);

  /* Loop through each data set */
  for (i = 0; i < atoi(fs->update[index].n_data_sets); i++) {

    sprintf(string, "\n\n%s %d %s\n\n", DATAS1, i+1, DATAS2);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, upd_ptr[index]->gmt,
        sizeof(upd_ptr[index]->gmt));
    sprintf(string, "%-45s%s\n", UPD_GMT, sstring);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, upd_ptr[index]->sar_channel,
        sizeof(upd_ptr[index]->sar_channel));
    sprintf(string, "%-45s%s\n", BAND_POL, sstring);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, upd_ptr[index]->line_no,
        sizeof(upd_ptr[index]->line_no));
    sprintf(string, "%-45s%s\n", UPD_LINE_NO, sstring);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, upd_ptr[index]->pixel_no,
        sizeof(upd_ptr[index]->pixel_no));
    sprintf(string, "%-45s%s\n", UPD_PIXEL, sstring);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, upd_ptr[index]->descr,
        sizeof(upd_ptr[index]->descr));
    sprintf(string, "%-45s%s\n", UPD_DESCR, sstring);
    fprintf(fp_wr, "%s", string);

    memset(sstring, 0, sizeof(sstring));
    strncpy(sstring, upd_ptr[index]->value,
        sizeof(upd_ptr[index]->value));
    if (strncmp(upd_ptr[index]->descr,
            "DATA WINDOW POSITION", 5) == 0) {
      justify(sstring, sizeof(upd_ptr[index]->value), dest);
      sprintf(string, "%-45s%s\n", DWP_VALUE, dest);
    }
    if (strncmp(upd_ptr[index]->descr, "RECEIVER GAIN", 5) == 0) {
      justify(sstring, sizeof(upd_ptr[index]->value), dest);
      sprintf(string, "%-45s%s\n", GAIN_VALUE, dest);
    }
    fprintf(fp_wr, "%s", string);

    /* Update pointer to point to next data set */
    upd_ptr[index]++;

  } /* for each data set */

} /* Rd_Update() */


/********************************************************************
*                                     
* Function:    Rd_Detailed_Proc                     
*                                     
* Abstract:    Read Detailed Processing Parameter Record        
*                                     
* Description:  This routine reads and prints the contents of the    
*        detailed processing parameter record.          
*                                     
* Inputs:    fs:      pointer to structure of input file      
*        fp_wr;    pointer to output file            
*                                     
* Return Value:  void                           
*                                     
********************************************************************/

  void
Rd_Detailed_Proc(sarl_file_t *fs, FILE *fp_wr)
{

  //hdr_t         hdr;  /* header structure */
  sarl_detailed_proc_t  s;  /* data quality structure */

  char  string[LONG_NAME_LEN];
  char  sstring[LONG_NAME_LEN];

  int   i;          /* loop counter */
  int   n_pairs;      /* counter of missing pairs per channel */

  /* First, output a boxed title for the data */
  Title_Box(SARL_TITLE, DETAILED_REC, fp_wr, 0, 0, NULL, 0);

  /* Now, output the header info */
  Write_Header(fp_wr, &fs->detailed.hdr);

  /* Finally, output record specific data */

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.seq_no, sizeof(s.seq_no));
  sprintf(string, "%-45s%s\n", SEQ_NO, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.n_flywheels, sizeof(s.n_flywheels));
  sprintf(string, "%-45s%s\n", FLYWHL, sstring);
  fprintf(fp_wr, "%s", string);


  fprintf(fp_wr, "%s\n", MISSING);

  /**** Channel 1 ****/
  i = 0;
  n_pairs = 0;
  fprintf(fp_wr, "%s\n", MISS_CH1);
  for (i = 0; i < MAX_MISSING_PAIRS * 2; i += 2) {
    if (atoi(fs->detailed.missing_1[i]) == 0 && 
      atoi(fs->detailed.missing_1[i+1]) == 0) {
      break;
    } else {
      n_pairs++;
      memset(string, 0, sizeof(string));
      memset(sstring, 0, sizeof(sstring));
      strncpy(string, fs->detailed.missing_1[i], sizeof(s.missing_1[i]));
      strncpy(sstring, fs->detailed.missing_1[i+1],
          sizeof(fs->detailed.missing_1[i+1]));
      fprintf(fp_wr, "%-18s%-23s%-15s\n", " ", string, sstring);
    } /* if - else */
  } /* for */
  if (n_pairs >= MAX_MISSING_PAIRS) {
    memset(sstring, 0, sizeof(sstring));
    sprintf(sstring, "%-45s%s\n", MORE_MISS, "YES");
  } else {
    memset(sstring, 0, sizeof(sstring));
    sprintf(sstring, "%-45s%s\n", MORE_MISS, "NO");
  }
  fprintf(fp_wr, "%s", sstring);
  
  /**** Channel 2 ****/
  i = 0;
  n_pairs = 0;
  fprintf(fp_wr, "%s\n", MISS_CH2);
  for (i = 0; i < MAX_MISSING_PAIRS * 2; i += 2) {
    if (atoi(fs->detailed.missing_2[i]) == 0 &&
      atoi(fs->detailed.missing_2[i+1]) == 0) {
      break;
    } else {
      n_pairs++;
      memset(string, 0, sizeof(string));
      memset(sstring, 0, sizeof(sstring));
      strncpy(string, fs->detailed.missing_2[i], sizeof(s.missing_2[i]));
      strncpy(sstring, fs->detailed.missing_2[i+1],
          sizeof(fs->detailed.missing_2[i+1]));
      fprintf(fp_wr, "%-18s%-23s%-15s\n", " ", string, sstring);
    } /* if - else */
  } /* for */
  if (n_pairs >= MAX_MISSING_PAIRS) {
    memset(sstring, 0, sizeof(sstring));
    sprintf(sstring, "%-45s%s\n", MORE_MISS, "YES");
  } else {
    memset(sstring, 0, sizeof(sstring));
    sprintf(sstring, "%-45s%s\n", MORE_MISS, "NO");
  }
  fprintf(fp_wr, "%s", sstring);
  

  /**** Channel 3 ****/
  i = 0;
  n_pairs = 0;
  fprintf(fp_wr, "%s\n", MISS_CH3);
  for (i = 0; i < MAX_MISSING_PAIRS * 2; i += 2) {
    if (atoi(fs->detailed.missing_3[i]) == 0 &&
      atoi(fs->detailed.missing_3[i+1]) == 0) {
      break;
    } else {
      n_pairs++;
      memset(string, 0, sizeof(string));
      memset(sstring, 0, sizeof(sstring));
      strncpy(string, fs->detailed.missing_3[i], sizeof(s.missing_3[i]));
      strncpy(sstring, fs->detailed.missing_3[i+1],
          sizeof(fs->detailed.missing_3[i+1]));
      fprintf(fp_wr, "%-18s%-23s%-15s\n", " ", string, sstring);
    } /* if - else */
  } /* for */
  if (n_pairs >= MAX_MISSING_PAIRS) {
    memset(sstring, 0, sizeof(sstring));
    sprintf(sstring, "%-45s%s\n", MORE_MISS, "YES");
  } else {
    memset(sstring, 0, sizeof(sstring));
    sprintf(sstring, "%-45s%s\n", MORE_MISS, "NO");
  }
  fprintf(fp_wr, "%s", sstring);
  
  /**** Channel 4 ****/
  i = 0;
  n_pairs = 0;
  fprintf(fp_wr, "%s\n", MISS_CH4);
  for (i = 0; i < MAX_MISSING_PAIRS * 2; i += 2) {
    if (atoi(fs->detailed.missing_4[i]) == 0 &&
      atoi(fs->detailed.missing_4[i+1]) == 0) {
      break;
    } else {
      n_pairs++;
      memset(string, 0, sizeof(string));
      memset(sstring, 0, sizeof(sstring));
      strncpy(string, fs->detailed.missing_4[i], sizeof(s.missing_4[i]));
      strncpy(sstring, fs->detailed.missing_4[i+1],
          sizeof(fs->detailed.missing_4[i+1]));
      fprintf(fp_wr, "%-18s%-23s%-15s\n", " ", string, sstring);
    } /* if - else */
  } /* for */
  if (n_pairs >= MAX_MISSING_PAIRS) {
    memset(sstring, 0, sizeof(sstring));
    sprintf(sstring, "%-45s%s\n", MORE_MISS, "YES");
  } else {
    memset(sstring, 0, sizeof(sstring));
    sprintf(sstring, "%-45s%s\n", MORE_MISS, "NO");
  }
  fprintf(fp_wr, "%s", sstring);
  
  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.ref_gain_hh, sizeof(s.ref_gain_hh));
  justify(sstring, sizeof(s.ref_gain_hh), dest);
  sprintf(string, "%-45s%s\n", REFCALHH, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.ref_gain_hv, sizeof(s.ref_gain_hv));
  justify(sstring, sizeof(s.ref_gain_hv), dest);
  sprintf(string, "%-45s%s\n", REFCALHV, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.ref_gain_vv, sizeof(s.ref_gain_vv));
  justify(sstring, sizeof(s.ref_gain_vv), dest);
  sprintf(string, "%-45s%s\n", REFCALVV, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.ref_gain_vh, sizeof(s.ref_gain_vh));
  justify(sstring, sizeof(s.ref_gain_vh), dest);
  sprintf(string, "%-45s%s\n", REFCALVH, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.mean_gain_hh, sizeof(s.mean_gain_hh));
  justify(sstring, sizeof(s.mean_gain_hh), dest);
  sprintf(string, "%-45s%s\n", MEANCALHH, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.mean_gain_hv, sizeof(s.mean_gain_hv));
  justify(sstring, sizeof(s.mean_gain_hv), dest);
  sprintf(string, "%-45s%s\n", MEANCALHV, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.mean_gain_vv, sizeof(s.mean_gain_vv));
  justify(sstring, sizeof(s.mean_gain_vv), dest);
  sprintf(string, "%-45s%s\n", MEANCALVV, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.mean_gain_vh, sizeof(s.mean_gain_vh));
  justify(sstring, sizeof(s.mean_gain_vh), dest);
  sprintf(string, "%-45s%s\n", MEANCALVH, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.dev_gain_hh, sizeof(s.dev_gain_hh));
  justify(sstring, sizeof(s.dev_gain_hh), dest);
  sprintf(string, "%-45s%s\n", DEVCALHH, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.dev_gain_hv, sizeof(s.dev_gain_hv));
  justify(sstring, sizeof(s.dev_gain_hv), dest);
  sprintf(string, "%-45s%s\n", DEVCALHV, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.dev_gain_vv, sizeof(s.dev_gain_vv));
  justify(sstring, sizeof(s.dev_gain_vv), dest);
  sprintf(string, "%-45s%s\n", DEVCALVV, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.dev_gain_vh, sizeof(s.dev_gain_vh));
  justify(sstring, sizeof(s.dev_gain_vh), dest);
  sprintf(string, "%-45s%s\n", DEVCALVH, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.over_sat_hh, sizeof(s.over_sat_hh));
  justify(sstring, sizeof(s.over_sat_hh), dest);
  sprintf(string, "%-45s%s\n", OVERSAT_HH, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.over_sat_hv, sizeof(s.over_sat_hv));
  justify(sstring, sizeof(s.over_sat_hv), dest);
  sprintf(string, "%-45s%s\n", OVERSAT_HV, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.over_sat_vv, sizeof(s.over_sat_vv));
  justify(sstring, sizeof(s.over_sat_vv), dest);
  sprintf(string, "%-45s%s\n", OVERSAT_VV, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.over_sat_vh, sizeof(s.over_sat_vh));
  justify(sstring, sizeof(s.over_sat_vh), dest);
  sprintf(string, "%-45s%s\n", OVERSAT_VH, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.under_sat_hh, sizeof(s.under_sat_hh));
  justify(sstring, sizeof(s.under_sat_hh), dest);
  sprintf(string, "%-45s%s\n", UNDERSAT_HH, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.under_sat_hv, sizeof(s.under_sat_hv));
  justify(sstring, sizeof(s.under_sat_hv), dest);
  sprintf(string, "%-45s%s\n", UNDERSAT_HV, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.under_sat_vv, sizeof(s.under_sat_vv));
  justify(sstring, sizeof(s.under_sat_vv), dest);
  sprintf(string, "%-45s%s\n", UNDERSAT_VV, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.under_sat_vh, sizeof(s.under_sat_vh));
  justify(sstring, sizeof(s.under_sat_vh), dest);
  sprintf(string, "%-45s%s\n", UNDERSAT_VH, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.proc_run, sizeof(s.proc_run));
  sprintf(string, "%-45s%s\n", PROC_RUN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.mission_id, sizeof(s.mission_id));
  sprintf(string, "%-45s%s\n", MISSION_ID, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.beam_spoil, sizeof(s.beam_spoil));
  sprintf(string, "%-45s%s\n", BEAM_SPOIL, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.start_gmt, sizeof(s.start_gmt));
  sprintf(string, "%-45s%s\n", START_GMT, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.start_gmt_sec, sizeof(s.start_gmt_sec));
  justify(sstring, sizeof(s.image_duration), dest);
  sprintf(string, "%-45s%s\n", ST_GMT_SEC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.image_duration, sizeof(s.image_duration));
  justify(sstring, sizeof(s.image_duration), dest);
  sprintf(string, "%-45s%s\n", IMAGE_DUR, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.near_slant, sizeof(s.near_slant));
  justify(sstring, sizeof(s.near_slant), dest);
  sprintf(string, "%-45s%s\n", NEAR_SLANT, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.ctr_radius, sizeof(s.ctr_radius));
  justify(sstring, sizeof(s.ctr_radius), dest);
  sprintf(string, "%-45s%s\n", CTR_RADIUS, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.nadir_radius, sizeof(s.nadir_radius));
  justify(sstring, sizeof(s.nadir_radius), dest);
  sprintf(string, "%-45s%s\n", NADIR_RADIUS, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.gmt_0met_year, sizeof(s.gmt_0met_year));
  sprintf(string, "%-45s%s\n", YEAR_0MET, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.gmt_0met_days, sizeof(s.gmt_0met_days));
  sprintf(string, "%-45s%s\n", DAY_0MET, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.gmt_0met_hours, sizeof(s.gmt_0met_hours));
  sprintf(string, "%-45s%s\n", HOUR_0MET, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.gmt_0met_minutes,
      sizeof(s.gmt_0met_minutes));
  sprintf(string, "%-45s%s\n", MIN_OMET, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.gmt_0met_sec, sizeof(s.gmt_0met_sec));
  justify(sstring, sizeof(s.gmt_0met_sec), dest);
  sprintf(string, "%-45s%s\n", SEC_0MET, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.met_drift, sizeof(s.met_drift));
  justify(sstring, sizeof(s.met_drift), dest);
  sprintf(string, "%-45s%s\n", DRIFT, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.fd0_const, sizeof(s.fd0_const));
  justify(sstring, sizeof(s.fd0_const), dest);
  sprintf(string, "%-45s%s\n", FD0_CONST, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.fd0_linear, sizeof(s.fd0_linear));
  justify(sstring, sizeof(s.fd0_linear), dest);
  sprintf(string, "%-45s%s\n", FD0_LIN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.fd0_quad, sizeof(s.fd0_quad));
  justify(sstring, sizeof(s.fd0_quad), dest);
  sprintf(string, "%-45s%s\n", FD0_QUAD, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.fd1_const, sizeof(s.fd1_const));
  justify(sstring, sizeof(s.fd1_const), dest);
  sprintf(string, "%-45s%s\n", FD1_CONST, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.fd1_linear, sizeof(s.fd1_linear));
  justify(sstring, sizeof(s.fd1_linear), dest);
  sprintf(string, "%-45s%s\n", FD1_LIN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.fd1_quad, sizeof(s.fd1_quad));
  justify(sstring, sizeof(s.fd1_quad), dest);
  sprintf(string, "%-45s%s\n", FD1_QUAD, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.fd2_const, sizeof(s.fd2_const));
  justify(sstring, sizeof(s.fd2_const), dest);
  sprintf(string, "%-45s%s\n", FD2_CONST, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.fd2_linear, sizeof(s.fd2_linear));
  justify(sstring, sizeof(s.fd2_linear), dest);
  sprintf(string, "%-45s%s\n", FD2_LIN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.fd2_quad, sizeof(s.fd2_quad));
  justify(sstring, sizeof(s.fd2_quad), dest);
  sprintf(string, "%-45s%s\n", FD2_QUAD, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.fr0_const, sizeof(s.fr0_const));
  justify(sstring, sizeof(s.fr0_const), dest);
  sprintf(string, "%-45s%s\n", FR0_CONST, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.fr0_linear, sizeof(s.fr0_linear));
  justify(sstring, sizeof(s.fr0_linear), dest);
  sprintf(string, "%-45s%s\n", FR0_LIN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.fr0_quad, sizeof(s.fr0_quad));
  justify(sstring, sizeof(s.fr0_quad), dest);
  sprintf(string, "%-45s%s\n", FR0_QUAD, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.fr1_const, sizeof(s.fr1_const));
  justify(sstring, sizeof(s.fr1_const), dest);
  sprintf(string, "%-45s%s\n", FR1_CONST, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.fr1_linear, sizeof(s.fr1_linear));
  justify(sstring, sizeof(s.fr1_linear), dest);
  sprintf(string, "%-45s%s\n", FR1_LIN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.fr1_quad, sizeof(s.fr1_quad));
  justify(sstring, sizeof(s.fr1_quad), dest);
  sprintf(string, "%-45s%s\n", FR1_QUAD, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.fr2_const, sizeof(s.fr2_const));
  justify(sstring, sizeof(s.fr2_const), dest);
  sprintf(string, "%-45s%s\n", FR2_CONST, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.fr2_linear, sizeof(s.fr2_linear));
  justify(sstring, sizeof(s.fr2_linear), dest);
  sprintf(string, "%-45s%s\n", FR2_LIN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.fr2_quad, sizeof(s.fr2_quad));
  justify(sstring, sizeof(s.fr2_quad), dest);
  sprintf(string, "%-45s%s\n", FR2_QUAD, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.processing_date, sizeof(s.processing_date));
  sprintf(string, "%-45s%s\n", PROC_DATE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.roll_ang_est_avg, 
      sizeof(s.roll_ang_est_avg));
  justify(sstring, sizeof(s.roll_ang_est_avg), dest);
  sprintf(string, "%-45s%s\n", RAEST, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.nr_rg_inc_angle, sizeof(s.nr_rg_inc_angle));
  justify(sstring, sizeof(s.nr_rg_inc_angle), dest);
  sprintf(string, "%-45s%s\n", NEAR_INC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.far_rg_inc_angle, 
      sizeof(s.far_rg_inc_angle));
  justify(sstring, sizeof(s.far_rg_inc_angle), dest);
  sprintf(string, "%-45s%s\n", FAR_INC, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.az_ref_length, sizeof(s.az_ref_length));
  sprintf(string, "%-45s%s\n", AZ_REF_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.signal_gain, sizeof(s.signal_gain));
  justify(sstring, sizeof(s.signal_gain), dest);
  sprintf(string, "%-45s%s\n", SIG_GAIN, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.hh_caltone_phase, 
      sizeof(s.hh_caltone_phase));
  justify(sstring, sizeof(s.hh_caltone_phase), dest);
  sprintf(string, "%-45s%s\n", HH_PHASE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.hv_caltone_phase, 
      sizeof(s.hv_caltone_phase));
  justify(sstring, sizeof(s.hv_caltone_phase), dest);
  sprintf(string, "%-45s%s\n", HV_PHASE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.vv_caltone_phase, 
      sizeof(s.vv_caltone_phase));
  justify(sstring, sizeof(s.vv_caltone_phase), dest);
  sprintf(string, "%-45s%s\n", VV_PHASE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.vh_caltone_phase,
      sizeof(s.vh_caltone_phase));
  justify(sstring, sizeof(s.vh_caltone_phase), dest);
  sprintf(string, "%-45s%s\n", VH_PHASE, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.polarization, sizeof(s.polarization));
  sprintf(string, "%-45s%s\n", POLINDX, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.sample_offset, sizeof(s.sample_offset));
  sprintf(string, "%-45s%s\n", SAMP_OFF, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->detailed.range_str_angle,
      sizeof(s.range_str_angle));
  justify(sstring, sizeof(s.range_str_angle), dest);
  sprintf(string, "%-45s%s\n", STEER_ANGLE, dest);
  fprintf(fp_wr, "%s", string);

} /* Rd_Detailed_Proc() */


/********************************************************************
*                                     
* Function:    Rd_Calibration                      
*                                     
* Abstract:    Read Calibration Data Record               
*                                     
* Description:  This routine reads and prints the contents of the    
*        calibration data record.                 
*                                     
* Inputs:    fs:      pointer to structure of input file      
*        fp_wr;    pointer to output file            
*                                     
* Return Value:  void                           
*                                     
********************************************************************/

  void
Rd_Calibration(sarl_file_t *fs, FILE *fp_wr)
{

  //hdr_t      hdr;     /* header structure */
  sarl_calibr_t  s;      /* data quality structure */

  char  string[LONG_NAME_LEN];
  char  sstring[LONG_NAME_LEN];

  int   i, j;        /* loop counters */

  /* First, output a boxed title for the data */
  Title_Box(SARL_TITLE, CALIB_REC, fp_wr, 0, 0, NULL, 0);

  /* Now, output the header info */
  Write_Header(fp_wr, &fs->calibration.hdr);


  /* Finally, output record specific data */

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->calibration.seq_no, sizeof(s.seq_no));
  sprintf(string, "%-45s%s\n", SEQ_NO, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->calibration.cal_coef, sizeof(s.cal_coef));
  justify(sstring, sizeof(s.cal_coef), dest);
  sprintf(string, "%-45s%s\n", CAL_COEF, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->calibration.chan_imbalance, sizeof(s.chan_imbalance));
  justify(sstring, sizeof(s.chan_imbalance), dest);
  sprintf(string, "%-45s%s\n", CHAN_IMB, dest);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->calibration.phase_imbalance,
      sizeof(s.phase_imbalance));
  justify(sstring, sizeof(s.phase_imbalance), dest);
  sprintf(string, "%-45s%s\n", PHASE_IMB, dest);
  fprintf(fp_wr, "%s", string);



  /* Output the 4 x 4 calibration matrix */
  memset(sstring, 0, sizeof(sstring));
  fprintf(fp_wr, "%s\n\n%s\n%s\n%s\n%s\n\n",
      MATRIX_TITLE,
      CAL_MAP1,
      CAL_MAP2,
      CAL_MAP3,
      CAL_MAP4);
  
  /* Print out each element of the 4 x 4 complex matrix */
  for (i = 0, j = 0; i < POL_MATRIX_SIZE / 2; i++, j += 2) {
    memset(string, 0, sizeof(string));
    memset(sstring, 0, sizeof(sstring));
    strncpy(string, fs->calibration.matrix[j],
        sizeof(fs->calibration.matrix[j]));
    strncpy(sstring,  fs->calibration.matrix[j + 1],
        sizeof(fs->calibration.matrix[j + 1]));
    fprintf(fp_wr, "[%2d]:  %22s + %si\n",
        i + 1, string, sstring);
  }


} /* Rd_Calibration() */


/********************************************************************
*                                     
* Function:    Rd_IMG_Descript                      
*                                     
* Abstract:    Read File Descriptor Record                
*                                     
* Description:  This routine reads and prints the contents of the    
*        Imagery Options file descriptor record.          
*                                     
* Inputs:    fs;      pointer to file structure          
*        fp_wr;    pointer to output file            
*                                     
* Return Value:  void                           
*                                     
********************************************************************/

  void
Rd_IMG_Descript(imgopt_file_t *fs, FILE *fp_wr)
{

  //hdr_t          hdr; /* header structure */
  img_descript_t      s;  /* file descriptor structure */

  char  string[LONG_NAME_LEN];
  char  sstring[LONG_NAME_LEN];

  /* First, output a boxed title for the data */
  Title_Box(IMG_TITLE, DESCR_REC, fp_wr, 0, 0, NULL, 0);

  /* Now, output the header info */
  Write_Header(fp_wr, &fs->descript.hdr);

  /* Finally, output record specific data */

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.ascii_flag, sizeof(s.ascii_flag));
  sprintf(string, "%-45s%s\n", ASCII_FL, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.doc_format, sizeof(s.doc_format));
  sprintf(string, "%-45s%s\n", DOC_FORM, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.format_rev, sizeof(s.format_rev));
  sprintf(string, "%-45s%s\n", FORM_REV, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.rec_format_rev, sizeof(s.rec_format_rev));
  sprintf(string, "%-45s%s\n", REC_REV, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.software_id, sizeof(s.software_id));
  sprintf(string, "%-45s%s\n", SW_VERS, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.file_no, sizeof(s.file_no));
  sprintf(string, "%-45s%s\n", FILE_NO, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.filename, sizeof(s.filename));
  sprintf(string, "%-45s%s\n", FILE_NAME, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.seq_flag, sizeof(s.seq_flag));
  sprintf(string, "%-45s%s\n", FSEQ, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.seq_location, sizeof(s.seq_location));
  sprintf(string, "%-45s%s\n", LOC_NO, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.seq_field_len, sizeof(s.seq_field_len));
  sprintf(string, "%-45s%s\n", SEQ_FLD_L, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.code_flag, sizeof(s.code_flag));
  sprintf(string, "%-45s%s\n", LOC_TYPE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.code_location, sizeof(s.code_location));
  sprintf(string, "%-45s%s\n", RCODE_LOC, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.code_field_len,
      sizeof(s.code_field_len));
  sprintf(string, "%-45s%s\n", RCODE_FLD_L, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_flag, sizeof(s.len_flag));
  sprintf(string, "%-45s%s\n", FLGT, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_location, sizeof(s.len_location));
  sprintf(string, "%-45s%s\n", REC_LEN_LOC, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.len_field_len, sizeof(s.len_field_len));
  sprintf(string, "%-45s%s\n", REC_LEN_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.header_size, sizeof(s.header_size));
  sprintf(string, "%-45s%s\n", RSD_HDR_SIZE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_sar_recs, sizeof(s.n_sar_recs));
  sprintf(string, "%-45s%s\n", N_SAR_RECS, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.sar_rec_len, sizeof(s.sar_rec_len));
  sprintf(string, "%-45s%s\n", SAR_REC_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.polarizations, sizeof(s.polarizations));
  sprintf(string, "%-45s%s\n", POLAR_STR, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.bits_sample, sizeof(s.bits_sample));
  sprintf(string, "%-45s%s\n", BITS_SPAMP, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.pixels_group, sizeof(s.pixels_group));
  sprintf(string, "%-45s%s\n", PIX_GP, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.bytes_group, sizeof(s.bytes_group));
  sprintf(string, "%-45s%s\n", BYTES_GP, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.sar_channels, sizeof(s.sar_channels));
  sprintf(string, "%-45s%s\n", N_SAR_CHAN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_lines, sizeof(s.n_lines));
  sprintf(string, "%-45s%s\n", N_LINES_IMG, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.left_pixels, sizeof(s.left_pixels));
  sprintf(string, "%-45s%s\n", LEFT_BD_PIX, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_pixels, sizeof(s.n_pixels));
  sprintf(string, "%-45s%s\n", N_PIX_LINE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.right_pixels, sizeof(s.right_pixels));
  sprintf(string, "%-45s%s\n", RIGHT_BD_PIX, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.top_lines, sizeof(s.top_lines));
  sprintf(string, "%-45s%s\n", TOP_LINES, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.bottom_lines, sizeof(s.bottom_lines));
  sprintf(string, "%-45s%s\n", BOTTOM_LINES, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.interleave, sizeof(s.interleave));
  sprintf(string, "%-45s%s\n", INTERLEAVE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.recs_line, sizeof(s.recs_line));
  sprintf(string, "%-45s%s\n", RECS_LINE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.recs_channel, sizeof(s.recs_channel));
  sprintf(string, "%-45s%s\n", RECS_CHAN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.prefix_len, sizeof(s.prefix_len));
  sprintf(string, "%-45s%s\n", LINE_PREFIX, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.bytes_line, sizeof(s.bytes_line));
  sprintf(string, "%-45s%s\n", BYTES_LINE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.suffix_len, sizeof(s.suffix_len));
  sprintf(string, "%-45s%s\n", LINE_SUFFIX, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.sar_format, sizeof(s.sar_format));
  sprintf(string, "%-45s%s\n", SAR_FORMAT, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_left_fill, sizeof(s.n_left_fill));
  sprintf(string, "%-45s%s\n", LT_PIX_FILL, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, fs->descript.n_right_fill, sizeof(s.n_right_fill));
  sprintf(string, "%-45s%s\n", RT_PIX_FILL, sstring);
  fprintf(fp_wr, "%s", string);

} /* Rd_IMG_Descript() */


/********************************************************************
*                                     
* Function:    Rd_SART_Descript                     
*                                     
* Abstract:    Read File Descriptor Record                
*                                     
* Description:  This routine reads and prints the contents of the    
*        SAR Trailer file descriptor record.            
*                                     
* Inputs:    rp;      pointer to record structure         
*        fp_wr;    pointer to output file            
*                                     
* Return Value:  void                           
*                                     
********************************************************************/

  void
Rd_SART_Descript(sart_descript_t *rp, FILE *fp_wr)
{

  //hdr_t          hdr; /* header structure */

  char  string[LONG_NAME_LEN];
  char  sstring[LONG_NAME_LEN];

  /* First, output a boxed title for the data */
  Title_Box(SART_TITLE, DESCR_REC, fp_wr, 0, 0, NULL, 0);

  /* Now, output the header info */
  Write_Header(fp_wr, &rp->hdr);

  /* Finally, output record specific data */

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->ascii_flag, sizeof(rp->ascii_flag));
  sprintf(string, "%-45s%s\n", ASCII_FL, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->doc_format, sizeof(rp->doc_format));
  sprintf(string, "%-45s%s\n", DOC_FORM, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->format_rev, sizeof(rp->format_rev));
  sprintf(string, "%-45s%s\n", FORM_REV, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->rec_format_rev, sizeof(rp->rec_format_rev));
  sprintf(string, "%-45s%s\n", REC_REV, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->software_id, sizeof(rp->software_id));
  sprintf(string, "%-45s%s\n", SW_VERS, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->file_no, sizeof(rp->file_no));
  sprintf(string, "%-45s%s\n", FILE_NO, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->filename, sizeof(rp->filename));
  sprintf(string, "%-45s%s\n", FILE_NAME, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->seq_flag, sizeof(rp->seq_flag));
  sprintf(string, "%-45s%s\n", FSEQ, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->seq_location, sizeof(rp->seq_location));
  sprintf(string, "%-45s%s\n", LOC_NO, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->seq_field_len, sizeof(rp->seq_field_len));
  sprintf(string, "%-45s%s\n", SEQ_FLD_L, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->code_flag, sizeof(rp->code_flag));
  sprintf(string, "%-45s%s\n", LOC_TYPE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->code_location, sizeof(rp->code_location));
  sprintf(string, "%-45s%s\n", RCODE_LOC, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->code_field_len,
      sizeof(rp->code_field_len));
  sprintf(string, "%-45s%s\n", RCODE_FLD_L, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_flag, sizeof(rp->len_flag));
  sprintf(string, "%-45s%s\n", FLGT, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_location, sizeof(rp->len_location));
  sprintf(string, "%-45s%s\n", REC_LEN_LOC, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_field_len, sizeof(rp->len_field_len));
  sprintf(string, "%-45s%s\n", REC_LEN_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_data_set_recs,
      sizeof(rp->n_data_set_recs));
  sprintf(string, "%-45s%s\n", DS_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_data_set, sizeof(rp->len_data_set));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_map_proj_recs, sizeof(rp->n_map_proj_recs));
  sprintf(string, "%-45s%s\n", MP_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_map_proj, sizeof(rp->len_map_proj));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_platf_recs, sizeof(rp->n_platf_recs));
  sprintf(string, "%-45s%s\n", PLATF_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_platf, sizeof(rp->len_platf));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_att_recs, sizeof(rp->n_att_recs));
  sprintf(string, "%-45s%s\n", ATT_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_att, sizeof(rp->len_att));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_radio_recs, sizeof(rp->n_radio_recs));
  sprintf(string, "%-45s%s\n", RADIO_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_radio, sizeof(rp->len_radio));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_radio_comp_recs,
      sizeof(rp->n_radio_comp_recs));
  sprintf(string, "%-45s%s\n", RADIOC_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_radio_comp, sizeof(rp->len_radio_comp));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_qual_recs, sizeof(rp->n_qual_recs));
  sprintf(string, "%-45s%s\n", QUAL_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_qual, sizeof(rp->len_qual));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_hist_recs, sizeof(rp->n_hist_recs));
  sprintf(string, "%-45s%s\n", HIST_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_hist, sizeof(rp->len_hist));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_spectra_recs, sizeof(rp->n_spectra_recs));
  sprintf(string, "%-45s%s\n", SPEC_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_spectra, sizeof(rp->len_spectra));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_elev_recs, sizeof(rp->n_elev_recs));
  sprintf(string, "%-45s%s\n", ELEV_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_elev, sizeof(rp->len_elev));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_update_recs, sizeof(rp->n_update_recs));
  sprintf(string, "%-45s%s\n", UPD_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_update, sizeof(rp->len_update));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_annot_recs, sizeof(rp->n_annot_recs));
  sprintf(string, "%-45s%s\n", ANNOT_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_annot, sizeof(rp->len_annot));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_proc_recs, sizeof(rp->n_proc_recs));
  sprintf(string, "%-45s%s\n", PROC_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_proc, sizeof(rp->len_proc));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_calib_recs, sizeof(rp->n_calib_recs));
  sprintf(string, "%-45s%s\n", CAL_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_calib, sizeof(rp->len_calib));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_ground, sizeof(rp->n_ground));
  sprintf(string, "%-45s%s\n", GROUND_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_ground, sizeof(rp->len_ground));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->n_facil_recs, sizeof(rp->n_facil_recs));
  sprintf(string, "%-45s%s\n", FAC_FILE, sstring);
  fprintf(fp_wr, "%s", string);

  memset(sstring, 0, sizeof(sstring));
  strncpy(sstring, rp->len_facil, sizeof(rp->len_facil));
  sprintf(string, "%-45s%s\n", RECORD_LEN, sstring);
  fprintf(fp_wr, "%s", string);

} /* Rd_SART_Descript() */

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

  void
justify(char *src, int length, char *destination)
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
* Function:    MatchSoftwareId
*
* Abstract:    Match software id between reader and writer
*
* Description:  This routine keeps track of the differences between software
*        versions
*
* Include Files: "ceos_reader.h"
*
* Inputs:    filenum:  0-vdf; 1-ldr; 2-img; 3-tlr; 4-nvd
*    Id:    Software id from the data file
*
* Outputs:    Messages
*
* Calls:    None
*
* Called by:  ceos_rd
*
* Return Value:  void
*
********************************************************************/
 
void
MatchSoftwareId ( filenum, Id )

int filenum;
char *Id;
{
    switch ( filenum ) {
    case 0:
        break;
    case 1:  
    if ( !strncmp( SW_VERSION, Id, 3 ) ) break;
    if ( !strncmp( Id, "1.0", 3 ) ){

      printf( "\n\n!!!!!!!!!! ** WARNING ** !!!!!!!!!!\n");
      printf( "You may not be able to decode ceos leader file ");
      printf( "due to format changes\n");
      printf( "Please use ceos_reader software version 1.0\n\n\n" );

    } else if ( !strncmp( Id, "1.1", 3 ) ){

          printf( "\n\nWARNING:\n");
          printf( "You may not be able to decode ceos leader file.\n");
          printf( "Please use ceos_reader software version 1.1\n\n\n" );

    }
        break;
    case 2:
        break;
    case 3:
        break;
    case 4:
        break;
    default:
        break;
    }

} /* End of MatchSoftwareId */

/********************************************************************
*                                     
* Function:    PolSARproConfigFile                    
*                                     
* Abstract:    Read CEOS formatted Imagery Options File         
*                                     
* Description:  This routine reads each record in the CEOS Imagery Options
*        File and outputs the data in each to a Config file.    
*                                     
*        Record in this file:                   
*                                     
*            File Descriptor Record              
*            Image (Signal) Data Record (one per image line)  
*                                     
* Inputs:    filename:  name of Imagery Options file to read from  
*                                     
* Outputs:    filename_"ascii"  ascii readable file          
*                                     
* Return Value:  none                           
*                                     
********************************************************************/

  void
PolSARproConfigFile(char *filename, char *fileconfig)
{


  FILE  *fp_rd;       /* pointer to imagery options file */
  FILE  *fp_wr;       /* pointer to ascii file to be created */

  int   nread;        /* number of elements read from disk */

  /* open the Imagery Options file for reading */
  if ((fp_rd = fopen(filename, "rb")) == NULL) {
    edit_error("Unable to open Imagery Options File :", imgopt_in);
  }

  /* read Imagery Options file in from disk */

  /*
   * read in file descriptor record.
   *
   * NOTE: The blanks padding the end of this record are not read in.
   *    They are not needed.
   */
  if ((nread = fread(&opt.descript, sizeof(opt.descript), 1, fp_rd)) < 1) {
    edit_error("Unable to read Imagery Options File : ", imgopt_in);
  }

  /* open/create an output Config File */
  if ((fp_wr = fopen(fileconfig, "w+")) == NULL) {
    edit_error("Unable to create output file : ", fileconfig);
  }

  /* --- Read File Descriptor Record */
  PolSARproCreateConfigFile(&opt, fp_wr);

  /* Close the files */
  if (fclose(fp_wr) != 0) {
    edit_error("Error closing file : ", imgopt_ascii);
  }

  /* Close the file */
  if (fclose(fp_rd) != 0) {
    edit_error("Error closing file : ", imgopt_in);
  }

} /* PolSARproConfigFile() */

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

  void
PolSARproCreateConfigFile(imgopt_file_t *fs, FILE *fp_wr)
{
  int  iline, ireclen, ibytes, isamp;
  int itype, imode;
  img_descript_t s;
  char str1[3], str2[3], str3[3], str4[3];
  char strchannel[100], strformat[100];
  char tmp[100];

  iline = atoi(fs->descript.n_sar_recs);
  ireclen = atoi(fs->descript.sar_rec_len);
  ibytes = atoi(fs->descript.bytes_group);
  isamp = atoi(fs->descript.n_pixels);

  strcpy(strchannel,"");
  strncat(strchannel, fs->descript.polarizations, sizeof(s.polarizations));
  strcpy(str1,"");strncat(str1, &strchannel[0], 2);
  strcpy(str2,"");strncat(str2, &strchannel[3], 2);
  strcpy(str3,"");strncat(str3, &strchannel[6], 2);
    strcpy(str4,"");strncat(str4, &strchannel[9], 2);

  strcpy(strformat,"");
  strncat(strformat, fs->descript.sar_format, sizeof(s.sar_format));

  itype = 0;
/* MLC data type */
  strcpy(tmp,"");strncat(tmp, &strformat[11], 5);
  if (strcmp(tmp,"CROSS")==0) {
    if ( ibytes == 10) itype = 2;
    if ( ibytes == 5)  itype = 3;
  }
/* SLC data type */
  strcpy(tmp,"");strncat(tmp, &strformat[11], 5);
  if (strcmp(tmp,"SCATT")==0) {
    if ( ibytes == 10) itype = 4;
    if ( ibytes == 4)  itype = 5;
    if ( ibytes == 6)  itype = 6;
  }
/* MLD data type */
  strcpy(tmp,"");strncat(tmp, &strformat[11], 3);
  if (strcmp(tmp,"TED")==0) itype = 1;
      
 
/* POLARIZATION MODE */

  imode = 10;

/* MLD single pol */
  if (itype == 1) {
    imode = 6;
    if (strcmp(str1,"HH") == 0) imode = 4;
    if (strcmp(str1,"VV") == 0) imode = 5;
  }

/* MLC quad pol */
  if (itype == 2) imode = 0;

/* MLC dual pol */
  if (itype == 3) {
    imode = 9;
    if ((strcmp(str1,"HH") == 0)&&(strcmp(str2,"VV") == 0)) imode = 1;
    if ((strcmp(str1,"VV") == 0)&&(strcmp(str2,"HH") == 0)) imode = 1;
    if ((strcmp(str1,"HH") == 0)&&(strcmp(str2,"HV") == 0)) imode = 2;
    if ((strcmp(str1,"HV") == 0)&&(strcmp(str2,"HH") == 0)) imode = 2;
    if ((strcmp(str1,"VH") == 0)&&(strcmp(str2,"VV") == 0)) imode = 3;
    if ((strcmp(str1,"VV") == 0)&&(strcmp(str2,"VH") == 0)) imode = 3;
    if ((strcmp(str1,"HV") == 0)&&(strcmp(str2,"VV") == 0)) imode = 7;
    if ((strcmp(str1,"VV") == 0)&&(strcmp(str2,"HV") == 0)) imode = 7;
    if ((strcmp(str1,"HH") == 0)&&(strcmp(str2,"VH") == 0)) imode = 8;
    if ((strcmp(str1,"VH") == 0)&&(strcmp(str2,"HH") == 0)) imode = 8;
  }

/* SLC quad pol */
  if (itype == 4) imode = 0;

/* SLC single pol */
  if (itype == 5) {
    imode = 6;
    if (strcmp(str1,"HH") == 0) imode = 4;
    if (strcmp(str1,"VV") == 0) imode = 5;
  }

/* SLC dual pol */
  if (itype == 6) {
    imode = 9;
    if ((strcmp(str1,"HH") == 0)&&(strcmp(str2,"VV") == 0)) imode = 1;
    if ((strcmp(str1,"VV") == 0)&&(strcmp(str2,"HH") == 0)) imode = 1;
    if ((strcmp(str1,"HH") == 0)&&(strcmp(str2,"HV") == 0)) imode = 2;
    if ((strcmp(str1,"HV") == 0)&&(strcmp(str2,"HH") == 0)) imode = 2;
    if ((strcmp(str1,"VH") == 0)&&(strcmp(str2,"VV") == 0)) imode = 3;
    if ((strcmp(str1,"VV") == 0)&&(strcmp(str2,"VH") == 0)) imode = 3;
    if ((strcmp(str1,"HV") == 0)&&(strcmp(str2,"VV") == 0)) imode = 7;
    if ((strcmp(str1,"VV") == 0)&&(strcmp(str2,"HV") == 0)) imode = 7;
    if ((strcmp(str1,"HH") == 0)&&(strcmp(str2,"VH") == 0)) imode = 8;
    if ((strcmp(str1,"VH") == 0)&&(strcmp(str2,"HH") == 0)) imode = 8;
  }


  fprintf(fp_wr, "nlig\n");
  fprintf(fp_wr, "%i\n", iline);
  fprintf(fp_wr, "---------\n");
  fprintf(fp_wr, "ncol\n");
  fprintf(fp_wr, "%i\n", isamp);
  fprintf(fp_wr, "---------\n");
  fprintf(fp_wr, "file_type\n");
  fprintf(fp_wr, "%i\n", itype);
  fprintf(fp_wr, "---------\n");
  fprintf(fp_wr, "file_mode\n");
  fprintf(fp_wr, "%i\n", imode);
  fprintf(fp_wr, "---------\n");
  fprintf(fp_wr, "bytes_per_pixel\n");
  fprintf(fp_wr, "%i\n", ibytes);
  fprintf(fp_wr, "---------\n");
  fprintf(fp_wr, "record_length\n");
  fprintf(fp_wr, "%i\n", ireclen);
  fprintf(fp_wr, "---------\n");
  fprintf(fp_wr, "channel\n");
  fprintf(fp_wr, "%s\n", strchannel);
  fprintf(fp_wr, "---------\n");
  fprintf(fp_wr, "format\n");
  fprintf(fp_wr, "%s\n", strformat);

  if (itype == 0) strcpy(tmp,"File Type Error");
  if (itype == 1) strcpy(tmp,"2 byte multilook detected (MLD)");
  if (itype == 2) strcpy(tmp,"10 byte multilook quad pol complex (MLC)");
  if (itype == 3) strcpy(tmp,"5 byte multilook dual pol complex (MLC)");
  if (itype == 4) strcpy(tmp,"10 byte singlelook quad pol complex (SLC)");
  if (itype == 5) strcpy(tmp,"4 byte singlelook single pol complex (SLC)");
  if (itype == 6) strcpy(tmp,"6 byte singlelook dual pol complex (SLC)");
  fprintf(fp_wr, "---------\n");
  fprintf(fp_wr, "file_type\n");
  fprintf(fp_wr, "%s\n", tmp);

  if (imode == 0) strcpy(tmp,"Quad Pol");
  if (imode == 1) strcpy(tmp,"Dual Pol : HH VV");
  if (imode == 2) strcpy(tmp,"Dual Pol : HH HV");
  if (imode == 3) strcpy(tmp,"Dual Pol : VH VV");
  if (imode == 4) strcpy(tmp,"Sngl Pol : HH");
  if (imode == 5) strcpy(tmp,"Sngl Pol : VV");
  if (imode == 6) strcpy(tmp,"Sngl Pol : ??");
  if (imode == 7) strcpy(tmp,"Dual Pol : HV VV");
  if (imode == 8) strcpy(tmp,"Dual Pol : HH VH");
  if (imode == 9) strcpy(tmp,"Dual Pol : ?? ??");
  if (imode == 10) strcpy(tmp,"File Mode Error");
  fprintf(fp_wr, "---------\n");
  fprintf(fp_wr, "file_mode\n");
  fprintf(fp_wr, "%s\n", tmp);

} /* CreateConfigFile() */




