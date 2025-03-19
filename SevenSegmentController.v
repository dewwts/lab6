`timescale 1ns / 1ps
module SevenSegmentController #(
    parameter ControllerClockCycle   = 100000, // Adjust for desired refresh rate
    parameter ControllerCounterWidth = 16      // Minimum width to count to ControllerClockCycle
) (
    input  wire       Reset,
    input  wire       Clk,
    output reg  [3:0] AN,      // Active low digit enable
    output reg  [1:0] Selector // Selector for segment data
);
    reg [ControllerCounterWidth-1:0] RefreshCounter; // Counter for refresh timing
    reg [1:0] DigitCounter; // Counter for digit selection

    // Remove initial block - we'll handle initialization in the sequential logic
    
    // Refresh Counter Logic
    always @(posedge Clk or posedge Reset) begin
        if (Reset) begin //reset
            RefreshCounter <= 0;
            DigitCounter <= 0;
            AN <= 4'b1111;     // All digits off on reset
            Selector <= 2'b00; // Reset selector
        end else begin //not reset, keep going
            if (RefreshCounter == ControllerClockCycle - 1) begin //it's time to refresh
                RefreshCounter <= 0;
                // Update digit counter only when refresh counter resets
                DigitCounter <= (DigitCounter == 2'b11) ? 2'b00 : DigitCounter + 1;
            end else begin
                RefreshCounter <= RefreshCounter + 1;
            end
            
            // Update outputs based on DigitCounter
            case (DigitCounter)
                2'b00: begin AN <= 4'b1110; Selector <= 2'b00; end
                2'b01: begin AN <= 4'b1101; Selector <= 2'b01; end
                2'b10: begin AN <= 4'b1011; Selector <= 2'b10; end
                2'b11: begin AN <= 4'b0111; Selector <= 2'b11; end
                default: begin AN <= 4'b1111; Selector <= 2'b00; end
            endcase
        end
    end

endmodule