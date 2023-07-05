addi $s0, $zero, 6
addi $s1, $zero, 8
sw $s0,0($zero)
lw $t0,0($zero)
sw $s1,0($zero)
sw $s1,4($zero)
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
addi $s1,$zero,2
sllv $s1,$s1,$s1
addi $s2,$zero,43
xor $s2,$s2,$s1
nor $s2,$s1,$s2
or $s2,$s2,$s1
sll $s1,$s1,2
sra $s2,$s2,4
srl $s2,$s2,3
addi $s1,$zero,2
srav $s2,$s2,$s1
srlv $s2,$s2,$s1
FINISH:
j FINISH