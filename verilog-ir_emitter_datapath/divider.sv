//
// divider.sv
// canonical  : https://github.com/lduran2/computer_architecture-projects/blob/master/verilog-ir_emitter_datapath/divider.sv
// lab3       : version 10/15/2022, 18:56 PM
// by         : Leomar Duran
// synthesis >= Yosys 0.9.0
//
//////////////////////////////////////////////////////////////////////////////////
// Creates a custom clock by dividing the input clock.
//
// The divider is parameterized to allow for different values of
// BIT_SIZE for the count.
//
// The `init_count` represents the amount by which to divide the input
// clock signal, that is, given the input clock frequency `in_freq` and
// the desired clock frequency `out_freq`, we need an `init_count` s.t.
//
//         ((out_freq)(init_count + 1) - in_freq) in Z[out_freq].
//
// The count will go from init_count down to 0 for a total count of
// (init_count + 1) states.
//
// The module accepts the input clock signal `clk` and produces the
// terminal count signal `tc` as a new clock signal whenever the
// (count == 0).  The count updates on the positive clock edge, and is
// also expose for convenience.
//
// Parameter:
//     BIT_SIZE = number of bits in the system clock count (default 4)
// Output:
//     tc: reg = terminal count representing new clock signal
//     count: reg [(BIT_SIZE - 1):0] = current value of the countdown
// Input:
//     clk: wire = input clock signal
//     rst: wire = signal to force reset the divider, so that
//         `count = init_count`
//     ena: wire = signal to enable countdown.  When the wire is reset
//         the count holds.
//     init_count: wire [(BIT_SIZE - 1):0] = where to start the
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
	// represents the on state for the enable signal
	parameter ENA_ON = 1'b1;

	// the next value to which to set the count
	reg [(BIT_SIZE - 1):0] next_count;

	// sequential logic (flip-flop):
	// whenever the clock goes from 0 to 1
	always @(posedge clk) begin
		// update the count
		count <= next_count;
	end // end always @(posedge clk)

	// combinational logic
	always @* begin
		// defaults
		next_count = count; // hold
		tc = 1'b0; // no terminal count signal yet

		// decrease count if enable signal is set
		if (ena == ENA_ON) begin
			// note only to check count and change next_count
			next_count = (count - 1'b1);
			// if countdown finished:
			if (count == 1'd0) begin
				tc = 1'b1; // flag terminal count
			end // if (count == 1'd0)
		end // if (ena == ENA_ON)

		// reset the count to initial value
		// on terminal count or rst
		if ((tc == 1'b1) || (rst == RST_ON)) begin
			next_count = init_count;
		end // if ((tc == 1'b1) || (rst == RST_ON))
	end // always @*

endmodule // divider
