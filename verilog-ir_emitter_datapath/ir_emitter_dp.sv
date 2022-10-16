//
// ip_emitter_dp.sv
// canonical  : https://github.com/lduran2/computer_architecture-projects/blob/master/verilog-ir_emitter_datapath/ir_emitter_dp.sv
// lab3       : version 10/15/2022, 10:22 PM
// by         : Leomar Duran
// synthesis >= Yosys 0.9.0
//
//////////////////////////////////////////////////////////////////////////////////
// Data path that creates a modulated 38 kHz carrier wave for an
// infrared wave from the Basys3's 100 MHz clock input.
//
// Output:
//     emitter_out: wire = modulated clock signal driving
//         the IR emitter
//     tc_modulator: wire = signals that modulation count completed
// Input:
//     clk: wire = Basys3 system clock signal
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

endmodule // ir_emitter_dp
