/* MATRIX */
char **matrix_char(int nrh, int nch)
{
  int i;
  char **m;
  char msg0[] = "";
  char msg1[] = "allocation failure 1 in matrix_char()";
  char msg2[] = "allocation failure 2 in matrix_char()";

  m = (char **) malloc((unsigned) (nrh + 1) * sizeof(char *));
  if (!m)
  edit_error(msg1,msg0);

  for (i = 0; i < nrh; i++) {
  m[i] = (char *) malloc((unsigned) (nch + 1) * sizeof(char));
  if (!m[i])
    edit_error(msg2,msg0);
  }
  return m;
}
float *vector_float(int nrh)
{
  int ii;
  float *m;
  char msg0[] = "";
  char msg1[] = "allocation failure 1 in vector_float()";

  m = (float *) malloc((unsigned) (nrh + 1) * sizeof(float));
  if (!m)
  edit_error(msg1,msg0);

  for (ii = 0; ii < nrh; ii++)
  m[ii] = 0.;
  return m;
}
void free_vector_float(float *m)
{
  free((float *) m);
}
float **matrix_float(int nrh, int nch)
{
  int i, j;
  float **m;
  char msg0[] = "";
  char msg1[] = "allocation failure 1 in matrix_float()";
  char msg2[] = "allocation failure 2 in matrix_float()";

  m = (float **) malloc((unsigned) (nrh) * sizeof(float *));
  if (!m)
  edit_error(msg1,msg0);

  for (i = 0; i < nrh; i++) {
  m[i] = (float *) malloc((unsigned) (nch) * sizeof(float));
  if (!m[i])
    edit_error(msg2,msg0);
  }
  for (i = 0; i < nrh; i++)
  for (j = 0; j < nch; j++)
    m[i][j] = 0.;
  return m;
}
void free_matrix_float(float **m, int nrh)
{
  int i;
  for (i = nrh - 1; i >= 0; i--)
    free((float *) (m[i]));
}
float ***matrix3d_float(int nz, int nrh, int nch)
{
  int ii, jj, dd;
  float ***m;
  char msg0[] = "";
  char msg1[] = "allocation failure 1 in matrix_float()";
  char msg2[] = "allocation failure 2 in matrix_float()";
  char msg3[] = "allocation failure 3 in matrix_float()";

  m = (float ***) malloc((unsigned) (nz + 1) * sizeof(float **));
  if (m == NULL)
  edit_error(msg1,msg0);
  for (jj = 0; jj < nz; jj++) {
  m[jj] = (float **) malloc((unsigned) (nrh + 1) * sizeof(float *));
  if (m[jj] == NULL)
    edit_error(msg2,msg0);
  for (ii = 0; ii < nrh; ii++) {
    m[jj][ii] =
    (float *) malloc((unsigned) (nch + 1) * sizeof(float));
    if (m[jj][ii] == NULL)
      edit_error(msg3,msg0);
  }
  }
  for (dd = 0; dd < nz; dd++)
  for (jj = 0; jj < nrh; jj++)
  for (ii = 0; ii < nch; ii++)
    m[dd][jj][ii] = (0.);
  return m;
}
void free_matrix3d_float(float ***m, int nz, int nrh)
{
  int ii, jj;

  for (jj = nz - 1; jj >= 0; jj--)
  for (ii = nrh - 1; ii >= 0; ii--)
    free((float *) (m[jj][ii]));
  free((float *) (m));
}

/* UTIL_BLOCK */
int read_block_matrix_float(FILE *in_file, float **M_in, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol)
{
  int lig, col;
  int NNwinLigM1S2, NNwinColM1S2;
  int NNwinLigM1, NNwinColM1;

  long PointerPosition;

  NNwinLigM1S2 = (NNwinLig - 1) / 2;
  NNwinColM1S2 = (NNwinCol - 1) / 2;
  NNwinLigM1 = (NNwinLig - 1);
  NNwinColM1 = (NNwinCol - 1);

  if (NNblock == 0) {

    /* OFFSET LINES READING */
    for (lig = 0; lig < OOff_lig; lig++)
      fread(&_VF_in[0], sizeof(float), NNcol, in_file);
  
    /* Set the Tmp matrix to 0 */
    for (lig = 0; lig < NNwinLigM1S2; lig++) 
      for (col = 0; col < Sub_NNcol + NNwinCol; col++)
        M_in[lig][col] = 0.;

    } else {

    /* FSEEK NNwinL LINES */
    PointerPosition = (NNwinLigM1 * NNcol) * sizeof(float);
    fseek(in_file, -PointerPosition, SEEK_CUR);

    /* FIRST (NNwin+1)/2 LINES READING */
    for (lig = 0; lig < NNwinLigM1S2; lig++) {
      fread(&_VF_in[0], sizeof(float), NNcol, in_file);
      for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_in[lig][col] = 0.; 
      for (col = 0; col < Sub_NNcol; col++) M_in[lig][col + NNwinColM1S2] = _VF_in[col + OOff_col];
      }

    } /* NNblock == 0 */
      
  /* READING NLIG LINES */
  for (lig = 0; lig < Sub_NNlig+NNwinLigM1S2; lig++) {
    if (NNbBlock <= 2) PrintfLine(lig,Sub_NNlig+NNwinLigM1S2);

    /* 1 line reading with zero padding */
    if (lig < Sub_NNlig) {
      fread(&_VF_in[0], sizeof(float), NNcol, in_file);
      for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_in[NNwinLigM1S2+lig][col] = 0.; 
      for (col = 0; col < Sub_NNcol; col++) M_in[NNwinLigM1S2+lig][col + NNwinColM1S2] = _VF_in[col + OOff_col];
      } else {
      if (NNblock == (NNbBlock - 1)) {
        for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_in[NNwinLigM1S2+lig][col] = 0.;
        } else {
        fread(&_VF_in[0], sizeof(float), NNcol, in_file);
        for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_in[NNwinLigM1S2+lig][col] = 0.; 
        for (col = 0; col < Sub_NNcol; col++) M_in[NNwinLigM1S2+lig][col + NNwinColM1S2] = _VF_in[col + OOff_col];
        }
      }
      
    } /*lig */

  return 1;
}
int write_block_matrix_float(FILE *out_file, float **M_out, int Sub_NNlig, int Sub_NNcol, int OOffLig, int OOffCol, int NNcol)
{
  int lig, col;

  for (lig = 0; lig < Sub_NNlig; lig++) {
    for (col = 0; col < NNcol; col++) {
      if (my_isfinite(M_out[OOffLig + lig][col]) == 0) M_out[OOffLig + lig][col] = eps;
      }
    fwrite(&M_out[OOffLig + lig][OOffCol], sizeof(float), Sub_NNcol, out_file);
    }

  return 1;
}
int read_block_S2_avg(FILE *datafile[], float ***M_out, char *PolType, int NNpolar, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol)
{
  int Np, lig, col, k, l;
  int NNpolarIn=4;
  int hh=0;
  int hv=1;
  int vh=2;
  int vv=3;
  int NNwinLigM1S2, NNwinColM1S2;
  int NNwinLigM1, NNwinColM1;
  float k1r, k1i, k2r, k2i, k3r, k3i, k4r, k4i;
  
  long PointerPosition;

  NNwinLigM1S2 = (NNwinLig - 1) / 2;
  NNwinColM1S2 = (NNwinCol - 1) / 2;
  NNwinLigM1 = (NNwinLig - 1);
  NNwinColM1 = (NNwinCol - 1);
    
    if (NNblock == 0) {
      /* OFFSET LINES READING */
      for (lig = 0; lig < OOff_lig; lig++)
        for (Np = 0; Np < NNpolarIn; Np++)
          fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
      /* Set the Tmp matrix to 0 */
      for (lig = 0; lig < NNwinLigM1S2; lig++) 
        for (col = 0; col < NNcol + NNwinCol; col++)
          for (Np = 0; Np < NNpolar; Np++) _MF_in[Np][lig][col] = 0.;

      /* FIRST (NNwin+1)/2 LINES READING TO FILTER THE FIRST DATA LINE */
      for (lig = NNwinLigM1S2; lig < NNwinLigM1; lig++) {
        for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);

        for (Np = 0; Np < NNpolar; Np++)
          for (col = 0; col < Sub_NNcol + NNwinCol; col++) _MF_in[Np][lig][col] = 0.;

        for (col = OOff_col; col < Sub_NNcol + OOff_col; col++) {
          if (strcmp(PolType, "C3") == 0) {
            k1r = _MC_in[hh][2*col];
            k1i = _MC_in[hh][2*col + 1];
            k2r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
            k2i = (_MC_in[hv][2*col + 1] + _MC_in[vh][2*col + 1]) / sqrt(2.);
            k3r = _MC_in[vv][2*col];
            k3i = _MC_in[vv][2*col + 1];
            
            _MF_in[C311][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            _MF_in[C312_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
            _MF_in[C312_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
            _MF_in[C313_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
            _MF_in[C313_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
            _MF_in[C322][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            _MF_in[C323_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
            _MF_in[C323_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
            _MF_in[C333][lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
            }
          
          if (strcmp(PolType, "C4") == 0) {
            k1r = _MC_in[hh][2*col];
            k1i = _MC_in[hh][2*col+1];
            k2r = _MC_in[hv][2*col];
            k2i  = _MC_in[hv][2*col+1];
            k3r = _MC_in[vh][2*col];
            k3i = _MC_in[vh][2*col+1];
            k4r = _MC_in[vv][2*col];
            k4i = _MC_in[vv][2*col+1];

            _MF_in[C411][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            _MF_in[C412_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
            _MF_in[C412_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
            _MF_in[C413_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
            _MF_in[C413_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
            _MF_in[C414_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k4r + k1i * k4i;
            _MF_in[C414_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k4r - k1r * k4i;
            _MF_in[C422][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            _MF_in[C423_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
            _MF_in[C423_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
            _MF_in[C424_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k4r + k2i * k4i;
            _MF_in[C424_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k4r - k2r * k4i;
            _MF_in[C433][lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
            _MF_in[C434_re][lig][col - OOff_col + NNwinColM1S2] = k3r * k4r + k3i * k4i;
            _MF_in[C434_im][lig][col - OOff_col + NNwinColM1S2] = k3i * k4r - k3r * k4i;
            _MF_in[C444][lig][col - OOff_col + NNwinColM1S2] = k4r * k4r + k4i * k4i;
            }
          }

        }
        
      } else {
      /* FSEEK NNwinL LINES */
      PointerPosition = (NNwinLigM1 * 2 * NNcol) * sizeof(float);
      for (Np = 0; Np < NNpolarIn; Np++)
        fseek(datafile[Np], -PointerPosition, SEEK_CUR);

      /* FIRST NNwin-1 LINES READING TO FILTER THE FIRST DATA LINE */
      for (lig = 0; lig < NNwinLigM1; lig++) {
        for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);

        for (Np = 0; Np < NNpolar; Np++)
          for (col = 0; col < Sub_NNcol + NNwinCol; col++) _MF_in[Np][lig][col] = 0.;

        for (col = OOff_col; col < Sub_NNcol + OOff_col; col++) {
          if (strcmp(PolType, "C3") == 0) {
            k1r = _MC_in[hh][2*col];
            k1i = _MC_in[hh][2*col + 1];
            k2r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
            k2i = (_MC_in[hv][2*col + 1] + _MC_in[vh][2*col + 1]) / sqrt(2.);
            k3r = _MC_in[vv][2*col];
            k3i = _MC_in[vv][2*col + 1];

            _MF_in[C311][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            _MF_in[C312_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
            _MF_in[C312_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
            _MF_in[C313_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
            _MF_in[C313_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
            _MF_in[C322][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            _MF_in[C323_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
            _MF_in[C323_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
            _MF_in[C333][lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
            }
          
          if (strcmp(PolType, "C4") == 0) {
            k1r = _MC_in[hh][2*col];
            k1i = _MC_in[hh][2*col+1];
            k2r = _MC_in[hv][2*col];
            k2i  = _MC_in[hv][2*col+1];
            k3r = _MC_in[vh][2*col];
            k3i = _MC_in[vh][2*col+1];
            k4r = _MC_in[vv][2*col];
            k4i = _MC_in[vv][2*col+1];

            _MF_in[C411][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            _MF_in[C412_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
            _MF_in[C412_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
            _MF_in[C413_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
            _MF_in[C413_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
            _MF_in[C414_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k4r + k1i * k4i;
            _MF_in[C414_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k4r - k1r * k4i;
            _MF_in[C422][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            _MF_in[C423_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
            _MF_in[C423_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
            _MF_in[C424_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k4r + k2i * k4i;
            _MF_in[C424_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k4r - k2r * k4i;
            _MF_in[C433][lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
            _MF_in[C434_re][lig][col - OOff_col + NNwinColM1S2] = k3r * k4r + k3i * k4i;
            _MF_in[C434_im][lig][col - OOff_col + NNwinColM1S2] = k3i * k4r - k3r * k4i;
            _MF_in[C444][lig][col - OOff_col + NNwinColM1S2] = k4r * k4r + k4i * k4i;
            }
          }

        }
        
      } /* NNblock == 0 */
      
    /* READING AND AVERAGING NLIG LINES */
    for (lig = 0; lig < Sub_NNlig; lig++) {
      if (NNbBlock == 1) if (lig%(int)(Sub_NNlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_NNlig - 1));fflush(stdout);}

      /* 1 line reading with zero padding */
      if (lig < Sub_NNlig - NNwinLigM1S2) {
        for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
        } else {
        if (NNblock == (NNbBlock - 1)) {
          for (Np = 0; Np < NNpolarIn; Np++)
            for (col = 0; col < 2 * NNcol; col++) _MC_in[Np][col] = 0.;
          } else {
          for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
          }
        }

      for (Np = 0; Np < NNpolar; Np++)
        for (col = 0; col < Sub_NNcol + NNwinCol; col++) _MF_in[Np][NNwinLigM1][col] = 0.;

      /* Row-wise shift */
      for (col = OOff_col; col < Sub_NNcol + OOff_col; col++) {
        if (strcmp(PolType, "C3") == 0) {
          k1r = _MC_in[hh][2*col];
          k1i = _MC_in[hh][2*col + 1];
          k2r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
          k2i = (_MC_in[hv][2*col + 1] + _MC_in[vh][2*col + 1]) / sqrt(2.);
          k3r = _MC_in[vv][2*col];
          k3i = _MC_in[vv][2*col + 1];

          _MF_in[C311][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          _MF_in[C312_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
          _MF_in[C312_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
          _MF_in[C313_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
          _MF_in[C313_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
          _MF_in[C322][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          _MF_in[C323_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
          _MF_in[C323_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
          _MF_in[C333][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
          }
          
        if (strcmp(PolType, "C4") == 0) {
          k1r = _MC_in[hh][2*col];
          k1i = _MC_in[hh][2*col+1];
          k2r = _MC_in[hv][2*col];
          k2i = _MC_in[hv][2*col+1];
          k3r = _MC_in[vh][2*col];
          k3i = _MC_in[vh][2*col+1];
          k4r = _MC_in[vv][2*col];
          k4i = _MC_in[vv][2*col+1];

          _MF_in[C411][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          _MF_in[C412_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
          _MF_in[C412_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
          _MF_in[C413_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
          _MF_in[C413_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
          _MF_in[C414_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k4r + k1i * k4i;
          _MF_in[C414_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1i * k4r - k1r * k4i;
          _MF_in[C422][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          _MF_in[C423_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
          _MF_in[C423_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
          _MF_in[C424_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2r * k4r + k2i * k4i;
          _MF_in[C424_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2i * k4r - k2r * k4i;
          _MF_in[C433][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
          _MF_in[C434_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k3r * k4r + k3i * k4i;
          _MF_in[C434_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k3i * k4r - k3r * k4i;
          _MF_in[C444][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k4r * k4r + k4i * k4i;
          }

        }
  
      for (col = 0; col < Sub_NNcol; col++) {
        if (col == 0) {
          for (Np = 0; Np < NNpolar; Np++) M_out[Np][lig][col] = 0.;
          /* Average matrix element calculation */
          for (k = -NNwinLigM1S2; k < 1 + NNwinLigM1S2; k++)
            for (l = -NNwinColM1S2; l < 1 + NNwinColM1S2; l++) {
              for (Np = 0; Np < NNpolar; Np++) M_out[Np][lig][col] = M_out[Np][lig][col] + _MF_in[Np][NNwinLigM1S2 + k][NNwinColM1S2 + col + l] / (float) (NNwinLig * NNwinCol);
              }
          } else {
          for (Np = 0; Np < NNpolar; Np++) M_out[Np][lig][col] = M_out[Np][lig][col-1];
          /* Average matrix element calculation */
          for (k = -NNwinLigM1S2; k < 1 + NNwinLigM1S2; k++) {
            for (Np = 0; Np < NNpolar; Np++) {
              M_out[Np][lig][col] = M_out[Np][lig][col] - _MF_in[Np][NNwinLigM1S2 + k][col - 1] / (float) (NNwinLig * NNwinCol);
              M_out[Np][lig][col] = M_out[Np][lig][col] + _MF_in[Np][NNwinLigM1S2 + k][NNwinCol - 1 + col] / (float) (NNwinLig * NNwinCol);
              }
            }
          }
        } /*col */
  
      /* Line-wise shift */
      for (l = 0; l < NNwinLigM1; l++)
        for (col = 0; col < Sub_NNcol + NNwinCol; col++)
          for (Np = 0; Np < NNpolar; Np++)
            _MF_in[Np][l][col] = _MF_in[Np][l + 1][col];
            
      } /*lig */ 

  return 1;
}

/* PROCESSING */
void Diagonalisation(int MatrixDim, float ***HM, float ***EigenVect, float *EigenVal)
{

  double a[10][10][2], v[10][10][2], d[10], b[10], z[10];
  double w[2], s[2], c[2], titi[2], gc[2], hc[2];
  double sm, tresh, x, toto, e, f, g, h, r, d1, d2;
  int n, pp, qq;
  int ii, i, j, k;

  n = MatrixDim;
  pp = 0; qq = 0;

  for (i = 1; i < n + 1; i++) {
    for (j = 1; j < n + 1; j++) {
      a[i][j][0] = HM[i - 1][j - 1][0];
      a[i][j][1] = HM[i - 1][j - 1][1];
      v[i][j][0] = 0.;
      v[i][j][1] = 0.;
    }
    v[i][i][0] = 1.;
    v[i][i][1] = 0.;
  }

  for (pp = 1; pp < n + 1; pp++) {
    d[pp] = a[pp][pp][0];
    b[pp] = d[pp];
    z[pp] = 0.;
  }

  for (ii = 1; ii < 1000 * n * n; ii++) {
    sm = 0.;
    for (pp = 1; pp < n; pp++) {
      for (qq = pp + 1; qq < n + 1; qq++) {
        sm = sm + 2. * sqrt(a[pp][qq][0] * a[pp][qq][0] + a[pp][qq][1] * a[pp][qq][1]);
      }
    }
    sm = sm / (n * (n - 1));
    if (sm < 1.E-16) goto Sortie;
    tresh = 1.E-17;
    if (ii < 4) tresh = (long) 0.2 *sm / (n * n);
    x = -1.E-15;
    for (i = 1; i < n; i++) {
      for (j = i + 1; j < n + 1; j++) {
        toto = sqrt(a[i][j][0] * a[i][j][0] + a[i][j][1] * a[i][j][1]);
        if (x < toto) {
          x = toto;
          pp = i;
          qq = j;
        }
      }
    }
    toto = sqrt(a[pp][qq][0] * a[pp][qq][0] + a[pp][qq][1] * a[pp][qq][1]);
    if (toto > tresh) {
      e = d[pp] - d[qq];
      w[0] = a[pp][qq][0];
      w[1] = a[pp][qq][1];
      g = sqrt(w[0] * w[0] + w[1] * w[1]);
      g = g * g;
      f = sqrt(e * e + 4. * g);
      d1 = e + f;
      d2 = e - f;
      if (fabs(d2) > fabs(d1)) d1 = d2;
      r = fabs(d1) / sqrt(d1 * d1 + 4. * g);
      s[0] = r;
      s[1] = 0.;
      titi[0] = 2. * r / d1;
      titi[1] = 0.;
      c[0] = titi[0] * w[0] - titi[1] * w[1];
      c[1] = titi[0] * w[1] + titi[1] * w[0];
      r = sqrt(s[0] * s[0] + s[1] * s[1]);
      r = r * r;
      h = (d1 / 2. + 2. * g / d1) * r;
      d[pp] = d[pp] - h;
      z[pp] = z[pp] - h;
      d[qq] = d[qq] + h;
      z[qq] = z[qq] + h;
      a[pp][qq][0] = 0.;
      a[pp][qq][1] = 0.;

      for (j = 1; j < pp; j++) {
        gc[0] = a[j][pp][0];
        gc[1] = a[j][pp][1];
        hc[0] = a[j][qq][0];
        hc[1] = a[j][qq][1];
        a[j][pp][0] = c[0] * gc[0] - c[1] * gc[1] - s[0] * hc[0] - s[1] * hc[1];
        a[j][pp][1] = c[0] * gc[1] + c[1] * gc[0] - s[0] * hc[1] + s[1] * hc[0];
        a[j][qq][0] = s[0] * gc[0] - s[1] * gc[1] + c[0] * hc[0] + c[1] * hc[1];
        a[j][qq][1] = s[0] * gc[1] + s[1] * gc[0] + c[0] * hc[1] - c[1] * hc[0];
      }
      for (j = pp + 1; j < qq; j++) {
        gc[0] = a[pp][j][0];
        gc[1] = a[pp][j][1];
        hc[0] = a[j][qq][0];
        hc[1] = a[j][qq][1];
        a[pp][j][0] = c[0] * gc[0] + c[1] * gc[1] - s[0] * hc[0] - s[1] * hc[1];
        a[pp][j][1] = c[0] * gc[1] - c[1] * gc[0] + s[0] * hc[1] - s[1] * hc[0];
        a[j][qq][0] = s[0] * gc[0] + s[1] * gc[1] + c[0] * hc[0] + c[1] * hc[1];
        a[j][qq][1] = -s[0] * gc[1] + s[1] * gc[0] + c[0] * hc[1] - c[1] * hc[0];
      }
      for (j = qq + 1; j < n + 1; j++) {
        gc[0] = a[pp][j][0];
        gc[1] = a[pp][j][1];
        hc[0] = a[qq][j][0];
        hc[1] = a[qq][j][1];
        a[pp][j][0] = c[0] * gc[0] + c[1] * gc[1] - s[0] * hc[0] + s[1] * hc[1];
        a[pp][j][1] = c[0] * gc[1] - c[1] * gc[0] - s[0] * hc[1] - s[1] * hc[0];
        a[qq][j][0] = s[0] * gc[0] + s[1] * gc[1] + c[0] * hc[0] - c[1] * hc[1];
        a[qq][j][1] = s[0] * gc[1] - s[1] * gc[0] + c[0] * hc[1] + c[1] * hc[0];
      }
      for (j = 1; j < n + 1; j++) {
        gc[0] = v[j][pp][0];
        gc[1] = v[j][pp][1];
        hc[0] = v[j][qq][0];
        hc[1] = v[j][qq][1];
        v[j][pp][0] = c[0] * gc[0] - c[1] * gc[1] - s[0] * hc[0] - s[1] * hc[1];
        v[j][pp][1] = c[0] * gc[1] + c[1] * gc[0] - s[0] * hc[1] + s[1] * hc[0];
        v[j][qq][0] = s[0] * gc[0] - s[1] * gc[1] + c[0] * hc[0] + c[1] * hc[1];
        v[j][qq][1] = s[0] * gc[1] + s[1] * gc[0] + c[0] * hc[1] - c[1] * hc[0];
      }
    }
  }

  Sortie:

  for (k = 1; k < n + 1; k++) {
    d[k] = 0;
    for (i = 1; i < n + 1; i++) {
      for (j = 1; j < n + 1; j++) {
        d[k] = d[k] + v[i][k][0] * (HM[i - 1][j - 1][0] * v[j][k][0] - HM[i - 1][j - 1][1] * v[j][k][1]);
        d[k] = d[k] + v[i][k][1] * (HM[i - 1][j - 1][0] * v[j][k][1] + HM[i - 1][j - 1][1] * v[j][k][0]);
      }
    }
  }

  for (i = 1; i < n + 1; i++) {
    for (j = i + 1; j < n + 1; j++) {
      if (d[j] > d[i]) {
        x = d[i];
        d[i] = d[j];
        d[j] = x;
        for (k = 1; k < n + 1; k++) {
          c[0] = v[k][i][0];
          c[1] = v[k][i][1];
          v[k][i][0] = v[k][j][0];
          v[k][i][1] = v[k][j][1];
          v[k][j][0] = c[0];
          v[k][j][1] = c[1];
        }
      }
    }
  }

  for (i = 0; i < n; i++) {
    EigenVal[i] = d[i + 1];
    for (j = 0; j < n; j++) {
      EigenVect[i][j][0] = v[i + 1][j + 1][0];
      EigenVect[i][j][1] = v[i + 1][j + 1][1];
    }
  }

}

/* UTIL */
void edit_error(char *s1, char *s2)
{
  printf("\n A processing error occured ! \n %s%s\n", s1, s2);
  exit(1);
}
void check_file(char *file)
{
#ifdef _WIN32
  int i;
  i = 0;
  while (file[i] != '\0') {
  if (file[i] == '/')
    file[i] = '\\';
  i++;
  }
#endif
}
void check_dir(char *dir)
{
#ifndef _WIN32
  strcat(dir, "/");
#else
  int i;
  i = 0;
  while (dir[i] != '\0') {
  if (dir[i] == '/')
    dir[i] = '\\';
  i++;
  }
  strcat(dir, "\\");
#endif
}
void read_config(char *dir, int *Nlig, int *Ncol, char *PolarCase, char *PolarType)
{
  char file_name[FilePathLength];
  char Tmp[FilePathLength];
  FILE *file;
  char msg[] = "Could not open configuration file : ";

  sprintf(file_name, "%sconfig.txt", dir);
  if ((file = fopen(file_name, "r")) == NULL)
  edit_error(msg, file_name);

  fscanf(file, "%s\n", Tmp);
  fscanf(file, "%i\n", &*Nlig);
  fscanf(file, "%s\n", Tmp);
  fscanf(file, "%s\n", Tmp);
  fscanf(file, "%i\n", &*Ncol);
  fscanf(file, "%s\n", Tmp);
  fscanf(file, "%s\n", Tmp);
  fscanf(file, "%s\n", PolarCase);
  fscanf(file, "%s\n", Tmp);
  fscanf(file, "%s\n", Tmp);
  fscanf(file, "%s\n", PolarType);

  fclose(file);
}
int PolTypeConfig(char *PolType, int *NpolarIn, char *PolTypeIn, int *NpolarOut, char *PolTypeOut, char *PolarType)
{
  int Config, ii;  
  char PolTypeTmp[20];
  const char *PolTypeConfig[92] = {"C2", "C2T2","C3", "C3T3", "C4", "C4T4", "C4C3", "C4T3", 
               "T2", "T2C2", "T3", "T3C3", "T4", "T4C4", "T4C3", "T4T3", "T6", 
               "S2SPPpp1", "S2SPPpp2", "S2SPPpp3", "S2IPPpp4", 
               "S2IPPpp5", "S2IPPpp6", "S2IPPpp7", "S2IPPfull", "S2", "S2C3", 
               "S2C4", "S2T3", "S2T4", "S2T6", "SPP", "SPPC2", "SPPT2","SPPT4",
               "SPPIPP", "IPP", "Ixx",
               "S2C2pp1", "S2C2pp2", "S2C2pp3",
               "S2SPPlhv", "S2SPPrhv", "S2SPPpi4",
               "S2C2lhv", "S2C2rhv", "S2C2pi4",
               "C2IPPpp5", "C2IPPpp6", "C2IPPpp7",
               "C3C2pp1", "C3C2pp2", "C3C2pp3",
               "C3C2lhv", "C3C2rhv", "C3C2pi4",
               "C3IPPpp4", "C3IPPpp5", "C3IPPpp6", "C3IPPpp7",
               "C4C2pp1", "C4C2pp2", "C4C2pp3",
               "C4C2lhv", "C4C2rhv", "C4C2pi4",
               "C4IPPpp4", "C4IPPpp5", "C4IPPpp6", "C4IPPpp7", "C4IPPfull",
               "T3C2pp1", "T3C2pp2", "T3C2pp3",
               "T3C2lhv", "T3C2rhv", "T3C2pi4",
               "T3IPPpp4", "T3IPPpp5", "T3IPPpp6", "T3IPPpp7",
               "T4C2pp1", "T4C2pp2", "T4C2pp3",
               "T4C2lhv", "T4C2rhv", "T4C2pi4",
               "T4IPPpp4", "T4IPPpp5", "T4IPPpp6", "T4IPPpp7", "T4IPPfull"
               };
  char msg1[] = "Wrong Input / Output Polarimetric Data Format\n";
  char msg2[] = "UsageHelpDataFormat";

  Config = 0;
  for (ii=0; ii<87; ii++) if (strcmp(PolTypeConfig[ii],PolType) == 0) Config = 1;
  if (Config == 0) edit_error(msg1,msg2);

  strcpy(PolTypeTmp,PolType);

  if (strcmp(PolTypeTmp,"S2C3") == 0) { 
    *NpolarIn = 4; *NpolarOut = 9;
    strcpy(PolType,"S2"); strcpy(PolTypeIn,"S2"); strcpy(PolTypeOut,"C3"); }
  
  if (strcmp(PolTypeTmp,"S2C4") == 0) { 
    *NpolarIn = 4; *NpolarOut = 16;
    strcpy(PolType,"S2"); strcpy(PolTypeIn,"S2"); strcpy(PolTypeOut,"C4"); }
   
  return 1;
}
int init_file_name(char *PolType, char *Dir, char **FileName)
{
  int ii;
  const char *file_name_S2[4] = 
  {"s11.bin", "s12.bin", "s21.bin", "s22.bin" };

  if (strcmp(PolType,"S2") == 0) 
    for (ii =0; ii<4; ii++) 
      sprintf(&FileName[ii][0], "%s%s", Dir, file_name_S2[ii]);

  return(1);
}
int memory_alloc(char *filememerr, int Nlig, int Nwin, int *NbBlock, int *NligBlock, int NBlockA, int NBlockB, int MemAlloc)
{
  FILE *fileerr;
  int ii, NligBlockSize, NligBlockRem;
  char msg1[] = "Could not open configuration file : ";
  char msg2[] = "ERROR : NOT ENOUGH MEMORY SPACE";
  char msg3[] = "";

  NligBlockSize = (int) floor( (250000 * MemAlloc - NBlockB) / NBlockA);

  if (NligBlockSize <= 1) {
    if ((fileerr = fopen(filememerr, "w")) == NULL) {
      printf("ERROR : NOT ENOUGH MEMORY SPACE\n");
      printf("THE AVALAIBLE PROCESSING MEMORY\n");
      printf("MUST BE HIGHER THAN %i Mb\n", MemAlloc);
      printf("NligBlockSize = %i\n", NligBlockSize);
      edit_error(msg1, filememerr);
      }
    fprintf(fileerr, "ERROR : NOT ENOUGH MEMORY SPACE\n");
    fprintf(fileerr, "THE AVALAIBLE PROCESSING MEMORY\n");
    fprintf(fileerr, "MUST BE HIGHER THAN %i Mb\n", MemAlloc);
    fclose(fileerr);
    edit_error(msg2, msg3);
    }
  
  if (NligBlockSize >= Nlig) {
    *NbBlock = 1;
    NligBlock[0] = Nlig;
    } else {
    *NbBlock = (int) floor(Nlig / NligBlockSize);
    NligBlockRem = Nlig - (*NbBlock) * NligBlockSize;
    for (ii = 0; ii < (*NbBlock); ii++) NligBlock[ii] = NligBlockSize;
    if ( NligBlockRem < Nwin ) {
      NligBlock[0] += NligBlockRem;
      } else { 
      NligBlock[(*NbBlock)] = NligBlockRem;
      (*NbBlock)++;
      }
    }
  return 1;
}
int PrintfLine(int lig, int NNlig)
{
if (NNlig > 20) {
   if (lig%(int)(NNlig/20) == 0) {printf("%f\r", 100. * lig / (NNlig - 1));fflush(stdout);}
   } else {
   if (NNlig > 1) {printf("%f\r", 100. * (lig+1) / NNlig);fflush(stdout);}
   }
return 1;
}
int CreateUsageHelpDataFormat(char *PolTypeConf)
{

    if (strcmp(PolTypeConf,"S2") == 0)  		strcat(UsageHelpDataFormat," S2         input : quad-pol S2     output : quad-pol S2\n");
    if (strcmp(PolTypeConf,"S2C3") == 0)		strcat(UsageHelpDataFormat," S2C3       input : quad-pol S2     output : covariance C3\n");
    if (strcmp(PolTypeConf,"S2C4") == 0)		strcat(UsageHelpDataFormat," S2C4       input : quad-pol S2     output : covariance C4\n");
    
return 1;
}
int CreateUsageHelpDataFormatInput(const char *PolTypeConf)
{

    if (strcmp(PolTypeConf,"S2") == 0)  		strcat(UsageHelpDataFormat," S2    input : quad-pol S2      output parameters derived from C3 or T3\n");
    if (strcmp(PolTypeConf,"S2m") == 0) 		strcat(UsageHelpDataFormat," S2m   input : quad-pol S2      output parameters derived from C3 or T3\n");
    if (strcmp(PolTypeConf,"S2b") == 0) 		strcat(UsageHelpDataFormat," S2b   input : quad-pol S2      output parameters derived from C4 or T4\n");
    if (strcmp(PolTypeConf,"S2C3") == 0)		strcat(UsageHelpDataFormat," S2C3  input : quad-pol S2      output parameters derived from covariance C3\n");
    if (strcmp(PolTypeConf,"S2C4") == 0)		strcat(UsageHelpDataFormat," S2C4  input : quad-pol S2      output parameters derived from covariance C4\n");
    
return 1;
}
int init_matrix_block(int NNcol, int NNpolar, int NNwinLig, int NNwinCol)
{

_VC_in = vector_float(2*NNcol);
_VF_in = vector_float(NNcol);
_MC_in = matrix_float(4,2*NNcol);
_MF_in = matrix3d_float(NNpolar,NNwinLig, NNcol+NNwinCol);
return 1;
}
int block_alloc(int *NNligBlock, int SSubSampLig, int NNLookLig, int SSub_Nlig, int *NNbBlock)
{
    int ii, NligRem, NligNew;

    NligRem = (int) floor ( fmod(NNligBlock[0], SSubSampLig*NNLookLig));
    if (NligRem != 0) {
      NligNew = (int) floor(NNligBlock[0] / (SSubSampLig*NNLookLig));
      NligNew = NligNew*SSubSampLig*NNLookLig;
      (*NNbBlock) = floor(SSub_Nlig / NligNew);
      NligRem = SSub_Nlig - (*NNbBlock)*NligNew;
      for (ii = 0; ii < (*NNbBlock); ii++) NNligBlock[ii] = NligNew;
      //NligBlock[NbBlock] = NligRem;
      NligNew = (int) floor(NligRem / (SSubSampLig*NNLookLig));
      NligNew = NligNew*SSubSampLig*NNLookLig;
      NNligBlock[(*NNbBlock)] = NligNew;
      (*NNbBlock)++;
      }
  return 1;
}

/* MY_UTILS */
int get_one_char_only(void)
{
int c, first;

/* get and save the first character */
first = c = getchar();

/* if it was not newline, keep getting more (but stop on EOF) */
while (c != '\n' && c != EOF)
c = getchar();

/* in any case, return the first one, which may be '\n' or EOF */
return first;
}
int get_commandline_prm(int argc, char *argv[], char *keyword, cmd_prm type, void *ptr, int required, char *usage)
{
 int  i, found=0,missing_prm=0,is_arg;
 unsigned int loop,count;
 char msg0[] = "";
 char msg1[] = "Wrong parameter type";
 char msg2[] = "Usage:\n";

 for (i=1; (!found) && (i<argc); i++)
 {
  if(!strcmp(keyword,argv[i]))
  {
  found=1;
  if(type != no_cmd_prm) /* a parameter is needed */
  {
  if(i < argc-1)
  {
   is_arg=1;
   if(argv[i+1][0]=='-')
   {
    count=0;
    is_arg=0;
    if(strlen(argv[i+1])>1)
    {
    for(loop=1;loop<strlen(argv[i+1]);loop++)
    {
    count+=((argv[i+1][loop] >= '0') && (argv[i+1][loop] <= '9'));
    count+=(argv[i+1][loop] == '.');
    }
    count++;
    is_arg=(count==strlen(argv[i+1]));
    }    
   }
      
   if(is_arg) /* the next argument is a parameter */
   {
    switch(type)
    {
    case int_cmd_prm: sscanf(argv[i+1], "%d", (int *)ptr);break;
    case flt_cmd_prm: sscanf(argv[i+1], "%f", (float *)ptr);break;
    //case str_cmd_prm: sscanf(argv[i+1], "%s", (char *)ptr);break;
    case str_cmd_prm: strcpy((char *)ptr, argv[i+1]);break;
    default:
    edit_error(msg1,msg0);
    }
   }
   else
    missing_prm=1;
  }
  else
   missing_prm=1;
  }
  }
 }

 if(missing_prm)
 {
  printf("\n A parameter is needed for the %s option\n",keyword);
  edit_error(msg2,usage);
 }

 if(!found && required)
 {
  printf("\n The required argument %s could not be found\n",keyword);
  edit_error(msg2,usage);
 }
  return found;
}
