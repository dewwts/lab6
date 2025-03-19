module ALU (
    input [3:0] ALUctl,                     // ใช้เลือกการดำเนินการของ ALU
    input brLt,                             // Branch Less Than (สำหรับคำสั่ง branch)
    input brEq,                             // Branch Equal (สำหรับคำสั่ง branch)
    input signed [31:0] A, B,               // ตัวดำเนินการ
    output reg signed [31:0] ALUOut         // ผลลัพธ์ของ ALU
);

    always @(*) begin
        case (ALUctl)
            4'b0101: begin  // Branch on Equal
                if (brEq) 
                    ALUOut = A + B;
                else 
                    ALUOut = A + 32'd4;
            end

            4'b0110: begin  // Branch on Not Equal
                if (!brEq) 
                    ALUOut = A + B;
                else 
                    ALUOut = A + 32'd4;
            end

            4'b0111: begin  // Branch on Less Than
                if (brLt) 
                    ALUOut = A + B;
                else 
                    ALUOut = A + 32'd4;
            end

            4'b1000: begin  // Branch on Greater or Equal
                if (!brLt) 
                    ALUOut = A + B;
                else 
                    ALUOut = A + 32'd4;
            end

            4'b0000: ALUOut = A + B;       // Addition
            4'b0001: ALUOut = A - B;       // Subtraction
            4'b0010: ALUOut = A & B;       // AND
            4'b0011: ALUOut = A | B;       // OR
            4'b1001: ALUOut = (A + B) & (~1); // Addition with alignment
            4'b0100: ALUOut = (A < B) ? 32'd1 : 32'd0; // Set Less Than

            default: ALUOut = 32'd0;       // ค่าเริ่มต้นกรณี ALUctl ไม่มีในรายการ
        endcase
    end

endmodule


