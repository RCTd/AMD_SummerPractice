module testbench();
 
  SHReg4 Ichip1(Pin,clk,shr,out);
  
  
  reg clk;
  reg shr;
  reg [3:0]Pin;
  wire [3:0]out;
  wire Sout;
  wire Sin;
  
  assign Sin=Pin[3];
  assign Sout=out[0];
  
  initial 
    begin
      clk= 1'b0;  
      forever #25 clk = ~clk;
    end
  
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    
    #0
    PIPO(4'b1011);
    PIPO(4'b0101);
    PIPO(4'b0000);

    SI(4'b1010);
    //SI(4'b0100);
    
    #900;
    $finish(1);
  end
  
  
  task PIPO;
    input [3:0]intest;
    begin
      #0 
      shr<=1'b0;	
      Pin[3:0]<=intest[3:0];
      #50;
    end
  endtask
  
  task PISO;
    input [3:0]intest;
    begin
      #0 
      shr<=1'b0;	
      Pin[3:0]<=intest[3:0];
      #50
      shr<=1'b1;
    end
  endtask
  
  task SI;
    input [3:0]intest;
    begin
      #0 
      shr<=1'b1;	
      Pin[3]<=intest[0];
      #50
      Pin[3]<=intest[1];
      #50
      Pin[3]<=intest[2];
      #50
      Pin[3]<=intest[3];
      #200;
    end
  endtask
  
  
  
endmodule
