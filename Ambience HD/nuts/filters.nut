function filters_define()
{
	filters_active <- 0
	filters <- []
	filters_animY <- []
	filters_animA <- []
	filters_initDone <- false
}

function filters_init()
{
	filters_active = fe.list.filter_index

	for ( local i = 0; i < 5; i++)
	{
		local obj = ms.add_text(fe.filters[ wrap( filters_active + 1 - i, fe.filters.len() ) ].name, FILTERS_X, FILTERS_Y + FILTERS_GAP * ( 4 - i ), FILTERS_W, FILTERS_H )
		obj.align = Align.MiddleLeft
		obj.nomargin = true
		obj.set_rgb( FILTERS_RGBA[0], FILTERS_RGBA[1], FILTERS_RGBA[2] )
		obj.alpha = FILTERS_RGBA[3]
		obj.charsize = 38 //TODO dynamic
		obj.font = "BarlowCondensed-Regular2-Display0.80.ttf"
		filters.push(obj)

		local anim = Animate( filters[i], "y", FILTERS_POS_CHOKE, 0, FILTERS_POS_SPEED )
		filters_animY.push( anim )

		local anim = Animate( filters[i], "alpha", FILTERS_POS_CHOKE, 0, FILTERS_POS_SPEED )
		filters_animA.push( anim )
	}

	filters[1].alpha = FILTERS_SEL_RGBA[3]
	filters[0].alpha = 0
	filters[4].alpha = 0

	blackout.zorder = 5
	filters_initDone = true
}
