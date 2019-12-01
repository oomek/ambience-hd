#version 130
uniform vec2 screenSize;

void main()
{
	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
	gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
	gl_TexCoord[1].xy = gl_Position.xy; // divide by screen size to have uv screen position
	gl_FrontColor = gl_Color;
}
