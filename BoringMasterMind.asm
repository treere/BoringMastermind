	.data
	.align 4
INTRO:	.asciiz "Benvenuti nel noioso gioco del master mind al contrario\n"
INS:	.asciiz "Inserire una stringa\n"
ERRORE:	.asciiz "E' stata certamente inserita una risposta errata\n"
VITT: 	.asciiz "E anche questa volta ti ho battuto\n"	
GUESS:	.asciiz "Tentativo: "
READ:	.asciiz "aaaao"
	.align 1
X:	.byte 17  #A 16 cosi' vedo 1111
O:	.byte 17 
	.align 2
PROP:	.word 0x01020304
TMP_P:	.space 4
TMP_C:	.space 4
EMPTY:	.space 4 # spazio vuoto per vedere dove inizia il COD
COD:	.space 16384 # 8 * 8 * 8 * 8 * 4byte

	.text

### filtra l'array cod. chiama la funzione map ###
filter:
	subu $sp, $sp, 8
	sw $ra, 4($sp)
	sw $fp, 0($sp)

	la $a0, COD
	li $a1, 16380 
	la $a2, compare_codes
	li $a3, 4

	jal map
	
	lw $fp, 0($sp)
	lw $ra, 4($sp)
	add $sp, $sp, 8
	jr $ra

compare_codes:
	subu $sp, $sp, 24
	# posizione 16 TMP_C
	# posizione 20 TMP_P
	sw $s2, 12($sp)
	sw $s1, 8($sp)
	sw $s0, 4($sp)
	sw $fp, 0($sp)

	li $s0, 0 # sono le X

	# copio il codice per non distruggerlo
	la $t0, TMP_C
	lw $t1, ($a0)
	sw $t1, ($t0)
	# copio il mio tentarivo per non distruggerlo
	la $t2, PROP
	la $t0, TMP_P
	lw $t1, ($t2)
	sw $t1, ($t0)

	la $t0, TMP_P
	la $t1, TMP_C

	### inizio con il controllo sulle X
	li $s1, 4 # serve per il ciclo
cc_loop_x:
	lb $t2, ($t0)
	lb $t3, ($t1)
	bne $t2, $t3, c_c_not_eq
	li $t2, -1
	sb $t2, ($t0)
	sb $t2, ($t1)
	addi $s0, $s0, 1
c_c_not_eq:
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	addi $s1, $s1, -1
	bgtz $s1, cc_loop_x

	la $t0, X
	lb $t0, ($t0)

	beq $t0, $s0, c_c_controlla_O
	li $t1, 0xff0000ff
	sw $t1, ($a0)
	j c_c_esci
	### fine controllo sulle X

	### inizio controllo sulle O
c_c_controlla_O:	
	li $s0, 0 # sono le O
	la $t0, TMP_C
	li $s1, 4
cc_loop_o:
	lb $t2, ($t0)
	li $t3, -1
	beq $t3, $t2, cc_continue_o
	la $t1, TMP_P
	li $s2, 4
cc_loop_oo:
	lb $t3, ($t1)
	bne $t2,$t3,cc_continue_oo
	addi $s0, $s0, 1
	li $t3, -1
	sb $t3, ($t1)
	j cc_continue_o
cc_continue_oo:	
	addi $t1, $t1, 1
	addi $s2, $s2, -1
	bgtz $s2, cc_loop_oo
cc_continue_o:	
	addi $t0, $t0, 1
	addi $s1, $s1, -1
	bgtz $s1, cc_loop_o

	la $t0, O
	lb $t0, ($t0)

	beq $t0, $s0, c_c_esci
	li $t1, -1
	sw $t1, ($a0)
	j c_c_esci
	### fine controllo sulle O
c_c_esci:	
	lw $s2, 12($sp)
	lw $s1, 8($sp)
	lw $s0, 4($sp)
	lw $fp, 0($sp)
	add $sp, $sp, 24
	jr $ra
	
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
	addi $s0, $s0, 1		
ri_nox:		
	bne $t1, $t3, ri_noo	# confronto on 'o'
	addi $s1, $s1, 1		
ri_noo:		
	addi $t0, $t0, -1		# diminuisco indice del ciclo
	bgez $t0, ri_loop	# controllo del ciclo

	sb $s0, X		# salvo X e O
	sb $s1, O		

	li $v0, 11
	li $a0, '\n'
	syscall

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
	jr $ra

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
	syscall		
	lw $fp, ($sp)
	addi $sp, $sp, 4
	jr $ra
	
guess:
	subu $sp, $sp, 4
	sw $fp, 0($sp)

	la $t0, COD
	li $t1, -1
guess_loop:	
	lb $t2, ($t0)
	bne $t2, $t1, guess_trovato
	addi $t0, $t0, 4
	
	la $t3, COD
	addi $t3, $t3, 16384
	sub $t3, $t3, $t0
	bgtz $t3, guess_loop
	li $v0, 4
	la $a0, ERRORE
	syscall
	li $v0, 10
	syscall

guess_trovato:
	li $v0, 4
	la $a0, GUESS
	syscall
	# forse vanno stampati invertiti
	la $t1, PROP
	li $v0, 1		
	lb $a0, 0($t0)
	sb $a0, 0($t1)
	syscall 		
	lb $a0, 1($t0)		
	sb $a0, 1($t1)
	syscall 		
	lb $a0, 2($t0)		
	sb $a0, 2($t1)
	syscall 		
	lb $a0, 3($t0)		
	sb $a0, 3($t1)
	syscall 		
	li $v0, 11
	li $a0, '\n'
	syscall

	lw $fp, 0($sp)
	add $sp, $sp, 4
	jr $ra
	
main:
	jal print_intro
	jal create_permutations
main_loop:	
	jal guess
	jal take_input
	jal read_input
	la $t0, X
	lb $t0, ($t0)
	li $t1, 4
	beq $t0, $t1, win
	jal filter
	j main_loop
	
win:	
	li $v0, 4
	la $a0, VITT
	syscall

end:	
	li $v0, 10
	syscall
