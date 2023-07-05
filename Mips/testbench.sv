module test();
  reg clk;
  
  MIPS mips(.clk(clk));
  
  reg Clock,stop_Clock;
  reg [31:0] addr,Ibits,Dbits;
  integer fim, fdm, Icount,Dcount,i;
  localparam EOF = -1;
  
  initial 
    begin
      Clock = 0;
      stop_Clock = 0;
      while (!stop_Clock)
        #5 Clock = ~Clock;
    end
  initial
    begin
      clk= 1'b0;  
      while (!stop_Clock) 
        #5;
      clk= 1'b0;
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
      
//       fim = $fopen("instM.txt", "r");
//       addr=0;
//       begin : read_I_loop// Read Instruction Memory
//         forever @(posedge Clock)
//         begin
//           Icount = $fscanf( fim, "%32b", Ibits );
//           if ( Icount == EOF || Icount == 0 )
//             disable read_I_loop;
//           else
//             begin
//               $display("%h :Ibits = %h ",addr, Ibits);
//               mips.im.mem[addr  ]=Ibits[7:0];
//               mips.im.mem[addr+1]=Ibits[15:8];
//               mips.im.mem[addr+2]=Ibits[23:16];
//               mips.im.mem[addr+3]=Ibits[31:24];
//               addr=addr+4;
//             end
//         end 
//       end //on EOF this block is disabled
//       $fclose( fim );
//       Ibits=addr-4;
//       fdm = $fopen("dataM.txt", "r");
//       addr=0;
//       begin : read_D_loop// Read Data Memory
//         forever @(posedge Clock)
//         begin
//           Dcount = $fscanf( fim, "%32d", Dbits );
//           if ( Dcount == EOF || Dcount == 0 )
//             disable read_D_loop;
//           else
//             begin
//               $display("Dbits = %32b ", Dbits);
//               mips.dm.mem[addr  ]=Dbits[7:0];
//               mips.dm.mem[addr+1]=Dbits[15:8];
//               mips.dm.mem[addr+2]=Dbits[23:16];
//               mips.dm.mem[addr+3]=Dbits[31:24];
//               addr=addr+4;
//             end
//         end 
//       end //on EOF this block is disabled
//       $fclose( fdm );
      stop_Clock = 1;
      
      //run until last instruction
//       while(mips.pc.out!==Ibits)
      while(mips.pc.out!==120)
        #5;
      #20 $finish(1);	
//       #700 $finish(1);

  end

endmodule
