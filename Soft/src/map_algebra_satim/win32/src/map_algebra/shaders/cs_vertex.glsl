#version 120

varying vec4 Color;

void main(void)
{
	gl_Position = gl_Position = ftransform();	//
	gl_TexCoord[0] = gl_MultiTexCoord0;
	Color = gl_Color;
}