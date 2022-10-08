//
// lab3 : version 10/08/2022, 03:40 AM
// by   : Leomar Duran
//
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/// Translates the binary coded decimal to the bit mask representing
/// the segments to activate.
///
/// In this situation, we refer to the position of the digit as the
/// digit, and the value as the combination of segments active in that
/// position.
///
/// Each digit has a common anode and 7 cathodes for each segment. 
/// Anodes and cathodes are both active LOW meaning they are on with a
/// low voltage.  This allows us to display 4 digits using
/// (4 anodes) + (7 segments) = 11 wires.
///
/// The cathodes are labeled as shown in figure 2, forming a 7-bit
/// binary number of the form 7'bGFEDCBA.
///
///     AAAAA
///     F   B
///     F   B
///     GGGGG
///     E   C
///     E   C
///     DDDDD
///
/// Figure 2. The segments of a digit.
///
/// Although the expected input is a binary-coded decimal, the decoder
/// is configured to produce hexadecimal digits when give a value 4'ha
/// to 4'hf.
///
/// Output:
///     seg_out : reg [6:0] = bit mask to activate the segments,
///         active LOW
/// Input:
///     bcd_in: wire [3:0] = 4-bit binary encoded decimal giving the
///         value of the digit to display
///     display_on: wire = whether the digit should be on at all
///
/// See: anode_decoder.sv
///
module svn_seg_decoder(
	output reg [6:0] seg_out,
	input wire [3:0] bcd_in,
	input wire display_on
	);

endmodule // svn_seg_decoder
