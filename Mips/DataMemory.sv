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
  
  always@(negedge clk)//addr)
    if(memWrite==1)
      begin
        mem[addr+3]<=writeData[31:24];
        mem[addr+2]<=writeData[23:16];
        mem[addr+1]<=writeData[15:8];
        mem[addr]  <=writeData[7:0];
      end
  
  assign out[31:24]=memRead? mem[addr+3]:8'hxx;
  assign out[23:16]=memRead? mem[addr+2]:8'hxx;
  assign out[15:8] =memRead? mem[addr+1]:8'hxx;
  assign out[7:0]  =memRead? mem[addr]  :8'hxx;  
endmodule