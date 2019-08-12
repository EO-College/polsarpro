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
	int i = 0;
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
