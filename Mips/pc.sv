module PC(in,
          clk,
          out);
  input [31:0]in;
  input clk;
  output reg [31:0]out=32'h0000;
  always@(posedge clk)
    out<=in;
endmodule
