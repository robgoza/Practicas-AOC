.data
A: .word 1, 2, 3, 5, 8, 13, 21, 34
B: .word 0x21, 0x02, 0x02, 0x04, 0x08, 0x20, 0x100, 0x2000

.globl __start

.text
__start:
	lw $s0, A
	#lb $s1, A
	addi $a0, $s0 ,0
	li $v0, 1
	syscall
	addi $a0, $s1, 0
	li $v0, 1
	syscall
	
	la $t2, A
	la $t3, B

	addi $t1, $t1, 0 #iterador del bucle
	addi $t9, $t9,8 #final del bucle
bucle:

	
	
	lw $t4, 0($t2)	#  t4 = A[i]
	lw $t5, 0($t3)  # t5= B[i]
	sw $t4, 0($t3)  #Guardo Ai en Bi
	sw $t5, 0($t2)  #Guardo Bi en Ai
	addi $t2, $t2,4
	addi $t3, $t3,4
	addi $t1, $t1, 1 #incremento del iterador
	addi $a0, $t4,0
	li $v0,1
	syscall
	addi $a0, $t5,0
	li $v0,1
	syscall
	bne $t1, $t9, bucle
	
	b final_bucle
final_bucle:

	li $v0, 10
	syscall