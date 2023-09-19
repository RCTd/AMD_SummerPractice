module InstructionMemory(addr,
                         out);
  input[31:0]addr;
  output[31:0]out; 
  reg [7:0]mem[0:1023];
  
  initial 
    begin//iterative fibonacci 
//       {mem[3],mem[2],mem[1],mem[0]}=32'b00100000000100000000000000000110; //0x20100006 	addi $s0, $zero, 6
//       {mem[7],mem[6],mem[5],mem[4]}=32'b00100000000100010000000000001000; //0x20110008 	addi $s1, $zero, 8
//       {mem[11],mem[10],mem[9],mem[8]}=32'b10101100000100000000000000000000; //0xac100000 	sw $s0,0($zero)
//       {mem[15],mem[14],mem[13],mem[12]}=32'b10001100000010000000000000000000; //0x8c080000 	lw $t0,0($zero)
//       {mem[19],mem[18],mem[17],mem[16]}=32'b10101100000100010000000000000000; //0xac110000 	sw $s1,0($zero)
//       {mem[23],mem[22],mem[21],mem[20]}=32'b10101100000100010000000000000100; //0xac110004 	sw $s1,4($zero)
//       {mem[27],mem[26],mem[25],mem[24]}=32'b10001100000010100000000000000100; //0x8c0a0004 	lw $t2,4($zero)
//       {mem[31],mem[30],mem[29],mem[28]}=32'b00000000000000001000000000100000; //0x8020 	add $s0,$zero,$zero
//       {mem[35],mem[34],mem[33],mem[32]}=32'b00100010000100010000000000000001; //0x22110001 	addi $s1,$s0,1
//       {mem[39],mem[38],mem[37],mem[36]}=32'b00000010001000000100100000100000; //0x2204820 	add $t1,$s1,$zero
//       {mem[43],mem[42],mem[41],mem[40]}=32'b00010001000010010000000000000111; //0x11090007 	beq $t0,$t1,DONE
//       {mem[47],mem[46],mem[45],mem[44]}=32'b00000010000000001001000000100000; //0x2009020 	add $s2,$s0,$zero
//       {mem[51],mem[50],mem[49],mem[48]}=32'b00000010001000001000000000100000; //0x2208020 	add $s0,$s1,$zero
//       {mem[55],mem[54],mem[53],mem[52]}=32'b00000010000100101000100000100000; //0x2128820 	add $s1,$s0,$s2
//       {mem[59],mem[58],mem[57],mem[56]}=32'b10101101010100010000000000000000; //0xad510000 	sw $s1,($t2)
//       {mem[63],mem[62],mem[61],mem[60]}=32'b00100001010010100000000000000100; //0x214a0004 	addi $t2,$t2,4
//       {mem[67],mem[66],mem[65],mem[64]}=32'b00100001001010010000000000000001; //0x21290001 	addi $t1,$t1,1
//       {mem[71],mem[70],mem[69],mem[68]}=32'b00001000000000000000000000001010; //0x800000a 	j START
//       {mem[75],mem[74],mem[73],mem[72]}=32'b00100000000100010000000000000010; //0x20110002 	addi $s1,$zero,2
//       {mem[79],mem[78],mem[77],mem[76]}=32'b00000010001100011000100000000100; //0x2318804 	sllv $s1,$s1,$s1
//       {mem[83],mem[82],mem[81],mem[80]}=32'b00100001001010010000000000000001; //0x21290001 	addi $t1,$t1,1
//       {mem[87],mem[86],mem[85],mem[84]}=32'b00100000000100100000000000101011; //0x2012002b 	addi $s2,$zero,43
//       {mem[91],mem[90],mem[89],mem[88]}=32'b00000010010100011001000000100110; //0x2519026 	xor $s2,$s2,$s1
//       {mem[95],mem[94],mem[93],mem[92]}=32'b00000010001100101001000000100111; //0x2329027 	nor $s2,$s1,$s2
//       {mem[99],mem[98],mem[97],mem[96]}=32'b00000010010100011001000000100101; //0x2519025 	or $s2,$s2,$s1
//       {mem[103],mem[102],mem[101],mem[100]}=32'b00000010001000001000100010000000; //0x2208880 	sll $s1,$s1,2
//       {mem[107],mem[106],mem[105],mem[104]}=32'b00000010010000001001000100000011; //0x2409103 	sra $s2,$s2,4
//       {mem[111],mem[110],mem[109],mem[108]}=32'b00000010010000001001000011000010; //0x24090c2 	srl $s2,$s2,3
//       {mem[115],mem[114],mem[113],mem[112]}=32'b00100000000100010000000000000010; //0x20110002 	addi $s1,$zero,2
//       {mem[119],mem[118],mem[117],mem[116]}=32'b00000010010100011001000000000111; //0x2519007 	srav $s2,$s2,$s1
//       {mem[123],mem[122],mem[121],mem[120]}=32'b00000010010100011001000000000110; //0x2519006 	srlv $s2,$s2,$s1
//       {mem[127],mem[126],mem[125],mem[124]}=32'b00100001001010011111111111111111; //0x2129ffff 	addi $t1,$t1,-1
//       {mem[131],mem[130],mem[129],mem[128]}=32'b00010001000010011111111111110100; //0x1109fff4 	beq $t0,$t1,UP
//       {mem[135],mem[134],mem[133],mem[132]}=32'b00000010001100001000000000101010; //0x230802a 	slt $s0,$s1,$s0
//       {mem[139],mem[138],mem[137],mem[136]}=32'b00001000000000000000000000100010; //0x8000022 	j FINISH
      
      $readmemb("instM.txt", mem);
    end
  
  assign out[31:24]=mem[addr+3];
  assign out[23:16]=mem[addr+2];
  assign out[15:8]=mem[addr+1];
  assign out[7:0]=mem[addr];
  
endmodule