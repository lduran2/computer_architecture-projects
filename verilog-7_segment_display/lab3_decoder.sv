//
// lab3_decoder.sv
// canonical  : https://github.com/lduran2/computer_architecture-projects/blob/master/verilog-7_segment_display/lab3_decoder.sv
// lab3       : version 10/08/2022, 08:32 AM
// by         : Leomar Duran
// synthesis >= Yosys 0.9.0
//
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Top level module for lab3, the 7-segment display.
// Instantiates the lower level decoder modules using switches
// for input.
//
// Switch 6 controls whether the display is on.
// Switches 5 and 4 control the anode.
// Switches 3-0 control the cathode.
//
// Output:
//     an: wire [3:0] = decoded value for anode
//     cathode: wire [6:0] = decoded value for cathode
// Input:
//     sw: wire [6:0] = switch inputs
//
module lab3_decoder(
	output wire [3:0] an,
	output wire [6:0] cathode,
	input wire [6:0] sw
	);

	// instantiate a 7-segment decoder
	svn_seg_decoder u_svn_seg_decoder(
		.seg_out(cathode),
		.display_on(sw[6]),
		.bcd_in(sw[3:0])
	);

	// instantiate an anode decoder
	anode_decoder u_anode_decoder(
		.anode(an),
		.switch_in(sw[5:4])
	);

endmodule // lab3_decoder
