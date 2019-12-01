#version 130
uniform sampler2D texture;
uniform vec2 screenSize;
uniform vec2 imageSize;
uniform float selectPos;
uniform float rowHeight;
uniform float rows;
uniform float frameSize;
uniform float frameScale;
uniform float bias;

void main()
{
	//dummy value to prevent uniform errors in the console due to glsl compiler optimizations
	vec2 dummy = screenSize * vec2( 0.0, 0.0 );

	// Frame Coords
	vec2 uv = gl_TexCoord[0].xy + dummy;
	vec2 uvf = vec2( 0.5, 0.5 );
	vec2 snapRatio = gl_TexCoord[2].xy;
	vec2 frameRatio = gl_TexCoord[3].xy;

	float light = 220.0 / 255.0;
	float dark = 110.0 / 255.0;
	vec3 color_light = vec3( light, light, light ); //HardLight
	vec3 color_dark = vec3( dark, dark, dark ); //HardLight

	// slice1.xy top/left slice2.xy bottom/right
	vec2 slice1 = max( sign( frameRatio.xy - uv ), 0.0 );
	vec2 slice2 = max( sign( uv - ( 1.0 - frameRatio.xy )), 0.0 );

	uvf = mix( uvf, uv * frameScale / snapRatio, slice1 );
	uvf = mix( uvf, ( 1.0 - ( 1.0 * frameScale - uv * frameScale ) / snapRatio ), slice2 );

	vec4 frame_color = textureLod( texture, uvf, bias );

	float a, b;

	a = min( max( gl_TexCoord[0].y * imageSize.y + rowHeight / 2.0 - 0.5 - frameSize / 2.0, rowHeight * 2.0 ), rowHeight * ( rows + 3.0 ));
	a = mod( a, rowHeight );
	a = abs( a - rowHeight / 2.0);

	b = gl_TexCoord[0].y * imageSize.y - 0.5 - rowHeight * ( selectPos + 5.0 ) + rowHeight * 2.0 + rowHeight / 2.0 - frameSize / 2.0;
	b = abs( b ) - rowHeight / 2.0;

	// todo: multiply a and b to get thinner lines in non native layout resolutions
	a = clamp( 1.0 - min( a * 1.0, b * 1.0 ), 0.0, 1.0 );

	gl_FragColor = gl_Color * frame_color;
	gl_FragColor.xyz *= mix( color_light, color_dark, a );
	gl_FragColor *= gl_Color.w;
}
