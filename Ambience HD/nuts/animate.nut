///////////////////////////////////////////////////
//
// Animate module
// This is an internal part of
// Ambience HD theme for Attract-Mode Frontend
//
// by Oomek 2019
//
///////////////////////////////////////////////////

class Animate
{
	x = null
	y = null
	width = null
	height = null
	alpha = null
	from = null
	to = null
	from2 = null
	var = null
	setOnce = null
	overshot = null
	delay = null
	smoothing = null
	delayed = null
	delayPos = null
	time = null
	object = null
	property = null
	running = null
	lastTick = null
	scale = null

	constructor ( _object, _property, _overshot, _delay, _smoothing )
	{
		object = _object
		x = 0
		y = 0
		width = 1
		height = 1
		property = _property
		overshot = _overshot
		delay = _delay
		smoothing = _smoothing * 0.9
		delayed = false
		running = false
		lastTick = false
		time = _delay
		scale = 0
		from = 0
		to = 0
		from2 = 0
		setOnce = false
		var = 0

		fe.add_ticks_callback( this, "tick_animate" )

		switch (property)
		{
			case "x":
				from = _object.x
				to = _object.x
				break
			case "y":
				from = _object.y
				to = _object.y
				break
			case "width":
				from = _object.width
				to = _object.width
				break
			case "height":
				from = _object.height
				to = _object.height
				break
			case "scale":
				width = _object.width
				height = _object.height
				from = 1
				to = 1
				break
			case "scale_y":
				height = _object.height
				from = 1
				to = 1
				break
			case "zoom":
				x = _object.x
				y = _object.y
				width = _object.width
				height = _object.height
				from = 0
				to = 0
				break
			case "alpha":
				from = _object.alpha
				to = _object.alpha
				break
			case "bg_alpha":
				from = _object.bg_alpha
				to = _object.bg_alpha
				break
			case "listbox_alpha":
				from = _object.bg_alpha
				to = _object.bg_alpha
				break
			case "shaderx":
				from = 0
				to = 0
				break
			case "var":
				width = _object.width
				height = _object.height
				from = 0
				to = 0
				var = 0
				break
		}
	}

	function wait( _to)
	{
		delayed = true
		time = delay
		delayPos = _to
		from2 = from
		setOnce = false
	}

	function set(_to)
	{
		setOnce = true
		from = _to
		to = _to
		from2 = _to
		delayed = false
	}

	function anim(_from,_to)
	{
		from = _from
		to = _to
		from2 = _from
	}

	function goto(_to)
	{
		to = _to
		from2 = from
	}

	function zoom_set()
	{
		x = object.x
		y = object.y
		width = object.width
		height = object.height
		alpha = object.alpha
	}

	function go()
	{
		if( true )
		{
			if ( from > to )
			{
				from2 = to * ( 1.0 - smoothing ) + from2 * smoothing
				from = from2 * ( 1.0 - smoothing ) + from * ( smoothing ) - overshot * ( 1.0 - smoothing )
				if ( from < to )
				{
					from = to
					from2 = to
				}
			}
			else if ( from < to )
			{
				from2 = to * ( 1.0 - smoothing ) + from2 * smoothing
				from = from2 * ( 1.0 - smoothing ) + from * ( smoothing ) + overshot * ( 1.0 - smoothing )
				if ( from > to )
				{
					from = to
					from2 = to
				}
			}
		}

		if ( delayed )
		{
			if( time > 0 )
			{
				time --
			}
			else
			{
				to = delayPos
				delayed = false
			}
		}

		if ( setOnce == true )
		{
			setOnce = false
			return to
		}
		else return from
	}

	function tick_animate( ttime )
	{
		if ( from != to || delayed == true || setOnce == true || lastTick == true)
		{
			running = true
			switch (property)
			{
				case "x":
					object.x = go()
					break
				case "y":
					object.y = go()
					break
				case "width":
					object.width = go()
					break
				case "height":
					object.height = go()
					break
				case "scale":
					scale = go()
					if ( object.texture_width >= object.texture_height) // TODO
					{
						object.width = mix( width.tofloat(), ZOOM_H_X + TILE_BORDER * 2.0, scale )
						object.height = mix( height.tofloat(), ZOOM_H_Y + TILE_BORDER * 2.0 + SELECTOR_TITLE_HEIGHT, scale )
						object.origin_x = object.width.tofloat() / 2.0
						object.origin_y = object.height.tofloat() / 2.0  + mix( 0, 20, scale )
					}
					else
					{
						object.width = mix( width.tofloat(), ZOOM_V_X + TILE_BORDER * 2.0, scale )
						object.height = mix( height.tofloat(), ZOOM_V_Y + TILE_BORDER * 2.0 + SELECTOR_TITLE_HEIGHT, scale )
						object.origin_x = object.width.tofloat() / 2.0
						object.origin_y = object.height.tofloat() / 2.0  + mix( 0, 45, scale )
					}
					break
				case "scale_y":
					scale = go()
					object.height = height * scale
					object.origin_y = ( height * scale - height ) / 2
					break
				case "zoom":
					scale = go()
					local s = pow( 2.0, scale )
					object.width = width * s
					object.height = height * s
					object.x = x + ( ( x - object.origin_x - flw / 2.0 ) * ( s - 1.0 ) )
					object.y = y + ( ( y - object.origin_y - flh / 2.0 ) * ( s - 1.0 ) )
					object.alpha = clamp( 1.0 - fabs( scale * 2.0 ), 0.0, 1.0 ) * alpha
					break
				case "alpha":
					object.alpha = go()
					break
				case "bg_alpha":
					object.bg_alpha = go()
					break
				case "listbox_alpha":
					object.alpha = go()
					object.sel_alpha = object.alpha
					object.selbg_alpha = object.alpha
					break
				case "shaderx":
					object.set_param( "position", go())
					break
				case "var":
					local var = go()
					break
			}

		}
		else
		{
			running = false
			lastTick = false
		}
	}
}
