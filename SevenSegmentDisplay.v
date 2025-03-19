`timescale 1ns / 1ps
module SevenSegmentDisplay #(
    parameter ControllerClockCycle   = 1,
    parameter ControllerCounterWidth = 1
) (
    input wire [15:0] DataIn,
    input wire Clk,
    input wire Reset,
    output wire [7:0] Segments,
    output wire [3:0] AN
);
    // Internal signals
    wire [1:0] Selector;       // Determines which digit to display
    wire [3:0] Digit;           // Current digit to display

    // Instantiate SevenSegmentController
    SevenSegmentController #(
        .ControllerClockCycle(ControllerClockCycle),
        .ControllerCounterWidth(ControllerCounterWidth)
    ) Controller (
        .Reset(Reset),
        .Clk(Clk),
        .AN(AN),
        .Selector(Selector)
    );

    // Select the appropriate digit based on the Selector signal
    Multiplexer Mux (
        .DataIn(DataIn),
        .Selector(Selector),
        .DataOut(Digit)
    );

    // BCD to Seven Segment Decoder
    SevenSegmentDecodar Decoder (
        .DataIn(Digit),
        .Segments(Segments)
    );
endmodule