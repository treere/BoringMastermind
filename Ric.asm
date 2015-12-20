	.text
main:
	subu $sp, $sp, 4
	sw $ra, ($sp)
	li $a0, 5
	li $a1, 1
	jal F
	move $s0, $v0
	lw $ra, ($sp)
	jr $ra


F:
	subu $sp, $sp, 4
	sw $ra, ($sp)

	bne $a0, $zero ELSE
	move $v0, $a1
	addi $sp, $sp, 4
	jr $ra

ELSE:
	addi $a0, $a0, -1
	jal F

	li $t0, 16380
	subu $t1, $t0, $v0
	mul $t1, $t1, $v0
	div $t1, $t0
	mfhi $v0
	

	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
