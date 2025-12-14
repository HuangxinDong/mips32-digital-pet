# main for reset, ignore and timer for testing purpose 
.data
# [no need to merge ]related data: for local testing only -----timer & death --yufei
	EDR:            .word 2
	current_energy: .word 5
	input_buffer:   .space  12          # A buffer for the input string

# [no need to merge] prompt ---- already included in our current version  
	msg_died1:       .asciiz "Error, energy level equal or less than 0. DP is dead!\n"
    	msg_died2:       .asciiz " *** Your Digital Pet has died! ***\n"
    	msg_ignore_result:  .asciiz "Current energy: "
    	newline:        .asciiz "\n"
    	msg_prompt:     .asciiz "Enter a command (F, E, P, I, R, Q) > "



.text

# [new added ]our current main loop at 22:24 EST(UTC-5) 13th Dec
main_loop:
	li	$v0, 4
	la	$a0, msg_prompt
	syscall
	
	li	$v0, 8
	la	$a0, input_buffer
	li	$a1, 12
	syscall
	
	jal	parse_command
	
	jal	timer_tick # new line needs to be added to make timer work
    
    	j 	main_loop 

# [new]logical timer 
timer_tick:
	addi 	$sp, $sp, -4
    	sw	$ra, 0($sp)

    	lw	$t0, current_energy
    	lw 	$t1, EDR
    	sub 	$t0, $t0, $t1
    	sw 	$t0, current_energy
    	
    	#--------------[no need to merge]
    	#this is for timer testing purpose only.
    	li 	$v0, 4
    	la 	$a0, msg_ignore_result  
    	syscall

    	lw 	$a0, current_energy
    	li 	$v0, 1
    	syscall

    	li 	$v0, 4
    	la 	$a0, newline
    	syscall
    	# --------------

    	blez 	$t0, pet_dead

    	lw 	$ra, 0($sp)
    	addi 	$sp, $sp, 4
    	jr 	$ra
#[new]
pet_dead:
    	li 	$v0, 4
    	la 	$a0, msg_died1
    	syscall
	
    	li 	$v0, 4
    	la 	$a0, msg_died2
    	syscall

    	li 	$v0, 10
    	syscall

# [no need to merge]below codes are for testing purpose only, no need to merge to the main
parse_command:

    jr $ra