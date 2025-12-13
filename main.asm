.data
    EDR:            .word   1           # Energy Depletion Rate (units/sec)
    MEL:            .word   15          # Maximum Energy Level
    IEL:            .word   10          # Initial Energy Level
    current_energy: .word   10          # Current energy (initialized to IEL)
    input_buffer:   .space  12          # A buffer for the input string
    
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
    
    # Initialise current_energy with IEL
    lw $t0, IEL
    sw $t0, current_energy

    # Print end of startup messages
    li $v0, 4
    la $a0, msg_params_set
    syscall
    
# Main game loop

main_loop:
    

# INITIALIZE SYSTEM

# ========================================
# read_config
#   $a0: prompt address, $a1: variable address, $t9: default value
# ========================================

read_config:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    move $s1, $a1

    # print prompt in reg $a0
    li $v0, 4
    syscall

    # get user input as string (syscall 8 with an input buffer)
    li $v0, 8
    la $a0, input_buffer
    li $a1, 12
    syscall

    # Check for "\n or no input"
    la $t2, input_buffer
    lb $t0, 0($t2)

    li $t1, 10
    beq $t0, $t1, use_default

    li $t1, 0
    beq $t0, $t1, use_default

    # Convert input into int
    la $a0, input_buffer
    jal str_to_int

    li $t1, -1
    beq $v0, $t1, use_default

    sw $v0, ($s1)
    j read_config_done

use_default:
    sw $t9, ($s1)

read_config_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
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

# ========================================
# str_to_int
#   converts ascii strings to integers
#   [!] This won't handle non-int strings
# ========================================

str_to_int:
    # Update stack pointer
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    li $v0, 0
    li $t1, 0
    li $t2, 10
    li $t4, 48
    li $t5, 57

str_to_int_loop:
    lb $t0, ($a0)

    # Check terminators
    li $t3, 0
    beq $t0, $t3, str_to_int_done

    li $t3, 10
    beq $t0, $t3, str_to_int_done

    # Check bounds
    blt $t0, $t4, return_error
    bgt $t0, $t5, return_error

    # Convert ASCII to INT
    sub $t0, $t0, $t4
    mul $v0, $v0, $t2
    add $v0, $v0, $t0

    addi $a0, $a0, 1
    j str_to_int_loop

return_error:
    li $v0, -1
    j str_to_int_done

str_to_int_done:
    # Restore Stack Pointer
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra