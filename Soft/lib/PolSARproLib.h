/***********************************************************************
PolSARpro v4.0 is free software; you can redistribute it and/or modify 
it under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2 (1991) of the License, or any
later version. This program is distributed in the hope that it will be 
useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 

See the GNU General Public License (Version 2, 1991) for more details.

************************************************************************

	File	 : PolSARproLib.h
	Project  : ESA_POLSARPRO
	Authors  : Eric POTTIER
	Version  : 1.0
	Creation : 08/2010
	Update	: 

*-----------------------------------------------------------------------
INSTITUT D'ELECTRONIQUE et de TELECOMMUNICATIONS de RENNES (I.E.T.R)
UMR CNRS 6164

Image and Remote Sensing Group
SAPHIR Team (SAr Polarimetry Holography Interferometry Radargrammetry)

UNIVERSITY OF RENNES I
Bât. 11D - Campus de Beaulieu
263 Avenue Général Leclerc
35042 RENNES Cedex
Tel :(+33) 2 23 23 57 63
Fax :(+33) 2 23 23 69 63
e-mail:eric.pottier@univ-rennes1.fr, laurent.ferro-famil@univ-rennes1.fr
*-----------------------------------------------------------------------

	Description :  PolSARpro Routines

*-----------------------------------------------------------------------
	
***********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* ROUTINES DECLARATION */
#include "util.h"
#include "util_block.h"
#include "util_convert.h"
#include "graphics.h"
#include "matrix.h"
#include "processing.h"
#include "statistics.h"
#include "sub_aperture.h"
#include "my_utils.h"

