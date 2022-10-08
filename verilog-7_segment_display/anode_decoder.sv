//
// lab3 : version 10/08/2022, 02:24 AM
// by   : Leomar Duran
//
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/// Translates the number of the digit to the bit mask representing
/// the anode to activate.
///
/// In this situation, we refer to the position of the digit as the
/// digit, and the value as the combination of segments active in that
/// position.
///
/// The display shows 4 digit displays which are chosen by a 2-bit number,
/// 00 to 11.   The digit is controlled by which anode is activated. 
/// All the digit have the cathodes in common.  Anodes and cathodes are
/// both active LOW meaning they are on with a low voltage.  Multiple
/// digits are displayed by switching between anodes faster than the
/// eye can see.  This allows us to display 4 digits using
/// (4 anodes) + (7 segments) = 11 wires.
///
/// anodes:                 3                            2                            1                            0
///                         |                            |                            |                            |             
///          ++-------------|-------------++-------------|-------------++-------------|-------------++-------------|-------------++
///          ++-------------o-------------++-------------o-------------++-------------o-------------++-------------o-------------++
///          ||                           ||                           ||                           ||                           ||
///          ||      +-----------------+  ||      +-----------------+  ||      +-----------------+  ||      +-----------------+  ||
///          ||    +-)---------------+ |  ||    +-)---------------+ |  ||    +-)---------------+ |  ||    +-)---------------+ |  ||
///          ||  +-)-)---------88888 | |  ||  +-)-)---------88888 | |  ||  +-)-)---------88888 | |  ||  +-)-)---------88888 | |  ||
///          ||  | | |     +---8   8-+ |  ||  | | |     +---8   8-+ |  ||  | | |     +---8   8-+ |  ||  | | |     +---8   8-+ |  ||
///          ||  | | |     |   8   8   |  ||  | | |     |   8   8   |  ||  | | |     |   8   8   |  ||  | | |     |   8   8   |  ||
///          ||  | | |     | +-88888   |  ||  | | |     | +-88888   |  ||  | | |     | +-88888   |  ||  | | |     | +-88888   |  ||
///          ||  | | |   +-)-)-8   8---+  ||  | | |   +-)-)-8   8---+  ||  | | |   +-)-)-8   8---+  ||  | | |   +-)-)-8   8---+  ||
///          ||  | | |   | | | 8   8      ||  | | |   | | | 8   8      ||  | | |   | | | 8   8      ||  | | |   | | | 8   8      ||
///          ||  | | | +-)-)-)-88888      ||  | | | +-)-)-)-88888      ||  | | | +-)-)-)-88888      ||  | | | +-)-)-)-88888      ||
///          ||  | | | | | | |            ||  | | | | | | |            ||  | | | | | | |            ||  | | | | | | |            ||
///          ++--|-|-|-|-|-|-|------------++--|-|-|-|-|-|-|------------++--|-|-|-|-|-|-|------------++--|-|-|-|-|-|-|------------++
///          ++--|-|-|-|-|-|-|------------++--|-|-|-|-|-|-|------------++--|-|-|-|-|-|-|------------++--|-|-|-|-|-|-|------------++
///              | | | | | | |                | | | | | | |                | | | | | | |                | | | | | | |              
///              +-)-)-)-)-)-)----------------+-)-)-)-)-)-)----------------+-)-)-)-)-)-)----------------+ | | | | | |              
///              | +-)-)-)-)-)----------------)-+-)-)-)-)-)----------------)-+-)-)-)-)-)----------------)-+ | | | | |
///              | | +-)-)-)-)----------------)-)-+-)-)-)-)----------------)-)-+-)-)-)-)----------------)-)-+ | | | |
///              | | | +-)-)-)----------------)-)-)-+-)-)-)----------------)-)-)-+-)-)-)----------------)-)-)-+ | | |
///              | | | | +-)-)----------------)-)-)-)-+-)-)----------------)-)-)-)-+-)-)----------------)-)-)-)-+ | |
///              | | | | | +-)----------------)-)-)-)-)-+-)----------------)-)-)-)-)-+-)----------------)-)-)-)-)-+ |
///              | | | | | | +----------------)-)-)-)-)-)-+----------------)-)-)-)-)-)-+----------------)-)-)-)-)-)-+
///              | | | | | | |
/// cathodes:    A B C D E F G
///
///  Figure 1. Pinout of the 4-digit 7-segment display.
///
/// Output:
///     anode : reg [3:0] = bit mask to activate the anode, active LOW
/// Input:
///     switch_in: wire [1:0] = 2-bit number representing the digit
///         to display
///
/// See: svn_seg_decoder.sv
///
module anode_decoder(
	output reg [3:0] anode,
	input wire [1:0] switch_in
	);

	// combinational model
	always @* begin
		// translate the digit number to an anode bit mask.
		// The number before the ":" represents a reference number
		// to which to compare switch_in.  After the ":" is the block
		// of statements to perform if (switch_in) equals the
		// reference.  This represents a multiplexer or file.
		// It is best practice to provide a sensible default always.
		// Here the default is to activate anode 0.
		case (switch_in)
			2'b01:   anode = 4'b1101;
			2'b10:   anode = 4'b1011;
			2'b11:   anode = 4'b0111;
			default: anode = 4'b1110;
		endcase // (switch_in)
	end // always @*

endmodule // anode_decoder
