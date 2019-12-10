///////////////////////////////////////////////////
//
// Carrier module
// This is a modified version and internal part of
// Ambience HD theme for Attract-Mode Frontend
//
// by Oomek 2019
//
///////////////////////////////////////////////////

class Carrier
{
	selectorPosSpeed = 0
	selectorPosClamp = null
	tileHeight = 0
	tileWidth = 0
	vertical = false //TODO
	tilesTable = []
	tilesTableTxt = []
	tilesTablePos = []
	tilesTableFav = []
	tilesY = 0
	tilesTableOffset = 0
	selectorPos = 0
	selectorPosOld = 0
	surface = null
	selector = null
	tilesTotal = 0
	carrierWidth = 0
	carrierHeight = 0
	carrierPosX = 0
	carrierPosY = 0
	tilePadding = 0
	tilesOffscreen = 0
	indexActive = 0
	animScale = []
	animFadeYTiles = []
	indexOld = 0
	indexOldSnap = 0
	scale = 0
	scaleOld = 0
	emptyFilterLabel = null

	constructor( _carrierPosX, _carrierPosY, _carrierWidth, _carrierHeight, _tilesCount, _tilePadding )
	{
		carrierPosX = _carrierPosX
		carrierPosY = _carrierPosY
		carrierWidth = _carrierWidth
		carrierHeight = _carrierHeight
		tilesTotal = _tilesCount + 2
		tilePadding = _tilePadding
		tileWidth = ( carrierWidth + tilePadding * 2 ) / _tilesCount
		tileHeight = carrierHeight
		tilesY = carrierPosY + ( tileHeight + TILE_TXT_HEIGHT ) / 2
		selectorPosSpeed = SELECTOR_POS_SPEED
		selectorPosClamp = tileWidth * ( tilesTotal / 2 - 1 )
		tilesTablePos = array( tilesTotal )

		local tileFrame
		if ( THEME_DARK ) tileFrame = fe.add_image( "images/frames/frame2.20.256.png" )
		else tileFrame = fe.add_image( "images/frames/frame2.20.256.png" )
		tileFrame.visible = false
		tileFrame.mipmap = true
		local index = -floor( tilesTotal / 2 )

		for ( local i = 0; i < tilesTotal; i++ )
		{
			local obj = fe.add_text_scaled( "[Title]", 0, 0, tileWidth - tilePadding * 2, TILE_TXT_HEIGHT, "BarlowCondensed-SemiBold2-Display0.80.ttf", ms )

			obj.charsize = 44 - 12
			obj.align = Align.TopLeft
			obj.set_rgb( TILE_TITLE_RGBA[0] ,TILE_TITLE_RGBA[1] ,TILE_TITLE_RGBA[2] )
			obj.charsize = 22 + 4
			obj.line_spacing = 0.85
			obj.alpha = 50
			obj.margin = 10
			obj.word_wrap = true
			tilesTableTxt.push( obj )

			obj = fe.add_frame_image_tile( "", 0, 0, 0, 0, TILE_BORDER, TILE_BORDER + 0, TILE_BORDER, TILE_BORDER + TILE_TXT_HEIGHT, ms )
			obj.set_frame( tileFrame )
			obj.set_snap_size( 242, 242 )
			obj.y = tilesY
			obj.width = tileWidth - tilePadding * 2 + TILE_BORDER * 2
			obj.height = tileHeight + tilesTableTxt[i].height + TILE_BORDER * 2
			obj.height = tileHeight + 44 + TILE_BORDER * 2
			obj.blend_mode = BlendMode.Premultiplied
			tilesTable.push( obj )

			obj = ms.add_image( "images/icon-fav-yellow2.png", 0, 0, 66, 66 )
			obj.mipmap = true
			tilesTableFav.push( obj )

			index++
		}

		selector = fe.add_frame_image_selector( "images/frames/frame2.100.256.png", 0, 0, 0, 0, 0, 0, 0, 0, ms )
		selector.set_blur( blur_surfaces[ blur_iterations - 1 ])
		selector.set_theme( THEME_DARK )
		selector.blend_mode = BlendMode.Premultiplied

		selectorPos = 0.0000000001
		selectorPosOld = 0.0000000001

		for ( local i = 0; i < tilesTable.len(); i++ )
		{
			local obj = Animate( tilesTable[i], "scale", SELECTOR_ZOOM_CHOKE, SELECTOR_ZOOM_DELAY, SELECTOR_ZOOM_SPEED + 0.05 )
			animScale.push( obj )
		}

		for ( local i = 0; i < tilesTable.len(); i++ )
		{
			local obj = Animate( tilesTable[i], "y", FILTERS_POS_CHOKE, 0, FILTERS_POS_SPEED )
			animFadeYTiles.push( obj )
		}

		emptyFilterLabel = ms.add_text("NO GAMES FOUND", carrierPosX, carrierPosY, carrierWidth, carrierHeight )
		emptyFilterLabel.align = Align.MiddleCentre
		emptyFilterLabel.nomargin = true
		emptyFilterLabel.set_rgb( FILTERS_RGBA[0], FILTERS_RGBA[1], FILTERS_RGBA[2] )
		emptyFilterLabel.alpha = FILTERS_RGBA[3]
		// emptyFilterLabel.bg_alpha = FILTERS_RGBA[3]
		emptyFilterLabel.charsize = 38 //TODO dynamic
		emptyFilterLabel.font = "BarlowCondensed-Regular2-Display0.80.ttf"

		fe.add_transition_callback( this, "on_transition_carrier" )
		fe.add_ticks_callback( this, "tick_carrier" )
	}

	function on_transition_carrier( ttype, var, ttime )
	{
		if ( ttype == Transition.StartLayout )
		{
			indexActive = floor( tilesTotal / 2 )

			tilesTable[ indexActive ].visible = false
			tilesTable[ indexOld ].visible = true
			selector.set_snap( tilesTable[ indexActive ].image )

			for ( local i = 0; i < tilesTotal; i++ )
			{
				tilesTable[i].rawset_index_offset( i - indexActive )
				tilesTableTxt[i].index_offset = tilesTable[i].index_offset
				tilesTablePos[i] = carrierPosX + i * tileWidth + tileWidth / 2 - tilePadding
			}
		}

		if ( ttype == Transition.ToNewSelection )
		{
			local index = -floor( tilesTotal / 2 )
			tilesTableOffset += var
			indexActive = wrap( index + tilesTableOffset - 1, tilesTotal )

			tilesTable[ indexActive ].visible = false
			tilesTable[ indexOld ].visible = true

			if ( abs( var ) > 1 )
			{
				local tempPosTable = array( tilesTotal )
				for ( local i = 0; i < tilesTotal; i++ )
				{
					if ( var < 0 ) tilesTable[ wrap( i + indexActive - 1, tilesTotal )].rawset_index_offset( i - 1 )
					if ( var > 0 ) tilesTable[ wrap( i + indexActive - tilesTotal + 2, tilesTotal )].rawset_index_offset( i - tilesTotal + 2 )
					tempPosTable[i] = tilesTablePos[ wrap( i - var, tilesTotal )]
				}
				tilesTablePos = tempPosTable
			}
			else
			{
				for ( local i = 0; i < tilesTotal; i++ )
				{
					tilesTable[i].rawset_index_offset( tilesTable[i].index_offset - var )
					tilesTablePos[i] -= var * tileWidth
				}
			}
			selectorPos += var * tileWidth
			selectorPosOld = selectorPos

			if ( selectorPos < -selectorPosClamp || selectorPos > selectorPosClamp ) selectorPosSpeed = 1.0
			soundBeep.playing = true
		}

		if ( ttype == Transition.EndNavigation )
		{
			selectorPos = clamp( selectorPos, -selectorPosClamp, selectorPosClamp )
			selectorPosOld = clamp( selectorPosOld, -selectorPosClamp, selectorPosClamp )
			selectorPosSpeed = SELECTOR_POS_SPEED

			animScale[ indexActive ].wait( 1 )
			if ( !g_sleepState ) g_isVideoPlaying = false
		}

		if ( ttype == Transition.FromOldSelection )
		{
			blur_snaps[ blur_activeSnap ].video_playing = false
			animScale[ indexActive ].scale = 0

			for ( local i = 0; i < animScale.len(); i++ )
				if ( animScale[i].from == 0 ) animScale[i].set( 0 )

			animScale[ indexOld ].wait( 0 )
			animScale[ indexOld ].to = 0
			tilesTable[ indexActive ].visible = false
			tilesTable[ indexOld ].visible = true
			selector.set_snap( tilesTable[ indexActive ].image )
			tilesTable[ indexOldSnap ].set_video( blur_snaps[ blur_activeSnap ] )
			indexOld = indexActive

			for ( local i = 0; i < tilesTotal; i++ )
				tilesTableTxt[i].index_offset = tilesTable[i].index_offset // needed when rawset_index_offset is set in ToNewSelection
		}

		if ( ttype == Transition.ToNewList )
		{
			if ( fe.list.size == 0 )
			{
				emptyFilterLabel.visible = true
				selector.visible = false
				surfaceTitle.visible = false
				for ( local i = 0; i < tilesTable.len(); i++ )
					tilesTable[i].visible = false
			}
			else
			{
				emptyFilterLabel.visible = false
				selector.visible = true
				surfaceTitle.visible = true
				for ( local i = 0; i < tilesTable.len(); i++ )
					tilesTable[i].visible = true
			}

			selector.set_snap( tilesTable[ indexActive ].image )
			if ( var == 0 && blur_snaps[ blur_activeSnap ].video_playing == true )
			{
				// reload only after add/remove favourite/tag. Do not reload on layout launch
				blur_reload_video() // reloads video on adding/removing from favourites TODO: try not to reload on adding
				indexOldSnap = indexActive
				selector.set_video( blur_snaps[ blur_activeSnap ])
			}
		}

		if ( ttype == Transition.StartLayout )
		{
			indexOld = indexActive
			indexOldSnap = indexActive
			animScale[ indexActive ].set( 0 )
		}

		if ( ttype == Transition.ToGame )
		{
			blur_snaps[ blur_activeSnap ].video_playing = false
			blur_snaps[ 1 - blur_activeSnap ].video_playing = false
		}

		if ( ttype == Transition.FromGame )
		{
			blur_snaps[ 1 - blur_activeSnap ].video_playing = false

			if ( animScale[ indexActive ].from == 1.0 )
				blur_snaps[ blur_activeSnap ].video_playing = true
			else
				blur_snaps[ blur_activeSnap ].video_playing = false
		}
		return false
	}


	function change_filter( var )
	{
		blur_snaps[ blur_activeSnap ].video_playing = false
		for ( local i = 0; i < animScale.len(); i++ )
			if ( i != indexActive && i != indexOldSnap )
				animScale[i].set( 0 )

		if ( !g_sleepState ) g_isVideoPlaying = false

		local offset = ::FILTERS_GAP * -var
		if ( var != 0 )
		for ( local i = 0; i < tilesTable.len(); i++ )
		{
			animFadeYTiles[i].anim( tilesY, tilesY + offset )
		}
	}

	function tick_carrier( ttime )
	{
		if ( !g_inGame )
			if (( animScale[ indexActive ].to == 1.0 ) && ( animScale[ indexActive ].from > 0.0 ) && ( g_filterTriggered == true ))
				blur_snaps[ blur_activeSnap ].video_playing = true

		local localFade = 1.0 - 2.0 * fabs(( tilesY - fabs( tilesTable[0].y )) / ::FILTERS_GAP )

		if ( localFade < 0.0 ) localFade = 0

		if ( true || selectorPos != 0 || animFadeYTiles[ indexActive ].running == true || animScale[ indexActive ].running == true )
		{
			if ( selectorPos > 0 )
			{
				selectorPosOld = selectorPosOld * selectorPosSpeed
				selectorPos = selectorPosOld * ( 1.0 - selectorPosSpeed ) + selectorPos * ( selectorPosSpeed ) - SELECTOR_POS_CHOKE * ( 1.0 - selectorPosSpeed )

				if ( selectorPos < 0 )
				{
					selectorPos = 0
					selectorPosOld = 0
				}
			}
			else if ( selectorPos < 0 )
			{
				selectorPosOld = selectorPosOld * selectorPosSpeed
				selectorPos = selectorPosOld * ( 1.0 - selectorPosSpeed ) + selectorPos * ( selectorPosSpeed ) + SELECTOR_POS_CHOKE * ( 1.0 - selectorPosSpeed )

				if ( selectorPos > 0 )
				{
					selectorPos = 0
					selectorPosOld = 0
				}
			}

			local selectorPosClamped = clamp( selectorPos, -selectorPosClamp, selectorPosClamp )

			for ( local i = 0; i < tilesTotal; i++ )
			{

				if ( tilesTable[i].x > carrierWidth + carrierPosX + tileWidth + tilePadding + tilesTable[ indexOldSnap ].width - tileWidth )
				{
					tilesTable[i].index_offset = tilesTable[i].index_offset - tilesTotal
					tilesTableTxt[i].index_offset = tilesTable[i].index_offset
					tilesTablePos[i] -= tileWidth * tilesTotal
				}
				if ( tilesTable[i].x < carrierPosX - tileWidth - tilePadding - tilesTable[ indexOldSnap ].width + tileWidth )
				{
					tilesTable[i].index_offset = tilesTable[i].index_offset + tilesTotal
					tilesTableTxt[i].index_offset = tilesTable[i].index_offset
					tilesTablePos[i] += tileWidth * tilesTotal
				}

				tilesTable[i].x = selectorPosClamped - tileWidth + tilesTablePos[i]

				if ( tilesTable[i].x < tilesTable[ indexOldSnap ].x ) tilesTable[i].x = tilesTable[i].x - ( tilesTable[ indexOldSnap ].width - tileWidth - TILE_BORDER * 2.0 ) / 2.0 - tilePadding
				if ( tilesTable[i].x > tilesTable[ indexOldSnap ].x ) tilesTable[i].x = tilesTable[i].x + ( tilesTable[ indexOldSnap ].width - tileWidth - TILE_BORDER * 2.0 ) / 2.0 + tilePadding

				tilesTableTxt[i].x = tilesTable[i].x - tilesTable[i].origin_x + TILE_BORDER
				tilesTableTxt[i].y = tilesTable[i].y + tilesTable[i].height - tilesTable[i].origin_y - TILE_BORDER - TILE_TXT_HEIGHT

				tilesTableFav[i].width = 33.0
				tilesTableFav[i].height = 33.0
				tilesTableFav[i].x = tilesTable[i].x + tilesTable[i].origin_x - tilesTableFav[i].width - TILE_BORDER - 8.0
				tilesTableFav[i].y = tilesTable[i].y - tilesTable[i].origin_y + TILE_BORDER + 8.0

				local tilesAlpha = 255 - abs( fe.layout.width / 2.0  - tilesTable[i].x ) + 770 // TODO fade side tiles properly

				if ( tilesAlpha > 255 ) tilesAlpha = 255
				if ( tilesAlpha < 0 )
				{
					tilesTableTxt[i].visible = false
					tilesTableFav[i].visible = false
					if ( i != indexActive ) tilesTable[i].visible = false
				}
				else
				{
					tilesTableTxt[i].visible = true
					if ( fe.game_info( Info.Favourite, tilesTable[i].index_offset ) == "1" ) tilesTableFav[i].visible = true; else tilesTableFav[i].visible = false
					tilesTableTxt[ indexActive ].visible = false //TEMP DEBUG set to TRUE to show title over selector
					if ( i != indexActive && fe.list.size > 0 ) tilesTable[i].visible = true
					local selectorAlpha = localFade * 255.0
					tilesTable[i].alpha = tilesAlpha * localFade
					tilesTableTxt[i].alpha = tilesTable[i].alpha * TILE_TITLE_RGBA[3] / 255
					tilesTableFav[i].alpha = tilesTable[i].alpha
				}
				selector.alpha = 255.0 * localFade
				surfaceTitle.alpha = 255.0 * localFade
			}

			selector.x = tilesTable[ indexActive ].x - SELECTOR_BORDER
		}

		scale = animScale[ indexActive ].scale
		scaleOld = animScale[ indexOldSnap ].scale
		selector.set_video_alpha( scale )
		tilesTable[ indexOldSnap ].set_border( TILE_BORDER, TILE_BORDER, TILE_BORDER, mix ( TILE_BORDER + TILE_TXT_HEIGHT, TILE_BORDER + SELECTOR_TITLE_HEIGHT, scaleOld ))

		// if ( tilesTable[ indexActive ].texture_width >= tilesTable[ indexActive ].texture_height )
		local rotation = fe.game_info( Info.Rotation,tilesTable[ indexActive ].index_offset, tilesTable[ indexActive ].filter_offset )
		if(  rotation == "90" || rotation == "270" )
		{
			selector.y = tilesTable[ indexActive ].y + TILE_BORDER
			selector.width = tilesTable[ indexActive ].width + SELECTOR_BORDER * 2.0
			selector.height = tilesTable[ indexActive ].height + SELECTOR_BORDER
			selector.origin_x = tilesTable[ indexActive ].origin_x
			selector.origin_y = tilesTable[ indexActive ].origin_y + TILE_BORDER + SELECTOR_BORDER
			selector.set_border( TILE_BORDER + SELECTOR_BORDER, TILE_BORDER + SELECTOR_BORDER, TILE_BORDER + SELECTOR_BORDER, mix( TILE_BORDER + TILE_TXT_HEIGHT, TILE_BORDER + SELECTOR_TITLE_HEIGHT, scale ))
			selector.set_snap_size( ZOOM_V_X, ZOOM_V_Y )
		}
		else
		{
			selector.y = tilesTable[ indexActive ].y + TILE_BORDER
			selector.width = tilesTable[ indexActive ].width + SELECTOR_BORDER * 2.0
			selector.height = tilesTable[ indexActive ].height + SELECTOR_BORDER
			selector.origin_x = tilesTable[ indexActive ].origin_x
			selector.origin_y = tilesTable[ indexActive ].origin_y + TILE_BORDER + SELECTOR_BORDER
			selector.set_border( TILE_BORDER + SELECTOR_BORDER, TILE_BORDER + SELECTOR_BORDER, TILE_BORDER + SELECTOR_BORDER, mix( TILE_BORDER + TILE_TXT_HEIGHT, TILE_BORDER + SELECTOR_TITLE_HEIGHT, scale ))
			selector.set_snap_size( ZOOM_H_X, ZOOM_H_Y )
		}

		for ( local i = 0; i < tilesTable.len(); i++ )
		{
			local rotation = fe.game_info( Info.Rotation,tilesTable[i].index_offset, tilesTable[i].filter_offset )
			if(  rotation == "90" || rotation == "270" )
				tilesTable[i].set_snap_size( ZOOM_V_X, ZOOM_V_Y )
			else
				tilesTable[i].set_snap_size( ZOOM_H_X, ZOOM_H_Y )
		}

		// Adjusting favourite icons positions
		tilesTableFav[ indexActive ].width = mix( 33, 66, scale )
		tilesTableFav[ indexActive ].height = mix( 33, 66, scale )
		tilesTableFav[ indexActive ].x = tilesTable[ indexActive ].x + tilesTable[ indexActive ].origin_x - tilesTableFav[ indexActive ].width - TILE_BORDER - mix( 8, 16, scale )
		tilesTableFav[ indexActive ].y = tilesTable[ indexActive ].y - tilesTable[ indexActive ].origin_y + TILE_BORDER + mix( 8, 16, scale )

		tilesTableTxt[ indexActive ].x = tilesTable[ indexActive ].x - tilesTable[ indexActive ].origin_x + TILE_BORDER

		tilesTableFav[ indexOldSnap ].width = mix( 33, 66, scaleOld )
		tilesTableFav[ indexOldSnap ].height = mix( 33, 66, scaleOld )
		tilesTableFav[ indexOldSnap ].x = tilesTable[ indexOldSnap ].x + tilesTable[ indexOldSnap ].origin_x - tilesTableFav[ indexOldSnap ].width - TILE_BORDER - mix( 8, 16, scaleOld )
		tilesTableFav[ indexOldSnap ].y = tilesTable[ indexOldSnap ].y - tilesTable[ indexOldSnap ].origin_y + TILE_BORDER + mix( 8, 16, scaleOld )


		// Adjusting tiles titles positions
		tilesTableTxt[ indexOldSnap ].width = mix( tileWidth - tilePadding * 2, ( tileWidth - tilePadding * 2 ) * 1.73, scaleOld ) //TODO Why 1.73?
		tilesTableTxt[ indexOldSnap ].height = mix( tilesTableTxt[ indexOldSnap ].height_, tilesTableTxt[ indexOldSnap ].height_ * 1.73, scaleOld ) //TODO Why 1.73?

		tilesTableTxt[ indexOldSnap ].x = tilesTable[ indexOldSnap ].x - tilesTable[ indexOldSnap ].origin_x + TILE_BORDER
		tilesTableTxt[ indexOldSnap ].y = tilesTable[ indexOldSnap ].y - tilesTable[ indexOldSnap ].origin_y
			+ tilesTable[ indexOldSnap ].height - tilesTable[ indexOldSnap ].borderBottom
		tilesTableTxt[ indexActive ].y = selector.y - selector.origin_y + tilesTable[ indexActive ].height
			- selector.borderBottom + selector.borderTop - TILE_BORDER

		tilesTable[ indexOldSnap ].set_video_alpha( scaleOld )

		surfaceTitle.x = mix( tilesTableTxt[ indexActive ].x, tilesTableTxt[ indexActive ].x - SELECTOR_BORDER, scale )
		surfaceTitle.y = tilesTableTxt[ indexActive ].y
		surfaceTitle.width = selector.width - selector.borderLeft - selector.borderRight
		surfaceTitle.height = selector.borderBottom - TILE_BORDER
		surfaceTitleShader.set_param( "textureSize", surfaceTitle.texture_width, surfaceTitle.texture_height )
		surfaceTitleShader.set_param( "imageSize", surfaceTitle.width, surfaceTitle.height )
		surfaceTitleShader.set_param( "scale", scale * 0.8421 + 1.1579 )

		selectorTitle.alpha = TILE_TITLE_RGBA[3] * ( 1.0 - scale )
		selectorTitleEx.alpha = TILE_TITLE_RGBA[3] * scale

		if ( animScale[ indexActive ].time == 0 && animScale[ indexActive ].delayed == true )
		{
			blur_reload_video()
			indexOldSnap = indexActive
			selector.set_video( blur_snaps[ blur_activeSnap ])
		}

		emptyFilterLabel.y = selector.y - carrierHeight / 2 - TILE_BORDER
		emptyFilterLabel.alpha = FILTERS_RGBA[3] * localFade
	}

	function set_selector_color( r, g ,b )
	{
		try { selector.set_bg_rgb( r, g, b ); selector.alpha = 10 }
		catch( e ) {}
	}

	function set_selector_alpha( a )
	{
		selector.alpha = a
	}

	function set_snap_videos()
	{
		for ( local i = 0; i < tilesTotal; i++ )
			tilesTable[i].video_flags = Vid.NoAudio
	}

	function set_keep_aspect()
	{
		for ( local i = 0; i < tilesTotal; i++ )
			tilesTable[i].preserve_aspect_ratio = true
	}

}
