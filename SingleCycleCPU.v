module SingleCycleCPU (
    input  wire        clk,
    input  wire        start,        // start=0 => reset, start=1 => run
    output wire [7:0]  segments,
    output wire [3:0]  an
);

//----------------------------------------------
// 1) ประกาศสายสัญญาณ (wires) ที่ต้องใช้เชื่อมระหว่างโมดูล
//----------------------------------------------

// Program Counter
wire [31:0] pc_i;
wire [31:0] pc_o;       // Current PC

// Instruction
wire [31:0] instruction;

// จาก Control
wire memRead, memWrite, regWrite, PCSel;
wire [1:0] memtoReg;
wire [2:0] ALUOp;
wire ALUSrc1, ALUSrc2;

// จาก Register
wire [31:0] readData1, readData2;
wire [31:0] reg5Data;  // ค่าจาก x5 (ใช้แสดงบน 7-seg)

// Immediate
wire [31:0] immValue;

// ALU Control
wire [3:0] ALUCtl;

// ALU
wire [31:0] aluOut;
wire brLt, brEq;

// Data Memory
wire [31:0] memReadData;

// MUX outputs
wire [31:0] muxPCout;        // จาก Mux2to1 (pc source)
wire [31:0] muxALU1out;      // จาก Mux2to1 (ALU source1)
wire [31:0] muxALU2out;      // จาก Mux2to1 (ALU source2)
wire [31:0] muxWriteDataOut; // จาก Mux3to1 (writeData)

// Adder สำหรับ PC+4
wire [31:0] pc_plus4;

//----------------------------------------------
// 2) ต่อโมดูลต่าง ๆ เข้าด้วยกัน
//----------------------------------------------

// (A) Program Counter
PC m_PC (
    .clk(clk),
    .rst(~start),     // start=0 => rst=1 => reset active
    .pc_i(pc_i),
    .pc_o(pc_o)
);

// (B) Adder for PC + 4
Adder m_Adder_1 (
    .a(pc_o),
    .b(32'd4),
    .sum(pc_plus4)
);

// (C) Instruction Memory
InstructionMemory m_InstMem (
    .readAddr(pc_o),
    .inst(instruction)
);

// (D) Control
Control m_Control (
    .opcode(instruction[6:0]),
    .memRead(memRead),
    .memtoReg(memtoReg),
    .ALUOp(ALUOp),
    .memWrite(memWrite),
    .ALUSrc1(ALUSrc1),
    .ALUSrc2(ALUSrc2),
    .regWrite(regWrite),
    .PCSel(PCSel)
);

// (E) Register File
Register m_Register (
    .clk(clk),
    .rst(~start),          // reset เมื่อ start=0
    .regWrite(regWrite),
    .readReg1(instruction[19:15]),  // rs1
    .readReg2(instruction[24:20]),  // rs2
    .writeReg(instruction[11:7]),   // rd
    .writeData(muxWriteDataOut),    // มาจาก Mux3to1
    .readData1(readData1),
    .readData2(readData2),
    .reg5Data(reg5Data)     // ค่าใน x5
);

// (F) Data Memory
DataMemory m_DataMemory (
    .rst(~start),
    .clk(clk),
    .memWrite(memWrite),
    .memRead(memRead),
    .address(aluOut),
    .writeData(readData2),
    .readData(memReadData)
);

// (G) ImmGen
ImmGen m_ImmGen (
    .inst(instruction),
    .imm(immValue)
);

// (H) Mux2to1 สำหรับ PC (PCSel: 0 => pc+4, 1 => branch target)
Mux2to1 #(.size(32)) m_Mux_PC (
    .sel(PCSel),
    .s0(pc_plus4),       // ถ้าไม่ branch => ไป pc+4
    .s1( aluOut ),       // ถ้า branch/jump => ไป aluOut (เช่น pc+imm หรือ jalr)
    .out(muxPCout)
);

// (I) Mux2to1 สำหรับ ALU source1 (ถ้า ALUSrc1=0 => readData1, ถ้า=1 => PC)
Mux2to1 #(.size(32)) m_Mux_ALU_1 (
    .sel(ALUSrc1),
    .s0(readData1),
    .s1(pc_o),           // สำหรับ jal ที่เอา PC มา + offset
    .out(muxALU1out)
);

// (J) Mux2to1 สำหรับ ALU source2 (ถ้า ALUSrc2=0 => readData2, ถ้า=1 => immValue)
Mux2to1 #(.size(32)) m_Mux_ALU_2 (
    .sel(ALUSrc2),
    .s0(readData2),
    .s1(immValue),
    .out(muxALU2out)
);

// (K) ALUCtrl
ALUCtrl m_ALUCtrl (
    .ALUOp(ALUOp),
    .funct7(instruction[30]),  // บิต 30 ของ R-type
    .funct3(instruction[14:12]),
    .ALUCtl(ALUCtl)
);

// (L) Branch Comparator
BranchComp m_BranchComp (
    .rs1(readData1),
    .rs2(readData2),
    .brLt(brLt),
    .brEq(brEq)
);

// (M) ALU
ALU m_ALU (
    .ALUctl(ALUCtl),
    .brLt(brLt),
    .brEq(brEq),
    .A(muxALU1out),
    .B(muxALU2out),
    .ALUOut(aluOut)
);

// (N) Mux3to1 สำหรับ writeData (กรณี memtoReg=0 => aluOut, 1 => memReadData, 2 => PC+4)
Mux3to1 #(.size(32)) m_Mux_WriteData (
    .sel(memtoReg),
    .s0(aluOut),        // ALU result
    .s1(memReadData),   // Load data
    .s2(pc_plus4),      // PC+4 (กรณี JAL/JALR)
    .out(muxWriteDataOut)
);

//----------------------------------------------
// เชื่อม pc_i กับ muxPCout (สุดท้าย PC จะเลือกไปตัวไหน)
assign pc_i = muxPCout;

//----------------------------------------------
// 3) Seven-Segment Display
//----------------------------------------------
//   - ต้องการแสดง reg5Data[15:0] เป็น 4 หลัก Hex บน 7-seg
//   - ตัวอย่างโมดูล SevenSeg (หรือตามชื่อที่คุณมี)
//   - รับสัญญาณ clk กับ rst (หรือ ~start) ตามดีไซน์
//   - 'hexValue' หรือ 'value' = reg5Data[15:0]

wire [15:0] x5_lower16 = reg5Data[15:0];

SevenSegDisplay m_SevenSeg (
    .clk(clk),
    .rst(~start),
    .value(x5_lower16),  // ส่งค่า 16 บิตล่าง
    .segments(segments),
    .an(an)
);

endmodule

