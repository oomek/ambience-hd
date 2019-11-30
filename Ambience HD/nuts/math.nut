// Extended Math Functions

function min( x, y ) { return x < y ? x : y }
function max( x, y ) { return x > y ? x : y }
function clamp( x, min, max ) {	return x > max ? max : x < min ? min : x }
function sign( x ) { return x < 0 ? -1 : 1 }
function irand( max ) { return (( 1.0 * rand() / RAND_MAX ) * ( max + 1 )).tointeger() }
function mix( a, b, c) { return a * ( 1 - c ) + b * c }
 // wrap around value within range { 0, n }
function wrap( i, n ) { while ( i < 0 ) { i += n }; while ( i >= n ) { i -= n }; return i }
function floorf( a ){ return floor( format( "%.5f", a ).tofloat() ) }
