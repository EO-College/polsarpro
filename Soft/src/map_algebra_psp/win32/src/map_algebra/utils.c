#include "utils.h"

const char* spin = "\\\\\\\\\\\\||||||||||//////////----------\0";
int spinId = 0;


char spc()
{
	spinId = (spinId + 1) % strlen(spin);
	return spin[spinId];
}

int fileExists(char* sciezka)
{
	struct stat buffer;	
	unsigned int i = 0;
	for (i = 0; i < strlen(sciezka); i++)
	{
		if (sciezka[i] == '\r' || sciezka[i] == '\n')
		{
			sciezka[i] = '\0';
			break;
		}
	}
	return (stat(sciezka, &buffer) == 0);
}
void tempFileRemove()
{		
//	unlink(tmpFile);
	//swallow errors :)
}

/*Modif EP - start*/
void PSP_check_file(char *file)
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

void PSP_check_dir(char *dir)
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
/*Modif EP - end*/
