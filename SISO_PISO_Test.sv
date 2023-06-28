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
  
  PISO Ichip2(Pin,clk,pl,so,done,out2);
  wire out2,done;
  reg so,pl;
  
  SISO Ichip3(in,clk,sl,so3,done3,out3);
  reg in,sl,so3;
  wire out3,done3;
  
  initial 
    begin
      clk= 1'b0;  
      forever #25 clk = ~clk;
    end
  
  initial begin
    #0 testSiso(4'b1011);
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    
    #0
//     PIPO(4'b1011);
//     PIPO(4'b0101);
//     PIPO(4'b0000);

//     SI(4'b1010);
    //SI(4'b0100);
    testPiso(4'b1011);
    
    #900;
    $finish(1);
  end
  
  task testPiso;
    input [3:0]intest;
    begin
      #0
      Pin[3:0]<=intest[3:0];
      pl=1'b1;
      so=1'b1;
      #50
      pl=1'b0;
      #200;
    end
  endtask
  
  task testSiso;
    input [3:0]intest;
    begin
      #0
      sl=1'b1;
      so3=1'b1;
      #50 
      in=intest[0];
      #50
      in=intest[1];
      #50
      in=intest[2];
      #50
      in=intest[3];
      #50
      sl=1'b0;
      #200;
    end
  endtask
  
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
