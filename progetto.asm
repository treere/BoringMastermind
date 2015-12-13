	.data
INTRO:	.asciiz "Benvenuti nel noioso gioco del master mind al contrario\n"
INS:	.asciiz "Inserire una stringa\n"
READ:	.asciiz "ooxxx"
	.align 1
X:	.byte 17  #A 16 cosi' vedo 1111
O:	.byte 17 
COD:	.space 16384 # 8 * 8 * 8 * 8 * 4

	.text
### crea le permutazioni chiamando la funzione map con la funzione permutation
create_permutations:
	subu $sp, $sp , 8
	sw $ra, 4($sp)
	sw $fp, 0($sp)

	la $a0, COD
	li $a1, 16380 
	la $a2, permutation
	li $a3, 4

	jal map
	
	lw $fp, 0($sp)
	lw $ra, 4($sp)
	add $sp, $sp, 8
	jr $ra

### genera permutazione nella posizione i
### permutazione(posizione)
permutation:
	subu $sp, $sp, 8
	sw $s1, 8($sp)
	sw $s0, 4($sp)
	sw $fp, 0($sp)

	li $s0, 4
	div $a0, $s0
	mflo $s1
	li $s0, 8
	div $s1, $s0 # lo = divisione , hi = resto
	mfhi $t0 # valore della prima posizione
	mflo $t1
	div $t1, $s0
	mfhi $t1 # valore seconda posizione
	mflo $t2
	div $t2, $s0
	mfhi $t2
	mflo $t3
	div $t3, $s0
	mfhi $t3

	sb $t0, 0($a0) 
	sb $t1, 1($a0) 
	sb $t2, 2($a0) 
	sb $t3, 3($a0) 

	lw $fp, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	add $sp, $sp, 8
	jr $ra

####  map ( array, valore , F(posizione in array), decremento ) ####
map: 
	subu $sp, $sp, 28
	sw $s4, 24($sp)
	sw $s3, 20($sp) 
	sw $s2, 16($sp)
	sw $s1, 12($sp)
	sw $s0, 8($sp) 
	sw $ra, 4($sp)
	sw $fp, 0($sp)

	move $s0, $a0 
	move $s1, $a1
	move $s2, $a2
	move $s4, $a3
m_loop:
	bltz $s1, m_end
	add $s3, $s0, $s1 # $s3 e' la posizione da lavorare
	move $a0, $s3
    jalr $s2
	subu $s1, $s1, $s4
	j m_loop
m_end:	
	lw $s4, 24($sp)
	lw $s3, 20($sp)
	lw $s2, 16($sp)
	lw $s1, 12($sp)
	lw $s0, 8($sp)
	lw $ra, 4($sp)
	lw $fp, 0($sp)
	addi $sp, $sp, 28
	jr $ra

#### read_input() #### salva l'input in X e O
read_input:
	### SALVATAGGIO ###
	subu $sp, $sp, 12
	sw $fp, 8($sp)
	sw $s0, 4($sp)
	sw $s1, 0($sp)
	
	li $s0, 0		# s0 -> X	
	li $s1, 0		# s1 -> O
	li $t0, 3		# devo dare 3 giri
	li $t2, 'x'		
	li $t3, 'o'		
	
ri_loop:				
	la $t1, READ		# metto in t1 il carattere t0-esime
	add $t1, $t1, $t0	
	lb $t1, ($t1)		
	
	bne $t1, $t2, ri_nox	# confronto on 'x'
	addi $s0, 1		
ri_nox:		
	bne $t1, $t3, ri_noo	# confronto on 'o'
	addi $s1, 1		
ri_noo:		
	addi $t0, -1		# diminuisco indice del ciclo
	bgez $t0, ri_loop	# controllo del ciclo

	sb $s0, X		# salvo X e O
	sb $s1, O		

	### RIPRISTINO STACK ###
	lw $fp, 8($sp)
	lw $s0, 4($sp)
	lw $s1, 0($sp)
	addi $sp, $sp, 12
	jr $ra

#### print intro() ####
print_intro:	
	subu $sp, $sp, 4
	sw $fp, ($sp)
	li $v0, 4		
	la $a0, INTRO		
	syscall 		
	lw $fp, ($sp)
	addi $sp, $sp, 4

#### take input() ####
take_input:
	subu $sp, $sp, 4
	sw $fp, ($sp)
	#   SCRITTA LETTURA
	li $v0, 4		
	la $a0, INS		
	syscall			
	#   INPUT LETTURA
	li $v0, 8		
	la $a0, READ		
	li $a1, 5		
#	syscall		
	
	lw $fp, ($sp)
	addi $sp, $sp, 4
	jr $ra
	
main:
	subu $sp, $sp, 4
	sw $ra, ($sp)

	jal create_permutations
	
	jal print_intro
	jal take_input
	jal read_input


	lw $ra, ($sp)
	jr $ra			
