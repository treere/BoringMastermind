        .data
INTRO:  .asciiz "Benvenuti nel noioso gioco del master mind al contrario\n"
INS:    .asciiz "Inserire una stringa\n"
ERRORE: .asciiz "E' stata certamente inserita una risposta errata\n"
VITT:   .asciiz "E anche questa volta ti ho battuto\n"  
GUESS:  .asciiz "Tentativo: "
        .align 2
COD:    .space 16384 # 8 * 8 * 8 * 8 * 4byte

        .text
########################################################################
#                                                                      #
# map( array, pos, F, arg* )                                           #
#                                                                      #
# array = array su cui lavorare                                        #
# pos = posizione da cui partire da cui scendere fino a zero           #
# F(a1,a2,a3) = funzione da applicare ad ogni posizione dell'array     #
# arg* = indirizzo di memoria in cui sono presenti i 3 argomenti per F #
#                                                                      #
########################################################################

map: 
        subu $sp, $sp, 24       # alloco spazio sullo stack e salvo i registri che andro' a modificare
        sw $ra, 4($sp)
        sw $fp, 0($sp)
        sw $s3, 20($sp) 
        sw $s2, 16($sp)
        sw $s1, 12($sp)
        sw $s0, 8($sp) 

        move $s0, $a0           # salvo gli argomenti passati
        move $s1, $a1
        move $s2, $a2
        move $s3, $a3
m_loop:
        bltz $s1, m_end         # se sono in una posizione negativa esco. 
        add $a0, $s0, $s1       # a0 = COD& + offset
        lw $a1, 0($s3)          # argomenti per F
        lw $a2, 4($s3)
        lw $a3, 8($s3)
        jalr $s2                # chiamo F
        subu $s1, $s1, 4        # decremento del ciclo
        j m_loop                # ritorno al ciclo
m_end:  
        lw $s3, 20($sp)         # ripristino i registri
        lw $s2, 16($sp)
        lw $s1, 12($sp)
        lw $s0, 8($sp)
        lw $ra, 4($sp)
        lw $fp, 0($sp)
        addi $sp, $sp, 24       # ripristino lo stack
        jr $ra                  # return
        
#####################################################################
#                                                                   #
# filter ( codice_proposto, x , o ) -> ()                           #
#                                                                   #
# lavora sull'array COD e ne annulla le posizioni in cui il codice  #
# presente, se fosse il codice segreto,                             #
# non darebbe il risultato introdotto dall'utente.                  #
#                                                                   #
#####################################################################

filter:
        subu $sp, $sp, 20       # alloco spazio sullo stack e salvo i registri che andro' a modificare
        sw $ra, 16($sp)         
        sw $fp, 12($sp)         
        sw $a2, 8($sp)          # salvo i parametri stack per la map
        sw $a1, 4($sp)          
        sw $a0, ($sp)           

        la $a0, COD             # carico l'array da elaborare
        li $a1, 16380           # carico da dove partire
        la $a2, compare_codes   # carico la funzione da usare
        la $a3, ($sp)           # posizione dello stack con il primo argomento per la funzione

        jal map                 # chiamo map
        
        lw $fp, 12($sp)         # ripristino i registri 
        lw $ra, 16($sp)
        add $sp, $sp, 20        # ripristino lo stack
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
        beq $t0, $t1, c_c_esci          # se sono in un codice gia' eliminato finisco subito senza fare altro

        li $s0, 0                       # sono le X
        sw $t1, 16($sp)                 # TMP_C = COD[i] : copio perche' devo lavorarci sopra
        
        sw $a1, 20($sp)                 # sposto il codice proposto nello stack per lavorare sui byte

        la $t0, 20($sp)                 # tengo in memoria la posizione di TMP_P
        la $t1, 16($sp)                 # tengo in memoria la posizioen di TMP_C

        # controllo sulle X
        li $s1, 4                       # devo fare 4 giri
cc_loop_x:
        lb $t2, ($t0)                   # leggo la iesima posizione di TMP_P
        lb $t3, ($t1)                   # leggo la iesima posizione di TMP_C
        bne $t2, $t3, c_c_not_eq        # se non sono uguali prosegui alla prossima posizione o vado al controllo sulle O
        li $t2, -1                      # falore per annullare la posizione
        sb $t2, ($t0)                   # annullo la posizione su TMP_P
        sb $t2, ($t1)                   # annullo la posizione su TMP_C
        addi $s0, $s0, 1                # incremento delle X trovate
c_c_not_eq:
        addi $t0, $t0,1                 # prossima posizione di TMP_P
        addi $t1, $t1,1                 # prossima posizione di TMP_C
        addi $s1, $s1, -1                       # decremento del ciclo
        bgtz $s1, cc_loop_x             # se devo ancora controllare posizioni continuo nel ciclo

        beq $a2, $s0, c_c_controlla_O   # se il numero di X calcolate e quelle date coindide controlle le O altrimenti 
        li $t1, 0xffffffff              # annullo il codice
        sw $t1, ($a0)
        j c_c_esci                      # esco dalla funzione

        #controllo sulle O
c_c_controlla_O:        
        li $s0, 0       # sono le O
        la $t0, 16($sp) # mi tengo in memoria la posizione di TMP_C
        li $s1, 4       # devo fare 4 giri sul codice
cc_loop_o:
        lb $t2, ($t0)                   # leggo la prima posizione del codice
        li $t3, -1                      
        beq $t3, $t2, cc_continue_o     # se e' gia' stata annullata vado avanti alla prossima posizione
        la $t1, 20($sp)                 # altrimenti carico la posizione di TMP_P
        li $s2, 4                       # devo fare altri 4 giri sul TMP_P
cc_loop_oo:
        lb $t3, ($t1)                   # carico la posizione i-esima di TMP_P
        bne $t2,$t3,cc_continue_oo      # se TMP_C[i] != TMP_P[i] vado avanti alla prossima posizione di TMP_P
        addi $s0,$s0,1                  # altrimenti annullo la posizione
        li $t3, -1
        sb $t3, ($t1)
        j cc_continue_o                 # e vado alla prossima posizione di TMP_C
cc_continue_oo: 
        addi $t1, $t1, 1                        # aumento posizione di TMP_P
        addi $s2, $s2, -1                       # decremento loop interno
        bgtz $s2, cc_loop_oo            # salto del loop interno
cc_continue_o:  
        addi $t0, $t0, 1                        # vado alla prossima posizione di TMP_C
        addi $s1, $s1, -1                       # decremento loop
        bgtz $s1, cc_loop_o             # salto del loop esterno

        beq $a3, $s0, c_c_esci          # confronto il numero delle O, se concisono esco
        li $t1, -1                      # se e' diverso distruggo il codice
        sw $t1, ($a0)
        j c_c_esci                      # esci
        ### fine controllo sulle O
c_c_esci:       
        lw $s2, 12($sp)
        lw $s1, 8($sp)
        lw $s0, 4($sp)
        lw $fp, 0($sp)
        add $sp, $sp, 24
        jr $ra

#####################################################################
#                                                                   #
# create_permutation () -> ()                                       #
#                                                                   #
# lavora sull'array COD e modifica ogni posizione                   #
# caricandoci il corrispondente codice segreto                      #
#                                                                   #
#####################################################################
        
create_permutations:
        subu $sp, $sp , 20      # alloco spazio sullo stack e salvo i registri che andro' a modificare
        sw $ra, 4($sp)
        sw $fp, 0($sp)

        la $a0, COD             # carico l'array da elaborare
        li $a1, 16380           # carico da dove partire 
        la $a2, permutation     # carico la funzione da usare
        la $a3, 8($sp)          # posizione dello stack con il primo argomento per la funzione

        jal map                 # chiamo map
        
        lw $fp, 0($sp)          # ripristino i registri
        lw $ra, 4($sp)
        add $sp, $sp, 20        # ripristino lo stack
        jr $ra                  # return

# permutation(index) -> ()
# COD[INDEX] =
#     I = INTEX / 4
#     I >> 0 % 8 || I >> 8 % 8 || I >> 16 % 8 || I >> 24 % 8

permutation:
        subu $sp, $sp, 4        # alloco spazio sullo stack e salvo i registri che andro' a modificare
        sw $fp, 0($sp)

        li $t3, 4               # t3 = 4
        div $a0, $t3            
        mflo $t4                # t4 = INDEX / 4, erano tutte posizioni multiple di 4 ( non di 8 )
        li $t3, 8               # t3 = 8 per la division
        li $t5, 4               # t5 = 4 per il controllo del ciclo

        li $t1,0                # indice del ciclo
p_loop:
        div $t4, $t3            # lo = divisione , hi = resto
        mfhi $t0                # t0 = t4 % 8
        add $t2, $a0, $t1       # t2 = &COD[INDEX][POS] carico indirizzo dove salvare il resto
        sb $t0, ($t2)           # t2 = t0               salvo il resto
        mflo $t4                # t4 = t4 / 8
        addi $t1, $t1, 1        # t1++
        bne $t1, $t5, p_loop    # se t1 != t5 loop

        lw $fp, 0($sp)          # ripristino i registri
        addi $sp, $sp, 4        # ripristino lo stack
        jr $ra                  # return

###################################################
#                                                 #
# take_input () -> v0 = X , v1 = O                #
#                                                 #
# legge l'input da tastiera e restutuisce         #
# quante X e quante O erano contenute nel codice  #
#                                                 #
###################################################

take_input:
        subu $sp, $sp, 28       # alloco spazio sullo stack e salvo i registri che andro' a modificare
        sw $ra, 4($sp)          # salvo i registri
        sw $fp, 0($sp)

        li $v0, 4               # syscall per stampa stringa
        la $a0, INS             # stampa stringa per dire di inserire risposta
        syscall                 

        li $v0, 8               # syscall per lettura stringa
        la $a0, 8($sp)          # salvo la stringa sullo stack
        li $a1, 5               # leggendo 5 caratteri ( un e' \0 )
        syscall         
        
        li $v0, 11              # syscall per stampa di un carattere
        li $a0, '\n'            # stampo un acapo
        syscall

        la $a0, 8($sp)          # carico come argomento i'indirizzo di quanto letto
        jal read_input          # chiamo la funzione read_input

        lw $fp, 0($sp)          # ripristino i registri
        lw $ra, 4($sp)          
        addi $sp, $sp, 28       # rispristino lo stack
        jr $ra                  # return , v0 e v1 sono stati impostati da read_input
        
# read_input(pos_stringa_letta) -> numero_X numero_O
read_input:
        subu $sp, $sp, 4        # sposto testa stack e salvo i registri
        sw $fp, ($sp)
        
        li $t5, 0               # t5 rappresenta le X   
        li $t6, 0               # t6 rappresenta le O
        li $t0, 3               # devo fare 4 giri (3..0)
        li $t2, 'x'             # t2 = 'x' per il confronto con il carattere
        li $t3, 'o'             # t3 = 'o' per il confronto con il carattere
        move $t4, $a0           # t4 = &READ
        
ri_loop:                                
        add $t1, $t4, $t0       # t1 = &READ[offset]
        lb $t1, ($t1)           # t1 = READ[offset]
        
        bne $t1, $t2, ri_nox    # se t1 = 'x' incremento s0 (X)
        addi $t5, $t5, 1
        j ri_noo                # salto alla fine del ciclo
ri_nox:         
        bne $t1, $t3, ri_noo    # se t1 = 'o' incremento s1 (O)
        addi $t6, $t6, 1                
ri_noo:         
        addi $t0, $t0, -1       # diminuisco indice del ciclo
        bgez $t0, ri_loop       # controllo del ciclo

        move $v0, $t5           # ritorno X
        move $v1 $t6            # ritorno O

        lw $fp, ($sp)           # rispristino registri
        addi $sp, $sp, 4        # rispristino testa stack
        jr $ra                  # return

############################################################
#                                                          #
# guess ( posizione_codice_usato ) -> nuovo_tentativo      #
#                                                          #
# L'ultimo tentativo fatto serve per generare              #
# della casualità della scelta della stringa da sottoporre #
#                                                          #
############################################################
        
guess:
        subu $sp, $sp, 16       # sposto la testa dello stack e salvo i registri che saranno modificati
        sw $ra, 8($sp)
        sw $s0, 4($sp)
        sw $fp, 0($sp)
        sw $s1, 12($sp)

        jal find_prop           # cerco il nuovo codice da proporre
        move $s0, $v0           # salvo i valori di return
        move $s1, $v1
        
        move $a0, $s0           # preparo codice trovato per la stampa
        jal print_code          # stampo il codice trovato

        move $v0, $s0           # return del codice trovato
        move $v1, $s1           # return della posizione del codice

        lw $s1, 12($sp)
        lw $ra, 8($sp)          # ripristino i registri
        lw $s0, 4($sp)  
        lw $fp, 0($sp)
        addi $sp, $sp, 16       # ripristino lo stack
        jr $ra                  # return 

# find_prop(posizione_codice_precedente ) ->
#               v0 = codice proposto
#               v1 = indice del codice proposto
#
# Lavora su COD per trovare il codice 
find_prop:
        subu $sp, $sp, 8
        sw $ra, 4($sp)
        sw $fp, 0($sp)

        la $t0, COD
        subu $a1, $a0, $t0
        li $a0, 5
        jal RIC

        la $t0, COD                     # t0 = &COD[0]
        li $t1, -1                      # t1 = -1 per vedere se i codici sono validi
        li $t4, 16380
        li $t7, 16384
find_loop:      
        add $t6, $t4, $v0               # calcolo lo shift
        div $t6, $t7
        mfhi $t6
        add $t5, $t6, $t0
        lb $t2, ($t5)                   # t2 = COD[a]
        bne $t2, $t1, find      # se t2 (COD[a]) != -1 e' un codice valido
        addi $t4, $t4, -4                       # incremento t0 per puntare alla posizione successiva di COD
        
        bgez $t4, find_loop             # se sono ancora nel vettore continuo nella ricerca altrimenti errore

        li $v0, 4                       # syscall stampa stringa
        la $a0, ERRORE                  # stampa messaggio di errore
        syscall
        li $v0, 10                      # uscita dal programma
        syscall
find:
        lw $v0, ($t5)
        move $v1, $t5
        lw $fp, 0($sp)
        lw $ra, 4($sp)
        addi $sp, $sp, 8
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

# print_code(code) -> ()
#
# stampa il codice passato come argomento 
print_code:
        subu $sp, $sp, 8        # sposto testa stack e salvo fp
        sw $fp, 4($sp)
        sw $a0, ($sp)           # salvo a0 per poter accedere ai byte

        li $v0, 4               # syscall stampa stringa
        la $a0, GUESS           # carico indirizzo tringa del tentativo
        syscall                 # stampo

        li $v0, 1               # syscall stampa intero
        lb $a0, 3($sp)          # carico posizione 3
        syscall                 # stampo
        lb $a0, 2($sp)          # carico posizione 2
        syscall                 # stampo
        lb $a0, 1($sp)          # carico posizione 1
        syscall                 # stampo
        lb $a0, 0($sp)          # carico posizione 0
        syscall                 # stampo
        
        li $v0, 11              # syscall stampa carattere
        li $a0, '\n'            # carico un acapo 
        syscall                 # stampo a capo per maggiore chiarezza in output

        lw $fp, 4($sp)          # ripristino fp
        addi $sp, $sp, 8        # rispritino stack
        jr $ra                  # return 

#################
#               #
# main () -> () #
#               #                                    
#################
main:
        li $v0, 4               # syscall per stampa stringa
        la $a0, INTRO           # carico stringa di benvenuto
        syscall                 # stampo
        jal create_permutations # crea tutti i possibili codici segreti
        la $s1,COD              # il primo codice sarà la testa dell'array
        li $s2, 4               # per vedere se sono state inserite 4 X
main_loop:      
        move $a0, $s1           # carico indirizzo ultimo codice
        jal guess               # propone un codice segreto
        move $s0,$v0            # salvo il codice proposto
        move $s1, $v1           # salvo indirizzo codice proposto

        jal take_input          # leggo l'input. ritorna X e O

        beq $v0, $s2, win       # confronta v0 e s2 ( X == 4 ). se la risposta e' vera ho vinto

        move $a0, $s0           # carico argomenti per filter
        move $a1, $v0
        move $a2, $v1
        jal filter              # filtra i codici eliminando quelli che non possono essere soluzione
        j main_loop             # salta a main loop per fare un nuovo tentativo
win:    
        li $v0, 4               # syscall per stampa stringa
        la $a0, VITT            # carico stringa di vittoria
        syscall                 # stampo vittoria
        li $v0, 10              # carico la syscall di chiusura
        syscall                 # chiude il programma
