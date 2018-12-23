.data
A: .space 256
B: .space 256
separador: .asciiz "\t" #tabulacion
separador2: .asciiz "\n" #salto de linea
separador3: .asciiz ","
separador4: .asciiz ":"
mensaje: "\tIntroduzca el elemento: "
.text
main:
	la $a0, A	#Guardamos direccion A
	la $a1, B	#Guardamos i
	li $a2, 5	#guardamos j
	jal funcionA
	jal funcionB
	jal Imprimir
	li $v0, 10
	syscall
	
funcionA:
	add $t0,$0,$0			#t0 -> j
	add $t1,$0,$0 			#t1 -> i
	add $t2,$a0,$0			#t2 -> puntero de la matriz en memoria
	
	bucle2:
		la $a0,mensaje
		li $v0,4
		syscall
	
		add $a0,$t1,$zero
		li $v0,1		#imprime i
		syscall
	
		la $a0,separador3	#imprime coma
		li $v0,4
		syscall
	
		add $a0,$t0,$zero
		li $v0,1		#imprime j
		syscall
		
		li $v0,4
		la $a0,separador4
		syscall
	
		li $v0,5		#pide entero
		syscall  
		
		mul $t3,$t1,$a2 #i x m
    		add $t3, $t3, $t0 #i x m + j

   		sll $t3, $t3, 2    # 4*(i x m + j)        
    
    		add $t3, $t3, $t2    #A + 4*(i x m + j)    A[i][j]
	
		sw $v0,0($t3)		#se guarda en la matriz
		
		addi $t0,$t0,1		#se incrementa j
		bne $t0, $a2, bucle2	#si ha terminado el nº de columnas se pasa a la fila siguiente
		add $t0,$0,$0
		addi $t1,$t1,1
		bne $t1,$a2,bucle2	#si no han terminado las filas se repite el bucle
	
	la $a0,separador2		#imprime salto de linea
	li $v0,4
	syscall
	
	jr $ra
	
		
	
	
	
	
calcula:	#en a0 la direccion del vector A.En a1 la direccion del vector B. En t0 i. En t1 j. En a2 size.

	mul $t2,$t0,$a2 #i x m
    	add $t2, $t2, $t1 #i x m + j

   	sll $t2, $t2, 2    # 4*(i x m + j)        
    
    	add $t2, $t2, $a0    #A + 4*(i x m + j)    A[i][j]
    	lw $t6,0($t2)
    
    	mul $t3,$t1,$a2 #j x m
    	add $t3, $t3, $t0 #j x m + i

    	sll $t3, $t3, 2    # 4*(j x m + i)        
    
    	add $t3, $t3, $a0    #A + 4*(j x m + i)    A[j][i]
   	lw $t7,0($t3)
    
    	sub $t6, $t6, $t7
    
    	mul $t4,$t0,$a2 #i x m
    	add $t4, $t4, $t1 #i x m + j

    	sll $t4, $t4, 2    # 4*(i x m + j)        
    
    	add $t4, $t4, $a1    #B + 4*(i x m + j)    B[i][j]
    
   	sw $t6, 0($t4)
    
    	jr $ra

funcionB: # a0: vector A; a1--> vector B, a2--> size     
	addi $sp, $sp, -4 #decremento la pila
	sw $ra, 4($sp) #guardo la posicion de la pila
	la $a0, A
	addi $t0, $zero,0 #iterador primer bucle  i =0
LoopI:	addi $t1, $zero,0 #iterador segundo bucle
		
LoopJ:	
	
	jal calcula
	
	addi $t1,$t1,1 #j++
	bne $t1, $a2,LoopJ
	addi $t0,$t0,1 #i++
	bne $t0,$a2,LoopI  #i<N
	#restaurar la pila y registros	
	lw $ra, 4($sp) #cargo la pila
	addi $sp, $sp, 4 #devuelvo sp a su posicion inicial
	jr $ra
Imprimir:
	add $t0,$0,$0 			#t0 -> j
	add $t1,$0,$0			#t1 -> i
	bucle:

    		mul $t4,$t0,$a2 #i x m
            	add $t4, $t4, $t1 #i x m + j
            	sll $t4, $t4, 2    # 4*(i x m + j)        
            	add $t4, $t4, $a1    #B + 4*(i x m + j)    B[i][j]

	
		bne $t0,$zero,sin_tab
		la $a0,separador	#imprime un tabulador para cada fila
		li $v0,4
		syscall
		
		sin_tab:
		lw $a0,0($t4)
		li $v0,1		#imprime el dato [i][j]
		syscall
		
		la $a0,separador	#imprime tabulador
		li $v0,4
		syscall
		
		addi $t0, $t0, 1	
		bne $t0,$a2,bucle	
		addi $t1,$t1,1		
		add $t0,$zero,$zero
		
		la $a0,separador2	#imprime salto de linea
		li $v0,4
		syscall
		
		bne $t1,$a2,bucle	
		
	jr $ra
