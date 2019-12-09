///////////////////////////////////////////////////
//
// Ambience HD v0.8 beta
// Theme for Attract-Mode Front-End
//
// by Oomek 2019
//
///////////////////////////////////////////////////

class UserConfig
{
	</ label="Theme", help="", options="Light,Dark", order=1 /> theme="Light"
	</ label="Snaps or Videos", help="Specifies what to show in the center tile.", options="Snaps,Videos,Videos Muted", order=2 /> snaps="Videos"
	</ label="Show Button Labels", help="Shows bottom bar with button labels.\n Configurable in settings.nut", options="Yes, No", order=3 /> labels="Yes"
}


// Check if this AM version supports .msg_wrapped property
local am_version_check = fe.add_text( "", 0, 0, 0, 0 )
try { am_version_check.msg_wrapped } catch(e) { while ( !fe.overlay.splash_message( "Ambience HD requires Attract Mode 2.6.0 or newer to run.\nPlease update" )) {} return }
am_version_check.visible = false


// This layout is fixed to 1920 x 1080 until all bugs are squashed.
fe.layout.width = 1920
fe.layout.height = 1080


////////////////////
// Global Variables
////////////////////

my_config <- fe.get_config()

flw <- fe.layout.width
flh <- fe.layout.height

g_sleepState <- false
g_isVideoPlaying <- false
g_filterTriggered <- false
g_autorepeatSuppression <- 0
g_inGame <- false

g_snaps <- []
g_activeSnap <- 0

g_indexChanged <- false
g_blackoutTimer <- 0


////////////////////
// Constants
////////////////////

if ( my_config["theme"] == "Light" )
{
	// LIGHT
	THEME_DARK <- 0.0
	TOP_BAR_RGBA <- [255,255,255,100] //TEMP alpha was 50
	LOGO_RGBA <- [0,0,0,255]
	BOTTOM_BAR_RGBA <- [255,255,255,100]
	BOTTOM_LEGEND_RGBA <- [0,0,0,255]
	FILTERS_RGBA <- [0,0,0,80]
	FILTERS_SEL_RGBA <- [0,0,0,200]
	ALPHABET_RGBA <- [0,0,0,80]
	LIST_POS_RGBA <- [0,0,0,200]
	TILE_TITLE_RGBA <- [0,0,0,150]
}
else
{
	// DARK
	THEME_DARK <- 1.0
	TOP_BAR_RGBA <- [255,255,255,50] //TEMP alpha was 50
	LOGO_RGBA <- [0,0,0,255]
	BOTTOM_BAR_RGBA <- [255,255,255,50]
	BOTTOM_LEGEND_RGBA <- [0,0,0,255]
	FILTERS_RGBA <- [255,255,255,80]
	FILTERS_SEL_RGBA <- [255,255,255,200]
	ALPHABET_RGBA <- [255,255,255,80]
	LIST_POS_RGBA <- [255,255,255,200]
	TILE_TITLE_RGBA <- [255,255,255,150]
}


FILTERS_POS_SPEED <- 0.9 //0.9
FILTERS_POS_CHOKE <- 1 //100 //5
SELECTOR_POS_SPEED <- 0.85 //0.9
SELECTOR_POS_CHOKE <- 2
FILTERS_GAP <- floor( flh * 0.045 )
FILTERS_W <- ( flh * 0.3 )
FILTERS_H <- ceil( flh * 0.025 )
FILTERS_X <- 65
FILTERS_Y <- 393 - FILTERS_GAP * 3
TILE_TXT_HEIGHT <- 70
TILES_COUNT <- 7
TILE_PADDING <- 15 //was 8 TODO check if it's not hardcoded elsewhere. if = 12 and some other values the tile positioning is not pixel perfect, investigate
TILE_BORDER <- 26 + 0
SELECTOR_BORDER <- 5
SELECTOR_ZOOM_DELAY <- 60 //50 latest 60
SELECTOR_ZOOM_SPEED <- 0.9 //50 latest 0.9
SELECTOR_ZOOM_CHOKE <- 0.01 // latest 0.01
SELECTOR_TITLE_HEIGHT <- 144 + 22 + 6
ZOOM_H_X <- 586// + 164
ZOOM_H_Y <- 406// + 100
ZOOM_V_X <- 460// + 76
ZOOM_V_Y <- 520// + 126
BLACKOUT_SPEED_TO_GAME <- 6
BLACKOUT_SPEED_FROM_GAME <- 6
ICON_SIZE <- 32
INFO_BORDER <- 13
GAME_LIST_POSITION_WIDTH <- 150
ICON_MARGIN_LEFT <- 20
ICON_MARGIN_RIGHT <- 6


////////////////////
// Debug - remove later
////////////////////

// debug1 <- fe.add_text( "1", 0, 0, 1000, 32 )
// debug1.align = Align.Left
// debug1.zorder = 3

// debug2 <- fe.add_text( "2", 0, 32, 1000, 32 )
// debug2.align = Align.Left
// debug2.zorder = 3

// debug3 <- fe.add_text( "3", 0, 64, 1000, 32 )
// debug3.align = Align.Left
// debug3.zorder = 3

////////////////////
// Sounds
////////////////////

soundBeep <- fe.add_sound( "sounds/menu_select2.wav" )
soundDrip <- fe.add_sound( "sounds/filter_select.wav" )
soundChord <- fe.add_sound( "sounds/menu_press3.wav" )
soundMenuSelect <- fe.add_sound( "sounds/menu_select.wav" )
soundMenuPress <- fe.add_sound( "sounds/menu_press.wav" )
soundMenuPopup <- fe.add_sound( "sounds/menu_popup.wav" )


////////////////////
// Includes
////////////////////

fe.do_nut( "nuts/math.nut" )
fe.do_nut( "nuts/frame_selector.nut" )
fe.do_nut( "nuts/frame_tile.nut" )
fe.do_nut( "nuts/animate.nut" )
fe.do_nut( "nuts/carrier.nut" )
fe.do_nut( "nuts/text_scaled.nut" )


////////////////////
// Functions
////////////////////

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
local genreTimer = -200
local genreDelay = -100
local genreCurrent = genreDelay


function genre_formatted()
{
	genre.clear()
	genreTimer = genreDelay * 2.0
	genreCurrent = 0
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
	genreTimer++
	if ( genre.len() > 1 )
	{
		if ( genreTimer > -genreDelay )
		{
			genreTimer = genreDelay
		}
		if ( genreTimer == 0 )
		{
			genreCurrent++
			if ( genreCurrent > genre.len() - 1 ) genreCurrent = 0
			selectorGenre.msg = genre[ genreCurrent ]
		}
		local t = abs(( genreTimer ) * 8 )
		t = t < 0 ? 0 : t > -genreDelay ? -genreDelay : t
		selectorGenre.alpha =  t / -genreDelay.tofloat() * 100.0
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


////////////////////
// Blackout
////////////////////

blackout <- fe.add_image( "images/black.png", 0, 0, flw, flh )
blackout.alpha = 255
blackout.zorder = 2


////////////////////
// Snaps for Blur
////////////////////

g_snaps.push( fe.add_image( "images/background.png", 839, 448, 242, 242 ))
g_snaps.push( fe.add_image( "images/background.png", 839, 448, 242, 242 ))
g_snaps[0].mipmap = true
g_snaps[1].mipmap = true
g_snaps[0].preserve_aspect_ratio = false
g_snaps[1].preserve_aspect_ratio = false
g_snaps[0].video_flags = Vid.NoAutoStart
g_snaps[1].video_flags = Vid.NoAutoStart
g_snaps[0].visible = false
g_snaps[1].visible = false

if ( my_config["snaps"] == "Snaps" )
{
	g_snaps[0].video_flags = Vid.ImagesOnly
	g_snaps[1].video_flags = Vid.ImagesOnly
}
else if ( my_config["snaps"] == "Videos Muted" )
{
	g_snaps[0].video_flags = Vid.NoAudio | Vid.NoAutoStart
	g_snaps[1].video_flags = Vid.NoAudio | Vid.NoAutoStart
}
else if ( my_config["snaps"] == "Videos" )
{
	g_snaps[0].video_flags = Vid.NoAutoStart
	g_snaps[1].video_flags = Vid.NoAutoStart
}


////////////////////
// Blur
////////////////////

fe.do_nut( "nuts/blur.nut" )


////////////////////
// Alphabet
////////////////////

fe.do_nut( "nuts/alphabet.nut" )
alphabet_define()
alphabet_init()


////////////////////
// Surfaces
////////////////////

surfaceTitleWidth <- ZOOM_H_X + SELECTOR_BORDER * 2
surfaceTitleHeight <- SELECTOR_TITLE_HEIGHT
surfaceTitle <- fe.add_surface( surfaceTitleWidth * 2, surfaceTitleHeight) // TODO check if * 2 fixes cropped info

ms <- fe.add_surface( flw, flh )

surfaceTitle.visible = false
surfaceTitle = ms.add_clone( surfaceTitle )
surfaceTitle.visible = true
surfaceTitle.zorder = 2

surfaceAlphabet.visible = false
surfaceAlphabet = ms.add_clone( surfaceAlphabet )
surfaceAlphabet.visible = true


blurFadeAnim <- Animate( images[1], "alpha", 10, 20, 1.05 )

local video_reloaded = true
function reload_video()
{
	g_snaps[ 1 - g_activeSnap ].video_playing = false
	g_snaps[ g_activeSnap ].video_playing = false
	blurFadeAnim.wait( g_activeSnap * 255.0 )
	g_activeSnap = 1 - g_activeSnap

	if ( fe.list.size == 0 )
		g_snaps[ g_activeSnap ].file_name = "images/background.png"
	else
	{
		if ( my_config["snaps"] == "Snaps" )
			g_snaps[ g_activeSnap ].file_name = fe.get_art( "snap", 0, 0, Art.ImagesOnly )
		else
			g_snaps[ g_activeSnap ].file_name = fe.get_art( "snap" )
	}

	shaders[0].set_param( "texsize", images[0].texture_width, images[0].texture_height )
	shaders[1].set_param( "texsize", images[1].texture_width, images[1].texture_height )
	carrier.indexOldSnap = carrier.indexActive
	carrier.selector.set_video( g_snaps[ g_activeSnap ])
}


////////////////////
// Filters
////////////////////

fe.do_nut( "nuts/filters.nut" )
filters_define()


////////////////////
// List Position
////////////////////

local gameListPosition = ms.add_text( "[ListEntry] / [ListSize]", flw - FILTERS_X - GAME_LIST_POSITION_WIDTH , 413 - 14, GAME_LIST_POSITION_WIDTH, FILTERS_H )
gameListPosition.char_size = FILTERS_H
gameListPosition.align = Align.BottomRight
gameListPosition.margin = 0
gameListPosition.font = "BarlowCondensed-Regular2-Display0.80.ttf"
gameListPosition.set_rgb( LIST_POS_RGBA[0], LIST_POS_RGBA[1], LIST_POS_RGBA[2] )
gameListPosition.alpha = LIST_POS_RGBA[3]


////////////////////
// Selector Title
////////////////////

surfaceTitleShader <- fe.add_shader( Shader.VertexAndFragment, "shaders/selector_title.vert", "shaders/selector_title.frag" )
surfaceTitle.shader = surfaceTitleShader
surfaceTitle.set_rgb( 0, 0, 0 )
surfaceTitle.blend_mode = BlendMode.Premultiplied

selectorTitle <- surfaceTitle.add_text( "[Title]", 0, 0, surfaceTitleWidth, 140 )
selectorTitle.line_spacing = 0.85
selectorTitle.align = Align.TopLeft
selectorTitle.word_wrap = true
selectorTitle.set_rgb( 0, 0, 0 )
selectorTitle.font = "BarlowCondensed-SemiBold2-Display0.80.ttf"
selectorTitle.margin = 18 //20
selectorTitle.charsize = 44 + 2
selectorTitle.alpha = TILE_TITLE_RGBA[3]

selectorTitleEx <- surfaceTitle.add_text( "[Title]", 0, 0, surfaceTitleWidth, 140 )
selectorTitleEx.line_spacing = 0.85
selectorTitleEx.align = Align.TopLeft
selectorTitleEx.word_wrap = true
selectorTitleEx.set_rgb( 0, 0, 0 )
selectorTitleEx.font = "BarlowCondensed-SemiBold2-Display0.80.ttf"
selectorTitleEx.margin = 18 //20
selectorTitleEx.charsize = 44 + 2
selectorTitleEx.alpha = 0


////////////////////
// Game Info
////////////////////

selectorIconYear <- surfaceTitle.add_image( "images/icon-copy.png", 15 - 5 + 8, 80 + 44 - 8 + 6 )
selectorIconYear.alpha = 100

// local selectorYear = surfaceTitle.add_text( "[!year_formatted]", 12-3 + 38 + 8, 46 + 44 - 8 + 6, 180, 96 )
selectorYear <- surfaceTitle.add_text( "", 12 - 3 + 38 + 8, selectorIconYear.y, 120, ICON_SIZE )
selectorYear.align = Align.MiddleLeft
selectorYear.set_rgb( 0, 0, 0 )
selectorYear.font = "BarlowCondensed-Regular2-Display0.80.ttf"
selectorYear.margin = 0
selectorYear.charsize = ceil( 10 * 2.148760330578512 ) + 4
selectorYear.alpha = 100
// selectorYear.bg_alpha = 100 //TEMP

selectorIconPlayers <- surfaceTitle.add_image( "images/icon-stick.png", 0, selectorIconYear.y )
selectorIconPlayers.alpha = 100

selectorPlayers <- surfaceTitle.add_text( "", 0, selectorIconYear.y, 20, ICON_SIZE )
selectorPlayers.align = Align.MiddleLeft
selectorPlayers.set_rgb( 0, 0, 0 )
selectorPlayers.font = "BarlowCondensed-Regular2-Display0.80.ttf"
selectorPlayers.margin = 0
selectorPlayers.charsize = ceil( 10 * 2.148760330578512 ) + 4
selectorPlayers.alpha = 100
// selectorPlayers.bg_alpha = 100 //TEMP

selectorIconGenre <- surfaceTitle.add_image( "images/icon-genre.png", 0, selectorIconYear.y )
selectorIconGenre.alpha = 100

selectorGenre <- surfaceTitle.add_text( "", 0, selectorIconYear.y, surfaceTitleWidth, ICON_SIZE )
selectorGenre.align = Align.MiddleLeft
selectorGenre.set_rgb( 0, 0, 0 )
selectorGenre.font = "BarlowCondensed-Regular2-Display0.80.ttf"
selectorGenre.margin = 0
selectorGenre.charsize = ceil( 10 * 2.148760330578512 ) + 4
selectorGenre.alpha = 100
// selectorGenre.bg_alpha = 100 //TEMP


////////////////////
// Carrier
////////////////////

//local carrier = Carrier( flw + flx - crw, 0, crw, flh_old, TILES_COUNT, 3, 8, "images/selector300x216.png", "images/white.png" )
carrier <- Carrier ( 65, floor( flh * 0.41 ), flw - 65 * 2, 242, TILES_COUNT, TILE_PADDING ) //TEMP frame2 + 200
//carrier.set_keep_aspect()
//carrier.set_selector_alpha( 255 ) //150
//carrier.set_background_alpha( 0 )


function tick_all( ttime )
{
	foreach ( anim in carrier.animScale )
		anim.tick_animate( ttime )

	foreach (anim in carrier.animFadeYTiles )
		anim.tick_animate( ttime )

	carrier.tick_carrier( ttime )

	if ( fe.filters.len() > 0 )
	{
		foreach ( anim in filters_animA )
			anim.tick_animate( ttime )

		foreach ( anim in filters_animY )
			anim.tick_animate( ttime )
	}

	alphabet_activeLetterShaderX.tick_animate( ttime )
	tick_layout( ttime )
	blurFadeAnim.tick_animate( ttime )
	zoomTop.tick_animate( ttime )
	zoomTopShadow.tick_animate( ttime )
	zoomBottom.tick_animate( ttime )
	zoomCentre.tick_animate( ttime )
}


////////////////////
// Transitions
////////////////////

local indexOld = carrier.indexActive

function on_transition( ttype, var, ttime )
{
	if ( ttype == Transition.StartLayout )
	{
		//g_sleepState = false
		//g_indexChanged = true
		//indexOld = carrier.indexActive
		carrier.change_filter(0)
		zoomTop.anim( 0.5, 0.0 )
		zoomTopShadow.anim( 0.5, 0.0 )
		zoomBottom.anim( 0.5, 0.0 )
		zoomCentre.anim( 2.0, 0.0 )
		blackoutAnimA.anim( 255.0, 0.0 )
	}


	if ( ttype == Transition.ToNewSelection )
	{
		g_indexChanged = true
	}

	if ( ttype == Transition.FromOldSelection )
	{
		selectorTitle.msg = carrier.tilesTableTxt[ carrier.indexActive ].msg_wrapped
		selectorTitleEx.msg = full_title( carrier.tilesTableTxt[ carrier.indexActive ])
	}

	if ( ttype == Transition.EndNavigation )
	{
		video_reloaded = false

		adjust_rom_info()
		selectorGenre.msg = genre_formatted()
		adjust_rom_info_positions()
	}

	if ( ttype == Transition.ToNewList)
	{
		if ( fe.filters.len() > 0 )
			if ( !filters_initDone ) filters_init()

		g_indexChanged = true

		adjust_rom_info()
		selectorGenre.msg = genre_formatted()
		adjust_rom_info_positions()

		selectorTitle.msg = carrier.tilesTableTxt[ carrier.indexActive ].msg_wrapped
		selectorTitleEx.msg = full_title( carrier.tilesTableTxt[ carrier.indexActive ])

		if ( var < 0 )
		{
		}

		if ( var > 0 )
		{
		}
	}

	if ( ttype == Transition.ToGame )
	{
		if ( g_blackoutTimer == 0 )
		{
			soundChord.playing = true
			zoomTop.anim( 0, 0.5 )
			zoomTopShadow.anim( 0, 0.5 )
			zoomBottom.anim( 0, 0.5 )
			zoomCentre.anim( 0, -0.5 )
		}
		if ( g_blackoutTimer < 255 )
		{
			g_inGame = true
			g_blackoutTimer += BLACKOUT_SPEED_TO_GAME
			blackout.alpha = min( g_blackoutTimer, 255 )

			tick_all( ttime )
			return true
		}
		blackout.alpha = 255
		g_blackoutTimer = 255
		return false
	}

	if ( ttype == Transition.FromGame )
	{
		g_inGame = false
		if ( g_blackoutTimer == 255 )
		{
			zoomTop.anim( 0.5, 0.0 )
			zoomTopShadow.anim( 0.5, 0.0 )
			zoomBottom.anim( 0.5, 0.0 )
			zoomCentre.anim( -0.5, 0.0 )
		}
		if ( g_blackoutTimer > 0 )
		{
			g_blackoutTimer -= BLACKOUT_SPEED_FROM_GAME
			blackout.alpha = max( g_blackoutTimer, 0 )

			tick_all( ttime )
			return true
		}
		blackout.alpha = 0
		g_blackoutTimer = 0
	}
	return false
}
fe.add_transition_callback( "on_transition" )


function next_filter()
{
	filters_active = wrap( ++filters_active, fe.filters.len() )
	for ( local i = 0; i < filters.len(); i++ )
		filters[i].msg = fe.filters[ wrap( filters_active + 1 - i, fe.filters.len() )].name

	for ( local i = 0; i < 5; i++ )
		filters_animY[ 4 - i ].anim( FILTERS_Y + FILTERS_GAP * ( i + 1 ), FILTERS_Y + FILTERS_GAP * i )

	filters_animA[0].set( 0.0 )
	filters_animA[1].anim( 0.0, FILTERS_SEL_RGBA[3] )
	filters_animA[3].set( FILTERS_RGBA[3] )
	filters_animA[4].anim( FILTERS_RGBA[3], 0.0 )

	soundDrip.playing = true
}

function prev_filter()
{
	filters_active = wrap( --filters_active, fe.filters.len() )
	for ( local i = 0; i < filters.len(); i++ )
		filters[i].msg = fe.filters[ wrap( filters_active + 1 - i, fe.filters.len() )].name

	for ( local i = 0; i < 5; i++ )
		filters_animY[ 4 - i ].anim( FILTERS_Y + FILTERS_GAP * ( i - 1 ), FILTERS_Y + FILTERS_GAP * i )

	filters_animA[0].anim( FILTERS_RGBA[3], 0.0 )
	filters_animA[1].set( FILTERS_SEL_RGBA[3] )
	filters_animA[3].anim( 0.0, FILTERS_RGBA[3] )
	filters_animA[4].set( 0.0 )

	soundDrip.playing = true
}




///////////////////////////
// Modern Dialogs - Sounds
///////////////////////////

function overlay_transition( ttype, var, ttime )
{
	switch ( ttype )
	{
		case Transition.ShowOverlay:
			soundMenuPopup.playing = true
			break

		case Transition.NewSelOverlay:
			soundMenuSelect.playing = true
			break

		case Transition.HideOverlay:
		case Transition.ShowOverlay:
			soundMenuPress.playing = true
			break
	}
	return false
}
fe.add_transition_callback( "overlay_transition" )


////////////////////
// Tick Callback
////////////////////

function tick_layout( ttime )
{
	if ( fe.get_input_state( "up" ) == false && fe.get_input_state( "down" ) == false )
		g_autorepeatSuppression = 0

	if ( g_indexChanged == true )
	{
		alphabet_update()
		g_indexChanged = false
	}

	genre_fade( ttime )

	local offset = carrier.animFadeYTiles[0].to - carrier.animFadeYTiles[0].from
	if ( abs( offset ) < FILTERS_GAP / 2.0 && g_filterTriggered == false )
	{
		offset = FILTERS_GAP * sign( offset )
		for ( local i = 0; i < carrier.animFadeYTiles.len(); i++ )
		{
			carrier.animFadeYTiles[i].from -= offset
			carrier.animFadeYTiles[i].from2 -= offset
			carrier.animFadeYTiles[i].to -= offset
			carrier.animScale[i].setOnce = true
		}

		g_filterTriggered = true

		carrier.animScale[ carrier.indexActive ].set(0)
		carrier.animScale[ carrier.indexActive ].wait(1)
		if (carrier.animFadeYTiles[0].running )
			if (offset < 0 ) fe.signal( "next_filter" )
			else if (offset > 0 ) fe.signal( "prev_filter" )
	}

	if ( fe.list.size == 0 )
		gameListPosition.alpha = 0
	else
		gameListPosition.alpha = carrier.selector.alpha * 2.0 / 3.0

	gameListPosition.y = carrier.selector.y - 224
}
fe.add_ticks_callback( "tick_layout" )


////////////////////
// Bottom Bar
////////////////////

fe.do_nut( "config.ini" )

local bottomBar = fe.add_surface( flw, ceil(flh * 0.037 ))
bottomBar.set_pos( 0, flh - ceil(flh * 0.037 ))
bottomBar.visible = false

if ( my_config["labels"] == "Yes" )
{
	bottomBar.visible = true
	local bottomBarBG = bottomBar.add_image( "images/white.png", 0, 0, bottomBar.width, bottomBar.height)
	bottomBarBG.set_rgb( BOTTOM_BAR_RGBA[0], BOTTOM_BAR_RGBA[1], BOTTOM_BAR_RGBA[2] )
	bottomBar.alpha = BOTTOM_BAR_RGBA[3]

	if ( THEME_DARK > 0 ) bottomBar.blend_mode = BlendMode.Add
	else bottomBar.blend_mode = BlendMode.Subtract

	labels <- []
	for ( local i = 1; i <= config_button_labels.len(); i++ )
	{
		l <- bottomBar.add_text( config_button_labels[i][0], 0, 0, ceil(bottomBar.width / 4), bottomBar.height )
		l.char_size = bottomBar.height * 0.6
		l.set_rgb( BOTTOM_LEGEND_RGBA[0], BOTTOM_LEGEND_RGBA[1], BOTTOM_LEGEND_RGBA[2] )
		l.alpha = BOTTOM_LEGEND_RGBA[3]
		l.align = Align.MiddleCentre
		l.margin = 0
		l.font = "BarlowCondensed-SemiBold2-Display0.80.ttf"
		l.width = l.msg_width
		l.x = ceil(flw * config_button_labels[i][1] - l.width / 2)
		labels.push( l )
	}
}


////////////////////
// Top Bar
////////////////////

local topBar = fe.add_surface( flw, ceil(flh * 0.1759) - 48 )
local topBarBG = topBar.add_image( "images/white.png", 0, 0, topBar.width, topBar.height) // h=188
topBarBG.set_rgb( TOP_BAR_RGBA[0], TOP_BAR_RGBA[1], TOP_BAR_RGBA[2] )
topBar.alpha = TOP_BAR_RGBA[3]

if ( THEME_DARK > 0 ) topBar.blend_mode = BlendMode.Add
else topBar.blend_mode = BlendMode.Subtract


if ( THEME_DARK > 0 )
{
	topBarSH <- fe.add_image( "images/shadowHbotM.png", 0, topBar.height, topBar.width, 64) // h=188
	topBarSH.blend_mode = BlendMode.Multiply
	topBarSH.alpha = 50
}
else
{
	topBarSH <- fe.add_image( "images/shadowHtopM.png", 0, topBar.height - 64, topBar.width, 64) // h=188
	topBarSH.blend_mode = BlendMode.Multiply
	topBarSH.alpha = 50
}



// System logo. TODO: implement other systems
local logoMame = topBar.add_image("images/logos/Arcade.png", 65, 65)
//logoMame.alpha = 255
logoMame.set_rgb( LOGO_RGBA[0], LOGO_RGBA[1], LOGO_RGBA[2] )
logoMame.width = 250
logoMame.height = 60

timeTxt <- topBar.add_text("23:35",1625,55,230,52)
timeTxt.font = "BarlowCondensed-SemiBold2-Display0.80.ttf"
timeTxt.align = Align.MiddleRight
timeTxt.set_rgb( LOGO_RGBA[0], LOGO_RGBA[1], LOGO_RGBA[2] )
timeTxt.margin = 0

dateTxt <- topBar.add_text("28/05/2017",1705,103,150,27)
dateTxt.font = "BarlowCondensed-Regular2-Display0.80.ttf"
dateTxt.align = Align.MiddleRight
dateTxt.set_rgb( LOGO_RGBA[0], LOGO_RGBA[1], LOGO_RGBA[2] )
dateTxt.margin = 0


function on_signal( sig )
{
	if ( fe.list.size == 0 )
		if ( sig == "next_game" || sig == "prev_game" || sig == "select" )
			return true

	if ( g_sleepState == true )
	{
		//g_snaps[ g_activeSnap ].video_playing = false
		//g_snaps[ g_activeSnap ].video_playing = true
		g_sleepState = false
		carrier.animScale[ carrier.indexActive ].set(0)
		carrier.animScale[ carrier.indexActive ].wait(1)
		return true
	}


	switch ( sig )
	{
		// This will allow for horizontal navigation in the next AttractMode release
		// without remapping actions in settings
		// case "left":
		// 	fe.signal( "prev_game" )
		// 	return true

		// case "right":
		// 	fe.signal( "next_game" )
		// 	return true

		case "down":
			if ( fe.filters.len() > 0 )
			{
				g_autorepeatSuppression++
				if ( g_filterTriggered == true && g_autorepeatSuppression < 2)
				{
					g_filterTriggered = false
					carrier.change_filter(1)
					next_filter()
				}
			}
			return true

		case "up":
			if ( fe.filters.len() > 0 )
			{
				g_autorepeatSuppression++
				if ( g_filterTriggered == true && g_autorepeatSuppression < 2)
				{
					g_filterTriggered = false
					carrier.change_filter(-1)
					prev_filter()
				}
			}
			return true

		case "next_filter":
		case "prev_filter":
			if ( fe.filters.len() == 0 )
				return true

		default:
			return false
	}
}
fe.add_signal_handler( "on_signal" )

ZOOM_SPEED <- 0.9
zoomTop <- Animate( topBar, "zoom", 0.01, 0, ZOOM_SPEED )
zoomTopShadow <- Animate( topBarSH, "zoom", 0.01, 0, ZOOM_SPEED )
zoomBottom <- Animate( bottomBar, "zoom", 0.01, 0, ZOOM_SPEED )
zoomCentre <- Animate( ms, "zoom", 0.01, 0, ZOOM_SPEED )
blackoutAnimA <- Animate( blackout, "alpha", 0.01, 0, ZOOM_SPEED )
zoomTop.zoom_set()
zoomTopShadow.zoom_set()
zoomBottom.zoom_set()
zoomCentre.zoom_set()


////////////////////
// Z-Order
////////////////////

for ( local i = 0; i < carrier.tilesTable.len(); i++ )
{
	carrier.tilesTable[i].zorder = 0
	carrier.tilesTableTxt[i].zorder = 1
	carrier.tilesTableFav[i].zorder = 1
}




////////////////////
// Modern Dialogs
////////////////////

fe.do_nut( "modern_dialogs/initialize.nut" )
