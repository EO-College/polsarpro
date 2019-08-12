/******************************************************************************

	File	 : sirc_ceos.h
	Project  : ESA_POLSARPRO
	Authors  : Eric POTTIER, Laurent FERRO-FAMIL
	Version  : 1.0
	Creation : 06/2006
	Update	:

*-------------------------------------------------------------------------------
	INSTITUT D'ELECTRONIQUE et de TELECOMMUNICATIONS de RENNES (I.E.T.R)
	UMR CNRS 6164																						  
	Groupe Image et Teledetection
	Equipe SAPHIR (SAr Polarimetrie Holographie Interferometrie Radargrammetrie)
	UNIVERSITE DE RENNES I
	Pôle Micro-Ondes Radar
	Bât. 11D - Campus de Beaulieu
	263 Avenue Général Leclerc
	35042 RENNES Cedex
	Tel :(+33) 2 23 23 57 63
	Fax :(+33) 2 23 23 69 63
	e-mail : eric.pottier@univ-rennes1.fr, laurent.ferro-famil@univ-rennes1.fr
*-------------------------------------------------------------------------------
	Description :  SIR-C CEOS Header File

*******************************************************************************/
/*****************************************************************************/
/*																			*/
/* Copyright (c) 1993, California Institute of Technology. U.S.			  */
/* Government Sponsorship under NASA Contract NAS7-918 is acknowledged.	  */
/*																			*/
/* "This software is provided to you "as is" and without warranty of		 */
/*  any kind, expressed or implied, including but not limited to,			*/
/*  warranties of performance, merchantability, or fitness for a			 */
/*  particular purpose.  User bears all risk as to the quality and			*/
/*  performance of the software."											*/
/*																			*/
/*****************************************************************************/
/******************************************************************************
*																			 *
*																			 *
* Module:	oceos.h						  Program:	SIR-C GDPS			*
*											Author:	P. Barrett			*
*											Initiated: 03-FEB-93			 *
*																			 *
* --------------------------------------------------------------------------- *
*																			 *
* Abstract:	 Header file for oceos.c and ceos_rd.c						 *
*																			 *
* Description:  This file includes definitions and constants used by		  *
*				oceos.c and ceos_rd.c										 *
*																			 *
******************************************************************************/

#ifndef OCEOS_H
#define OCEOS_H


/*
 * If building task ceos_rd, include ceos_rd.h.
 * If building task oceos, do not include ceos_rd.h
 */
#ifdef SIRC_CEOS_READER
#include "sirc_header.h"
#endif


/******************************************************************************
*																			 *
*						  Constants										  *
*																			 *
******************************************************************************/


/* General Values */

#define  KILO				  1024		 /* One k bytes = 1024 bytes */
#define  MAX_LINE_LENGTH		(16 * KILO)  /* Max pixels/samples per line */
#define  MAX_BYTES_PER_PIXEL	10			/* Max bytes per pixel */
#define  MAX_MISSING_PAIRS	 5			/* Max missing line pairs */



/*************************
*						*
* Record Header Values	*
*						*
*************************/

/* Volume Directory - File Descriptor Record */

#define VDSEQ		  1
#define VD1SUB		 192
#define VDTYPE		 192
#define VD2SUB		 18
#define VD3SUB		 18

/* Volume Directory File - SAR Leader Pointer Record */

#define VLSEQ		  VDSEQ + 1
#define VL1SUB		 219
#define VLTYPE		 192
#define VL2SUB		 18
#define VL3SUB		 18

/* Volume Directory File - Imagery Options Pointer Record */

#define VISEQ		  VLSEQ + 1
#define VI1SUB		 219
#define VITYPE		 192
#define VI2SUB		 18
#define VI3SUB		 18

/* Volume Directory File - SAR Trailer Pointer Record */

#define VTSEQ		  VISEQ + 1
#define VT1SUB		 219
#define VTTYPE		 192
#define VT2SUB		 18
#define VT3SUB		 18

/* Volume Directory File - Text Record */

#define VXSEQ		  VTSEQ + 1
#define VX1SUB		 18
#define VXTYPE		 63
#define VX2SUB		 18
#define VX3SUB		 18

/* SAR Leader File - File Descriptor Record */

#define LDSEQ		  1
#define LD1SUB		 63
#define LDTYPE		 192
#define LD2SUB		 18
#define LD3SUB		 18

/* SAR Leader File - Data Set Summary Record */

#define LSSEQ		  LDSEQ + 1
#define LS1SUB		 10
#define LSTYPE		 10
#define LS2SUB		 50
#define LS3SUB		 20

/* SAR Leader File - Map Projection Data Record */

#define LMSEQ		 LSSEQ + 1
#define LM1SUB		10
#define LMTYPE		20
#define LM2SUB		50
#define LM3SUB		20

/* SAR Leader File - Platform Position Record */

#define LPSEQ		 LMSEQ + 1
#define LP1SUB		10
#define LPTYPE		30
#define LP2SUB		50
#define LP3SUB		20

/* SAR Leader File - Attitude Data Record */

#define LASEQ		 LPSEQ + 1
#define LA1SUB		10
#define LATYPE		40
#define LA2SUB		50
#define LA3SUB		20

/* SAR Leader File - Radiometric Data Record */

#define LRSEQ		 LASEQ + 1
#define LR1SUB		10
#define LRTYPE		50
#define LR2SUB		50
#define LR3SUB		20

/* SAR Leader File - Radiometric Compensation Record */

#define LCSEQ		 LRSEQ + 1
#define LC1SUB		10
#define LCTYPE		51
#define LC2SUB		50
#define LC3SUB		20

/* SAR Leader File - Data Quality Summary Record */

#define LQSEQ		 LCSEQ + 1
#define LQ1SUB		10
#define LQTYPE		60
#define LQ2SUB		50
#define LQ3SUB		20

/* SAR Leader File - Data Histograms Record */

#define LHSEQ		LQSEQ + 1
#define LH1SUB		10
#define LHTYPE		70
#define LH2SUB		50
#define LH3SUB		20

/* SAR Leader File - Range Spectra Record */

#define LZSEQ		LHSEQ + 1
#define LZ1SUB		10
#define LZTYPE		80
#define LZ2SUB		50
#define LZ3SUB		20

/* SAR Leader File - Radar Parameter Update Data Record */

#define LUSEQ		LZSEQ + 1
#define LU1SUB		10
#define LUTYPE		100
#define LU2SUB		50
#define LU3SUB		20

/* SAR Leader File - Detailed Processing Parameters Data Record */

#define LYSEQ		LUSEQ + 1
#define LY1SUB		10
#define LYTYPE		120
#define LY2SUB		50
#define LY3SUB		61

/* SAR Leader File - Calibration Data Record */

#define LBSEQ		LYSEQ + 1
#define LB1SUB		10
#define LBTYPE		130
#define LB2SUB		50
#define LB3SUB		20

/* Imagery Options File - File Descriptor Record */

#define IDSEQ		1
#define ID1SUB		63
#define IDTYPE		192
#define ID2SUB		18
#define ID3SUB		18

/* Imagery Options File - Reformatted Signal Data Record */

#define IRSEQ		IDSEQ + 1
#define IR1SUB		50
#define IRTYPE		10
#define IR2SUB		50
#define IR3SUB		20

/* Imagery Options File - Image Data Record */

#define IISEQ		IDSEQ + 1
#define II1SUB	  50
#define IITYPE	  11
#define II2SUB	  50
#define II3SUB	  20

/* SAR Trailer File - File Descriptor Record */

#define TDSEQ		1
#define TD1SUB	  63
#define TDYTYPE	 192
#define TD2SUB	  18
#define TD3SUB	  18

/* Null Volume Directory File - File Descriptor Record */

#define NDSEQ		1
#define ND1SUB	  192
#define NDTYPE	  192
#define ND2SUB	  63
#define ND3SUB	  18



/* Miscellaneous Constants */

#define LEFT_LOOK_DEG	-90.0
#define RIGHT_LOOK_DEG	90.0
#define POL_MATRIX_SIZE  32	 /* size of 4 x 4 pol cal (complex) matrix */

/* Polarization Masks */

#define HH_MASK		 1
#define HV_MASK		 2
#define VV_MASK		 4
#define VH_MASK		 8

/* SAR Leader File Descriptor Record */
#define CEOS_SW_ID			  1.1
#define SARL_FILE_NO			3
#define EMPTY_RECORD			0
#define N_SUMMARY_RECS		  1
#define N_MAP_RECS			  1
#define N_PLATFORM_RECS		 1
#define N_ATTITUDE_RECS		 1
#define N_ELEVATION_RECS		0	  /* record not used by SIR-C */
#define N_ANNOTATION_RECS		0	  /* record not used by SIR-C */
#define N_DET_PROC_REC		  1
#define N_CALIBRATION_RECS	  1
#define N_GROUND_PTS_RECS		0	  /* record not used by SIR-C */
#define N_FACILITY_RECS		 0	  /* record not used by SIR-C */

/* Data Set Summary Record Constants */

#define DSS_LCF		  1.0	/* linear conversion factor */

/* Radiometric Data Record Constants */

#define RADIO_N_SETS	 1	  /* number of data sets (fixed for SIR-C) */
#define RAD_ARRY_SZ	  0	  /* no table data provided */
#define RADIO_N_SAMPLES  0	  /* number of samples */
#define RADIO_LCF		1.0	/* linear conversion factor */
#define RADIO_OCF		0	  /* offset conversion factor */


/* Radiometric Compensation Data Record Constants */

#define RADIOC_N_SETS	1	  /* number of data sets */
#define RADIO_COMP_N_REQ 1	  /* number of recs to reconstitute table */
#define RADIO_TABLE_NO	1	  /* table sequence number */
#define CORRES_1ST_SAMP  1	  /* slant rg sample corresp to 1st correction */
#define RADIO_COMP_GP_SZ 1	  /* sample group size */
#define MIN_SAMP_INDEX	1.0	/* minimum sample index */


/* Histogram Data Record Constants */

#define HIST_N_SETS	  2	  /* # of data sets: 1 raw, 1 image */
#define RAW_HISTOGRAM	0	  /* raw histo is 1st data set */
#define IMAGE_HISTOGRAM  1	  /* image histo is 2nd data set */
#define HIST_REQ_RECS	1	  /* number of recs to reconstitute table */
#define HIST_TABLE_NO	1	  /* table sequence number */
#define RAWHIST_MIN_VAL  0.0	/* minimum value in raw histogram */

/* Data Quality Summary Record Constants */

#define QUAL_N_CHAN	  1	  /* number of channels */
#define SEQN_LOC		 1	  /* sequence number */
#define SEQ_FLD_LEN	  4	  /* sequence field length */
#define CODE_LOC		 SEQN_LOC + SEQ_FLD_LEN
#define CODE_FLD_LEN	 4	  /* recode code field length */
#define LEN_LOC		  CODE_LOC + CODE_FLD_LEN
#define LEN_FLD_LEN	  4

/* Range Spectra Record Constants */

#define SPECTRA_N_REQ	1	  /* number of records required */
#define SPECTRA_SET_SZ	256	/* data set size */
#define SPECTRA_TABLE_NO 1	  /* table sequence number */


/* Parameter Update Record Constants */

#define UPD_PIXEL_NUMBER 0	  /* Pixel no. of parameter change */


/* Imagery Options: File Descriptor Record Constants */

#define RSD_BITS_SAMPLE  8	  /* RSD bits per sample */
#define MLD_BITS_SAMPLE  16	 /* MLD bits per sample */
#define MLD_PIXELS_GP	1	  /* MLD, pixels per data group */
#define MLC_PIXELS_GP_DL 2	  /* MLC, pixels per data group, dual pol */
#define MLC_PIXELS_GP_QD 3	  /* MLC, pixels per data group, quad pol */
#define SLC_PIXELS_GP_SG 1	  /* SLC, pixels per data group, single pol */
#define SLC_PIXELS_GP_DL 2	  /* SLC, pixels per data group, dual pol */
#define SLC_PIXELS_GP_QD 4	  /* SLC, pixels per data group, quad pol */
#define RSD_PIXELS_GP	1	  /* RSD, pixels per data group */
#define MLD_BYTES_GP	 2	  /* MLD, bytes per group */
#define MLC_DUAL_BYTES	5	  /* MLC, dual pol, bytes per group */
#define MLC_QUAD_BYTES	10	 /* MLC, quad pol, bytes per group */
#define SLC_SING_BYTES	4	  /* SLC, single pol, bytes per group */
#define SLC_DUAL_BYTES	6	  /* SLC, dual pol, bytes per group */
#define SLC_QUAD_BYTES	10	 /* SLC, quad pol, bytes per group */
#define RSD_BYTES_GP	 1	  /* RSD, bytes per group */
#define LEFT_BORDER_PIX  0	  /* number of left border pixels */
#define RIGHT_BORDER_PIX 0	  /* number of right border pixels */
#define TOP_BORDER_PIX	0	  /* number of top border pixels */
#define BOTTOM_BD_PIX	0	  /* number of bottom border pixels */
#define N_RECS_LINE	  1	  /* number of physical recs per line */
#define N_RECS_CHANNEL	1	  /* n of records per multichannel line */
#define IMG_PREFIX_LEN	0	  /* length of prefix data per line */
#define IMG_SUFFIX_LEN	0	  /* length of suffix data per line */
#define N_LEFT_FILL	  0	  /* number of left fill bits per pixel */
#define N_RIGHT_FILL	 0	  /* number of right fill bits per pixel */


/* Strings */

#define YES_STR		  "YES"
#define NO_STR			"NO"
#define ASCII_STR		"A"
#define CEOS_DOC		 "CEOS-SAR-CCT"
#define DOC_VERS		 "A"
#define REV_LEVEL		"A"
#define SEQ_FLAG		 "FSEQ"
#define LOC_FLAG		 "FTYP"
#define REC_LOC_FLAG	 "FLGT"
#define MOTION_COMP	  "00"
#define PROC_FACILITY	"JPL"
#define NONE			 "NONE"
#define COS_SQUARE		"COS SQUARE PLUS %01.2f PEDESTAL HT"
#define SIRC_STR		 "SIR-C"
#define HYPHEN_STR		"-"
#define LSTR			 "L"
#define CSTR			 "C"
#define XSTR			 "X"
#define RES_STR		  "HI"
#define TX_H			 "H"
#define TX_V			 "V"
#define TX_HV			"HV"
#define RX_H			 "H"
#define RX_V			 "V"
#define RX_HV			"HV"
#define ANAL_CHIRP_STR	"ANALYTIC CHIRP"
#define DIGIT_CHIRP_STR  "DIGITAL CHIRP"
#define MEAS_CHIRP_STR	"MEASURED CHIRP"
#define BIT_QUANT_STR	"UNIFORM"
#define BFPQ_STR		 "(8,4)BFPQ"
#define OFF_STR		  "OFF"
#define ON_STR			"ON"
#define MLD_STR		  "MULTI-LOOK DETECTED"
#define MLC_STR		  "MULTI-LOOK COMPLEX"
#define SLC_STR		  "SINGLE-LOOK COMPLEX"
#define RSD_STR		  "REFORMATTED SIGNAL DATA"
#define PROC_ALGOR_STR	"FREQUENCY DOMAIN CONVOLUTION"
#define INCR_STR		 "INCREASE"
#define DECR_STR		 "DECREASE"
#define RANGE_STR		"RANGE"
#define BIAS_STR		 "0"
#define GAIN_STR		 "1"
#define ANNOT_PTS_STR	"0"
#define GND_RG_STR		"GROUND RANGE"
#define SLT_RG_STR		"SLANT RANGE"
#define CROSS_PROD_STR	"CROSS PRODUCTS"
#define SCAT_MTX_STR	 "SCATTERING MATRX"
#define NOT_APPL_STR	 "N/A"
#define RAW_DATA_HIST	"RAW DATA"
#define IMAGE_DATA_HIST  "IMAGE DATA"
#define DWP_DESCR_STR	"DATA WINDOW POSITION"
#define GAIN_DESCR_STR	"RECEIVER GAIN"
#define ALL_POLS_STR	 "ALL POLS"
#define EME_STR		  "EME"
#define ARIES_STR		"ARIES MEAN OF 1950 CARTESIAN"
#define GREENWICH_STR	"GREENWICH TRUE OF DATE"
#define COMPENS_DESCR	"RG RADIOMETRIC CORRECTION VECTOR"
#define ELEV_ANT_PAT	 "ELEVATION ANTENNA PATTERN"
#define FLIGHT_1		 "SRL-1"
#define FLIGHT_2		 "SRL-2"
#define FLIGHT_3		 "SRL-3"
#define FLIGHT_4		 "SRL-4"
#define BITS_PER_SAMPLE  " "
#define INTERLEAVING_IND "BSQ"
#define POWER_DETECTED	"POWER DETECTED"
#define COMPR_CROSS_PROD "COMPRESSED CROSS-PRODUCTS"
#define COMPR_SCAT_MATRIX "COMPRESSED SCATTERING MATRIX"
#define REAL_BYTE		"REAL BYTE"
#define VARIES			"VARIES"
#define ASCENDING_STR	"ASCENDING"
#define DESCENDING_STR	"DESCENDING"


/* SAR Channels */

#define XVV			  00
#define LHH			  11
#define LHV			  12
#define LVV			  13
#define LVH			  14
#define LQUAD			15
#define LHH_LHV		  16
#define LVV_LVH		  17
#define LHH_LVV		  18
#define CHH			  21
#define CHV			  22
#define CVV			  23
#define CVH			  24
#define CQUAD			25
#define CHH_CHV		  26
#define CVV_CVH		  27
#define CHH_CVV		  28

/* Product Level Codes */

#define RSD_PROD_CODE	"0.0"
#define SLC_PROD_CODE	"1.0"
#define ML_PROD_CODE	 "1.5"



/******************************************************************************
*																			 *
*				 Structures which define CEOS Data Records					*
*																			 *
******************************************************************************/


/***************************************************
*												  *
*					  Header					  *
*												  *
* ..the 12-byte preamble at the beginning of every *
* CEOS data record.  These are the only binary	 *
* values stored in the CEOS files.  Everything	 *
* else is ASCII.									*
*												  *
***************************************************/

typedef struct {
	unsigned		record_seq_no;		/* record sequence number */
	unsigned char  first_rec_subtype;	/* first record subtype */
	unsigned char  record_type_code;	 /* record type code */
	unsigned char  second_rec_subtype;	/* second record subtype */
	unsigned char  third_rec_subtype;	/* third record subtype */
	unsigned		rec_length;			/* length of this record */

} hdr_t;



/****************************
*							*
*  Volume Directory File	*
*  Volume Descriptor Record *
*							*
****************************/

typedef struct {
	hdr_t  hdr;				  /* header info */
	char  ascii_flag[2];		/* ASCII flag */
	char  spare1[2];			/* spare */
	char  doc_no[12];			/* control document number */
	char  doc_rev[2];			/* revision number (00-99) */
	char  design_rev[2];		/* file design revision number */
	char  software_id[12];	  /* software ID */
	char  tape_id[16];		  /* physical tape ID */
	char  logical_id[16];		/* logical set ID */
	char  volume_id[16];		/* volume set ID */
	char  n_volumes[2];		 /* number of physical volumes */
	char  first_seq[2];		 /* first physical vol sequence number */
	char  last_seq[2];		  /* last physical vol sequence number */
	char  this_seq[2];		  /* this physical vol number */
	char  first_ref_file[4];	/* first reference file in volume */
	char  log_vol[4];			/* logical volume in set */
	char  log_vol_phys[4];	  /* logical volume in physical volume */
	char  tape_date[8];		 /* tape creation date */
	char  tape_time[8];		 /* tape creation time */
	char  country[12];		  /* tape creating country */
	char  agency[8];			/* tape creating agency */
	char  facility[12];		 /* tape creating facility */
	char  n_pointers[4];		/* number of pointer records */
	char  n_records[4];		 /* number of records */
	char  spare2[92];			/* spare */
	char  spare3[100];		  /* spare */

} vol_descript_t;



/****************************
*							*
*  Volume Directory File	*
*  File Pointer Record	  *
*							*
****************************/

typedef struct {
	hdr_t  hdr;				  /* header info */
	char  ascii[2];			 /* ascii flag */
	char  spare1[2];			/* spare */
	char  file_no[4];			/* file number */
	char  filename[16];		 /* filename */
	char  file_class[28];		/* file class */
	char  class_code[4];		/* file class code */
	char  data_type[28];		/* data type */
	char  type_code[4];		 /* data type code */
	char  n_records[8];		 /* number of records */
	char  first_len[8];		 /* first record length */
	char  max_len[8];			/* max record length */
	char  rec_type[12];		 /* record type */
	char  rec_code[4];		  /* record type code */
	char  start_vol[2];		 /* start file volume number */
	char  end_vol[2];			/* end file volume number */
	char  first_rec[8];		 /* first record number on tape */
	char  last_rec[8];		  /* last record number on tape */
	char  spare2[100];		  /* spare */
	char  spare3[100];		  /* spare */

} vol_ptr_t;



/****************************
*							*
*  Volume Directory File	*
*  Text Record			  *
*							*
****************************/

typedef struct {
	hdr_t  hdr;				  /* header info */
	char  ascii[2];			 /* ascii flag */
	char  spare1[2];			/* spare */
	char  prod[40];			 /* product type specifier */
	char  loc[60];			  /* location, date/time prod creation */
	char  vol_id[40];			/* physical volume ID */
	char  scene_id[40];		 /* scene ID */
	char  scene_loc[40];		/* scene location */
	char  spare2[20];			/* spare */
	char  spare3[104];		  /* spare */

} vol_text_t;



/****************************
*							*
*  SAR Leader File:		 *
*  File Descriptor Record	*
*							*
****************************/

typedef struct {
	hdr_t  hdr;				  /* header info */
	char  ascii_flag[2];		/* ASCII flag */
	char  spare1[2];			/* spare */
	char  doc_format[12];		/* document format */
	char  format_rev[2];		/* format revision ("A") */
	char  rec_format_rev[2];	/* record format revision level */
	char  software_id[12];	  /* software ID */
	char  file_no[4];			/* file number */
	char  filename[16];		 /* filename */
	char  seq_flag[4];		  /* record sequence and location type flag */
	char  seq_location[8];	  /* sequence number location */
	char  seq_field_len[4];	 /* sequence number field length */
	char  code_flag[4];		 /* record code and location type flag */
	char  code_location[8];	 /* record code location */
	char  code_field_len[4];	/* record code field length */
	char  len_flag[4];		  /* record length and location type flag */
	char  len_location[8];	  /* record length location */
	char  len_field_len[4];	 /* record length field length */
	char  spare2[1];			/* spare */
	char  spare3[1];			/* spare */
	char  spare4[1];			/* spare */
	char  spare5[1];			/* spare */
	char  spare6[64];			/* spare */
	char  n_data_set_recs[6];	/* number of data set summary records */
	char  len_data_set[6];	  /* record length */
	char  n_map_proj_recs[6];	/* number of map projection data records */
	char  len_map_proj[6];	  /* record length */
	char  n_platf_recs[6];	  /* number of platform position records */
	char  len_platf[6];		 /* record length */
	char  n_att_recs[6];		/* number of attitude data records */
	char  len_att[6];			/* record length */
	char  n_radio_recs[6];	  /* number of radiometric data records */
	char  len_radio[6];		 /* record length */
	char  n_radio_comp_recs[6]; /* number of radio compensation records */
	char  len_radio_comp[6];	/* record length */
	char  n_qual_recs[6];		/* number of data quality summary records */
	char  len_qual[6];		  /* record length */
	char  n_hist_recs[6];		/* number of data histogram records */
	char  len_hist[6];		  /* record length */
	char  n_spectra_recs[6];	/* number of range spectra records */
	char  len_spectra[6];		/* record length */
	char  n_elev_recs[6];		/* number of digital elevation model recs */
	char  len_elev[6];		  /* record length */
	char  n_update_recs[6];	 /* number of radar parameter update recs */
	char  len_update[6];		/* record length */
	char  n_annot_recs[6];	  /* number of annotation data records */
	char  len_annot[6];		 /* record length */
	char  n_proc_recs[6];		/* number of detailed processing records */
	char  len_proc[6];		  /* record length */
	char  n_calib_recs[6];	  /* number of calibration data records */
	char  len_calib[6];		 /* record length */
	char  n_ground[6];		  /* number of ground control pts records */
	char  len_ground[6];		/* record length */
	char  spare7[6];			/* spare */
	char  spare8[6];			/* spare */
	char  spare9[6];			/* spare */
	char  spare10[6];			/* spare */
	char  spare11[6];			/* spare */
	char  spare12[6];			/* spare */
	char  spare13[6];			/* spare */
	char  spare14[6];			/* spare */
	char  spare15[6];			/* spare */
	char  spare16[6];			/* spare */
	char  n_facil_recs[6];	  /* number of facility data records */
	char  len_facil[6];		 /* record length */
	char  spare17[288];		 /* spare */

} sarl_descript_t;



/****************************
*							*
*  SAR Leader File:		 *
*  Data Set Summary Record  *
*							*
****************************/

typedef struct {
	char  sensid[6];			/* SIR-C */
	char  hyphen1[1];			/* hyphen */
	char  freq[2];			  /* SAR band: L, C, or X */
	char  hyphen2[1];			/* hyphen */
	char  res[2];				/* resolution mode: HI, LO, SUrvey */
	char  acq[2];				/* radar data acquisiton mode */
	char  hyphen3[1];			/* hyphen */
	char  tx[2];				/* transmit polarization */
	char  rx[2];				/* receive polarization */
	char  spare1[13];			/* pad structure to length 32 */

} sensor_id_t;


typedef struct {
	hdr_t  hdr;				  /* header info */
	char  seq_no[4];			/* Data Set Summary: record sequence number */
	char  SAR_channel[4];		/* SAR channel indicator */
	char  site_id[16];		  /* site ID (3-char ID) */
	char  site_name[32];		/* site name */
	char  center_GMT[32];		/* image center GMT: YYYYMMDDhhmmssttt */
	char  center_MET[16];		/* image center MET: DDhhmmssttt */
	char  lat_scene_ctr[16];	/* latitude at scene center */
	char  long_scene_ctr[16];	/* longitude at scene center */
	char  track_angle[16];	  /* track angle at image center */
	char  ellipsoid_name[16];	/* ellipsoid designator */
	char  semimajor_axis[16];	/* ellipsoid semimajor axis (km) */
	char  semiminor_axis[16];	/* ellipsoid semiminor axis (km) */
	char  spare2[16];			/* spare */
	char  spare3[16];			/* spare */
	char  spare4[16];			/* spare */
	char  spare5[16];			/* spare */
	char  spare6[16];			/* spare */
	char  terrain_ht[16];		/* average terrain height */
	char  center_line[16];	  /* image center line number (azimuth) */
	char  center_pixel[16];	 /* image center pixel number (range) */
	char  image_length_km[16];  /* image length in km */
	char  image_width_km[16];	/* image width in km */
	char  spare7[8];			/* spare */
	char  spare8[8];			/* spare */
	char  n_channels[4];		/* number of SAR channels */
	char  spare9[4];			/* spare */
	char  platform_id[16];	  /* platform (shuttle) id */
	sensor_id_t  sensor_id;	 /* sensor id: AAAAAA-BB-CCDD-EEFF */
	char  datatake_id[8];		/* datatake id */
	char  craft_lat[8];		 /* spacecraft latitude at nadir */
	char  craft_long[8];		/* spacecraft longitude at nadir */
	char  platform_heading[8];  /* sensor platform heading (degrees) */
	char  clock_angle[8];		/* sensor clock angle rel to flight dir */
	char  incid_angle_ctr[8];	/* incidence angle at image center */
	char  frequency[8];		 /* radar frequency (GHz) */
	char  wavelength[16];		/* radar wavelength (m) */
	char  motion_comp[2];		/* motion compensation indicator */
	char  rg_code_spec[16];	 /* range pulse code specifier */
	char  spare10[16];		  /* spare */
	char  spare11[16];		  /* spare */
	char  spare12[16];		  /* spare */
	char  spare13[16];		  /* spare */
	char  spare14[16];		  /* spare */
	char  spare15[16];		  /* spare */
	char  rg_pulse_phase2[16];  /* range pulse phase coefficient #2 */
	char  rg_pulse_phase3[16];  /* range pulse phase coefficient #3 */
	char  spare16[16];		  /* spare */
	char  spare17[16];		  /* spare */
	char  spare18[8];			/* spare */
	char  spare19[8];			/* spare */
	char  rg_sampling_rate[16]; /* range complex sampling rate */
	char  echo_delay[16];		/* range gate at early edge */
	char  rg_pulse_len[16];	 /* range pulse length */
	char  base_band_conv[4];	/* base band conversion flag */
	char  rg_compressed[4];	 /* range compressed flag */
	char  rcv_gain_like[16];	/* receiver gain for like pol */
	char  rcv_gain_cross[16];	/* receiver gain for cross pol */
	char  quant_bits[8];		/* quantization bits per channel */
	char  quant_descr[12];	  /* quantizer description */
	char  spare20[16];		  /* spare */
	char  spare21[16];		  /* spare */
	char  spare22[16];		  /* spare */
	char  spare23[16];		  /* spare */
	char  spare24[16];		  /* spare */
	char  elect_boresight[16];  /* electronic boresight */
	char  mech_boresight[16];	/* mechanical boresight */
	char  echo_tracker_flag[4]; /* echo tracker flag */
	char  prf[16];			  /* nominal PRF */
	char  elev_beamwidth[16];	/* antenna elevation 3dB beam width */
	char  az_beamwidth[16];	 /* antenna azimuth 3dB beam width */
	char  spare25[16];		  /* spare */
	char  spare26[32];		  /* spare */
	char  spare27[8];			/* spare */
	char  spare28[8];			/* spare */
	char  proc_facility[16];	/* processing facility: JPL */
	char  hw_version[8];		/* processing h/w version */
	char  sw_version[8];		/* processor s/w version */
	char  spare29[16];		  /* spare */
	char  product_code[16];	 /* product code */
	char  product_type[32];	 /* product type */
	char  proc_algorithm[32];	/* processing algorithm */
	char  n_looks[16];		  /* number of looks */
	char  spare30[16];		  /* spare */
	char  spare31[16];		  /* spare */
	char  spare32[16];		  /* spare */
	char  az_bandwidth[16];	 /* processor bandwidth (azimuth) */
	char  rg_bandwidth[16];	 /* processor bandwidth (range) */
	char  az_weighting[32];	 /* weighting function (azimuth) */
	char  rg_weighting[32];	 /* weighting function (range) */
	char  hddc_id[16];		  /* HDDC id */
	char  rg_nom_res[16];		/* nominal resolution (range) */
	char  az_nom_res[16];		/* nominal resolution (azimuth) */
	char  bias[16];			 /* bias */
	char  gain[16];			 /* gain */
	char  spare33[16];		  /* spare */
	char  spare34[16];		  /* spare */
	char  spare35[16];		  /* spare */
	char  spare36[16];		  /* spare */
	char  spare37[16];		  /* spare */
	char  spare38[16];		  /* spare */
	char  spare51[16];		  /* spare - added later */
	char  rg_time_dir[8];		/* time direction (range) */
	char  az_time_dir[8];		/* time direction (azimuth) */
	char  spare39[16];		  /* spare */
	char  spare40[16];		  /* spare */
	char  spare41[16];		  /* spare */
	char  spare42[16];		  /* spare */
	char  spare43[16];		  /* spare */
	char  spare44[16];		  /* spare */
	char  spare45[16];		  /* spare */
	char  electronic_delay[16]; /* electronic delay time (RSD only) */
	char  line_content[8];	  /* line content indicator */
	char  clutter_lock_flag[4]; /* clutter lock flag */
	char  autofocus_flag[4];	/* autofocussing flag */
	char  line_spacing[16];	 /* line spacing (m) */
	char  pixel_spacing[16];	/* pixel spacing (m) */
	char  rg_compression[16];	/* range compression designator */
	char  orbit_dir[16];		/* orbit direction */
	char  spare47[16];		  /* spare */
	char  spare48[120];		 /* spare */
	char  spare49[120];		 /* spare */
	char  annot_pts[8];		 /* no. of annotation points in image */
	char  spare50[2];			/* spare for word boundary padding */

} sarl_data_summary_t;



/****************************
*							*
*  SAR Leader File:		 *
*  Map Projection Data Rec  *
*							*
****************************/

typedef struct {
	hdr_t  hdr;				  /* header info */
	char  spare1[16];			/* spare */
	char  map_proj_descr[32];	/* map projection descriptor */
	char  n_pixels[16];		 /* number of pixels per line */
	char  n_lines[16];		  /* number of image lines */
	char  pix_spacing[16];	  /* pixel spacing (m) */
	char  line_spacing[16];	 /* line spacing (m) */
	char  spare2[16];			/* spare */
	char  spare3[16];			/* spare */
	char  spare4[16];		  /* spare */
	char  platform_dist[16];	/* platform distance */
	char  geodet_alt[16];		/* geodetic altitude */
	char  ground_speed[16];	 /* ground speed at nadir */
	char  platform_heading[16]; /* platform heading */
	char  ellipsoid_name[32];	/* name of reference ellipsoid */
	char  semimajor_axis[16];	/* semimajor axis of ref ellipsoid */
	char  semiminor_axis[16];	/* semiminor axis of ref ellipsoid */
	char  spare5[16];			/* spare */
	char  spare6[16];			/* spare */
	char  spare7[16];			/* spare */
	char  spare8[16];			/* spare */
	char  spare9[16];			/* spare */
	char  spare10[16];		  /* spare */
	char  spare11[16];		  /* spare */
	char  spare12[32];		  /* spare */
	char  spare13[32];		  /* spare */
	char  spare14[4];			/* spare */
	char  spare15[16];		  /* spare */
	char  spare16[16];		  /* spare */
	char  spare17[16];		  /* spare */
	char  spare18[16];		  /* spare */
	char  spare19[16];		  /* spare */
	char  spare20[16];		  /* spare */
	char  spare21[16];		  /* spare */
	char  spare22[32];		  /* spare */
	char  spare23[16];		  /* spare */
	char  spare24[16];		  /* spare */
	char  spare25[16];		  /* spare */
	char  spare26[32];		  /* spare */
	char  spare27[16];		  /* spare */
	char  spare28[16];		  /* spare */
	char  spare29[16];		  /* spare */
	char  spare30[16];		  /* spare */
	char  spare31[16];		  /* spare */
	char  spare32[16];		  /* spare */
	char  spare33[16];		  /* spare */
	char  spare34[16];		  /* spare */
	char  spare35[16];		  /* spare */
	char  spare36[16];		  /* spare */
	char  spare37[16];		  /* spare */
	char  spare38[16];		  /* spare */
	char  spare39[16];		  /* spare */
	char  spare40[16];		  /* spare */
	char  spare41[16];		  /* spare */
	char  spare42[16];		  /* spare */
	char  spare43[16];		  /* spare */
	char  spare44[16];		  /* spare */
	char  spare45[16];		  /* spare */
	char  spare46[16];		  /* spare */
	char  spare47[16];		  /* spare */
	char  spare48[16];		  /* spare */
	char  spare49[16];		  /* spare */
	char  near_early_lat[16];	/* near-early latitude */
	char  near_early_long[16];  /* near-early longitude */
	char  far_early_lat[16];	/* far-early latitude */
	char  far_early_long[16];	/* far_early longitude */
	char  far_late_lat[16];	 /* far-late latitude */
	char  far_late_long[16];	/* far-late longitude */
	char  near_late_lat[16];	/* near-late latitude */
	char  near_late_long[16];	/* near-late longitude */
	char  spare50[16];		  /* spare */
	char  spare51[16];		  /* spare */
	char  spare52[16];		  /* spare */
	char  spare53[16];		  /* spare */
	char  spare54[8][20];		/* spare */
	char  spare55[8][20];		/* spare */
	char  spare56[36];		  /* spare */

} sarl_map_proj_t;



/****************************
*							*
*  SAR Leader File:		 *
*  Platform Position Rec	*
*							*
****************************/

/****************************************************
*													*
* NOTE: The pointer values at the end of these and  *
* other structures are not written to the CEOS	  *
* files and are not read by the reader software.	*
*													*
*****************************************************/


/* data set structure */

struct platform_dset {
	char  pos_vector[3][22];	/* (X,Y,Z) position vector of 1st data pt */
	char  vel_vector[3][22];	/* (X,Y,Z) velocity vector of 1st data pt */
	char  spare1[4];			/* spare for word boundary padding */
	struct platform_dset *next; /* link (must be last structure member) */
} ;

typedef struct platform_dset platf_data_set;

/* main structure */

typedef struct {
	hdr_t  hdr;				  /* header info */
	char  spare1[32];			/* spare */
	char  spare2[16];			/* spare */
	char  spare3[16];			/* spare */
	char  spare4[16];			/* spare */
	char  spare5[16];			/* spare */
	char  spare6[16];			/* spare */
	char  spare7[16];			/* spare */
	char  n_data_sets[4];		/* number of data sets */
	char  year[4];			  /* year of first data point */
	char  month[4];			 /* month of first data point */
	char  day[4];				/* day of first data point */
	char  day_in_year[4];		/* day in year of first data point */
	char  sec_in_day[22];		/* seconds in day of first data point */
	char  interval[22];		 /* time interval between data points (s) */
	char  coord_sys[64];		/* reference coordinate system */
	char  hour_angle[22];		/* GMT hour angle (degrees) */
	char  spare8[16];			/* spare */
	char  spare9[16];			/* spare */
	char  spare10[16];		  /* spare */
	char  spare11[16];		  /* spare */
	char  spare12[16];		  /* spare */
	char  spare13[16];		  /* spare */
	char  spare14[6];			/* spare for word boundary padding */
	platf_data_set *data_set;	/* pointer to linked list of data sets */

} sarl_platf_pos_t;



/****************************
*							*
*  SAR Leader File:		 *
*  Attitude Data Record	 *
*							*
****************************/

/* data set structure */

struct attitude_dset {
	char  days[4];			  /* day in the year (GMT) */
	char  millisecs[8];		 /* millisecond of the day (GMT) */
	char  spare1[4];			/* spare */
	char  spare2[4];			/* spare */
	char  spare3[4];			/* spare */
	char  pitch[16];			/* pitch (degrees) */
	char  roll[16];			 /* roll (degrees) */
	char  yaw[16];			  /* yaw (degrees) */
	char  spare4[4];			/* spare */
	char  spare5[4];			/* spare */
	char  spare6[4];			/* spare */
	char  spare7[16];			/* pitch rate (degrees/sec) */
	char  spare8[16];			/* roll rate (degrees/sec) */
	char  spare9[16];			/* yaw_rate (degrees/sec) */
	char  spare10[4];			/* padding for word boundary */
	struct attitude_dset *next; /* link (must be last struct member) */

} ;

typedef struct attitude_dset att_data_set;



/* main structure */

typedef struct {
	hdr_t  hdr;				  /* header info */
	char  n_data_sets[4];		/* number of attitude data sets */
	att_data_set *data_set;	  /* pointer to linked list */
} sarl_attitude_t;



/****************************
*							*
*  SAR Leader File:		 *
*  Radiometric Data Record  *
*							*
****************************/

/* data set structure */

struct radio_dset {
	char  data_set_size[8];	 /* radiometric data set size */
	char  sar_channel[4];		/* SAR channel indicator */
	char  spare1[4];			/* spare */
	char  calibration_date[24]; /* calibration date */
	char  n_samples[8];		 /* no. of samples in look up table */
	char  sample_type[16];	  /* sample type indicator */
	char  noise_est[16];		/* noise power estimate */
	char  linear_conv_fact[16]; /* linear conversion factor */
	char  proc_gain_noise[16];  /* processor gain for noise data */
	char  spare4[4];			/* spare */
	char  spare5[4];			/* padding for word boundary */
	struct radio_dset *next;	/* link (must be last struct member) */
} ;

typedef struct radio_dset radio_data_set;


/* main structure */

typedef struct {
 hdr_t	hdr;				  /* header info */
  char	seq_no[4];			/* radiometric data rec seq number */
  char	n_data_sets[4];		/* number of data sets */
  char	spare1[4];			/* padding for word boundary */
  radio_data_set  *data_set;	/* pointer to linked list */
} sarl_radio_t;




/****************************
*							*
*  SAR Leader File:		 *
*  Radiometric Comp Record  *
*							*
****************************/

/* data set structure */

struct radio_comp_tbl {
	char  sample_index[16];	 /* compensation sample index */
	char  sample_value[16];	 /* compensation sample value */
	struct radio_comp_tbl *next; /* link (must be last struct member) */

};

typedef struct radio_comp_tbl radcomp_table;


/* main structure */

typedef struct {

	hdr_t  hdr;				  /* header info */
	char  seq_no[4];			/* radio comp record seq number */
	char  sar_channel[4];		/* sar channel indicator */
	char  n_data_sets[8];		/* number of data sets */
	char  data_set_size[8];	 /* data set size */
	char  data_type[8];		 /* data type designator */
	char  data_descr[32];		/* data descriptor */
	char  req_records[4];		/* number of required records */
	char  table_seq_num[4];	 /* table sequence number */
	char  spare1[8];			/* data point subsampling factor */
	char  first_pixel[8];		/* pixel corresponding to first correction */
	char  last_pixel[8];		/* pixel corresponding to last correction */
	char  pixel_size[8];		/* pixel group size (subsample factor) */
	char  min_samp_index[16];	/* minimum sample index */
	char  min_comp_value[16];	/* minimum radiometric compensation value */
	char  max_samp_index[16];	/* maximum sample index */
	char  max_comp_value[16];	/* maximum radiometric compensation value */
	char  spare2[16];			/* spare */
	char  n_table_entries[8];	/* number of table entries */
	char  spare3[4];			/* padding for word boundary */
  radcomp_table  *tbl_ptr;	  /* pointer to linked list */



} sarl_radio_comp_t;



/****************************
*							*
*  SAR Leader File:		 *
*  Data Quality Summary	 *
*							*
****************************/

typedef struct {
	hdr_t  hdr;				  /* header info */
	char  seq_no[4];			/* dqs record sequence number */
	char  sar_channel[4];		/* sar channel indicator */
	char  calibr_date[6];		/* calibration date */
	char  n_channels[4];		/* number of channels */
	char  islr[16];			 /* integrated side lobe ratio */
	char  pslr[16];			 /* peak side lobe ratio */
	char  az_ambig[16];		 /* azimuth ambiguity */
	char  rg_ambig[16];		 /* range ambiguity */
	char  snr_est[16];		  /* signal-to-noise ratio estimate */
	char  ber[16];			  /* bit error rate */
	char  slant_rg_res[16];	 /* nominal slant range resolution */
	char  az_res[16];			/* nominal azimuth resolution */
	char  radio_res[16];		/* nominal radiometric resolution */
	char  dynam_rg[16];		 /* instantaneous dynamic range */
	char  abs_radio_unc[16];	/* absolute radio calibration uncertainty */
	char  spare1[16];			/* spare */
	char  relst_radio_unc[16];  /* rel short term radio calibr uncertainty */
	char  rel_phase_uncert[16]; /* relative phase calibration uncertainty */
	char  rellt_radio_unc[16];  /* rel long term radio calibr uncertainty */
	char  st_freq_freq[16];	 /* short term freq-to-freq uncertainty */
	char  lt_freq_freq[16];	 /* long term freq-to-freq uncertainty */
	char  along_loc_error[16];  /* location error along track */
	char  cross_loc_error[16];  /* location error cross track */
	char  along_scale_err[16];  /* along track scale error */
	char  cross_scale_err[16];  /* cross track scale error */
	char  skew_err[16];		 /* geometric skew error */
	char  orient_err[16];		/* image orientation error */
	char  along_err_hh[16];	 /* along track error of SAR HH */
	char  cross_err_hh[16];	 /* cross track error of SAR HH */
	char  along_err_lc[16];	 /* along track error LHH and CHH */
	char  cross_err_lc[16];	 /* cross track error LHH and CHH */
	char  spare2[2];			/* spare for word boundary padding */

} sarl_data_qual_summary_t;



/****************************
*							*
*  SAR Leader File:		 *
* Data Histograms Record	*
*							*
****************************/

/* data set structure */

struct histogram_dset {
	char  descriptor[32];		/* histogram descriptor */
	char  req_recs[4];		  /* required records */
	char  table_no[4];		  /* table sequence number */
	char  table_size[8];		/* table size, bytes */
	char  n_pixels[8];		  /* number of pixels in line */
	char  n_lines[8];			/* number of lines in image */
	char  cross_pixels[8];	  /* pixels/group, cross track */
	char  along_pixels[8];	  /* pixels/group, along track */
	char  n_groups_cross[8];	/* number of groups, cross track */
	char  n_groups_along[8];	/* number of groups, along track */
	char  min_sample_value[16]; /* minimum pixel value */
	char  max_sample_value[16]; /* maximum pixel value */
	char  spare1[16];			/* spare */
	char  spare2[16];			/* spare */
	char  mean[16];			 /* mean sample value */
	char  std_dev[16];		  /* std deviation of sample value */
	char  increment[16];		/* sample value increment */
	char  min_value[16];		/* minimum table value */
	char  max_value[16];		/* maximum table value */
	char  n_bins[8];			/* number of bins */
	char  data_values[256][16]; /* table values 1-256 */
	struct histogram_dset *next; /* link (must be last struct member) */
} ;

typedef struct histogram_dset hist_data_set;


/* main structure */

typedef struct {
	hdr_t  hdr;				  /* header info */
	char  seq_no[4];			/* data histogram record seq no. */
	char  sar_channel[4];		/* SAR channel */
	char  n_data_sets[8];		/* number of data sets */
	char  data_set_size[8];	 /* data set size */
	char  spare1[4];			/* padding for word boundary */
	hist_data_set *data_set;	 /* pointer to linked list */
} sarl_histogram_t;



/****************************
*							*
*  SAR Leader File:		 *
*  Range Spectra Record	 *
*							*
****************************/

typedef struct {
	hdr_t  hdr;				  /* header info */
	char  seq_no[4];			/* range spectra sequence no. */
	char  sar_channel[4];		/* SAR channel */
	char  n_data_sets[8];		/* number of data sets */
	char  data_set_size[8];	 /* data set size */
	char  req_recs[4];		  /* number of records required */
	char  table_no[4];		  /* table sequence number */
	char  n_pixels[8];		  /* number of pixels in line */
	char  pixel_offset[8];	  /* offset from first pixel */
	char  n_lines[8];			/* number of lines integrated for spectra */
	char  first_freq[16];		/* center freq of first spectra bin */
	char  last_freq[16];		/* center freq of last spectra bin */
	char  min_power[16];		/* minimum spectral power */
	char  max_power[16];		/* maximum spectral power */
	char  spare1[16];			/* spare */
	char  spare2[16];			/* spare */
	char  n_bins[8];			/* number of freq bins in table */
	char  spare3[4];			/* padding for word boundary */
	char  data_values[256][16];  /* spectral data values 1-256 */

} sarl_spectra_t;



/****************************
*							*
*  SAR Leader File:		 *
*  Radar Parameter Update	*
*							*
****************************/

/* data set structure */

struct upd_dset {
	char  gmt[20];			  /* GMT of change: YYYYMMDD-hhmmssttt */
	char  sar_channel[4];		/* SAR channel indicator */
	char  line_no[8];			/* data line number of change */
	char  pixel_no[8];		  /* pixel number of change */
	char  descr[32];			/* desriptor field */
	char  value[16];			/* parameter value (gain or DWP) */
	struct upd_dset *next;	  /* link (must be last struct member) */

} ;

typedef struct upd_dset upd_data_set;

/* main structure */

typedef struct {
	hdr_t  hdr;				  /* header info */
	char  seq_no[4];			/* radar parameter update record */
	char  spare1[4];			/* spare */
	char  n_data_sets[8];		/* number of data sets */
	char  data_set_size[8];	 /* radar parameter update data set size */
	char  spare2[4];			/* padding for word boundary */
	upd_data_set *data_set;	  /* ptr to linked list of data sets */

} sarl_param_upd_t;



/****************************
*							*
*  SAR Leader File:		 *
*  Detailed Processing Data *
*							*
****************************/

typedef struct {
	hdr_t  hdr;				  /* header info */
	char  seq_no[4];			/* detailed proc rec sequence no */
	char  spare1[4];			/* spare */
	char  n_flywheels[8];		/* number of flywheels */
	char  missing_1[10][8];	 /* missing line pairs, channel 1 */
	char  more_1[1];			/* flag indicating more than 5 pair missing */
	char  missing_2[10][8];	 /* missing line pairs, channel 2 */
	char  more_2[1];			/* flag indicating more than 5 pair missing */
	char  missing_3[10][8];	 /* missing line pairs, channel 3 */
	char  more_3[1];			/* flag indicating more than 5 pair missing */
	char  missing_4[10][8];	 /* missing line pairs, channel 4 */
	char  more_4[1];			/* flag indicating more than 5 pair missing */
	char  ref_gain_hh[16];	  /* caltone reference gain setting HH */
	char  ref_gain_hv[16];	  /*								HV */
	char  ref_gain_vv[16];	  /*								VV */
	char  ref_gain_vh[16];	  /*								VH */
	char  mean_gain_hh[16];	 /* mean of caltone gain HH */
	char  mean_gain_hv[16];	 /*					  HV */
	char  mean_gain_vv[16];	 /*					  VV */
	char  mean_gain_vh[16];	 /*					  VH */
	char  dev_gain_hh[16];	  /* std deviation of caltone gain est HH */
	char  dev_gain_hv[16];	  /*									HV */
	char  dev_gain_vv[16];	  /*									VV */
	char  dev_gain_vh[16];	  /*									VH */
	char  over_sat_hh[16];	  /* average % oversat in raw data hist HH */
	char  over_sat_hv[16];	  /*									HV */
	char  over_sat_vv[16];	  /*									VV */
	char  over_sat_vh[16];	  /*									VH */
	char  under_sat_hh[16];	 /* average % undersat in raw data hist HH */
	char  under_sat_hv[16];	 /*									 HV */
	char  under_sat_vv[16];	 /*									 VV */
	char  under_sat_vh[16];	 /*									 VH */
	char  proc_run[8];		  /* processing run number */
	char  mission_id[8];		/* mission (flight) ID */
	char  beam_spoil[1];		/* antenna beam spoiling mode (0-7) */
	char  start_gmt[24];		/* start GMT: YYYY/DD/MM hh:mm:ss.ttt */
	char  start_gmt_sec[16];	/* start GMT in seconds */
	char  image_duration[16];	/* image duration */
	char  near_slant[16];		/* near slant range (km) */
	char  ctr_radius[16];		/* radius of earth at image center (km) */
	char  nadir_radius[16];	 /* radius of earth at nadir (km) */
	char  gmt_0met_year[8];	 /* GMT of 0 MET: year */
	char  gmt_0met_days[8];	 /* GMT of 0 MET: days */
	char  gmt_0met_hours[8];	/* GMT of 0 MET: hours */
	char  gmt_0met_minutes[8];  /* GMT of 0 MET: minutes */
	char  gmt_0met_sec[8];	  /* GMT of 0 MET: seconds: ss.ccc */
	char  met_drift[16];		/* MET drift time (10**-6) */
	char  fd0_const[16];		/* doppler centroid: constant */
	char  fd0_linear[16];		/*					linear term coefficient */
	char  fd0_quad[16];		 /*					quad term coefficient */
	char  fd1_const[16];		/* doppler centroid: constant */
	char  fd1_linear[16];		/*					linear term coefficient */
	char  fd1_quad[16];		 /*					quad term coefficient */
	char  fd2_const[16];		/* doppler centroid: constant */
	char  fd2_linear[16];		/*					linear term coefficient */
	char  fd2_quad[16];		 /*					quad term coefficient */
	char  fr0_const[16];		/* doppler rate: constant */
	char  fr0_linear[16];		/*				linear term coefficient */
	char  fr0_quad[16];		 /*				quad term coefficient */
	char  fr1_const[16];		/* doppler rate: constant */
	char  fr1_linear[16];		/*				linear term coefficient */
	char  fr1_quad[16];		 /*				quad term coefficient */
	char  fr2_const[16];		/* doppler rate: constant */
	char  fr2_linear[16];		/*				linear term coefficient */
	char  fr2_quad[16];		 /*				quad term coefficient */
	char  processing_date[11];  /* data processing date */
	char  roll_ang_est_avg[16]; /* average of roll angle estimates from
								 * null-line processing
								 */
	char  nr_rg_inc_angle[16];  /* near range incidence angle */
	char  far_rg_inc_angle[16]; /* far range incidence angle */
	char  az_ref_length[8];	 /* azimuth reference function length */
	char  signal_gain[16];	  /* signal processing gain */
	char  hh_caltone_phase[16]; /* HH caltone phase */
	char  hv_caltone_phase[16]; /* HV caltone phase */
	char  vv_caltone_phase[16]; /* VV caltone phase */
	char  vh_caltone_phase[16]; /* VH caltone phase */
	char  polarization[2];	  /* SIR-C internal polarization value
								 * 0:HH, 1:HV, 2:VV, 3:VH, 4:QUADPOL,
								 * 5:HHHV, 6:VVVH, 7:HHVV, 8:HHVH,
								 * 9:VVHV, 10:HVVH
								 */
	char sample_offset[8];	  /* offset to first processing range sample */
	char range_str_angle[16];	/* electronic steering angle */
	
	char spare2[2];			 /* padding */

} sarl_detailed_proc_t;



/****************************
*							*
*  SAR Leader File:		 *
*  Calibration Data Record  *
*							*
****************************/

typedef struct {
	hdr_t  hdr;				  /* header info */
	char  seq_no[4];			/* calibration rec sequence number */
	char  spare1[4];			/* spare */
	char  cal_coef[16];		 /* absolute calibration coefficient */
	char  chan_imbalance[16];	/* channel imbalance */
	char  phase_imbalance[16];  /* phase imbalance */
	char  matrix[32][22];		/* 4 x 4 polarimetric calibration matrix */
	char  spare2[4];			/* padding for word boundary */

} sarl_calibr_t;



/****************************
*							*
*  Imagery Options File	 *
*  File Descriptor Record	*
*							*
****************************/

typedef struct {
	hdr_t  hdr;				  /* header info */
	char  ascii_flag[2];		/* ASCII flag */
	char  spare1[2];			/* spare */
	char  doc_format[12];		/* control document */
	char  format_rev[2];		/* document revision ("$A", then "$B", etc. */
	char  rec_format_rev[2];	/* record format revision level */
	char  software_id[12];	  /* software ID */
	char  file_no[4];			/* file number */
	char  filename[16];		 /* filename */
	char  seq_flag[4];		  /* record sequence and location type flag */
	char  seq_location[8];	  /* sequence number location */
	char  seq_field_len[4];	 /* sequence number field length */
	char  code_flag[4];		 /* record code and location type flag */
	char  code_location[8];	 /* record code location */
	char  code_field_len[4];	/* record code field length */
	char  len_flag[4];		  /* record length and location type flag */
	char  len_location[8];	  /* record length location */
	char  len_field_len[4];	 /* record length field length */
	char  header_size[8];		/* bytes in signal data header */
	char  spare3[60];			/* spare */
	char  n_sar_recs[6];		/* number of SAR data records */
	char  sar_rec_len[6];		/* SAR data record length (bytes) */
	char  polarizations[24];	/* pol string: e.g. "HH HV VV VH" */
	char  bits_sample[4];		/* number of bits per sample/pixel */
	char  pixels_group[4];	  /* number of pixels per data group */
	char  bytes_group[4];		/* number of bytes per data group */
	char  spare5[4];			/* spare */
	char  sar_channels[4];	  /* number of SAR channels */
	char  n_lines[8];			/* number of lines per data set */
	char  left_pixels[4];		/* number of left border pixels per line */
	char  n_pixels[8];		  /* number of pixels per line */
	char  right_pixels[4];	  /* number of right border pixels */
	char  top_lines[4];		 /* number of top border scan lines */
	char  bottom_lines[4];	  /* number of bottom border scan lines */
	char  interleave[4];		/* interleaving indicator */
	char  recs_line[2];		 /* number of records per line */
	char  recs_channel[2];	  /* number of records per channel */
	char  prefix_len[4];		/* length of prefix data per line */
	char  bytes_line[8];		/* number of bytes per line */
	char  suffix_len[4];		/* length of suffix data per line */
	char  spare6[4];			/* spare */
	char  spare7[8];			/* spare */
	char  spare8[8];			/* spare */
	char  spare9[8];			/* spare */
	char  spare10[8];			/* spare */
	char  spare11[8];			/* spare */
	char  spare12[4];			/* spare */
	char  spare13[28];		  /* spare */
	char  spare14[8];			/* spare */
	char  spare15[8];			/* spare */
	char  spare16[8];			/* spare */
	char  spare17[8];			/* spare */
	char  sar_format[28];		/* SAR data format type indicator */
	char  spare18[4];			/* spare */
	char  n_left_fill[4];		/* number of left fill bits within pixel */
	char  n_right_fill[4];	  /* number of right fill bits within pixel */
	char  spare19[8];			/* spare */

	/* NOTE: This record is padded out with spaces until it is equal to
	* the length of the Image Data Record (or Signal Data Record).
	* The amount of padding necessary is calculated at run time.
	* See the source code for details (imgopts.c).
	*/

} img_descript_t;



/****************************
*							*
*  Imagery Options File	 *
*  RSD and Image Records	*
*							*
****************************/

typedef struct {
	hdr_t			  hdr;						/* header info */
	unsigned char	 img_line[MAX_LINE_LENGTH * MAX_BYTES_PER_PIXEL];

} img_record_t;



/****************************
*							*
*  SAR Trailer File		 *
*  File Descriptor Record	*
*							*
****************************/

typedef struct {
	hdr_t  hdr;				  /* header info */
	char  ascii_flag[2];		/* ASCII flag */
	char  spare1[2];			/* spare */
	char  doc_format[12];		/* document format */
	char  format_rev[2];		/* format revision ("A") */
	char  rec_format_rev[2];	/* record format revision level */
	char  software_id[12];	  /* software ID */
	char  file_no[4];			/* file number */
	char  filename[16];		 /* filename */
	char  seq_flag[4];		  /* record sequence and location type flag */
	char  seq_location[8];	  /* sequence number location */
	char  seq_field_len[4];	 /* sequence number field length */
	char  code_flag[4];		 /* record code and location type flag */
	char  code_location[8];	 /* record code location */
	char  code_field_len[4];	/* record code field length */
	char  len_flag[4];		  /* record length and location type flag */
	char  len_location[8];	  /* record length location */
	char  len_field_len[4];	 /* record length field length */
	char  spare2[1];			/* spare */
	char  spare3[1];			/* spare */
	char  spare4[1];			/* spare */
	char  spare5[64];			/* spare */
	char  n_data_set_recs[6];	/* number of data set summary records */
	char  len_data_set[6];	  /* record length */
	char  n_map_proj_recs[6];	/* number of map projection data records */
	char  len_map_proj[6];	  /* record length */
	char  n_platf_recs[6];	  /* number of platform position records */
	char  len_platf[6];		 /* record length */
	char  n_att_recs[6];		/* number of attitude data records */
	char  len_att[6];			/* record length */
	char  n_radio_recs[6];	  /* number of radiometric data records */
	char  len_radio[6];		 /* record length */
	char  n_radio_comp_recs[6]; /* number of radio compensation records */
	char  len_radio_comp[6];	/* record length */
	char  n_qual_recs[6];		/* number of data quality summary records */
	char  len_qual[6];		  /* record length */
	char  n_hist_recs[6];		/* number of data histogram records */
	char  len_hist[6];		  /* record length */
	char  n_spectra_recs[6];	/* number of range spectra records */
	char  len_spectra[6];		/* record length */
	char  n_elev_recs[6];		/* number of digital elevation model recs */
	char  len_elev[6];		  /* record length */
	char  n_update_recs[6];	 /* number of radar parameter update recs */
	char  len_update[6];		/* record length */
	char  n_annot_recs[6];	  /* number of annotation data records */
	char  len_annot[6];		 /* record length */
	char  n_proc_recs[6];		/* number of detailed processing records */
	char  len_proc[6];		  /* record length */
	char  n_calib_recs[6];	  /* number of calibration data records */
	char  len_calib[6];		 /* record length */
	char  n_ground[6];		  /* number of ground control pts records */
	char  len_ground[6];		/* record length */
	char  spare6[6];			/* spare */
	char  spare7[6];			/* spare */
	char  spare8[6];			/* spare */
	char  spare9[6];			/* spare */
	char  spare10[6];			/* spare */
	char  spare11[6];			/* spare */
	char  spare12[6];			/* spare */
	char  spare13[6];			/* spare */
	char  spare14[6];			/* spare */
	char  spare15[6];			/* spare */
	char  n_facil_recs[6];	  /* number of facility data records */
	char  len_facil[6];		 /* record length */
	char  spare16[288];		 /* spare */

} sart_descript_t;


	
/****************************
*							*
*  Null Volume Direct File  *
*  Volume Descriptor Record *
*							*
****************************/

typedef struct {
	hdr_t  hdr;				  /* header info */
	char  ascii_flag[2];		/* ASCII flag */
	char  spare1[2];			/* spare */
	char  doc_no[12];			/* control document number */
	char  doc_rev[2];			/* revision number (00-99) */
	char  design_rev[2];		/* file design revision number */
	char  software_id[12];	  /* software ID */
	char  tape_id[16];		  /* physical tape ID */
	char  logical_id[16];		/* logical set ID */
	char  volume_id[16];		/* volume set ID */
	char  n_volumes[2];		 /* number of physical volumes */
	char  first_seq[2];		 /* first physical vol sequence number */
	char  last_seq[2];		  /* last physical vol sequence number */
	char  this_seq[2];		  /* this physical vol number */
	char  first_ref_file[4];	/* first reference file in volume */
	char  log_vol[4];			/* logical volume in set */
	char  log_vol_phys[4];	  /* logical volume in physical volume */
	char  spare2[8];			/* spare */
	char  spare3[8];			/* spare */
	char  spare4[12];			/* spare */
	char  spare5[8];			/* spare */
	char  spare6[12];			/* spare */
	char  spare7[4];			/* spare */
	char  spare8[4];			/* spare */
	char  spare9[92];			/* spare */
	char  spare10[100];		 /* spare */

} null_descript_t;



/******************************************************************************
*																			 *
*				  Structures which define CEOS Data Files					*
*																			 *
******************************************************************************/


/***************************
*						  *
* Volume Directory File	*
*						  *
***************************/

struct vol_ptr_recs {
	vol_ptr_t				  sarl_ptr;
	vol_ptr_t				  img_ptr;
	vol_ptr_t				  sart_ptr;
	vol_text_t				 text;
};

typedef struct vol_ptr_recs vol_ptrs;


typedef struct {

	vol_descript_t			 descript;
	vol_ptrs					*ptrs_list; /* ptr to top of linked list */

} volume_file_t;



/***************************
*						  *
* SAR Leader File		  *
*						  *
***************************/

typedef struct {

	sarl_descript_t			descript;
	sarl_data_summary_t		data_set;
	sarl_map_proj_t			map_proj;
	sarl_platf_pos_t			platform;
	sarl_attitude_t			attitude;
	sarl_radio_t				radio[MAX_POLS];		/* one record per pol */
	sarl_radio_comp_t		  radio_comp[MAX_POLS];	/* one record per pol */
	sarl_data_qual_summary_t	data_qual[MAX_POLS];	/* one record per pol */
	sarl_histogram_t			histogram[MAX_POLS];	/* one record per pol */
	sarl_spectra_t			 spectra[MAX_POLS];	  /* one record per pol */
	sarl_param_upd_t			update[MAX_POLS + 1];	/* one DWP; upto 4 RG */
	sarl_detailed_proc_t		detailed;
	sarl_calibr_t			  calibration;

} sarl_file_t;



/***************************
*						  *
* Imagery Options File	 *
*						  *
***************************/

typedef struct {

	img_descript_t			 descript;
	img_record_t				*next;				  /* ptr to linked list */
	
} imgopt_file_t;



/***************************
*						  *
* SAR Trailer File		 *
*						  *
***************************/

/*
 * No structure definition is needed to define this file because 
 * the SAR Trailer file consists of only the file description
 * record (sart_descript_t).
 */




/******************************
*							 *
* Null Volume Descriptor File *
*							 *
******************************/

/*
 * No structure definition is needed because the Null Volume file
 * consists of only the file description record (null_descript_t).
 */


#endif /* OCEOS_H */




