///////////////////////////////////////////////////
//
// Additional Functions
// This is an internal part of
// Ambience HD theme for Attract-Mode Frontend
//
// by Oomek 2019
//
///////////////////////////////////////////////////

function adjust_rom_info()
{
	selectorYear.width = ZOOM_V_X

	local m = fe.game_info( Info.Manufacturer )
	local y = fe.game_info( Info.Year )

	local result = ""
	if (( m.len() > 0 ) && ( y.len() > 0 ))
		result = y + " " + m

	selectorYear.msg = result
	selectorYear.width = selectorYear.msg_width


	selectorPlayers.width = 100

	selectorPlayers.msg = fe.game_info( Info.Players )
	selectorPlayers.width = selectorPlayers.msg_width
}

local genre = []
local genre_timer = -200
local genre_delay = -100
local genre_current = genre_delay


function genre_formatted()
{
	genre.clear()
	genre_timer = genre_delay * 2.0
	genre_current = 0
	genre = split( fe.game_info( Info.Category ), "/" )

	local result = ""
	if ( genre.len() > 0 )
	{
		for ( local i = 0; i < genre.len(); i++ ) genre[i] = lstrip( genre[i] )
		result = genre[0]
	}

	local genreMaxWidth = 0
	selectorGenre.width = 200

	if ( genre.len() == 1 )
	{
		selectorGenre.msg = genre[0]
		genreMaxWidth = selectorGenre.msg_width
	}

	if ( genre.len() > 1 )
	{
		for ( local i = 0; i < genre.len(); i++ )
		{
			selectorGenre.msg = genre[i]
			if ( genreMaxWidth < selectorGenre.msg_width )
				genreMaxWidth = selectorGenre.msg_width
		}
	}

	selectorGenre.width = genreMaxWidth

	return result
}


function adjust_rom_info_positions()
{
	local maxInfoWidth = 0

	if( fe.game_info( Info.Rotation ) == "90" || fe.game_info( Info.Rotation ) == "270" ) // TODO adapt in selector
		maxInfoWidth = ZOOM_V_X - INFO_BORDER * 2
	else
	    maxInfoWidth = ZOOM_H_X - INFO_BORDER * 2

	local maxYearWidth = maxInfoWidth - selectorPlayers.width - selectorGenre.width - ICON_SIZE * 3 - ICON_MARGIN_LEFT * 2 - ICON_MARGIN_RIGHT * 3
	if ( selectorYear.width > maxYearWidth )
		selectorYear.width = maxYearWidth

	selectorYear.x = selectorIconYear.x + ICON_SIZE + ICON_MARGIN_RIGHT
	selectorIconPlayers.x = selectorYear.x + selectorYear.width + ICON_MARGIN_LEFT
	selectorPlayers.x = selectorIconPlayers.x + ICON_SIZE + ICON_MARGIN_RIGHT
	selectorIconGenre.x = selectorPlayers.x + selectorPlayers.width + ICON_MARGIN_LEFT
	selectorGenre.x = selectorIconGenre.x + ICON_SIZE + ICON_MARGIN_RIGHT
}


function update_clock( ttime )
{
	local datetime = date();
	timeTxt.msg = format( "%02d",datetime.hour ) + ":" + format( "%02d",datetime.min )
	dateTxt.msg = format( "%02d",datetime.day ) + " / " + format( "%02d",datetime.month + 1 ) + " / " + format( "%04d",datetime.year )
}
fe.add_ticks_callback( "update_clock" );



function genre_fade( ttime )
{
	genre_timer++
	if ( genre.len() > 1 )
	{
		if ( genre_timer > -genre_delay )
		{
			genre_timer = genre_delay
		}
		if ( genre_timer == 0 )
		{
			genre_current++
			if ( genre_current > genre.len() - 1 ) genre_current = 0
			selectorGenre.msg = genre[ genre_current ]
		}
		local t = abs(( genre_timer ) * 8 )
		t = t < 0 ? 0 : t > -genre_delay ? -genre_delay : t
		selectorGenre.alpha =  t / -genre_delay.tofloat() * 100.0
	}
}

function full_title( text )
{
	local new_line_pos = text.msg_wrapped.find("\n")
  	local full_title = fe.game_info(Info.Title)
  	local title_table = split(full_title, "(/[")
  	if ( title_table.len() > 0 )
  		return title_table[0].slice(0, new_line_pos) + "\n" +  lstrip(title_table[0].slice(new_line_pos + 0))
  	else
  		return ""
}
