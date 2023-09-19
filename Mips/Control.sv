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