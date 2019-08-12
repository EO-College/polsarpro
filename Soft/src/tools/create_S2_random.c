#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "omp.h"

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* ALIASES  */

/* S matrix */
#define s11  0
#define s12  1
#define s21  2
#define s22  3

/* CONSTANTS  */
#define Npolar  4

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"

void speckle(float ***bbg);

int main(int argc, char *argv[])
{

/* LOCAL VARIABLES */

/* Input/Output file pointer arrays */
  FILE *out_file[16];


/* Strings */
  char file_name[FilePathLength], out_dir[FilePathLength];
  char *file_name_in_out[4] =
  { "s11.bin", "s12.bin", "s21.bin", "s22.bin" };

/* Input variables */
  int Nlig, Ncol, N;

/* Internal variables */
  int i, j, np, nd;
  int ii, jj;
  float re, im;
  
  int gg;
  float u,k;
  float moy, std;

/* Matrix arrays */
  float ***M_out;
  float **bbg;
  
/* PROGRAM START */

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

  Nlig = 1000; Ncol = Nlig;

/* MATRIX DECLARATION */
  M_out = matrix3d_float(Npolar, Nlig, 2 * Ncol);
  bbg = matrix_float(Npolar, 2);

  for (nd = 0; nd < 10; nd++) {

  sprintf(out_dir, "C:/A4_dir%i",nd);
  check_dir(out_dir);

/* INPUT/OUTPUT FILE OPENING*/
  for (np = 0; np < Npolar; np++) {
    sprintf(file_name, "%s%s", out_dir, file_name_in_out[np]);
    if ((out_file[np] = fopen(file_name, "wb")) == NULL)
      edit_error("Could not open output file : ", file_name);
  }

printf("\nFin Input/output files\n");

/* RADIOMETRY */

  for (i = 0; i < Nlig/2; i++) {
    for (j = 0; j < Ncol/2; j++) {
      M_out[s11][i][2 * j] = 0.02621*cos(0.00951); M_out[s11][i][2 * j + 1] = 0.02621*sin(0.00951);
      M_out[s12][i][2 * j] = 0.01138*cos(-0.02710); M_out[s12][i][2 * j + 1] = 0.01138*sin(-0.02710);
      M_out[s21][i][2 * j] = 0.01138*cos(-0.02710); M_out[s21][i][2 * j + 1] = 0.01138*sin(-0.02710);
      M_out[s22][i][2 * j] = 0.02778*cos(0.03635); M_out[s22][i][2 * j + 1] = 0.02778*sin(0.03635);

      M_out[s11][i+Nlig/2][2 * j] = 0.06451*cos(-0.03286); M_out[s11][i+Nlig/2][2 * j + 1] = 0.06451*sin(-0.03286);
      M_out[s12][i+Nlig/2][2 * j] = 0.02777*cos(-0.04596); M_out[s12][i+Nlig/2][2 * j + 1] = 0.02777*sin(-0.04596);
      M_out[s21][i+Nlig/2][2 * j] = 0.02777*cos(-0.04596); M_out[s21][i+Nlig/2][2 * j + 1] = 0.02777*sin(-0.04596);
      M_out[s22][i+Nlig/2][2 * j] = 0.05053*cos(0.01615); M_out[s22][i+Nlig/2][2 * j + 1] = 0.05053*sin(0.01615);

      M_out[s11][i][2 * (j+Ncol/2)] = 0.04907*cos(-0.02465); M_out[s11][i][2 * (j+Ncol/2) + 1] = 0.04907*sin(-0.02465);
      M_out[s12][i][2 * (j+Ncol/2)] = 0.02292*cos(0.00021); M_out[s12][i][2 * (j+Ncol/2) + 1] = 0.02292*sin(0.00021);
      M_out[s21][i][2 * (j+Ncol/2)] = 0.02292*cos(0.00021); M_out[s21][i][2 * (j+Ncol/2) + 1] = 0.02292*sin(0.00021);
      M_out[s22][i][2 * (j+Ncol/2)] = 0.05051*cos(-0.06073); M_out[s22][i][2 * (j+Ncol/2) + 1] = 0.05051*sin(-0.06073);

      M_out[s11][i+Nlig/2][2 * (j+Ncol/2)] = 0.02321*cos(0.00097); M_out[s11][i+Nlig/2][2 * (j+Ncol/2) + 1] = 0.02321*sin(0.00097);
      M_out[s12][i+Nlig/2][2 * (j+Ncol/2)] = 0.00994*cos(0.02253); M_out[s12][i+Nlig/2][2 * (j+Ncol/2) + 1] = 0.00994*sin(0.02253);
      M_out[s21][i+Nlig/2][2 * (j+Ncol/2)] = 0.00994*cos(0.02253); M_out[s21][i+Nlig/2][2 * (j+Ncol/2) + 1] = 0.00994*sin(0.02253);
      M_out[s22][i+Nlig/2][2 * (j+Ncol/2)] = 0.02957*cos(0.03265); M_out[s22][i+Nlig/2][2 * (j+Ncol/2) + 1] = 0.02957*sin(0.03265);
      }
    }
printf("\nFin Radio\n");


/* SPECKLE */


  for (i = 0; i < Nlig; i++) {
    for (j = 0; j < Ncol; j++) {

moy = 0.;
std = 0.5;
for (np = 0; np < Npolar; np++) {
  bbg[np][0] = 0.;
  for (ii = 0; ii < 2; ii++) {
    while (fabs(bbg[np][ii]) < 1.E-25) {
      u = 0.;
      for (gg = 1; gg <= 12; gg++) {
        k = (float)(rand());
        u += (float)(k/32768.);
        }
      u = (float)(std*(u-6.)+moy);
      bbg[np][ii] = u;
      }
    }
  }

      re = M_out[s11][i][2*j]*bbg[s11][0]-M_out[s11][i][2*j+1]*bbg[s11][1];
      im = M_out[s11][i][2*j]*bbg[s11][1]+M_out[s11][i][2*j+1]*bbg[s11][0];
      M_out[s11][i][2*j] = re; M_out[s11][i][2*j+1] = im;
      re = M_out[s12][i][2*j]*bbg[s12][0]-M_out[s12][i][2*j+1]*bbg[s12][1];
      im = M_out[s12][i][2*j]*bbg[s12][1]+M_out[s12][i][2*j+1]*bbg[s12][0];
      M_out[s12][i][2*j] = re; M_out[s12][i][2*j+1] = im;
      re = M_out[s21][i][2*j]*bbg[s21][0]-M_out[s21][i][2*j+1]*bbg[s21][1];
      im = M_out[s21][i][2*j]*bbg[s21][1]+M_out[s21][i][2*j+1]*bbg[s21][0];
      M_out[s21][i][2*j] = re; M_out[s21][i][2*j+1] = im;
      re = M_out[s22][i][2*j]*bbg[s22][0]-M_out[s22][i][2*j+1]*bbg[s22][1];
      im = M_out[s22][i][2*j]*bbg[s22][1]+M_out[s22][i][2*j+1]*bbg[s22][0];
      M_out[s22][i][2*j] = re; M_out[s22][i][2*j+1] = im;
      }
    }
printf("\nFin Speckle\n");
    
/* ZONE ZERO */

  N = Nlig;
  for (i = 0; i < N/2; i++) {
    for (j = 0; j < N/2 - i; j++) {
      for (np = 0; np < Npolar; np++) M_out[np][i][2*j] = 0.;
      for (np = 0; np < Npolar; np++) M_out[np][i][2*j+1] = 0.;
      }
    for (j = N/2 + i; j < N; j++) {
      for (np = 0; np < Npolar; np++) M_out[np][i][2*j] = 0.;
      for (np = 0; np < Npolar; np++) M_out[np][i][2*j+1] = 0.;
      }
    }
  for (i = N/2; i < N; i++) {
    for (j = 0; j < i - N/2 + 1; j++) {
      for (np = 0; np < Npolar; np++) M_out[np][i][2*j] = 0.;
      for (np = 0; np < Npolar; np++) M_out[np][i][2*j+1] = 0.;
      }
    for (j = 3*N/2 - 1 - i; j < N; j++) {
      for (np = 0; np < Npolar; np++) M_out[np][i][2*j] = 0.;
      for (np = 0; np < Npolar; np++) M_out[np][i][2*j+1] = 0.;
      }
    }

printf("\nFin Zero\n");

    
/* ZONE TARGET */
for (ii = -1; ii <= 1; ii++) {
 jj = 0;
 
// Sphere (0,0)
  i = 500+ii; j = 500+jj;
  M_out[s11][i][2*j] = 1.; M_out[s11][i][2*j+1] = 0.; 
  M_out[s12][i][2*j] = 0.; M_out[s12][i][2*j+1] = 0.; 
  M_out[s21][i][2*j] = 0.; M_out[s21][i][2*j+1] = 0.; 
  M_out[s22][i][2*j] = 1.; M_out[s22][i][2*j+1] = 0.; 

// Diedre 0°
  i = 250+ii; j = 500+jj;
  M_out[s11][i][2*j] = 1.; M_out[s11][i][2*j+1] = 0.; 
  M_out[s12][i][2*j] = 0.; M_out[s12][i][2*j+1] = 0.; 
  M_out[s21][i][2*j] = 0.; M_out[s21][i][2*j+1] = 0.; 
  M_out[s22][i][2*j] = -1.; M_out[s22][i][2*j+1] = 0.; 
// Diedre 90°
  i = 750+ii; j = 500+jj;
  M_out[s11][i][2*j] = -1.; M_out[s11][i][2*j+1] = 0.; 
  M_out[s12][i][2*j] = 0.; M_out[s12][i][2*j+1] = 0.; 
  M_out[s21][i][2*j] = 0.; M_out[s21][i][2*j+1] = 0.; 
  M_out[s22][i][2*j] = 0.; M_out[s22][i][2*j+1] = 0.; 
// Diedre +45°
  i = 500+ii; j = 250+jj;
  M_out[s11][i][2*j] = 0.; M_out[s11][i][2*j+1] = 0.; 
  M_out[s12][i][2*j] = 1.; M_out[s12][i][2*j+1] = 0.; 
  M_out[s21][i][2*j] = 1.; M_out[s21][i][2*j+1] = 0.; 
  M_out[s22][i][2*j] = 0.; M_out[s22][i][2*j+1] = 0.; 
// Diedre -45°
  i = 500+ii; j = 750+jj;
  M_out[s11][i][2*j] = 0.; M_out[s11][i][2*j+1] = 0.; 
  M_out[s12][i][2*j] = -1.; M_out[s12][i][2*j+1] = 0.; 
  M_out[s21][i][2*j] = -1.; M_out[s21][i][2*j+1] = 0.; 
  M_out[s22][i][2*j] = 0.; M_out[s22][i][2*j+1] = 0.; 

// Helix Left
  i = 500+ii; j = 125+jj;
  M_out[s11][i][2*j] = 0.5; M_out[s11][i][2*j+1] = 0.; 
  M_out[s12][i][2*j] = 0.; M_out[s12][i][2*j+1] = 0.5; 
  M_out[s21][i][2*j] = 0.; M_out[s21][i][2*j+1] = 0.5; 
  M_out[s22][i][2*j] = -0.5; M_out[s22][i][2*j+1] = 0.; 

// Helix Left
  i = 500+ii; j = 875+jj;
  M_out[s11][i][2*j] = 0.5; M_out[s11][i][2*j+1] = 0.; 
  M_out[s12][i][2*j] = 0.; M_out[s12][i][2*j+1] = -0.5; 
  M_out[s21][i][2*j] = 0.; M_out[s21][i][2*j+1] = -0.5; 
  M_out[s22][i][2*j] = -0.5; M_out[s22][i][2*j+1] = 0.; 

// Dipole 0°
  i = 375+ii; j = 375+jj;
  M_out[s11][i][2*j] = 1.; M_out[s11][i][2*j+1] = 0.; 
  M_out[s12][i][2*j] = 0.; M_out[s12][i][2*j+1] = 0.; 
  M_out[s21][i][2*j] = 0.; M_out[s21][i][2*j+1] = 0.; 
  M_out[s22][i][2*j] = 0.; M_out[s22][i][2*j+1] = 0.; 

// Dipole 45°
  i = 375+ii; j = 625+jj;
  M_out[s11][i][2*j] = 0.5; M_out[s11][i][2*j+1] = 0.; 
  M_out[s12][i][2*j] = 0.5; M_out[s12][i][2*j+1] = 0.; 
  M_out[s21][i][2*j] = 0.5; M_out[s21][i][2*j+1] = 0.; 
  M_out[s22][i][2*j] = 0.5; M_out[s22][i][2*j+1] = 0.; 

// Dipole -45°
  i = 625+ii; j = 375+jj;
  M_out[s11][i][2*j] = 0.5; M_out[s11][i][2*j+1] = 0.; 
  M_out[s12][i][2*j] = -0.5; M_out[s12][i][2*j+1] = 0.; 
  M_out[s21][i][2*j] = -0.5; M_out[s21][i][2*j+1] = 0.; 
  M_out[s22][i][2*j] = 0.5; M_out[s22][i][2*j+1] = 0.; 

// Dipole 90°
  i = 625+ii; j = 625+jj;
  M_out[s11][i][2*j] = 0.; M_out[s11][i][2*j+1] = 0.; 
  M_out[s12][i][2*j] = 0.; M_out[s12][i][2*j+1] = 0.; 
  M_out[s21][i][2*j] = 0.; M_out[s21][i][2*j+1] = 0.; 
  M_out[s22][i][2*j] = 1.; M_out[s22][i][2*j+1] = 0.; 

  }

for (jj = -1; jj <= 1; jj++) {
  ii = 0;
  
// Sphere (0,0)
  i = 500+ii; j = 500+jj;
  M_out[s11][i][2*j] = 1.; M_out[s11][i][2*j+1] = 0.; 
  M_out[s12][i][2*j] = 0.; M_out[s12][i][2*j+1] = 0.; 
  M_out[s21][i][2*j] = 0.; M_out[s21][i][2*j+1] = 0.; 
  M_out[s22][i][2*j] = 1.; M_out[s22][i][2*j+1] = 0.; 

// Diedre 0°
  i = 250+ii; j = 500+jj;
  M_out[s11][i][2*j] = 1.; M_out[s11][i][2*j+1] = 0.; 
  M_out[s12][i][2*j] = 0.; M_out[s12][i][2*j+1] = 0.; 
  M_out[s21][i][2*j] = 0.; M_out[s21][i][2*j+1] = 0.; 
  M_out[s22][i][2*j] = -1.; M_out[s22][i][2*j+1] = 0.; 
// Diedre 90°
  i = 750+ii; j = 500+jj;
  M_out[s11][i][2*j] = -1.; M_out[s11][i][2*j+1] = 0.; 
  M_out[s12][i][2*j] = 0.; M_out[s12][i][2*j+1] = 0.; 
  M_out[s21][i][2*j] = 0.; M_out[s21][i][2*j+1] = 0.; 
  M_out[s22][i][2*j] = 0.; M_out[s22][i][2*j+1] = 0.; 
// Diedre +45°
  i = 500+ii; j = 250+jj;
  M_out[s11][i][2*j] = 0.; M_out[s11][i][2*j+1] = 0.; 
  M_out[s12][i][2*j] = 1.; M_out[s12][i][2*j+1] = 0.; 
  M_out[s21][i][2*j] = 1.; M_out[s21][i][2*j+1] = 0.; 
  M_out[s22][i][2*j] = 0.; M_out[s22][i][2*j+1] = 0.; 
// Diedre -45°
  i = 500+ii; j = 750+jj;
  M_out[s11][i][2*j] = 0.; M_out[s11][i][2*j+1] = 0.; 
  M_out[s12][i][2*j] = -1.; M_out[s12][i][2*j+1] = 0.; 
  M_out[s21][i][2*j] = -1.; M_out[s21][i][2*j+1] = 0.; 
  M_out[s22][i][2*j] = 0.; M_out[s22][i][2*j+1] = 0.; 

// Helix Left
  i = 500+ii; j = 125+jj;
  M_out[s11][i][2*j] = 0.5; M_out[s11][i][2*j+1] = 0.; 
  M_out[s12][i][2*j] = 0.; M_out[s12][i][2*j+1] = 0.5; 
  M_out[s21][i][2*j] = 0.; M_out[s21][i][2*j+1] = 0.5; 
  M_out[s22][i][2*j] = -0.5; M_out[s22][i][2*j+1] = 0.; 

// Helix Left
  i = 500+ii; j = 875+jj;
  M_out[s11][i][2*j] = 0.5; M_out[s11][i][2*j+1] = 0.; 
  M_out[s12][i][2*j] = 0.; M_out[s12][i][2*j+1] = -0.5; 
  M_out[s21][i][2*j] = 0.; M_out[s21][i][2*j+1] = -0.5; 
  M_out[s22][i][2*j] = -0.5; M_out[s22][i][2*j+1] = 0.; 

// Dipole 0°
  i = 375+ii; j = 375+jj;
  M_out[s11][i][2*j] = 1.; M_out[s11][i][2*j+1] = 0.; 
  M_out[s12][i][2*j] = 0.; M_out[s12][i][2*j+1] = 0.; 
  M_out[s21][i][2*j] = 0.; M_out[s21][i][2*j+1] = 0.; 
  M_out[s22][i][2*j] = 0.; M_out[s22][i][2*j+1] = 0.; 

// Dipole 45°
  i = 375+ii; j = 625+jj;
  M_out[s11][i][2*j] = 0.5; M_out[s11][i][2*j+1] = 0.; 
  M_out[s12][i][2*j] = 0.5; M_out[s12][i][2*j+1] = 0.; 
  M_out[s21][i][2*j] = 0.5; M_out[s21][i][2*j+1] = 0.; 
  M_out[s22][i][2*j] = 0.5; M_out[s22][i][2*j+1] = 0.; 

// Dipole -45°
  i = 625+ii; j = 375+jj;
  M_out[s11][i][2*j] = 0.5; M_out[s11][i][2*j+1] = 0.; 
  M_out[s12][i][2*j] = -0.5; M_out[s12][i][2*j+1] = 0.; 
  M_out[s21][i][2*j] = -0.5; M_out[s21][i][2*j+1] = 0.; 
  M_out[s22][i][2*j] = 0.5; M_out[s22][i][2*j+1] = 0.; 

// Dipole 90°
  i = 625+ii; j = 625+jj;
  M_out[s11][i][2*j] = 0.; M_out[s11][i][2*j+1] = 0.; 
  M_out[s12][i][2*j] = 0.; M_out[s12][i][2*j+1] = 0.; 
  M_out[s21][i][2*j] = 0.; M_out[s21][i][2*j+1] = 0.; 
  M_out[s22][i][2*j] = 1.; M_out[s22][i][2*j+1] = 0.; 

}

/* OUPUT DATA WRITING */
  for (np = 0; np < Npolar; np++) {
    printf("%s%s\n", out_dir, file_name_in_out[np]);
    for (i = 0; i < Nlig; i++) 
      fwrite(&M_out[np][i][0], sizeof(float), 2 * Ncol, out_file[np]);
    }
    
printf("\nFin Write\n");
  }

  free_matrix3d_float(M_out, Npolar, Nlig);
  return 1;
}

void speckle(float ***bbg)
{
int ii,jj,gg,np;
int nb_bbg, nx;
float u,k;
float moy, std;

moy = 0.;
std = 0.5;
nb_bbg = 2;
nx = 1000*1000;

for (np = 0; np < 4; np++) {
  bbg[np][0][0] = 0.;
  for (ii = 0; ii < nb_bbg; ii++) {
    for (jj = 0; jj < nx; jj++) {
      while (fabs(bbg[np][ii][jj]) < 1.E-25) {
        u = 0.;
        for (gg = 1; gg <= 12; gg++) {
          k = (float)(rand());
          u += (float)(k/32768.);
          }
        u = (float)(std*(u-6.)+moy);
        bbg[np][ii][jj] = u;
        }
      }
    }
  }


}
