///////////////////////////////////////////////////
//
// Multipass Blur
// This is an internal part of
// Ambience HD theme for Attract-Mode Frontend
//
// by Oomek 2019
//
///////////////////////////////////////////////////

// TODO: dynamic resolution
blur_width <- flw / 16
blur_height <- flh / 16

blur_snaps <- []
blur_activeSnap <- 0
blur_snaps.push( fe.add_image( "images/background.png", 839, 448, 242, 242 ))
blur_snaps.push( fe.add_image( "images/background.png", 839, 448, 242, 242 ))
blur_snaps[0].mipmap = true
blur_snaps[1].mipmap = true
blur_snaps[0].preserve_aspect_ratio = false
blur_snaps[1].preserve_aspect_ratio = false
blur_snaps[0].video_flags = Vid.NoAutoStart
blur_snaps[1].video_flags = Vid.NoAutoStart
blur_snaps[0].visible = false
blur_snaps[1].visible = false

if ( my_config["snaps"] == "Snaps" )
{
	blur_snaps[0].video_flags = Vid.ImagesOnly
	blur_snaps[1].video_flags = Vid.ImagesOnly
}
else if ( my_config["snaps"] == "Videos Muted" )
{
	blur_snaps[0].video_flags = Vid.NoAudio | Vid.NoAutoStart
	blur_snaps[1].video_flags = Vid.NoAudio | Vid.NoAutoStart
}
else if ( my_config["snaps"] == "Videos" )
{
	blur_snaps[0].video_flags = Vid.NoAutoStart
	blur_snaps[1].video_flags = Vid.NoAutoStart
}

blur_iterations <- 8
blur_surfaces <- []
blur_shaders <- []
blur_images <- []

// local kernels = [ 0,0.5,1,1,2,3,4,6,9,13,18,24,31,39,48,58 ]
local kernels = [ 0,0.5,1,1,2,3,4,6,9,13,18+2,24+4,31+8,39+16,48+32,58+64 ]

blur_surfaces.push( fe.add_surface( blur_width, blur_height ))

blur_images.push( blur_surfaces[0].add_clone( blur_snaps[1] ))
blur_images.push( blur_surfaces[0].add_clone( blur_snaps[0] ))

blur_images[0].set_pos( 0, 0, blur_width, blur_height )
blur_images[1].set_pos( 0, 0, blur_width, blur_height )
blur_images[0].visible = true
blur_images[1].visible = true

blur_surfaces[0].set_pos( -blur_width, -blur_height )
blur_images[0].set_rgb( 255, 255, 255 )
blur_images[1].set_rgb( 255, 255, 255 )
blur_shaders.push( fe.add_shader( Shader.Fragment, "shaders/prefilter.frag" ))
blur_shaders.push( fe.add_shader( Shader.Fragment, "shaders/prefilter.frag" ))
blur_images[0].shader = blur_shaders[0]
blur_images[1].shader = blur_shaders[1]
blur_shaders[0].set_param( "texsize", blur_images[0].texture_width, blur_images[0].texture_height )
blur_shaders[1].set_param( "texsize", blur_images[1].texture_width, blur_images[1].texture_height )

blur_shaders[0].set_param( "theme", THEME_DARK )
blur_shaders[1].set_param( "theme", THEME_DARK )

// Kawase Blur - Multipass
for ( local i = 1; i < blur_iterations; i++ )
{
	blur_surfaces.push( fe.add_surface( blur_width, blur_height ) )
	blur_surfaces[i].set_pos(-blur_width, -blur_height)
	blur_images.push( blur_surfaces[i].add_image( "images/white.png", 0, 0, blur_width, blur_height ))
	blur_shaders.push( fe.add_shader( Shader.Fragment, "shaders/kawaseblur.frag" ))
	blur_shaders[ i + 1 ].set_param( "coords",  0, 0, blur_width, blur_height )
	blur_shaders[ i + 1 ].set_param( "res",  blur_width, blur_height )
	blur_shaders[ i + 1 ].set_param( "iter", kernels[i - 1] )
	blur_shaders[ i + 1 ].set_texture_param( "background",  blur_surfaces[ i - 1 ])
	blur_images[ i + 1 ].shader = blur_shaders[ i + 1 ]
}

// Fullscreen output texture with deband filter
blur_radius <- blur_iterations - 1
blur_radius2 <- 2 * blur_iterations / 5.0
blur_output <- fe.add_image( "images/white.png" 0, 0, flw, flh )
blur_output.preserve_aspect_ratio = false
blur_shaderDeband <- fe.add_shader( Shader.Fragment, "shaders/debandfilter.frag" )
blur_shaderDeband.set_texture_param( "background",  blur_surfaces[ blur_radius ])
blur_shaderDeband.set_param( "coords",  0, 0, blur_width, blur_height )
blur_shaderDeband.set_param( "res",  blur_width, blur_height )
blur_shaderDeband.set_param( "radius2", blur_radius2 )
blur_output.shader = blur_shaderDeband
blur_output.visible = true

blur_fadeAnim <- Animate( blur_images[1], "alpha", 10, 20, 1.05 )


function blur_reload_video()
{
	blur_snaps[ 1 - blur_activeSnap ].video_playing = false
	blur_snaps[ blur_activeSnap ].video_playing = false
	blur_fadeAnim.wait( blur_activeSnap * 255.0 )
	blur_activeSnap = 1 - blur_activeSnap

	if ( fe.list.size == 0 )
		blur_snaps[ blur_activeSnap ].file_name = "images/background.png"
	else
	{
		if ( my_config["snaps"] == "Snaps" )
			blur_snaps[ blur_activeSnap ].file_name = fe.get_art( "snap", 0, 0, Art.ImagesOnly )
		else
			blur_snaps[ blur_activeSnap ].file_name = fe.get_art( "snap" )
	}

	blur_shaders[0].set_param( "texsize", blur_images[0].texture_width, blur_images[0].texture_height )
	blur_shaders[1].set_param( "texsize", blur_images[1].texture_width, blur_images[1].texture_height )
}
