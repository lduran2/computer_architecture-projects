//
// lab3 : version 10/08/2022
// by   : Leomar Duran
//
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/// Translates the number of the digit to the bit mask representing
/// the anode to activate.
///
/// The display shows 4 digits which are chosen by a 2-bit number,
/// 00 to 11.   The digit is controlled by which anode is activated. 
/// Each digit has the cathodes in common.  Anodes and cathodes are
/// both active LOW meaning they are on with a low voltage.  Multiple
/// digits are displayed by switching between anodes faster than the
/// eye can see.  This allows us to display 4 digits using
/// (4 cathodes) x (7 segments) = 28 wires.
///
/// Output:
///	    anode : reg [3:0] = bit mask to activate the anode, active LOW
/// Input:
///     switch_in: wire [1:0] = two bit number representing the anode
//		to activate
///
module anode_decoder(
	output reg [3:0] anode,
	input wire [1:0] switch_in
	);

endmodule // anode_decoder
