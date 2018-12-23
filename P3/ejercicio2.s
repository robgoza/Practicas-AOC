.data
hex: .asciiz "0x"
mensaje: .asciiz " Introduce un numero en decimal: "

.text
la $a1,hex
la $a0,mensaje
li $v0,4
syscall
li $v0,5
syscall
add $a0,$v0,$zero
jal funcion
add $a0,$a1,$zero
li $v0,4 #para imprimir el numero
syscall
li $v0,10
syscall


funcion:
	addi $t0,$0,4026531840 #4026531840 = 0xF0000000
	add $t1,$a0,$0
	sll $t1,$t1,2 #numero *4
	addi $t2,$0,8
	add $t4,$0,$a1
	addi $t5,$0,48
	sw $t5,0($t4)
	addi $t4,$t4,1
	addi $t5,$0,120
	sb $t5,0($t4)
	addi $t4,$t4,1

	bucle:
		and $t3,$t0,$t1 #se realiza un and con el dato y la mascara para tener los 4 bits MSB
		srl $t3,$t3,28 #se desplazan los bits 28 posiciones
		blt $t3,10,numero #comprobamos si numero >= a 10
		addi $t3,$t3,55 #sumamos 55 para obtener la letra correspondiente
		j guardar
	numero:
		addi $t3,$t3,48 #sumamos 48 para obtener el digito correspondiente
	guardar:
		sb $t3,0($t4)
		addi $t4,$t4,1 #direccion guardado ++
		sll $t1,$t1,4
		addi $t2,$t2,-1 #contador --
		bne $t2,$0,bucle
	sb $0,0($t4)	
	jr $ra	
		
		
