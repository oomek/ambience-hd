#version 130
uniform sampler2D texture;
uniform float radius;
uniform vec2 size;
uniform float position;
uniform vec4 colour;

float roundCorners( vec2 p, vec2 b, float r )
{
    return length( max( abs( p ) - b + r, 0.0 )) - r;
}

void main()
{
	vec2 uv = gl_TexCoord[0].xy;
	float text = texture2D( texture, uv ).w;
	vec2 halfRes = vec2( 0.5, 0.5 ) * vec2( size.y, size.y ) - vec2( 0.5, 0.5 );
	uv.x = ( uv.x * size.x - position ) / size.y;
	float b = clamp( 1.0 - roundCorners(( uv * size.y ) - 0.5 * size.y, halfRes, abs( radius )), 0.0, 1.0 );
    gl_FragColor.xyz = colour.xyz / 255.0;
	gl_FragColor.w = abs( text - b ) * colour.w / 255.0;
	gl_FragColor.xyz *= gl_FragColor.w;
	gl_FragColor.w *= gl_Color.w;
}
