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

module MUX4_2(A,B,C,D,sel,O);
  input A,B,C,D;
  input [1:0]sel;
  output O;
  assign O=sel[1] ? (sel[0]?D:C) : (sel[0]?B:A);
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

module SHReg4E(in,
              clk,
              sel,
              out);
  input [3:0]in;
  input clk;
  input [1:0]sel; //00-idle 01-pl 10-shr 11-reset
  output [3:0]out;
  
  wire [3:0]muxO;
  
  MUX4_2 mux3(out[3],in[3],in[3],1'b0,sel,muxO[3]);
  MUX4_2 mux2(out[2],in[2],out[3],1'b0,sel,muxO[2]);
  MUX4_2 mux1(out[1],in[1],out[2],1'b0,sel,muxO[1]);
  MUX4_2 mux0(out[0],in[0],out[1],1'b0,sel,muxO[0]);

  BistabilD BD3(muxO[3],clk,out[3]);
  BistabilD BD2(muxO[2],clk,out[2]);
  BistabilD BD1(muxO[1],clk,out[1]);
  BistabilD BD0(muxO[0],clk,out[0]);
  
endmodule
  

// module Reg4SISO(in,clk,out);
//   input in;
//   input clk;
//   output out;
  
//   wire [2:0]next;
  
//   BistabilD BD3(in,clk,next[2]);
//   BistabilD BD2(next[2],clk,next[1]);
//   BistabilD BD1(next[1],clk,next[0]);
//   BistabilD BD0(next[0],clk,out);
// endmodule
  
// module Reg4SIPO(in,clk,out);
//   input in;
//   input clk;
//   output [3:0]out;
  
//   BistabilD BD3(in,clk,out[3]);
//   BistabilD BD2(out[3],clk,out[2]);
//   BistabilD BD1(out[2],clk,out[1]);
//   BistabilD BD0(out[1],clk,out[0]);
// endmodule

// module Reg4PIPO(in,clk,out);
//   input [3:0]in;
//   input clk;
//   output [3:0]out;
  
//   BistabilD BD3(in[3],clk,out[3]);
//   BistabilD BD2(in[2],clk,out[2]);
//   BistabilD BD1(in[1],clk,out[1]);
//   BistabilD BD0(in[0],clk,out[0]);
// endmodule

module PISO(in,
            clk,
            pl,
            so,
            out);
  input [3:0]in;
  input clk;
  input pl;
  input so;
  reg done=1'b1;
  output out;
  
  reg [1:0]sel=2'b00;
  reg [2:0]i=4;
  wire [3:0]dout;
  SHReg4E D(in,clk,sel,dout);
  assign out=done?1'bz:dout[0];
  
  always@(posedge clk)
  begin
    casex({pl,so})
      2'b00:
        begin
          sel=2'b00;
          done=1'bz;
        end
      2'b1x:
        begin
          sel=2'b01;
          i=4;
        end
      2'b01:
        begin
          sel=2'b10;
          done=1'b0;
          if(i>0)
          	i=i-1;
          else
            done=1'b1;
        end
    endcase
  end
  
endmodule


module SISO(in,
            clk,
            sl,
            so,
            out);
  input in;
  input clk;
  input sl;
  input so;
  reg done=1'b1;
  output out;
  
  reg [1:0]sel=2'b00;
  reg [2:0]i=4;
  reg [2:0]j=4;
  wire [3:0]dout;
  SHReg4E D({in,3'bz},clk,sel,dout);
  
  assign out=done?1'bz:dout[0];
  
  always@(posedge clk)
  begin
    casex({sl,so})
      2'b00:
        begin
          sel=2'b00;
          done=1'bz;
          i=4;j=4;
        end
      2'b1x:
        begin
          sel=2'b10;
          if(j>0)
          	j=j-1;
          else
            begin
              i=4;
              sel=2'b00;
            end
        end
      2'b01:
        begin
          sel=2'b10;
          done=1'b0;
          if(i>0)
          	i=i-1;
          else
            begin
              done=1'b1;
              j=4;
              sel=2'b00;
            end
        end
    endcase
  end
  
endmodule

module SIPO(in,
            clk,
            sl,
            po,
            out);
  input in;
  input clk;
  input sl;
  input po;
  reg done=1'b1;
  output [3:0]out;
  
  reg [1:0]sel=2'b00;
  reg [2:0]j=4;
  reg i=0;
  wire [3:0]dout;
  SHReg4E D({in,3'bz},clk,sel,dout);
  
  assign out=done?4'bz:dout;
  
  always@(posedge clk)
  begin
    casex({sl,po})
      2'b00:
        begin
          sel=2'b00;
          done=1'b1;
          j=4;
          i=0;
        end
      2'b1x:
        begin
          sel=2'b10;
          done=1'b1;
          i=0;
          if(j>0)
          	j=j-1;
          else
            sel=2'b00;
        end
      2'b01:
        begin
          sel=2'b00;
          done=1'b1;
          if(i==0)
            begin
              i=i+1;
              sel=2'b10;
              done=1'b0;
              j=4;
            end            
        end
    endcase
  end
  
endmodule

module PIPO(in,
            clk,
            pl,
            po,
            out);
  input [3:0]in;
  input clk;
  input pl;
  input po;
  reg done=1'b1;
  output [3:0]out;
  
  reg [1:0]sel=2'b00;
  reg i=1;
  wire [3:0]dout;
  SHReg4E D(in,clk,sel,dout);
  
  assign out=done?4'bz:dout; 
  
  always@(posedge clk)
  begin
    casex({pl,po})
      2'b00:
        begin
          sel=2'b00;
          done=1'b1;
          i=1;
        end
      2'b1x:
        begin
          sel=2'b01;
          done=1'b1;
          i=1;
        end
      2'b01:
        begin
          sel=2'b00;
          done=1'b1;
          if(i==1)
            begin
              i=i-1;
              sel=2'b10;
              done=1'b0;
            end            
        end
    endcase
  end
  
endmodule
