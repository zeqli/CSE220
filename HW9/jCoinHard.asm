.data
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

.text
main:
	li $a0, 12
	li $a1, 0
	jal jCoinEx2
	move $t0, $v0

	li $v0, 10
	syscall
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
		
FOR:		bge $t0, 5, jCoinEx2_End
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
		j FOR			
			
jCoinEx2_End: 	lw $a0, 0($sp)			# Retore jCoin
		lw $ra, 8($sp)			# Restore $ra
		printf3($a0, $s0, $s1, $s2)	
		lw $a0, 0($sp)			# Restore jCoin
		addi $sp, $sp, 28		# Adjust sp
		move $v0, $a1
		jr $ra
		

