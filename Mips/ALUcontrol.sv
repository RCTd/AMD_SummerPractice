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