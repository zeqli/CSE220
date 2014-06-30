	##########################################################################################################
	##													##			
	##			CSE 220 HW9									##
	##			Zeqing Li									##
	##			ID: 109094692									##
	##													##
	##													##	
	##########################################################################################################

.data
Enter_single_word: .asciiz "Enter a single word: "
anagram_str1: .asciiz "There are "
anagram_str2: .asciiz " anagrams.\n"
anagram_str3:  .asciiz "The anagrams are: \n"
Enter_start_jCoin_prompt: .asciiz "Enter a starting jCoin value: "
JCoinEx1_str1: .asciiz "I can obtain at most "
JCoinEx1_str2: .asciiz " zero coins from my "
JCoinEx1_str3: .asciiz " jCoin.\n"
JCoinEx2_return_prompt: .asciiz " jCoinEx2 returns "
JCoinEx2_return_end_prompt: ".\n"
macro1_str1_prompt: .asciiz "\n My jCoin is "
macro1_str2_prompt: .asciiz ". I currently have "
macro1_str3_prompt: .asciiz " zero jCoins\n"
macro2_str1_prompt: .asciiz "\tjCoin "
macro2_str2_prompt: .asciiz ", i="
macro2_str3_prompt: .asciiz ": I am exchanging jCoin "
newline: .asciiz "\n"
macro3_str1_prompt: .asciiz "\tjCoin "
macro3_str2_prompt: .asciiz " was exchanged for: "
macro3_str3_prompt: .asciiz " zero jCoins\n"
comma: .asciiz ", "
seed_prompt: .asciiz "Enter Seed:"
LFG_str1: .asciiz "\nj="
LFG_str2: .asciiz "\nValue: "
LFG_str3: .asciiz "\nLFG Value:"
str: .space 9

.text

.macro getNums %r %n
	li $a0, 3
	addi $a1, $zero, %n
	li $v0, 42
	syscall
	move %r, $a0
.end_macro

.macro printf(%a)
	li $v0, 4
	syscall
.end_macro
##		s7--i, s6--j, s5--value, s4--seed
		li $s5, -1
		li $s4, 0
		la $a0, Enter_single_word
		printf($a0)

		li $v0, 8
		la $a0, str
		li $a1, 8
		syscall		# get input
		
		jal strlen
		move $s0, $v0		# (s0)x = strlen(str)
		
		la $a0, anagram_str1
		printf($a0)
		
		move $a0, $s0
		jal factorial
		move $a0, $v0
		li $v0, 1
		syscall			# factorial output
		
		la $a0, anagram_str2
		printf($a0)
		
		la $a0, anagram_str3
		printf($a0)
		
		la $a0, str
		move $a1, $s0
		jal anagram
###############################################################
# 		TEST JCoin
###############################################################

		li $s7, 0		 # i = 0
FOR_COIN_EX1:
		bge $s7, 3, FOR_COIN_EX1_NEXT
		jal funkyfunc
		
		la $a0, Enter_start_jCoin_prompt
		printf($a0)
		
		li $v0, 5
		syscall
		move $s5, $v0	
		
		move $a0, $s5
		jal jCoinEx1		# jCoinEx1(value)
		move $t0, $v0
		
		la $a0, JCoinEx1_str1	# put "I can obtain..."
		printf($a0)
		
		move $a0, $t0		# 
		li $v0, 1
		syscall
		
		la $a0, JCoinEx1_str2
		printf($a0)
		
		li $v0, 1
		move $a0, $s5
		syscall
		
		la $a0, JCoinEx1_str3
		printf($a0)
		
		addi $s7, $s7, 1
		j FOR_COIN_EX1
FOR_COIN_EX1_NEXT:
		addi $s6, $s7, -1		# j = i-1
		move $t0, $s7
		add $s7, $s7, $s7
		add $s7, $s7, $t0		# i = i*3
WHILE:		bgt $s6, $s7, WHILE_NEXT
		jal funkyfunc
		la $a0, Enter_start_jCoin_prompt
		printf($a0)
		
		li $v0, 5
		syscall
		move $s5, $v0
		
		move $a0, $s5
		li $a1, 0
		jal jCoinEx2
		move $t0, $v0
		
		la $a0, JCoinEx2_return_prompt
		printf($a0)
		
		li $v0, 1
		move $a0, $t0
		syscall
		
		la $a0, JCoinEx2_return_end_prompt
		printf($a0)
		
		add $s6, $s6, 1		# j++
		
		la $a0, seed_prompt
		printf($a0)
		
		li $v0, 5
		syscall
		
		move $a1, $v0
		li $a0, 3
		li $v0, 40
		syscall
		
		getNums $t1, 10000		# Generates a random number between 0 <= n < 10000
		
		## TEST LFG2
		la $a0, LFG_str1
		printf($a0)
		
		li $v0, 1			# print j
		move $a0, $s6
		syscall
		
		la $a0, LFG_str2
		printf($a0)
		
		li $v0, 1			# print value
		move $a0, $s5
		syscall 
		
		la $a0, LFG_str3
		printf($a0)
		
		li $v0, 1
		li $a0, 0
		syscall

		
		addi $s6, $s6, 1
		j WHILE
	
WHILE_NEXT:	
		li $v0, 10
		syscall
		
		
######################################################################################################	
## 		t0, a0, t1,	
factorial:	addi $sp, $sp, -12		# Adjust sp
	move $t0, $a0			# t1 = n
	addi $t1, $a0, -1		# Compute t1 = n - 1
	sw $t0, 0($sp)			# Save n to stack
	sw $t1, 4($sp)			# Save n - 1 to stack
	sw $ra, 8($sp)			# Save return address
	bgt $a0, 1, factorial_else		# branch ! ( n <= 1)
	li $v0, 1			# Set return value to 1
	add $sp, $sp, 12		# Adjust Sp
	jr $ra				# Return
	
factorial_else:	move $a0, $t1			# fac ( n - 1 )
	jal factorial				
	lw $t0, 0($sp)			# Set t0 = n
	mult $t0, $v0			# n * fact( n - 1 )
	mflo $v0			# put result in v0
	lw $ra, 8($sp)			# restore return address from stack
	addi $sp, $sp, 12		# Adjust sp
	jr $ra				# Return		
######################################################################################################		
##	suppose we know the n of the string
##	a0 -- word address, a1 -- n, s0 -- i
anagram:	addi $sp, $sp, -16		# Adjust sp
		sw $a0, 0($sp)			# Save word address
		sw $a1, 4($sp)			# Save n
		sw $ra, 8($sp)			# Save $ra

		bne $a1, 1, anagram_else1		# if(n==1) (Branch if n != 1)
		li $v0, 4			# printf("%s", word)
		syscall

		j end_anagram
		
		
anagram_else1:		move $s0, $zero			# i = 0
		lw $a1, 4($sp)			# a1 = n
		
FOR_ANAGRAM:		lw $a1, 4($sp)			# restore n
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
		
		bne $t3, 1, anagram_else2		# if(n % 2)
		
		# swap word[0] and word[n-1]		
		lb $t3, 0($t0)			# tmp1 = addr[0] 
		lb $t4, 0($t1)			# tmp2 = addr[n-1]
		sb $t4, 0($t0)			# addr[0] = addr[n-1](tmp2)
		sb $t3, 0($t1)			# addr[n-1] = tmp1
				
		addi $s0, $s0, 1		# i++
		j FOR_ANAGRAM	
anagram_else2:					
		add $t0, $a0, $zero		# t0 = addr[0]
		add $t0, $t0, $s0		# t0 = addr[i]
		
		lb $t3, 0($t0)			# tmp1 = addr[i] 
		lb $t4, 0($t1)			# tmp2 = addr[n-1]
		sb $t4, 0($t0)			# addr[i] = addr[n-1](tmp2)
		sb $t3, 0($t1)			# addr[n-1] = tmp1		

		
		addi $s0, $s0, 1		# i++
		j FOR_ANAGRAM

end_anagram:	lw $ra, 8($sp)			# Restore return address
		
		addi $sp, $sp, 16		# Adjust sp
		jr $ra		
######################################################################################################		
##		$a0--addr of str
##		$v0--length of str
strlen:		
		add $t0, $zero, $a0	# t0 = addr[0](index)
		add $t1, $zero, $zero	# counter t1 = 0
loop:		lb $t3, 0($t0)
		beq $t3, 0, strlen_return
		beq $t3, 10, strlen_return
		addi $t0, $t0, 1
		addi $t1, $t1, 1	# increment counter
		j loop
		
strlen_return: 	add $v0, $zero, $t1
		jr $ra	
######################################################################################################		
##	suppose we know the n of the string
##	a0 -- n, v0--return, a1--sum of jCoinEx1(n/2)+jCoinEx1(n/3)+jCoinEx1(n/4))
jCoinEx1:	addi $sp, $sp, -12		# Adjust sp
		sw $a0, 0($sp)			# Store n
		sw $ra, 4($sp)			# Store $ra

		bne $a0, 0, jCoinEx1_ELSE		# if(n==0) (Branch if n != 0)
		li $v0, 1
		j jCoinEx1_Return
		
		
jCoinEx1_ELSE:		
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
######################################################################################################
.macro printf1(%jCoin, %zeroCoins)
	move $t9, %jCoin
	move $t8, %zeroCoins
	la $a0, macro1_str1_prompt
	li $v0, 4
	syscall
	
	li $v0, 1
	add $a0, $t9, $zero
	syscall
	
	la $a0, macro1_str2_prompt
	li $v0, 4
	syscall
	
	li $v0, 1
	add $a0, $t8, $zero
	syscall
	
	la $a0, macro1_str3_prompt
	li $v0, 4
	syscall
.end_macro
	
.macro printf2(%jCoin, %i, %jCoin_i)
	move $t9, %jCoin
	move $t8, %i	
	move $t7, %jCoin_i
	
	la $a0, macro2_str1_prompt
	li $v0, 4
	syscall
	
	li $v0, 1
	move $a0, $t9
	syscall
	
	la $a0, macro2_str2_prompt
	li $v0, 4
	syscall
	
	li $v0, 1
	move $a0, $t8
	syscall
	
	la $a0, macro2_str3_prompt
	li $v0, 4
	syscall
	
	li $v0, 1
	move $a0, $t7
	syscall
	
	la $a0, newline
	li $v0, 4
	syscall	
.end_macro
	
.macro printf3(%jCoin, %Coin0, %Coin1, %Coin2)
	move $t9, %jCoin
	move $t8, %Coin0
	move $t7, %Coin1
	move $t6, %Coin2


	la $a0, macro3_str1_prompt
	li $v0, 4
	syscall
	
	li $v0, 1
	move $a0, $t9
	syscall
	
	la $a0, macro3_str2_prompt
	li $v0, 4
	syscall
	
	li $v0, 1
	move $a0, $t8
	syscall
	
	la $a0, comma
	li $v0, 4
	syscall

	li $v0, 1
	move $a0, $t7
	syscall
	
	la $a0, comma
	li $v0, 4
	syscall

	li $v0, 1
	move $a0, $t6
	syscall
	
	la $a0, macro3_str3_prompt
	li $v0, 4
	syscall
.end_macro	
##	suppose we know the n of the string
##	a0 -- jCoin, a1--zeroCoins, v0--zeroCoins, t0--i
## 	sp = {jCoin, zeroCoins, ra, i, coin[0], coin[1], coin[2]}
jCoinEx2:	addi $sp, $sp, -28		# Adjust sp
		sw $a0, 0($sp)			# Store jCoin
		sw $a1, 4($sp)			# Store zeroCoins
		sw $ra, 8($sp)			# Store $ra
		li $t0, 2			# init i = 2
		sw $t0, 12($sp)			# Store i
		li $s0, 0			# init Coin[0]
		li $s1, 0 			# init Coin[1]
		li $s2, 0			# init Coin[2]
		sw $s0, 16($sp)			# Store Coin[0]
		sw $s1, 20($sp)			# Store Coin[1]
		sw $s2, 24($sp)			# Store Coin[2]		
		
		printf1($a0, $a1)
		lw $a0, 0($sp)			# Restore jCoin
		
FOR_COIN_EX2:		bge $t0, 5, jCoinEx2_End
		div $a0, $t0			# jCoin/i
		mflo $t1			# t1 = jCoin/i
		bne $t1, 0, ELSE		# if(jCoin/i == 0) (Branch if jCoin != 0)
		add $a1, $a1, 1			# zeroCoins++
		add $t2, $t0, -2
		li $t3, 0		
		beq $t2, 0, Coin0
		beq $t2, 1, Coin1
		beq $t2, 2, Coin2

ELSE:		
		printf2($a0, $t0, $t1)
		lw $a0, 0($sp)			# Restore jCoin
		
		sw $a0, 0($sp)			# Store jCoin
		sw $a1, 4($sp)			# Store zeroCoins
		sw $t0, 12($sp)			# Store i
		sw $s0, 16($sp)			# Store Coin[0]
		sw $s1, 20($sp)			# Store Coin[1]
		sw $s2, 24($sp)			# Store Coin[2]	
		
		move $a0, $t1			# Passing a1 = jCoin/i
		jal jCoinEx2
		move $t3, $v0			# Get return value
		lw $a0, 0($sp)			# Restore jCoin
		lw $a1, 4($sp)			# Restore zeroCoins
		lw $t0, 12($sp)			# Restore i
		lw $s0, 16($sp)			# Restore Coin[0]
		lw $s1, 20($sp)			# Restore Coin[1]
		lw $s2, 24($sp)			# Restore Coin[2]	
		
		
		sub $t3, $t3, $a1		# t3 stores new zeroCoins
		add $a1, $a1, $t3
		add $t2, $t0, -2		# i-2
		beq $t2, 0, Coin0
		beq $t2, 1, Coin1
		beq $t2, 2, Coin2
		
Coin0:		move $s0, $t3
		j FOR_CLOSE
Coin1:		move $s1, $t3
		j FOR_CLOSE
Coin2:		move $s2, $t3
		j FOR_CLOSE
		
FOR_CLOSE:	add $t0, $t0, 1		# i++
		j FOR_COIN_EX2			
			
jCoinEx2_End: 	lw $a0, 0($sp)			# Retore jCoin
		lw $ra, 8($sp)			# Restore $ra
		printf3($a0, $s0, $s1, $s2)	
		lw $a0, 0($sp)			# Restore jCoin
		addi $sp, $sp, 28		# Adjust sp
		move $v0, $a1
		jr $ra
######################################################################################
funkyfunc:
	li $a0, 'f'
	li $v0, 11
	syscall

	li $a0, '\n'
	li $v0, 11
	syscall

	li $t0, 15
	sll $t1, $t0, 4
	sll $t2, $t1, 4
	sll $t3, $t2, 4
	sll $t4, $t3, 4
	sll $t5, $t4, 4
	sll $t6, $t5, 4
	sll $t7, $t6, 4
	rol $t8, $t7, 4
	neg $t9, $t8
	addi $t9, $t9, -1 		
	
	li $v0, 0xFFFFFFFF
	li $v1, 0xFFFFFFFF

	or $a0, $0, $0
	or $a1, $0, $0
	or $a2, $0, $0
	or $a3, $0, $0

	jr $ra
