.data
inStr: .asciiz "3 + 4 * 2 / ( 1 - 5 ) ^ 2 ^ 3 "  # 3 + 4 * 2 / 65536 
postStr: .space 51
token: .space 51
stk_size: .word 0
.text
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

main:		la $gp, stk_size
		la $a0, inStr
		jal ProcessInFix
		
		la $a0, postStr
		li $v0, 4
		syscall
		
		li $v0, 10
		syscall


## 	$a0 -- input str, s1 -- token
ProcessInFix:
		addi $sp, $sp, -8
		sw $ra, 0($sp)
		sw $a0, 4($sp)
		jal tokenizer
		move $s1, $v0		# s1 == token address
		
		lb $s3, 0($s1)		# $v0 = char* token
		move $s0, $v1		# store next postion to $s0
PI_WHILE:	beq $s3, 0, stack_WHILE	# is str hit to end
		
		
if_IS_NUM:	# we can determine if token is a number by examine first element
		blt $s3, 48, if_IS_OP
		bgt $s3, 57, if_IS_OP
		
		move $a0, $s1		# copy token adderss.
		jal AddToPostStr	# queue.add(token
		
		j PI_WHILE_CONT
if_IS_OP:	move $a0, $s3		# isOperater((*token))
		jal isOperater		# if true then return 1, else 0
		beqz $v0, else_if_IS_LP
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

else_if_IS_LP:	
		bne $s3, 40, else_if_IS_RP	# 40 '('
		push($s3)
		j PI_WHILE_CONT
else_if_IS_RP:
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
		j strlen_WHILE

end_strlen:	move $v0, $t1
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
		move $t0, $a0		# Copy a0 to v0
		lb $t1, 0($t0)		# Load byte to t0
WHILE1:		bne $t1, 32, NEXT		# if meet space
		add $t0, $t0, 1		# Skip
		lb $t1, 0($t0)
		j WHILE1
NEXT:		la $t3, token

WHILE2:		beq $t1, 0, end_tokenizer
		beq $t1, 10, end_tokenizer
		beq $t1, 32, end_tokenizer
		sb $t1, 0($t3)
		add $t0, $t0, 1		
		add $t3, $t3, 1
		lb $t1, 0($t0)
		j WHILE2
		
end_tokenizer:	la $v0, token		# return token
		move $v1, $t0		# new start location
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
