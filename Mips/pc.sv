module PC(in,
          clk,
          start,
          out);
  input [31:0]in;
  input clk,start;
  output reg [31:0]out=32'h0000;
  always@(posedge clk)
    if(start==1'b1)
    	out<=in;
endmodule
