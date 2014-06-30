.data
str: .asciiz "70 / ( ( 3 + 4 ) * 10 )"
result: .space 15 
.text
main:
		la $a0, str
		
		jal tokenizer
		lb $t0, 0($v0)
WHILE:		beq $t0, 0, End
		move $a0, $v0
		li $v0, 4
		syscall
		move $a0, $v1
		jal tokenizer
		lb $t0, 0($v0)
		j WHILE
		
End:		li $v0, 10
		syscall		
		

##	$a0 -- start location $v0 -- return token, $v1, new start location
tokenizer:
# Skip all the space 
		move $t0, $a0		# Copy a0 to v0
		lb $t1, 0($t0)		# Load byte to t0
WHILE1:		bne $t1, 32, NEXT		# if meet space
		add $t0, $t0, 1		# Skip
		lb $t1, 0($t0)
		j WHILE1
NEXT:		la $t3, result

WHILE2:		beq $t1, 0, end_tokenizer
		beq $t1, 10, end_tokenizer
		beq $t1, 32, end_tokenizer
		sb $t1, 0($t3)
		add $t0, $t0, 1		
		add $t3, $t3, 1
		lb $t1, 0($t0)
		j WHILE2
		
end_tokenizer:	la $v0, result		# return token
		move $v1, $t0		# new start location
		li $t1, 0		
		sb $t1, 0($t3)		# Set null to the end
		jr $ra
		

