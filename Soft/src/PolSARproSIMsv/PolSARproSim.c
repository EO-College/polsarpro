/************************************************************************/
/*																		*/
/* PolSARproSim Version C1b  Forest Synthetic Aperture Radar Simulation	*/
/* Copyright (C) 2007 Mark L. Williams									*/
/*																		*/
/* This program is free software; you may redistribute it and/or		*/
/* modify it under the terms of the GNU General Public License			*/
/* as published by the Free Software Foundation; either version 2		*/
/* of the License, or (at your option) any later version.				*/
/*																		*/
/* This program is distributed in the hope that it will be useful,		*/
/* but WITHOUT ANY WARRANTY; without even the implied warranty of		*/
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.					*/
/* See the GNU General Public License for more details.					*/
/*																		*/
/* You should have received a copy of the GNU General Public License	*/
/* along with this program; if not, write to the Free Software			*/
/* Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,			*/
/* MA  02110-1301, USA. (http://www.gnu.org/copyleft/gpl.html)			*/
/*																		*/
/************************************************************************/
/*
 * Author      : Mark L. Williams
 * Module      : PolSARproSim.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 * Notes       : Coherent Forest SAR Simulation for PolSARPro.
 */
#include	"PolSARproSim.h"

int main(int argv, char *argc[])
{
/**************************************/
/* Miscellaneous variable definitions */
/**************************************/
 char					*passed_input_directory_plus_prefix;
 char					*passed_master_directory;
 char					*passed_slave_directory;
 char					*input_directory;
 char					*master_directory;
 char					*slave_directory;
#ifdef _WIN32
 const char				ddlim	= '\\';
#else 
 const char				ddlim	= '/';
#endif
 char					*prefix;
 int					n,nmax,i,ilen;
 char					*input_string;
 char					*output_string;
 char					*logfile_string;
 char					*call_string;
 FILE					*pCF;
/*********************/
/* The master record */
/*********************/
 PolSARproSim_Record		Master_Record;

/*******************************************/
/* Check command line argument list length */
/*******************************************/

 if (argv < 4) {
  printf ("Use:      PolSARproSim input_directory_plus_prefix master_directory slave_directory\n");
  exit (1);
 } else {
  passed_input_directory_plus_prefix			= argc[1];
  passed_master_directory						= argc[2];
  passed_slave_directory						= argc[3];
 }

/***********************/
/* Generate file names */
/***********************/

/***********************************************/
/* Parse string arguments for TCLTK convention */
/***********************************************/

 tcltk_parser	(passed_input_directory_plus_prefix);
 tcltk_parser	(passed_master_directory);
 tcltk_parser	(passed_slave_directory);

/***************************/
/* Extract filename prefix */
/***************************/

 i		= 0;
 nmax	= strlen (passed_input_directory_plus_prefix);
 for (n=0; n<nmax; n++) {
  if (passed_input_directory_plus_prefix[n] == ddlim) {
   i = n;
  }
 }
 ilen	= nmax - i;
 ilen++;
 prefix	= (char*) calloc (ilen, sizeof(char));
 strcpy (prefix, &(passed_input_directory_plus_prefix[i+1]));

/************************************************/
/* Extract delimiter terminated Input directory */
/************************************************/

 input_directory	= (char*) calloc (i+2, sizeof(char));
 strncat (input_directory, passed_input_directory_plus_prefix, i+1);
 input_directory[i+1]	= '\0';

/*************************************************/
/* Extract delimiter terminated Master directory */
/*************************************************/

 nmax	= strlen (passed_master_directory);
 if (passed_master_directory[nmax-1] == ddlim) {
  master_directory	= (char*) calloc (nmax+1, sizeof(char));
  strcpy  (master_directory, passed_master_directory);
 } else {
  master_directory	= (char*) calloc (nmax+2, sizeof(char));
  strcpy  (master_directory, passed_master_directory);
  master_directory[nmax]	= ddlim;
 }

/*************************************************/
/* Extract delimiter terminated Slave  directory */
/*************************************************/

 nmax	= strlen (passed_slave_directory);
 if (passed_slave_directory[nmax-1] == ddlim) {
  slave_directory	= (char*) calloc (nmax+1, sizeof(char));
  strcpy  (slave_directory, passed_slave_directory);
 } else {
  slave_directory	= (char*) calloc (nmax+2, sizeof(char));
  strcpy  (slave_directory, passed_slave_directory);
  slave_directory[nmax]	= ddlim;
 }

/************************/
/* Calculate file names */
/************************/

 input_string	= (char*) calloc (strlen(input_directory)+strlen(prefix)+6, sizeof(char));
 strcpy  (input_string, input_directory);
 strncat (input_string, prefix, strlen(prefix));
 strncat (input_string, ".sar", 4);
 output_string	= (char*) calloc (strlen(master_directory)+strlen(prefix)+6, sizeof(char));
 strcpy  (output_string, master_directory);
 strncat (output_string, prefix, strlen(prefix));
 strncat (output_string, ".out", 4);
 logfile_string	= (char*) calloc (strlen(master_directory)+strlen(prefix)+6, sizeof(char));
 strcpy  (logfile_string, master_directory);
 strncat (logfile_string, prefix, strlen(prefix));
 strncat (logfile_string, ".log", 4);
 Master_Record.pFilenamePrefix	= prefix;
 Master_Record.pInputDirectory	= input_directory;
 Master_Record.pMasterDirectory	= master_directory;
 Master_Record.pSlaveDirectory	= slave_directory;
 call_string	= (char*) calloc (strlen(master_directory)+strlen(prefix)+11, sizeof(char));
 strcpy  (call_string, master_directory);
 strncat (call_string, prefix, strlen(prefix));
 strncat (call_string, "_call.txt", 9);

/********************/
/* Report filenames */
/********************/

 if ((pCF = fopen(call_string, "w")) == NULL) {
  printf ("Unable to open call file %s.\n", call_string);
  return (!NO_POLSARPROSIM_ERRORS);
 } else {
  fprintf (pCF, "\nArguments:\n%s\n%s\n%s\n", argc[1], argc[2], argc[3]);
  fprintf (pCF, "\nInput_directory     %s\n", input_directory);
  fprintf (pCF, "\nMaster_directory    %s\n", master_directory);
  fprintf (pCF, "\nSlave_directory     %s\n", slave_directory);
  fprintf (pCF, "\nReading input from  %s\n", input_string);
  fprintf (pCF, "\nWriting output to   %s\n", output_string);
  fprintf (pCF, "\nWriting log to      %s\n\n", logfile_string);
  fclose (pCF);
 }

#ifdef VERBOSE_POLSARPROSIM
 printf ("\nArguments:\n%s\n%s\n%s\n", argc[1], argc[2], argc[3]);
 printf ("\nInput_directory     %s\n", input_directory);
 printf ("\nMaster_directory    %s\n", master_directory);
 printf ("\nSlave_directory     %s\n", slave_directory);
 printf ("\nReading input from  %s\n", input_string);
 printf ("\nWriting output to   %s\n", output_string);
 printf ("\nWriting log to      %s\n\n", logfile_string);
#endif

/********************************/
/* Attempt to open output files */
/********************************/

 if ((Master_Record.pOutputFile = fopen(output_string, "w")) == NULL) {
  printf ("Unable to open output file %s.\n", output_string);
  return (!NO_POLSARPROSIM_ERRORS);
 }
 if ((Master_Record.pLogFile = fopen(logfile_string, "w")) == NULL) {
  printf ("Unable to open log file %s.\n", logfile_string);
  return (!NO_POLSARPROSIM_ERRORS);
 }

/**********************/
/* The simulation ... */
/**********************/

 PolSARproSim_notice (Master_Record.pOutputFile);
 PolSARproSim_notice (Master_Record.pLogFile);
 fprintf (Master_Record.pOutputFile, "\nReading parameters from file %s.\n", input_string);
 fprintf (Master_Record.pLogFile,    "\nReading parameters from file %s.\n", input_string);
 fflush (Master_Record.pOutputFile);
 fflush (Master_Record.pLogFile);

/******************************/
/* Report compilation options */
/******************************/

 PolSARproSim_compile_options (Master_Record.pLogFile);

/**********************************************/
/* Report type sizes for consistency checking */
/**********************************************/

 Report_SIM_Type_Sizes (Master_Record.pLogFile);

/************************************************/
/* Read the input file to setup the simulations */
/************************************************/

 Input_PolSARproSim_Record (input_string, &Master_Record);

#ifdef POLSARPROSIM_MAX_PROGRESS
 PolSARproSim_indicate_progress (&Master_Record);
#endif

/****************************************************/
/* Stage 1: Create the 3D description of the forest */
/****************************************************/
/*************************************************************/
/* Generate ground height map on ground range - azimuth grid */
/*************************************************************/

 Create_SIM_Record				(&(Master_Record.Ground_Height));
 Ground_Surface_Generation		(&Master_Record);

#ifndef POLSARPROSIM_NOSIMOUTPUT
 Write_SIM_Record				(&(Master_Record.Ground_Height));
#endif

/****************************************************/
/* Generate tree stem position and height database. */
/****************************************************/

 if (Master_Record.species != POLSARPROSIM_HEDGE) {
  Tree_Location_Generation		(&Master_Record);
 }

/********************************/
/* Increment progress indicator */
/********************************/

 Master_Record.progress++;

/********************************/
/* Report progress if requested */
/********************************/

#ifdef POLSARPROSIM_MAX_PROGRESS
 PolSARproSim_indicate_progress (&Master_Record);
#endif

/**************************************************************************/
/* Create a graphic image of the forest from the perspective of the radar */
/**************************************************************************/

 Forest_Graphic					(&Master_Record);

/*************************************************************/
/* Stage 2: Calculate the electrical proprties of the forest */
/*************************************************************/

/*****************************************************/
/* Calculate the vegetation effective permittivities */
/*****************************************************/

 Effective_Permittivities		(&Master_Record);

/***************************************************/
/* Calculate the spatial attenuation look-up table */
/***************************************************/

 Attenuation_Map				(&Master_Record);

/*****************************************************/
/* Stage 3: Calculate the interferometric SAR images */
/*****************************************************/

 for (Master_Record.current_track = 0; Master_Record.current_track < Master_Record.Tracks; Master_Record.current_track++) {
  /*************************************************************/
  /* Initialise the current SAR image variables for this track */
  /*************************************************************/
  Destroy_SAR_Images					(&Master_Record);
  /***********************************************************************************/
  /* Calculate filenames based on track number and directory architecture convention */
  /***********************************************************************************/
#ifndef POLSARPRO_CONVENTION
  Create_SAR_Filenames					(&Master_Record, master_directory, slave_directory, prefix);
#else
  Create_SAR_Filenames					(&Master_Record, master_directory, slave_directory);
#endif
  /**********************************/
  /* Initialise SAR image variables */
  /**********************************/
  Clean_SAR_Images						(&Master_Record);
  /********************************************/
  /* Calculate the direct ground contribution */
  /********************************************/
  PolSARproSim_Direct_Ground			(&Master_Record);
  /***************************************/
  /* Stage 3 testing of individual terms */
  /***************************************/
#ifdef POLSARPROSIM_STAGE3
  Clean_SAR_Images						(&Master_Record);
#endif
  /***********************************************/
  /* Calculate the short vegetation contribution */
  /***********************************************/
  PolSARproSim_Short_Vegetation_Direct	(&Master_Record);
  PolSARproSim_Short_Vegetation_Bounce	(&Master_Record);
  /*************************************/
  /* Calculate the volume contribution */
  /*************************************/
 // PolSARproSim_Forest_Direct			(&Master_Record);
 // PolSARproSim_Forest_Bounce			(&Master_Record);
  /****************************************/
  /* Optional flat earth phase correction */
  /****************************************/
#ifdef	POLSARPROSIM_FLATEARTH
  Flat_Earth_Phase_Removal				(&Master_Record);
#endif
  /****************************************/
  /* Output the SAR images for this track */
  /****************************************/
  Write_SAR_Images						(&Master_Record);
 }

/***************/
/* End of Main */
/***************/

 free	(input_string);
 free	(output_string);
 free	(logfile_string);
 free   (call_string);
 fclose (Master_Record.pOutputFile);
 fclose (Master_Record.pLogFile);

 return (NO_POLSARPROSIM_ERRORS);
}
