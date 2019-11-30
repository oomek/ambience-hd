///////////////////////////////////////////////////
//
// This is an internal part of
// Ambience HD theme for Attract-Mode Frontend
//
// by Oomek 2019
//
///////////////////////////////////////////////////

class FrameImageSelector {
	image = null
	shader = null
	borderLeft = null
	borderRight = null
	borderTop = null
	borderBottom = null
	constructor ( file_name, x, y, w, h, _bl, _br = null, _bt = null, _bb = null, surface = null ) {
		borderLeft = _bl
		borderRight = _br
		borderTop = _bt
		borderBottom = _bb
		if ( surface == null ) surface = ::fe
		image = surface.add_image( file_name, x, y, w, h )
		image.mipmap = true
		shader = ::fe.add_shader( Shader.VertexAndFragment, "shaders/frame_selector.vert", "shaders/frame_selector.frag" )
		shader.set_param( "imageSize", image.width, image.height )
		shader.set_param( "textureSize", image.texture_width, image.texture_height )
		if ( borderRight == null || borderTop == null || borderBottom == null )
			shader.set_param( "frame", borderLeft, borderLeft, borderLeft, borderLeft )
		else
			shader.set_param( "frame", borderLeft, borderRight, borderTop, borderBottom )
		image.shader = shader
	}

	function set_pos( x, y, w = null, h = null ) {
		if ( w && h )
			image.set_pos( x, y, w, h )
		else
			image.set_pos( x, y )
	}

	function set_rgb( r, g, b ) {
		image.set_rgb( r, g, b )
	}

	function _get( idx ) {
		return image[idx]
	}

	function set_snap( name ) {
		shader.set_texture_param( "snap", name )
	}

	function set_blur( name ) {
		shader.set_texture_param( "blur", name )
	}

	function set_theme( t ) {
		shader.set_param( "theme", t )
	}

	function set_video( name ) {
		shader.set_texture_param( "video", name )
	}

	function set_video_alpha( value ) {
		shader.set_param( "videoAlpha", value )
	}

	function set_snap_size( x, y ) {
		shader.set_param( "snapSize", x, y )
	}

	function set_border( bl, br, bt, bb ) {
		borderLeft = bl
		borderRight = br
		borderTop = bt
		borderBottom = bb
		shader.set_param( "frame", bl, br, bt, bb )
	}

	function _set( idx, val ) {
		if ( idx == "width" || idx == "height" ) {
			if ( idx == "width" ) image.width = val
			if ( idx == "height" ) image.height = val
			shader.set_param( "imageSize", image.width, image.height )
		} else if ( idx == "preserve_aspect_ratio" ) {
			return false
		} else {
			image[idx] = val
		}
	}
}

::fe.add_frame_image_selector <- FrameImageSelector
