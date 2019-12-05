function alphabet_define()
{
	alphabet_letterTable <- "0ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	alphabet_numberTable <- "'123456789"
	alphabet_activeLetterShaderX <- null
	alphabet_activeLetterTableX <- array( alphabet_letterTable.len() )
	alphabet_index <- 0
	alphabet_firstLetter <- "0"
}

function alphabet_update()
{
	alphabet_firstLetter = fe.game_info( Info.Title )
	if ( alphabet_firstLetter != "" )
	{
		if ( alphabet_firstLetter.find( "The " ) == 0 )
			alphabet_firstLetter = alphabet_firstLetter.slice( 4, 5 )
		else if ( alphabet_firstLetter.find( "Vs. " ) == 0 )
			alphabet_firstLetter = alphabet_firstLetter.slice( 4, 5 )
		else
			alphabet_firstLetter = alphabet_firstLetter.slice( 0, 1 )

		if ( alphabet_numberTable.find( alphabet_firstLetter.toupper() ) != null )
			alphabet_index = 0
		else
			alphabet_index = alphabet_letterTable.find( alphabet_firstLetter.toupper() )
		if ( alphabet_index != null )
			alphabet_activeLetterShaderX.to = alphabet_activeLetterTableX[ alphabet_index ]
	}
	if ( fe.list.size == 0 )
		alphabet_activeLetterShaderX.to = alphabet_activeLetterTableX[0]
}

function alphabet_init()
{
	// Alphabet selector shift table for each letter

	// Alphabet Surface
	local alphabetLetterX = 0
	local alphabetHeight = 26
	local alphabetLetterSpacing = alphabetHeight
	local alphabetLetters = []
	local alphabetWidth = 0

	//Calculate surface width for alphabet
	local tempLetter = fe.add_text( "", 0, 0, 0, alphabetHeight)
	tempLetter.align = Align.MiddleLeft
	tempLetter.nomargin = true
	tempLetter.visible = false
	tempLetter.font = "BarlowCondensed-SemiBold2-Display0.80.ttf"
	for ( local i = 0; i < alphabet_letterTable.len(); i++ )
	{
		tempLetter.msg = alphabet_letterTable.slice( i, i + 1 )
		alphabetWidth += tempLetter.msg_width + alphabetLetterSpacing
	}

	surfaceAlphabet <- fe.add_surface( alphabetWidth , alphabetHeight )
	surfaceAlphabet.origin_x = floor( surfaceAlphabet.width / 2.0 )
	surfaceAlphabet.set_pos( floor( flw / 2.0 ), 888 + 40 + 28 )

	for ( local i = 0; i < alphabet_letterTable.len(); i++ )
	{
		alphabetLetters.push( surfaceAlphabet.add_text( alphabet_letterTable.slice( i, i + 1 ), 0, 0, alphabetHeight, alphabetHeight ))
		alphabetLetters[i].align = Align.MiddleLeft
		alphabetLetters[i].nomargin = true
		alphabetLetters[i].font = "BarlowCondensed-SemiBold2-Display0.80.ttf"
		alphabetLetters[i].width = alphabetLetters[i].msg_width
		alphabetLetters[i].x = alphabetLetterX + floor( alphabetLetterSpacing / 2.0 )
		alphabet_activeLetterTableX[i] = alphabetLetterX + floor( alphabetLetters[i].msg_width / 2.0 )
		alphabetLetterX += alphabetLetters[i].width + alphabetLetterSpacing
	}

	local surfaceAlphabetShader = fe.add_shader( Shader.Fragment, "shaders/alphabet.frag" )
	surfaceAlphabet.shader = surfaceAlphabetShader
	surfaceAlphabetShader.set_param( "radius", floor( alphabetHeight / 4.0 ))
	surfaceAlphabetShader.set_param( "size", surfaceAlphabet.width, surfaceAlphabet.height )
	surfaceAlphabetShader.set_param( "position", 200 )
	surfaceAlphabetShader.set_param( "colour" ALPHABET_RGBA[0], ALPHABET_RGBA[1], ALPHABET_RGBA[2], ALPHABET_RGBA[3] )

	alphabet_activeLetterShaderX = Animate( surfaceAlphabetShader, "shaderx", 4, 0, 0.75 )

	local fontShader = fe.add_shader( Shader.Vertex, "shaders/font.vert" )
	fontShader.set_param( "width", flw )
}
