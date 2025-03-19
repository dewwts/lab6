`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/11/2025 03:47:20 PM
// Design Name: 
// Module Name: SevenSegmentDecodar
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module SevenSegmentDecodar(
    input  wire [3:0] DataIn, //input  wire [3:0] DataIn,
    output wire [7:0] Segments
);
  reg [7:0] segments = 8'b11111111;
  assign Segments = segments;
  always @(*) begin
    case (DataIn)
      4'b0000: segments = 8'b00000011;
      4'b0001: segments = 8'b10011111;
      4'b0010: segments = 8'b00100101;
      4'b0011: segments = 8'b00001101;
      4'b0100: segments = 8'b10011001;
      4'b0101: segments = 8'b01001001;
      4'b0110: segments = 8'b01000001;
      4'b0111: segments = 8'b00011111;
      4'b1000: segments = 8'b00000001;
      4'b1001: segments = 8'b00001001;
      4'b1010: segments = 8'b00010001;
      4'b1011: segments = 8'b11000001;
      4'b1100: segments = 8'b01100011;
      4'b1101: segments = 8'b10000101;
      4'b1110: segments = 8'b01100001;
      4'b1111: segments = 8'b01110001;
      default: segments = 8'b11111111;
    endcase
  end
endmodule