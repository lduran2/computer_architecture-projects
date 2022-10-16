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

	// counts corresponding to the Lego RC Encoding specification
	// since counts are in from mod_init_count down to 0, these counts
	// mark (mod_init_count + 1) cycles.
	//  6 cycles for IR mark
	parameter IR_MARK = 6'd5;
	// 10 cycles for Low bit pause
	parameter LOW_BIT_PAUSE = 6'd9;
	// 21 cycles for High bit pause
	parameter HIGH_BIT_PAUSE = 6'd20;
	// 39 cycles for Start/Stop bit pause
	parameter START_STOP_BIT_PAUSE = 6'd38;
	// the corresponding bit size
	parameter MOD_BIT_SIZE = 6;

	// terminal count of 76k divider
	wire tc_2f;
	// carrier signal produced by u_sw_carrier
	wire sw_carrier;
	// terminal count produced by u_sw_carrier
	wire tc_carrier;
	// initial count for the modulator
	reg [5:0] mod_init_count;

	// the 2f divider
	// ignore the count
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

	// short circuit emitter_out if not sw_modulator
	and emitter_and(emitter_out, sw_modulator, sw_carrier);

	always @* begin
		// 4x1 mux
		// choose the count depending on mod_sel and
		// the Lego RC Encoding specification
		case (mod_sel)
			2'b00: mod_init_count = IR_MARK;
			2'b01: mod_init_count = LOW_BIT_PAUSE;
			2'b10: mod_init_count = HIGH_BIT_PAUSE;
			2'b11: mod_init_count = START_STOP_BIT_PAUSE;
			default: mod_init_count = 6'd0;
		endcase // (mod_sel)
	end // always @*

	// the modulator divider
	// ignore the count
	divider #(.BIT_SIZE(MOD_BIT_SIZE)) u_modulator(
		// output
		.tc(tc_modulator), .count(),
		// input
		.init_count(mod_init_count), .clk(clk), .rst(rst), .ena(tc_carrier)
	);

endmodule // ir_emitter_dp
