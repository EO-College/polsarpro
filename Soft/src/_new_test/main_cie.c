#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define PI 3.14159265358979323846


//+------------------------------------------------------------------+
//|                                                                  |
//|                         STRUCTURE                                |
//|                                                                  |
//+------------------------------------------------------------------+
typedef struct {
  float R[3], G[3], B[3];
  float RefWhiteRGB[3];
  float Gamma;
  float MtxRGB2XYZ[9], MtxXYZ2RGB[9];
} RGBModel;

typedef struct {
  float MtxAdaptMa[9];
  float AdaptationIndex;
  float MtxAdaptMaI[9];
} Adaptation;

//+------------------------------------------------------------------+
//|                                                                  |
//|                         SUBROUTINES                              |
//|                                                                  |
//+------------------------------------------------------------------+
void StrSplit(char** arr, char* str, const char* del) {
  char* s = strtok(str, del);
  
  if(s == NULL){
    printf("ERROR::StrSplit:The string split results is fail\n");
    exit(EXIT_FAILURE);
  }

  while(s != NULL) {
    *arr++ = s;
    s = strtok(NULL, del);
  }
}

void RemoveSpaces(char* source){
  char* i = source;
  char* j = source;
  while(*j != 0){
    *i = *j++;
    if(*i != ' '){
      i++;
    }
  }
  *i = 0;
}

int GetENVIHeaderSampleLine(const char* file_hdr, long* sample, long* line){
  // Read header
  FILE* fin = fopen(file_hdr, "r");
  
  //check if file exists
  if(fin == NULL){
    printf("ERROR::GetENVIHeaderSampleLine:file does not exists %s\n", file_hdr);
    exit(EXIT_FAILURE);
  }
  
  char str[200];
  char* arr[20];
  *sample = -9999;
  *line   = -9999;
  while(fgets(str, 200, fin) != NULL){
    StrSplit(arr, str, "=");
    char* tag = arr[0];
    RemoveSpaces(tag);
    if(!strcmp(tag, "samples\0")){ *sample = atol(arr[1]); }
    if(!strcmp(tag, "lines\0")){   *line   = atol(arr[1]); }
  }
  
  fclose(fin);
  return 0;
}

int ReadENVIBinaryfloat(const char* file_bin, const long sample, const long line, float** bin){
  // Read Binary
  long sz = sample * line;
  *bin = (float*)malloc(sizeof(float) * sz);
  if(bin == NULL){
    printf("ERROR::ReadENVIBinaryfloat:Memory allocation fail.\n");
    exit(EXIT_FAILURE);
  }
  
  // Read header
  FILE* fin = fopen(file_bin, "rb");
  
  //check if file exists
  if(fin == NULL){
    printf("ERROR::ReadENVIBinaryfloat:file does not exists %s\n", file_bin);
    exit(EXIT_FAILURE);
  }
  fread(*bin, sizeof(float), sz, fin); // read 10 bytes to our buffer
  fclose(fin);
  
  return 0;
}

int ReadENVIfloat(const char* file_bin, float** bin, long* sample, long* line){
  // Get binary file name
  char file_hdr[200];
  strcpy(file_hdr, file_bin);
  strcat(file_hdr, ".hdr");
  
  // Read ENVI sample & line
  int IsOKHdr = GetENVIHeaderSampleLine(file_hdr, sample, line);
  if(IsOKHdr != 0){
    return 1;
  }
  
  // Read Binary
  int IsOKBin = ReadENVIBinaryfloat(file_bin, *sample, *line, bin);
  
  if(IsOKBin != 0){
    return 1;
  }else{
    return 0;
  }
}

int WriteENVIHeader(const char* file, const char* name, const long sample, const long line){
  // Write ASCII
  FILE* fout = fopen(file, "wb");
  
  //check if file exists
  if(fout == NULL){
    printf("ERROR::WriteENVIHeader:file does not exists %s\n", file);
    exit(EXIT_FAILURE);
  }
  
  fprintf(fout, "ENVI\n");
  fprintf(fout, "description = {\n");
  fprintf(fout, "PolSARpro File Imported to ENVI}\n");
  fprintf(fout, "samples = %ld\n", sample);
  fprintf(fout, "lines   = %ld\n", line);
  fprintf(fout, "bands   = 1\n");
  fprintf(fout, "header offset = 0\n");
  fprintf(fout, "file type = ENVI Standard\n");
  fprintf(fout, "data type = 4\n");
  fprintf(fout, "interleave = bsq\n");
  fprintf(fout, "sensor type = Unknown\n");
  fprintf(fout, "byte order = 0\n");
  fprintf(fout, "band names = {\n");
  fprintf(fout, "%s }\n", name);
  
  fclose(fout);

  return 0;
}

int WriteBinary(const char* file, const float* dat, const long N){
  // Write Binary
  FILE* fout = fopen(file, "wb");
  
  //check if file exists
  if(fout == NULL){
    printf("ERROR::WriteBinary:file does not exists %s\n", file);
    exit(EXIT_FAILURE);
  }
  
  fwrite(dat, sizeof(float), N, fout);
  fclose(fout);
  
  return 0;
}

int WriteRGB(const char* file_R, const char* file_G, const char* file_B, const long sample, const long line,
       const float* R, const float* G, const float* B, const long N){
  
  // Write binary
  int IsOKR = WriteBinary(file_R, R, N);
  int IsOKG = WriteBinary(file_G, G, N);
  int IsOKB = WriteBinary(file_B, B, N);
  
  char file_R_hdr[100];
  char file_G_hdr[100];
  char file_B_hdr[100];
  strcpy(file_R_hdr, file_R);
  strcpy(file_G_hdr, file_G);
  strcpy(file_B_hdr, file_B);
  strcat(file_R_hdr, ".hdr");
  strcat(file_G_hdr, ".hdr");
  strcat(file_B_hdr, ".hdr");
  
  // Write ENVI header
  int IsOKRhdr = WriteENVIHeader(file_R_hdr, "R.bin", sample, line);
  int IsOKGhdr = WriteENVIHeader(file_G_hdr, "G.bin", sample, line);
  int IsOKBhdr = WriteENVIHeader(file_B_hdr, "B.bin", sample, line);
  
  return IsOKR + IsOKG + IsOKB + IsOKRhdr + IsOKGhdr + IsOKBhdr;
}

void FindMinMax(const float* data, const long N, float* min, float* max){
  *min =  99999999;
  *max = -99999999;
  
  for(long i=0;i<N;++i){
    if(data[i] < *min){ *min = data[i]; }
    if(data[i] > *max){ *max = data[i]; }
  }
}

void HistogramCalc(const long Nbins, const long N, const float* data, long** hist, float** idx){
  // Find Min & Max
  float min, max;
  FindMinMax(data, N, &min, &max);
  
  // reset to zero
  for(long i=0; i<Nbins; ++i){
    (*hist)[i] = 0;
  }
  
  // bin width
  float d = (max - min)/((float)Nbins - 1);
  
  // make index series
  for(long i=0; i<Nbins; ++i){
    (*idx)[i] = (float)i * d + min;
  }
  
  // Scan for each pixel
  for(long i=0; i<N; ++i){
    // Find which bin(index) needs to to count.
    float k = round((data[i] - d/2 - min) / d);  // same as IDL
    if(k < 0){ k = 0; }
    (*hist)[(long)k]++;
  }
}

void ReadY4R(const char* file_Pd, const char* file_Ps, const char* file_Pv, const char* file_Pc,  // input
       float** Pd, float** Ps, float** Pv, float** Pc, long* sample, long* line){        // output
  
  int IsOKPd = ReadENVIfloat(file_Pd, &*Pd, sample, line);
  int IsOKPs = ReadENVIfloat(file_Ps, &*Ps, sample, line);
  int IsOKPv = ReadENVIfloat(file_Pv, &*Pv, sample, line);
  int IsOKPc = ReadENVIfloat(file_Pc, &*Pc, sample, line);
  
  if(IsOKPd != 0){
    printf("ReadY4R::ERROR:Read Pd : %s\n", file_Pd);
    exit(EXIT_FAILURE);
  }
  
  if(IsOKPs != 0){
    printf("ReadY4R::ERROR:Read Ps : %s\n", file_Ps);
    exit(EXIT_FAILURE);
  }
  
  if(IsOKPv != 0){
    printf("ReadY4R::ERROR:Read Pv : %s\n", file_Pv);
    exit(EXIT_FAILURE);
  }
  
  if(IsOKPc != 0){
    printf("ReadY4R::ERROR:Read Pc : %s\n", file_Pc);
    exit(EXIT_FAILURE);
  }
}

double total(const long* hist, const long Nbins){
  // Get total
  double sum = 0;
  for(long i=0;i<Nbins;++i){
    sum += hist[i];
  }
  return sum;
}

long FindNearestIndex(const double* cum, const long Nbins, const double value){
  double diff, d = 99999999999;
  long idx = 0;
  for(long i=0;i<Nbins;++i){
    diff = fabs(cum[i] - value);
    if(diff < d){
      idx = i;
      d = diff;
    }
  }
  return idx;
}

void GetHistogramBoundary(float** array, const long N, const float truncate_percent, const long NBINS,  // input
              float* min_val, float* max_val, int SHOW){                  // output
  // Get histogram
  long* hist;
  float* idx;
  
  // Memory allocate
  hist = (long*)malloc(NBINS * sizeof(long));
  if(hist == NULL){
    printf("GetHistogramBoundary::ERROR:Memory allocation 'hist' fail.\n");
    exit(EXIT_FAILURE);
  }
  
  idx = (float*)malloc(NBINS * sizeof(float));
  if(idx == NULL){
    printf("GetHistogramBoundary::ERROR:Memory allocation 'idx' fail.\n");
    exit(EXIT_FAILURE);
  }
  
  HistogramCalc(NBINS, N, *array, &hist, &idx);

  // Calculate cumulate density function
  double sum = total(hist, NBINS);
  double* cum = (double*)malloc(NBINS * sizeof(double));
  for(long i=0;i<NBINS;++i){
    cum[i] = hist[i] / sum;
  }
  for(long i=1;i<NBINS;++i){
    cum[i] += cum[i-1];
  }
  
  // Find boundary
  long idx_min = FindNearestIndex(cum, NBINS, truncate_percent/100.);
  long idx_max = FindNearestIndex(cum, NBINS, (100.-truncate_percent)/100.);
  *min_val = idx[idx_min];
  *max_val = idx[idx_max];
  
  if(SHOW != 0){
    printf("======================================\n");
    printf(" In %f%% truncated : \n", truncate_percent);
    printf("     Minimum value = %f\n", *min_val);
    printf("     Maximum value = %f\n", *max_val);
  }
 
  free(hist);
  free(idx);
  free(cum);
}

float Max(const float v1, const float v2, const float v3, const float v4){
  float val = v1;
  if(v2 > val){ val = v2; }
  if(v3 > val){ val = v3; }
  if(v4 > val){ val = v4; }
  return val;
}

float Max3(const float v1, const float v2, const float v3){
  float val = v1;
  if(v2 > val){ val = v2; }
  if(v3 > val){ val = v3; }
  return val;
}

float Min3(const float v1, const float v2, const float v3){
  float val = v1;
  if(v2 < val){ val = v2; }
  if(v3 < val){ val = v3; }
  return val;
}

void Scale(const float* in, const long N, const float min_val, const float max_val, float** out){
  float min_in, max_in;
  FindMinMax(in, N, &min_in, &max_in);
  
  for(long i=0;i<N;++i){
    (*out)[i] = (max_val-min_val)/(max_in-min_in) * (in[i]-min_in) + min_val;
  }
}

float deg2rad(const float deg){
  return deg/180.*PI;
}

void Invert(const float in[9], float out[9]){
  // computes the inverse of a matrix in
  double det = in[0] * (in[4] * in[8] - in[5] * in[7]) -
  in[3] * (in[1] * in[8] - in[7] * in[2]) +
  in[6] * (in[1] * in[5] - in[4] * in[2]);
  
  double invdet = 1 / det;
  
  out[0] = (in[4] * in[8] - in[5] * in[7]) * invdet;
  out[3] = (in[6] * in[5] - in[3] * in[8]) * invdet;
  out[6] = (in[3] * in[7] - in[6] * in[4]) * invdet;
  out[1] = (in[7] * in[2] - in[1] * in[8]) * invdet;
  out[4] = (in[0] * in[8] - in[6] * in[2]) * invdet;
  out[7] = (in[1] * in[6] - in[0] * in[7]) * invdet;
  out[2] = (in[1] * in[5] - in[2] * in[4]) * invdet;
  out[5] = (in[2] * in[3] - in[0] * in[5]) * invdet;
  out[8] = (in[0] * in[4] - in[1] * in[3]) * invdet;
}

void MatrixMultiply(const float M[9], const float v[3], float o[3]){
  o[0] = M[0]*v[0] + M[1]*v[1] + M[2]*v[2];
  o[1] = M[3]*v[0] + M[4]*v[1] + M[5]*v[2];
  o[2] = M[6]*v[0] + M[7]*v[1] + M[8]*v[2];
}

void MatrixMultiply2(const float M[9], const float v0, const float v1, const float v2,
           float* o0, float* o1, float* o2){
  *o0 = M[0]*v0 + M[1]*v1 + M[2]*v2;
  *o1 = M[3]*v0 + M[4]*v1 + M[5]*v2;
  *o2 = M[6]*v0 + M[7]*v1 + M[8]*v2;
}

void GetRGBModel_CIERGB(RGBModel* M){
  M->R[0] = 0.735; M->R[1] = 0.265; M->R[2] = 1 - M->R[0] - M->R[1];
  M->G[0] = 0.274; M->G[1] = 0.717; M->G[2] = 1 - M->G[0] - M->G[1];
  M->B[0] = 0.167; M->B[1] = 0.009; M->B[2] = 1 - M->B[0] - M->B[1];
  M->RefWhiteRGB[0] = 1; M->RefWhiteRGB[1] = 1; M->RefWhiteRGB[2] = 1;
  M->Gamma =  2.2;
  
  float m[9], mi[9];
  m[0] = M->R[0]/M->R[1]; m[1] = M->G[0]/M->G[1]; m[2] = M->B[0]/M->B[1];
  m[3] = M->R[1]/M->R[1]; m[4] = M->G[1]/M->G[1]; m[5] = M->B[1]/M->B[1];
  m[6] = M->R[2]/M->R[1]; m[7] = M->G[2]/M->G[1]; m[8] = M->B[2]/M->B[1];
  
  Invert(m, mi);
  float srgb[3];
  MatrixMultiply(mi, M->RefWhiteRGB, srgb);

  for(int j=0;j<3;++j){
    for(int i=0;i<3;++i){
      M->MtxRGB2XYZ[j*3+i] = srgb[i] * m[j*3+i];
    }
  }
  
  Invert(M->MtxRGB2XYZ, M->MtxXYZ2RGB);
}

void GetRefWhite_D50(float RefWhite[3]){
  RefWhite[0] = 0.96422;
  RefWhite[1] = 1;
  RefWhite[2] = 0.82521;
}

void GetAdaptation_Bradford(Adaptation* A){
  A->MtxAdaptMa[0] =  0.8951; A->MtxAdaptMa[3] = -0.7502; A->MtxAdaptMa[6] =  0.0389;
  A->MtxAdaptMa[1] =  0.2664; A->MtxAdaptMa[4] =  1.7135; A->MtxAdaptMa[7] = -0.0685;
  A->MtxAdaptMa[2] = -0.1614; A->MtxAdaptMa[5] =  0.0367; A->MtxAdaptMa[8] =  1.0296;
  A->AdaptationIndex = 0;
  // Invert 3x3 matrix
  Invert(A->MtxAdaptMa, A->MtxAdaptMaI);
}

float Cubed(const float in){
  return in*in*in;
}

void Lab2XYZ(const float Lab[3], const float RefWhite[3], float XYZ[3]){
  float kE = 216. / 24389.;
  float kK = 24389 / 27.;
  float kKE = 8;
  float fxyz[3], fx3, fz3;
  
  fxyz[1] = (Lab[0] + 16.)/116.;
  fxyz[0] = 0.002 * Lab[1] + fxyz[1];
  fxyz[2] = fxyz[1] - 0.005 * Lab[2];
  
  fx3 = Cubed(fxyz[0]);
  fz3 = Cubed(fxyz[2]);
  
  XYZ[0] = (fx3 > kE)? fx3 : ((116. * fxyz[0] - 16.) / kK);
  XYZ[1] = (Lab[0] > kKE)? Cubed((Lab[0] + 16.) / 116.) : (Lab[0] / kK);
  XYZ[2] = (fz3 > kE)? fz3 : ((116. * fxyz[2] - 16.) / kK);
  
  XYZ[0] *= RefWhite[0];
  XYZ[1] *= RefWhite[1];
  XYZ[2] *= RefWhite[2];
}

void RGBLinear2NonLinear(const float RGB[3], const float Gamma,  float compRGB[3]){
  // Convert from linear to non-linear RGB
  float R = RGB[0];
  float G = RGB[1];
  float B = RGB[2];
  
  if(Gamma > 0){
    R = (R > 1)? 1:R; R = (R < 0)? 0:R;
    G = (G > 1)? 1:G; G = (G < 0)? 0:G;
    B = (B > 1)? 1:B; B = (B < 0)? 0:B;
    
    compRGB[0] = pow(R, 1./Gamma);
    compRGB[1] = pow(G, 1./Gamma);
    compRGB[2] = pow(B, 1./Gamma);
    }else{
    // Change negtive to positive
    
    float sR, sG, sB;
    
    sR = (RGB[0] < 0)? -1:1;
    sG = (RGB[1] < 0)? -1:1;
    sB = (RGB[2] < 0)? -1:1;
    compRGB[0] = sR * RGB[0];
    compRGB[1] = sG * RGB[1];
    compRGB[2] = sB * RGB[2];
    
    if(Gamma < 0){
      // sRGB
      // R
      if(compRGB[0] < 0.0031308){
        compRGB[0] *= 12.92;
      }else{
        compRGB[0] = 1.055 * powf(compRGB[0], (1/2.4) - 0.055);
      }
      // G
      if(compRGB[1] < 0.0031308){
        compRGB[1] *= 12.92;
      }else{
        compRGB[1] = 1.055 * powf(compRGB[1], (1/2.4) - 0.055);
      }
      // B
      if(compRGB[2] < 0.0031308){
        compRGB[2] *= 12.92;
      }else{
        compRGB[2] = 1.055 * powf(compRGB[2], (1/2.4) - 0.055);
      }
    }else{
      // L*
      // R
      if(compRGB[0] < (216./24389.)){
        compRGB[0] = compRGB[0] * 24389./2700.;
      }else{
        compRGB[0] = 1.16 * powf(compRGB[0], (1/3.) - 0.16);
      }
      // G
      if(compRGB[1] < (216./24389.)){
        compRGB[1] = compRGB[1] * 24389./2700.;
      }else{
        compRGB[1] = 1.16 * powf(compRGB[1], (1/3.) - 0.16);
      }
      // B
      if(compRGB[2] < (216./24389.)){
        compRGB[2] = compRGB[2] * 24389./2700.;
      }else{
        compRGB[2] = 1.16 * powf(compRGB[2], (1/3.) - 0.16);
      }
      // sign back
      compRGB[0] *= sR;
      compRGB[1] *= sG;
      compRGB[2] *= sB;
    }
  }
}

void XYZ2RGB(const float XYZ[3], const RGBModel* M, const float RefWhite[3], const Adaptation* A,  float RGB[3]){                    // output
  float s[3], d[3];
  float rgb[3];
  
  float xyz[3];
  
  if(A->AdaptationIndex != 3){
    MatrixMultiply(A->MtxAdaptMa, RefWhite, s);
    MatrixMultiply(A->MtxAdaptMa, M->RefWhiteRGB, d);
    
    MatrixMultiply(A->MtxAdaptMa, XYZ, rgb);
    rgb[0] *= (d[0]/s[0]); rgb[1] *= (d[1]/s[1]); rgb[2] *= (d[2]/s[2]);
    MatrixMultiply(A->MtxAdaptMaI, rgb, xyz);
  }else{
    printf("ERROR::XYZ2RGB:AdaptationIndex == 3 is not support\n");
    exit(EXIT_FAILURE);
  }
  
  MatrixMultiply(M->MtxXYZ2RGB, xyz, rgb);
  RGBLinear2NonLinear(rgb, M->Gamma, RGB);
}

void Lab2RGB(const float Lab[3], const RGBModel* M, const float RefWhite[3], const Adaptation* A, float RGB[3]){
  float XYZ[3];
  Lab2XYZ(Lab, RefWhite, XYZ);
  XYZ2RGB(XYZ, M, RefWhite, A, RGB);
}

//+------------------------------------------------------------------------------------------------------------------------+
//|                                                                                                                        |
//|                                                        MAIN                                                            |
//|                                                                                                                        |
//+------------------------------------------------------------------------------------------------------------------------+
int main(int argc, const char * argv[]) {

  if(argc < 7){
    printf("+--------------+\n");
    printf("|     Usage    |\n");
    printf("+--------------+\n");
    printf("file_hdr_Dbl        : [in] Yamaguchi4_Y4R_Dbl.bin\n");
    printf("file_hdr_Odd        : [in] Yamaguchi4_Y4R_Odd.bin\n");
    printf("file_hdr_Vol        : [in] Yamaguchi4_Y4R_Vol.bin\n");
    printf("file_hdr_Hlx        : [in] Yamaguchi4_Y4R_Hlx.bin\n");
    printf("file_R              : [out] R.bin\n");
    printf("file_G              : [out] G.bin\n");
    printf("file_B              : [out] B.bin\n");
    printf("truncate_percent_L  : [Optional] Truncated value in percent for L-axis, default = 0.01(empty or type '-')\n");
    printf("truncate_percent_ab : [Optional] Truncated value in percent for ab-plane, default = 15.0(empty or type '-')\n");
    printf("NBINS               : [Optional] Number of bin for histogram calculation, default = 32768(empty or type '-')\n");
    exit(EXIT_SUCCESS);
  }

  // Input arguments
  const char* file_Dbl = argv[1];
  const char* file_Odd = argv[2];
  const char* file_Vol = argv[3];
  const char* file_Hlx = argv[4];
  const char* file_R = argv[5];
  const char* file_G = argv[6];
  const char* file_B = argv[7];
  float truncate_percent_L = 0.01;
  float truncate_percent_ab = 15.0;
  long NBINS = 32768;
  
  if(argc > 8){
    if(strcmp(argv[8], "-") == 0){
      truncate_percent_L = 0.01;
    }else{
      truncate_percent_L = atof(argv[8]);
    }
  }
  
  if(argc > 9){
    if(strcmp(argv[9], "-") == 0){
      truncate_percent_ab = 15.0;
    }else{
      truncate_percent_ab = atof(argv[9]);
    }
  }
  
  if(argc > 10){
    if(strcmp(argv[10], "-") == 0){
      NBINS = 32768;
    }else{
      NBINS = atol(argv[10]);
    }
  }
  
  // Variables
  float *Pd, *Ps, *Pv, *Pc, *Tp;
  long sample, line, sz;
  
  
  // Read Y4R binary
  ReadY4R(file_Dbl, file_Odd, file_Vol, file_Hlx, &Pd, &Ps, &Pv, &Pc, &sample, &line);
  
  // Get Total power
  sz = sample * line;
  Tp = (float*)malloc(sizeof(float) * sz);
  for(int i=0;i<sz;++i){
    Tp[i] = Pd[i] + Ps[i] + Pv[i] + Pc[i];
  }
  
  // CIE-Lab enhancement
  float A_min = -128;
  float A_max =  127;
  float B_min = -128;
  float B_max =  127;
  
  float Tp_min, Tp_max, Ps_min, Ps_max, Pd_min, Pd_max, Pv_min, Pv_max, Pc_min, Pc_max;
  FindMinMax(Tp, sz, &Tp_min, &Tp_max);
  FindMinMax(Ps, sz, &Ps_min, &Ps_max);
  FindMinMax(Pd, sz, &Pd_min, &Pd_max);
  FindMinMax(Pv, sz, &Pv_min, &Pv_max);
  FindMinMax(Pc, sz, &Pc_min, &Pc_max);
  
  printf("+-----------------------+\n");
  printf("|       Original        |\n");
  printf("+-----------------------+\n");
  printf("TP : [%f,%f]\n", Tp_min, Tp_max);
  printf("--\n");
  printf("Ps : [%f,%f]\n", Ps_min, Ps_max);
  printf("Pd : [%f,%f]\n", Pd_min, Pd_max);
  printf("Pv : [%f,%f]\n", Pv_min, Pv_max);
  printf("Pc : [%f,%f]\n", Pc_min, Pc_max);
  
  // Get boundaries
  float rg_L_min, rg_L_max, rg_ab_min, rg_ab_max;
  GetHistogramBoundary(&Tp, sz, truncate_percent_L,  NBINS, &rg_L_min,  &rg_L_max,  0);
  GetHistogramBoundary(&Tp, sz, truncate_percent_ab, NBINS, &rg_ab_min, &rg_ab_max, 0);
  
  //+-----------------------------------------------------------------------------+
  //|                           L-axis boundary trim                              |
  //+-----------------------------------------------------------------------------+
  for(long i=0;i<sz;++i){
    // minimun constrain
    if(Tp[i] < rg_L_min){
      Ps[i] = Ps[i] * (rg_L_min / Tp[i]);
      Pd[i] = Pd[i] * (rg_L_min / Tp[i]);
      Pv[i] = Pv[i] * (rg_L_min / Tp[i]);
      Pc[i] = Pc[i] * (rg_L_min / Tp[i]);
      Tp[i] = rg_L_min;
    }
    // maximun constrain
    if(Tp[i] > rg_L_max){
      Ps[i] = Ps[i] / Tp[i] * rg_L_max;
      Pd[i] = Pd[i] / Tp[i] * rg_L_max;
      Pv[i] = Pv[i] / Tp[i] * rg_L_max;
      Pc[i] = Pc[i] / Tp[i] * rg_L_max;
      Tp[i] = rg_L_max;
    }
  }
  
  //
  // Boundary values of L-axis
  //
  float LRg = 100.0 - truncate_percent_L * 2.0;
  float LMin = (100.0 - LRg) / 2.0;
  float LMax = 100.0 - LMin;
  
  FindMinMax(Tp, sz, &Tp_min, &Tp_max);
  FindMinMax(Ps, sz, &Ps_min, &Ps_max);
  FindMinMax(Pd, sz, &Pd_min, &Pd_max);
  FindMinMax(Pv, sz, &Pv_min, &Pv_max);
  FindMinMax(Pc, sz, &Pc_min, &Pc_max);
  
  printf("+---------------------------+\n");
  printf("|    Normalized (L-axis)    |\n");
  printf("+---------------------------+\n");
  printf("TP : [%f,%f]\n", Tp_min, Tp_max);
  printf("LRg: [%f,%f]\n", LMin, LMax);
  printf("--\n");
  printf("Ps : [%f,%f]\n", Ps_min, Ps_max);
  printf("Pd : [%f,%f]\n", Pd_min, Pd_max);
  printf("Pv : [%f,%f]\n", Pv_min, Pv_max);
  printf("Pc : [%f,%f]\n", Pc_min, Pc_max);
  
  //+-----------------------------------------------------------------------------+
  //|                          ab-plane boundary trm                              |
  //+-----------------------------------------------------------------------------+
  for(long i=0;i<sz;++i){
    if(Tp[i] > rg_ab_max){
      Ps[i] = Ps[i] / Tp[i] * rg_ab_max;
      Pd[i] = Pd[i] / Tp[i] * rg_ab_max;
      Pv[i] = Pv[i] / Tp[i] * rg_ab_max;
      Pc[i] = Pc[i] / Tp[i] * rg_ab_max;
    }
  }
  
  FindMinMax(Ps, sz, &Ps_min, &Ps_max);
  FindMinMax(Pd, sz, &Pd_min, &Pd_max);
  FindMinMax(Pv, sz, &Pv_min, &Pv_max);
  FindMinMax(Pc, sz, &Pc_min, &Pc_max);
  
  printf("+---------------------------+\n");
  printf("|   Normalized (ab-plane)   |\n");
  printf("+---------------------------+\n");
  printf("Ps : [%f,%f]\n", Ps_min, Ps_max);
  printf("Pd : [%f,%f]\n", Pd_min, Pd_max);
  printf("Pv : [%f,%f]\n", Pv_min, Pv_max);
  printf("Pc : [%f,%f]\n", Pc_min, Pc_max);
  
  //+-----------------------------------------------------------------------------+
  //|                          CIE-Lab composition                                |
  //+-----------------------------------------------------------------------------+
  float max_val = Max(Ps_max, Pd_max, Pv_max, Pc_max);
  
  for(long i=0;i<sz;++i){
    Tp[i] = 10*log10f(Tp[i]);
  }
  
  float* Lab0 = (float*)malloc(sz * sizeof(float));
  float* Lab1 = (float*)malloc(sz * sizeof(float));
  float* Lab2 = (float*)malloc(sz * sizeof(float));
  
  Scale(Tp, sz, LMin, LMax, &Lab0);
  
  for(long i=0;i<sz;++i){
    Lab1[i] = A_min * Pv[i] * cos(deg2rad(30))/max_val + A_max * Pd[i] * cos(deg2rad(30))/max_val;
    Lab2[i] = B_min * Ps[i]/max_val + B_max * ((Pv[i] + Pd[i])*cos(deg2rad(60)) + Pc[i])/max_val;
  }
  
  
  //+-----------------------------------------------------------------------------+
  //|                            Convert to CIE-RGB                               |
  //+-----------------------------------------------------------------------------+
  float* R = (float*)malloc(sz * sizeof(float));
  float* G = (float*)malloc(sz * sizeof(float));
  float* B = (float*)malloc(sz * sizeof(float));
  
  RGBModel M;
  float RefWhite[3];
  Adaptation A;
  
  GetRGBModel_CIERGB(&M);
  GetRefWhite_D50(RefWhite);
  GetAdaptation_Bradford(&A);
  
  
  float lab[3];
  float rgb[3];
  for(long i=0;i<sz;++i){
    lab[0] = Lab0[i]; lab[1] = Lab1[i]; lab[2] = Lab2[i];
    Lab2RGB(lab, &M, RefWhite, &A, rgb);
    R[i] = rgb[0] * 255;
    G[i] = rgb[1] * 255;
    B[i] = rgb[2] * 255;
  }
  
  // Assign max & min around the corner
  // 1. Find global max & min
  float Rmin, Rmax, Gmin, Gmax, Bmin, Bmax;
  FindMinMax(R, sz, &Rmin, &Rmax);
  FindMinMax(G, sz, &Gmin, &Gmax);
  FindMinMax(B, sz, &Bmin, &Bmax);
  
  float minVal = Min3(Rmin, Gmin, Bmin);
  float maxVal = Max3(Rmax, Gmax, Bmax);
  
  R[0] = minVal; G[0] = minVal; B[0] = minVal;
  R[1] = maxVal; G[1] = maxVal; B[1] = maxVal;
  
  
  // Write to disk
  WriteRGB(file_R, file_G, file_B, sample, line, R, G, B, sz);
  
  
  
  
  // Free memory
  free(Pd);
  free(Ps);
  free(Pv);
  free(Pc);
  free(Tp);
  free(Lab0);
  free(Lab1);
  free(Lab2);
  free(R);
  free(G);
  free(B);
  
  printf(">>> Everything is OK, Finish <<<\n");
    return 0;
}

