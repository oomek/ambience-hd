#version 130
uniform sampler2D texture;
uniform vec2 texsize;
uniform float theme;

void main()
{
	vec2 uv = vec2( (gl_TexCoord[0].x), gl_TexCoord[0].y);
	
	float texsizex = texsize.x;
	float texsizey = texsize.y;

	float offx = 0.5 / texsizex * 0.0; // 10.0 for debuging prefilter offset
	float offy = 0.5 / texsizey * 0.0; // 10.0
	
	vec4 base = vec4(0,0,0,0);

	base += texture2D(texture, uv + vec2(offx,offy));
	base += texture2D(texture, uv + vec2(offx,-offy));
	base += texture2D(texture, uv + vec2(-offx,offy));
	base += texture2D(texture, uv + vec2(-offx,-offy));
	base *= 0.25;

	vec3 light = gl_Color.xyz * base.xyz * vec3(0.5,0.5,0.5) + vec3(0.5,0.5,0.5);
	vec3 dark = gl_Color.xyz * base.xyz * vec3(0.33,0.33,0.33) + vec3(0.1,0.1,0.1);
	
	gl_FragColor.xyz = mix( light, dark, theme );
	
	//gl_FragColor.xyz = mix(gl_FragColor.xyz * (1.5 - uv.y), gl_FragColor.xyz, 0.75); 
	gl_FragColor.w = gl_Color.w * base.w;
}