	##########################################################################################################
	##													##			
	##			CSE 220 HW8									##
	##			Zeqing Li									##
	##			ID: 109094692									##
	##													##
	##													##	
	##########################################################################################################
	
.data
input_prompt: .asciiz "please input the fac value: "
result_prompt: .asciiz "the factorial of the number is: "
exit_prompt: .asciiz "detected you have input a zero, promgram terminal"

.text
main:
	li $v0, 4
	la $a0, input_prompt
	syscall
	
	li $v0, 5
	syscall
	
	beqz $v0, exit
	
	move $a0, $v0
	jal fac
	move $a0, $v0
	li $v0, 1
	syscall
	j main

fac:	addi $sp, $sp, -12		# Adjust sp
	move $t0, $a0			# t1 = n
	addi $t1, $a0, -1		# Compute t1 = n - 1
	sw $t0, 0($sp)			# Save n to stack
	sw $t1, 4($sp)			# Save n - 1 to stack
	sw $ra, 8($sp)			# Save return address
	bgt $a0, 1, ELSE		# branch ! ( n <= 1)
	li $v0, 1			# Set return value to 1
	add $sp, $sp, 12		# Adjust Sp
	jr $ra				# Return
	
ELSE:	move $a0, $t1			# fac ( n - 1 )
	jal fac				
	lw $t0, 0($sp)			# Set t0 = n
	mult $t0, $v0			# n * fact( n - 1 )
	mflo $v0			# put result in v0
	lw $ra, 8($sp)			# restore return address from stack
	addi $sp, $sp, 12		# Adjust sp
	jr $ra				# Return
	
exit: 	
	li $v0, 4
	la $a0, exit_prompt
	syscall
	
	li $v0, 10
	syscall