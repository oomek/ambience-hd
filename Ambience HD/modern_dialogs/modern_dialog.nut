class ModernDialog
{
	fe = ::fe
	frame = null
	title = null
	list = null
	list_shader = null
	title_shader = null
	background = null
	dialog_zoom = null

	visible = null
	total = null
	selection = null
	var_old = null
	row_size = null
	rows = null
	dy = null

	constructor ( _x, _y, _w, _rh, _r )
	{
		background = fe.add_text( "", 0, 0, fe.layout.width, fe.layout.height )
		background.set_bg_rgb( 0, 0, 0 )
		background.bg_alpha = 100

		dialog_zoom = 1.0
		frame = ModernDialogFrame( _x, _y, _w, _rh, _r )
		title = fe.add_text( "POWER OPTIONS", frame.x - frame.origin_x + frame.frame_scaled / 2.0, frame.y - frame.origin_y + frame.frame_scaled / 2.0, frame.width - frame.frame_scaled, frame.row_height * 2.0 )
		title.font = "BarlowCondensed-Regular2-Display0.80.ttf"
		title.set_rgb( 0, 0, 0 )
		title.alpha = 170
		title.margin = 0
		title.char_size = frame.row_height
		title.align = Align.MiddleCentre
		//title.bg_alpha = 100

		list = fe.add_listbox( frame.x - frame.origin_x + frame.frame_scaled / 2.0, frame.y - frame.origin_y + frame.frame_scaled / 2.0 + frame.row_height * 2.0, frame.width - frame.frame_scaled, frame.row_height * frame.rows )
		list.font = "BarlowCondensed-Regular2-Display0.80.ttf"
		list.char_size = frame.row_height / 1.5
		list.set_rgb( 0, 0, 0 )
		list.set_sel_rgb ( 255, 255, 255 )
		list.selbg_alpha = 0
		list.set_bg_rgb( 0, 0, 0 )
		//list.alpha = 255 // 170
		//list.bg_alpha = 170 // temp
		//list.set_bg_rgb(0,255,0) //temp
		list.rows = frame.rows

		list_shader = fe.add_shader( Shader.VertexAndFragment, "modern_dialogs/modern_dialog_listbox.vert", "modern_dialogs/modern_dialog_listbox.frag" )
		list.shader = list_shader
		list_shader.set_param( "screenSize", fe.layout.width, fe.layout.height )

		title_shader = fe.add_shader( Shader.VertexAndFragment, "modern_dialogs/modern_dialog_listbox.vert", "modern_dialogs/modern_dialog_listbox.frag" )
		title.shader = title_shader
		title_shader.set_param( "screenSize", fe.layout.width, fe.layout.height )

		//list.bg_alpha = 100 //temp
		//list.selbg_alpha = 100 //temp

		//title.shader = list_shader

		visible = 0
		total = 0
		selection = 0
		var_old = 0
		row_size = 0
		rows = 0
		dy = 0
	}

	function _set( idx, val )
	{
		if ( idx == "zoom" )
		{
			if ( val < 0.0 ) val = 0.0
			dialog_zoom = val
			frame.zoom = dialog_zoom
			title.y = frame.y - frame.origin_y + frame.frame_scaled / 2.0
			//list.y = frame.y - frame.origin_y + frame.frame_scaled / 2.0 + frame.row_height * 2.0
			list.y = frame.y - frame.origin_y + frame.frame_scaled / 2.0 + frame.row_height * 2.0 - dy * frame.row_height
			//::print( list.y + "\n" )
			list_shader.set_param( "crop", frame.y - ( frame.height - frame.frame_scaled ) / 2.0, frame.y + ( frame.height - frame.frame_scaled ) / 2.0 )
			title_shader.set_param( "crop", frame.y - ( frame.height - frame.frame_scaled ) / 2.0, frame.y + ( frame.height - frame.frame_scaled ) / 2.0 )

			list_shader.set_param( "crop", frame.y - ( frame.height - frame.frame_scaled ) / 2.0 + frame.row_height * 2,
										   math.min( frame.y - ( frame.height - frame.frame_scaled ) / 2.0 + frame.row_height * ( visible + 2.0 ),
										   frame.y + ( frame.height - frame.frame_scaled ) / 2.0 ))
			//list_shader.set_param( "crop", 0.0, fe.layout.height )
			if ( val > 1.0 ) val = 1.0
			frame.alpha = val * 255.0
			title.alpha = val * 170.0
			list.alpha = val * 170.0
			list.sel_alpha = val * 255.0
			background.bg_alpha = val * 170.0
		}
		else if ( idx == "rows" )
		{
			list.rows = val
			list.height = frame.row_height * val
			frame.rows = val
		}
		// else if ( idx == "alpha" )
		// {
		// 	frame.alpha = val * 255.0
		// 	title.alpha = val * 170.0
		// 	list.alpha = val * 170.0
		// 	list.sel_alpha = val * 255.0
		// }
	}

	function set( _selection )
	{
		visible = list.list_size
		total = list.list_size

		if ( visible > 7 ) visible = 7

		if ( _selection == total - 1 )
			selection = visible - 1
		else
			selection = math.min( _selection, visible - 2 )

		var_old = _selection
		dy = visible - 1 - selection * 2
		rows = visible + abs( dy )

		if ( dy < 0 ) dy = 0

		list.rows = rows
		list.height = frame.row_height * rows
		frame.rows = visible
		//list.y = fe.layout.height / 2.0 - visible * row_size / 2.0 - dy * row_size
		//list.y = frame.y - frame.origin_y + frame.frame_scaled / 2.0 + frame.row_height * 2.0 - dy * frame.row_height
		// overlay_listbox_shader.set_param( "crop", ( overlay_listbox.y + dy * row_size ) / flh * 2.0 - 1.0,
												  // ( overlay_listbox.y + overlay_listbox.height ) / flh * 2.0 - 1.0 )
		frame.set_pos( selection )
	}

	function move( _var )
	{
		if ( _var > var_old )
			if ( selection < visible - 2 || _var == selection - visible + total + 1 )
				selection = selection + _var - var_old
		if ( _var < var_old )
			if ( selection > 1 || _var == selection - 1 )
				selection = selection + _var - var_old

		selection = math.clamp( selection, 0, visible - 1 )

		dy = visible - 1 - selection * 2
		rows = visible + abs( dy )

		if ( dy < 0 ) dy = 0

		var_old = _var

		list.rows = rows
		list.height = frame.row_height * rows
		list.y = frame.y - frame.origin_y + frame.frame_scaled / 2.0 + frame.row_height * 2.0 - dy * frame.row_height
		//list_shader.set_param( "crop", ( overlay_listbox.y + dy * row_size ) / flh * 2.0 - 1.0,
												  //( overlay_listbox.y + overlay_listbox.height ) / flh * 2.0 - 1.0 )
		//list_shader.set_param( "crop", frame.y - ( frame.height - frame.frame_scaled ) / 2.0, frame.y + ( frame.height - frame.frame_scaled ) / 2.0 )

		// crops also title, try to fix the list instead
		//list_shader.set_param( "crop", frame.y - ( frame.height - frame.frame_scaled ) / 2.0 + frame.row_height * 2,
									   // frame.y + ( frame.height - frame.frame_scaled ) / 2.0 - frame.row_height * 1 )
		frame.set_pos( selection )
	}
}

class ModernDialogFrame
{
	fe = ::fe
	math = ::math
	image = null
	shader = null
	frame_width = null
	frame_height = null
	frame_scaled = null
	frame_zoom = null
	corner_size = 128 // the size of the corner in the png including shadow
	corner_radius = 24 // adjustable
	texture_size = 512 // texture must be square
	row_height = null
	dialog_rows = null

	constructor ( _x, _y, _w, _rh, _r )
	{
		row_height = _rh
		dialog_rows = _r
		frame_width = _w
		frame_height = row_height * ( dialog_rows + 3 )
		frame_zoom = 0.0
		// fe.layout.height / 2160.0 scales to resolutions. 512px texture is scaled to 256px on 1080p
		frame_scaled = math.min( math.min( frame_width, frame_height ) / 1.0, corner_size * fe.layout.height * corner_radius / 24.0 / 2160.0 )
		image = fe.add_image( "modern_dialogs/frame512x512pm.png", _x , _y, frame_height + frame_scaled, 0 )
		shader = fe.add_shader( Shader.VertexAndFragment, "modern_dialogs/modern_dialog_frame.vert", "modern_dialogs/modern_dialog_frame.frag" )
		image.shader = shader
		image.mipmap = true
		image.blend_mode = BlendMode.Premultiplied
		image.width = frame_width + frame_scaled
		//image.height = frame_height + frame_scaled
		image.origin_x = image.width / 2.0
		image.origin_y = image.height / 2.0
		shader.set_param( "screenSize", fe.layout.width, fe.layout.height )
		shader.set_param( "imageSize", image.width, image.height )
		shader.set_param( "textureSize", image.subimg_width, image.subimg_height )
		shader.set_param( "frameSize", frame_scaled )
		shader.set_param( "frameScale", corner_size / frame_scaled )
		shader.set_param( "rowHeight", row_height )
		shader.set_param( "rows", dialog_rows )
		shader.set_param( "bias", math.min( 6.0 - math.logn( frame_scaled / 2.0 ) / math.logn( 2.0 ), 6.0 ) - 0.0 )
	}

	function _get( idx )
	{
		if ( idx == "rows" ) return dialog_rows
		else if ( idx == "zoom" ) return frame_zoom
		else return image[ idx ]
	}

	function set_pos( pos )
	{
		shader.set_param( "selectPos", pos )
	}

	function _set( idx, val )
	{
		if ( idx == "rows" )
		{
			dialog_rows = val
			frame_height = ::abs( row_height / 1 ) * 1 * ( val + 3 ) // TEMP abs
			shader.set_param( "rows", dialog_rows )
		}
		else if ( idx == "zoom" )
		{
			frame_zoom = val
			// fe.layout.height / 2160.0 scales to resolutions. 512px texture is scaled to 256px on 1080p
			frame_scaled = math.min( math.min( frame_width * frame_zoom, frame_height * frame_zoom ) / 1.0, corner_size * fe.layout.height * corner_radius / 24.0 / 2160.0 )
			image.width = frame_width + frame_scaled
			image.height = frame_height * frame_zoom + frame_scaled + 0.0 // TODO + 1.0 fixes blurred vertical lines in 960x540
			shader.set_param( "imageSize", image.width, image.height )
			shader.set_param( "frameSize", frame_scaled )
			shader.set_param( "frameScale", corner_size / frame_scaled )
			shader.set_param( "bias", math.min( 6.0 - math.logn( frame_scaled / 2.0 * ScreenHeight / fe.layout.height ) / math.logn( 2.0 ), 6.0 ) - 0.0 )
			image.origin_x = image.width / 2.0
			image.origin_y = image.height / 2.0
		}
		else if ( idx == "preserve_aspect_ratio" )
		{
			return false
		}
		else
		{
			image[ idx ] = val
		}
	}
}
