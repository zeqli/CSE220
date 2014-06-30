.data
str: .asciiz "The result is: "
.text

main:
		li $a0, 2
		li $a1, 5
		jal Power
		
		move $t0, $v0
		
		la $a0, str
		li $v0, 4
		syscall
		
		move $a0, $t0
		li $v0, 1
		syscall
		
		li $v0, 10
		syscall
		
##  Add (firstOperand, secondOperand) return firstOperand + secondOperand 
##  a0--firstOp, a1--secondOp
Add:		add $sp,$sp, -12
		sw $ra, 0($sp)
		sw $a0, 4($sp)
		sw $a1, 8($sp)
		add $v0, $a0, $a1
		j end_Add
end_Add:
		lw $ra, 0($sp)
		lw $a0, 4($sp)
		lw $a1, 8($sp)
		add $sp,$sp, 12
		jr $ra
		
##  Subtract (firstOperand, secondOperand) return firstOperand - secondOperand
##  a0--firstOp, a1--secondOp
Substract:	add $sp,$sp, -12
		sw $ra, 0($sp)
		sw $a0, 4($sp)
		sw $a1, 8($sp)
		sub $v0, $a0, $a1
		j end_Substract
end_Substract:
		lw $ra, 0($sp)
		lw $a0, 4($sp)
		lw $a1, 8($sp)
		add $sp,$sp, 12
		jr $ra
		
		
##  Multiply (firstOperand, secondOperand) return firstOperand * secondOperand 
##  a0--firstOp, a1--secondOp
Multiply:	add $sp,$sp, -12
		sw $ra, 0($sp)
		sw $a0, 4($sp)
		sw $a1, 8($sp)
		mult $a0, $a1
		mflo $v0
		j end_Multiply
end_Multiply:
		lw $ra, 0($sp)
		lw $a0, 4($sp)
		lw $a1, 8($sp)
		add $sp,$sp, 12
		jr $ra
		
		
##  Integer Division (firstOperand, secondOperand) return firstOperand / secondOperand
##  a0--firstOp, a1--secondOp
Integer_Division:add $sp,$sp, -12
		sw $ra, 0($sp)
		sw $a0, 4($sp)
		sw $a1, 8($sp)
		div $a0, $a1
		mflo $v0
		j end_Integer_Division
end_Integer_Division:
		lw $ra, 0($sp)
		lw $a0, 4($sp)
		lw $a1, 8($sp)
		add $sp,$sp, 12
		jr $ra



##   (firstOperand, secondOperand) return firstOperand^secondOperand
##  a0--n, a1--e
Power:		add $sp,$sp, -12
		sw $ra, 0($sp)
		sw $a0, 4($sp)
		sw $a1, 8($sp)
		li $t0, 0
		beqz $a1, Power_return1		# if e = 0 then result = 1
		beq $a1, 1, Power_returnN	# if e = 1 then result = n
		j Power_returnRec		# if e > 1 then retult = Power(n, e-1) * n
		
Power_return1:	
		li $t0, 1
		j end_Power
Power_returnN:
		add $t0, $a0, $zero
		j end_Power
Power_returnRec:
 		addi $a1, $a1, -1		# e = e - 1
		jal Power			# Power(n, e - 1)
		mult $v0, $a0			# Power(n, e - 1) * n
		mflo $t0
		j end_Power
end_Power:
		lw $ra, 0($sp)
		lw $a0, 4($sp)
		lw $a1, 8($sp)
		add $sp,$sp, 12
		move $v0, $t0
		jr $ra
		


##   RotateRight(firstOperand, secondOperand) 
##  a0--firstOperand, a1--secondOperand
RotateRight:	add $sp,$sp, -12
		sw $ra, 0($sp)
		sw $a0, 4($sp)
		sw $a1, 8($sp)
		ror $v0, $a0, $a1
end_RotateRight:
		lw $ra, 0($sp)
		lw $a0, 4($sp)
		lw $a1, 8($sp)
		add $sp,$sp, 12
		jr $ra
		

##   RotateLeft(firstOperand, secondOperand) 
##  a0--firstOperand, a1--secondOperand
RotateLeft:	add $sp,$sp, -12
		sw $ra, 0($sp)
		sw $a0, 4($sp)
		sw $a1, 8($sp)
		rol $v0, $a0, $a1
end_RotateLeft:
		lw $ra, 0($sp)
		lw $a0, 4($sp)
		lw $a1, 8($sp)
		add $sp,$sp, 12
		jr $ra