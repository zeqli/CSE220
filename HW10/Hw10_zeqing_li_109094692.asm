	##########################################################################################################
	##													##			
	##			CSE 220 HW9									##
	##			Zeqing Li									##
	##			ID: 109094692									##
	##													##
	##													##	
	##########################################################################################################


#####################################
#Data Section
#####################################

.data

inStr: 	.space 51
postStr: .space 51
selection: .space 3
token: .space 51
intro:	.asciiz "\nCalculator\n"
selection_prompt: .asciiz "\nPlease Enter 1 for Infix or 2 for Postfix: "
prompt: .asciiz "\nPlease enter the string to calculate: "
result: .asciiz "\nThe Result of " 
is:     .asciiz " is: "
reAsk: .asciiz "\nYou have entered a wrong value. Please select again."
prompt_for_more: .asciiz "\nAnother calculation (Y/N)?"

#####################################
#Text Section
#####################################
.text
.globl main

main:
		la $a0,intro        # print Program Introduction "Calculator"
		li $v0,4
		syscall

begin:		la $a0,selection_prompt	# print Prompt
		li $v0,4
		syscall

select:	  	la $a0,selection       # read in 1 or 2 for infix or postfix or Y/N of quit
    		li $a1,3
    		li $v0,8
    		syscall

		lb $t0,0($a0)          # get first char of input
				
		beq $t0,'N',Exit       # Check for Y/N input
		beq $t0,'n',Exit
		beq $t0,'Y',begin
		beq $t0,'y',begin
				
		blt $t0,'1',repeat     # Invalid input not 1 or 2, go to Repeat to repromt and ask again
		bgt $t0,'2',repeat     

		la $a0,prompt          # Valid Choice (1 or 2). Prompt for calculation string
		li $v0,4
		syscall
				
		la $a0,inStr           # Read in String 
		li $a1,51
		li $v0,8
		syscall
				
		bne $t0,'1',postfix    # if value is 2, goto call for PostFix
				                       # parameter: address of string in $a0
		jal ProcessInfix       # call Infix
	       	j print_result         # goto print result 

postfix:    	                       # parameter: address of string in $a0
		jal ProcessPostfix     # call Postfix
		j print_result         # goto print result 

print_result:	move $t5, $v0          #preserve the $v0 value before printing
                la $a0, result         #print Result text
		li $v0,4
		syscall

                la $a0, inStr          #print inputted expression text
                jal strlen
                addi $t0, $v0, -1
                add $t0, $a0, $t0
                lb $t1, 0($t0)
                bne $t1, 10, go_on
                add $t1, $zero, $zero
                sb $t1, 0($t0)
go_on:		li $v0, 4
		syscall

                la $a0, is             #print is text
		syscall

                add $a0,$t5,$0         #print result value
		li $v0,1
		syscall

ask_for_more:	la $a0,prompt_for_more # print out prompt for program repeat
		li $v0,4
		syscall
		j select               # goto read input

repeat:		la $a0,reAsk            # Print reenter prompt
		li $v0,4
		syscall
		j begin                      

Exit:		li $v0,10
		syscall

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

################################# ProcessInfix #########################################
## 	$a0 -- input str, s1 -- token
ProcessInfix:
		addi $sp, $sp, -8
		sw $ra, 0($sp)
		sw $a0, 4($sp)
		jal tokenizer
		move $s1, $v0		# s1 == token address
		
		lb $s3, 0($s1)		# $v0 = char* token
		move $s0, $v1		# store next postion to $s0
PI_WHILE:	beq $s3, 0, stack_WHILE	# is str hit to end
		
		
PI_if_IS_NUM:	# we can determine if token is a number by examine first element
		blt $s3, 48, PI_if_IS_OP
		bgt $s3, 57, PI_if_IS_OP
		
		move $a0, $s1		# copy token adderss.
		jal AddToPostStr	# queue.add(token
		
		j PI_WHILE_CONT
PI_if_IS_OP:	move $a0, $s3		# isOperater((*token))
		jal isOperater		# if true then return 1, else 0
		beqz $v0, PI_else_if_IS_LP
		move $a1, $a0		# if token is operater, denote $a1 as o1 
		
	OP_WHILE:	peek($a0)		# o2 = stack peek
			jal isOperater		# if true then return 1, else 0
			beqz $v0, OP_WHILE_NEXT	# if o2 is not a operater
			beq $a1, 94, OP_WHILE_NEXT # if o2 is exp than push without heisitate
			jal precedence		# precedence(o2, o1) $a0 = o2, $a1 = o1
			bltz $v0, OP_WHILE_NEXT	# while(... precedence (o2, o1) >= 0)
		
			pop($a0)		# pop
			
			sb $a0, 0($s1)		# set token = 'P'
			sb $zero, 1($s1)	# set token = 'P\0'
			move $a0, $s1		# copy token adderss.
			jal AddToPostStr	# queue.add(token)
			j OP_WHILE
		
	OP_WHILE_NEXT:	push($s3)		# push o1
			
			j PI_WHILE_CONT

PI_else_if_IS_LP:	
		bne $s3, 40, PI_else_if_IS_RP	# 40 '('
		push($s3)
		j PI_WHILE_CONT
PI_else_if_IS_RP:
		bne $s3, 41, PI_WHILE_CONT	# 41 ')'
	RP_WHILE:	pop($t1)
			beq $t1, 40, PI_WHILE_CONT
			
			sb $t1, 0($s1)		# set token = 'P'
			sb $zero, 1($s1)	# set token = 'P\0'
			move $a0, $s1		# copy token adderss.
			jal AddToPostStr	# queue.add(token)
			
			j RP_WHILE
	# there supposed to be mismatch 
		

PI_WHILE_CONT:

		
		move $a0, $s0		# update new start position
		jal tokenizer
		move $s1, $v0		# s1 == token address
		lb $s3, 0($s1)		# $v0 = char* token
		move $s0, $v1		# store next postion to $s0
		j PI_WHILE		
			


stack_WHILE:	lw $t9, 0($gp)
		beqz $t9, end_ProcessInfix		# if stack size equal to 0 then end
		pop($a0)		# pop
		sb $a0, 0($s1)		# set token = 'P'
		sb $zero, 1($s1)	# set token = 'P\0'
		move $a0, $s1		# copy token adderss.
		jal AddToPostStr	# queue.add(token)

		j stack_WHILE
		
		
	
end_ProcessInfix:
		la $a0, postStr		# print out converted string
		li $v0, 4
		syscall
		
		jal ProcessPostfix	# return ProcessPostfix
		
		lw $ra, 0($sp)
		lw $a0, 4($sp)
		addi $sp, $sp, 8
		jr $ra
		
################################# ProcessPostfix ##################################33
## 	$a0 -- input str, $s1 -- token, $t1 -- op_1, $t2 -- op_2, $t3 -- result
##	$s0 -- pointer new location in tokenizer
ProcessPostfix: addi $sp, $sp, -4
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
		jal resetPostStr
		pop($v0)
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
		
######################### RESETPOSTSTR ########################
resetPostStr:	addi $sp, $sp, -4
		sw $ra, 0($sp)
		la $a0, postStr
		lb $t1, 0($a0)
reset_WHILE:	beqz $t1, end_reset
		sb $zero, 0($a0)
		addi $a0, $a0, 1	# increment index
		lb $t1, 0($a0)
		j reset_WHILE

end_reset:	lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra		
		
		
############################ EVALUATE ######################################
##      a3 -- token, a1 -- firstOperand, a2 -- secondOperand	
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
############################ IS OPERATOR ######################################	
##      a0 -- token	
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

			
################################# ADD TO POSTSTRL################
## 	$a0 -- token that will be added to poststr
AddToPostStr:
		addi $sp, $sp, -8
		sw $a0, 0($sp)
		sw $a1, 4($sp)
		la $a1, postStr		# get postStr address
		lb $t0, 0($a1)		# load first byte
AddToPostStr_WHILE:
		beqz $t0, AddToPostStr_NEXT
		addi $a1, $a1, 1	# increment a1
		lb $t0, 0($a1)		# load byte
		j AddToPostStr_WHILE
AddToPostStr_NEXT: 
		# at this time $t0 == 0
		lb $t0, 0($a0)		
AddToPostStr_WHILE2:
		beqz $t0, end_AddToPostStr
		sb $t0, 0($a1)	
		addi $a1, $a1, 1	# increment a1
		addi $a0, $a0, 1	# increment a0
		lb $t0, 0($a0)
		j AddToPostStr_WHILE2

end_AddToPostStr:
		li $t0, 32		# insert white space
		sb $t0, 0($a1)		# restore it back
		addi $a1, $a1, 1	# increment a1
		li $t0, 0
		sb $t0, 0($a1)		# append \0 to the end
		
		lw $a0, 0($sp)		
		lw $a1, 4($sp)
		addi $sp, $sp, 8
		jr $ra
		
################################# STRLEN ########################
##	$a0 -- input str, $v0, len
strlen:		addi $sp, $sp, -8
		sw $a0, 0($sp)
		sw $ra, 4($sp)
		li $t0, 0		# init counter
		lb $t1, 0($a0)
strlen_WHILE:	beqz $t1, end_strlen
		addi $t0, $t0, 1	# increment counter
		addi $a0, $a0, 1	# increment index
		lb $t1, 0($a0)
		j strlen_WHILE

end_strlen:	move $v0, $t0
		lw $a0, 0($sp)
		lw $ra, 4($sp)	
		addi $sp, $sp, 8
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
############################### precedence #################################
.macro get_Pre (%x)
		beq %x, 43, lowest	# '+'
		beq %x, 45, lowest	# '-'
		beq %x, 42, medium	# '*'
		beq %x, 47, medium	# '/'
		beq %x, 60, medium	# '<'
		beq %x, 62, medium	# '>'
		beq %x, 94, highest	# 'exp'	
		li %x, 0	
		j end_macro
		

lowest:		li %x, 2
		j end_macro
medium:		li %x, 3
		j end_macro
highest:	li %x, 4
		j end_macro
end_macro:
.end_macro	
## precedence a0 -- o1, a1 -- o2
precedence: 
		addi $sp, $sp, -12
		sw $a0, 0($sp)
		sw $a1, 4($sp)
		sw $ra, 8($sp)
		get_Pre($a0)
		get_Pre($a1)
		beq $a0, $a1, return0
		bgt $a0, $a1, return1
		li $v0, -1
		j end_precedence
return0:	li $v0, 0
		j end_precedence
return1:	li $v0, 1
		j end_precedence
end_precedence:	
		lw $a0, 0($sp)
		lw $a1, 4($sp)
		lw $ra, 8($sp)
		addi $sp, $sp, 12
		jr $ra			

