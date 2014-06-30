.data
str: .asciiz "31312023"
.text
main:
		la $a0, str
		jal atoi
		
		move $a0, $v0
		li $v0, 1
		syscall			# print values
		
		li $v0, 10
		syscall
		
## a0--pointer to token e.g. "123214"
atoi:		
		addi $sp, $sp, -8	# Adjust stack
		sw $a0, 0($sp)
		sw $ra, 4($sp)
		li $t0, 0		# value = 0
WHILE:		lb $t1, 0($a0)
		blt $t1, 48 end_atoi
		bgt $t1, 57, end_atoi	# Branch equal to newline
		addi $t1, $t1, -48	# digit of token - '0'
		li $t3, 10		# tmp
		mult $t0, $t3
		mflo $t0		# value = value * 10
		add $t0, $t0, $t1	# value = value * 10 + (digit of token - '0')
		add $a0, $a0, 1		# a0 increment
		j WHILE
end_atoi:
		lw $a0, 0($sp)
		lw $ra, 4($sp)
		addi $sp, $sp, 8
		move $v0, $t0
		jr $ra
