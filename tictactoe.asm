#Copyright (C) 2022 Antonio Amadeu Dall Agnor Rohr and Rafael Carneiro Pregardier - All Rights Reserved
 #You may use, distribute and modify this code under the terms of the MIT license.
 #Tic Tac Toe with a simple AI.

.macro for(%i, %to, %body)
    li %i, 0       
startLoop:
    beq %i, %to, endLoop    
    jal %body        
    addiu %i, %i, 1     
    j startLoop    
endLoop:
.end_macro

.macro printString(%label)
	li $v0, 4
	la $a0, %label
	syscall
.end_macro

.macro printInt(%x)
	li $v0, 1
	add $a0, %x, $zero
	syscall
.end_macro

.macro printChar(%x)
	li $v0, 11
	add $a0, %x, $zero
	syscall
.end_macro

.eqv        SERVICO_IMPRIME_INTEIRO     1
.eqv        SERVICO_IMPRIME_STRING      4
.eqv        SERVICO_IMPRIME_CARACTERE   11
.eqv        SERVICO_EXIT2               17
.eqv        SUCESSO                     0
.eqv        SERVICO_LEIA_INTEIRO    5
.eqv        CHAR_X 	88
.eqv 	CHAR_O   79
.eqv	       CHAR_ESPACO  32

.data 
tabuleiro: .space 9 #tabuleiro
parar: .word 0 #terminar o programa
jogadas: .word 0 #numero de jogadas
acabou: .word 0 #acabou o current game
posicao: .word 0 #posicao que o jogador ira jogar

empate: .asciiz "EMPATE! \n"
vitoria_do_computador: .asciiz "O COMPUTADOR VENCEU! \n"
vitoria_do_jogador: .asciiz "VOCE VENCEU! \n"
jogar_novamente: .asciiz "Deseja jogar novamente? (1 - SIM / 0 - NAO): "
nova_linha: .asciiz "\n"
print_vez_do_computador: .asciiz "VEZ DO COMPUTADOR \n"
computador_jogando: .asciiz "COMPUTADOR JOGANDO...\n"
posicao_que_quer_jogar: .asciiz "Digite a posicao que deseja jogar: "
primeira_linha_jdv: .asciiz " 0 | 1 | 2\n"
linha_de_desenho_jdv: .asciiz "---+---+---\n"
segunda_linha_jdv: .asciiz " 3 | 4 | 5\n"
terceira_linha_jdv: .asciiz " 6 | 7 | 8\n"
barra_reta: .asciiz "|"

.text
init:
	jal		main #essa parte nao ta pronta, porque eu nao tinha todas as funcoes prontas, ai deixei por ultimo essa parte da main
finit:

main:
	lw 		$t0, jogadas
	li 		$t0, 0
	sb		$t0, jogadas
	lw 		$t1, acabou
	li 		$t1, 0
	sb		$t1, acabou
	lw 		$t2, parar
	li 		$t2, 0
	sb 		$s2, parar
	
	j inicializarTabuleiro #chama a funcao pra preencher o tabuleiro todo com 0
	
while_inicio:
	j while_testa_condicao
	
while_codigo: #basicamente, a "main".
	jal 		tabuleiroPrint #printar o tabuleiro
	jal 		printar_posicoes #vez do player
	jal 		verificar_empate #se empatou, dar um j para o fim do programa e printar a mensagem de empate e o tabuleiro final	
	jal		verificar_vitoria #se o pc ganhou, dar um j para o fim do programa e printar a mensagem de vitoria do pc e o tabuleiro final
	jal 		tabuleiroPrint #sempre printar o tabuleiro a cada jogada
	jal 		vez_do_computador #vez do pc
	jal 		verificar_vitoria #se o jogador ganhou, dar um j para o fim do programa e printar a mensagem de vitoria do jogador e o tabuleiro final
	j  		while_inicio #faz o while começar de novo

while_testa_condicao:
	sw 		$s0, acabou #guardar o valor da variavel acabou
	li 		$t1 1 #guardar 1 parar comparacao
	bne		$s0,  $t1, while_codigo #se a condicao for falsa, desvia para a "main"
	j 		endtudo #se for verdadeira, desvia para o do while para jogar de novo
	
verificar_empate:
	lw 		$t1, jogadas #carrega o valor da variavel jogadas
	li 		$t2, 9 #carrega o valor 9
	beq		$t1, $t2, printar_empate      #se jogadas for igual a 9 vai para a funcao printar empate
	
	jr 		$ra #se nao for 9, volta para a funcao que chamou
		  
printar_empate:
	printString(empate)

	j 		endtudo	  #vai para o fim do programa

verificar_linhas:
	li 		$t1, 0 #indice 1
	li 		$t2, 1 #indice 2
	li		$t3, 2 #indice 3
	li 		$t7, 9 #tamanho array
	li 		$s1, 0
	
while_linhas:
	bge 		$t3, $t7, verificar_colunas #sair do loop
	lb 		$t4, tabuleiro($t1) # carrega primeiro valor do tabuleiro
	lb 		$t5, tabuleiro($t2) # carrega segundo valor do tabuleiro
	lb 		$t6, tabuleiro($t3) # carrega terceiro valor do tabuleiro
	beq 		$t4, $t5, comparar_linhas #se os dois forem iguais vai pra outra funçao de comparar
	
adicionar_linhas:
	addiu 	$t1, $t1, 3 #soma o indice em 3 pra ir pra proxima linha
	addiu	$t2, $t2, 3 #soma o indice em 3 pra ir pra proxima linha
	addiu 	$t3, $t3, 3 #soma o indice em 3 pra ir pra proxima linha
	
	j 		while_linhas #recomeça o loop
	
comparar_linhas:
	beq 		$t4, $s1, adicionar_linhas
	beq		$t5, $s1, adicionar_linhas
	beq 		$t6, $s1, adicionar_linhas
	beq 		$t4, $t6, acabar #se o primeiro for igual ao terceiro elemento da linha acaba o jogo
	addiu 	$t1, $t1, 3 #soma o indice em 3 pra ir pra proxima linha
	addiu 	$t2, $t2, 3 #soma o indice em 3 pra ir pra proxima linha
	addiu 	$t3, $t3, 3 #soma o indice em 3 pra ir pra proxima linha
	
	j		while_linhas #recomeça o loop
	
acabar:
	beq 		$t4, -1, vitoria_humano #se for igual a 1 jogador ganhou
	beq 		$t4, 1, vitoria_maquina #se for igual a -1 computador ganhou
	
vitoria_humano:
	jal 		tabuleiroPrint
	j 		printar_vitoria_jogador #pula para funçao de vitoria do jogador
	
vitoria_maquina:
	jal 		tabuleiroPrint
	j 		printar_vitoria_computador #pula para funçao de vitoria do computador
	
verificar_colunas:
	li 		$t1, 0 #indice 1
	li		$t2, 3 #indice 2
	li 		$t3, 6 #indice 3
	li 		$t7, 9 #tamanho array
	li 		$s1, 0
	
while_colunas:
	bge 		$t3, $t7, verificar_diagonal_principal #sair do loop
	lb 		$t4, tabuleiro($t1) # carrega primeiro valor do tabuleiro
	lb 		$t5, tabuleiro($t2) # carrega segundo valor do tabuleiro
	lb 		$t6, tabuleiro($t3) # carrega terceiro valor do tabuleiro
	beq 		$t4, $t5, comparar_colunas #se os dois forem iguais vai pra outra funçao de comparar
	
adicionar_colunas:
	addiu 	$t1, $t1, 1 #soma o indice em 1 pra ir pra proxima coluna
	addiu 	$t2, $t2, 1 #soma o indice em 1 pra ir pra proxima coluna
	addiu 	$t3, $t3, 1 #soma o indice em 1 pra ir pra proxima coluna
	
	j 		while_colunas #recomeça o loop
		
comparar_colunas:
	beq 		$t4, $s1, adicionar_colunas
	beq 		$t5, $s1, adicionar_colunas
	beq 		$t6, $s1, adicionar_colunas
	beq 		$t4, $t6, acabar #se o primeiro for igual ao terceiro elemento da linha acaba o jogo
	addiu 	$t1, $t1, 1 #soma o indice em 1 pra ir pra proxima coluna
	addiu 	$t2, $t2, 1 #soma o indice em 1 pra ir pra proxima coluna
	addiu 	$t3, $t3, 1 #soma o indice em 1 pra ir pra proxima coluna
	j 		while_colunas #recomeça o loop
		
verificar_diagonal_principal:
	li 		$s2, 0 #indice 1
	li 		$s3, 4 #indice 2
	li 		$s4, 8 #indice 3
	li 		$s1, 0
	lb		$t4, tabuleiro($s2) # carrega primeiro valor do tabuleiro
	lb 		$t5, tabuleiro($s3) # carrega segundo valor do tabuleiro
	lb 		$t6, tabuleiro($s4) # carrega terceiro valor do tabuleiro
	beq		$t4, $s1, verificar_diagonal_secundaria
	beq 		$t5, $s1, verificar_diagonal_secundaria
	beq 		$t6, $s1, verificar_diagonal_secundaria
	bne 		$t4, $t5, verificar_diagonal_secundaria #se os dois nao forem iguais vai pra funcao de retorno
	bne 		$t4, $t6, verificar_diagonal_secundaria #se o primeiro nao for igual ao terceiro elemento vai para fuincao de retorno
	
	j 		acabar

verificar_diagonal_secundaria:
	li 		$s2, 2 #indice 1
	li 		$s3, 4 #indice 2
	li 		$s4, 6 #indice 3
	li 		$s1, 0
	lb 		$t4, tabuleiro($s2) # carrega primeiro valor do tabuleiro
	lb 		$t5, tabuleiro($s3) # carrega segundo valor do tabuleiro
	lb 		$t6, tabuleiro($s4) # carrega terceiro valor do tabuleiro
	beq 		$t4, $s1, sair
	beq 		$t5, $s1, sair
	beq 		$t6, $s1, sair
	bne 		$t4, $t5, sair #se os dois nao forem iguais vai pra funcao de retorno
	bne 		$t4, $t6, sair #se o primeiro nao for igual ao terceiro elemento vai para fuincao de retorno
	
	j 		acabar

sair:
	jr 		$ra

verificar_vitoria:
	j 		verificar_linhas 
	
printar_posicoes: #apenas printa as posicoes para o jogador jogar
	printString(nova_linha)
 	printString(primeira_linha_jdv)
        printString(linha_de_desenho_jdv)
	printString(segunda_linha_jdv)
        printString(linha_de_desenho_jdv)
     	printString(terceira_linha_jdv)
     	
vez_do_jogador:        
	printString(posicao_que_quer_jogar)

	 li      	$v0, SERVICO_LEIA_INTEIRO # lendo um inteiro da posicao onde sera jogado 
         syscall                     
      
         move 	$s1, $v0  #mover a leitura para a variavel posicao
         la   		$t0, posicao    # $t0 <- endereÃ§o da variavel posicao
         sw    	$s1, 0($t0)       # guardar a posicao lida
         
         lw 		$t0, posicao
         li 		$t1, 0
         li 		$t2, 8
         blt 		$t0, $t1, vez_do_jogador
         bgt 		$t0, $t2, vez_do_jogador
         
        printString(nova_linha)
         
         li 		$t1, -1 #carregamos -1, o que corresponde a X
        
         lw 		$t0, posicao #carrega a variavel posicao
         lb 		$t4, tabuleiro($t0)
         bne 	$t4, $zero, vez_do_jogador
         
         sb 		$t1, tabuleiro($t0) #coloca no tabuleiro[posicao] a bolinha O
         
         lw 		$t2, jogadas #carrega a variavel jogadas
         addiu 	$t2, $t2, 1 #soma uma jogada as jogadas ja feitas
	 sb 		$t2, jogadas
	 	
         jr 		$ra
          
vez_do_computador:
	printString(nova_linha)
	
	la 		$a0, print_vez_do_computador
	syscall #imprime vez do computador
	
	la 		$a0, computador_jogando
	syscall #imprime computador jogando
	
	lw 		$t0, jogadas
	li 		$t1, 1
	beq 		$t0, $t1, primeira_jogada
	
	j 		counter_jogadas1

jogada_random:
	li 		$v0, 42  # 42 is system call code to generate random int
	li 		$a1, 9 # $a1 is where you set the upper bound
	syscall     # your generated number will be at $a0

	move 	$t2, $a0
	
	lb 		$t3, tabuleiro($t2) #coloca no tabuleiro[posicao] a bolinha O
	bne 		$t3, $zero, jogada_random
	li 		$t3, 1
	sb 		$t3, tabuleiro($t2) #coloca no tabuleiro[posicao] a bolinha O

	j 		acabou_jogada
		
primeira_jogada:
	li 		$t1, 4
	lb 		$t2, tabuleiro($t1)
	bne 		$t2, $zero, jogada_random
	li 		$t2, 1
	sb 		$t2, tabuleiro($t1)
	
acabou_jogada:
	 lw 		$t0, jogadas #carrega a variavel jogadas
         addiu 	$t0, $t0, 1 #soma uma jogada as jogadas ja feitas
	 sb 		$t0, jogadas
         jr 		$ra
	
counter_jogadas1:
	li 		$t0, 0 #indice 1
	li 		$t1, 1 #indice 2
	li 		$t2, 2 #indice 3
	li 		$t7, 9 #tamanho array
	
	j 		carregar_valores
	
counter_jogadas4:
    	li 		$t0, 0 #indice 1
    	li 		$t1, 3 #indice 2
    	li 		$t2, 6 #indice 3
    	li 		$t7, 9 #tamanho array
    	
    	j 		carregar_valores_colunas

carregar_valores:
	bge 		$t2, $t7, counter_jogadas4 #sair do loop
	lb 		$t3, tabuleiro($t0) # carrega primeiro valor do tabuleiro
	lb 		$t4, tabuleiro($t1) # carrega segundo valor do tabuleiro
	lb 		$t5, tabuleiro($t2) # carrega terceiro valor do tabuleiro
	
	beq 		$t3, $t4, verificar_counter1
	beq 		$t3, $t5, verificar_counter2
	beq 		$t4, $t5, verificar_counter3
	
	j 		counter_jogadas4
	
verificar_counter1:
	beq 		$t3, $zero, adicionar_linhas_pc
	bne 		$t5, $zero, adicionar_linhas_pc
	
	li 		$t5, 1
	sb 		$t5, tabuleiro($t2)
	
	j 		acabou_jogada

verificar_counter2:
	beq		$t3, $zero, adicionar_linhas_pc
	bne 		$t4, $zero, adicionar_linhas_pc
	
	li 		$t4, 1
	sb 		$t4, tabuleiro($t1)
	
	j 		acabou_jogada
	
verificar_counter3:
    	beq    	$t4, $zero, adicionar_linhas_pc
   	bne    	$t3, $zero, adicionar_linhas_pc

    	li 		$t3, 1
    	sb 		$t3, tabuleiro($t0)

    	j 		acabou_jogada

adicionar_linhas_pc:
        addiu 	$t0, $t0, 3 #soma o indice em 3 pra ir pra proxima linha
        addiu 	$t1 $t1, 3 #soma o indice em 3 pra ir pra proxima linha
        addiu 	$t2, $t2, 3 #soma o indice em 3 pra ir pra proxima linha
        
        j 		carregar_valores

carregar_valores_colunas:
    	bge 		$t2, $t7, carregar_valores_diagonal_principal #sair do loop
    	lb 		$t3, tabuleiro($t0) # carrega primeiro valor do tabuleiro
    	lb 		$t4, tabuleiro($t1) # carrega segundo valor do tabuleiro
    	lb 		$t5, tabuleiro($t2) # carrega terceiro valor do tabuleiro

    	beq 		$t3, $t4, verificar_counter4
    	beq 		$t3, $t5, verificar_counter5
    	beq 		$t4, $t5, verificar_counter6

    	j 		adicionar_colunas_pc

verificar_counter4:
    	beq 		$t3, $zero, adicionar_colunas_pc
    	bne 		$t5, $zero, adicionar_colunas_pc

    	li 		$t5, 1
    	sb 		$t5, tabuleiro($t2)

    	j 		acabou_jogada
    
carregar_valores_diagonal_principal:
	li 		$t0, 0
	li 		$t1, 4
	li 		$t2, 8
	lb 		$t3, tabuleiro($t0)
	lb 		$t4, tabuleiro($t1)
	lb 		$t5, tabuleiro($t2)
	beq 		$t3, $t4, verificar_counter7
	beq 		$t3, $t5, verificar_counter8
	beq 		$t4, $t5, verificar_counter9
	
	j 		carregar_valores_diagonal_secundaria
	
verificar_counter7:
	beq 		$t3, $zero, carregar_valores_diagonal_secundaria
    	bne		$t5, $zero, carregar_valores_diagonal_secundaria
	li 		$t5, 1
	sb 		$t5, tabuleiro($t2)
	
	j 		acabou_jogada
	
verificar_counter8:
	beq 		$t3, $zero, carregar_valores_diagonal_secundaria
    	bne 		$t4, $zero, carregar_valores_diagonal_secundaria
	li 		$t4, 1
	sb		$t4, tabuleiro($t1)
	
	j 		acabou_jogada

verificar_counter9:
	beq 		$t4, $zero, carregar_valores_diagonal_secundaria
    	bne 		$t3, $zero, carregar_valores_diagonal_secundaria
	li 		$t3, 1
	sb 		$t3, tabuleiro($t0)
	
	j 		acabou_jogada

carregar_valores_diagonal_secundaria:
	li 		$t0, 2
	li 		$t1, 4
	li 		$t2, 6
	lb 		$t3, tabuleiro($t0)
	lb 		$t4, tabuleiro($t1)
	lb 		$t5, tabuleiro($t2)
	beq 		$t3, $t4, verificar_counter10
	beq 		$t3, $t5, verificar_counter11
	beq 		$t4, $t5, verificar_counter12
	
	j 		jogada_random
	
verificar_counter10:
	beq 		$t3, $zero, jogada_random
    	bne 		$t5, $zero, jogada_random
	li 		$t5, 1
	sb		$t5, tabuleiro($t2)
	
	j 		acabou_jogada
	
verificar_counter11:
	beq 		$t3, $zero, jogada_random
    	bne 		$t4, $zero, jogada_random
	li 		$t4, 1
	sb 		$t4, tabuleiro($t1)
	
	j 		acabou_jogada

verificar_counter12:
	beq		$t4, $zero, jogada_random
    	bne 		$t3, $zero, jogada_random
	li 		$t3, 1
	sb 		$t3, tabuleiro($t0)
	
	j 		acabou_jogada

verificar_counter5:
    	beq    	$t3, $zero, adicionar_colunas_pc
    	bne 		$t4, $zero, adicionar_colunas_pc

    	li 		$t4, 1
    	sb 		$t4, tabuleiro($t1)

   	 j 		acabou_jogada

verificar_counter6:
    	beq   	$t4, $zero, adicionar_colunas_pc
    	bne 		$t3, $zero, adicionar_colunas_pc

    	li 		$t3, 1
    	sb 		$t3, tabuleiro($t0)

    	j 		acabou_jogada

adicionar_colunas_pc:
	addiu 	$t0, $t0, 1 #soma o indice em 3 pra ir pra proxima linha
        addiu 	$t1, $t1, 1 #soma o indice em 3 pra ir pra proxima linha
        addiu 	$t2, $t2, 1 #soma o indice em 3 pra ir pra proxima linha
        
        j 		carregar_valores_colunas

printar_vitoria_computador:
 	printString(vitoria_do_computador)         # imprimimos a string
 	
        j 		endtudo

printar_vitoria_jogador:
 	printString(vitoria_do_jogador)
 	
        j 		endtudo
        
inicializarTabuleiro: #inicializa o tabuleiro
	for($t0, 9, preencher_tabuleiro) #um for feito com macro
	
	j	 	while_inicio
        
tabuleiroPrint: #apenas o print do tabuleiro com o que tem dentro, isso foi dificil de fazer, nao sei explicar, mas funciona
	j 		while_print_inicio
	
while_print_inicio:
    	li 		$t0, 0
    
while_codigo_print:
    	li 		$t1, CHAR_ESPACO
    printChar($t1)
    
    	lb 		$t2, tabuleiro($t0)
    	bne 		$t2, $zero, else_if
    	printChar($t1)
    	j 		resto
    
else_if:
   	li 		$t3, 1
    	bne 		$t2, $t3, else
    	li 		$t4, CHAR_O
    	printChar($t4)
    	
   	 j resto
    
else:
   	li 		$t5, CHAR_X
   	printChar($t5)
   
resto:
  	printChar($t1)
  
  	li 		$t6, 2
  	li 		$t7, 5
  	li 		$t1, 8
  	beq 		$t0, $t6, nova_line
  	beq 		$t0, $t7, nova_line
  	beq 		$t0, $t1, fim_print
  
  	printString(barra_reta)
 	 j 		while_incrementa
  
 nova_line:
  	printString(nova_linha)
  	printString(linha_de_desenho_jdv)
  	j 		while_incrementa
  
while_incrementa:
  	addi 	$t0, $t0, 1
 	 j 		while_codigo_print
  
fim_print:
  	printString(nova_linha)
  	
  	jr 		$ra

preencher_tabuleiro: #o corpo da funcao do for 
     	li 		$t1, 0
     	sb 		$t1, tabuleiro($t0)
     	
     	jr 		$ra	
     
endtudo: #acabou
    	jal    		tabuleiroPrint
     	printString(jogar_novamente)
        
        li      		$v0, SERVICO_LEIA_INTEIRO # lendo um inteiro da posicao onde sera jogado 
        syscall                     
      
         move 	$t0, $v0  #mover a leitura 
         li 		$t1, 1
         bgt 		$t0, $t1, endtudo
         blt 		$t0, $zero, endtudo
         beq 	$t0, $t1, main
         
         li          	$a0, 0                  # retornamo o valor 0: programa executado com sucesso
         li          	$v0, 17                 # serviÃ§o 17, termina o programa
         syscall
