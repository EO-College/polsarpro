#version 120

uniform sampler2D tex; 
uniform float brightness;
uniform int bsize;
uniform vec2 texSize;
uniform vec3 rgbvalues;

void main(void)
{ 
	vec4 dst = vec4(0.0);
	for (float i = -bsize; i < bsize + 1; i+=1)
		for (float j = -bsize; j < bsize + 1; j+=1)
			dst += texture2D(tex, gl_TexCoord[0].st + vec2( i / texSize.x, j / texSize.y));

			
	
	dst.rgb /= (2*bsize+1)*(2*bsize+1);
	
	dst += vec4(brightness, brightness, brightness, 0.0);
	dst.rgb *= rgbvalues;

	gl_FragColor = dst;
}
  