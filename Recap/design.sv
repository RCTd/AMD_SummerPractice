module BistabilD(A,clk,out);
  input A;
  input clk;
  output out;
  
  reg out=1'b0;
  always @(posedge clk)
  begin
  	out<=A;
  end
endmodule
    
module AND(input A, input B, output O);
  assign O = A & B;
endmodule

module F(input A, input B,input C,input D, output O);
  assign O = ~((A & B)&((C&D)^(C|B)));
endmodule

module MUX(A,B,sel,O);
  input A,B,sel;
  output O;
  //assign O=A&~(sel) | B&sel;
  assign O=sel ? B : A;
endmodule


module SHReg4(in,
              clk,
              shr,
              out);
  input [3:0]in;
  input clk;
  input shr;
  output [3:0]out;
  
  wire [2:0]muxO;
  
  MUX mux2(in[2],out[3],shr,muxO[2]);
  MUX mux1(in[1],out[2],shr,muxO[1]);
  MUX mux0(in[0],out[1],shr,muxO[0]);
  
  BistabilD BD3(in[3],clk,out[3]);
  BistabilD BD2(muxO[2],clk,out[2]);
  BistabilD BD1(muxO[1],clk,out[1]);
  BistabilD BD0(muxO[0],clk,out[0]);
endmodule
  
  
