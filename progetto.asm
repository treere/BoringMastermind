	.data
INTRO:	.asciiz "Benvenuti nel noioso gioco del master mind al contrario\n"
INS:	.asciiz "Inserire una stringa\n"
READ:	.asciiz "xxxxx"
	.align 1
X:	.byte 17  #A 16 cosi' vedo 1111
O:	.byte 17 
COD:	.space 40000

	.text
main:
	######################
	######   INTRO  ######
	######################

	li $v0, 4		
	la $a0, INTRO		
	syscall 		

	######################
	#   SCRITTA LETTURA  #
	######################

	li $v0, 4		
	la $a0, INS		
	syscall			

	#######################
	###   INPUT LETTURA  ##
	#######################

	li $v0, 8		
	la $a0, READ		
	li $a1, 5		
	syscall		
	
	#######################
	###   CAPISCE INPUT  ##
	#######################

	li $s0, 0		# s0 -> X	
	li $s1, 0		# s1 -> O
	li $t0, 3		# devo dare 3 giri
	li $t2, 'x'		
	li $t3, 'o'		
	
loop:				
	la $t1, READ		# metto in t1 il carattere t0-esime
	add $t1, $t1, $t0	
	lb $t1, ($t1)		
	
	bne $t1, $t2, nox	# confronto on 'x'
	addi $s0, 1		
nox:		
	bne $t1, $t3, noo	# confronto on 'o'
	addi $s1, 1		
noo:		
	addi $t0, -1		# diminuisco indice del ciclo
	bgez $t0, loop		# controllo del ciclo

	sb $s0, X		# salvo X e O
	sb $s1, O		

	#######################
	#######   FINE  #######
	#######################

	jr $ra			# FINE	
	
