.data
A:.space 100
numero: .word 2147483647
texto: .asciiz "Inserte el número en decimal:"
mensaje: .asciiz "No se ha introducido nada \n"
mensaje2: .asciiz "Caracter Incorrecto\n"
mensaje3: .asciiz "Numero demasiado grande\n"

.text

la $a0,texto
li $v0,4
syscall

la $a0, A	#donde guardo el numero
li $a1, 12	#tamaño buffer
li $v0, 8	#leer string
syscall


jal decimalABinario

beq $v0, 3, vacio2
beq $v0, 2, overflow2
beq $v0, 1, error2

add $a0, $0, $v1
la $v0,1
la $a1,A
jal binarioAHexadecimal
la $a0,A
la $v0,4
syscall
li $v0,10
syscall

overflow2:
	la $a0,mensaje3		#Mensaje si cadena vacia
	li $v0,4
	syscall
	li $v0,10
	syscall


vacio2:
	la $a0,mensaje		#Mensaje si cadena vacia
	li $v0,4
	syscall
	li $v0,10
	syscall

error2:
	la $a0,mensaje2		#Mensaje si cadena vacia
	li $v0,4
	syscall
	li $v0,10
	syscall


decimalABinario:
	add $t0, $0, $a0	#guardamos en t0 el puntero del numero introducido 
	add $t1, $0, $0		#contador bucle para las cifras
	add $t2, $0, 1		
	
	
	la $t7, numero
    	lw $t6, 0($t7)
	
	
	lb $t3, 0($t0)
	beq $t3, 45, signo
	beq $t3, 10, vacio
	
	bucle:
		lb $t3, 0($t0)	#Cargamos  numero
		
		beq $t3, 10, continuar	#Si encontramos el \0 salimos, si no seguimos recorriendo el numero
		ble  $t3, 47, error
		bge $t3, 58, error
		addi $t1, $t1, 1	#Incremento contador del bucle
		addi $t0, $t0, 1	#Incremento posicion del numero
		
		j bucle
		
	signo:
		addi $t0, $t0, 1	#Incremento la posición pero no el contador, para no tener en cuenta el signo a la hora de coger el número
		add $t9, $t9, 1		#Flag para luego hacer negativo
		j bucle
		
	continuar:
	addi $t4, $t4, 1	#Contador de la potencia de 10
	add $t5, $0, $0		#Aquí irá la suma del número
	
	beq $t1, 10, overflow 
	
	sumar:
		addi $t0, $t0, -1
		lb $t3,0($t0)
		addi $t3,$t3,-48	#pasamos el número de ascii a decimal
		mul $t3, $t3, $t4	#multiplicamos por la potencia de 10
		add $t5, $t5, $t3	#Aquí va el número en decimal
		mul $t4, $t4,10		#Seguimos con las potencias de 10
		addi $t1, $t1, -1	#Decrementamos el bucle
		bne $t1, 0, sumar	#Cuando llega a 0 se sale del bucle
	
	beq $t9, 1, negativo		#Compruebo si había un signo para calcular el opuesto del numero
	add $v1,$t5,$0
	jr $ra
	
	overflow:
		add $v0, $0, 2
		jr $ra
		
	negativo:
		sub $v1, $0, $t5
		jr $ra
	
	error:
		add $v0, $0, 1
		jr $ra
	
	vacio:
		add $v0, $0, 3
		jr $ra

binarioAHexadecimal:
	
	addi $t0,$0,4026531840		#t0 -> mascara para leer los primeros 4  bits
	add $t1,$a0,$0			#t1 -> numero
	addi $t2,$0,8			#t2 -> contador de veces
	add $t4,$0,$a1			#t4 -> puntero de la cadena

		bucle2:
			and $t3,$t0,$t1		#se sacan los 4 bits
			srl $t3,$t3,28		
			blt $t3,10,numero2
			addi $t3,$t3,55
			j guardar2
		numero2:
			addi $t3,$t3,48
		guardar2:
			sb $t3,0($t4)
			addi $t4,$t4,1
			sll $t1,$t1,4
			addi $t2,$t2,-1
			bne $t2,$0,bucle2
			add $v0,$t4,$0		#se devuelve el puntero a la ultima posicion de la cadena
			bne $a3,0,cero2
		salir2:	
			jr $ra
		cero2:
			sb $0,0($t4)		
			j salir2	
	