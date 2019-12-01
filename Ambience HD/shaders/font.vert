#version 130
uniform float width; // width in pixels of the rendertarget

void main()
{
    // transform the vertex position
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
    gl_Position.x = round((gl_Position.x / 2.0 + 0.499999) * width) / width * 2.0 - 1.0;

	//gl_Position.x = (gl_Position.x + 1.0) * 0.5 - 1.0;
	//gl_Position.y = (gl_Position.y - 1.0) * 0.5 + 1.0;

    // transform the texture coordinates
    gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;

    // forward the vertex color
    gl_FrontColor = gl_Color;
}

// uniform float width;

// void main()
// {
    // // transform the vertex position
    // gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
	// gl_Position.x = round(gl_Position.x * width ) / width;

    // // transform the texture coordinates
    // gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
	// //gl_TexCoord[0].x = ceil(gl_TexCoord[0].x * 20.0 ) / 20.0;

    // // forward the vertex color
    // gl_FrontColor = gl_Color;
// }
