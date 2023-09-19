`define SHMATNRBITI 5
`define OPSELNB 4
`define OPSELNRBITI `OPSELNB+`SHMATNRBITI
module ALU(opA,
           opB,
           opSel,
           result,
           zero);
  input [31:0]opA,opB;
  input [`OPSELNRBITI-1:0]opSel;
  output reg[31:0]result=0;
  output reg zero;
  
  always@(*)
    begin
      casex(opSel[`OPSELNB-1:0])
        `OPSELNB'b0000:result=opA&opB;				//AND
        `OPSELNB'b0001:result=opA|opB;				//OR
        `OPSELNB'b0010:result=opA+opB;				//ADD
        `OPSELNB'b0110:result=opA-opB;				//SUB
        `OPSELNB'b0111:result=(opA<opB)?32'h1:32'h0;//SLT
        
        //valori ce nu se regasesc in vreo documentatie
        `OPSELNB'b0011:result=opA^opB;				//XOR
        `OPSELNB'b0100:result=~(opA|opB);			//NOR
        `OPSELNB'b0101:								//DIV       
          begin 
            result[31:16]=opA%opB;
            result[15:0]=opA/opB;
          end
        `OPSELNB'b1000:result=opA<<opB[4:0];		//SLLV
        `OPSELNB'b1001:result=opA>>opB[4:0];		//SRLV
        `OPSELNB'b1010:result=opA>>>opB[4:0];		//SRAV
        `OPSELNB'b1011:result=opA<<opSel[`OPSELNRBITI-1:`SHMATNRBITI-1];
        `OPSELNB'b1100:result=opA>>opSel[`OPSELNRBITI-1:`SHMATNRBITI-1];		//SRL
        `OPSELNB'b1101:result=opA>>>opSel[`OPSELNRBITI-1:`SHMATNRBITI-1];		//SRA
        default:result=32'bx;

      endcase
      zero=~(|result);
    end
 
endmodule