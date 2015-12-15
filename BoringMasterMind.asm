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

	la $a0, COD		# carico l'array da elaborare
	li $a1, 16380 		# carico da dove partire
	la $a2, compare_codes	# carico la funzione da usare
	li $a3, 4		# carico l'incremento

	jal map			# faccio partire la map
	
	lw $fp, 0($sp)
	lw $ra, 4($sp)
	add $sp, $sp, 8
	jr $ra

compare_codes:
# TODO usare stack invece delle variabili globali
# TODO manca l'uscita automatica se non e' una combinazione valida
	subu $sp, $sp, 16
	sw $s2, 12($sp)
	sw $s1, 8($sp)
	sw $s0, 4($sp)
	sw $fp, 0($sp)

	li $s0, 0 	# sono le X

	la $t0, TMP_C   # faccio una copia della posizione dalla dell'array perchè devo lavorarci sopra
	lw $t1, ($a0)	
	sw $t1, ($t0)	# TMP_C = COD[i]
	
	la $t2, PROP	# faccio una copia della mia proposta di codice perche' devo lavorarci sopra
	la $t0, TMP_P
	lw $t1, ($t2)
	sw $t1, ($t0)	# TMP_P = PROP

	la $t0, TMP_P	# tengo in memoria la posizione di TMP_P
	la $t1, TMP_C	# tengo in memoria la posizioen di TMP_C

	# controllo sulle X
	li $s1, 4 			# devo fare 4 giri
cc_loop_x:
	lb $t2, ($t0)			# leggo la iesima posizione di TMP_P
	lb $t3, ($t1)			# leggo la iesima posizione di TMP_C
	bne $t2, $t3, c_c_not_eq	# se non sono uguali prosegui alla prossima posizione o vado al controllo sulle O
	li $t2, -1			# falore per annullare la posizione
	sb $t2, ($t0)			# annullo la posizione su TMP_P
	sb $t2, ($t1)			# annullo la posizione su TMP_C
	addi $s0, $s0, 1		# incremento delle X trovate
c_c_not_eq:
	addi $t0, $t0,1			# prossima posizione di TMP_P
	addi $t1, $t1,1			# prossima posizione di TMP_C
	addi $s1, $s1, -1			# decremento del ciclo
	bgtz $s1, cc_loop_x 		# se devo ancora controllare posizioni continuo nel ciclo

	la $t0, X			# t0 = X 
	lb $t0, ($t0)

	beq $t0, $s0, c_c_controlla_O	# se il numero di X calcolate e quelle date coindide controlle le O altrimenti 
	li $t1, 0xffffffff		# annullo il codice
	sw $t1, ($a0)
	j c_c_esci			# esco dalla funzione

	#controllo sulle O
c_c_controlla_O:	
	li $s0, 0 	# sono le O
	la $t0, TMP_C	# mi tengo in memoria la posizione di TMP_C
	li $s1, 4	# devo fare 4 giri sul codice
cc_loop_o:
	lb $t2, ($t0)			# leggo la prima posizione del codice
	li $t3, -1			
	beq $t3, $t2, cc_continue_o	# se e' gia' stata annullata vado avanti alla prossima posizione
	la $t1, TMP_P			# altrimenti carico la posizione di TMP_P
	li $s2, 4			# devo fare altri 4 giri sul TMP_P
cc_loop_oo:
	lb $t3, ($t1)			# carico la posizione i-esima di TMP_P
	bne $t2,$t3,cc_continue_oo	# se TMP_C[i] != TMP_P[i] vado avanti alla prossima posizione di TMP_P
	addi $s0,$s0,1			# altrimenti annullo la posizione
	li $t3, -1
	sb $t3, ($t1)
	j cc_continue_o			# e vado alla prossima posizione di TMP_C
cc_continue_oo:	
	addi $t1, $t1, 1			# aumento posizione di TMP_P
	addi $s2, $s2, -1			# decremento loop interno
	bgtz $s2, cc_loop_oo		# salto del loop interno
cc_continue_o:	
	addi $t0, $t0, 1			# vado alla prossima posizione di TMP_C
	addi $s1, $s1, -1			# decremento loop
	bgtz $s1, cc_loop_o	    	# salto del loop esterno

	la $t0, O			# prendo quante O erano state inserite dall'utente
	lb $t0, ($t0)

	beq $t0, $s0, c_c_esci		# confronto il numero delle O, se concisono esco
	li $t1, -1			# se e' diverso distruggo il codice
	sw $t1, ($a0)
	j c_c_esci			# esci
	### fine controllo sulle O
c_c_esci:	
	lw $s2, 12($sp)
	lw $s1, 8($sp)
	lw $s0, 4($sp)
	lw $fp, 0($sp)
	add $sp, $sp, 16
	jr $ra
	
### crea le permutazioni chiamando la funzione map con la funzione permutation
create_permutations:
	subu $sp, $sp , 8
	sw $ra, 4($sp)
	sw $fp, 0($sp)

	la $a0, COD		# carico indirizzo array su cui lavorare
	li $a1, 16380 		# carico il punto di partenza
	la $a2, permutation	# carico la funzione da chiamare
	li $a3, 4		# carico il decremento

	jal map			# faccio partire la map
	
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

	li $s0, 4		# s0 = 4
	div $a0, $s0		# a0/4 eliminare i due 0 finali nella posizione
	mflo $s1		# s1 = salvo la posizione al byte
	li $s0, 8		# s0 = 8
	
    li $t1,0    # indice del ciclo
p_loop:
	div $s1, $s0 		# lo = divisione , hi = resto
	mfhi $t0 		# t0 = resto ( e ci interessa per la posizione i-esima )
    add $t2, $a0, $t1
	sb $t0, 0($t2)  	# salvo i calori calcolati nella posizione indicata
	mflo $s1		# t1 = la parte restante su cui calcolare nuovamente il resto
	li $t2, 4       # devo arrivare alla posizione 3
    addi $t1, $t1, 1 # incremento del ciclo
    bne $t1, $t2, p_loop

	lw $fp, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	add $sp, $sp, 8
	jr $ra

####  map ( array, posizione da cui partire  , F(posizione in array), decremento ) ####
map: 
	subu $sp, $sp, 28
	sw $s4, 24($sp)
	sw $s3, 20($sp) 
	sw $s2, 16($sp)
	sw $s1, 12($sp)
	sw $s0, 8($sp) 
	sw $ra, 4($sp)
	sw $fp, 0($sp)

	move $s0, $a0		# carico nei registri gli argomenti. Devo fare una chiamata a funzione
	move $s1, $a1
	move $s2, $a2
	move $s4, $a3
m_loop:
	bltz $s1, m_end		# se sono arrivato ad una posizione negativa esci, ho finito
	add $s3, $s0, $s1 	# metto in s3 e' la posizione su cui lavorare
	move $a0, $s3		# e la metto come argomento per la funzione da chiamare
	jalr $s2		# chiamo la funzione
	subu $s1, $s1, $s4	# decremento del ciclo
	j m_loop		# ritorno al ciclo
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
# TODO fare che X e 0 siano valori di ritorno
read_input:
	subu $sp, $sp, 16
	sw $s2, 12($sp)
	sw $fp, 8($sp)
	sw $s0, 4($sp)
	sw $s1, 0($sp)
	
	li $s0, 0		# s0 sara' la X	
	li $s1, 0		# s1 sara' la O
	li $t0, 3		# devo fare 4 giri (3..0)
	li $t2, 'x'		# t2 = 'x' per il confronto con il carattere
	li $t3, 'o'		# t3 = 'o' per il confronto con il carattere
    la $s2, READ    # s2 = &READ
	
ri_loop:				
	add $t1, $s2, $t0	# t1 = &READ[offset]
	lb $t1, ($t1)		# t1 = READ[offset]
	
	bne $t1, $t2, ri_nox	# se t1 = 'x' incremento s0 (X)
	addi $s0, $s0, 1		
ri_nox:		
	bne $t1, $t3, ri_noo	# se t1 = 'o' incremento s1 (O)
	addi $s1, $s1, 1		
ri_noo:		
	addi $t0, $t0, -1		# diminuisco indice del ciclo
	bgez $t0, ri_loop	# controllo del ciclo

	sb $s0, X		# salvo X
	sb $s1, O		# salvo O

	lw $s2, 12($sp)
	lw $fp, 8($sp)
	lw $s0, 4($sp)
	lw $s1, 0($sp)
	addi $sp, $sp, 12
	jr $ra

#### print intro() ####
print_intro:	
	subu $sp, $sp, 4
	sw $fp, ($sp)
	li $v0, 4		# syscall per stampa stringa
	la $a0, INTRO		# spama stringa di introduzione
	syscall 		
	lw $fp, ($sp)
	addi $sp, $sp, 4
	jr $ra

#### take input(): salva in variabile grobale READ ####
take_input:
	subu $sp, $sp, 4
	sw $fp, ($sp)

	li $v0, 4		# syscall per stampa stringa
	la $a0, INS		# stampa stringa per dire di inserire risposta
	syscall			

	li $v0, 8		# syscall per lettura stringa
	la $a0, READ		# dove salvare la stringa
	li $a1, 5		# quanti carattere leggere
	syscall		
	
	li $v0, 11		# syscall per stampa di un carattere
	li $a0, '\n'		# stampo un acapo
	syscall

	lw $fp, ($sp)
	addi $sp, $sp, 4
	jr $ra
	
guess:
	subu $sp, $sp, 4
	sw $fp, 0($sp)

	la $t0, COD			# t0 = &COD[0]
	li $t1, -1			# t1 = -1 per vedere se i codici sono validi
guess_loop:	
	lb $t2, ($t0)			# t2 = COD[a]
	bne $t2, $t1, guess_trovato    	# se t2 (COD[a]) != -1 e' un codice valido
	addi $t0, $t0, 4			# incremento t0 per puntare alla posizione successiva di COD
	
	la $t3, COD			# t3 = &COD[0]
	addi $t3, $t3,16384			# t3 = &COD[0] + N_pos -> t3 sara l'ultima posizione dell'array
	sub $t3, $t3, $t0		# t3 = ultima posizione - posizione corrente
	bgtz $t3, guess_loop		# se sono ancora nel vettore continuo nella ricerva altrimenti errore

	li $v0, 4			# syscall stampa stringa
	la $a0, ERRORE			# stampa messaggio di errore
	syscall
	li $v0, 10			# uscita dal programma
	syscall

guess_trovato:
	li $v0, 4 			# syscall stampa
	la $a0, GUESS			# stampo messaggio di spampa del tentativo
	syscall

# TODO non PROP ma valore di ritorno

	la $t1, PROP			# t1 = &PROP[0]. in PROP salvo il tentativo
    lw $t2, ($t0)           # salvo il codice in PROP
    sw $t2, ($t1) 
	li $v0, 1			# syscall stampa numero
    li $t2, 3           # indice del ciclo
guess_trv_loop:
    add $t3, $t0, $t2       # calcolo la posizione nell'codice
	lb $a0, 0($t3)			# stampo la posizione i del codice
	syscall 
    addi $t2, $t2, -1
    bgez $t2, guess_trv_loop

	li $v0, 11			# syscall stampa carattere
	li $a0, '\n'			# stampo un acapo per chiarezza
	syscall

	lw $fp, 0($sp)
	add $sp, $sp, 4
	jr $ra

print_win:
	subu $sp, $sp, 4
	sw $fp, ($sp)
	li $v0, 4		# syscall per stampa stringa
	la $a0, VITT		# spama stringa di introduzione
	syscall 		
	lw $fp, ($sp)
	addi $sp, $sp, 4
	jr $ra

main:
	jal print_intro 	# stampa le scritte iniziali
	jal create_permutations # crea tutti i possibili codici segreti
main_loop:	
	jal guess 		# propone un codice segreto
	jal take_input		# legge l'input da tastiera
	jal read_input		# capisce quante X e O si sono inserite
	la $t0, X		# legge quante X ci sono
	lb $t0, ($t0)		# e salva il valore in t0
	li $t1, 4		# mette in t1 4 per il confronto
	beq $t0, $t1, win	# confronta t1 e t0 ( X == 4 ) e se la risposta e' vera ho vinto
	jal filter		# filtra i codici eliminando quelli che non possono essere soluzione
	j main_loop		# salta a main loop per fare un nuovo tentativo
win:	
	jal print_win 		# stampa il messaggio di vittoria
	li $v0, 10		# carico la syscall di chiusura
	syscall			# chiude il programma
