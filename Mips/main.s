addi $t0,$zero,3
add $s0,$zero,$zero
addi $s1,$s0,1
add $t1,$s1,$zero
START:
beq $t0,$t1,DONE
add $s2,$s0,$zero
add $s0,$s1,$zero
add $s1,$s0,$s2
addi $t1,$t1,1
j START
DONE:
j DONE