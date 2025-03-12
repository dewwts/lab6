module ALUCtrl (
    input [2:0] ALUOp,          // ALU operation
    input funct7,               // funct7 field of instruction (only 30th bit of instruction)
    input [2:0] funct3,         // funct3 field of instruction
    output reg [3:0] ALUCtl     // ALU control signal
);

    // TODO: implement your ALU control here
    // For testbench verifying, Do not modify input and output pin
    // For funct7, we care only 30th bit of instruction. Why?
    // See all R-type instructions in the lab and observe.

    // Hint: using ALUOp, funct7, funct3 to select exact operation
    always @(*) begin

        case(ALUOp)
            3'b000 : begin
                ALUCtl = 4'b0010; //add address calculation
            end
            
            //branch if equal
            3'b001 : begin
                case(funct3)
                    3'b000, // beq use sub
                    3'b001: ALUCtl = 4'b0110; // bne use sub
                    3'b100, //blt use SRT
                    3'b101 : ALUCtl = 4'b0111; // bge use SET
                    default: ALUCtl = 4'b0000; //default case
                endcase
            end

            3'b010 : begin
                case({funct7, funct3})
                    4'b0_000: ALUCtl = 4'b0010; // ADD //2
                    4'b1_000: ALUCtl = 4'b0110; // SUB //3
                    4'b0_111: ALUCtl = 4'b0000; // AND
                    4'b0_110: ALUCtl = 4'b0001; // OR
                    4'b0_100: ALUCtl = 4'b1000; // XOR
                    default:  ALUCtl = 4'b0000; // Default case
                endcase
            end
        

        3'b011: begin // I-type
            case (funct3)
                3'b000: ALUCtl = 4'b0010;         // ADDI
                3'b111: ALUCtl = 4'b0000;         // ANDI
                3'b110: ALUCtl = 4'b0001;         // ORI
                3'b100: ALUCtl = 4'b1000;         // XORI
                3'b001: ALUCtl = 4'b1001;         // SLLI
                3'b101: ALUCtl = funct7 ? 4'b1011 : 4'b1010; // SRLI
                3'b010: ALUCtl = 4'b0111;         // SLTI
                3'b100: ALUCtl = 4'b0011;           // J
                3'b101: ALUCtl = 4'b0100;           // JLL
                default: ALUCtl = 4'b0000; // Default case
            endcase
        end  
        default: default: ALUCtl = 4'b0000;

        endcase

    end
endmodule

