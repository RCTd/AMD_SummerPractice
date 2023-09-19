`include "extra.sv"
`include "pc.sv"
`include "InstructionMemory.sv"
`include "DataMemory.sv"
`include "Registers.sv"
`include "Control.sv"
`include "ALU.sv"
`include "ALUcontrol.sv"    
      
module MIPS(clk,start);
  input clk;
  input start;
  
  PC pc(.in(pcin),
        .clk(clk),
        .start(start),
        .out(pcout));
  InstructionMemory im(.addr(pcout),
                       .out(instruction));
  Registers rg(.readRegister1(instruction[25:21]),
               .readRegister2(instruction[20:16]),
               .writeRegister(muxInstOut),
               .writeData(muxDataOut),
               .regWrite(RegWrite),
               .clk(clk),
               .readData1(readData1),
               .readData2(readData2));
  ALU alu(.opA(readData1),
          .opB(muxALUOut),
          .opSel(opSel),
          .result(aluresult),
          .zero(zero));
  DataMemory dm(.addr(aluresult),
                .memWrite(MemWrite),
                .memRead(MemRead),
                .writeData(readData2),
                .clk(clk),
                .out(mdout));
  Control cnt(.opcode(instruction[31:26]),
              .RegDst(RegDst),
              .Jump(Jump),
              .Branch(Branch),
              .MemRead(MemRead),
              .MemtoReg(MemtoReg),
              .ALUOp(ALUOp),
              .MemWrite(MemWrite),
              .ALUSrc(ALUSrc),
              .RegWrite(RegWrite));
  ALUcontrol alucnt(.ALUOp(ALUOp),
                    .funct(instruction[`FNCTNB-1:0]),
                    .opSel(opSel));
  ADD add4(.opa(pcout),
           .opb(32'h4),
           .out(add4out));
  ADD addb(.opa(add4out),
           .opb(sh2bout),
           .out(addbout));
  ShiftLeft2 #(.NIN(32),.NOUT(32))sh2b(.in(sgnexout),
                                       .out(sh2bout));
  SignExtend sgnex(.in(instruction[15:0]),
                   .out(sgnexout));
  ShiftLeft2 #(.NIN(26),.NOUT(28))sh2j(.in(instruction[25:0]),
                                       .out(sh2jout));
  Mux #(.NRBITS(5))muxreg(.in0(instruction[20:16]),
                          .in1(instruction[15:11]),
                          .sel(RegDst),
                          .out(muxInstOut));
  Mux #(.NRBITS(32))muxALU(.in0(readData2),
                           .in1(sgnexout),
                           .sel(ALUSrc),
                           .out(muxALUOut));
  Mux #(.NRBITS(32))muxData(.in0(aluresult),
                            .in1(mdout),
                            .sel(MemtoReg),
                            .out(muxDataOut));
  Mux #(.NRBITS(32))muxb(.in0(add4out),
                           .in1(addbout),
                           .sel(Branch&zero),
                         .out(muxbout));
  Mux #(.NRBITS(32))muxalu(.in0(muxbout),
                           .in1({add4out[31:28],sh2jout}),
                           .sel(Jump),
                           .out(pcin));
  
  wire [31:0]pcin,pcout,instruction,readData1,readData2,
  muxALUOut,aluresult,mdout,muxDataOut,sgnexout,sh2bout,
  addbout,muxbout,add4out;
  wire[27:0] sh2jout;
  wire[4:0]muxInstOut;
  wire[`OPSELNRBITI-1:0] opSel;
  wire[1:0] ALUOp;
  wire RegDst,Jump,Branch,MemRead,MemtoReg,MemWrite,
	ALUSrc,RegWrite,zero;
  
endmodule
  

