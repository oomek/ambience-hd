#version 130
uniform sampler2D texture;
uniform vec2 screenSize;
uniform vec2 crop;

void main()
{
	vec4 pixel = texture2D( texture, gl_TexCoord[0].xy );
	gl_FragColor = gl_Color * pixel;
	if ( gl_TexCoord[1].y < ( 1.0 - crop.y / screenSize.y * 2.0 )) discard;
	if ( gl_TexCoord[1].y > ( 1.0 - crop.x / screenSize.y * 2.0 )) discard;
}
