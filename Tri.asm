
	.text
main:
	subu $sp, $sp, 4
	sw $ra, ($sp)

	li $a0, 2
	li $a1, 1000
	jal RIC
	move $s0, $v0

	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra


F:
	subu $sp, $sp, 4
	sw $fp, ($sp)
	addi $t0, $a0, -8192
	blez $t0, SX
	li $t0, 16384
	sub $a0, $t0, $a0
SX:
	li $t0, 2
	mul $v0, $a0, $t0
	lw $fp, ($sp)
	addi $sp, $sp, 4
	jr $ra
	

RIC:
	subu $sp, $sp, 12
	sw $fp, ($sp)
	sw $ra, 4($sp)
	sw $s0, 8($sp)
	
	bne $a0, $zero, R
	move $a0, $a1
	jal F
	lw $fp, ($sp)
	lw $ra, 4($sp)
	lw $s0, 8($sp)
	addi $sp, $sp, 12
	jr $ra
	
R:	
	addi $a0, $a0, -1
	jal RIC
	move $a0, $v0
	jal F
	lw $fp, ($sp)
	lw $ra, 4($sp)
	lw $s0, 8($sp)
	addi $sp, $sp, 12
	jr $ra
	
