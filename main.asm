.data
    EDR:            .word   1           # Energy Depletion Rate (units/sec)
    MEL:            .word   15          # Maximum Energy Level
    IEL:            .word   10          # Initial Energy Level
    current_energy: .word   10          # Current energy (initialized to IEL)
    
    # Startup messages
    msg_title:      .asciiz "=== Digital Pet Simulator (MIPS32) ===\n"
    msg_init:       .asciiz "Initializing system...\n"
    msg_params:     .asciiz "Please set parameters (press Enter for default):\n"
    msg_edr_prompt: .asciiz "Enter Natural Energy Depletion Rate (EDR) [Default: 1]: "
    msg_mel_prompt: .asciiz "Enter Maximum Energy Level (MEL) [Default: 15]: "
    msg_iel_prompt: .asciiz "Enter Initial Energy Level (IEL) [Default: 10]: "
    msg_params_set: .asciiz "Parameters set successfully!\n"
    msg_alive:      .asciiz "Your Digital Pet is alive! Current status:\n"
    
    # Command prompt
    msg_prompt:     .asciiz "Enter a command (F, E, P, I, R, Q) > "
 
    # Quit messages
    msg_saving:     .asciiz "Saving session... goodbye!\n"
    msg_terminated: .asciiz "--- simulation terminated ---\n"

.text
.globl main


# MAIN PROGRAM

main:
    # Print startup messages
    li $v0, 4
    la $a0, msg_title
    syscall
    la $a0, msg_init
    syscall
    la $a0, msg_params
    syscall

    # Get EDR Config
    la $a1, EDR
    la $a0, msg_edr_prompt
    li $t9, 1
    jal read_config

    # Get MEL config
    la $a1, MEL
    la $a0, msg_mel_prompt
    li $t9, 15
    jal read_config

    # Get IEL config
    la $a1, IEL
    la $a0, msg_iel_prompt
    li $t9, 10
    jal read_config
    
    li $v0, 4
    la $a0, msg_params_set
    syscall
    
# Main game loop

main_loop:
    

# INITIALIZE SYSTEM

read_config:
    # print prompt in a0
    li $v0, 4
    syscall

    # get user input
    li $v0, 5
    syscall

    # move user input into register $t0
    move $t0, $v0

    li $t1, 0
    beq $t0, $t1, use_default

    # store value into address at register $a1
    sw $t0, ($a1)
    j read_config_done

use_default:
    sw $t9, ($a1)

read_config_done:
    jr $ra

# COMMAND PARSING AND EXECUTION



# TIMING FUNCTIONS



# DISPLAY FUNCTIONS



# UTILITY FUNCTIONS

print_string:
    # Print null-terminated string in $a0
    li      $v0, 4
    syscall
    jr      $ra

print_int:
    # Print integer in $a0
    li      $v0, 1
    syscall
    jr      $ra

print_char:
    # Print character in $a0
    li      $v0, 11
    syscall
    jr      $ra