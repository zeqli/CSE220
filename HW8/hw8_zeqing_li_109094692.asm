	##########################################################################################################
	##													##			
	##			CSE 220 HW8									##
	##			Zeqing Li									##
	##			ID: 109094692									##
	##													##
	##													##	
	##########################################################################################################

.data
start_prompt: .asciiz "Welcome to the Cipher Program.\n"
opt_prompt_0: .asciiz "What would you like to do:\n"
opt_prompt_1: .asciiz "1. Encrypt/Decrypt with XOR cipher\n"
opt_prompt_2: .asciiz "2. Encrypt/Decrypt with ROT47 cipher\n"
opt_prompt_3: .asciiz "3. Encrypt/Decrypt with Vigenere cipher\n"
opt_prompt_4: .asciiz "4. Quit\n"
select_prompt: .asciiz "Slection: "
vopt_prompt_0: .asciiz "Vigenere: \n"
vopt_prompt_1: .asciiz "a. Generate Tabula Recta Table\n"
vopt_prompt_2: .asciiz "b. Encrypt Vigenere cipher\n"
vopt_prompt_3: .asciiz "c. Decrypt Vigenere cipher\n"
vopt_prompt_4: .asciiz "d. Return to Main Menu\n"
range_error_prompt: .asciiz "Please enter a valid value again.\n"
enter_text_prompt: .asciiz "Enter text: "
input_xor_prompt: .asciiz "Please enter a XOR value between[-128,127]: "
table_notification_pormpt: .asciiz "You must build the Tabula Recta first.\n"
enter_start_shift: .asciiz "Enter starting shift (0-25): "
enter_key_prompt: .asciiz "Enter Key: "
feedback_prompt: .asciiz " characters were encrypted/decrypted.\nThe text is now: "

str: .space 51
key: .space 51
table: .space 676

.text
main:
	li $v0, 4
	la $a0, start_prompt
	syscall
show_menu:	
	li $v0, 4
	la $a0, opt_prompt_0	#"What would you like to do:\n"
	syscall
	li $v0, 4
	la $a0, opt_prompt_1	#"1. Encrypt/Decrypt with XOR cipher\n"
	syscall
	li $v0, 4
	la $a0, opt_prompt_2	#"2. Encrypt/Decrypt with ROT47 cipher\n"
	syscall
	li $v0, 4
	la $a0, opt_prompt_3	#"3. String check\n"
	syscall
	li $v0, 4
	la $a0, opt_prompt_4	#"4. Quit\n"
	syscall
	li $v0, 4
	la $a0, select_prompt	#"Slection: "
	syscall
read_opt1:	
	li $v0, 5		# read character
	syscall
	move $t0, $v0		# move input to t0
	
	li $t1, 1
	li $t2, 2
	li $t3, 3
	li $t4, 4
	
	beq $t0, $t1, Enter_text
	beq $t0, $t2, Enter_text
	beq $t0, $t3, goto3
	beq $t0, $t4, goto4
	
	li $v0, 4
	la $a0, range_error_prompt
	syscall
	j read_opt1
Enter_text:	
	li $v0, 4
	la $a0, enter_text_prompt
	syscall
	
	li $v0, 8	# read string
	la $a0, str	# set str[] as buffer
	li $a1, 50	# 50 characters long string	
	syscall
	#move $t0, $a0	# set t3 to the address of string
	beq $t0, $t1, goto1
	beq $t0, $t2, goto2
	beq $t0, $t3, goto3
	beq $t0, $t4, goto4
	
	
goto1:	jal XORcipher
	j print_result
goto2:	jal ROT47cipher
	j print_result
goto3:	li $s0, 0		# set a flag to indicate if the table been built
	jal Vigenere
	j print_result
goto4:	
	j return0
print_result:
	move $a0, $v0
	
	li $v0, 1
	syscall
	
	li $v0, 4
	la $a0, feedback_prompt
	syscall
	
	li $v0, 4
	la $a0, str
	syscall 
	
	li $v0, 11		# print character
	li $a0, 10
	syscall
	
	j show_menu
	

XORcipher:
#########################
#    input(addr. a0) 
#    t0: address
#    t1: xor value
#    t2: counter
#    t3: temp
#    return: v0--character being encrypted
#########################
xor_get_value:
	li $t2, 0 		# init counter
	move $t0, $a0		# set t0 as the addr of str
	li $v0, 4
	la $a0, input_xor_prompt	# "Please enter a XOR value between[-128,127]: "
	syscall
	
	li $v0, 5
	syscall
	
	blt $v0, -128, xor_get_value
	bgt $v0, 127, xor_get_value
	
	move $t1, $v0		# move xor value to t1

	
loop1:	lb $t4, 0($t0)		# get one character from string
	beqz $t4, return1	# if encounter a NULL
	beq $t4, 10, return1 	# if encounter a newline
	
	xor $t4, $t4, $t1	# XOR cipher
	sb $t4, 0($t0)		# save byte to original string
	
	addi $t2, $t2, 1 	# counter++
	addi $t0, $t0, 1 	# address increase
	j loop1
return1:
	move $v0, $t2
	jr $ra

ROT47cipher:
#########################
#    input(addr. a0) 
#    a0, t0: address
#    t1: counter
#    t3: temp
#    return: v0--character being encrypted 
#########################
	##	if(32 < c < 80) 
	##		c  = c + 47
	##	if(79 < c < 127)
	##		c = c - 47
	##
	li $t1,0
	move $t0, $a0
	
loop2: 	lb $t3, 0($t0)
	beqz $t3, return2	# if encounter a NULL
	beq $t3, 10, return2 	# if encounter a newline
	blt $t3, 33, continue2	# if byte value is less than 33
	bgt $t3, 126, continue2	# if byte value is greater than 126
	ble $t3, 79, cipher_add		
	addi $t3, $t3, -47
	j next2
cipher_add:
	addi $t3, $t3, 47
next2:
	addi $t1, $t1, 1	# counter++
continue2:
	sb $t3, 0($t0)		# store byte to memory
	addi $t0, $t0, 1	# increase addr.
	j loop2
return2: 
	move $v0, $t1		# return counter
	jr $ra
	
	
Vigenere:
	li $v0, 4
	la $a0, vopt_prompt_0	#"Vigenere: \n"
	syscall
	li $v0, 4
	la $a0, vopt_prompt_1	#"a. Generate Tabula Recta Table\n"
	syscall
	li $v0, 4
	la $a0, vopt_prompt_2	#"b. Encrypt Vigenere cipher\n"
	syscall
	li $v0, 4
	la $a0, vopt_prompt_3	#"c. Decrypt Vigenere cipher\n"
	syscall
	li $v0, 4
	la $a0, vopt_prompt_4	#"d. Return to Main Menu\n"
	syscall
	li $v0, 4
	la $a0, select_prompt	#"Slection: "
	syscall
	
read_opt2:	
	li $v0, 12		# read character
	syscall
	move $t0, $v0		# move input to t0
	
	li $v0, 12		# get char
	syscall
	
	li $v0, 11		# print character
	li $a0, 10
	syscall
	
	li $t1, 97		# t1 = a
	li $t2, 98		# t2 = b
	li $t3, 99		# t3 = c
	li $t4, 100		# t4 = d
	
	beq $t0, $t1, jump1
	beq $t0, $t2, jump2
	beq $t0, $t3, jump3
	beq $t0, $t4, jump4
	
	la $a0, range_error_prompt
	li $v0, 4
	syscall
	j read_opt2
	
jump1:	li $v0, 4
 	la $a0, enter_start_shift
 	syscall
 	
 	li $v0, 5		# read range
 	syscall
 	move $a1, $v0

	bltz $a1, jump1
	bgt $a1,25, jump1
	 
	la $a0, table
	jal TabulaRecta
	li $s0, 1		# indicate table have been built
	j Vigenere
jump2:	
	beqz $s0, warning
	jal VEncrypt
	j Vigenere
jump3:	
	beqz $s0, warning
	jal VDecrypt
	j Vigenere
jump4:	
	j show_menu
warning:
	li $v0, 4
	la $a0, table_notification_pormpt
	syscall
	j jump1


TabulaRecta:
########################
#    input:a0--the base address of the table in memory
#          a1--the initial letter
#
#	   t0--a0
#	   t1--a1
#	   t2--i
#	   t3--j
#	   t4--letter in the alphabet, which is 26
#	   t5--cursor
#	   t6--temp
#    return None
########################
	addi $sp,$sp,-8 # save registers on stack
	sw $a0,0($sp)

	sw $ra,4($sp)
	move $t0, $a0		# t1 = addr.
	move $t1, $a1		# t2 = start
	li $t2, 0		# i = 0
	li $t3, 0		# j = 0
	li $t4, 26
while1:
	bge $t2, $t4, table_end 	# if i >= 26 then break
	li $t3, 0
while2:
	bge $t3, $t4, while1_cont	# if j >= 26 then break
	move $t5, $t4		# set t5 == 26 # of colomn
	mult $t5, $t2		# (#of colomn)*i
	mflo $t5
	add $t5, $t5, $t3	# (#of colomn)*i + j
	add $t5, $t5, $t0	# table[i][j]
	li $t6, 65		# t6 = 'A'
	add $t6, $t6, $t1	# t6 = start + 'A'
	sb $t6, 0($t5)	
	addi $t1, $t1, 1	# start = start + 1
	div $t1, $t4
	mfhi $t1
	addi $t3, $t3, 1	# j = j + 1
	j while2
while1_cont:
	addi $t1, $t1, 1	# start = start + 1
	div $t1, $t4
	mfhi $t1
	addi $t2, $t2, 1	# i = i + 1
	j while1
table_end:
	jal printTabulaRecta
	
	lw $a0,0($sp)
	lw $ra,4($sp)
	addi $sp,$sp,8 # restore registers on stack
	jr $ra
	
	
	

printTabulaRecta:		# print the Tabula Recta table on the screen
########################
#    input(a0--the base address of the table in memory)
#    return None
########################
	move $t0, $a0		# t1 = addr.
	li $t2, 0		# i = 0
	li $t3, 0		# j = 0
	li $t4, 26
pwhile1:
	bge $t2, $t4, ptable_end 	# if i >= 26 then break
	li $t3, 0		# j = 0
pwhile2:
	bge $t3, $t4, pwhile1_cont	# if j >= 26 then break
	move $t5, $t4		# set t5 == 26 # of colomn
	mult $t5, $t2		# (#of colomn)*i
	mflo $t5
	add $t5, $t5, $t3	# (#of colomn)*i + j
	add $t5, $t5, $t0	# table[i][j]
	lb $t6, 0($t5)		# load character from table
	
	li $v0, 11		# print character
	move $a0, $t6
	syscall
	
	li $v0, 11		# print character
	li $a0, 32
	syscall
	
	addi $t3, $t3, 1	# j = j + 1
	j pwhile2
pwhile1_cont:
	li $v0, 11		# print new line
	li $a0, 10
	syscall 
	addi $t2, $t2, 1	# i = i + 1
	j pwhile1
ptable_end:
	jr $ra

	

VEncrypt:
########################
#    input:a0--the base address of the text string
#	   a1--the length of the text string
#	   a2--the base address of the key
#	   a3--the base address of the Tabula Recta table
#	   t4--counter
#    return: v0--number of characters encrpyted
########################
	addi $sp,$sp,-20 # save registers on stack
	sw $a0,0($sp)
	sw $a1,4($sp)
	sw $a2,8($sp)
	sw $a3,12($sp)
	sw $ra,16($sp)
	
	move $t0, $a0		# copy addr to to
	move $t1, $a1		# copy addr to t1
	move $t2, $a2		# copy addr to t2
	move $t3, $a3		# copy addr to t3	
get_input1:
	li $v0, 4
	la $a0, enter_text_prompt
	syscall
	
	li $v0, 8	# read string
	la $a0, str	# set str[] as buffer
	li $a1, 50	# 50 characters long string	
	syscall
	jal STRCHECK
	move $t5, $v0	# get length of string
	move $t6, $v1	# get flag
	beq $t6, 1, get_input1
	
	li $v0, 4
	la $a0, enter_key_prompt
	syscall
	
	li $v0, 8	# read key
	la $a0, key	# set key[] as buffer
	li $a1, 50	# 50 characters long string	
	syscall
	jal STRCHECK
	move $t7, $v0	# get length of string
	move $t6, $v1	# get flag
	beq $t6, 1, get_input1
	beq $t5, $t7, get_input1
########################
#    input:a0--the base address of the text string
#	   a1--the length of the text string
#	   a2--the base address of the key
#	   a3--the base address of the Tabula Recta table
#	   t4--counter
#	t5-- i
#	t6 -- j
#	t1-- k
#	t7 -- text length
#	t8-- plain text
#	t9-- ky
#    return: v0--number of characters encrpyted
########################	
	li $t5, 0	# i = 0
	li $s1, 26	# number of alphabet
while3: bge $t5, $t7,break_while
	lb $t8, 0($t0)	# char p := plaintext[i] 
	lb $t9, 0($t2)	# char ky := key[i] 
	li $t6, 0	#j = 0
	li $t1, 0	#k = 0
while4:	bge $t6, $s1,while5
	move $s4, $s1
	add $s4, $s4, $t6
	add $s4, $s4, $t3	# add table base addr
	lb $s3, 0($s4)		# s3 = table[0][j]
	beq $t8, $s3, while5		# if equal
	add $t6, $t6, 1
	j while4
while5: bge $t1, $s1,while3_cont
	move $s4, $s1
	mult $s4, $t1		# num of alphabet * k
	mflo $s4
	add $s4, $s4, $t3	# add table base addr
	lb $s3, 0($s4)		# s3 = table[k][0]
	beq $t9, $s3, while3_cont		# if equal
	add $t1, $t1, 1
	j while4
while3_cont:
	move $s4, $s1
	mult $s4, $t1		# num of alphabet * k
	mflo $s4
	add $s4, $s4, $t6
	add $s4, $s4, $t3	# add table base addr
				#plaintext[i] (t0)= table[k][j] (t3)
	lb $s6, 0($s4)
	
	add $t5, $t5, 1		# i ++
	
	
	
break_while
	lw $a0,0($sp)
	lw $a1,4($sp)
	lw $a2,8($sp)
	lw $a3,12($sp)
	lw $ra,16($sp)
	addi $sp,$sp,16 # restore registers on stack
	jr $ra

VDecrypt:
	addi $sp,$sp,-20 # save registers on stack
	sw $a0,0($sp)
	sw $a1,4($sp)
	sw $a2,8($sp)
	sw $a3,12($sp)
	sw $ra,16($sp)
	
	move $t0, $a0		# copy addr to t0
	move $t1, $a1		# copy addr to t0
	move $t2, $a2		# copy addr to t0
	move $t3, $a3		# copy addr to t0	
get_input2:
	li $v0, 4
	la $a0, enter_text_prompt
	syscall
	
	li $v0, 8	# read string
	la $a0, str	# set str[] as buffer
	li $a1, 50	# 50 characters long string	
	syscall
	jal STRCHECK
	move $t5, $v0	# get length of string
	move $t6, $v1	# get flag
	beq $t6, 1, get_input2
	
	li $v0, 4
	la $a0, enter_key_prompt
	syscall
	
	li $v0, 8	# read key
	la $a0, key	# set key[] as buffer
	li $a1, 50	# 50 characters long string	
	syscall
	jal STRCHECK
	move $t7, $v0	# get length of string
	move $t6, $v1	# get flag
	beq $t6, 1, get_input2
	beq $t5, $t7, get_input2
	
	
	
	
	
	lw $a0,0($sp)
	lw $a1,4($sp)
	lw $a2,8($sp)
	lw $a3,12($sp)
	lw $ra,16($sp)
	addi $sp,$sp,16 # restore registers on stack
	jr $ra
	jr $ra

STRCHECK:	
#########################
#    input(addr. a0) 
#    a0, t0: address
#    t1: counter
#    t3: temp
#    return: v0--length of string v1--flag
#########################
	li $t1, 0		# init return value
	li $t2, 0		# init counter
	move $t0, $a0		# set t0 as the address of string

loop3:	lb $t4, 0($t0)		# get one character from string
	beqz $t4, return3	# if encounter a NULL
	beq $t4, 10, return3 	# if encounter a newline
	
	blt $t4, 65, setfalse
	bgt $t4, 122, setfalse
	# now t4 at the range of [65,122]
	blt $t4, 91, next
	# now t4 at the range of [91, 122]
	blt $t4, 97, setfalse
	# now t4 at the range of [97, 122]
	addi $t4, $t4, -32	# convert to uppercase\
	sb $t4,0($t0)		# save back to memory
	
next:	addi $t2, $t2, 1	 # counter++
	addi $t0, $t0, 1 	# address increase
	j loop3

setfalse:
	li $t1, 1
	j next
return3:
	move $v0, $t2		# return length of string
	move $v1, $t1		# if valid return 0, else return 1
	jr $ra 			# return

return0:
	li $v0, 10
	syscall
	
	
