#extra feature: sleeping 
.data
	#for sleep
	current_energy:		.word 10
	is_sleeping:    	.word 0      # 0 = awake, 1 = sleeping
	#for level up
	level:               	.word 1
	positive_actions:    	.word 0
	decay_counter:       	.word 0
	
	# for sleep
	msg_sleep:      	.asciiz "Your pet is now sleeping...\n"
	msg_wake:       	.asciiz "Your pet woke up.\n"
	msg_decay:      	.asciiz "Energy decreased by 1.\n"
	msg_energy:     	.asciiz "Current energy: "
	newline:        	.asciiz "\n"
	# for level up
	msg_level: 		.asciiz "Current level: "
	msg_level_up:        	.asciiz "Level up!\n"
	# for dating mood
	msg_date_locked: 	.asciiz "Your pet is too young to date.\n"
	msg_happy:       	.asciiz "Your pet is happy in love!\n"
	msg_calm:        	.asciiz "Your pet feels calm today.\n"
	msg_sad:         	.asciiz "Your pet feels a bit sad.\n"

	
.text
.globl main

main:
#testing dating
#level1
    jal dating

# testing, level2
    li  $t0, 2
    sw  $t0, level

#testing level higher than 2
    jal dating
    jal dating
    jal dating

    li  $v0, 10
    syscall

#testing level up
    #jal print_status

    #jal positive_action
    #jal print_status

    #jal positive_action
    #jal print_status

    #jal positive_action
    #jal print_status

    #li  $v0, 10
    #syscall
# testing sleep
    #jal print_energy

    #jal sleep

    #jal apply_decay 

    #jal wake

    #jal print_energy
    
    #li  $v0, 10
    #syscall

#sleep
sleep:
    li  $t0, 1
    sw  $t0, is_sleeping

    li  $v0, 4
    la  $a0, msg_sleep
    syscall

    jr  $ra
# wake up
wake:
    sw  $zero, is_sleeping

    li  $v0, 4
    la  $a0, msg_wake
    syscall

    jr  $ra

apply_decay:
    # no delay during slee
    lw   $t0, is_sleeping
    bne  $t0, $zero, skip_decay

    # decay_counter++
    lw   $t1, decay_counter
    addi $t1, $t1, 1
    sw   $t1, decay_counter

    # if decay_counter < level 不掉血
    lw   $t2, level
    blt  $t1, $t2, skip_decay

    # 掉血
    lw   $t3, current_energy
    addi $t3, $t3, -1
    sw   $t3, current_energy

    sw   $zero, decay_counter

    li   $v0, 4
    la   $a0, msg_decay
    syscall

skip_decay:
    jr   $ra


print_energy:
    li  $v0, 4
    la  $a0, msg_energy
    syscall

    lw  $a0, current_energy
    li  $v0, 1
    syscall

    li  $v0, 4
    la  $a0, newline
    syscall

    jr  $ra
    
# positive  function
positive_action:
    lw   $t0, positive_actions 
    addi $t0, $t0, 1
    sw   $t0, positive_actions

    li   $t1, 3 
    bne  $t0, $t1, end_positive

    # level up
    lw   $t2, level
    addi $t2, $t2, 1
    sw   $t2, level

    sw   $zero, positive_actions

    li   $v0, 4
    la   $a0, msg_level_up
    syscall

end_positive:
    jr   $ra
 
print_status:
    li  $v0, 4
    la  $a0, msg_energy
    syscall

    lw  $a0, current_energy
    li  $v0, 1
    syscall

    li  $v0, 4
    la  $a0, newline
    syscall

    # for level
    li  $v0, 4
    la  $a0, msg_level
    syscall

    lw  $a0, level
    li  $v0, 1
    syscall

    li  $v0, 4
    la  $a0, newline
    syscall

    jr  $ra

    #for dating
    # dating: random mood interaction (level >= 2)
dating:
    # if level < 2, dating is blocked
    lw   $t0, level
    li   $t1, 2
    blt  $t0, $t1, dating_locked

    # random syscall, 0-1-2
    li   $v0, 42        
    li   $a0, 0         
    li   $a1, 2         
    syscall
    move $t2, $a0       # for random result

    beq  $t2, $zero, dating_happy
    li   $t3, 1
    beq  $t2, $t3, dating_calm

dating_sad:
    li   $v0, 4
    la   $a0, msg_sad
    syscall
    jr   $ra

dating_calm:
    li   $v0, 4
    la   $a0, msg_calm
    syscall
    jr   $ra

dating_happy:
    li   $v0, 4
    la   $a0, msg_happy
    syscall

    jal  positive_action
    jr   $ra

dating_locked:
    li   $v0, 4
    la   $a0, msg_date_locked
    syscall
    jr   $ra
