///////////////////////////////////////////////////
//
// This is an internal part of
// Ambience HD theme for Attract-Mode Frontend
//
// by Oomek 2019
//
///////////////////////////////////////////////////

class TextScaled
{
	fe = ::fe
	text_ = null
    shader_ = null
	width_ = null
	height_ = null
    constructor ( _text, _x, _y, _w, _h, _font, _surface = null )
    {
        if ( _surface == null ) _surface = fe
        text_ = _surface.add_text( _text, _x, _y, _w, _h )
		text_.font = _font
		text_.charsize = _h
		width_ = _w
		height_ = text_.height
		shader_ = fe.add_shader( Shader.Vertex, "shaders/text_scaled.vert" )
        shader_.set_param( "scale", 0.0 )
        shader_.set_param( "position", text_.x, text_.y )
        text_.shader = shader_
	}

    function set_pos( x, y, w = null, h = null )
    {
        if ( w && h )
            text_.set_pos( x, y, w, h )
        else
            text_.set_pos( x, y )
    }

	function set_rgb( r, g, b )
    {
		text_.set_rgb( r, g, b )
	}

	function set_bg_rgb( r, g, b )
    {
		text_.set_bg_rgb( r, g, b )
	}

    function _get( idx )
    {
           return text_[idx]
	}

    function _set( idx, val )
    {
        if ( idx == "x" || idx == "y" || idx == "width" || idx == "height" )
        {
            if ( idx == "x" ) text_.x = val
            if ( idx == "y" ) text_.y = val
            if ( idx == "width" ) width_ = val
			if ( idx == "height" )
				shader_.set_param( "scale", ( val - height_ ) / height_ )

			shader_.set_param( "crop", ( text_.x + width_ ) / fe.layout.width * 2.0 - 1.0 )
			shader_.set_param( "position", text_.x, text_.y )
		}
		else
            text_[idx] = val
    }
}

::fe.add_text_scaled <- TextScaled
