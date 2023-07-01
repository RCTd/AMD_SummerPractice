module test();
  reg clk;
  
  MIPS mips(.clk(clk));
  
  reg Clock,stop_Clock;
  reg [31:0] addr,bits;
  integer fd, count;
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
      fd = $fopen("instM.txt", "r");
      addr=0;
      begin : read_loop
        forever @(posedge Clock)
        begin
          count = $fscanf( fd, "%32b", bits );
          if ( count == EOF || count == 0 )
            disable read_loop;
          else
            begin
              $display("bits = %32b ", bits);
              mips.im.mem[addr  ]=bits[7:0];
              mips.im.mem[addr+1]=bits[15:8];
              mips.im.mem[addr+2]=bits[23:16];
              mips.im.mem[addr+3]=bits[31:24];
              addr=addr+4;
            end
        end 
      end //on EOF this block is disabled
      $fclose( fd );
      stop_Clock = 1;
      
      //this is the last line of my current program
      while(mips.pc.out!==32'h28)
        #5;
    #10 $finish(1);
    
  end

endmodule