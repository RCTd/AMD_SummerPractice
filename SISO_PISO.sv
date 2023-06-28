module MUX4_2(A,B,C,D,sel,O);
  input A,B,C,D;
  input [1:0]sel;
  output O;
  assign O=sel[1] ? (sel[0]?D:C) : (sel[0]?B:A);
endmodule
module SHReg4E(in,
              clk,
              sel,
              out);
  input [3:0]in;
  input clk;
  input [1:0]sel; //00-idle 01-pl 10-shr 11-reset
  output [3:0]out;
  
  wire [3:0]dout;
  assign out=dout;
  wire [3:0]muxO;
  
  MUX4_2 mux3(dout[3],in[3],in[3],1'b0,sel,muxO[3]);
  MUX4_2 mux2(dout[2],in[2],dout[3],1'b0,sel,muxO[2]);
  MUX4_2 mux1(dout[1],in[1],dout[2],1'b0,sel,muxO[1]);
  MUX4_2 mux0(dout[0],in[0],dout[1],1'b0,sel,muxO[0]);

  BistabilD BD3(muxO[3],clk,dout[3]);
  BistabilD BD2(muxO[2],clk,dout[2]);
  BistabilD BD1(muxO[1],clk,dout[1]);
  BistabilD BD0(muxO[0],clk,dout[0]);
  
endmodule


module PISO(in,
            clk,
            pl,
            so,
            done,
            out);
  input [3:0]in;
  input clk;
  input pl;
  input so;
  output reg done=1'b1;
  output out;
  
  reg [1:0]sel=2'b00;
  reg [2:0]i=4;
  wire [2:0]dout;
  SHReg4E D(in,clk,sel,{dout,out});
  
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
            done,
            out);
  input in;
  input clk;
  input sl;
  input so;
  output reg done=1'b1;
  output out;
  
  reg [1:0]sel=2'b00;
  reg [2:0]i=4;
  reg [2:0]j=4;
  wire [2:0]dout;
  wire [2:0]din;
  SHReg4E D({in,din},clk,sel,{dout,out});
  
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
