.data
a: .space 100
mensaje: .asciiz "Introduzca un numero hexadecimal (sin 0x): " 
mensaje2: .asciiz "Error, cadena incorrecta \n"
mensaje3: .asciiz "Error, cadena demasiado larga \n"
mensaje4: .asciiz " El número dividido entre 4 es: "
.text
main:
	la $a0,mensaje
	li $v0,4
	syscall

	la $a0,a
	li $a1,12
	li $v0,8
	syscall
	jal hexadecimalABinario
	add $a0,$v0,$0
	srl $a0,$a0,2
	add $a2,$v1,$0
	beq $a2,0,sinError
	beq $a2,1,caracterIncorrecto
	beq $a2,2,demasiadoLarga



caracterIncorrecto:
	la $a0,mensaje2 #imprime un mensaje si la cadena es incorrecta
	li $v0,4
	syscall
	j main

demasiadoLarga:
	la $a0,mensaje3 #imprime un error si es demasiado larga
	li $v0,4
	syscall
	j main



sinError:
	la $a1,a
	jal binarioAHexadecimal
	la $a0,mensaje4
	la $v0,4
	syscall
	la $a0,a
	la $v0,4
	syscall
	li $v0,10
	syscall


hexadecimalABinario:
	addi $t0, $a0,0
	add $t3,$0,$0  
	
	lb $t1, 0($t0)	#para ir almacenando cada caracter
	
	bucle:	
		blt $t1,48,incorrecto	#< 0
		bgt $t1,102,incorrecto	#> f
		blt $t1,58,numero	# 0<x<9
		blt $t1,65,incorrecto   #9<x<A
		blt $t1,71,mayusculas   #a<x<f
		blt $t1,97,incorrecto   #a<x<f
		addi $t1,$t1,-87
		j guardar
	mayusculas:
		addi $t1,$t1,-55
		j guardar
	numero:
		addi $t1,$t1,-48
	guardar:
		or $t2,$t2,$t1
		addi $t3,$t3,1
		addi $t0,$t0,1
		beq $t3,8,comprobar
		lb $t1, 0($t0)
		beq $t1,10,salir
		sll $t2,$t2,4
		j bucle
	salir:

		li $v1,0
		add $v0,$t2,$0
		jr $ra		
	comprobar:
		lb $t1, 0($t0)	
		beq $t1,10,salir
		li $v1,2
		jr $ra
	incorrecto:
		beq $t1,10,salir
		li $v1,1
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
		
