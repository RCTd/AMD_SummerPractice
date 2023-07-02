module SignExtend(in,
                  out);
  input [15:0] in;
  output [31:0] out;
  assign out={{16{in[15]}},in};
endmodule

module ShiftLeft2
  #(parameter NIN=26,parameter NOUT=28)(in,
                  		out);
  
  input [NIN-1:0]in;
  output [NOUT-1:0]out;
  
  assign out=in<<2;
endmodule

module PC(in,
          clk,
          out);
  input [31:0]in;
  input clk;
  output reg [31:0]out=32'h0000;
  always@(posedge clk)
    out=in;  
endmodule

module Mux //Mux #(.NRBITS(5))mux(.in0(ina),...
  #(parameter NRBITS=32)(in0,
                         in1,
                         sel,
                         out);
  input [NRBITS-1:0]in0;
  input [NRBITS-1:0]in1;
  input sel;
  output [NRBITS-1:0]out;
  
  assign out=sel?in1:in0;
  
endmodule

module ADD(opa,
           opb,
           out);
  input[31:0]opa;
  input[31:0]opb;
  output[31:0]out;
  
  assign out=opa+opb;
endmodule

module InstructionMemory(addr,
                         out);
  input[31:0]addr;
  output[31:0]out; 
  reg [7:0]mem[1023:0];
  assign out[31:24]=mem[addr+3];
  assign out[23:16]=mem[addr+2];
  assign out[15:8]=mem[addr+1];
  assign out[7:0]=mem[addr];
  
endmodule

module DataMemory(addr,
                  memWrite,
                  memRead,
                  writeData,
                  clk,
                  out);
  input[31:0]addr;
  input memWrite,memRead;
  input [31:0]writeData;
  input clk;
  output[31:0]out; 
  reg [7:0]mem[1023:0];
  
  always@(posedge clk)//addr)
    if(memWrite==1)
      begin
        mem[addr+3]=writeData[31:24];
        mem[addr+2]=writeData[23:16];
        mem[addr+1]=writeData[15:8];
        mem[addr]  =writeData[7:0];
      end
  
  assign out[31:24]=memRead? mem[addr+3]:8'hxx;
  assign out[23:16]=memRead? mem[addr+2]:8'hxx;
  assign out[15:8] =memRead? mem[addr+1]:8'hxx;
  assign out[7:0]  =memRead? mem[addr]  :8'hxx;  
endmodule

module Registers(readRegister1,
                 readRegister2,
                 writeRegister,
                 writeData,
                 regWrite,
                 clk,
                 readData1,
                 readData2);
  input[31:0]writeData;
  input[4:0]readRegister1,readRegister2,writeRegister;
  input regWrite;
  input clk;
  output [31:0]readData1,readData2;
  reg [31:0]inReg[31:0];
  
  integer i;
  initial for(i=0;i<32;i=i+1)
         inReg[i]={64'h0};
  
  assign readData1=inReg[readRegister1];
  assign readData2=inReg[readRegister2];

  always@(*)
    inReg[0]=0;
  
  always@(posedge clk)
    begin
      if(regWrite==1)
        inReg[writeRegister]=writeData;
    end	
  
endmodule

  
module Control(opcode,
               RegDst,
               Jump,
               Branch,
               MemRead,
               MemtoReg,
               ALUOp,
               MemWrite,
               ALUSrc,
               RegWrite);
  input [5:0]opcode;
  output reg RegDst=0,Jump=0,Branch=0,MemRead=0,MemtoReg=0,MemWrite=0,ALUSrc=0,RegWrite=0;
  output reg [1:0]ALUOp=0;
  always@(opcode)
    case(opcode)
      6'h00://R-Type
      	{RegDst,Jump,Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite,ALUOp}
        ={1'b1 ,1'b0,1'b0  ,1'b0   ,1'b0    ,1'b0    ,1'b0  ,1'b1    ,2'b10};
      6'h8://addi
      	{RegDst,Jump,Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite,ALUOp}
        ={1'b0 ,1'b0,1'b0  ,1'b0   ,1'b0    ,1'b0    ,1'b1  ,1'b1    ,2'b00};
      6'h23://lw
      	{RegDst,Jump,Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite,ALUOp}
        ={1'b0 ,1'b0,1'b0  ,1'b1   ,1'b1    ,1'b0    ,1'b1  ,1'b1    ,2'b00};
      6'h2b://sw
      	{RegDst,Jump,Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite,ALUOp}
        ={1'b0 ,1'b0,1'b0  ,1'b0   ,1'b0    ,1'b1    ,1'b1  ,1'b0    ,2'b00};
      6'h4://beq
      	{RegDst,Jump,Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite,ALUOp}
        ={1'b0 ,1'b0,1'b1  ,1'b0   ,1'b0    ,1'b0    ,1'b0  ,1'b0    ,2'b01};
      6'h2://j
      	{RegDst,Jump,Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite,ALUOp}
        ={1'b0 ,1'b1,1'b0  ,1'b0   ,1'b0    ,1'b0    ,1'b0  ,1'b0    ,2'b00};
    endcase
endmodule

module ALU(opA,
           opB,
           opSel,
           result,
           zero);
  input [31:0]opA,opB;
  input [3-1:0]opSel;
  output reg[31:0]result=32'h00000000;
  output reg zero;
  
  always@(*)
    begin
      casex(opSel)
        3'b010:result=opA+opB;
        3'b110:result=opA-opB;
        3'b000:result=opA&opB;
        3'b001:result=opA|opB;
        3'b111:result=(opA<opB)?32'h1:32'h0;
        default:result=32'bx;

      endcase
      zero=~(|result);
    end
  
  
endmodule

module ALUcontrol(ALUOp,
                  funct,
                  opSel);
  input [1:0]ALUOp;
  input[5:0]funct;
  output reg[3-1:0]opSel;
  
  always@(*)
    casex({ALUOp,funct})
      8'b00_xxxxxx,
      8'b1x_100000,
      8'b1x_100100: opSel=3'b010;
      8'bx1_xxxxxx,
      8'b1x_100010: opSel=3'b110;
      8'b1x_100100: opSel=3'b000;
      8'b1x_100101: opSel=3'b001;
      8'b1x_101010: opSel=3'b111;
    endcase
endmodule
      
      
module MIPS(clk);
  input clk;
  
  PC pc(.in(pcin),
        .clk(clk),
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
                    .funct(instruction[5:0]),
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
  wire[2:0] opSel;
  wire[1:0] ALUOp;
  wire RegDst,Jump,Branch,MemRead,MemtoReg,MemWrite,
	ALUSrc,RegWrite,zero;
  
endmodule
  
  