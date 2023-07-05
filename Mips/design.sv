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
  reg [7:0]mem[0:1023];
  
  initial 
    begin//iterative fibonacci 
      {mem[3],mem[2],mem[1],mem[0]}=32'b00100000000100000000000000000110; //0x20100006 	addi $s0, $zero, 6
      {mem[7],mem[6],mem[5],mem[4]}=32'b00100000000100010000000000001000; //0x20110008 	addi $s1, $zero, 8
      {mem[11],mem[10],mem[9],mem[8]}=32'b10101100000100000000000000000000; //0xac100000 	sw $s0,0($zero)
      {mem[15],mem[14],mem[13],mem[12]}=32'b10001100000010000000000000000000; //0x8c080000 	lw $t0,0($zero)
      {mem[19],mem[18],mem[17],mem[16]}=32'b10101100000100010000000000000000; //0xac110000 	sw $s1,0($zero)
      {mem[23],mem[22],mem[21],mem[20]}=32'b10101100000100010000000000000100; //0xac110004 	sw $s1,4($zero)
      {mem[27],mem[26],mem[25],mem[24]}=32'b10001100000010100000000000000100; //0x8c0a0004 	lw $t2,4($zero)
      {mem[31],mem[30],mem[29],mem[28]}=32'b00000000000000001000000000100000; //0x8020 	add $s0,$zero,$zero
      {mem[35],mem[34],mem[33],mem[32]}=32'b00100010000100010000000000000001; //0x22110001 	addi $s1,$s0,1
      {mem[39],mem[38],mem[37],mem[36]}=32'b00000010001000000100100000100000; //0x2204820 	add $t1,$s1,$zero
      {mem[43],mem[42],mem[41],mem[40]}=32'b00010001000010010000000000000111; //0x11090007 	beq $t0,$t1,DONE
      {mem[47],mem[46],mem[45],mem[44]}=32'b00000010000000001001000000100000; //0x2009020 	add $s2,$s0,$zero
      {mem[51],mem[50],mem[49],mem[48]}=32'b00000010001000001000000000100000; //0x2208020 	add $s0,$s1,$zero
      {mem[55],mem[54],mem[53],mem[52]}=32'b00000010000100101000100000100000; //0x2128820 	add $s1,$s0,$s2
      {mem[59],mem[58],mem[57],mem[56]}=32'b10101101010100010000000000000000; //0xad510000 	sw $s1,($t2)
      {mem[63],mem[62],mem[61],mem[60]}=32'b00100001010010100000000000000100; //0x214a0004 	addi $t2,$t2,4
      {mem[67],mem[66],mem[65],mem[64]}=32'b00100001001010010000000000000001; //0x21290001 	addi $t1,$t1,1
      {mem[71],mem[70],mem[69],mem[68]}=32'b00001000000000000000000000001010; //0x800000a 	j START
      {mem[75],mem[74],mem[73],mem[72]}=32'b00100000000100010000000000000010; //0x20110002 	addi $s1,$zero,2
      {mem[79],mem[78],mem[77],mem[76]}=32'b00000010001100011000100000000100; //0x2318804 	sllv $s1,$s1,$s1
      {mem[83],mem[82],mem[81],mem[80]}=32'b00100000000100100000000000101011; //0x2012002b 	addi $s2,$zero,43
      {mem[87],mem[86],mem[85],mem[84]}=32'b00000010010100011001000000100110; //0x2519026 	xor $s2,$s2,$s1
      {mem[91],mem[90],mem[89],mem[88]}=32'b00000010001100101001000000100111; //0x2329027 	nor $s2,$s1,$s2
      {mem[95],mem[94],mem[93],mem[92]}=32'b00000010010100011001000000100101; //0x2519025 	or $s2,$s2,$s1
      {mem[99],mem[98],mem[97],mem[96]}=32'b00000010001000001000100010000000; //0x2208880 	sll $s1,$s1,2
      {mem[103],mem[102],mem[101],mem[100]}=32'b00000010010000001001000100000011; //0x2409103 	sra $s2,$s2,4
      {mem[107],mem[106],mem[105],mem[104]}=32'b00000010010000001001000011000010; //0x24090c2 	srl $s2,$s2,3
      {mem[111],mem[110],mem[109],mem[108]}=32'b00100000000100010000000000000010; //0x20110002 	addi $s1,$zero,2
      {mem[115],mem[114],mem[113],mem[112]}=32'b00000010010100011001000000000111; //0x2519007 	srav $s2,$s2,$s1
      {mem[119],mem[118],mem[117],mem[116]}=32'b00000010010100011001000000000110; //0x2519006 	srlv $s2,$s2,$s1
      {mem[123],mem[122],mem[121],mem[120]}=32'b00001000000000000000000000011110; //0x800001e 	j FINISH
    end
  
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
  reg [7:0]mem[0:1023];
  
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
      6'h4://andi
      	{RegDst,Jump,Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite,ALUOp}
        ={1'b0 ,1'b0,1'b1  ,1'b0   ,1'b0    ,1'b0    ,1'b0  ,1'b0    ,2'b01};
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

`define SHMATNRBITI 5
`define OPSELNB 4
`define OPSELNRBITI `OPSELNB+`SHMATNRBITI
module ALU(opA,
           opB,
           opSel,
           result,
           zero);
  input [31:0]opA,opB;
  input [`OPSELNRBITI-1:0]opSel;
  output reg[31:0]result=0;
  output reg zero;
  
  always@(*)
    begin
      casex(opSel)
        {`SHMATNRBITI'b0,`OPSELNB'b0000}:result=opA&opB;				//AND
        {`SHMATNRBITI'b0,`OPSELNB'b0001}:result=opA|opB;				//OR
        {`SHMATNRBITI'b0,`OPSELNB'b0010}:result=opA+opB;				//ADD
        {`SHMATNRBITI'b0,`OPSELNB'b0110}:result=opA-opB;				//SUB
        {`SHMATNRBITI'b0,`OPSELNB'b0111}:result=(opA<opB)?32'h1:32'h0;//SLT
        
        //valori ce nu se regasesc in vreo documentatie
        {`SHMATNRBITI'b0,`OPSELNB'b0011}:result=opA^opB;				//XOR
        {`SHMATNRBITI'b0,`OPSELNB'b0100}:result=~(opA|opB);			//NOR
        {`SHMATNRBITI'b0,`OPSELNB'b0101}:								//DIV       
          begin 
            result[31:16]=opA%opB;
            result[15:0]=opA/opB;
          end
        {`SHMATNRBITI'b0,`OPSELNB'b1000}:result=opA<<opB[4:0];		//SLLV
        {`SHMATNRBITI'b0,`OPSELNB'b1001}:result=opA>>opB[4:0];		//SRLV
        {`SHMATNRBITI'b0,`OPSELNB'b1010}:result=opA>>>opB[4:0];		//SRAV
        {`SHMATNRBITI'bx,`OPSELNB'b1011}:result=opA<<opSel[`OPSELNRBITI-1:`SHMATNRBITI-1];
        {`SHMATNRBITI'bx,`OPSELNB'b1100}:result=opA>>opSel[`OPSELNRBITI-1:`SHMATNRBITI-1];		//SRL
        {`SHMATNRBITI'bx,`OPSELNB'b1101}:result=opA>>>opSel[`OPSELNRBITI-1:`SHMATNRBITI-1];		//SRA
        default:result=32'bx;

      endcase
      zero=~(|result);
    end
  
  
endmodule
`define FNCNB 6
`define FNCTNB `FNCNB+`SHMATNRBITI
module ALUcontrol(ALUOp,
                  funct,
                  opSel);
  input [1:0]ALUOp;
  input[`FNCTNB-1:0]funct;
  output reg[`OPSELNRBITI-1:0]opSel;
  
  always@(*)
    casex({ALUOp,funct[`FNCNB-1:0]})
      {2'b00,`FNCNB'bxxxxxx},//+
      {2'b1x,`FNCNB'b100000}://add
      		 opSel={`SHMATNRBITI'b0,`OPSELNB'b0010};
      {2'bx1,`FNCNB'bxxxxxx},//-
      {2'b1x,`FNCNB'b100010}://sub
      		 opSel={`SHMATNRBITI'b0,`OPSELNB'b0110};
      {2'b1x,`FNCNB'b100100}: opSel={`SHMATNRBITI'b0,`OPSELNB'b0000};//and
      {2'b1x,`FNCNB'b100101}: opSel={`SHMATNRBITI'b0,`OPSELNB'b0001};//or
      {2'b1x,`FNCNB'b101010}: opSel={`SHMATNRBITI'b0,`OPSELNB'b0111};//slt
      {2'b1x,`FNCNB'b011010}: opSel={`SHMATNRBITI'b0,`OPSELNB'b0101};//div
      {2'b1x,`FNCNB'b100110}: opSel={`SHMATNRBITI'b0,`OPSELNB'b0011};//xor
      {2'b1x,`FNCNB'b100111}: opSel={`SHMATNRBITI'b0,`OPSELNB'b0100};//nor
      {2'b1x,`FNCNB'b000100}: opSel={`SHMATNRBITI'b0,`OPSELNB'b1000};//sllv
      {2'b1x,`FNCNB'b000110}: opSel={`SHMATNRBITI'b0,`OPSELNB'b1001};//srlv
      {2'b1x,`FNCNB'b000111}: opSel={`SHMATNRBITI'b0,`OPSELNB'b1010};//srav
      {2'b1x,`FNCNB'b000000}: opSel={funct[`FNCTNB-1:`FNCNB],`OPSELNB'b1011};//sll
      {2'b1x,`FNCNB'b000010}: opSel={funct[`FNCTNB-1:`FNCNB],`OPSELNB'b1100};//srl
      {2'b1x,`FNCNB'b000011}: opSel={funct[`FNCTNB-1:`FNCNB],`OPSELNB'b1101};//sra
      default:opSel=`OPSELNRBITI'bx;

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
  

