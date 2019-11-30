class ModernDialogAnimate
{
	from = 0.0
	to = 0.0
	speed = null
	object = null
	offset = 8192 // denormal protection, reduces float precission
	buf = []
	bounce = 0.0
	running = false

	constructor ( _object )
	{
		object = _object
		buf = [ offset, offset, offset, offset ]
		fe.add_ticks_callback( this, "tick" )
		object.zoom = go()
	}

	function go()
	{
		speed = 0.35
		bounce = 1.2

		if ( to == 0.0 )
		{
			speed = 0.4
			bounce = 0.2
		}

		// 4pole LowPass filter with feedback
		buf[0] += speed * (( to + offset ) - buf[0] + bounce * ( buf[0] - buf[1] ));
		buf[1] += speed * ( buf[0] - buf[1] );
		buf[2] += speed * ( buf[1] - buf[2] );
		buf[3] += speed * ( buf[2] - buf[3] );
		from = buf[3] - offset
		return from
	}

	function tick( tick_time )
	{
		if ( from != to )
		{
			running = true
			object.zoom = go()
		}
		else
			running = false
	}
}
