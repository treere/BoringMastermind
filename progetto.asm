	.data
VET:	.space 40
	.text
	
main:	
	la $t0, VET
	li $t1, 40
loop:	
	addi $t1, -4 #incremento del ciclo
	add $t2, $t0, $t1
	sw $t1, ($t2)
	bgtz $t1, loop
	jr $ra
