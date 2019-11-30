// Extended Math Functions
// Oomek 2018

math <-
{
	min = function( x, y ) { return x < y ? x : y }
	max = function( x, y ) { return x > y ? x : y }
	clamp = function( x, min, max ) { return x > max ? max : x < min ? min : x }
	sign = function( x ) { return x < 0 ? -1 : 1 }
	irand = function( max ) { return (( 1.0 * rand() / RAND_MAX ) * ( max + 1 )).tointeger() }
	mix = function( a, b, c) { return a * ( 1 - c ) + b * c }
	// wrap around value within range { 0, n }
	wrap = function( i, n ) { while ( i < 0 ) { i += n }; while ( i >= n ) { i -= n }; return i }
	logn = function( x ) { return log( x ) }
}
