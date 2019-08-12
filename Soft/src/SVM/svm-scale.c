/*
 * 
 * This function is based on the LIBSVM V2.29, and adapted to use binary file
 * 
 */
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "svm.h"
#include <unistd.h>
#include <math.h>
#include <time.h>
#include <float.h>

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/**********************************************************************/
/**********************************************************************/
/**********************************************************************/

void exit_with_help()
{
	printf(
	"Usage: svm-scale range_file input_bin output_bin number_of_polarimetric_indices\n"//CHANGE
	);
	exit(1);
}

char *line = NULL;
int max_line_len = 1024;
double lower=-1.0,upper=1.0,y_lower,y_upper;
int y_scaling = 0;
double *feature_max;
double *feature_min;
double y_max = -DBL_MAX;
double y_min = DBL_MAX;
int max_index;
long int num_nonzeros = 0;
long int new_num_nonzeros = 0;
int Npolar;/* Number of polarimetric indices used in the classification*/

#define max(x,y) (((x)>(y))?(x):(y))
#define min(x,y) (((x)<(y))?(x):(y))

float output_target(double value);
float output(int index, double value);
char* readline(FILE *input);


int main(int argc,char **argv)
{
	int i;
	FILE *out_put,*in_put, *fp_restore = NULL;
	char range_file[1024];
	char input_bin[1024], output_bin[1024];
	char *restore_filename = NULL;

    if (argc < 5) {
    printf("\n A processing error occured ! \n svm-scale_polsarpro range_file input_bin output_bin number_of_polarimetric_indices\n");
    exit(1);
    } else {
	strcpy(range_file, argv[1]);
	strcpy(input_bin, argv[2]);
	strcpy(output_bin, argv[3]);
	Npolar = atoi(argv[4]);
    }

	in_put=fopen(input_bin,"rb");
	if(in_put==NULL)
	{
		fprintf(stderr,"can't open input file %s\n", input_bin);
		exit(1);
	}

	out_put = fopen(output_bin,"wb");	
	if(out_put == NULL)
	{
		fprintf(stderr,"can't open output file %s\n",output_bin);
		exit(1);
	}

	if(Npolar<1)
	{
		fprintf(stderr,"the number of polarimetric indices is missing or to low\n");
		exit(1);
	}
	float pixel[Npolar + 1];

	if(!(upper > lower) || (y_scaling && !(y_upper > y_lower)))
	{
		fprintf(stderr,"inconsistent lower/upper specification\n");
		exit(1);
	}
	
	//if(restore_filename && range_file)
	if(restore_filename && (strcmp(range_file,"")!=0))
	{
		fprintf(stderr,"cannot use -r and -s simultaneously\n");
		exit(1);
	}

#define SKIP_TARGET\
	while(isspace(*p)) ++p;\
	while(!isspace(*p)) ++p;

#define SKIP_ELEMENT\
	while(*p!=':') ++p;\
	++p;\
	while(isspace(*p)) ++p;\
	while(*p && !isspace(*p)) ++p;
	

	/* pass 1: find out min/max value */
	feature_max = (double *)malloc((Npolar)* sizeof(double));
	feature_min = (double *)malloc((Npolar)* sizeof(double));

	if(feature_max == NULL || feature_min == NULL)
	{
		fprintf(stderr,"can't allocate enough memory\n");
		exit(1);
	}

	for(i=0;i<Npolar;i++)
	{
		feature_max[i]=-DBL_MAX;
		feature_min[i]=DBL_MAX;
	}	
	int k=0;

	while(fread(&pixel, sizeof(float), Npolar +1, in_put)!=0)
	{
		float *p=pixel;
		y_max = max(y_max,p[0]);
		y_min = min(y_min,p[0]);

		for(i=0;i<Npolar;i++)
			{
				feature_max[i]=max(feature_max[i],p[i+1]);
				feature_min[i]=min(feature_min[i],p[i+1]);
			}
		k++;
	}
	rewind(in_put);

	/* pass 1.5: save/restore feature_min/feature_max */
	
	if(restore_filename)
	{
		/* fp_restore rewinded in finding max_index */
		int idx, c;
		double fmin, fmax;
		
		if((c = fgetc(fp_restore)) == 'y')
		{
			if(fscanf(fp_restore, "%lf %lf\n", &y_lower, &y_upper));
			if(fscanf(fp_restore, "%lf %lf\n", &y_min, &y_max));
			y_scaling = 1;
		}
		else
			ungetc(c, fp_restore);

		if (fgetc(fp_restore) == 'x') {
			if(fscanf(fp_restore, "%lf %lf\n", &lower, &upper));
			while(fscanf(fp_restore,"%d %lf %lf\n",&idx,&fmin,&fmax)==3)
			{
				if(idx<=max_index)
				{
					feature_min[idx] = fmin;
					feature_max[idx] = fmax;
				}
			}
		}
		fclose(fp_restore);
	}

	//if(range_file)
    if (strcmp(range_file,"")!=0)
	{
		FILE *fp_save = fopen(range_file,"w");
		if(fp_save==NULL)
		{
			fprintf(stderr,"can't open file %s\n", range_file);
			exit(1);
		}
		if(y_scaling)
		{
			fprintf(fp_save, "y\n");
			fprintf(fp_save, "%.16g %.16g\n", y_lower, y_upper);
			fprintf(fp_save, "%.16g %.16g\n", y_min, y_max);
		}
		fprintf(fp_save, "x\n");
		fprintf(fp_save, "%.16g %.16g\n", lower, upper);
		for(i=0;i<Npolar;i++)
		{
			if(feature_min[i]!=feature_max[i])
				fprintf(fp_save,"%d %.16g %.16g\n",i+1,feature_min[i],feature_max[i]);
		}
		fclose(fp_save);
	}

	/* pass 2: scale */

	while(fread(&pixel, sizeof(float), Npolar +1, in_put)!=0)
	{
		float *p=pixel;
		float target;

		target = p[0];
		target = output_target(target);
		fwrite(&target, sizeof(float), 1, out_put);

		for (i= 1;i < Npolar + 1; i++)
		{
		p[i] = output(i-1,p[i]);
		fwrite(&p[i], sizeof(float), 1, out_put);
		}
	}

	free(feature_max);
	free(feature_min);
	fclose(in_put);
	fclose(out_put);
	return 0;
}

char* readline(FILE *input)
{
	int len;
	
	if(fgets(line,max_line_len,input) == NULL)
		return NULL;

	while(strrchr(line,'\n') == NULL)
	{
		max_line_len *= 2;
		line = (char *) realloc(line, max_line_len);
		len = (int) strlen(line);
		if(fgets(line+len,max_line_len-len,input) == NULL)
			break;
	}
	return line;
}


float output_target(double value)
{
	if(y_scaling)
	{
		if(value == y_min)
			value = y_lower;
		else if(value == y_max)
			value = y_upper;
		else value = y_lower + (y_upper-y_lower) *
			     (value - y_min)/(y_max-y_min);
	}
	return (float)value;
}

float output(int index, double value)
{
	/* skip single-valued attribute */
	if(feature_max[index] == feature_min[index])
		return 0;

	if(value == feature_min[index])
		value = lower;
	else if(value == feature_max[index])
		value = upper;
	else
		value = lower + (upper-lower) * 
			(value-feature_min[index])/
			(feature_max[index]-feature_min[index]);
return (float)value;
}
