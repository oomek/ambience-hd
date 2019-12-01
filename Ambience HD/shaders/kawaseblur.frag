#version 130
uniform sampler2D texture;
uniform sampler2D background;
uniform vec4 coords;
uniform vec2 res;
uniform float iter;
uniform float ttime;

void main()
{
	vec2 uv = vec2( gl_TexCoord[0].x, ( 1.0 - gl_TexCoord[0].y ));
	
	uv.x = uv.x / res.x * coords.z;
	uv.x = (uv.x * res.x + coords.x ) / res.x;

	uv.y = uv.y / res.y * coords.w;
	uv.y = (uv.y * res.y + res.y - coords.w - coords.y ) / res.y;	
	
	vec2 texelSize = vec2( 1.0 / res );
	vec2 texelSize05 = texelSize * 0.5;
	
	vec2 uvOffset = texelSize.xy * vec2( iter, iter ) + texelSize05;
	
	vec2 texCoordSample;
	vec4 color;
	
	texCoordSample.x = uv.x - uvOffset.x;
	texCoordSample.y = uv.y + uvOffset.y;
	color = texture2D( background, texCoordSample );

	texCoordSample.x = uv.x + uvOffset.x;
	texCoordSample.y = uv.y + uvOffset.y;
	color += texture2D( background, texCoordSample );
	
	texCoordSample.x = uv.x + uvOffset.x;
	texCoordSample.y = uv.y - uvOffset.y;
	color += texture2D( background, texCoordSample );
	
	texCoordSample.x = uv.x - uvOffset.x;
	texCoordSample.y = uv.y - uvOffset.y;
	color += texture2D( background, texCoordSample );
	
	gl_FragColor.xyz = color.xyz * 0.25 * gl_Color.xyz;
	gl_FragColor.w = color.w * gl_Color.w;
}
