#define GLEW_STATIC
#include <gl/glew.h>
#include <GL/freeglut.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>



static char *
shaderLoadSource(const char *filePath);
static GLuint
shaderCompileFromFile(GLenum type, const char *filePath);
void
shaderAttachFromFile(GLuint program, GLenum type, const char *filePath);