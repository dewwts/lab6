module ImmGen (
    input  [31:0] inst,                  // Instruction 32 บิต
    output reg signed [31:0] imm         // Immediate แบบ sign-extended
);
    wire [6:0] opcode = inst[6:0];

    always @(*) begin
        case (opcode)
            // I-type opcodes: (e.g. addi=0010011, lw=0000011, jalr=1100111, etc.)
            7'b0010011, // addi, andi, ori, xori, slli, srli, srai, ...
            7'b0000011, // lw, lb, lh
            7'b1100111: // jalr
            begin
                // I-type: imm = sign-extend of inst[31:20]
                imm = {{20{inst[31]}}, inst[31:20]};
            end

            // S-type opcodes: (e.g. sw=0100011)
            7'b0100011: begin
                // S-type: imm = sign-extend of {inst[31:25], inst[11:7]}
                imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
            end

            // B-type opcodes: (e.g. beq, bne, blt, bge => 1100011)
            7'b1100011: begin
                // B-type: imm = sign-extend of { inst[31], inst[7], inst[30:25], inst[11:8], 1'b0 }
                // ระวังลำดับบิตตามสเปค
                imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
            end

            // U-type opcodes: (lui=0110111, auipc=0010111)
            7'b0110111, // LUI
            7'b0010111: // AUIPC
            begin
                // U-type: imm = {inst[31:12], 12'b0}
                imm = {inst[31:12], 12'b0};
            end

            // J-type opcodes: (jal=1101111)
            7'b1101111: begin
                // J-type: imm = sign-extend of { inst[31], inst[19:12], inst[20], inst[30:21], 1'b0 }
                imm = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
            end

            // R-type หรือค่าที่ไม่ระบุ => imm = 0
            // (เพราะ R-type ไม่ได้ใช้ immediate)
            default: begin
                imm = 32'b0;
            end
        endcase
    end
endmodule

