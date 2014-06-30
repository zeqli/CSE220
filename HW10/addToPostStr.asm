.data
inStr: .asciiz "70 / ((3 + 4) * 10) "
postStr: .space 51
token: .ascii "ABC\0"
token1: .ascii "+\0"
token2: .ascii "789\0"
token3: .ascii "508\0"
token4: .ascii "-\0"
.text

main:
	la $a0, token
	jal AddToPostStr
	
	la $a0, token1
	jal AddToPostStr
	
	la $a0, token2
	jal AddToPostStr
	
	la $a0, token3
	jal AddToPostStr
	
	la $a0, token4
	jal AddToPostStr
	
	la $a0, postStr
	li $v0, 4
	syscall
	
	li $v0, 10
	syscall



################################# ADD TO POSTSTRL################
## 	$a0 -- token that will be added to poststr
AddToPostStr:
		addi $sp, $sp, -4
		sw $a0, 0($sp)
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
		addi $sp, $sp, 4
		jr $ra
