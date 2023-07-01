module test();
  reg clk;
  
  MIPS mips(.clk(clk));
  
  reg Clock,stop_Clock;
  reg [31:0] addr,Ibits,Dbits;
  integer fim, fdm, Icount,Dcount;
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
      clk= 1'bx;  
      while (!stop_Clock) 
        #5;
      clk= 1'b0;
      forever #5 clk = ~clk;
    end
  
  initial
    begin// Write Instruction Memory
      $dumpfile("dump.vcd"); $dumpvars;
      fim = $fopen("instM.txt", "r");
      addr=0;
      begin : read_I_loop
        forever @(posedge Clock)
        begin
          Icount = $fscanf( fim, "%32b", Ibits );
          if ( Icount == EOF || Icount == 0 )
            disable read_I_loop;
          else
            begin
              $display("Ibits = %32b ", Ibits);
              mips.im.mem[addr  ]=Ibits[7:0];
              mips.im.mem[addr+1]=Ibits[15:8];
              mips.im.mem[addr+2]=Ibits[23:16];
              mips.im.mem[addr+3]=Ibits[31:24];
              addr=addr+4;
            end
        end 
      end //on EOF this block is disabled
      $fclose( fim );
      
      fdm = $fopen("dataM.txt", "r");
      addr=0;
      begin : read_D_loop
        forever @(posedge Clock)
        begin
          Dcount = $fscanf( fim, "%32b", Dbits );
          if ( Dcount == EOF || Dcount == 0 )
            disable read_D_loop;
          else
            begin
              $display("Dbits = %32b ", Dbits);
              mips.dm.mem[addr  ]=Dbits[7:0];
              mips.dm.mem[addr+1]=Dbits[15:8];
              mips.dm.mem[addr+2]=Dbits[23:16];
              mips.dm.mem[addr+3]=Dbits[31:24];
              addr=addr+4;
            end
        end 
      end //on EOF this block is disabled
      $fclose( fdm );
      stop_Clock = 1;
      
      //this is the last line of my current program
      while(mips.pc.out!==32'h28)
        #5;
    #10 $finish(1);
    
  end

endmodule