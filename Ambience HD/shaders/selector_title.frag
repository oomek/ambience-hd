#version 130
uniform sampler2D texture;
uniform vec2 textureSize;
uniform vec2 imageSize;
uniform float scale;
void main()
{
	vec2 uv = gl_TexCoord[0].xy;
	uv.y = 1.0 - uv.y;
	uv.x *= 2.0 / ( textureSize.x * scale / imageSize.x );
	uv.y *= 2.0 / ( textureSize.y * scale / imageSize.y );
	uv.y = 1.0 - uv.y;
	float x = gl_TexCoord[2].x;
	vec4 pixel = texture2D( texture, uv );
	gl_FragColor = pixel * gl_Color;
	gl_FragColor.xyz *= gl_Color.www;
}
