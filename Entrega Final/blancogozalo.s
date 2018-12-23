#Practica realizada por:
#Luis Blanco de la Cruz
#Roberto Gozalo Andres

.data
fecha1:.space 64		#Guardamos la fecha1 introducida
fecha2:.space 64		#Guardamos la fecha2 introducida
espaciofecha1:.space 64		#Guardamos la fecha1 ya formateada sin espacios
espaciofecha2:.space 64		#Guardamos la fecha2 ya formateada sin espacios
guardarFecha1:.space 32		#Guardamos los dias de la fecha1 en dias segundos mes año dia 
guardarFecha2:.space 32		#Guardamos los dias de la fecha2
diferencia:.space 24
swap:.space 8
mesesN: .word 31 28 31 30 31 30 31 31 30 31 30 31 
mesesS: .word 0 31 59 90 120 151 181 212 243 273 304 334 
mensaje: .asciiz "Introduzca la primera fecha con formato DD/MM/AAAA HH:MM:SS : "
mensaje2: .asciiz "Introduzca la segunda fecha con formato DD/MM/AAAA HH:MM:SS: "
mensaje3: .asciiz "Error, cadena incorrecta \n"
mensaje4: .asciiz "Error, has sobrepasado la capacidad maxima del buffer \n"
mensaje5: .asciiz "Han pasado:\n"
mensaje6: .asciiz "    años,    meses,    dias,    horas,    minutos,    segundos\n"
mensaje7: .asciiz "Error, fecha incorrecta\n"

#(año-1)x365+mes_en_dias-dias_del_mes+dia = fecha en dias
#Se puede meter fechas con espacios, pero hay que usar las / para las horas y los : para las horas.
#Admite años mayores que 0 hasta el 9999. No admite minutos y segundos mayores de 59 ni horas mayores que 23.
.text
main:
	la $a0,mensaje                      #carga en a0 la direccion donde esta el mensaje
	la $a1,fecha1                       #carga en a1 la direccion donde se guardara la cadena
	li $a2,64                           #en a2 la longitud maxima de la cadena
	li $v0,54                           #El syscall 54 permite introducr un String como el syscall 8 pero con una ventana 
	syscall                             #Este syscall ademas pone un codigo en a1 sobre si ha ido bien o ha ocurrido un error

	beq $a1,-2,cancelar                 #Cuando se pulsa el boton cancelar, el programa termina
	beq $a1,-3,error1                   #Cuando se introduce una cadena vacia, no se acepta
	beq $a1,-4,bufferException          #Cuando se introduce una cadena que tiene mas longitud de la permitida

	la $a0,fecha1
	la $a1,espaciofecha1
	jal comprobarFecha                 #LLama a la funcion que separa la cadena en dos
	move $s7,$v1                        #En s7 estara el numero que indica si ha habido algun error
	beq $s7,1,error1
	beq $s7,2,error2

	la $a0,mensaje2                     #carga en a0 la direccion donde esta el mensaje
	la $a1,fecha2                       #carga en a1 la direccion donde se guardara la cadena
	li $a2,64                           #en a2 la longitud maxima de la cadena
	li $v0,54                           #El syscall 54 permite introducr un String como el syscall 8 pero con una ventana 
	syscall                             #Este syscall ademas pone un codigo en a1 sobre si ha ido bien o ha ocurrido un error

	beq $a1,-2,cancelar                 #Cuando se pulsa el boton cancelar, el programa termina
	beq $a1,-3,error1                   #Cuando se introduce una cadena vacia, no se acepta
	beq $a1,-4,bufferException          #Cuando se introduce una cadena que tiene mas longitud de la permitida

	la $a0,fecha2
	la $a1,espaciofecha2
	jal comprobarFecha                  #LLama a la funcion que separa la cadena en dos
	move $s7,$v1                        #En s7 estara el numero que indica si ha habido algun error
	beq $s7,1,error1
	beq $s7,2,error2
	j sinError


error1:                                     #Este error es si se ha introducido algun caracter no valido, una cadena vacia,
	la $a0,mensaje3                     # un espacio entre dos numeros, o dos operadores seguidos no perimtidos
	li $a1,0
	li $v0,55                           #El syscall 55 muestra una ventana con un mensaje que esta en a0
	syscall                             #En a1 esta el simbolo si es un error, una advertencia u otro, en este caso 0 porqur es un error
	j main                              #Si ha habido un error, se vuelve a pedir otra cadena
	
error2:                                    
	la $a0,mensaje7                     #Este error es si uno de los numeros no tiene la longitud correcta
	li $a1,0
	li $v0,55
	syscall
	j main
	
bufferException:
	la $a0,mensaje4                     #Este error es si la cadena es tan larga que no entra en el espacio que hemos reservado
	li $a1,0			    #En este caso se acaba el programa
	li $v0,55
	syscall
	li $v0,10
	syscall

sinError:				     #Si la validacion ha ido bien, pasamos ambas fechas a dias y segundos y las devolvemos en $s0 y $s1
        la $a0,espaciofecha1		     #Carga direccion de una fecha para pasarselo a la funcion
        jal convertirASegundos
        beq $v1,1,error2
        la $a0,guardarFecha1
        la $a3,guardarFecha2
        lw $s0,0($a3)               #Como nuestra funcion recibe como parametro el puntero de la fecha en a0, tenemos que mover todo el contenido 
        lw $s1,4($a3)               # a otro vector para reutilizar nuestra funcion y no perder datos
        sw $s0,0($a0)
        sw $s1,4($a0)
        lw $s0,8($a3)
        lw $s1,12($a3)
        sw $s0,8($a0)
        sw $s1,12($a0)
        lw $s0,16($a3)
        sw $s0,16($a0)
        la $a0,espaciofecha2
        jal convertirASegundos
        beq $v1,1,error2
        la $a0,guardarFecha1
        la $a3,guardarFecha2
        lw $s0,0($a0)
        lw $s1,0($a3)
        sub $s0,$s0,$s1
        blt $s0,$zero,cambiarSigno
        j noCambiarSigno
cambiarSigno:
	mul $s0,$s0,-1
noCambiarSigno:	        
        sw $s0,20($a0)
        
        lw $s0,4($a0)
        lw $s1,4($a3)
        sub $s0,$s0,$s1
        ble $s0,$zero,cambiarSigno2
        j noCambiarSigno2
cambiarSigno2:
	mul $s0,$s0,-1
	li $s6,1
noCambiarSigno2:	        
        sw $s0,24($a0)
        
        la $a0,guardarFecha1
        la $a1,guardarFecha2
        jal bisiestos
        move $s3,$v0
        la $a0,guardarFecha1
        lw $s4,20($a0)
        add $s4,$s4,$s3
        sw $s4,20($a0)
    
        la $a0,diferencia
        la $a1,guardarFecha1
        move $a2,$s6
        move $a3,$s3
        jal formato 
      
	la $a0,mensaje6
	la $a1,diferencia
	la $a2,swap
	jal completarCadena
	
	la $a0,mensaje5
	la $a1,mensaje6
	li $v0,59
	syscall
			
						
cancelar:                                  #Aqui se llega si se ha pulsado el boton cancelar en alguna ventana
	li $v0,10 
	syscall
	
#################################################################################################	
comprobarFecha:				  #a0 introducida, a1 donde lo quiero dejar. Al acabar en el segundo vector se encuentra la fecha ya en formato correcto
	addi $sp,$sp,-4
	sw $ra,0($sp)
	add $t0,$a0,$0	                  #t0 puntero para la cadena
	add $t1,$a1,$0	                  #t1 puntero para la zona de la fecha
	add $t3,$0,$0                     
	add $t5,$0,$0                     #t5 cuenta el numero de numeros que hay en la cadena
	bucleE:
		lb $t4,0($t0)
		
		sne $t9,$t4,32            #Si el dato leido es un 32(espacio), pone $t9 a 0, sino a 1
		addi $t9,$t9,-1           #Se le resta 1 para poder usar la instruccion bltzal
		move $a0,$t0
		bltzal $t9,espacios       #Si t9 es menor que 0 entonces es que hay un espacio y va a la funcion que los obvia
		move $t0,$a0
		
		lb $t4,0($t0)		  #Como en espacios mueve a la posicion siguiente, vuelvo a cargar
		
		ble $t4,47,cadenaIncorrecta   #Para ver si el primer dato(excepto espacios) es un numero
		bge $t4,58,cadenaIncorrecta
		
	bucle:				     #Bucle que recorre todas las cifras introducidas
		lb $t4,0($t0)                
		
		sne $t9,$t4,32                #De nuevo puede haber espacios entre un numero y un separador
		addi $t9,$t9,-1
		move $a0,$t0
		bltzal $t9,espacios
		move $t0,$a0
		
		lb $t4,0($t0) 
		
		ble $t4,47,cadenaIncorrecta   #Si despues de quitar los espacios y el siguiente dato no es un numero
		bge $t4,58,cadenaIncorrecta   # la cadena introducida por el usuario es incorrecta
		
		move $a0,$t0
		move $a1,$t1
		move $a2,$t5	
		jal esUnNumero                #LLama a la funcion que trabaja con la cadena de los numeros
		move $t0,$v0                  #Puntero de la cadena principal recibido de la funcion anterior
		move $t1,$v1                  #Direccion de la cadena de los numeros o el codigo de error de la funcion anterior
		
		addi $t5,$t5,1                #Se suma uno a t5 por cada numero leido
		beq $t1,2,numeroMuyLargo      #El error que puede retornar esta funcion es que uno de los numeros sea mayor de 4 cifras
	
		lb $t4,0($t0)                 #Cargo siguiente caracter
		
		sne $t9,$t4,32                #De nuevo puede haber espacios entre un numero y un separdor
		addi $t9,$t9,-1
		move $a0,$t0
		bltzal $t9,espacios
		move $t0,$a0
		
		lb $t4,0($t0) 		       #Cargo siguiente caracter porque espacios lo ha movido
		
		beq $t4,10,salir               #Puede haber dos terminadores de cadena el 0 o el /n
		beq $t4,0,salir
		
		move $a0,$t0
		move $a1,$t1
		move $a2,$t5
		jal separador             #Llama a la funcion que se encarga de trabajar con los operadores permitidos
		move $t0,$v0
		move $t1,$v1
		
		beq $t1,1,cadenaIncorrecta    #El error que puede haber es que haya un simbolo no permitido o dos operadores seguidos
		j bucle                       #Si todo ha ido bien, seguimos recorriendo la cadena

	
	numeroMuyLargo:                       #Retorna el codigo de error de un numero muy largo(grande)
		li $v1,2
		lw $ra,0($sp)
		addi $sp,$sp, 4
		jr $ra
	cadenaIncorrecta:	              #Retorna el codigo de error de que hay algun simbolo incorrecto o dos operadores seguidos en la cadena
		li $v1,1
		lw $ra,0($sp)
		addi $sp,$sp, 4
		jr $ra
	
	salir:                                
		sb $zero,0($t0)
		sb $zero,0($t1)
		ble $t5,5,cadenaIncorrecta	#Si hay menos de 4 cifras, algo ha ido mal porque lo minimo es el 1/1/1 a las 0:0:1
		move $v0,$t5                    #Retorna la cantidad de numeros que hay
		lw $ra,0($sp)
		addi $sp,$sp, 4
		jr $ra
		
#######################################################################################	
esUnNumero:
	addi $sp,$sp,-4				#La funcion recibe como parametros el puntero de la cadena en a0, el puntero de la zona donde lo quieres guardar en a1 y la cuenta de los numeros en a2
	sw $ra,0($sp)
	move $t0,$a0            
	move $t1,$a1
	bucle3:
		sb $t4,0($t1)                #Se guarda la primera cifra en el segundo vector
		addi $t3,$t3,1               #t3 contador de cifras
		beq $t3,5,salir3	     #como mucho los anyos pueden tener 4 cifras
		addi $t1,$t1,1
		addi $t0,$t0,1
		lb $t4,0($t0)
		ble $t4,47,salir2            #Cuando se lea algo que no sea un numero se sale, aunque lo leido sea un caracter incorrecto
		bge $t4,58,salir2            # eso ya lo comprobara la siguiente funcion
		j bucle3
	salir2:
		beq $t3,3,salir3
	salir2_2:	
		li $t3,0
		move $v0,$t0                 #Retorna el puntero actualizado de la cadena principal en v0 y la de los numeros en v1
		move $v1,$t1		     #Solo la usamos para comprobar que no haya un error al introducir un anyo con mas de 4 cifras y mas de 2 cifras en el resto de cosas
		lw $ra,0($sp)
		addi $sp,$sp, 4
		jr $ra
	salir3:
		beq $a2,2,salir2_2
		li $v1,2                     #Si ha llegado hasta aqui es porque ha habido un numero que es demasiado grande
		lw $ra,0($sp)                #Retorna el codigo de error
		addi $sp,$sp, 4
		jr $ra		
				
#######################################################################################					
separador:
	addi $sp,$sp,-4				#La funcion recibe como parametros el puntero de la cadena en a0, el puntero de la zona donde lo quieres guardar en a1 y la cuenta de los numeros en a2
	sw $ra,0($sp)
	move $t0,$a0
	move $t1,$a1
	lb $t4,0($t0) 						
	blt $a2,3,barra
	beq $a2,3,espacioS
	dospuntos:
		bne $t4,58,salir4		#Si hay dos dos puntos seguidos, error
		j salir5	
	barra:
		bne $t4,47,salir4		#Si hay dos barras seguidas, error				
		j salir5
	espacioS:
		li $t4,32
		addi $t0,$t0,-1
		j salir5							
	salir4:
		li $v1,1                 
		lw $ra,0($sp)
		addi $sp,$sp, 4
		jr $ra
	salir5:
		sb $t4,0($t1)
		addi $t0,$t0,1	
		addi $t1,$t1,1
		move $v0,$t0
		move $v1,$t1			#Si todo es correcto, se devuelve en v0 el puntero de la cadena y en v1 el puntero de la zona ya actualizados sin separador
		lw $ra,0($sp)
		addi $sp,$sp, 4
		jr $ra									

#######################################################################################																																															
convertirASegundos:				#Recibe como parametro la fecha sin espacios en a0 y la devuelve en las posiciones 2,3 y 4 del vector guardarFecha
	addi $sp,$sp,-4
	sw $ra,0($sp)
	move $t0,$a0
	li $t5,0				#Iterador de cifras a guardar
	li $t7,0
	
	bucleS:
		move $a0,$t0			#Cargamos parametros para llevarlos a la siguiente funcion
		move $a2,$t5
		jal decimalABinario
		move $t4,$v0			#Numero recibido en binario
		move $t1,$v1			#bytes leidos
		add $a0,$a0,$t1
		addi $a0,$a0,1
		addi $t5,$t5,1
		beq $t5,1,guardarDias
		beq $t5,2,guardarMes
		beq $t5,3,guardarAño
		beq $t5,4,comprobarHoras
		beq $t5,5,comprobarMinutosYSegundos
		beq $t5,6,comprobarMinutosYSegundos
	seguirBucleS:	
		move $a1,$t4		#Puntero para pasar a la funcion
		move $a2,$t5		#Iterador para pasar a la funcion
		jal multiplicar
		move $t4,$v0
		add $t7,$t7,$t4		#Sumatorio de dias/segundos
		beq $t5,3,guardarDias2
		move $t0,$a0
		bne $t5,6,bucleS
		j salir7
	
	guardarMes:
		la $a3,guardarFecha2
		beqz $t4,errorFecha
		bgt $t4,12,errorFecha
		move $a1,$t4			#Cargo el mes de la fecha para la funcion de comprobar
		lw $a2,16($a3)			#Cargo el dia que tengo almacenado en la posicion 4 del vector para comprobar el dia bueno
		jal comprobarDiaMes
		move $t2,$v1
		beq $t2,0,errorFecha
		beq $t2,2,cambiarVeintinueve
	guardarMes2:	
		move $s5,$v0
		sw $t4,8($a3)
		j seguirBucleS
	guardarAño:
		la $a3,guardarFecha2		#Cargo direccion final de la fecha para guardarla
		beqz $t4,errorFecha		#El año no puede ser 0
		sw $t4,12($a3)			#Guardo en la posicion 3 del vector el año
		j seguirBucleS	
	
	guardarDias:
		la $a3,guardarFecha2
		bgt $t4,31,errorFecha		#Si es mayor que 31 o 0 o menos, error
		beqz $t4,errorFecha
		sw $t4,16($a3)			#Guarda el dato del dia en la posicion 4 del vector
		j seguirBucleS
	guardarDias2:
		la $a3,guardarFecha2
		sub $t7,$t7,$s5	
		sw $t7,0($a3)
		move $t0,$a0
		move $t7,$zero
		j bucleS
	comprobarHoras:
		bgt $t4,23,errorFecha
		j seguirBucleS
	comprobarMinutosYSegundos:	
		bgt $t4,59,errorFecha
		j seguirBucleS
		
	cambiarVeintinueve:
		lw $t2,16($a3)
		sub $t2,$t2,1
		sw $t2,16($a3)
		j guardarMes2					
	salir7:	
		sw $t7,4($a3)
		li $v1,0
	     	lw $ra,0($sp)
		addi $sp,$sp, 4
		jr $ra																																																																																														
	errorFecha:					#Devuelve error de fecha mal introducida
		li $v1,1
		lw $ra,0($sp)
		addi $sp,$sp, 4
		jr $ra
			
###################################################################################		
comprobarDiaMes:																																																																																																																																																																																														
	addi $sp,$sp,-4
	sw $ra,0($sp)																																																																																																																																																																																																																																																																																																																																																																																								
	move $t2,$a2  #dia
	move $t4,$a1  #mes
	la $a2,mesesN				#Cargo el array con los dias del mes 
	addi $t4,$t4,-1
	sll $t8,$t4,2				#Obtenemos el día maximo del  mes introducido
	add $t8,$t8,$a2
	lw $t8,($t8)
	addi $t4,$t4,1
	sle $v1,$t2,$t8 	#Comprobamos que no sea mayor al dia maximo de cada mes
	move $v0,$t8
	seq $t2,$t2,29
	seq $t9,$t4,2
	and $t2,$t2,$t9
	beq $t2,1,veintinueveF
	lw $ra,0($sp)
	addi $sp,$sp, 4
	jr $ra
veintinueveF:
	li $v1,2	
	lw $ra,0($sp)
	addi $sp,$sp, 4
	jr $ra	
																																																																																																																																																																																																																																																																																																																																																																																								
#######################################################################																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																		
multiplicar:
	addi $sp,$sp,-4				#Recibe como parametros puntero en a1 e iterador en a2
	sw $ra,0($sp)																																																																																																																																																																																																																																																																																																																																																																																								
	move $t4,$a1
	move $t6,$a2
	beq $t6,1,dia
	beq $t6,2,mes																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																			
	beq $t6,3,año																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																															
	beq $t6,4,hora
	beq $t6,5,minuto
	j segundo
	
	año:
		addi $t4,$t4,-1
		mul $t4,$t4,365
		j segundo
	mes:
		beq $t4,1,enero
		beq $t4,2,febrero
		beq $t4,3,marzo
		beq $t4,4,abril
		beq $t4,5,mayo
		beq $t4,6,junio
		beq $t4,7,julioAgosto
		beq $t4,8,julioAgosto
		beq $t4,9,septiembre
		beq $t4,10,octubre
		beq $t4,11,noviembre
		beq $t4,12,diciembre
		
		enero:
			mul $t4,$t4,31
			j segundo
		febrero:
			mul $t4,$t4,28
			addi $t4,$t4,3
			j segundo
		marzo:
			mul $t4,$t4,31
			addi $t4,$t4,-3
			j segundo
		abril:
			mul $t4,$t4,30
			j segundo
		mayo:
			mul $t4,$t4,31
			addi $t4,$t4,-4
			j segundo
		junio:
			mul $t4,$t4,30
			addi $t4,$t4,1
			j segundo
		julioAgosto:
			mul $t4,$t4,31
			addi $t4,$t4,-5
			j segundo
		septiembre:
			mul $t4,$t4,30
			addi $t4,$t4,3
			j segundo
		octubre:
			mul $t4,$t4,31
			addi $t4,$t4,-6
			j segundo
		noviembre:
			mul $t4,$t4,30
			addi $t4,$t4,4
			j segundo
		diciembre:
			mul $t4,$t4,31
			addi $t4,$t4,-7
			j segundo									
			
	dia:
		j segundo
	hora:
		mul $t4,$t4,60
	minuto:
		mul $t4,$t4,60
	segundo:
		move $v0,$t4			#Devuelve en v0 el numero calculado
		lw $ra,0($sp)
		addi $sp,$sp, 4
		jr $ra	
		
####################################################################		
#Esta funcion es la que se encarga de cada vez que lea un espacio volver a leer en bucle hasta que el dato leido no sea un espacio		
espacios:
	addi $sp,$sp,-4
	sw $ra,0($sp)
	move $t0,$a0
	espacios3:
		lb $t9,0($t0)
		addi $t0,$t0,1
		beq $t9,32,espacios3
	addi $t0,$t0,-1
	move $a0,$t0                              
	lw $ra,0($sp)
	addi $sp,$sp, 4
	jr $ra	
	
####################################################################
formato:																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																						
	addi $sp,$sp,-4		#gestion de pila
	sw $ra,0($sp)		#gestion de pila
	move $t0,$a0 		#$t0 -> $a0
	move $t1,$a1		#$t1 -> $a1
	move $t9,$a2		#$t9 -> $a2
	move $t6,$a3		#$t6 -> $a3
	la $t5,mesesS
	lw $t2,20($t1)
	sub $t2,$t2,$t6
	lw $t3,24($t1)																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																											
años:	
	li $t4,365		#$t4 -> 365 (dias/365)
	div $t2,$t4		#$t2/365
	mflo $t4		#$t4 -> cociente de la division  (anyos)
	mfhi $t2		#$t2 -> resto de la division	(dias)
	sw $t4,0($t0)
meses:
	li $t4,0
bucleMeses:
	addi $t4,$t4,1		#reseteamos $t4 y sumo 1
	sll $t8,$t4,2		#multiplico por 4 (para coger la primera posicion de la cadena)
	add $t8,$t8,$t5		#direccion de mesesS ->$t5 +4 para acceder a la segunda posicion (31)
	lw $t8,($t8)		#guardo la segunda posicion en $t8
	sle $t6,$t8,$t2		#si $t8 <= $t2 se pone un 1 en $t6 $t2 el resto
	bnez $t6,bucleMeses	#salta si !=0
	addi $t4,$t4,-1		#para sacar la anterior posicion
	sll $t8,$t4,2
	add $t8,$t8,$t5
	lw $t8,($t8)
	sub $t2,$t2,$t8		#lo que tengo - la posicion de mesesS
	sw $t4,4($t0)		#guardo el mes
dias:
	bne $t9,1,dias2
dias3:	
	sw $t2,8($t0)		#almacenamos los días en su posicion
	
segundos:	
	li $t4,60
	div $t3,$t4		#segundos/60
	mflo $t3		#$t3 -> cociente de la division
	mfhi $t4		#$t4 -> resto de la division
	sw $t4,20($t0)
minutos:
	li $t4,60
	div $t3,$t4		#min/60
	mflo $t3		#$t3 -> cociente de la division
	mfhi $t4		#$t4 -> resto de la division
	sw $t4,16($t0)
horas:
	beq $t3,24,horas3	
horas2:	
	sw $t3,12($t0)
	lw $ra,0($sp)
	addi $sp,$sp, 4
	jr $ra																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																				
horas3:				#para evitar que se sume un dia adiccional
	li $t3,0
	j horas2
	
dias2:
	sub $t2,$t2,1
	li $t5,86400   #1 dia en segundos
	sub $t3,$t5,$t3
	j dias3			
	
####################################################################																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																											
#Esta funcion es la que se encarga de ver si algun año es bisiesto o cuantos años bisiestos hay entre las dos fechas		
bisiestos:
	addi $sp,$sp,-4
	sw $ra,0($sp)
	move $t0,$a0
	move $t1,$a1
	lw $t3,0($t0)		#fecha alta
	lw $t5,0($t1)		#fecha baja
	bgt $t5,$t3,alreves	#si $t5>$t3 -> alreves
	lw $t3,12($t0)		#fecha alta
	lw $t5,12($t1)		#fecha baja
	j noalreves
alreves:	
	lw $t5,12($t0)	
	lw $t3,12($t1)
	li $t4,1		#si esta dado la vuelta ponemos $t4 a 1 y si no a 0 
noalreves:	
	sub $t6,$t3,$t5		#$t6=fecha alta - fecha baja
	li $t9,-1		#$t9 a -1
bucleAñoBisiesto:	
	li $t7,400
	div $t3,$t7
	mfhi $t7
	beqz $t7,esBisiesto
	li $t7,4
	div $t3,$t7
	mfhi $t7
	beqz $t7, segundaComprobacion
	j noEsBisiesto
		
	segundaComprobacion:
		li $t7,100
		div $t3,$t7
		mfhi $t7
		bnez $t7,esBisiesto
		j noEsBisiesto					
	esBisiesto:
		beq $t9,-1,fechaAltaB
		beqz $t6, fechaBaja
	esBisiesto2:						
		addi $t9,$t9,1				
	noEsBisiesto:
		beq $t9,-1,fechaAltaA
	noEsBisiesto2:	
  		addi $t6,$t6,-1		#contador anyos - -
  		addi $t3,$t3,-1		#anyo que estoy comprobando -1 (para seguir comprobando los anyos)
		bgez $t6,bucleAñoBisiesto #mientras $t6 >0
		j eliminarBisiestosMalos

	fechaAltaA:	
		addi $t9,$t9,1
		j noEsBisiesto2		
	fechaAltaB:
		addi $t9,$t9,1
		li $t2,1
		sw $t2,28($t0)		#guardamos el 1, pero aun no sabemos que es bisiesto
		j esBisiesto2
	fechaBaja:
		li $t2,1
		sw $t2,28($t1)
		j esBisiesto2	
		
eliminarBisiestosMalos:	
	#vuelvo a comprobar las fechas, porque si no se mezclarian las fechas								
	beq $t4,1,alreves2
	lw $t3,8($t0)
	lw $t5,8($t1)
	lw $t2,16($t0)
	lw $t4,16($t1)
	j noalreves2
alreves2:	
	lw $t5,8($t0)
	lw $t3,8($t1)
	lw $t4,16($t0)
	lw $t2,16($t1)
noalreves2:
	lw $t7,28($t0)
	beq $t7,1,comprobarBisiestoAlto
seguirComprobacion:
	lw $t7,28($t1)
	beq $t7,1,comprobarBisiestoBajo
	j salirBisiestos
comprobarBisiestoAlto:	
	slti $t7,$t3,3		#si $t3<3 ponemos en $t7 un 1
	slti $t8,$t2,29		#si $t2<29 ponemos en $t8 un 1
	and $t7,$t7,$t8		#para ver que son validas las dos condiciones (si $t7 es 1 NO es bisiesto)
	sub $t9,$t9,$t7		#resto uno a la cuenta de bisiestos, porque en realidad no lo era
	j seguirComprobacion	#para comprobar el otro anyo de la otra fecha que introducimos
comprobarBisiestoBajo:	
	sge $t7,$t5,3		#si $t5>3 ponemos $t7 a 1
	sub $t9,$t9,$t7		#lo restamos de la cuenta de bisiestos
salirBisiestos:	
	move $v0,$t9		#devolvemos el numero de bisiestos
	lw $ra,0($sp)
	addi $sp,$sp, 4
	jr $ra		
	
############################################################################
completarCadena:
	#pasas anyos a string sumas las posiciones necesarias para almacenar meses y asi sucesivamente
	addi $sp,$sp, -8 # reserva 2 lugares en la pila
	sw $ra,4($sp) # guarda dirección de retorno
	sw $s1,0($sp) # guarda parámetro
	move $s0,$a0
	move $s1,$a1	
	lw $t2,0($s1)
	move $a0,$s0
	move $a1,$t2
	jal binarioADecimal
	addi $s0,$s0,10
	addi $s1,$s1,4
	lw $t2,0($s1)
	move $a0,$s0
	move $a1,$t2
	jal binarioADecimal
	addi $s0,$s0,10
	addi $s1,$s1,4
	lw $t2,0($s1)
	move $a0,$s0
	move $a1,$t2
	jal binarioADecimal
	addi $s0,$s0,9
	addi $s1,$s1,4
	lw $t2,0($s1)
	move $a0,$s0
	move $a1,$t2
	jal binarioADecimal
	addi $s0,$s0,10
	addi $s1,$s1,4
	lw $t2,0($s1)
	move $a0,$s0
	move $a1,$t2
	jal binarioADecimal
	addi $s0,$s0,12
	addi $s1,$s1,4
	lw $t2,0($s1)
	move $a0,$s0
	move $a1,$t2
	jal binarioADecimal
	lw $s1,0($sp) # recupera valor original de s1
	lw $ra,4($sp) # y dirección de retorno,
	addi $sp,$sp, 8 # libera los 2 lugares de la pila,
	jr $ra
			
####################################################################										
#Convierte un numero entero de formato String a binario
#v1 vale 1 si el numero es demasiado grande (mas de 9 cifras)
decimalABinario:
	addi $sp,$sp,-4
	sw $ra,0($sp)
	add $t0,$0,$a0		#t0 -> puntero de la cadena
	addi $t2,$0,-1		#t2 -> contador de cifras
	add $t3,$0,1		#t3 -> potencias de 10
	addi $t4,$0,0		#t4 -> numero en decimal


	li $v1,0
	
	derecha:			#mueve el puntero hasta encontrar el lsb y cuenta las cifras del numero
		lb $t1,0($t0)
		addi $t0,$t0,1
		addi $t2,$t2,1		
		bge $t2,10,muy_grande
		bge $t1,58,seguir
		ble $t1,47,seguir
		j derecha
	
	seguir:
		addi $t0,$t0,-1
		move $v1,$t2
		j bucleDAB 

	muy_grande: 
		li $v1,10
		jr $ra

	bucleDAB :
		addi $t0,$t0,-1
		lb $t1,0($t0)
		addi $t1,$t1,-48	#paso a decimal
		mul $t1,$t1,$t3		#se multiplica por la potencia de 10	
		add $t4,$t4,$t1		#t4 -> numero en decimal
		mul $t3,$t3,10
		addi $t2,$t2,-1		
		bne $t2,0,bucleDAB 	#se repite con todas las cifras

	move $v0,$t4			#devuelvo numero en v0
	
	salirDAB:
		lw $ra,0($sp)
		addi $sp,$sp,4
		jr $ra

####################################################################		
#Convierte un numero entero en su representacion como String		
binarioADecimal:
	move $t5,$a0 		#t0 -> puntero de la cadena
	move $t1,$a1		#t1 -> numero
	addi $t2,$0,10		#t2 -> valor 10 para dividir
	addi $t0,$a2,4		#t5 -> puntero al principio de la cadena para cambiar el orden
	add $t7,$0,$0		#t7 -> indicara si el numero es positivo o negativo
	addi $t8,$0,45		#t8 -> valor ASCII del guion
	
	blt $t1,0,negativo
	
	j bucleBAD
	
	negativo:			#si el numero es negativo se pasa a positivo y se guarda que lo era
		mul $t1,$t1,-1
		add $t7,$0,1
	
	bucleBAD:			#se va dividiendo entre 10 y obteniendo los restos
		div $t1,$t2
		mfhi $t3		#HI -> t3 -> resto
		mflo $t1		#LO -> t1 -> cociente
		
		addi $t3,$t3,48		#paso a ASCII
		sb $t3,0($t0)
		
		addi $t0,$t0,-1
		bge $t1,10,bucleBAD	#si el cociente es mayor que el divisor (10) se repite el bucle
		
		mflo $t1		#se guarda el ultimo cociente
		addi $t0,$t0,1
		beq $t1,0,otro		#si este es 0 no se guarda
		addi $t0,$t0,-1
		addi $t1,$t1,48
		sb $t1,0($t0)
		
	otro:	
		bne $t7,1,bucle2	#si el numero es negativo se guarda el guion que representa al signo
		addi $t0,$t0,-1
		sb $t8,0($t0)
				
	bucle2:				#cambia el orden de la cadena y la pone al principio
		lb $t3,0($t0)
		beq $t3,0,salirBAD	#cuando se encuente el caracter nulo para
		sb $t3,0($t5)
		addi $t5,$t5,1		#se incrementan los contadores del principio y el final
		addi $t0,$t0,1
		j bucle2
		
	salirBAD:
		move $v0,$t0
		jr $ra