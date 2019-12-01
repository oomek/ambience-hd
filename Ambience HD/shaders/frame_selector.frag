//
// Attract-Mode Front-End
// Ambience HD theme - Frame Shader
// 2018, Oomek
//
#version 130
uniform sampler2D texture;
uniform sampler2D snap;
uniform sampler2D blur;
uniform sampler2D video;
uniform float videoAlpha;
uniform vec2 imageSize;
uniform vec2 textureSize;
uniform vec2 snapSize;
uniform vec4 frame;
uniform float theme;

float Smooth(float x) {
    return x + (x - (x * x * (3.0f - 2.0f * x)));
}

void main() {
	vec2 uvb = gl_TexCoord[0].xy;
	uvb.y = 1.0 - uvb.y;
	vec3 blur = texture2D(blur, uvb).xyz;// * 0.975 + 0.66;
	blur = mix(blur * 0.75 + 0.4, blur * 0.975 + 0.66, theme);
	
	vec2 uv = gl_TexCoord[0].xy;
    vec2 ratio = textureSize / imageSize;
    vec4 frameRatio = (frame + 1.0) / imageSize.xxyy;
	vec2 scaler;
	float imageRatio = imageSize.x / imageSize.y; 
	float snapRatio = snapSize.x / snapSize.y; 
    
	vec2 uvi = uv;
	vec2 uvis = uv;
	
	uvis.y = (uvis.y * imageSize.y - frame.z) / (imageSize.y - frame.z - frame.w);
	uvis.x = (uvis.x * imageSize.x - frame.x) / (imageSize.x - frame.x - frame.y);

	vec2 cropSize = vec2(imageSize.x - frame.x - frame.y, imageSize.y - frame.z - frame.w); 
	float cropRatio = cropSize.x / cropSize.y;
	
	if (cropSize.x > (cropSize.y) * snapRatio) {
		uvis.y = uvis.y * snapRatio / cropRatio;
		uvis.y = uvis.y + (snapSize.y - ( snapSize.x * cropSize.y / cropSize.x) ) / snapSize.y / 2.0;
	}
	else {
		uvis.x = uvis.x / snapRatio * cropRatio;
		uvis.x = uvis.x + (snapSize.x - ( snapSize.y * cropSize.x / cropSize.y) ) / snapSize.x / 2.0;
	}

	uvi.y = (uvi.y * imageSize.y - frame.z - 1.0) / (imageSize.y - frame.z - frame.w - 2.0);
	uvi.x = (uvi.x * imageSize.x - frame.x - 1.0) / (imageSize.x - frame.x - frame.y - 2.0);
	cropSize = vec2(imageSize.x - frame.x - frame.y - 2.0, imageSize.y - frame.z - frame.w - 2.0); 

	vec4 snapColor = texture2D(snap, uvis);
	vec4 videoColor = texture2D(video, uvis);
	snapColor = mix(snapColor, videoColor, pow(videoAlpha, 16)); //delay to hide source video fadein
	//snapColor = mix(snapColor, videoColor, max(videoAlpha * 32 - 31, 0.0)); // to linear

	float fadex = 0.0;
	float fadey = 0.0;

    if (uv.x < frameRatio.x)
        uv.x = uv.x / ratio.x;
    
    else if (uv.x > (1.0 - frameRatio.y))
        uv.x = 1.0 - (1.0 - uv.x) / ratio.x;
        
    else {
        scaler.x = ((frame.x + 1.0) * (textureSize.x - imageSize.x)) / (textureSize.x * (frame.x + frame.y + 2.0 - imageSize.x));
        scaler.y = ((frame.y + 1.0) * (textureSize.x - imageSize.x)) / (textureSize.x * (frame.x + frame.y + 2.0 - imageSize.x));
		uv.x = uv.x * (1.0 - scaler.x - scaler.y) + scaler.x;
    }
    
    if (uv.y < frameRatio.z)
        uv.y = uv.y / ratio.y;
    
    else if (uv.y > (1.0 - frameRatio.w))
        uv.y = 1.0 - (1.0 - uv.y) / ratio.y;

    else {
        scaler.x = ((frame.z + 1.0) * (textureSize.y - imageSize.y)) / (textureSize.y * (frame.z + frame.w + 2.0 - imageSize.y));
        scaler.y = ((frame.w + 1.0) * (textureSize.y - imageSize.y)) / (textureSize.y * (frame.z + frame.w + 2.0 - imageSize.y));
		uv.y = uv.y * (1.0 - scaler.x - scaler.y) + scaler.x;
    }
	
	blur.xyz = mix(vec3(1.0,1.0,1.0), blur.xyz, videoAlpha); //new, fade blur when small
	
	vec4 frameColor = texture2D(texture, uv);
	frameColor.xyz = frameColor.xyz * blur.xyz * gl_Color.xyz;
	
	frameColor *= videoAlpha * 0.1 + 0.9; //new, fade blur when small
	
	fadex = abs(0.5 - uvi.x) * cropSize.x - (cropSize.x + 1.0) / 2.0;	
	fadey = abs(0.5 - uvi.y) * cropSize.y - (cropSize.y + 1.0) / 2.0;

	fadex = 1.0 - clamp(fadex, 0.0, 1.0);
	fadey = 1.0 - clamp(fadey, 0.0, 1.0);
	
	float fade = 1.0 - fadex * fadey;
	//fade = Smooth(fade);
		
	snapColor.w = 1.0 - fade;
	snapColor.xyz *= snapColor.w;
	
	//frameColor.xyz *= frameColor.w; // not sure if it's necessary
	
	gl_FragColor.xyz = snapColor.xyz + frameColor.xyz * fade;
	gl_FragColor.w = snapColor.w + frameColor.w * fade;
	gl_FragColor.w *= gl_Color.w;
	gl_FragColor.xyz *= gl_Color.w;

	//DEBUG blur burnout ( colors > 1.0 )
	// if (gl_FragColor.x > 1.0) gl_FragColor.x = 0;
	// if (gl_FragColor.y > 1.0) gl_FragColor.y = 0;
	// if (gl_FragColor.z > 1.0) gl_FragColor.z = 0;
}
