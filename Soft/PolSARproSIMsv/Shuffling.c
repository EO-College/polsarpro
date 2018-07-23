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
 * Module      : Shuffling.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#include	"Shuffling.h"

/********************************/
/* Generation of tree locations */
/********************************/

double		tree_periodic_separation_2	(TreeDisc *pCn1, TreeDisc *pCn2, double Lx, double Ly)
{
 double		s2	= 0.0;
 double		sx	= pCn1->t.x - pCn2->t.x;
 double		sy	= pCn1->t.y - pCn2->t.y;

 if (sx < -Lx/2.0) {
  sx += Lx;
 } else {
  if (sx > Lx/2.0) {
   sx -= Lx;
  }
 }
 if (sy < -Ly/2.0) {
  sy += Ly;
 } else {
  if (sy > Ly/2.0) {
   sy -= Ly;
  }
 }
 s2		= sx*sx + sy*sy;
 return (s2);
}

double  tree_location_cost_function (double r2, double s2)
{
 double rinv2	 = s2/r2;
 double rinv6	= rinv2*rinv2*rinv2;
 double	cost	= rinv6*(rinv6-1.0);
 if (r2 < s2) {
  cost	= 10.0*TREE_LOCATION_NEAREST_NEIGHBOURS;
 }
 return (cost);
}

int	tree_location_min_sep	(int *pNNN, double *pNNS, int Nlist)
{
 int	k	= 0;
 int	m	= pNNN[0];
 double			r	= pNNS[0];
 int	n;

 for (n=0; n<Nlist; n++) {
  if (pNNS[n] < r) {
   m	= pNNN[n];
   r	= pNNS[n];
   k	= n;
  }
 }
 pNNN[k]	= pNNN[Nlist-1];
 pNNS[k]	= pNNS[Nlist-1];
 return (m);
}

void		Tree_Disc_Nearest_Neighbour		(TreeDisc *pTDL, int Nmax, 
											 double Lx, double Ly, double cost_radius)
{
 int		*nnn	= (int*) calloc (Nmax, sizeof (int));
 double		*nns	= (double*) calloc (Nmax, sizeof (double));
 int		i,j,k,m,n,nn;
 int		Nlist;
 double		r2;
 double		cost_d2	= 4.0*cost_radius*cost_radius;
 int		tlnn;

 tlnn		= TREE_LOCATION_NEAREST_NEIGHBOURS;
 if (tlnn > Nmax-1) {
  tlnn	= Nmax-1;
 }

 for (i=0; i<Nmax; i++) {
  k	 = 0;
  for (j=0; j<Nmax; j++) {
   if (i != j) {
    nns[k]	= tree_periodic_separation_2 (&(pTDL[i]), &(pTDL[j]), Lx, Ly);
    nnn[k]	= j;
	k++;
   }
  }
  Nlist	= Nmax - 1;
  for (m=0; m<tlnn; m++) {
   pTDL[i].nnlist[m]	 = tree_location_min_sep (nnn, nns, Nlist);
   Nlist				-= 1;
  }
 }
 for (n=0; n<Nmax; n++) {
  pTDL[n].cost	= 0.0;
  for (nn=0; nn<tlnn; nn++) {
   m	= pTDL[n].nnlist[nn];
   r2	= tree_periodic_separation_2 (&(pTDL[n]), &(pTDL[m]), Lx, Ly);
   pTDL[n].cost	+= tree_location_cost_function (r2, cost_d2);
  }
 }
 free (nnn);
 free (nns);
 return;
}

void		Tree_Disc_Shuffle		(TreeDisc *pTDL, int Nmax, 
									 double Lx, double Ly, double cost_radius, 
									 double temp_scale_factor)
{
 double			dx	= cost_radius/sqrt(2.0);
 double			dy	= cost_radius/sqrt(2.0);
 int			nn,n,m;
 double			r2;
 double			x,y,cost;
 double			deltax;
 double			deltay;
 double			dr2		= 4.0*cost_radius*cost_radius;
 double			drrms	= TREE_DISC_SHUFFLE_FACTOR*2.0*cost_radius*sqrt(1.0/12.0);
 double			rzero	= 2.0*cost_radius*pow (2.0, 1.0/6.0);
 double			rzpdr	= rzero + drrms;
 double			rzpdr2	= rzpdr*rzpdr;
 double			dcost	= tree_location_cost_function (rzpdr2, dr2)+0.25;
 double			temp0	= -TREE_DISC_TEMP_FACTOR*TREE_LOCATION_NEAREST_NEIGHBOURS*dcost/log(TREE_DISC_ACCEPTANCE_RATE);
 double			temp	= temp0*temp_scale_factor;
 double			cost_d2	= 4.0*cost_radius*cost_radius;

 dx	= sqrt((Lx*Ly)/Nmax)-2.0*cost_radius;
 dy	= sqrt((Lx*Ly)/Nmax)-2.0*cost_radius;

 for (n=0; n<Nmax; n++) {
  x				= pTDL[n].t.x;
  y				= pTDL[n].t.y;
  deltax		= TREE_DISC_SHUFFLE_FACTOR*dx*(drand()-0.5);
  deltay		= TREE_DISC_SHUFFLE_FACTOR*dy*(drand()-0.5);
  pTDL[n].t.x	+= deltax;
  pTDL[n].t.y	+= deltay;
  if (pTDL[n].t.x>Lx/2.0) {
	pTDL[n].t.x	-= Lx;
  } else {
   if (pTDL[n].t.x<-Lx/2.0) {
	pTDL[n].t.x	+= Lx;
   }
  }
  if (pTDL[n].t.y>Ly/2.0) {
	pTDL[n].t.y	-= Ly;
  } else {
   if (pTDL[n].t.y<-Ly/2.0) {
	pTDL[n].t.y	+= Ly;
   }
  }
  cost			= 0.0;
  for (nn=0; nn<TREE_LOCATION_NEAREST_NEIGHBOURS; nn++) {
   m	= pTDL[n].nnlist[nn];
   r2	= tree_periodic_separation_2 (&(pTDL[n]), &(pTDL[m]), Lx, Ly);
   cost	+= tree_location_cost_function (r2, cost_d2);
  }
  if (cost > 0.0) {
   /**********/
   /* REJECT */
   /**********/
   pTDL[n].t.x	-= deltax;
   pTDL[n].t.y	-= deltay;
  } else {
   if (cost > pTDL[n].cost) {
    if (drand()>exp((pTDL[n].cost-cost)/temp)) { 
     /**********/
     /* REJECT */
     /**********/
     pTDL[n].t.x	-= deltax;
     pTDL[n].t.y	-= deltay;
    } else {
     /**********/
     /* ACCEPT */
     /**********/
     pTDL[n].cost	= cost;
    }
   } else {
    /**********/
    /* ACCEPT */
    /**********/
    pTDL[n].cost	= cost;
   }
  }
 }
 return;
}

void		Tree_Location_Generation		(PolSARproSim_Record *pPR)
{
 double		Lx;
 double		Ly;
 int		nx;
 int		ny;
 int		Trees;
 double		deltax;
 double		deltay;
 double		mean_crown_radius;
 int		TDsize;
 TreeDisc	*TreeDiscList;
 int		iTree, jTree;
 int		ix, iy;
 double		x,y;
 double		a_max;
 double		a_x;
 double		a_y;
 double		a_shuffle;
 double		theta;
 double		cos_theta;
 double		sin_theta;
 double		xr, yr;
 double		Frad2;
 int		Stand_Number;
 double		Stand_Packing_Fraction;
 double		Requested_Packing_Fraction;
 TreeLoc	*New_Tree_Location;
 double		y_shift;
#ifndef NO_TREE_SHUFFLING 
 double		x_loop;
 int		iloop, jloop;
 double		temp_scale_factor;
#endif

/******************************************/
/* Report call if running in VERBOSE mode */
/******************************************/

#ifdef VERBOSE_POLSARPROSIM
 printf ("\n");
 printf ("Call to Tree_Location_Generation ... \n");
 printf ("\n");
#endif
 fprintf (pPR->pLogFile, "Call to Tree_Location_Generation ... \n");
 fflush  (pPR->pLogFile);

/******************/
/* Initialisation */
/******************/

 if (pPR->Lx > 3.0*pPR->Stand_Radius) {
  Lx				= 3.0*pPR->Stand_Radius;
 } else {
  Lx				= pPR->Lx;
 }
 if (pPR->Ly > 3.0*pPR->Stand_Radius) {
  Ly				= 3.0*pPR->Stand_Radius;
 } else {
  Ly				= pPR->Ly;
 }
 nx					= (int) ((double)pPR->nTreex*Lx/pPR->Lx);
 ny					= (int) ((double)pPR->nTreey*Ly/pPR->Ly);
 Trees				= nx*ny;
 deltax				= Lx/(double)nx;
 deltay				= Ly/(double)ny;
 mean_crown_radius	= pPR->mean_crown_radius;
 TDsize				= sizeof(TreeDisc);
 TreeDiscList		= (TreeDisc*) calloc (Trees, TDsize);
 theta				= DPI_RAD*TREE_DISC_ROTATION_ANGLE/180.0;
 cos_theta			= cos(theta);
 sin_theta			= sqrt(1.0-cos_theta*cos_theta);
 Frad2				= pPR->Stand_Radius*pPR->Stand_Radius;

/********************************/
/* Seed random number generator */
/********************************/

 srand (pPR->seed);

/******************************/
/* Initialise disc parameters */
/******************************/

 iTree	= 0;
 for (ix=0; ix<nx; ix++) {
  x	= ix*deltax - Lx/2.0 + deltax/2.0;
  for (iy=0; iy<ny; iy++) {
   y	= iy*deltay - Ly/2.0 + deltay/4.0;
   if ((ix-2*(ix/2))==0) {
    y	+= deltay/2.0;
   }
   y	= -y;
   TreeDiscList[iTree].t.x		= x;
   TreeDiscList[iTree].t.y		= y;
   TreeDiscList[iTree].t.height	= pPR->Tree_Location[iTree].height;
   TreeDiscList[iTree].t.radius	= pPR->Tree_Location[iTree].radius;
   iTree++;
  }
 }

/*********************************/
/* Output initial tree locations */
/*********************************/
/*
 fprintf (pPR->pLogFile, "\n");
 fprintf (pPR->pLogFile, "Initial tree locations ...\n");
 fprintf (pPR->pLogFile, "\n");
 iTree	= 0;
 for (ix=0; ix<nx; ix++) {
  for (iy=0; iy<ny; iy++) {
   fprintf (pPR->pLogFile, "%3d\t%10.3e\t%10.3e\t%10.3e\t%10.3e\n", iTree,	TreeDiscList[iTree].t.x, TreeDiscList[iTree].t.y, 
															TreeDiscList[iTree].t.height, TreeDiscList[iTree].t.radius);
   iTree++;
  }
 }
*/
 fprintf (pPR->pLogFile, "\n");
 fflush  (pPR->pLogFile);

/**********************************************/
/* Calculate the radius for the cost function */
/**********************************************/

 a_x		= 0.5*sqrt(deltax*deltax+deltay*deltay/4.0);
 a_y		= 0.5*deltay;
 if (a_y > a_x) {
  a_max	= a_x;
 } else {
  a_max	= a_y;
 }
 a_shuffle	= TREE_DISC_SHUFFLE_RADIUS_FACTOR*a_max;
 if (a_shuffle > mean_crown_radius) {
  a_shuffle	= mean_crown_radius;
 }

/*********************************************************/
/* Initialise nearest neighbour lists and cost functions */
/*********************************************************/

 Tree_Disc_Nearest_Neighbour (TreeDiscList, Trees, Lx, Ly, a_shuffle);

/*************************/
/* Perform the Shuffling */
/*************************/

#ifndef NO_TREE_SHUFFLING

 for (iloop=0; iloop<TREE_DISC_ILOOP_MAX; iloop++) {
  x_loop			= ((double)iloop)/(double)(TREE_DISC_ILOOP_MAX-1);
  temp_scale_factor	= 1.0/(1.0+TREE_DISC_TEMP_ALPHA*x_loop);
  for (jloop=0; jloop<TREE_DISC_JLOOP_MAX; jloop++) {
   Tree_Disc_Shuffle (TreeDiscList, Trees, Lx, Ly, a_shuffle, temp_scale_factor);
  }
  Tree_Disc_Nearest_Neighbour (TreeDiscList, Trees, Lx, Ly, a_shuffle);
 }

#endif

/*******************************************************************************/
/* Rotate the stand so that stem lines don't coincide with the range direction */
/*******************************************************************************/

 for (iTree=0; iTree < Trees; iTree++) {
  xr						= TreeDiscList[iTree].t.x;
  yr						= TreeDiscList[iTree].t.y;
  TreeDiscList[iTree].t.x	= cos_theta*xr + sin_theta*yr;
  TreeDiscList[iTree].t.y	= cos_theta*yr - sin_theta*xr;
 }

/************************************************************/
/* Count the number of trees within the forest stand radius */
/************************************************************/

 Stand_Number	= 0;
 for (iTree=0; iTree < Trees; iTree++) {
  xr	= TreeDiscList[iTree].t.x;
  yr	= TreeDiscList[iTree].t.y;
  if (xr*xr+yr*yr < Frad2) {
   Stand_Number++;
  }
 }
 Stand_Packing_Fraction		= Stand_Number*DPI_RAD*mean_crown_radius*mean_crown_radius/pPR->Stand_Area;
 Requested_Packing_Fraction	= pPR->req_trees_per_hectare*pPR->Hectares*DPI_RAD*mean_crown_radius*mean_crown_radius/pPR->Area;
 New_Tree_Location			= (TreeLoc*) calloc (Stand_Number, sizeof(TreeLoc));
 y_shift					= pPR->mean_crown_radius + pPR->Layover_Distance + pPR->Stand_Radius + pPR->Gap_Distance - pPR->Ly/2.0;
 jTree						= 0;
 for (iTree=0; iTree < Trees; iTree++) {
  xr	= TreeDiscList[iTree].t.x;
  yr	= TreeDiscList[iTree].t.y;
  if (xr*xr+yr*yr < Frad2) {
   /********************************************************/
   /* Shift stand slightly in range to accommodate layover */
   /********************************************************/
   New_Tree_Location[jTree].x		= xr;
   New_Tree_Location[jTree].y		= yr + y_shift;
   New_Tree_Location[jTree].height	= pPR->Tree_Location[iTree].height;
   New_Tree_Location[jTree].radius	= pPR->Tree_Location[iTree].radius;
   jTree++;
  }
 }
 free (pPR->Tree_Location);
 pPR->Tree_Location	= New_Tree_Location;
 pPR->Trees			= Stand_Number;

/*******************************************************************/
/* Note that the following will simply help to avoid crashes later */
/*******************************************************************/

 pPR->nTreey		= ny;
 pPR->nTreex		= Stand_Number / ny;

/*******************************/
/* Output final tree locations */
/*******************************/

 fprintf (pPR->pLogFile, "\n");
 fprintf (pPR->pLogFile, "Requested stand packing fraction: %10.3e\n", Requested_Packing_Fraction);
 fprintf (pPR->pLogFile, "Recovered stand packing fraction: %10.3e\n", Stand_Packing_Fraction);
 fprintf (pPR->pLogFile, "There are %d trees in a stand of radius %10.3em.\n", pPR->Trees, pPR->Stand_Radius);
 fprintf (pPR->pLogFile, "Final tree locations ...\n");
 fprintf (pPR->pLogFile, "\n");
 iTree	= 0;
 for (iTree=0; iTree < pPR->Trees; iTree++) {
   fprintf (pPR->pLogFile, "%3d\t%10.3e\t%10.3e\t%10.3e\t%10.3e\n", iTree,	pPR->Tree_Location[iTree].x, pPR->Tree_Location[iTree].y, 
															pPR->Tree_Location[iTree].height, pPR->Tree_Location[iTree].radius);
 }
 fprintf (pPR->pLogFile, "\n");
 fflush  (pPR->pLogFile);

/***********/
/* Tidy up */
/***********/

 free (TreeDiscList);

/******************************************/
/* Report call if running in VERBOSE mode */
/******************************************/

#ifdef VERBOSE_POLSARPROSIM
 printf ("\n");
 printf ("... Returning from call to Tree_Location_Generation\n");
 printf ("\n");
#endif
 fprintf (pPR->pLogFile, "... Returning from call to Tree_Location_Generation\n\n");
 fflush  (pPR->pLogFile);

 return;
}
