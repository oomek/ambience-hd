#version 130
uniform vec2 screenSize;
uniform vec2 imageSize;
uniform vec2 textureSize;
uniform float frameSize;

void main()
{
	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
	gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
	gl_TexCoord[1].xy = gl_Vertex.xy / screenSize; // divide by screen size to have uv screen position
	gl_TexCoord[2].xy = textureSize / imageSize;
	gl_TexCoord[3].xy = frameSize / imageSize;
	gl_FrontColor = gl_Color;
}
