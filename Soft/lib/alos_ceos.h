/*******************************************************************************
PolSARpro v2.0 is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 (1991) of the License, or any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. 

See the GNU General Public License (Version 2, 1991) for more details.

*******************************************************************************

	File	 : also_ceos.h
	Project  : ESA_POLSARPRO
	Authors  : Eric POTTIER
	Version  : 1.0
	Creation : 08/2006
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
	e-mail : eric.pottier@univ-rennes1.fr
*-------------------------------------------------------------------------------
	Description :  ALOS CEOS Header File

	This file includes structure definitions used by alos_header.c

	This software is extracted and adapted from the SIR-C GDPS OPS ceos_rd.c software
	Copyright (c) 1993, California Institute of Technology. U.S.
	Government Sponsorship under NASA Contract NAS7-918 is acknowledged.
	Author:	P. Barrett, Initiated: 11-FEB-93

	The updates have been made according to the document:
	"ALOS/PALSAR Level 1 product - Format Description, vol2, level 1.1/1.5"
	Revision G, October 2005, JAXA, Earth Observation Researcg and Application Center

 ******************************************************************************/

#ifndef ALOS_CEOS_H
#define ALOS_CEOS_H

#ifdef ALOS_CEOS_READER
#include "alos_header.h"
#endif

/********************************************************************
*																	*
*				 Structures which define CEOS Data Records			*
*																	*
*********************************************************************/

/****************************************************
*													*
*					  Header						*
*													*
* ..the 12-byte preamble at the beginning of every	*
* CEOS data record.									*
*													*
****************************************************/

typedef struct {
	unsigned		record_seq_no;		/* record sequence number */
	unsigned char  first_rec_subtype;	/* first record subtype */
	unsigned char  record_type_code;	 /* record type code */
	unsigned char  second_rec_subtype;	/* second record subtype */
	unsigned char  third_rec_subtype;	/* third record subtype */
	unsigned		rec_length;			/* length of this record */
} hdr_t;

/********************************************************************
*																	*
*				  Structures which define Leader File				*
*																	*
********************************************************************/

/****************************
*							*
*  SAR Leader File:			*
*  File Descriptor Record	*
*							*
****************************/

typedef struct {
	hdr_t  hdr;					/* header info */
	char  ascii_flag[2];		/* ASCII flag */
	char  spare1[2];			/* spare */
	char  doc_format[12];		/* document format */
	char  format_rev[2];		/* format revision ("A") */
	char  rec_format_rev[2];	/* record format revision level */
	char  software_id[12];		/* software ID */
	char  file_no[4];			/* file number */
	char  filename[16];			/* filename */
	char  seq_flag[4];			/* record sequence and location type flag */
	char  seq_location[8];		/* sequence number location */
	char  seq_field_len[4];		/* sequence number field length */
	char  code_flag[4];			/* record code and location type flag */
	char  code_location[8];		/* record code location */
	char  code_field_len[4];	/* record code field length */
	char  len_flag[4];			/* record length and location type flag */
	char  len_location[8];		/* record length location */
	char  len_field_len[4];		/* record length field length */
	char  spare2[68];			/* spare */
	char  n_data_set_recs[6];	/* number of data set summary records */
	char  len_data_set[6];		/* record length */
	char  n_map_proj_recs[6];	/* number of map projection data records */
	char  len_map_proj[6];		/* record length */
	char  n_platf_recs[6];		/* number of platform position records */
	char  len_platf[6];			/* record length */
	char  n_att_recs[6];		/* number of attitude data records */
	char  len_att[6];			/* record length */
	char  n_radio_recs[6];		/* number of radiometric data records */
	char  len_radio[6];			/* record length */
	char  n_radio_comp_recs[6]; /* number of radio compensation records */
	char  len_radio_comp[6];	/* record length */
	char  n_qual_recs[6];		/* number of data quality summary records */
	char  len_qual[6];			/* record length */
	char  n_hist_recs[6];		/* number of data histogram records */
	char  len_hist[6];			/* record length */
	char  n_spectra_recs[6];	/* number of range spectra records */
	char  len_spectra[6];		/* record length */
	char  n_elev_recs[6];		/* number of digital elevation model recs */
	char  len_elev[6];			/* record length */
	char  n_update_recs[6];		/* number of radar parameter update recs */
	char  len_update[6];		/* record length */
	char  n_annot_recs[6];		/* number of annotation data records */
	char  len_annot[6];			/* record length */
	char  n_proc_recs[6];		/* number of detailed processing records */
	char  len_proc[6];			/* record length */
	char  n_calib_recs[6];		/* number of calibration data records */
	char  len_calib[6];			/* record length */
	char  n_ground[6];			/* number of ground control pts records */
	char  len_ground[6];		/* record length */
	char  spare3[6];			/* spare */
	char  spare4[6];			/* spare */
	char  spare5[6];			/* spare */
	char  spare6[6];			/* spare */
	char  spare7[6];			/* spare */
	char  spare8[6];			/* spare */
	char  spare9[6];			/* spare */
	char  spare10[6];			/* spare */
	char  spare11[6];			/* spare */
	char  spare12[6];			/* spare */
	char  n_facil_recs1[6];		/* number of facility data records #01 */
	char  len_facil1[8];		/* record length #01 */
	char  n_facil_recs2[6];		/* number of facility data records #02 */
	char  len_facil2[8];		/* record length #02 */
	char  n_facil_recs3[6];		/* number of facility data records #03 */
	char  len_facil3[8];		/* record length #03 */
	char  n_facil_recs4[6];		/* number of facility data records #04 */
	char  len_facil4[8];		/* record length #04 */
	char  n_facil_recs5[6];		/* number of facility data records #05 */
	char  len_facil5[8];		/* record length #05 */
	char  n_facil_recs6[6];		/* number of facility data records #06 */
	char  len_facil6[8];		/* record length #06 */
	char  n_facil_recs7[6];		/* number of facility data records #07 */
	char  len_facil7[8];		/* record length #07 */
	char  n_facil_recs8[6];		/* number of facility data records #08 */
	char  len_facil8[8];		/* record length #08 */
	char  n_facil_recs9[6];		/* number of facility data records #09 */
	char  len_facil9[8];		/* record length #09 */
	char  n_facil_recs10[6];	/* number of facility data records #10 */
	char  len_facil10[8];		/* record length #10 */
	char  n_facil_recs11[6];	/* number of facility data records #11 */
	char  len_facil11[8];		/* record length #11 */
	char  spare13[146];			/* spare */
} leader_descript_struct;

/****************************
*							*
*  SAR Leader File:			*
*  Data Set Summary Record	*
*							*
****************************/

typedef struct {
	char  sensid[6];			/* sensor identification */
	char  hyphen1[1];			/* hyphen */
	char  freq[2];				/* frequency band */
	char  hyphen2[1];			/* hyphen */
	char  res[2];				/* resolution mode: HI, LO, SUrvey */
	char  acq[2];				/* radar data acquisiton mode */
	char  hyphen3[1];			/* hyphen */
	char  tx[2];				/* transmit polarization */
	char  rx[2];				/* receive polarization */
	char  spare1[13];			/* pad structure to length 32 */
} sensor_id_t;

typedef struct {
	hdr_t  hdr;					/* header info */
	char  seq_no[4];			/* Data Set Summary: record sequence number */
	char  SAR_channel[4];		/* SAR channel indicator */
	char  site_id[32];			/* site ID (3-char ID) */
	char  site_name[16];		/* site name */
	char  center_GMT[32];		/* image center GMT: YYYYMMDDhhmmssttt */
	char  center_MET[16];		/* image center MET: DDhhmmssttt */
	char  lat_scene_ctr[16];	/* latitude at scene center */
	char  long_scene_ctr[16];	/* longitude at scene center */
	char  track_angle[16];		/* track angle at image center */
	char  ellipsoid_name[16];	/* ellipsoid designator */
	char  semimajor_axis[16];	/* ellipsoid semimajor axis (km) */
	char  semiminor_axis[16];	/* ellipsoid semiminor axis (km) */
	char  earth_mass[16];		/* Earth's mass */
	char  gravit_constant[16];	/* gravitational constant */
	char  ellipsoid_j2[16];		/* ellipsoid J2 parameters */
	char  ellipsoid_j3[16];		/* ellipsoid J3 parameters */
	char  ellipsoid_j4[16];		/* ellipsoid J4 parameters */
	char  spare2[16];			/* spare */
	char  terrain_ht[16];		/* average terrain height */
	char  center_line[8];		/* image center line number (azimuth) */
	char  center_pixel[8];		/* image center pixel number (range) */
	char  image_length_km[16];	/* image length in km */
	char  image_width_km[16];	/* image width in km */
	char  spare3[16];			/* spare */
	char  n_channels[4];		/* number of SAR channels */
	char  spare4[4];			/* spare */
	char  platform_id[16];		/* platform (shuttle) id */
	sensor_id_t  sensor_id;		/* sensor id: AAAAAA-BB-CCDD-EEFF */
	char  datatake_id[8];		/* datatake id */
	char  craft_lat[8];			/* spacecraft latitude at nadir */
	char  craft_long[8];		/* spacecraft longitude at nadir */
	char  platform_heading[8];  /* sensor platform heading (degrees) */
	char  clock_angle[8];		/* sensor clock angle rel to flight dir */
	char  incid_angle_ctr[8];	/* incidence angle at image center */
	char  spare5[8];			/* spare */
	char  wavelength[16];		/* radar wavelength (m) */
	char  motion_comp[2];		/* motion compensation indicator */
	char  rg_code_spec[16];		/* range pulse code specifier */
	char  rg_pulse_amp1[16];	/* range pulse amplitude coefficient #1 */
	char  rg_pulse_amp2[16];	/* range pulse amplitude coefficient #2 */
	char  rg_pulse_amp3[16];	/* range pulse amplitude coefficient #3 */
	char  rg_pulse_amp4[16];	/* range pulse amplitude coefficient #4 */
	char  rg_pulse_amp5[16];	/* range pulse amplitude coefficient #5 */
	char  rg_pulse_phase1[16];	/* range pulse phase coefficient #1 */
	char  rg_pulse_phase2[16];	/* range pulse phase coefficient #2 */
	char  rg_pulse_phase3[16];	/* range pulse phase coefficient #3 */
	char  rg_pulse_phase4[16];	/* range pulse phase coefficient #4 */
	char  rg_pulse_phase5[16];	/* range pulse phase coefficient #5 */
	char  down_link_index[8];	/* down linked data chirp extraction index */
	char  spare6[8];			/* spare */
	char  rg_sampling_rate[16];	/* range complex sampling rate */
	char  echo_delay[16];		/* range gate at early edge */
	char  rg_pulse_len[16];		/* range pulse length */
	char  base_band_conv[4];	/* base band conversion flag */
	char  rg_compressed[4];		/* range compressed flag */
	char  rcv_gain_like[16];	/* receiver gain for like pol */
	char  rcv_gain_cross[16];	/* receiver gain for cross pol */
	char  quant_bits[8];		/* quantization bits per channel */
	char  quant_descr[12];		/* quantizer description */
	char  dc_bias_i_comp[16];	/* DC bias I component */
	char  dc_bias_q_comp[16];	/* DC bias Q component */
	char  gain_imbalance[16];	/* gain imbalance I & Q components */
	char  spare7[16];			/* spare */
	char  spare8[16];			/* spare */
	char  elect_boresight[16];	/* electronic boresight */
	char  mech_boresight[16];	/* mechanical boresight */
	char  echo_tracker_flag[4];	/* echo tracker flag */
	char  prf[16];				/* nominal PRF */
	char  elev_beamwidth[16];	/* antenna elevation 3dB beam width */
	char  az_beamwidth[16];		/* antenna azimuth 3dB beam width */
	char  satellite_time[16];	/* satellite encoded binary time code */
	char  satellite_clock[32];	/* satellite clock time */
	char  satellite_incr[16];	/* satellite clock increment */
	char  proc_facility[16];	/* processing facility */
	char  hw_version[8];		/* processing h/w version */
	char  sw_version[8];		/* processor s/w version */
	char  process_code[16];		/* processing facility processor code */
	char  product_code[16];		/* product code */
	char  product_type[32];		/* product type */
	char  proc_algorithm[32];	/* processing algorithm */
	char  n_looks_az[16];		/* number of looks in azimuth*/
	char  n_looks_rg[16];		/* number of looks in range*/
	char  bandwidth_az[16];		/* bandwidth per look in azimuth */
	char  bandwidth_rg[16];		/* bandwidth per look in range */
	char  az_bandwidth[16];		/* processor bandwidth (azimuth) */
	char  rg_bandwidth[16];		/* processor bandwidth (range) */
	char  az_weighting[32];		/* weighting function (azimuth) */
	char  rg_weighting[32];		/* weighting function (range) */
	char  hddc_id[16];			/* HDDC id */
	char  rg_nom_res[16];		/* nominal resolution (range) */
	char  az_nom_res[16];		/* nominal resolution (azimuth) */
	char  bias[16];				/* bias */
	char  gain[16];				/* gain */
	char  along_Doppler_1[16];	/* along track Doppler frequency constant term */
	char  along_Doppler_2[16];	/* along track Doppler frequency linear term */
	char  along_Doppler_3[16];	/* along track Doppler frequency quadratic term */
	char  spare9[16];			/* spare */
	char  cross_Doppler_1[16];	/* cross track Doppler frequency constant term */
	char  cross_Doppler_2[16];	/* cross track Doppler frequency linear term */
	char  cross_Doppler_3[16];	/* cross track Doppler frequency quadratic term */
	char  rg_time_dir[8];		/* time direction (range) */
	char  az_time_dir[8];		/* time direction (azimuth) */
	char  along_Doppler_4[16];	/* along track Doppler frequency rate constant term */
	char  along_Doppler_5[16];	/* along track Doppler frequency rate linear term */
	char  along_Doppler_6[16];	/* along track Doppler frequency rate quadratic term */
	char  spare10[16];			/* spare */
	char  cross_Doppler_4[16];	/* cross track Doppler frequency rate constant term */
	char  cross_Doppler_5[16];	/* cross track Doppler frequency rate linear term */
	char  cross_Doppler_6[16];	/* cross track Doppler frequency rate quadratic term */
	char  spare11[16];			/* spare */
	char  line_content[8];		/* line content indicator */
	char  clutter_lock_flag[4];	/* clutter lock flag */
	char  autofocus_flag[4];	/* autofocussing flag */
	char  line_spacing[16];		/* line spacing (m) */
	char  pixel_spacing[16];	/* pixel spacing (m) */
	char  rg_compression[16];	/* range compression designator */
	char  Doppler_freq1[16];	/* Doppler center frequency constant term */
	char  Doppler_freq2[16];	/* Doppler center frequency linear term */
	char  calib_data[4];		/* calibration data indicator */
	char  calib_line1[8];		/* start line number of calibration at upper image */
	char  calib_line2[8];		/* stop line number of calibration at upper image */
	char  calib_line3[8];		/* start line number of calibration at bottom image */
	char  calib_line4[8];		/* stop line number of calibration at bottom image */
	char  prf_indicator[4];		/* PRF switching indicator */
	char  prf_line[8];			/* line locator of PRF switching */
	char  beam_center[16];		/* direction of a beam center in a scene center */
	char  yew_steering[4];		/* yew steering mode flag */
	char  para_number[4];		/* parameter table number of automatically setting */
	char  offnadir_angle[16];	/* nominal offnadir angle */
	char  beam_number[4];		/* antenna beam number */
	char  spare12[28];			/* spare */
	char  inc_angle_a0[20];		/* incidence angle constant term a0 */
	char  inc_angle_a1[20];		/* incidence angle linear term a1 */
	char  inc_angle_a2[20];		/* incidence angle quadratic term a2 */
	char  inc_angle_a3[20];		/* incidence angle cubic term a3 */
	char  inc_angle_a4[20];		/* incidence angle fourth term a4 */
	char  inc_angle_a5[20];		/* incidence angle fifth term a5 */
	char  annot_pts[8];			/* no. of annotation points in image */
	char  spare13[8];			/* spare */
	char  annot_line[8];		/* line number of 1st annotation start */
	char  annot_pixel[8];		/* pixel number of 1st annotation start */
	char  annot_text[16];		/* 1st annotation text */
	char  annot_text2[2016];	/* 2nd - 64th annotation text */
	char  spare14[2];			/* spare */
	char  spare15[24];			/* spare - system reserve */
} leader_data_summary_struct;

/****************************
*							*
*  SAR Leader File:			*
*  Map Projection Data Rec 	*
*							*
****************************/

typedef struct {
	hdr_t  hdr;					/* header info */
	char  spare1[16];			/* spare */
	char  map_proj_descr[32];	/* map projection descriptor */
	char  n_pixels[16];			/* number of pixels per line */
	char  n_lines[16];			/* number of image lines */
	char  pix_spacing[16];		/* pixel spacing (m) */
	char  line_spacing[16];		/* line spacing (m) */
	char  orientation[16];		/* orientation output scene */
	char  platform_incl[16];	/* platform inclinaison*/
	char  ascending_node[16];	/* ascending node */
	char  platform_dist[16];	/* platform distance */
	char  geodet_alt[16];		/* geodetic altitude */
	char  ground_speed[16];		/* ground speed at nadir */
	char  platform_heading[16];	/* platform heading */
	char  ellipsoid_name[32];	/* name of reference ellipsoid */
	char  semimajor_axis[16];	/* semimajor axis of ref ellipsoid */
	char  semiminor_axis[16];	/* semiminor axis of ref ellipsoid */
	char  datum_shift_para1[16];/* datum shift parameter referenced to Greenwith */
	char  datum_shift_para2[16];/* datum shift parameter perpendicular to Greenwith */
	char  datum_shift_para3[16];/* datum shift parameter direction of the rotation*/
	char  datum_shift_para4[16];/* additional datum shift parameter 1st rotation */
	char  datum_shift_para5[16];/* additional datum shift parameter 2nd rotation */
	char  datum_shift_para6[16];/* additional datum shift parameter 3rd rotation */
	char  scale_factor1[16];	/* scale factor of reference ellipsoid */
	char  map_projection[32];	/* map projection*/
	char  utm_descriptor[32];	/* UTM descriptor */
	char  utm_zone[4];			/* signature of the UTM zone */
	char  map_origin_fe1[16];	/* map origin (false easting) */
	char  map_origin_fn1[16];	/* map origin (false northing) */
	char  center_proj_long1[16];/* UTM center of projection longitude */
	char  center_proj_lat1[16];	/* UTM center of projection latitude */
	char  stand_para_1[16];		/* 1st standard parallel */
	char  stand_para_2[16];		/* 2nd standard parallel */
	char  scale_factor2[16];	/* UTM scale factor */
	char  ups_descriptor[32];	/* UPS descriptor */
	char  center_proj_long2[16];/* UPS center of projection longitude */
	char  center_proj_lat2[16]; /* UPS center of projection latitude */
	char  scale_factor3[16];	/* UPS scale factor */
	char  proj_desc[32];		/* projection descriptor */
	char  map_origin_fe2[16];	/* map origin (false easting) */
	char  map_origin_fn2[16];	/* map origin (false northing) */
	char  center_proj_long3[16];/* UTM center of projection longitude */
	char  center_proj_lat3[16];	/* UTM center of projection latitude */
	char  stand_para_3[16];		/* standard parallel */
	char  stand_para_4[16];		/* standard parallel */
	char  spare2[16];			/* spare */
	char  spare3[16];			/* spare */
	char  spare4[16];			/* spare */
	char  spare5[16];			/* spare */
	char  spare6[16];			/* spare */
	char  spare7[64];			/* spare */
	char  near_early_no[16];	/* near-early northing */
	char  near_early_ea[16];	/* near-early easting */
	char  far_early_no[16];		/* far-early northing */
	char  far_early_ea[16];		/* far_early easting */
	char  far_late_no[16];		/* far-late northing */
	char  far_late_ea[16];		/* far-late easting */
	char  near_late_no[16];		/* near-late northing */
	char  near_late_ea[16];		/* near-late easting */
	char  near_early_lat[16];	/* near-early latitude */
	char  near_early_long[16];	/* near-early longitude */
	char  far_early_lat[16];	/* far-early latitude */
	char  far_early_long[16];	/* far_early longitude */
	char  far_late_lat[16];		/* far-late latitude */
	char  far_late_long[16];	/* far-late longitude */
	char  near_late_lat[16];	/* near-late latitude */
	char  near_late_long[16];	/* near-late longitude */
	char  spare8[16];			/* spare */
	char  spare9[16];			/* spare */
	char  spare10[16];			/* spare */
	char  spare11[16];			/* spare */
	char  coeff_aij_1[20];		/* Eight coefficients: A11, A12, A13 ... A24 */
	char  coeff_aij_2[20];		/* Eight coefficients: A11, A12, A13 ... A24 */
	char  coeff_aij_3[20];		/* Eight coefficients: A11, A12, A13 ... A24 */
	char  coeff_aij_4[20];		/* Eight coefficients: A11, A12, A13 ... A24 */
	char  coeff_aij_5[20];		/* Eight coefficients: A11, A12, A13 ... A24 */
	char  coeff_aij_6[20];		/* Eight coefficients: A11, A12, A13 ... A24 */
	char  coeff_aij_7[20];		/* Eight coefficients: A11, A12, A13 ... A24 */
	char  coeff_aij_8[20];		/* Eight coefficients: A11, A12, A13 ... A24 */
	char  coeff_bij_1[20];		/* Eight coefficients: B11, B12, B13 ... B24 */
	char  coeff_bij_2[20];		/* Eight coefficients: B11, B12, B13 ... B24 */
	char  coeff_bij_3[20];		/* Eight coefficients: B11, B12, B13 ... B24 */
	char  coeff_bij_4[20];		/* Eight coefficients: B11, B12, B13 ... B24 */
	char  coeff_bij_5[20];		/* Eight coefficients: B11, B12, B13 ... B24 */
	char  coeff_bij_6[20];		/* Eight coefficients: B11, B12, B13 ... B24 */
	char  coeff_bij_7[20];		/* Eight coefficients: B11, B12, B13 ... B24 */
	char  coeff_bij_8[20];		/* Eight coefficients: B11, B12, B13 ... B24 */
	char  spare12[36];			/* spare */
} leader_map_proj_struct;

/****************************
*							*
*  SAR Leader File:			*
*  Platform Position Rec	*
*							*
****************************/

typedef struct {
	hdr_t  hdr;					/* header info */
	char  orbit_design[32];		/* orbital elements designator */
	char  orbital_elt1[16];		/* 1st orbital element (m) */
	char  orbital_elt2[16];		/* 2nd orbital element (m) */
	char  orbital_elt3[16];		/* 3rd orbital element (m) */
	char  orbital_elt4[16];		/* 4th orbital element (m) */
	char  orbital_elt5[16];		/* 5th orbital element (m) */
	char  orbital_elt6[16];		/* 6th orbital element (m) */
	char  n_data_sets[4];		/* number of data sets */
	char  year[4];				/* year of first data point */
	char  month[4];				/* month of first data point */
	char  day[4];				/* day of first data point */
	char  day_in_year[4];		/* day in year of first data point */
	char  sec_in_day[22];		/* seconds in day of first data point */
	char  interval[22];			/* time interval between data points (s) */
	char  coord_sys[64];		/* reference coordinate system */
	char  hour_angle[22];		/* GMT hour angle (degrees) */
	char  along_track_err1[16];	/* along track position error (m) */
	char  across_track_err1[16];/* across track position error (m) */
	char  radial_track_err1[16];/* radial track position error (m) */
	char  along_track_err2[16];	/* along track velocity error (m/s) */
	char  across_track_err2[16];/* across track velocity error (m/s) */
	char  radial_track_err2[16];/* radial track velocity error (m/s) */
	char  pos_vel_vec[28][6][22];/* (X,Y,Z) position and velocity vector of data points */
	char  spare1[18];			/* spare */
	char  occ_flag[1];			/* occurrence flag */
	char  spare2[579];			/* spare */
} leader_platf_pos_struct;

/****************************
*							*
*  SAR Leader File:			*
*  Attitude Data Record		*
*							*
****************************/

typedef struct {
	hdr_t  hdr;					/* header info */
	char  n_data_sets[4];		/* number of attitude data sets */
	char  attitude_data[62][120];/* attitude data points */
	char  spare1[736];			/* spare */
} leader_attitude_struct;

/****************************
*							*
*  SAR Leader File:			*
*  Radiometric Data Record  *
*							*
****************************/

typedef struct {
	hdr_t  hdr;					/* header info */
	char  seq_no[4];			/* radiometric data record seq number */
	char  n_data_sets[4];		/* number of radiometric data record fields */
	char  calib_factor[16];		/* calibration factor */
	char  dt11_real[16];		/* real part of transmit distorsion matrix DT(1,1) */
	char  dt11_imag[16];		/* imag part of transmit distorsion matrix DT(1,1) */
	char  dt12_real[16];		/* real part of transmit distorsion matrix DT(1,2) */
	char  dt12_imag[16];		/* imag part of transmit distorsion matrix DT(1,2) */
	char  dt21_real[16];		/* real part of transmit distorsion matrix DT(2,1) */
	char  dt21_imag[16];		/* imag part of transmit distorsion matrix DT(2,1) */
	char  dt22_real[16];		/* real part of transmit distorsion matrix DT(2,2) */
	char  dt22_imag[16];		/* imag part of transmit distorsion matrix DT(2,2) */
	char  dr11_real[16];		/* real part of receive distorsion matrix DT(1,1) */
	char  dr11_imag[16];		/* imag part of receive distorsion matrix DT(1,1) */
	char  dr12_real[16];		/* real part of receive distorsion matrix DT(1,2) */
	char  dr12_imag[16];		/* imag part of receive distorsion matrix DT(1,2) */
	char  dr21_real[16];		/* real part of receive distorsion matrix DT(2,1) */
	char  dr21_imag[16];		/* imag part of receive distorsion matrix DT(2,1) */
	char  dr22_real[16];		/* real part of receive distorsion matrix DT(2,2) */
	char  dr22_imag[16];		/* imag part of receive distorsion matrix DT(2,2) */
	char  spare1[9568];			/* spare */
} leader_radio_struct;

/****************************
*							*
*  SAR Leader File:			*
*  Data Quality Summary		*
*							*
****************************/

typedef struct {
	hdr_t  hdr;					/* header info */
	char  seq_no[4];			/* record sequence number */
	char  sar_channel[4];		/* sar channel indicator */
	char  calibr_date[6];		/* calibration date */
	char  n_channels[4];		/* number of channels */
	char  islr[16];				/* integrated side lobe ratio */
	char  pslr[16];				/* peak side lobe ratio */
	char  az_ambig[16];			/* azimuth ambiguity */
	char  rg_ambig[16];			/* range ambiguity */
	char  snr_est[16];			/* signal-to-noise ratio estimate */
	char  ber[16];				/* bit error rate */
	char  slant_rg_res[16];		/* nominal slant range resolution */
	char  az_res[16];			/* nominal azimuth resolution */
	char  radio_res[16];		/* nominal radiometric resolution */
	char  dynam_rg[16];			/* instantaneous dynamic range */
	char  abs_radio_unc[16];	/* absolute radio calibration uncertainty */
	char  pha_radio_unc[16];	/* phase radio calibration uncertainty */
	char  rad_pha_unc[32][16];	/* relative magnitude phase calibration uncertainty channel 1*/
	char  along_track_err[16];	/* absolute location error along track */
	char  across_track_err[16];	/* absolute location error across track */
	char  scale_line_err[16];	/* geometric distorsion scale in line direction */
	char  scale_pix_err[16];	/* geometric distorsion scale in pixel direction */
	char  skew_err[16];			/* geometric distorsion scew */
	char  scene_err[16];		/* scene orientation error */
	char  track_mis[32][16];	/* along - across track relative misregistration error channel 1 */
	char  spare[278];			/* spare */
} leader_data_qual_struct;

/****************************
*							*
*  SAR Leader File:			*
* Facility Data Record		*
*							*
****************************/

typedef struct {
	hdr_t  hdr;					/* header info */
	char  seq_no[4];			/* record sequence number */
	char  spare1[50];			/* spare */
} leader_facility_struct;

/****************************
*							*
*  SAR Leader File:			*
* Facility Data Record 11	*
*							*
****************************/

typedef struct {
	hdr_t  hdr;					/* header info */
	char  seq_no[4];			/* record sequence number */
	char  coefficient[20][20];	/* coefficients for map projection */
	char  calib_indic[4];		/* calibration indicator */
	char  start_line_up[8];		/* start line number of calibration at upper image */
	char  stop_line_up[8];		/* stop line number of calibration at upper image */
	char  start_line_bo[8];		/* start line number of calibration at bottom image */
	char  stop_line_bo[8];		/* stop line number of calibration at bottom image */
	char  prf_indic[4];			/* PRF switching indicator */
	char  prf_line[8];			/* line locator of PRF switching */
	char  sar_process_line[8];	/* SAR processing start line number */
	char  loss_lines[8];		/* number of loss lines */
	char  loss_lines_rg[8];		/* number of loss range lines */
	char  spare1[312];			/* spare */
	char  spare2[224];			/* spare */
} leader_facility11_struct;

/********************************************************************
*																	*
*				  Structures which define Imagery Options File		*
*																	*
********************************************************************/

/****************************
*							*
*  Imagery Options File		*
*  File Descriptor Record	*
*							*
****************************/

typedef struct {
	hdr_t  hdr;					/* header info */
	char  ascii_flag[2];		/* ASCII flag */
	char  spare1[2];			/* spare */
	char  doc_format[12];		/* control document */
	char  format_rev[2];		/* document revision ("$A", then "$B", etc. */
	char  rec_format_rev[2];	/* record format revision level */
	char  software_id[12];		/* software ID */
	char  file_no[4];			/* file number */
	char  filename[16];			/* filename */
	char  seq_flag[4];			/* record sequence and location type flag */
	char  seq_location[8];		/* sequence number location */
	char  seq_field_len[4];		/* sequence number field length */
	char  code_flag[4];			/* record code and location type flag */
	char  code_location[8];		/* record code location */
	char  code_field_len[4];	/* record code field length */
	char  len_flag[4];			/* record length and location type flag */
	char  len_location[8];		/* record length location */
	char  len_field_len[4];		/* record length field length */
	char  spare2[68];			/* spare */
	char  n_sar_recs[6];		/* number of SAR data records */
	char  sar_rec_len[6];		/* SAR data record length (bytes) */
	char  spare3[24];			/* spare */
	char  bits_sample[4];		/* number of bits per sample/pixel */
	char  pixels_group[4];		/* number of pixels per data group */
	char  bytes_group[4];		/* number of bytes per data group */
	char  spare4[4];			/* spare */
	char  sar_channels[4];		/* number of SAR channels */
	char  n_lines[8];			/* number of lines per data set */
	char  left_pixels[4];		/* number of left border pixels per line */
	char  n_pixels[8];			/* number of pixels per line */
	char  right_pixels[4];		/* number of right border pixels */
	char  top_lines[4];			/* number of top border scan lines */
	char  bottom_lines[4];		/* number of bottom border scan lines */
	char  interleave[4];		/* interleaving indicator */
	char  recs_line[2];			/* number of records per line */
	char  recs_channel[2];		/* number of records per channel */
	char  prefix_len[4];		/* length of prefix data per line */
	char  bytes_line[8];		/* number of bytes per line */
	char  suffix_len[4];		/* length of suffix data per line */
	char  prefix_flag[4];		/* prefix / suffix repeat flag */
	char  line_locator[8];		/* sample data line number locator */
	char  sar_locator[8];		/* SAR channel number locator */
	char  time_locator[8];		/* time of SAR data line locator */
	char  left_locator[8];		/* left-fill count locator */
	char  right_locator[8];		/* right-fill count locator */
	char  pad_pix[4];			/* pad pixels present indicator */
	char  spare5[28];			/* spare */
	char  data_locator[8];		/* SAR data line quality code locator */
	char  calib_locator[8];		/* calibration information field locator */
	char  gain_locator[8];		/* gain values field locator */
	char  bias_locator[8];		/* bias values field locator */
	char  sar_format[28];		/* SAR data format type indicator */
	char  sar_code[4];			/* SAR data format type code */
	char  n_left_fill[4];		/* number of left fill bits within pixel */
	char  n_right_fill[4];		/* number of right fill bits within pixel */
	char  max_range[8];			/* maximum data range of pixel */
	char  spare6[272];			/* spare */
} image_descript_struct;

/****************************
*							*
*  Imagery Options File		*
*  Signal Data Record		*
*							*
****************************/

typedef struct {
	hdr_t  hdr;					/* header info */
	unsigned  sar_line;			/* SAR image data line number */
	unsigned  sar_index;		/* SAR image data record index */
	unsigned  left_pix;			/* actual count of left-fill pixels */
	unsigned  data_pix;			/* actual count of data pixels */
	unsigned  right_pix;		/* actual count of right-fill pixels */
	unsigned  sensor_flag;		/* sensor parameters update flag */
	unsigned  sensor_year;		/* sensor acquisition year */
	unsigned  sensor_day;		/* sensor acquisition day of the year */
	unsigned  sensor_ms;		/* sensor acquisition milliseconds of day */
	short	 sar_channel;		/* SAR channel indicator */
	short	 sar_code;			/* SAR channel code */
	short	 t_pol;				/* transmitted polarization */
	short	 r_pol;				/* received polarization */
	unsigned  prf;				/* PRF (MHz) */
	unsigned  scan_id;			/* scan id for scan sar mode */
	short	 range_flag;		/* onboard range compressed flag */
	short	 chirp_des;			/* pulse (chirp) type designator */
	unsigned  chirp_len;		/* chirp lenght (ns) */
	unsigned  chirp_coeff1;		/* chirp constant coefficient (Hz) */
	unsigned  chirp_coeff2;		/* chirp linear coefficient (Hz/micro-s) */
	unsigned  chirp_coeff3;		/* chirp quadratic coefficient (Hz/micro-s^2) */
	char  spare1[8];			/* spare */
	unsigned  gain;				/* receiver gain (dB) */
	unsigned  line_flag;		/* nought line flag */
	unsigned  ant_squint1;		/* antenna squint angle (millionths of deg) */
	unsigned  ant_elev1;		/* antenna elevation angle from nadir (millionths of deg) */
	unsigned  ant_squint2;		/* antenna squint angle (millionths of deg) */
	unsigned  ant_elev2;		/* antenna elevation angle from nadir (millionths of deg) */
	unsigned  slant_data;		/* slant range to 1st data sample (m) */
	unsigned  data_wind;		/* data record window (ns) */
	char	  spare2[4];		/* spare */
	unsigned  platf_pos;		/* platform position parameters update flag */
	unsigned  platf_lat;		/* platform latitude (millionths of deg) */
	unsigned  platf_lon;		/* platform longitude (millionths of deg) */
	unsigned  platf_alt;		/* platform altitude (m) */
	unsigned  platf_speed;		/* platform ground speed (cm/s) */
	unsigned  platf_velx;		/* platform velocity X (cm/s) */
	unsigned  platf_vely;		/* platform velocity Y (cm/s) */
	unsigned  platf_velz;		/* platform velocity Z (cm/s) */
	unsigned  platf_accx;		/* platform acceleration X (cm/s^2) */
	unsigned  platf_accy;		/* platform acceleration Y (cm/s^2) */
	unsigned  platf_accz;		/* platform acceleration Z (cm/s^2) */
	unsigned  platf_track1;		/* platform track angle (millionths of deg) */
	unsigned  platf_track2;		/* platform track angle (millionths of deg) */
	unsigned  platf_pitch;		/* platform pitch angle (millionths of deg) */
	unsigned  platf_roll;		/* platform roll angle (millionths of deg) */
	unsigned  platf_yaw;		/* platform yaw angle (millionths of deg) */
	char  spare3[92];			/* spare */
	unsigned  counter;			/* counter of PALSAR frame */
	char  aux_data[100];		/* PALSAR auxiliary data */
} image_signal_struct;

/****************************
*							*
*  Imagery Options File		*
*  Processed Data Record	*
*							*
****************************/

typedef struct {
	hdr_t  hdr;					/* header info */
	unsigned  sar_line;			/* SAR image data line number */
	unsigned  sar_index;		/* SAR image data record index */
	unsigned  left_pix;			/* actual count of left-fill pixels */
	unsigned  data_pix;			/* actual count of data pixels */
	unsigned  right_pix;		/* actual count of right-fill pixels */
	unsigned  sensor_flag;		/* sensor parameters update flag */
	unsigned  sensor_year;		/* sensor acquisition year */
	unsigned  sensor_day;		/* sensor acquisition day of the year */
	unsigned  sensor_ms;		/* sensor acquisition milliseconds of day */
	short	 sar_channel;		/* SAR channel indicator */
	short	 sar_code;			/* SAR channel code */
	short	 t_pol;				/* transmitted polarization */
	short	 r_pol;				/* received polarization */
	unsigned  prf;				/* PRF (MHz) */
	unsigned  scan_id;			/* scan id for scan sar mode */
	unsigned  slant_1st;		/* slant range to 1st pixel */
	unsigned  slant_mid;		/* slant range to mid pixel */
	unsigned  slant_lst;		/* slant range to last pixel */
	unsigned  doppler_1st;		/* Doppler centroid value at 1st pixel */
	unsigned  doppler_mid;		/* Doppler centroid value at mid pixel */
	unsigned  doppler_lst;		/* Doppler centroid value at last pixel */
	unsigned  az_fm_1st;		/* azimuth FM rate of 1st pixel */
	unsigned  az_fm_mid;		/* azimuth FM rate of mid pixel */
	unsigned  az_fm_lst;		/* azimuth FM rate of last pixel */
	unsigned  look_angle;		/* look angle of nadir (millionths of deg) */
	unsigned  az_squint;		/* azimuth squint angle (millionths of deg) */
	unsigned  spare1[20];		/* spare */
	unsigned  geo_ref;			/* geographic ref. parameter update flag */
	unsigned  lat_1st;			/* latitude of 1st pixel */
	unsigned  lat_mid;			/* latitude of mid pixel */
	unsigned  lat_lst;			/* latitude of last pixel */
	unsigned  lon_1st;			/* longitude of 1st pixel */
	unsigned  lon_mid;			/* longitude of mid pixel */
	unsigned  lon_lst;			/* longitude of last pixel */
	unsigned  northing_1st;		/* northing of 1st pixel */
	char  spare2[4];			/* spare */
	unsigned  northing_lst;		/* northing of last pixel */
	unsigned  easting_1st;		/* easting of 1st pixel */
	char  spare3[4];			/* spare */
	unsigned  easting_lst;		/* easting of last pixel */
	unsigned  line_heading;		/* line heading */
} image_process_struct;

/********************************************************************
*																	*
*				  Structures which define trailer File				*
*																	*
********************************************************************/

/****************************
*							*
*  SAR Trailer File			*
*  File Descriptor Record	*
*							*
****************************/

typedef struct {
	hdr_t  hdr;					/* header info */
	char  ascii_flag[2];		/* ASCII flag */
	char  spare1[2];			/* spare */
	char  doc_format[12];		/* document format */
	char  format_rev[2];		/* format revision ("A") */
	char  rec_format_rev[2];	/* record format revision level */
	char  software_id[12];		/* software ID */
	char  file_no[4];			/* file number */
	char  filename[16];			/* filename */
	char  seq_flag[4];			/* record sequence and location type flag */
	char  seq_location[8];		/* sequence number location */
	char  seq_field_len[4];		/* sequence number field length */
	char  code_flag[4];			/* record code and location type flag */
	char  code_location[8];		/* record code location */
	char  code_field_len[4];	/* record code field length */
	char  len_flag[4];			/* record length and location type flag */
	char  len_location[8];		/* record length location */
	char  len_field_len[4];		/* record length field length */
	char  spare2[68];			/* spare */
	char  n_data_set_recs[6];	/* number of data set summary records */
	char  len_data_set[6];		/* record length */
	char  n_map_proj_recs[6];	/* number of map projection data records */
	char  len_map_proj[6];		/* record length */
	char  n_platf_recs[6];		/* number of platform position records */
	char  len_platf[6];			/* record length */
	char  n_att_recs[6];		/* number of attitude data records */
	char  len_att[6];			/* record length */
	char  n_radio_recs[6];		/* number of radiometric data records */
	char  len_radio[6];			/* record length */
	char  n_radio_comp_recs[6]; /* number of radio compensation records */
	char  len_radio_comp[6];	/* record length */
	char  n_qual_recs[6];		/* number of data quality summary records */
	char  len_qual[6];			/* record length */
	char  n_hist_recs[6];		/* number of data histogram records */
	char  len_hist[6];			/* record length */
	char  n_spectra_recs[6];	/* number of range spectra records */
	char  len_spectra[6];		/* record length */
	char  n_elev_recs[6];		/* number of digital elevation model recs */
	char  len_elev[6];			/* record length */
	char  n_update_recs[6];		/* number of radar parameter update recs */
	char  len_update[6];		/* record length */
	char  n_annot_recs[6];		/* number of annotation data records */
	char  len_annot[6];			/* record length */
	char  n_proc_recs[6];		/* number of detailed processing records */
	char  len_proc[6];			/* record length */
	char  n_calib_recs[6];		/* number of calibration data records */
	char  len_calib[6];			/* record length */
	char  n_ground[6];			/* number of ground control pts records */
	char  len_ground[6];		/* record length */
	char  spare3[60];			/* spare */
	char  n_facil_recs1[6];		/* number of facility data records #01 */
	char  len_facil1[8];		/* record length #01 */
	char  n_facil_recs2[6];		/* number of facility data records #02 */
	char  len_facil2[8];		/* record length #02 */
	char  n_facil_recs3[6];		/* number of facility data records #03 */
	char  len_facil3[8];		/* record length #03 */
	char  n_facil_recs4[6];		/* number of facility data records #04 */
	char  len_facil4[8];		/* record length #04 */
	char  n_facil_recs5[6];		/* number of facility data records #05 */
	char  len_facil5[8];		/* record length #05 */
	char  n_facil_recs6[6];		/* number of facility data records #06 */
	char  len_facil6[8];		/* record length #06 */
	char  n_facil_recs7[6];		/* number of facility data records #07 */
	char  len_facil7[8];		/* record length #07 */
	char  n_facil_recs8[6];		/* number of facility data records #08 */
	char  len_facil8[8];		/* record length #08 */
	char  n_facil_recs9[6];		/* number of facility data records #09 */
	char  len_facil9[8];		/* record length #09 */
	char  n_facil_recs10[6];	/* number of facility data records #10 */
	char  len_facil10[8];		/* record length #10 */
	char  n_facil_recs11[6];	/* number of facility data records #11 */
	char  len_facil11[8];		/* record length #11 */
	char  low_records[6];		/* number of low res. image data records */
	char  low_length[6];		/* low res. image data record length */
	char  low_pixels[6];		/* number of pixels of low res. image data */
	char  low_lines[6];			/* number of lines of low res. image data */
	char  low_bytes[6];			/* number of bytes per one sample of low res. image data */
	char  spare4[116];			/* spare */
} trailer_file_struct;

/********************************************************************
*																	*
*				  Structures which define CEOS Data Files			*
*																	*
********************************************************************/

/************************
*						*
* SAR Leader File		*
*						*
************************/

typedef struct {
	leader_descript_struct			descript;
	leader_data_summary_struct		data_set;
	leader_map_proj_struct			map_proj;
	leader_platf_pos_struct			platform;
	leader_attitude_struct			attitude;
	leader_radio_struct				radio;	
	leader_data_qual_struct			data_qual;
	leader_facility_struct			facility;
	leader_facility11_struct		facility11;
} leader_file_struct;

/****************************
*							*
* Imagery Options File		*
*							*
****************************/

typedef struct {
	image_descript_struct			descript;
	image_signal_struct				signal;
	image_process_struct			process;
} image_file_struct;


#endif /* ALOS_OCEOS_H */
