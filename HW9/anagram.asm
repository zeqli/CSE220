.data
str_prompt: .asciiz "Please input the string: "
word: .space 9

.textstring
main:

	li $v0, 4
	la $a0, str_prompt
	syscall
	
	
	li $v0, 8
	la $a0, word
	li $a1, 8
	syscall
	move $s0, $a0
	
	jal STRLEN
	move $a0, $v0
	li $v0, 1
	syscall
	
	move $a1, $a0
	move $a0, $s0
	jal anagram
	
	li $v0, 10
	syscall
	
##	suppose we know the n of the string
##	a0 -- word address, a1 -- n, s0 -- i
anagram:	addi $sp, $sp, -16		# Adjust sp
		sw $a0, 0($sp)			# Save word address
		sw $a1, 4($sp)			# Save n
		sw $ra, 8($sp)			# Save $ra

		bne $a1, 1, ELSE1		# if(n==1) (Branch if n != 1)
		li $v0, 4			# printf("%s", word)
		syscall

		j end_anagram
		
		
ELSE1:		move $s0, $zero			# i = 0
		lw $a1, 4($sp)			# a1 = n
		
FOR:		lw $a1, 4($sp)			# restore n
		lw $a0, 0($sp)			# restore addr
		
		bge $s0, $a1, end_anagram	# while i > n	# for(int i = 0; i < n; i++)	
		
		addi $a1, $a1, -1		# n = n - 1
		sw $s0, 12($sp)			# store i
		jal anagram			# anagram(word, n-1);
		
		lw $a0, 0($sp)			# restore a0 = addr
		lw $s0, 12($sp)			# restore s0 = i
		lw $a1, 4($sp)			# load a1 = n
		
		add $t0, $a0, $zero		# t0 = addr[0]
		add $a1, $a1, -1		# a1 = n-1
		add $t1, $a1, $a0		# t1 = addr[n-1]
		
		li $t3, 2
		div $a1, $t3			# $t1 = n % 2
		mfhi $t3
		
		bne $t3, 1, ELSE2		# if(n % 2)
		
		# swap word[0] and word[n-1]		
		lb $t3, 0($t0)			# tmp1 = addr[0] 
		lb $t4, 0($t1)			# tmp2 = addr[n-1]
		sb $t4, 0($t0)			# addr[0] = addr[n-1](tmp2)
		sb $t3, 0($t1)			# addr[n-1] = tmp1
				
		addi $s0, $s0, 1		# i++
		j FOR	
ELSE2:					
		add $t0, $a0, $zero		# t0 = addr[0]
		add $t0, $t0, $s0		# t0 = addr[i]
		
		lb $t3, 0($t0)			# tmp1 = addr[i] 
		lb $t4, 0($t1)			# tmp2 = addr[n-1]
		sb $t4, 0($t0)			# addr[i] = addr[n-1](tmp2)
		sb $t3, 0($t1)			# addr[n-1] = tmp1		

		
		addi $s0, $s0, 1		# i++
		j FOR

end_anagram:	lw $ra, 8($sp)			# Restore return address
		
		addi $sp, $sp, 16		# Adjust sp
		jr $ra
		
##		$a0--addr of str
##		$v0--length of str
STRLEN:		
		add $t0, $zero, $a0	# t0 = addr[0](index)
		add $t1, $zero, $zero	# counter t1 = 0
loop:		lb $t3, 0($t0)
		beq $t3, 0, RETURN
		beq $t3, 10, RETURN
		addi $t0, $t0, 1
		addi $t1, $t1, 1	# increment counter
		j loop
		
RETURN: 	add $v0, $zero, $t1
		jr $ra
		

