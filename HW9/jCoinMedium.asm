.data
str1_prompt: .asciiz "I can obtain at most "
str2_prompt: .asciiz " zero coins from my 12 jCoin. "
word: .space 9

.text
main:
	li $a0, 100
	jal jCoinEx1
	move $t0, $v0
	
	li $v0, 4
	la $a0, str1_prompt
	syscall
	
	li $v0, 1
	move $a0, $t0
	syscall
	
	li $v0, 4
	la $a0, str2_prompt
	syscall
	
	
	li $v0, 10
	syscall
	
##	suppose we know the n of the string
##	a0 -- n, v0--return, a1--sum of jCoinEx1(n/2)+jCoinEx1(n/3)+jCoinEx1(n/4))
jCoinEx1:	addi $sp, $sp, -12		# Adjust sp
		sw $a0, 0($sp)			# Store n
		sw $ra, 4($sp)			# Store $ra

		bne $a0, 0, ELSE1		# if(n==0) (Branch if n != 0)
		li $v0, 1
		j jCoinEx1_Return
		
		
ELSE1:		
		add $a1, $zero, $zero		# init a1
		sw $a1, 8($sp)			# Store a1
		
		lw $a0, 0($sp)			# retore a0 = n
		li $t0, 2
		div $a0, $t0
		mflo $a0			# Set a0 = n/2
		jal jCoinEx1			# Get jCoinEx1(n/2)
		lw $a1, 8($sp)			# Restore a1
		add $a1, $a1, $v0
		sw $a1, 8($sp)			# Store a1
		
		lw $a0, 0($sp)			# restore a0 = n
		li $t0, 3
		div $a0, $t0
		mflo $a0			# Set a0 = n/3
		jal jCoinEx1			# Get jCoinEx1(n/3)
		lw $a1, 8($sp)			# Restore a1
		add $a1, $a1, $v0
		sw $a1, 8($sp)			# Store a1
		
		lw $a0, 0($sp)			# restore a0 = n
		li $t0, 4
		div $a0, $t0			
		mflo $a0			# Set t1 = n/4
		jal jCoinEx1			# Get jCoinEx1(n/4)
		lw $a1, 8($sp)			# Restore a1
		add $a1, $a1, $v0
		
		add $v0, $a1, $zero		# v0 = a1
		j jCoinEx1_Return
		

jCoinEx1_Return:
		lw $ra, 4($sp)			# Restore return address
		addi $sp, $sp, 12		# Adjust sp
		jr $ra
		
		

