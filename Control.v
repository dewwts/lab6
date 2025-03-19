module Control (
    input [6:0] opcode,         // opcode field of instruction
    output reg memRead,         // memory read signal
    output reg [1:0] memtoReg,  // memory to register signal
    output reg [2:0] ALUOp,     // ALU operation signal
    output reg memWrite,        // memory write signal
    output reg ALUSrc1,         // ALU source 1 signal (for MUX)
    output reg ALUSrc2,         // ALU source 2 signal (for MUX)
    output reg regWrite,        // register write signal
    output reg PCSel            // PC select signal (for MUX PC)
);

    // TODO: implement your Control here
    // Hint: follow the Architecture (figure in spec) to set output signal
    always @(*) begin
        //add it also have sub in maybe have to consider func7
        //also have and but and func 3 = 111
        //ADD 000/ SUB 000/ AND 111/ OR 110 / SLT 010
        if (opcode == 7'b0110011) begin
            memRead = 0;
            memtoReg = 2'b00;
            //ALUOP modify later
            ALUOp = 3'b000;
            memWrite = 0;
            ALUSrc1 = 0;
            ALUSrc2 = 0;
            regWrite = 1;
            PCSel = 0;
        //ADDI 000// ANDI 111/ ORI 110 / SLTI 010
        end else if (opcode == 7'b0010011) begin
            memRead = 0;
            memtoReg = 2'b00;
            //ALUOP modify later
            ALUOp = 3'b001;
            memWrite = 0;
            ALUSrc1 = 0;
            ALUSrc2 = 1;
            regWrite = 1;
            PCSel = 0;
        //LW 010
        end else if (opcode == 7'b0000011) begin
            memRead = 1;
            memtoReg = 2'b01;
            //ALUOP modify later
            ALUOp = 3'b010;
            memWrite = 0;
            ALUSrc1 = 0;
            ALUSrc2 = 1;
            regWrite = 1;
            PCSel = 0;
        //store 010
        end else if (opcode == 7'b0100011) begin
            memRead = 0;
            //dontcare memtoreg
            //ALUOP modify later
            ALUOp = 3'b011;
            memWrite = 1;
            ALUSrc1 = 0;
            ALUSrc2 = 1;
            regWrite = 0;
            PCSel = 0;
        //beq 000//bne 001//blt 100// bge 101
        end else if (opcode == 7'b1100011) begin
            memRead = 0;
            //dc mtr
            memWrite = 0;
            ALUOp = 3'b100;
            ALUSrc1 = 1;
            ALUSrc2 = 1;
            regWrite = 0;
            PCSel = 1;
        //jal
        end else if (opcode == 7'b1101111) begin
            memRead = 0;
            memtoReg = 2'b10;
            //ALUOP LATER
            ALUOp = 3'b101;
            memWrite = 0;
            ALUSrc1 = 1;
            ALUSrc2 = 1;
            regWrite = 1;
            PCSel = 1;
        //jalr 000
        end else if (opcode == 7'b1100111) begin
            memRead = 0;
            memtoReg = 2'b10;
            //ALUOP LATER
            ALUOp = 3'b110;
            memWrite = 0;
            ALUSrc1 = 0;
            ALUSrc2 = 1;
            regWrite = 1;
            PCSel = 1;
        end
    end

endmodule