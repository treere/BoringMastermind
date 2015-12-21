	.data
INTRO:	.asciiz " Benvenuti nel noioso gioco del master mind al contrario\n"
INS:	.asciiz "Inserire una stringa\n"
ERRORE:	.asciiz "E' stata certamente inserita una risposta errata\n"
VITT: 	.asciiz "E anche questa volta ti ho battuto\n"	
GUESS:	.asciiz "Tentativo: "
	.align 2
COD:	.space 16384 # 8 * 8 * 8 * 8 * 4byte

	.text
### filtra(PROP,X,O) l'array cod. chiama la funzione map,  ###
# TODO mettere argomenti prima di fp e cambiare anche la map
filter:
	subu $sp, $sp, 20
	sw $a2, 16($sp)		# salvo sullo stack i valori passati
	sw $a1, 12($sp)		# poiche' saranno passati alla map
	sw $a0, 8($sp)		# sullo stack
	sw $ra, 4($sp)
	sw $fp, 0($sp)

	la $a0, COD		# carico l'array da elaborare
	li $a1, 16380 		# carico da dove partire
	la $a2, compare_codes	# carico la funzione da usare
	la $a3, 8($sp)		# posizione dello stack con il primo argomento per la funzione

	jal map			# faccio partire la map
	
	lw $fp, 0($sp)
	lw $ra, 4($sp)
	add $sp, $sp, 20
	jr $ra

# compare_codes(INDEX, PROP, X , O)
compare_codes:
	subu $sp, $sp, 24
	# 20 TMP_P
	# 16 TMP_C
	sw $s2, 12($sp)
	sw $s1, 8($sp)
	sw $s0, 4($sp)
	sw $fp, 0($sp)

	lw $t1, ($a0)	
	li $t0, -1
	beq $t0, $t1, c_c_esci # se sono in un codice gia' eliminato finisco subito senza fare altro

	li $s0, 0 	# sono le X
	sw $t1, 16($sp)	# TMP_C = COD[i] : copio perche' devo lavorarci sopra
	
	sw $a1, 20($sp)	# sposto il codice proposto nello stack per lavorare sui byte

	la $t0, 20($sp) # tengo in memoria la posizione di TMP_P
	la $t1, 16($sp) # tengo in memoria la posizioen di TMP_C

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

	beq $a2, $s0, c_c_controlla_O	# se il numero di X calcolate e quelle date coindide controlle le O altrimenti 
	li $t1, 0xffffffff		# annullo il codice
	sw $t1, ($a0)
	j c_c_esci			# esco dalla funzione

	#controllo sulle O
c_c_controlla_O:	
	li $s0, 0 	# sono le O
	la $t0, 16($sp) # mi tengo in memoria la posizione di TMP_C
	li $s1, 4	# devo fare 4 giri sul codice
cc_loop_o:
	lb $t2, ($t0)			# leggo la prima posizione del codice
	li $t3, -1			
	beq $t3, $t2, cc_continue_o	# se e' gia' stata annullata vado avanti alla prossima posizione
	la $t1, 20($sp)			# altrimenti carico la posizione di TMP_P
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

	beq $a3, $s0, c_c_esci		# confronto il numero delle O, se concisono esco
	li $t1, -1			# se e' diverso distruggo il codice
	sw $t1, ($a0)
	j c_c_esci			# esci
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
	subu $sp, $sp , 20	# alloco piu' spazio per i tre argomenti che permutation non prende per evitare errori
	sw $ra, 4($sp)
	sw $fp, 0($sp)

	la $a0, COD		# carico indirizzo array su cui lavorare
	li $a1, 16380 		# carico il punto di partenza
	la $a2, permutation	# carico la funzione da chiamare
	la $a3, 8($sp)		# metto l'indirizzo dove dovrebbero esserci gli indirizzi

	jal map			# faccio partire la map
	
	lw $fp, 0($sp)
	lw $ra, 4($sp)
	add $sp, $sp, 20
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

####  map ( array, posizione da cui partire  , F(posizione in array), luogo argomenti per F ) ####
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
	move $s3, $a3
m_loop:
	bltz $s1, m_end		# se sono arrivato ad una posizione negativa esci, ho finito
	add $s4, $s0, $s1 	# metto in s3 e' la posizione su cui lavorare
	move $a0, $s4		# e la metto come argomento per la funzione da chiamare
	lw $a1, 0($s3)
	lw $a2, 4($s3)
	lw $a3, 8($s3)
	jalr $s2		# chiamo la funzione
	subu $s1, $s1, 4	# decremento del ciclo
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

#### read_input(posizione dove leggere) #### salva l'input in X e O
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
	move $s2, $a0    	# s2 = &READ
	
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

	move $v0, $s0		# ritorno le X
	move $v1 $s1		# ritorno le O

	lw $s2, 12($sp)
	lw $fp, 8($sp)
	lw $s0, 4($sp)
	lw $s1, 0($sp)
	addi $sp, $sp, 16
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
	subu $sp, $sp, 28
	sw $ra, 4($sp)
	sw $fp, 0($sp)

	li $v0, 4		# syscall per stampa stringa
	la $a0, INS		# stampa stringa per dire di inserire risposta
	syscall			

	li $v0, 8		# syscall per lettura stringa
	la $a0, 8($sp)		# dove salvare la stringa
	li $a1, 5		# quanti carattere leggere
	syscall		
	
	li $v0, 11		# syscall per stampa di un carattere
	li $a0, '\n'		# stampo un acapo
	syscall

	la $a0, 8($sp)
	jal read_input

	lw $fp, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 28
	jr $ra
	
# guess() -> v0 = valore proposto. Usa COD
# TODO deve prendere un offset in input
find_prop:
	subu $sp, $sp, 4
	sw $fp, 0($sp)

	la $t0, COD			# t0 = &COD[0]
	li $t1, -1			# t1 = -1 per vedere se i codici sono validi
	li $t4, 16380
find_loop:	
	add $t5, $t4, $t0
	lb $t2, ($t5)			# t2 = COD[a]
	bne $t2, $t1, find    	# se t2 (COD[a]) != -1 e' un codice valido
	addi $t4, $t4, -4			# incremento t0 per puntare alla posizione successiva di COD
	
	bgez $t4, find_loop		# se sono ancora nel vettore continuo nella ricerca altrimenti errore

	li $v0, 4			# syscall stampa stringa
	la $a0, ERRORE			# stampa messaggio di errore
	syscall
	li $v0, 10			# uscita dal programma
	syscall
find:
	lw $v0, ($t5)
	lw $fp, 0($sp)
	addi $sp, $sp, 4
	jr $ra

print_code:
	subu $sp, $sp, 8
	sw $fp, 4($sp)
	sw $a0, ($sp)

	li $v0, 4 			# syscall stampa
	la $a0, GUESS			# stampo messaggio di spampa del tentativo
	syscall

	li $v0, 1
	lb $a0, 3($sp)
	syscall
	lb $a0, 2($sp)
	syscall
	lb $a0, 1($sp)
	syscall
	lb $a0, 0($sp)
	syscall
	
	li $v0, 11			# syscall stampa carattere
	li $a0, '\n'			# stampo un acapo per chiarezza
	syscall

	lw $fp, 4($sp)
	addi $sp, $sp, 8
	jr $ra

# aggiungere funzione per stampa codice
guess:
	subu $sp, $sp, 12
	sw $ra, 8($sp)
	sw $s0, 4($sp)
	sw $fp, 0($sp)

	jal find_prop
	move $s0, $v0

	move $a0, $s0
	jal print_code

	move $v0, $s0

	lw $ra, 8($sp)
	lw $s0, 4($sp)			# return del valore proposto
	lw $fp, 0($sp)
	addi $sp, $sp, 12
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

	move $s0,$v0		# salvo il codice proposto
	jal take_input		# leggo l'input. ritorna X e O

	li $t1, 4		# mette in t1 4 per il confronto
	beq $v0, $t1, win	# confronta t1 e t0 ( X == 4 ) e se la risposta e' vera ho vinto

	move $a0, $s0		# carico argomenti per filter
	move $a1, $v0
	move $a2, $v1
	jal filter		# filtra i codici eliminando quelli che non possono essere soluzione
	j main_loop		# salta a main loop per fare un nuovo tentativo
win:	
	jal print_win 		# stampa il messaggio di vittoria
	li $v0, 10		# carico la syscall di chiusura
	syscall			# chiude il programma
