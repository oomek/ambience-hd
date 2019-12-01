#version 130
uniform float scale;
uniform vec2 position;
uniform float crop;

void main()
{
	vec4 vert = gl_Vertex;
    gl_Position = gl_ModelViewMatrix * vert;
	gl_Position.xy = (gl_Position.xy - position) * scale + gl_Position.xy;
    gl_Position = gl_ProjectionMatrix * gl_Position;
	gl_Position.x = clamp(gl_Position.x, -1.0, crop);
	gl_TexCoord[0] = normalize(gl_TextureMatrix[0] * gl_MultiTexCoord0);
    gl_FrontColor = gl_Color;
}
