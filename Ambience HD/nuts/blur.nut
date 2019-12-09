///////////////////////////////////////////////////
//
// Multipass Blur
// This is an internal part of
// Ambience HD theme for Attract-Mode Frontend
//
// by Oomek 2019
//
///////////////////////////////////////////////////

//TODO: dynamic resolution
local sizex = flw / 16
local sizey = flh / 16

iterations <- 8
surfaces <- []
shaders <- []
images <- []

//local kernels = [ 0,0.5,1,1,2,3,4,6,9,13,18,24,31,39,48,58 ]
local kernels = [ 0,0.5,1,1,2,3,4,6,9,13,18+2,24+4,31+8,39+16,48+32,58+64 ]

//Cloning snap from carrier. Check if it does improve performance
surfaces.push( fe.add_surface( sizex, sizey ))

images.push( surfaces[0].add_clone( g_snaps[1] ))
images.push( surfaces[0].add_clone( g_snaps[0] ))

images[0].set_pos( 0, 0, sizex, sizey )
images[1].set_pos( 0, 0, sizex, sizey )
images[0].visible = true
images[1].visible = true

surfaces[0].set_pos( -sizex, -sizey )
images[0].set_rgb( 255, 255, 255 )
images[1].set_rgb( 255, 255, 255 )
shaders.push( fe.add_shader( Shader.Fragment, "shaders/prefilter.frag" ))
shaders.push( fe.add_shader( Shader.Fragment, "shaders/prefilter.frag" ))
images[0].shader = shaders[0]
images[1].shader = shaders[1]
shaders[0].set_param( "texsize", images[0].texture_width, images[0].texture_height )
shaders[1].set_param( "texsize", images[1].texture_width, images[1].texture_height )

shaders[0].set_param( "theme", THEME_DARK )
shaders[1].set_param( "theme", THEME_DARK )

//Kawase Blur - Multipass
for ( local i = 1; i < iterations; i++ )
{
	surfaces.push( fe.add_surface( sizex, sizey ) )
	surfaces[i].set_pos(-sizex, -sizey)
	images.push( surfaces[i].add_image( "images/white.png", 0, 0, sizex, sizey ))
	shaders.push( fe.add_shader( Shader.Fragment, "shaders/kawaseblur.frag" ))
	shaders[ i + 1 ].set_param( "coords",  0, 0, sizex, sizey )
	shaders[ i + 1 ].set_param( "res",  sizex, sizey )
	shaders[ i + 1 ].set_param( "iter", kernels[i - 1] )
	shaders[ i + 1 ].set_texture_param( "background",  surfaces[ i - 1 ] )
	images[ i + 1 ].shader = shaders[ i + 1 ]
}

//Fullscreen Blurred
local radius = iterations - 1
local radius2 = 2 * iterations / 5.0
blurred <- fe.add_image( "images/white.png" 0, 0, flw, flh )
blurred.preserve_aspect_ratio = false
local shaderblurred = fe.add_shader( Shader.Fragment, "shaders/debandfilter.frag" )
shaderblurred.set_texture_param( "background",  surfaces[ radius ])
shaderblurred.set_param( "coords",  0, 0, sizex, sizey )
shaderblurred.set_param( "res",  sizex, sizey )
shaderblurred.set_param( "radius2", radius2 )
blurred.shader = shaderblurred
blurred.visible = true
