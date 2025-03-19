module SingleCycleCPU (
    input   wire        clk,
    input   wire        start,
    output  wire [7:0]  segments,
    output  wire [3:0]  an
);

// When input start is zero, cpu should reset
// When input start is high, cpu start running

// TODO: Connect wires to realize SingleCycleCPU and instantiate all modules related to seven-segment displays
// The following provides simple template,

//start with Istruction Memory
wire [31:0] Read_addr;
wire [31:0] Instruction;

//Control part
wire memRead;         // memory read signal
wire [1:0] memtoReg;  // memory to register signal
wire [2:0] ALUOp;     // ALU operation signal
wire memWrite;        // memory write signal
wire PCSel;            // PC select signal (for MUX PC)
wire ALUSrc1;         // ALU source 1 signal (for MUX)
wire ALUSrc2;         // ALU source 2 signal (for MUX)
wire regWrite;        // register write signal
wire [31:0] for_sevenSegDis;
//Adder_1 // Result from Adder
wire [31:0] Result_adder1;

PC m_PC(
    .clk(clk),
    .rst(start),
    .pc_i(Result_mumpc),
    .pc_o(Read_addr)
);

Adder m_Adder_1(
    .a(Read_addr),
    .b(32'd4),
    .sum(Result_adder1)
);

InstructionMemory m_InstMem(
    .readAddr(Read_addr),
    .inst(Instruction)
);
//tmp
Control m_Control(
    .opcode(Instruction[6:0]),
    .memRead(memRead),
    .memtoReg(memtoReg),
    .ALUOp(ALUOp),
    .memWrite(memWrite),
    .ALUSrc1(ALUSrc1),
    .ALUSrc2(ALUSrc2),
    .regWrite(regWrite),
    .PCSel(PCSel)
);

// ------------------------------------------
// For Student:
// Do not change the modules' instance names and I/O port names!!
// Or you will fail validation.
// By the way, you still have to wire up these modules

wire [31:0] rd1;
wire [31:0] rd2;

Register m_Register(
    .clk(clk),
    .rst(start),
    .regWrite(regWrite),
    .readReg1(Instruction[19:15]),
    .readReg2(Instruction[24:20]),
    .writeReg(Instruction[11:7]),
    .writeData(Result_mumwrite),
    .readData1(rd1),
    .readData2(rd2),
    .reg5Data(for_sevenSegDis) //for seven-segments
);
SevenSegmentDisplay sevenSegDis(
    .DataIn(for_sevenSegDis[15:0]), //4(32)
    .Clk(clk),
    .Reset(!start) //reset when == 0
);
//for readdata_from mem
wire [31:0] Read_frommem;
DataMemory m_DataMemory(
    .rst(start),
    .clk(clk),
    .memWrite(memWrite),
    .memRead(memRead),
    .address(Result_frombrother),
    .writeData(rd2),
    .readData(Read_frommem)
);

// ------------------------------------------

//imm
wire [31:0] imm_val;
ImmGen m_ImmGen(
    .inst(Instruction),
    .imm(imm_val)
);

//Result from Mumpc
wire [31:0] Result_mumpc;

Mux2to1 #(.size(32)) m_Mux_PC(
    .sel(PCSel),
    .s0(Result_adder1),
    .s1(Result_frombrother),
    .out(Result_mumpc)
);

//result alu1
wire [31:0] Result_alu1;
Mux2to1 #(.size(32)) m_Mux_ALU_1(
    .sel(ALUSrc1),
    .s0(rd1),
    .s1(Read_addr),
    .out(Result_alu1)
);

wire [31:0] Result_alu2;
Mux2to1 #(.size(32)) m_Mux_ALU_2(
    .sel(ALUSrc2),
    .s0(rd2),
    .s1(imm_val),
    .out(Result_alu2)
);

wire [3:0] result_aluctrl;
ALUCtrl m_ALUCtrl(
    .ALUOp(ALUOp),
    .funct7(Instruction[30]),
    .funct3(Instruction[14:12]),
    .ALUCtl(result_aluctrl)
);

//alu after 2 alu
wire [31:0] Result_frombrother;
ALU m_ALU(
    .ALUctl(result_aluctrl),
    .brLt(brLt),
    .brEq(brEq),
    .A(Result_alu1),
    .B(Result_alu2),
    .ALUOut(Result_frombrother)
);

//shack mux
wire [31:0] Result_mumwrite;

Mux3to1 #(.size(32)) m_Mux_WriteData(
    .sel(memtoReg),
    .s0(Result_frombrother),
    .s1(Read_frommem),
    .s2(Result_adder1),
    .out(Result_mumwrite)
);

wire brLt;
wire brEq;

BranchComp m_BranchComp(
    .rs1(rd1),
    .rs2(rd2),
    .brLt(brLt),
    .brEq(brEq)
);

endmodule
