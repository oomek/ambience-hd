//
// Attract-Mode Front-End
// Ambience HD theme - Frame Shader
// 2018, Oomek
//
#version 130
uniform sampler2D texture;
uniform sampler2D frame_image;
uniform sampler2D video;
uniform float videoAlpha;
uniform vec2 imageSize;
uniform vec2 textureSize;
uniform vec2 snapSize;
uniform vec4 frame;

float Smooth(float x) {
    return x + (x - (x * x * (3.0f - 2.0f * x)));
}

void main() {	
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

	vec4 snapColor = texture2D(texture, uvis);
	vec4 videoColor = texture2D(video, uvis);
	snapColor = mix(snapColor, videoColor, videoAlpha);

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
	
	vec4 frameColor = texture2D(frame_image, uv);
	frameColor.xyz *= gl_Color.xyz;// * sign(frameColor.w);// * max(sign(frameColor.w - 1.0/255.0), 0.0);// * sign(frameColor.w); //fixed png mask fringing while scrolling

	fadex = abs(0.5 - uvi.x) * cropSize.x - (cropSize.x + 1.0) / 2.0;	
	fadey = abs(0.5 - uvi.y) * cropSize.y - (cropSize.y + 1.0) / 2.0;

	fadex = 1.0 - clamp(fadex, 0.0, 1.0);
	fadey = 1.0 - clamp(fadey, 0.0, 1.0);

	float fade = 1.0 - fadex * fadey;

	//fade = Smooth(fade);
	

	
	//snapColor.w = 1.0 - (fade); // TEMP REM
	//frameColor.xyz *= floor(fade) * frameColor.w; //TEMP REM
	//frameColor.xyz *= frameColor.w; //TEMP REM
	snapColor.xyz *= 1.0 - floor(fade); //TEMP REM
	//frameColor.xyz *= floor(fade) * frameColor.w; //TEMP REM
	//frameColor.xyz *= max(floor(fade), 1.0 - fadey) * frameColor.w; //TEMP REM
	frameColor.xyz *= (1.0 - floor(fadey)) * frameColor.w; //TEMP REM
	//frameColor.xyz *= frameColor.w; //TEMP REM
	
//	gl_FragColor.xyz = snapColor.xyz; //debug
//	gl_FragColor.w = 1.0; //debug
//	return;
	
	//ALTERNATIVE AA
	//snapColor.xyz = mix(snapColor.xyz, frameColor.xyz, (fadey));
	//snapColor.xyz = mix(snapColor.xyz, frameColor.xyz, fade);
	//frameColor.xyz = mix(snapColor.xyz, frameColor.xyz, (fade));
	//frameColor.w = mix(snapColor.w, frameColor.w, floor(fade));
	//frameColor.xyz = mix(snapColor.xyz, frameColor.xyz, floor(fade));
	frameColor = mix(snapColor, frameColor, fade);
	//frameColor = FrameColor;
	//frameColor.w = mix(snapColor.w, frameColor.w, fade);
	gl_FragColor = frameColor;
	gl_FragColor.w *= gl_Color.w;
	gl_FragColor.xyz *= gl_Color.w; //Premultiplied
	//gl_FragColor.xyz = fade2; //debug
	//gl_FragColor.w = 1.0; //debug
	return;


	frameColor.xyz *= frameColor.w; // not sure if it's necessary
	frameColor.w *= fade;
	gl_FragColor.xyz = snapColor.xyz + frameColor.xyz * fade;
	gl_FragColor.w = snapColor.w + frameColor.w * fade;
	gl_FragColor.w *= gl_Color.w;
}
