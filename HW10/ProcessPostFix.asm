.data
str: .asciiz "3 4 2 * 1 5 - 2 3 ^ ^ / +" # result should be 1   
result_text: .asciiz "\nThe Result is " 
op1: .asciiz "\nThe first operand is: "
op2: .asciiz "\nThe second operand is: "
nl: .asciiz "\n"
token: .space 15
.text

.macro printOp1(%a)
	move $t4, %a
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	la $a0, op1
	li $v0, 4
	syscall
	move $a0, $t4
	li $v0, 1
	syscall
	la $a0, nl
	li $v0, 4
	syscall
	lw $a0, 0($sp)
	addi $sp, $sp, 4
.end_macro

.macro printOp2(%a)
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	la $a0, op2
	li $v0, 4
	syscall
	move $a0, %a
	li $v0, 1
	syscall
	la $a0, nl
	li $v0, 4
	syscall
	lw $a0, 0($sp)
	addi $sp, $sp, 4
.end_macro


.macro push (%x)
	addi $sp, $sp, -4
	sw %x, 0($sp)
	lw $t9, 0($gp)
	addi $t9, $t9, 1
	sw $t9, 0($gp)
.end_macro

.macro pop (%x)
	lw %x, 0($sp)
	addi $sp, $sp, 4
	lw $t9, 0($gp)
	addi $t9, $t9, -1
	sw $t9, 0($gp)
.end_macro

.macro peek(%x)
	lw %x, 0($sp)
.end_macro

		
		
		
		
		la $a0, str
		jal ProcessPostfix
		
		move $t0, $v0
		la $a0, result_text         #print Result text
		li $v0, 4
		syscall
		
		add $a0, $t0, $zero         #print result value
		li $v0,1
		syscall

		li $v0, 10
		syscall
################################# ProcessPostfix ##################################33
## 	$a0 -- input str, $s1 -- token, $t1 -- op_1, $t2 -- op_2, $t3 -- result
##	$s0 -- pointer new location in tokenizer
ProcessPostfix:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		jal tokenizer
		lb $s1, 0($v0)		# $s1 = first byte in token
		move $s0, $v1		# store next postion to $s0
PP_WHILE:	beq $s1, 0, end_ProcessPostfix	# is str hit to end
		move $a0, $s1		# isOperater((8token))
		jal isOperater
if_IS_OP:	beq $v0, 0, else_IS_OP
		move $a3, $a0
		pop($a1)		# secondOperand = stack.pop()
		pop($a0)		# firstOperand = stack.pop()
		jal Eval 		# Eval(firstOperand, secondOperand, token); 
		push($v0)		# result = eval(token, firstOperand, secondOperand);
	
		j PP_WHILE_CONT
else_IS_OP:
		la $a0, token
		jal atoi
		push($v0)

PP_WHILE_CONT:
		move $a0, $s0		# update new start position
		jal tokenizer
		move $s0, $v1
		lb $s1, 0($v0)
		j PP_WHILE		
			
end_ProcessPostfix:
		pop($v0)
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
	
		
		
		
############################ TOKENIZER ########################################
##	$a0 -- start location $v0 -- return token, $v1, new start location
tokenizer:
# Skip all the space 
		addi $sp, $sp -8
		sw $a0, 0($sp)
		sw $ra, 4($sp)
		lb $t1, 0($a0)		# Load byte to t1
WHILE1:		bne $t1, 32, NEXT		# if meet space
		add $a0, $a0, 1		# Skip space
		lb $t1, 0($a0)		# Load byte to t1
		j WHILE1
NEXT:		la $t3, token

WHILE2:		beq $t1, 0, end_tokenizer
		beq $t1, 10, end_tokenizer
		beq $t1, 32, end_tokenizer
		sb $t1, 0($t3)		# Store first element in token[0]
		add $a0, $a0, 1		
		add $t3, $t3, 1
		lb $t1, 0($a0)
		j WHILE2
		
end_tokenizer:	la $v0, token		# return token
		move $v1, $a0		# new start location
		li $t1, 0		
		sb $t1, 0($t3)		# Set null to the end
		lw $a0, 0($sp)
		lw $ra, 4($sp)
		addi $sp, $sp 8
		jr $ra				
############################ IS OPERATOR ######################################	
##      a0 -- token, a1 -- firstOperand, a2 -- secondOperand	
isOperater:	
		addi $sp, $sp, -8
		sw $a0, 0($sp)
		sw $ra, 4($sp)
		li $v0, 0	
		beq $a0, 43, isOperator_true	# '+'
		beq $a0, 45, isOperator_true	# '-'
		beq $a0, 42, isOperator_true	# '*'
		beq $a0, 47, isOperator_true	# '/'
		beq $a0, 60, isOperator_true	# '<'
		beq $a0, 62, isOperator_true	# '>'
		beq $a0, 94, isOperator_true	# 'exp'		
		j end_isOperater
isOperator_true:
		li $v0, 1
end_isOperater:	
		lw $a0, 0($sp)
		lw $ra, 4($sp)
		addi $sp, $sp, 8
		jr $ra	
		
############################ EVALUATE ######################################
##      a0 -- token, a1 -- firstOperand, a2 -- secondOperand	
Eval:		addi $sp, $sp, -16
		sw $ra, 0($sp)
		sw $a0, 4($sp)
		sw $a1, 8($sp)
		sw $a2, 12($sp)
		beq $a3, 43, A		# '+'
		beq $a3, 45, S		# '-'
		beq $a3, 42, M		# '*'
		beq $a3, 47, D		# '/'
		beq $a3, 60, RL		# '<'
		beq $a3, 62, RR		# '>'
		beq $a3, 94, E		# exp
		j end_Eval
A:		jal Add
		j end_Eval
S:		jal Substract
		j end_Eval
M:		jal Multiply
		j end_Eval
D:		jal Integer_Division
		j end_Eval
RL:		jal RotateLeft
		j end_Eval
RR:		jal RotateRight
		j end_Eval
E: 		jal Power
		j end_Eval
end_Eval:
		
		lw $ra, 0($sp)
		lw $a0, 4($sp)
		lw $a1, 8($sp)
		lw $a2, 12($sp)
		addi $sp, $sp, 16
		jr $ra
		
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

################################ HELPER OPERATION METHOD ##############################################

################################ ATOI #################################################################
## a0--pointer to token e.g. "123214"
atoi:		
		addi $sp, $sp, -8	# Adjust stack
		sw $a0, 0($sp)		
		sw $ra, 4($sp)
		li $t0, 0		# value = 0
WHILE:		lb $t1, 0($a0)
		blt $t1, 48 end_atoi	# Branch less than '0'
		bgt $t1, 57, end_atoi	# Branch greater than '9'
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
