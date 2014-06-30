funkyfunc:
	li $a0, 'f'
	li $v0, 11
	syscall

	li $a0, '\n'
	li $v0, 11
	syscall

	li $t0, 15
	sll $t1, $t0, 4
	sll $t2, $t1, 4
	sll $t3, $t2, 4
	sll $t4, $t3, 4
	sll $t5, $t4, 4
	sll $t6, $t5, 4
	sll $t7, $t6, 4
	rol $t8, $t7, 4
	neg $t9, $t8
	addi $t9, $t9, -1 		
	
	li $v0, 0xFFFFFFFF
	li $v1, 0xFFFFFFFF

	or $a0, $0, $0
	or $a1, $0, $0
	or $a2, $0, $0
	or $a3, $0, $0

	jr $ra
