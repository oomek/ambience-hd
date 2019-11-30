///////////////////////////////////////////////////
//
// Modern Dialogs module
// This is an internal part of
// Ambience HD theme for Attract-Mode Frontend
//
// by Oomek 2019
//
///////////////////////////////////////////////////

fe.do_nut( "modern_dialogs/math.nut" )
fe.do_nut( "modern_dialogs/modern_dialog.nut" )
fe.do_nut( "modern_dialogs/modern_dialog_animate.nut" )

class ModernDialogs
{
	key_add_favourite = "add_favourite"
	key_displays_menu = "displays_menu"
	key_filters_menu = "filters_menu"
	key_add_tags = "add_tags"
	key_exit = "exit"
	key_default = "default"
	pressed_key = null
	sleep_state = false
	dialog = null
	dialogAnimZoom = null
	dialog_row_height = 0
	dialog_rows = 6
	dialog_select_pos = 0

	constructor()
	{
		pressed_key = key_default
		dialog_row_height = ceil( fe.layout.height / 1080.0 * 50.0 / 1.0 ) * 1 //TODO / 2.0 and * 2.0 to investigate non 1080p resolutions
		dialog = ModernDialog( fe.layout.width / 2, fe.layout.height / 2, math.max( fe.layout.width / 3, fe.layout.height / 3 ), dialog_row_height, dialog_rows )
		dialog.frame.rows = dialog_rows
		dialogAnimZoom = ModernDialogAnimate( dialog )
		fe.overlay.set_custom_controls( dialog.title, dialog.list )
		fe.add_transition_callback( this, "modern_dialogs_overlay_transition" )
		fe.add_signal_handler( this, "modern_dialogs_on_signal" )
	}

	function sleep()
	{
		if ( sleep_state == false )
		{
			local dialog_options = []
			local dialog_title = "POWER OPTIONS"
			dialog_options.push( "Exit Attract-Mode" )
			foreach (key, data in config_power_menu)
				dialog_options.push( data[0] )
			dialog_options.push( "Back" )
			local result = fe.overlay.list_dialog( dialog_options, dialog_title, 0, dialog_options.len() - 1 )

			for ( local i = 1; i <= config_power_menu.len(); i++ )
			{
				if (( result ) == i )
					fe.plugin_command_bg( config_power_menu[i][1], config_power_menu[i][2] )
			}

			switch( result )
			{
				case 0:
					fe.signal( "exit_to_desktop" )
					break
				case config_power_menu.len() + 1:
					break
				default:
					break
			}
		}
		else
		{
			sleep_state = false
		}

		pressed_key = key_default
	}

	function modern_dialogs_overlay_transition( ttype, var, ttime )
	{
		switch ( ttype )
		{
			case Transition.ShowOverlay:
				dialogAnimZoom.to = 1.0
				dialog.rows = dialog.list.list_size
				dialog.set(0)

				switch( pressed_key )
				{
					case key_add_favourite:
						local m = fe.game_info( Info.Favourite )

						if ( m == "1" )
							dialog.title.msg = "REMOVE FROM FAVOURITES?"
						else
							dialog.title.msg = "ADD TO FAVOURITES?"

						dialog.set(1)
						break

					case key_displays_menu:
						// Special case when exit is called from Displays menu
						if ( var == Overlay.Exit )
						{
							dialog.title.msg = "EXIT ATTRACT-MODE?"
							dialog.set(1)
						}
						else
						{
							dialog.title.msg = "DISPLAYS"
							dialog.set( fe.list.display_index )
						}
						break

					case key_filters_menu:
						dialog.title.msg = "FILTERS"
						dialog.set( fe.list.filter_index )
						break

					case key_add_tags:
						dialog.title.msg = "TAGS"
						break

					case key_exit:
						dialog.title.msg = "POWER OPTIONS"
						dialog.set(0)
						break
				}
				break

			case Transition.HideOverlay:
				dialogAnimZoom.to = 0.0
				if ( dialogAnimZoom.from > 0.0 )
				{
					foreach ( a in carrier.animScale )
						a.tick_animate( ttime )

					carrier.tick_carrier( ttime )
					tick_layout( ttime )
					dialogAnimZoom.tick( ttime )
					return true
				}
				break

			case Transition.NewSelOverlay:
				dialog.move( var )
				break
		}
	}

	function modern_dialogs_on_signal( sig )
	{
		switch ( sig )
		{
			case key_add_favourite:
				pressed_key = key_add_favourite
				return false

			case key_displays_menu:
				pressed_key = key_displays_menu
				return false

			case key_filters_menu:
				pressed_key = key_filters_menu
				// return false
				return true // We don't need filters menu showing up in Ambience

			case key_add_tags:
				pressed_key = key_add_tags
				return false

			case key_exit:
				pressed_key = key_exit
				sleep()
				return true

			default:
				return false
		}
	}
}

ModernDialogs()
