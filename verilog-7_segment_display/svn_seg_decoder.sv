//
// svn_seg_decoder.sv
// canonical  : https://github.com/lduran2/computer_architecture-projects/blob/master/verilog-7_segment_display/svn_seg_decoder.sv
// lab3       : version 10/08/2022, 08:19 AM
// by         : Leomar Duran
// synthesis >= Yosys 0.9.0
//
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Translates the binary coded decimal to the bit mask representing
// the segments to activate.
//
// In this situation, we refer to the position of the digit as the
// digit, and the value as the combination of segments active in that
// position.
//
// Each digit has a common anode and 7 cathodes for each segment. 
// Anodes and cathodes are both active LOW meaning they are on with a
// low voltage.  This allows us to display 4 digits using
// (4 anodes) + (7 segments) = 11 wires.
//
// The cathodes are labeled as shown in figure 2, forming a 7-bit
// binary number of the form 7'bGFEDCBA.
//
//     AAAAA
//     F   B
//     F   B
//     GGGGG
//     E   C
//     E   C
//     DDDDD
//
// Figure 2. The segments of a digit.
//
// Although the expected input is a binary-coded decimal, the decoder
// is configured to produce hexadecimal digits when give a value 4'ha
// to 4'hf.
//
// Output:
//     seg_out : reg [6:0] = bit mask to activate the segments,
//         active LOW
// Input:
//     bcd_in: wire [3:0] = 4-bit binary encoded decimal giving the
//         value of the digit to display
//     display_on: wire = whether the digit is on at all
//
// See: anode_decoder.sv
//
module svn_seg_decoder(
	output reg [6:0] seg_out,
	input wire [3:0] bcd_in,
	input wire display_on
	);

	// represents the on state for the display
	parameter DISPLAY_STATE_ON = 1'b1;

	// combinational logic
	always @* begin
		// default seg_out to all off if (display_on) if not on
		// or if an invalid (bcd_in) is given
		seg_out = 7'b1111111;
		// if the display is on
		if (display_on == DISPLAY_STATE_ON) begin
			// perform decoding
			//
			// remember that seg_out is a binary number 7'bGFEDCBA
			// represented on the 7-segment display:
			//
			// AAAAA
			// F   B
			// F   B
			// GGGGG
			// E   C
			// E   C
			// DDDDD
			//
			case (bcd_in)
				4'h0: seg_out = 7'b1000000;
				4'h1: seg_out = 7'b1111001;
				4'h2: seg_out = 7'b0100100;
				4'h3: seg_out = 7'b0110000;
				4'h4: seg_out = 7'b0011001;
				4'h5: seg_out = 7'b0010010;
				4'h6: seg_out = 7'b0000010;
				4'h7: seg_out = 7'b1111000;
				4'h8: seg_out = 7'b0000000;
				4'h9: seg_out = 7'b0010000;
				4'ha: seg_out = 7'b0100000;
				4'hb: seg_out = 7'b0000011;
				4'hC: seg_out = 7'b1000110;
				4'hd: seg_out = 7'b0100001;
				4'hE: seg_out = 7'b0000110;
				4'hF: seg_out = 7'b0001110;
				// since seg_out is already defaulted,
				// there is no need for a default case
			endcase // (bcd_in)
		end // if (display_on == DISPLAY_STATE_ON)
	end // always @*

endmodule // svn_seg_decoder
