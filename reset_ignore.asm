# main for reset, ignore and timer
.data
# for local testing only -----yufei
	EDR:	.word   1           # Energy Depletion Rate (units/sec)
	MEL:	.word   15          # Maximum Energy Level
	IEL:	.word   10          # Initial Energy Level
	current_energy:		.word 10        # Current energy - for testing purpose, change to any value less than 10 to test

# [need to be merged into main]reset feature - reset messages & ignore message
	msg_reset_cmd:		.asciiz "Command recognized: Reset.\n"	 
	msg_reset_done:		.asciiz "Digital Pet has been reset to its initial state!\n"
	msg_ignore_cmd:		.asciiz "Command recognized: Ignore.\n"
	msg_ignore_intensity:	.asciiz "Enter ignore intensity (n, positive integer): "
	msg_ignore_loss: 	.asciiz "Energy decreased by "
	msg_ignore_result:	.asciiz "Current energy: "


.text
.globl main

# local main only works for the ignore command. 
main:
# Command recognized
	li  	$v0, 4
	la  	$a0, msg_ignore_cmd
	syscall
# print prompt for ignore
    	li   	$v0, 4
    	la   	$a0, msg_ignore_intensity
    	syscall

# read integer n
    	li   	$v0, 5
    	syscall
    	move 	$a0, $v0    

    	jal  	ignore
    	move	$t2, $v0
# print energy reduced
	li   	$v0, 4
	la   	$a0, msg_ignore_loss   
	syscall

	move 	$a0, $t2               # t2 = n*3
	li   	$v0, 1
	syscall
	
	li   $v0, 11     
	li   $a0, 10     
	syscall

# print result for ignore 
    	li   	$v0, 4
    	la   	$a0, msg_ignore_result
   	syscall
   	
   	lw   $a0, current_energy
	li   $v0, 1
	syscall
	
	li   $v0, 11
	li   $a0, 10
	syscall
# exit
    	li   	$v0, 10      # EXIT
    	syscall

# reset feature 
reset:
	la	$a0, msg_reset_cmd #use a0 to save cmd
	jal	print_string
	
	la	$t0,IEL #load address and save IEL into t0 - this is the address of iel
	lw	$t1, 0($t0) #load iel into t1 -- this is the value of iel
	
	la 	$t2, current_energy #the address of current energy is t2
	sw	$t1, 0($t2) # current_energy = t2
		
	la	$a0, msg_reset_done
	jal	print_string

	jr	$ra

# ignore feature 
ignore:
    	li   	$t0, 3        # damage per ignore
    	mul  	$v0, $a0, $t0 # v0 = n * 3

    	lw   	$t1, current_energy
    	sub  	$t1, $t1, $v0
    	sw   	$t1, current_energy

    	jr   	$ra
	

# for local testing purpose. this is for reset
print_string:
	li 	$v0, 4
   	syscall
    	jr 	$ra