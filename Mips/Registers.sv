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
  
  always@(negedge clk)
    begin
      if(regWrite==1)
        inReg[writeRegister]<=writeData;
    end	
  
endmodule
