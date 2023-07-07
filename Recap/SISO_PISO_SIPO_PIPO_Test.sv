module testbench();
 
  //SHReg4 Ichip1(Pin,clk,shr,out);
  
  reg clk;
  //reg shr;
//   reg [3:0]Pin;
//   wire [3:0]out;  
  
  PISO Ichip2(in2,clk,pl2,so2,out2);
  wire out2;
  reg so2,pl2;
  reg[3:0]in2;
  
  SISO Ichip3(in3,clk,sl3,so3,out3);
  reg in3,sl3,so3;
  wire out3;
  
  SIPO Ichip4(in4,clk,sl4,po4,out4);
  reg in4,sl4,po4;
  wire [3:0]out4;
  
  PIPO Ichip5(in5,clk,pl5,po5,out5);
  reg pl5,po5;
  wire [3:0]out5;
  reg[3:0]in5;
  
  initial 
    begin
      clk= 1'b0;  
      forever #25 clk = ~clk;
    end
  
  initial begin
    #0 testSiso(4'b1011);
  end
  
  initial begin
    #0 testSipo(4'b1011);
  end
  
  initial begin
    #0 testPipo(4'b1011);
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
      in2[3:0]<=intest[3:0];
      pl2=1'b1;
      so2=1'b1;
      #50
      pl2=1'b0;
      #200;
    end
  endtask
  
  task testSiso;
    input [3:0]intest;
    begin
      #0
      sl3=1'b1;
      so3=1'b1;
      #50 
      in3=intest[0];
      #50
      in3=intest[1];
      #50
      in3=intest[2];
      #50
      in3=intest[3];
      #50
      sl3=1'b0;
      #200;
    end
  endtask
  
  task testSipo;
    input [3:0]intest;
    begin
      #0
      sl4=1'b1;
      po4=1'b1;
      #50 
      in4=intest[0];
      #50
      in4=intest[1];
      #50
      in4=intest[2];
      #50
      in4=intest[3];
      #50
      sl4=1'b0;
      #100;
    end
  endtask
  
  task testPipo;
    input [3:0]intest;
    begin
      #0
      pl5=1'b1;
      po5=1'b1;
      in5=intest;
      #50
      pl5=1'b0;
      #100;
    end
  endtask
  
//   task PIPO;
//     input [3:0]intest;
//     begin
//       #0 
//       shr<=1'b0;	
//       Pin[3:0]<=intest[3:0];
//       #50;
//     end
//   endtask
  
//   task PISO;
//     input [3:0]intest;
//     begin
//       #0 
//       shr<=1'b0;	
//       Pin[3:0]<=intest[3:0];
//       #50
//       shr<=1'b1;
//     end
//   endtask
  
//   task SI;
//     input [3:0]intest;
//     begin
//       #0 
//       shr<=1'b1;	
//       Pin[3]<=intest[0];
//       #50
//       Pin[3]<=intest[1];
//       #50
//       Pin[3]<=intest[2];
//       #50
//       Pin[3]<=intest[3];
//       #200;
//     end
//   endtask
  
  
  
endmodule
