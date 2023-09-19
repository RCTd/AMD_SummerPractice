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