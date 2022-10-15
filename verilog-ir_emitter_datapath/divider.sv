//
// anode_decoder.sv
// canonical  : https://github.com/lduran2/computer_architecture-projects/blob/master/verilog-ir_emitter_datapath/divider.sv
// lab3       : version 10/15/2022, 12:14 PM
// by         : Leomar Duran
// synthesis >= Yosys 0.9.0
//
//////////////////////////////////////////////////////////////////////////////////
// Creates a custom clock by dividing the input clock.
//
// Parameter:
//     BIT_SIZE = number of bits in the system clock count (default 4)
// Output:
//     tc : reg = terminal count representing new clock signal
//     count : reg [(BIT_SIZE - 1):0] = 
// Input:
//     clk : wire = input clock signal
//     rst : wire = signal to force reset the clock
//     ena : wire = signal to enable countdown
//     init_count : wire [(BIT_SIZE - 1):0] = where to start the
//         countdown
//////////////////////////////////////////////////////////////////////////////////
module divider #(parameter BIT_SIZE=4) (
	output reg tc,
	output reg [(BIT_SIZE - 1):0] count,
	input wire clk,
	input wire rst,
	input wire ena,
	input wire [(BIT_SIZE - 1):0] init_count
	);

	// represents the on state for the reset signal
	parameter RST_ON = 1'b1;

	// the next value to which to set the count
	reg [(BIT_SIZE - 1):0] next_count;
	// local copy (internal) of reset signal that can be overrided
	reg in_rst;

	// sequential logic:
	// whenever the clock goes from 0 to 1
	always @(posedge clk) begin
		// update the count
		count <= next_count;
	end

	// combinational logic
	always @* begin
		// defaults
		next_count = count; // hold
		in_rst = rst; // use external reset signal

		// reset the count to initial value on in_rst
		if (in_rst == RST_ON) begin
			next_count = init_count;
		end // end if (in_rst == RST_ON)
	end // always @*

endmodule // divider
