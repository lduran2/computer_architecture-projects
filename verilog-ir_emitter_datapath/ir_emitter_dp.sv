//
// ip_emitter_dp.sv
// canonical  : https://github.com/lduran2/computer_architecture-projects/blob/master/verilog-ir_emitter_datapath/ir_emitter_dp.sv
// lab3       : version 10/15/2022, 10:22 PM
// by         : Leomar Duran
// synthesis >= Yosys 0.9.0
//
//////////////////////////////////////////////////////////////////////////////////
// Data path that creates a modulated f = 38 kHz carrier wave for an
// infrared wave from the Basys3's 100 MHz clock input.
//
// The output signal should be a square wave with a 50% duty cycle. 
// Thus, the clock signal is first divided into a
// 2f = 2(38 kHz) = 76 kHz signal by a 1316-count divider (because
// 1316*76 kHz = 100.016 MHz, the lowest multiple of 76 kHz greater
// than the original clock frequency of 100 MHz) before being divided
// into the 2-state duty cycle by a 2-count divider giving the desired
// duty cycle.
//
// Output:
//     emitter_out: wire = modulated clock signal driving
//         the IR emitter
//     tc_modulator: wire = signals that modulation count completed
// Input:
//     clk: wire = the Basys3 system clock signal
//     rst: wire = signal to force reset all internal dividers
//     ena: wire = enable signal for carrier frequency counter
//     mod_sel: wire [1:0] = selects the initial count for the modulator
//     sw_modulator: wire = control resetting the emitter_out signal
//////////////////////////////////////////////////////////////////////////////////
module ir_emitter_dp (
	output wire emitter_out,
	output wire tc_modulator,
	input wire clk,
	input wire rst,
	input wire ena,
	input wire [1:0] mod_sel,
	input wire sw_modulator
	);

	// count for dividing the system clock signal to 2f
	parameter COUNT_2F = 11'd1315;
	// corresponding bit size
	parameter BIT_SIZE_2F = 11;

	// terminal count of 76k divider
	wire tc_2f;
	// carrier signal produced by u_sw_carrier
	wire sw_carrier;
	// terminal count produced by u_sw_carrier
	wire tc_carrier;

	// the 2f divider
	// the count is ignored
	divider #(.BIT_SIZE(BIT_SIZE_2F)) u_2f(
		// output
		.tc(tc_modulator), .count(),
		// input
		.init_count(COUNT_2F), .clk(clk), .rst(rst), .ena(ena)
	);

	// the 50%-duty cycle square wave carrier divider
	divider #(.BIT_SIZE(1)) u_sw_carrier(
		// output
		.tc(tc_carrier), .count(sw_carrier),
		// input
		.init_count(1'b1), .clk(clk), .rst(rst), .ena(tc_2f)
	);

endmodule // ir_emitter_dp
