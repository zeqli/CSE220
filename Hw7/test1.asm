        .text
         .globl __start
    __start:
         la $a0,str1 #Load and print string asking for string
         li $v0,4
         syscall

# read a string into and store to t0
         li $v0,8 #take in input
         la $a0, buffer #load byte space into address
         li $a1, 20 # allot the byte space for string
         move $t0,$a0 #save string to t0
         syscall

# print prompt
         la $a0,str2 #load and print "you wrote" string
         li $v0,4
         syscall

# load buffer and print out
         la $a0, buffer #reload byte space to primary address
         move $a0,$t0 # primary address = t0 address (load pointer)
         li $v0,4 # print string
         syscall

         li $v0,10 #end program
         syscall


               .data
             buffer: .space 20
             str1:  .asciiz "Enter string(max 20 chars): "
             str2:  .asciiz "You wrote:\n"
             ###############################
             #Output:
             #Enter string(max 20 chars): qwerty 123
             #You wrote:
             #qwerty 123
             #Enter string(max 20 chars):   new world oreddeYou wrote:
             #  new world oredde //lol special character
             ###############################