lw $t0,0($zero)
lw $t2,4($zero)
add $s0,$zero,$zero
addi $s1,$s0,1
add $t1,$s1,$zero
START:
beq $t0,$t1,DONE
add $s2,$s0,$zero
add $s0,$s1,$zero
add $s1,$s0,$s2
sw $s1,($t2)
addi $t2,$t2,4
addi $t1,$t1,1
j START
DONE:
j DONE