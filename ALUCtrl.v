module ALUCtrl (
    input [2:0] ALUOp,          // ALU operation
    input funct7,               // Bitที่ 30 ของคำสั่ง (funct7)
    input [2:0] funct3,         // funct3 field ของคำสั่ง
    output reg [3:0] ALUCtl     // สัญญาณควบคุม ALU
);

    always @(*) begin
        case (ALUOp)
            3'b000: begin // R-type และ I-type instructions
                case (funct3)
                    3'b000: ALUCtl = funct7 ? 4'b0001 : 4'b0000; // SUB ถ้า funct7 เป็น 1, ไม่งั้นเป็น ADD
                    3'b111: ALUCtl = 4'b0010; // AND
                    3'b110: ALUCtl = 4'b0011; // OR
                    3'b010: ALUCtl = 4'b0100; // SLT (Set Less Than)
                    default: ALUCtl = 4'bxxxx; // ไม่ได้กำหนดค่า
                endcase
            end

            3'b001: begin // I-type immediate
                case (funct3)
                    3'b000: ALUCtl = 4'b0000; // ADD
                    3'b111: ALUCtl = 4'b0010; // AND
                    3'b110: ALUCtl = 4'b0011; // OR
                    3'b010: ALUCtl = 4'b0100; // SLT
                    default: ALUCtl = 4'bxxxx; // ไม่ได้กำหนดค่า
                endcase
            end

            3'b010, 3'b011: ALUCtl = 4'b0000; // Load (lw) และ Store (sw) ใช้ ADD

            3'b100: begin // Branch instructions (beq, bne, blt, bge)
                case (funct3)
                    3'b000: ALUCtl = 4'b0101; // BEQ
                    3'b001: ALUCtl = 4'b0110; // BNE
                    3'b100: ALUCtl = 4'b0111; // BLT
                    3'b101: ALUCtl = 4'b1000; // BGE
                    default: ALUCtl = 4'bxxxx; // ไม่ได้กำหนดค่า
                endcase
            end

            3'b101: ALUCtl = 4'b0000; // JALR ใช้ ADD

            3'b110: ALUCtl = 4'b1001; // กรณีพิเศษ

            default: ALUCtl = 4'bxxxx; // ไม่ได้กำหนดค่า
        endcase
    end
    
endmodule
