#version 130
#define PI 3.14159265359
uniform sampler2D texture;
uniform sampler2D background;
uniform vec4 coords;
uniform vec2 res;
uniform float radius;
uniform float radius2;
uniform float ttime;


float rndf( vec2 x )
{
    int n = int( x.x * 40.0 + x.y * 6400.0 );
    n = ( n << 13 ) ^ n;
    return 1.0 - float(( n * ( n * n * 15731 + 789221 ) + \
             1376312589 ) & 0x7fffffff ) / 1073741824.0;
}

void main()
{
	vec2 uv = vec2( gl_TexCoord[0].x, ( 1.0 - gl_TexCoord[0].y ));

	uv.x = uv.x / res.x * coords.z;
	uv.x = ( uv.x * res.x + coords.x ) / res.x;

	uv.y = uv.y / res.y * coords.w;
	uv.y = ( uv.y * res.y + res.y - coords.w - coords.y ) / res.y;

	vec2 rnd = vec2( rndf( gl_TexCoord[0].xy * 1000 + mod( ttime, 123 )) * radius2 / 1920, rndf( gl_TexCoord[0].yx * 1000 + mod( ttime, 234 )) * radius2 / 1080 );

	float alpha = texture2D( background, uv ).w;
	gl_FragColor = texture2D( background, uv + rnd * 5.0 ) * gl_Color;
	gl_FragColor.w = alpha * gl_Color.w;
}
