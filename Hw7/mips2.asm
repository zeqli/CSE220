.data
name_prompt: .asciiz "What is your name?"
name: .space 30 # allocate 30 space byte memory

.text
input_name:
	la $a0, name_prompt
	li $v0, 4
	syscall
	
	li $v0, 8 # read string
	la $a0, name
	li $a1, 2
	syscall
	
	li $v0, 4
	syscall

	li $v0, 10
	syscall
	
	
