#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

#include "PolSARproLib.h"

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
    edit_error("Wrong parameter type","");
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
  edit_error("Usage:\n",usage);
 }

 if(!found && required)
 {
  printf("\n The required argument %s could not be found\n",keyword);
  edit_error("Usage:\n",usage);
 }
  return found;
}

