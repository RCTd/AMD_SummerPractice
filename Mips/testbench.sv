module test();
  reg clk;
  
  MIPS mips(.clk(clk));
  
  reg [31:0] addr;
  integer i;
  initial
    begin
      clk=1'bz;
      #5 clk= 1'b0;
      forever #5 clk = ~clk;
    end
  
  initial
    begin
      $dumpfile("dump.vcd"); 
      $dumpvars(0,mips);
      // view some data memory
      for(i = 0; i < 32; i = i + 1)
        $dumpvars(1, mips.dm.mem[i]);
	
      // view registers
      for(i = 0; i < 32; i = i + 1)
        $dumpvars(1, mips.rg.inReg[i]);	

      while(mips.pc.out!==136)
        #5;
      #20 $finish(1);	
//       #700 $finish(1);

  end

endmodule
