/******************************************************************************

	File	 : sirc_header.h
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
* Module:	ceos_rd.h						Program:	SIR-C GDPS			*
*											Author:	P. Barrett			*
*											Initiated: 11-FEB-93			 *
*																			 *
* --------------------------------------------------------------------------- *
*																			 *
* Abstract:	 ceos_rd.c definitions										 *
*																			 *
* Description:  This file includes definitions and constants used by		  *
*				ceos_rd.c													 *
*																			 *
******************************************************************************/

#ifndef CEOS_RD_H
#define CEOS_RD_H

/* Miscellaneous */

#define SPACE			'\040'  /* ascii space character */

/******************************************************************************
*																			 *
*								Titles										*
*																			 *
******************************************************************************/


#define STARS1 "***************************************************"
#define STARS2 "*												 *"
#define DATAS1 "	*** Data Set"
#define DATAS2 "***"
#define TABLE1 "	*** Table Entry"
#define TABLE2 "***"


#define VOL_TITLE	 "*  Volume Directory File:"
#define SARL_TITLE	"*  SAR Leader File:"
#define IMG_TITLE	 "*  Imagery Options File:"
#define SART_TITLE	"*  SAR Trailer File:"
#define NULL_TITLE	"*  Null Volume Directory File:"

#define DESCR_REC	 "*  File Descriptor Record"
#define PTR_REC_SARL  "*  File Pointer Record: SAR Leader"
#define PTR_REC_IMG	"*  File Pointer Record: Imagery Options"
#define PTR_REC_SART  "*  File Pointer Record: SAR Trailer"
#define TEXT		  "*  Text Record"

#define DSS_REC		"*  Data Set Summary Record"
#define MAP_REC		"*  Map Projection Data Record"
#define PLATF_REC	 "*  Platform Position Record"
#define ATT_REC		"*  Attitude Data Record"
#define RADIO_REC	 "*  Radiometric Data Record"
#define RADIOC_REC	"*  Radiometric Compensation Record"
#define QUAL_REC	  "*  Data Quality Summary Record"
#define HIST_REC	  "*  Data Histograms Record"
#define SPECTRA_REC	"*  Range Spectra Record"
#define UPDATE_REC	"*  Radar Parameter Update Record"
#define DETAILED_REC  "*  Detailed Processing Parameter Record"
#define CALIB_REC	 "*  Calibration Data Record"


/* strings */

#define HH_STR	 "HH"
#define HV_STR	 "HV"
#define VV_STR	 "VV"
#define VH_STR	 "VH"


/* constants */

/*#define MAX_MISSING_PAIRS	 5*/  /* Max pairs of missing rg lines/chan */
#define NAME_LEN			 128	 /* short string length */
#define LONG_NAME_LEN		128	 /* long string length */
#define MAX_POLS				4	 /* max number of pols: HH, HV, VV, VH */
#define RSD					1	 /* RSD image data type */
#define non_RSD				2	 /* MLC, MLD, SLC image data type */

/* CEOS input filenames */

#define LDR_IN_FILE	 "pr%s_ldr_ceos"
#define IMG_IN_FILE	 "pr%s_img_ceos"
#define TLR_IN_FILE	 "pr%s_tlr_ceos"

/* CEOS output filenames */

#define LDR_OUT_FILE	"pr%s_ldr_ceos_ascii"
#define IMG_OUT_FILE	"pr%s_img_ceos_ascii"
#define TLR_OUT_FILE	"pr%s_tlr_ceos_ascii"
#define IMG_DISP_FILE	"pr%s_img_ceos_image"
#define RSD_DISP_FILE	"pr%s_rsd_ceos_"


/******************************************************************************
*																			 *
*							Text Fields									  *
*																			 *
******************************************************************************/

/* Common Header */

#define HDR_SEQ	 "Record Sequence Number:"
#define HDR_1SUB	"First Record Subtype Code:"
#define HDR_TYPE	"Record Type Code:"
#define HDR_2SUB	"Second Record Subtype Code:"
#define HDR_3SUB	"Third Record Subtype Code:"
#define HDR_LEN	 "Record Length:"

/* SAR Leader: File Descriptor Headers */

#define ASCII_FL	 "Data Format (A = ASCII):"
#define DOC_FORM	 "Format Control Document:"
#define FORM_REV	 "Format Control Document Version:"
#define REC_REV	  "Record Format Revision Level:"
#define FILE_NO	  "File Number:"
#define FILE_NAME	"File Name:"
#define FSEQ		 "Record Sequence and Location Type Flag:"
#define LOC_NO		"Sequence Number Location:"
#define SEQ_FLD_L	"Sequence Number Field Length:"
#define LOC_TYPE	 "Record Code and Location Type Flag:"
#define RCODE_LOC	"Record Code Location:"
#define RCODE_FLD_L  "Record Code Field Length:"
#define FLGT		 "Record Length and Location Type Flag:"
#define REC_LEN_LOC  "Record Length Location:"
#define REC_LEN_LEN  "Record Length Field Length:"
#define DS_FILE	  "Number of Data Set Summary Records:"
#define RECORD_LEN	"Record Length (bytes):"
#define MP_FILE	  "Number of Map Projection Records:"
#define PLATF_FILE	"Number of Platform Position Records:"
#define ATT_FILE	 "Number of Attitude Records:"
#define RADIO_FILE	"Number of Radiometric Data Records:"
#define RADIOC_FILE  "Number of Radiometric Compensation Records:"
#define QUAL_FILE	"Number of Data Quality Summary Records:"
#define HIST_FILE	"Number of Data Histogram Records:"
#define SPEC_FILE	"Number of Range Spectra Records:"
#define ELEV_FILE	"Number of Digital Elevation Model Records:"
#define UPD_FILE	 "Number of Radar Parameter Update Records:"
#define ANNOT_FILE	"Number of Annotation Data Records:"
#define PROC_FILE	"Number of Detailed Processing Records:"
#define CAL_FILE	 "Number of Calibration Data Records:"
#define GROUND_FILE  "Number of Ground Control Points Records:"
#define FAC_FILE	 "Number of Facility Data Records:"

/* SAR Leader: Data Set Summary Headers */

#define SEQ_NO		"Sequence Number:"
#define SAR_CHAN	 "SAR Channel Indicator:"
#define SITE_ID	  "Site ID:"
#define SITE_NAME	"Site Name:"
#define CTR_GMT	  "GMT, Image Center (YYYY/MM/DD hh:mm:ss.ttt):"
#define CTR_MET	  "MET, Image Center (DD hh:mm:ss.ttt):"
#define LAT_CTR	  "Geodetic Latitude at Image Center (deg):"
#define LONG_CTR	 "Geodetic Longitude at Image Center (deg):"
#define TRK_ANG_CTR  "Track Angle at Image Center (deg):"
#define ELLIPSE_NAME "Ellipsoid Designator:"
#define MAJOR_AXIS	"Ellipsoid Semimajor Axis (km):"
#define MINOR_AXIS	"Ellipsoid Semiminor Axis (km):"
#define TERR_HT	  "Average Terrain Height above Ellipsoid (m):"
#define CTR_LINE	 "Image Center Line Number:"
#define CTR_PIX	  "Image Center Pixel Number:"
#define IMG_LEN	  "Image Length (km):"
#define IMG_WID	  "Image Width (km):"
#define N_CHAN		"Number of SAR Polarization Channels:"
#define PLAT_ID	  "Sensor Platform Mission ID:"
#define SENSE_ID	 "Sensor ID:"
#define BAND		 "	SAR Band:"
#define RESOL		"	Resolution (HI = 20 MHz, LO = 10 MHz):"
#define ACQ		  "	Data Acquisition Mode (0 - 23):"
#define TX_POL		"	Transmit Polarization:"
#define RX_POL		"	Receive Polarization:"
#define DT_ID		"Datatake ID:"
#define CRAFT_LAT	"Platform Geodetic Latitude at Nadir (deg):"
#define CRAFT_LONG	"Platform Geodetic Longitude at Nadir (deg):"
#define PLAT_HD	  "Platform Heading at Nadir (deg):"
#define CLOCK_ANG	"Clock Angle (Left: -90, Right: +90) (deg):"
#define INC_ANGLE	"Incidence Angle at Image Center (deg):"
#define FREQ		 "Radar Frequency (GHz):"
#define WAVE_LEN	 "Radar Wavelength (m):"
#define MOTION		"Motion Compensation (00 = No Compensation):"
#define CD_SPEC	  "Range Pulse Code Specifier:"
#define CHIRP_FR	 "Range Chirp Start Frequency (MHz):"
#define CHIRP_RATE	"Range Chirp Rate (MHz / microsec):"
#define RG_SAMPL	 "Range Complex Sampling Rate (MHz):"
#define ECHO_DLAY	"One-Way Echo Delay Time (microsec):"
#define PULSE_LEN	"Range Pulse Duration (microsec):"
#define BAND_CONV	"Base Band Conversion ?:"
#define COMPR_FLAG	"Range Compressed ?:"
#define LIKE_GAIN	"Receiver Gain for Like Polarization (dB):"
#define CROSS_GAIN	"Receiver Gain for Cross Polarization (dB):"
#define Q_BITS		"Quantization in Bits per Channel:"
#define QUANT_DES	"Quantization Descriptor:"
#define ELECT_BORE	"Antenna Electronic Boresight (deg):"
#define MECH_BORE	"Antenna Mechanical Boresight (deg):"
#define ECHO_TRK	 "Echo Tracking:"
#define PRF		  "Nominal PRF (Hz):"
#define RG_BEAMW	 "Antenna Elevation 6 dB Beamwidth (deg):"
#define AZ_BEAMW	 "Antenna Azimuth 6 dB  Beamwidth (deg):"
#define HW_VERS	  "Hardware Version:"
#define SW_VERS	  "Software Version:"
#define JPL		  "Processing Facility:"
#define PROD_CODE	"Product Level Code:"
#define PROD_TYPE	"Product Type:"
#define PROC_ALG	 "Processing Algorithm:"
#define N_LOOKS	  "Total Number of Looks:"
#define AZ_BNDWTH	"Total Processor Azimuth Bandwidth (Hz):"
#define RG_BNDWTH	"Total Processor Range Bandwidth (MHz):"
#define AZ_WEIGHT	"Azimuth Weighting Function:"
#define RG_WEIGHT	"Range Weighting Function:"
#define HDDC		 "HDDC ID:"
#define RG_RES		"Nominal Range Resolution (m):"
#define AZ_RES		"Nominal Azimuth Resolution (m):"
#define GAIN		 "Processor Gain for Noise Data:"
#define BIAS		 "Linear Radiometric Conversion Factor:"
#define RG_TIME	  "Time Direction Indicator (Range):"
#define AZ_TIME	  "Time Direction Indicator (Azimuth):"
#define ELEC_DELAY	"Electronic Delay (RSD only) (microsec):"
#define LINE_CON	 "Line Content:"
#define CLUTTER	  "Clutter Lock Applied ?"
#define AUTOFOCUS	"Autofocussing Applied ?"
#define LINE_SP	  "Line Spacing (m):"
#define PIXEL_SP	 "Pixel Spacing (m):"
#define RG_COMPR	 "Processor Range Compression:"
#define ORBIT_DIR	"Orbit Direction:"
#define N_ANNOT	  "Number of Annotation Points:"

/* SAR Leader: Map Projection Headers */

#define MP_DESCR	 "Map Projection Descriptor:"
#define N_PIXELS	 "Number of Pixels per Image Line:"
#define N_LINES	  "Number of Image Lines:"
#define PL_DIST	  "Platform Distance at Image Center (km):"
#define ALTITUDE	 "Geodetic Altitude of Platform (km):"
#define SPEED		"Spacecraft Speed at Nadir (km/sec):"
#define NE_LAT		"Near Range Early Time Latitude (deg):"
#define NE_LONG	  "Near Range Early Time Longitude (deg):"
#define FE_LAT		"Far Range Early Time Latitude (deg):"
#define FE_LONG	  "Far Range Early Time Longitude (deg):"
#define FL_LAT		"Far Range Late Time Latitude (deg):"
#define FL_LONG	  "Far Range Late Time Longitude (deg):"
#define NL_LAT		"Near Range Late Time Latitude (deg):"
#define NL_LONG	  "Near Range Late Time Longitude (deg):"


/* SAR Leader: Platform Position Headers */

#define PLAT_YEAR	 "Year of First Point (YYYY):"
#define PLAT_MONTH	"Month of First Point (MM):"
#define PLAT_DAY	  "Day of First Point (DD):"
#define PLAT_DIY	  "Day of Year of First Point:"
#define PLAT_SID	  "Seconds in Day of First Point:"
#define PLAT_INT	  "Time Between Points (s):"
#define PLAT_COORD	"Reference Coordinate System:"
#define PLAT_HOUR	 "Mean Hour Angle (deg):"
#define PLAT_POSV	 "Position Vector (km):"
#define PLAT_VEL	  "Velocity Vector (km/sec):"
#define PLAT_XYZ	  "		x						y					 z"


/* SAR Leader: Attitude Data Headers */

#define ATT_DAYS	 "GMT Day of Year:"
#define ATT_SECS	 "GMT Millisecond of Day:"
#define ATT_PITCH	"Pitch from PATH tape (deg):"
#define ATT_ROLL	 "Roll Angle from PATH tape (deg):"
#define ATT_YAW	  "Yaw from PATH tape (deg):"


/* SAR Leader: Radiometric Data Headers */

#define N_SETS		"Number of Data Sets:"
#define DATA_ARRY_SZ "Size of Data Array (bytes):"
#define SET_SIZE	 "Data Set Size (bytes):"
#define BAND_POL	 "SAR Frequency/Polarization:"
#define N_SAMPLES	"Number of Samples:"
#define SMPL_TYPE	"Sample Type:"
#define NOISE_POW	"Raw Noise Power Est. (data number units):"
#define LCF		  "Linear Conversion Factor:"
#define OCF		  "Processor Noise Gain for Noise Data:"


/* SAR Leader: Radiometric Compensation Data Headers */

#define RC_TBL_SZ	"Size of Data Table (bytes):"
#define DESIGN		"Compensation Data Type Designator:"
#define DESCRIPT	 "Compensation Data Descriptor:"
#define REQ_REC	  "No. of Records Required to Compensate Table:"
#define TABLE_SEQ	"Sequence Number in Table:"
#define SUBSAMPLE	"Data Subsampling Factor:"
#define COMP1		"Range Index, 1st Table Value:"
#define COMP_LAST	"Range Index, Last Table Value:"
#define GROUP_SZ	 "Compensation Pixel Group Size:"
#define MIN_INDEX	"Minimum Sample Index:"
#define MIN_COMP	 "Minimum Radiometric Compensation Value:"
#define MAX_INDEX	"Maximum Sample Index:"
#define MAX_COMP	 "Maximum Radiometric Compensation Value:"
#define COMP_N_ENT	"Number of Compensation Table Entries:"
#define SMPL_INDEX	"Sample Index:"
#define SMPL_VALUE	"Sample Value:"




/* SAR Leader: Data Quality Summary Headers */

#define CAL_DATE	 "Nearest Calibration Update (YYMMDD):"
#define ISLR		 "Two-Dimensional ISLR (dB):"
#define PSLR		 "Two-Dimensional PSLR (dB):"
#define AZ_AMB		"Nominal Azimuth Ambiguity (dB):"
#define RG_AMB		"Nominal Range Ambiguity (dB):"
#define SNR_EST	  "SNR Estimate (from range spectra):"
#define BER		  "Bit Error Rate Estimate:"
#define SLANT_RES	"Nominal Slant Range Resolution (m):"
#define RADIO_RES	"Nominal Radiometric Resolution (dB):"
#define DYNAMIC	  "Instantaneous Dynamic Range (dB):"
#define ABS_RAD_UNC  "Abs. Radiometric Calibration Unc (dB):"
#define SHORT_UNC	"Rel. Short-Term Uncertainty vs HH (dB):"
#define PHASE_UNC	"Rel. Phase Calibration Unc vs HH (deg):"
#define LONG_UNC	 "Rel. Long-Term Calibr Unc vs HH (dB):"
#define SHORT_CL	 "Short-Term Freq-to-Freq Unc. CHH/LHH (dB):"
#define LONG_CL	  "Long-Term Freq-to-Freq Unc.  CHH/LHH (dB):"
#define ALOC_E		"Abs. Location Error Along Track (m):"
#define XLOC_E		"Abs. Location Error Cross Track (m):"
#define ASCALE_E	 "Geometric Scale Error Along Track:"
#define XSCALE_E	 "Geometric Scale Error Cross Track:"
#define SKEW_E		"Nominal Geometric Skew Error:"
#define ORIENT_E	 "Scene Orientation Error (deg):"
#define AREG_E		"Along Track Registration Err vs HH (m):"
#define XREG_E		"Cross Track Registration Err vs HH (m):"
#define AREG_CL_E	"Along Track Registration Err CHH/LHH (m):"
#define XREG_CL_E	"Cross Track Registration Err CHH/LHH (m):"


/* SAR Leader: Data Histograms Headers */

#define HIST_DESCR	"Histogram Descriptor:"
#define HIST_REQ	 "Records Req to Reconstitute Histogram Table:"
#define TABLE_NO	 "Sequence Number in Histogram Table:"
#define TABLE_SIZE	"Histogram Table Size (bytes):"
#define HIST_SAMP	"Number of Samples per Range Line:"
#define HIST_PIX	 "Number of Pixels per Image Line:"
#define HIST_RECS	"Number of Range Lines:"
#define HIST_LINES	"Number of Image Lines:"
#define CROSS_PIX	"Data Samples/Pixels per Group, Cross Track:"
#define ALONG_PIX	"Data Lines per Group, Along Track:"
#define CROSS_GPS	"Number of Groups, Cross Track:"
#define ALONG_GPS	"Number of Groups, Along Track:"
#define MIN_PIXEL	"Minimum Sample Value:"
#define MAX_PIXEL	"Maximum Sample Value:"
#define HIST_MEAN	"Mean Sample Value:"
#define HIST_ST_DEV  "Standard Deviation of Sample Value:"
#define INCREMENT	"Sample Value Increment:"
#define MIN_TABLE	"Minimum Histogram Table Value:"
#define MAX_TABLE	"Maximum Histogram Table Value:"
#define HIST_N_BINS  "Number of Bins:"


/* SAR Leader: Range Spectra Headers */

#define SP_REC_REQ	"Records Req to Reconstitute Spectra Table:"
#define SP_TBL_NO	"Sequence Number in Range Spectra Table:"
#define SP_SAMPS	 "Total Number of Samples in Range Direction:"
#define SP_PIX_OFF	"Number of Samples Offset from 1st Sample:"
#define SP_INT_LINES "No. of Range Lines Integrated for Spectra:"
#define FIRST_FREQ	"Center Frequency of First Spectra Bin (MHz):"
#define LAST_FREQ	"Center Frequency of Last Spectra Bin (MHz):"
#define SP_MINP	  "Minimum Spectral Power (dB):"
#define SP_MAXP	  "Maximum Spectra Power (dB):"
#define SP_N_BINS	"Number of Frequency Bins in Table:"
#define BIN_VALUES	"Bin	Values			Bin	  Values"


/* SAR Leader: Radar Parameter Update Headers */

#define UPD_GMT	  "GMT of Change (YYYYMMDD hhmm:ss.ttt):"
#define UPD_LINE_NO  "Radar Data Line Number of Update:"
#define UPD_PIXEL	"Radar Data Sample Number of Update:"
#define UPD_DESCR	"Parameter Descriptor:"
#define DWP_VALUE	"Parameter Value (microsecs):"
#define GAIN_VALUE	"Parameter Value (dB):"
#define RDR_DWP_STR  "DWP Update"
#define RDR_GAIN_STR "Receiver Gain Update"

/* SAR Leader: Detailed Processing Parameters Headers */

#define FLYWHL		"Number of Flywheels:"
#define MISSING	  "Missing Lines	 Start Frame			End Frame"
#define MISS_CH1	 "  Channel 1:"
#define MISS_CH2	 "  Channel 2:"
#define MISS_CH3	 "  Channel 3:"
#define MISS_CH4	 "  Channel 4:"
#define MORE_MISS	"  More Missing Lines?"
#define REFCALHH	 "Reference Caltone Gain Setting HH (dBmW):"
#define REFCALHV	 "Reference Caltone Gain Setting HV (dBmW):"
#define REFCALVV	 "Reference Caltone Gain Setting VV (dBmW):"
#define REFCALVH	 "Reference Caltone Gain Setting VH (dBmW):"
#define MEANCALHH	"Mean of Caltone Gain Estimates HH (dBmW):"
#define MEANCALHV	"Mean of Caltone Gain Estimates HV (dBmW):"
#define MEANCALVV	"Mean of Caltone Gain Estimates VV (dBmW):"
#define MEANCALVH	"Mean of Caltone Gain Estimates VH (dBmW):"
#define DEVCALHH	 "Std Deviation of Caltone Gain Est HH (dBmW):"
#define DEVCALHV	 "Std Deviation of Caltone Gain Est HV (dBmW):"
#define DEVCALVV	 "Std Deviation of Caltone Gain Est VV (dBmW):"
#define DEVCALVH	 "Std Deviation of Caltone Gain Est VH (dBmW):"
#define OVERSAT_HH	"Oversat in Raw Histogram HH (Mean %):"
#define OVERSAT_HV	"Oversat in Raw Histogram HV (Mean %):"
#define OVERSAT_VV	"Oversat in Raw Histogram VV (Mean %):"
#define OVERSAT_VH	"Oversat in Raw Histogram VH (Mean %):"
#define UNDERSAT_HH  "Undersat in Raw Histogram HH (Mean %):"
#define UNDERSAT_HV  "Undersat in Raw Histogram HV (Mean %):"
#define UNDERSAT_VV  "Undersat in Raw Histogram VV (Mean %):"
#define UNDERSAT_VH  "Undersat in Raw Histogram VH (Mean %):"
#define PROC_RUN	 "Processing Run Number:"
#define MISSION_ID	"Mission ID (Flight Number):"
#define BEAM_SPOIL	"Antenna Beam Spoiling Mode (0-7):"
#define START_GMT	"GMT, Image Start (YYYY/MM/DD hh:mm:ss.ttt):"
#define ST_GMT_SEC	"GMT, Image Start (s):"
#define IMAGE_DUR	"Image Duration (s):"
#define NEAR_SLANT	"Near Slant Range (km):"
#define CTR_RADIUS	"Earth Radius at Image Center (km):"
#define NADIR_RADIUS "Earth Radius at Nadir (km):"
#define YEAR_0MET	"GMT of 0 MET, Year:"
#define DAY_0MET	 "GMT of 0 MET, Days:"
#define HOUR_0MET	"GMT of 0 MET, Hours:"
#define MIN_OMET	 "GMT of 0 MET, Minutes:"
#define SEC_0MET	 "GMT of 0 MET, Seconds:"
#define DRIFT		"MET Drift Time (10**-6):"
#define FD0_CONST	"Fd0 Constant Term (Hz):"
#define FD0_LIN	  "Fd0 Linear Coefficient (10**-3 Hz):"
#define FD0_QUAD	 "Fd0 Quadratic Coefficient (10**-7 Hz):"
#define FD1_CONST	"Fd1 Constant Term (10**-3 Hz):"
#define FD1_LIN	  "Fd1 Linear Coefficient (10**-6 Hz):"
#define FD1_QUAD	 "Fd1 Quadratic Coefficient (10**-10 Hz):"
#define FD2_CONST	"Fd2 Constant Term (10**-7 Hz):"
#define FD2_LIN	  "Fd2 Linear Coefficient (10**-10 Hz):"
#define FD2_QUAD	 "Fd2 Quadratic Coefficient (10**-14 Hz):"
#define FR0_CONST	"Fr0 Constant Term (Hz/sec):"
#define FR0_LIN	  "Fr0 Linear Coefficient (10**-3 Hz/sec):"
#define FR0_QUAD	 "Fr0 Quadratic Coefficient (10**-7 Hz/sec):"
#define FR1_CONST	"Fr1 Constant Term (10**-3 Hz/sec):"
#define FR1_LIN	  "Fr1 Linear Coefficient (10**-6 Hz/sec):"
#define FR1_QUAD	 "Fr1 Quadratic Coefficient (10**-10 Hz/sec):"
#define FR2_CONST	"Fr2 Constant Term (10**-7 Hz/sec):"
#define FR2_LIN	  "Fr2 Linear Coefficient (10**-10 Hz/sec):"
#define FR2_QUAD	 "Fr2 Quadratic Coefficient (10**-14 Hz/sec):"
#define PROC_DATE	"Data Processing Date (MM-DD-YYYY):"
#define RAEST		"Average Roll Angle Estimates (deg):"
#define CHAN_IMB	 "Imbalance Between HH and VV (dB):"
#define PHASE_IMB	"Phase Error Between HH and VV (deg):"
#define NEAR_INC	 "Near Range Incidence Angle (deg):"
#define FAR_INC	  "Far Range Incidence Angle (deg):"
#define AZ_REF_LEN	"Az Ref Function Len at mid-swath (samples):"
#define SIG_GAIN	 "Signal Processing Gain:"
#define HH_PHASE	 "HH Caltone Phase Estimate (deg):"
#define HV_PHASE	 "HV Caltone Phase Estimate (deg):"
#define VV_PHASE	 "VV Caltone Phase Estimate (deg):"
#define VH_PHASE	 "VH Caltone Phase Estimate (deg):"
#define POLINDX	  "Internal SIR-C Polarization Index:"
#define SAMP_OFF	 "Offset to First Processing Range Sample:"
#define STEER_ANGLE  "Range Electronic Steering Angle (deg):"



/* Calibration Data Record Headers */
#define CAL_COEF	 "Absolute Calibration Coefficient (dB):"
#define MATRIX_TITLE "4x4 Polarimetric Calibration (Complex) Matrix:"
#define CAL_MAP1	 " 1	2	3	4"
#define CAL_MAP2	 " 5	6	7	8"
#define CAL_MAP3	 " 9  10  11  12"
#define CAL_MAP4	 "13  14  15  16"


/* Imagery Options File: File Descriptor Record Headers */
#define RSD_HDR_SIZE "Header bytes in RSD data product:"
#define N_SAR_RECS	"SAR Data Record Count:"
#define SAR_REC_LEN  "SAR Record Length (Bytes):"
#define POLAR_STR	"Image or RSD polarizations:"
#define BITS_SPAMP	"Bits Per Sample/Pixel (RSD & MLD Only):"
#define PIX_GP		"Pixels Per Data Group:"
#define BYTES_GP	 "Bytes Per Data Group:"
#define N_SAR_CHAN	"Number of SAR Polarization Channels:"
#define N_LINES_IMG  "Number of Image Lines this Channel:"
#define LEFT_BD_PIX  "Left Border Pixels per Line:"
#define N_PIX_LINE	"Samples/Pixels/Data Groups per Line:"
#define RIGHT_BD_PIX "Right Border Pixels per Line:"
#define TOP_LINES	"Top Border Scan Lines:"
#define BOTTOM_LINES "Bottom Border Scan Lines:"
#define INTERLEAVE	"Interleaving Indicator:"
#define RECS_LINE	"Physical Records Per Line:"
#define RECS_CHAN	"Physical Records Per Multi-Channel Line:"
#define LINE_PREFIX  "Length of Prefix Data per Line (Bytes):"
#define BYTES_LINE	"Bytes of Sample/Image Data per Line:"
#define LINE_SUFFIX  "Length of Suffix Data per Line (Bytes):"
#define SAR_FORMAT	"SAR Format Indicator:"
#define LT_PIX_FILL  "Left Fill Bits within Pixel:"
#define RT_PIX_FILL  "Right Fill Bits within Pixel:"

#endif /* CEOS_RD_H */

