########################################################################################################################
#	CSE220 Homework 7											       #
#	Name: Zeqing Li												       #
#	ID: 109094692												       #
########################################################################################################################


.data
name: .space 30
name_prompt: .asciiz "What is your name?\n"
hi_prompt: .asciiz "Hi "
canyouguess_prompt: .asciiz "! Can you guess this song\n"
volume_prompt: .asciiz  "Please enter a Volume between[0-127]\n"
volume_err_msg: .asciiz "You provided an incorrect value.\n"
instr_prompt: .asciiz "Pleaes select an instrument to play [0-127]\n"
play_again_prompt: .asciiz "Would you like to play the midi again (Y/N)?\n"
start_over_prompt: .asciiz "Do you want to start over (Y/N)?\n"
instrument: .asciiz "0-7	Piano			64-71	Reed\n8-15	Chromatic Percussion	72-79	Pipe\n16-23	Organ			80-87	Synth Lead\n24-31	Guitar			88-95	Synth Pad\n32-39	Bass			96-103	Synth Effects\n40-47	Strings			104-111	Ethnic\n48-55	Ensemble		112-119	Percussion\n56-63	Brass			120-127 Sound Effects\n"

song: .byte 76, 12,  -1
song1: .byte 76, 12, 76, 12, 20, 12, 76, 12, 20, 12, 72, 12, 76, 12, 20, 12, 79, 12, 20, 36, 67, 12, 20, 36,
72, 12, 20, 24, 67, 12, 20, 24, 64, 12, 20, 24, 69, 12, 20, 12, 71, 12, 20, 12, 70, 12, 69, 12, 20, 12, 67, 16, 76, 16, 79, 16, 81, 12, 20, 12, 77, 12, 79, 12, 20, 12, 76, 12, 20, 12, 72, 12, 74, 12, 71, 12, 20, 24,
72, 12, 20, 24, 67, 12, 20, 24, 64, 12, 20, 24, 69, 12, 20, 12, 71, 12, 20, 12, 70, 12, 69, 12, 20, 12, 67, 16, 76, 16, 79, 16, 81, 12, 20, 12, 77, 12, 79, 12, 20, 12, 76, 12, 20, 12, 72, 12, 74, 12, 71, 12, 20, 24,
48, 12, 20, 12, 79, 12, 78, 12, 77, 12, 75, 12, 60, 12, 76, 12, 53, 12, 68, 12, 69, 12, 72, 12, 60, 12, 69, 12, 72, 12, 74, 12, 48, 12, 20, 12, 79, 12, 78, 12, 77, 12, 75, 12, 55, 12, 76, 12, 20, 12, 84, 12, 20, 12, 84, 12, 84, 12,
55, 12, 20, 12, 48, 12, 20, 12, 79, 12, 78, 12, 77, 12, 75, 12, 60, 12, 76, 12, 53, 12, 68, 12, 69, 12, 72, 12, 60, 12, 69, 12, 72, 12, 74, 12, 48, 12, 20, 12, 75, 24, 20, 12, 74, 24, 20, 12, 72, 24, 20, 12, 55, 12, 55, 12, 20, 12, 48, 12,
72, 12, 72, 12, 20, 12, 72, 12, 20, 12, 72, 12, 74, 12, 20, 12, 76, 12, 72, 12, 20, 12, 69, 12, 67, 12, 20, 12, 43, 12, 20, 12, 72, 12, 72, 12, 20, 12, 72, 12, 20, 12, 72, 12, 74, 12, 76, 12, 55, 12, 20, 24, 48, 12, 20, 24, 43, 12, 20, 12, 72, 12, 72, 12, 20, 12, 72, 12, 20, 12, 72, 12, 74, 12, 20, 12, 76, 12, 72, 12, 20, 12, 69, 12, 67, 12, 20, 12, 43, 12, 20, 12, 76, 12, 76, 12, 20, 12, 76, 12, 20, 12, 72, 12, 76, 12, 20, 12, 79, 12, 20, 36, 67, 12, 20, 36,
76, 12, 72, 12, 20, 12, 67, 12, 55, 12, 20, 12, 68, 12, 20, 12, 69, 12, 77, 12, 53, 12, 77, 12, 69, 12, 60, 12, 53, 12, 20, 12, 71, 16, 81, 16, 81, 16, 81, 16, 79, 16, 77, 16, 76, 12, 72, 12, 55, 12, 69, 12, 67, 12, 60, 12, 55, 12, 20, 12, 76, 12, 72, 12, 20, 12, 67, 12, 55, 12, 20, 12, 68, 12, 20, 12, 69, 12, 77, 12, 53, 12, 77, 12, 69, 12, 60, 12, 53, 12, 20, 12, 71, 12, 77, 12, 20, 12, 77, 12, 77, 16, 76, 16, 74, 16, 72, 12, 64, 12, 55, 12, 64, 12, 60, 12, 20, 36,
76, 12, 72, 12, 20, 12, 67, 12, 55, 12, 20, 12, 68, 12, 20, 12, 69, 12, 77, 12, 53, 12, 77, 12, 69, 12, 60, 12, 53, 12, 20, 12, 71, 16, 81, 16, 81, 16, 81, 16, 79, 16, 77, 16, 76, 12, 72, 12, 55, 12, 69, 12, 67, 12, 60, 12, 55, 12, 20, 12, 76, 12, 72, 12, 20, 12, 67, 12, 55, 12, 20, 12, 68, 12, 20, 12, 69, 12, 77, 12, 53, 12, 77, 12, 69, 12, 60, 12, 53, 12, 20, 12, 71, 12, 77, 12, 20, 12, 77, 12, 77, 16, 76, 16, 74, 16, 72, 12, 64, 12, 55, 12, 64, 12, 60, 12, 20, 36,
72, 12, 20, 24, 67, 12, 20, 24, 64, 24, 69, 16, 71, 16, 69, 16, 68, 24, 70, 24, 68, 24, 67, 12, 65, 12, 67, 48, -1

.text
main:
	# prompt "What is your name?"
	la $a0, name_prompt
	li $v0, 4
	syscall
	
	# read string to 'name'
	li $v0, 8
	la $a0, name
	li $a1, 30
	syscall
	move $t3, $a0

# use this loop to convert a string to upper case

	la $a0, hi_prompt		# print "Hi "
	li $v0, 4
	syscall
	
	ori $t0, $zero, 1
loop:   addu $t0, $t0, 1		# increase t0 by 1
	lb $t1, 0($t3)			# get the address of char to $t0 to convert
	addiu $t3, $t3, 1		# increase array index
	beqz $t1, input			# if we meet NULL then break the loop
	beq $t1,10, input		# if we meet a new line
	# else continue convert
	
	bgt $t1, 122, printchar # a0 > 122 ? continue
	blt $t1, 97, printchar # a0  < 97 ? continue
	# convert all charactor to uppercase
	sub $t1, $t1, 32
printchar: 
	la $a0, ($t1)		# print converted charactor
	li $v0, 11
	syscall
	
	#loop end condition
	blt $t0, 30, loop
	
input:
	# print "Hi NAME! Can you guess this song?"
	la $a0, canyouguess_prompt
	li $v0, 4
	syscall
	
	# print "Please enter a volume between [0-127]"
	la $a0, volume_prompt
	li $v0, 4
	syscall

	
get_input1:
	li $v0, 5
	syscall
	add $t0, $v0, $0
        bltz $t0,  print_range_err1 #bltz if $v0 is less than 0
        bgt $t0, 127, print_range_err1
	# save the volume at $s0
	add $s0,$t0,$0
	
	la $a0, instrument
	li $v0, 4
	syscall

	# print "Please enter an instrument to play[0-127]"
	la $a0, instr_prompt
	li $v0, 4
	syscall	
	
get_input2:
	li $v0, 5
	syscall
	add $t0, $v0, $0
        bltz $t0,  print_range_err2 #bltz if $v0 is less than 0
        bgt $t0, 127, print_range_err2
	# save the volume at $s0
	add $s1,$t0,$0
	
	la $s4, song
play_music:
###################################################################################################
 # 				ticksPerBeat =  24						#
 # 				beatsPerMinute = 280						#
 # 				$a0 = pitch (0-127) 						#
 # 				$a1 = duration in milliseconds					# 
 # 				$a2 = instrument (0-127) 					#
 # 				$a3 = volume (0-127)						#
###################################################################################################
	
	lb $a0, 0($s4) 		# load pitch to a0
	beq $a0, -1, end_play	# if we meet -1
	addiu $s4, $s4, 1	# increament
	lb $t0, 0($s4)		# load #ofTicks
	beq $t0, -1, end_play	# if we meet -1 
	addiu $s4, $s4, 1 
	li $t1, 60000		# load 60000
	mult $t0, $t1		# mult #ofTicks * 60000
	mflo $t8		# get result store to t8
	li $t0,6720 		# get ticksPerBeats * beatsPerMinute = 24 * 280 = 6720
	div $t8, $t0		# calc duration in millisecond
	mflo $a1		# save result to a1
	add $a2, $s1, $0 	# move $s1, $a2		
	add $a3, $s0, $0	# move $s0, $a3		
	li $v0, 33
	syscall
	j play_music
	
	
end_play: 
	la $a0, play_again_prompt # print ""Would you like to play the midi again (Y/N)?"
	li $v0, 4 # print string
	syscall
	
	li $v0, 12	# read a charactor
	syscall
	add $t0, $v0, $0	# move input to t0
	#move $t0, $v0
	
	# put a new line
	add $a0, $0, 0xA
	li $v0, 11
	syscall
	
	la $s4, song
	beq $t0, 89, play_music		# if t0 = 'Y', play music again
	beq $t0, 78, exit		# if t0 = 'N', exit
	
	la $a0, volume_err_msg		# "You provided an incorrect value.\n"
	li $v0, 4
	syscall
	j end_play

print_range_err1:
        la $a0, volume_err_msg		# "You provided an incorrect value.\n"
        li $v0, 4
        syscall
        j get_input1
print_range_err2:
        la $a0, volume_err_msg		# "You provided an incorrect value.\n"
        li $v0, 4
        syscall
        j get_input2

exit: 
	la $a0, start_over_prompt
	li $v0, 4
	syscall
	
	li $v0, 12
	syscall
	add $t0, $v0, $0 	# move input from v0 to 
	
	# put a new line 
	add $a0, $0, 0xA
	li $v0, 11
	syscall
	
	
	beq $t0, 89, main	# if 'Y', start over
	beq $t0, 78, true_exit	# if 'N', exit promgram
	
	la $a0, volume_err_msg	# if neither 'Y' nor 'N' prompt user enter again
	li $v0, 4
	syscall
	j end_play
	
true_exit:
	li $v0, 10
	syscall
