# ========================================|========================================|========================================
#
#                                                   MIPS Digital Pet Group C
#
# ========================================|========================================|========================================

.data
    # Global Variables & State
    EDR:            .word   1           # Energy Depletion Rate (units/sec)
    MEL:            .word   15          # Maximum Energy Level
    IEL:            .word   10          # Initial Energy Level
    current_energy: .word   10          # Current energy (initialized to IEL)
    pet_alive:      .word   1           # 1 = Alive, 0 = Dead
    last_tick:      .word   0           # Timestamp of last energy update
    
    # Increased buffer size to handle save codes (e.g., "1 15 10 100 1")
    input_buffer:   .space  64          

    # String Constants
    newline:        .asciiz "\n"
    
    # Extra feature config
    pet_sick:       .word   0
    pet_sleeping:   .word   0   # 0 = awake, 1 = sleeping
    level: 	    .word 1
    positive_actions:.word 0   # count of positive commands


    # Startup messages
    msg_title:      .asciiz "=== Digital Pet Simulator (MIPS32) ===\n"
    msg_init:       .asciiz "Initializing system...\n\n"
    msg_params:     .asciiz "Please set parameters (press Enter for default):\n"
    msg_edr_prompt: .asciiz "Enter Natural Energy Depletion Rate (EDR) [Default: 1]: "
    msg_mel_prompt: .asciiz "Enter Maximum Energy Level (MEL) [Default: 15]: "
    msg_iel_prompt: .asciiz "Enter Initial Energy Level (IEL) [Default: 10]: "
    msg_params_set: .asciiz "Parameters set successfully!\n"
    
    # Parameters Strings
    msg_edr_info:   .asciiz "- EDR: "
    msg_mel_info:   .asciiz "- MEL: "
    msg_iel_info:   .asciiz "- IEL: "
    msg_units:      .asciiz " units\n"
    msg_units2:     .asciiz " units"
    msg_units_sec:  .asciiz " units/sec\n"
    
    msg_max_energy: .asciiz "Error, maximum energy level reached! Capped to the Max.\n"
    msg_alive:      .asciiz "Your Digital Pet is alive! Current status:\n"
    msg_died1:       .asciiz "Error, energy level equal or less than 0. DP is dead!\n"
    msg_died2:       .asciiz " *** Your Digital Pet has died! ***\n"
    msg_dead_block:  .asciiz "Your pet is dead! You must Reset (R) or Quit (Q).\n"
    msg_pet_sick:   .asciiz "Your Digital Pet has gotten sick! Cure with 'C'!\n"
    msg_cured:      .asciiz "You gave your Digital Pet medicine. It is cured!\n"
    
    # Command prompt
    msg_prompt:     .asciiz "\nEnter a command (F, E, P, I, D, S, R, Q) > "
    
    # Command recognized messages
    msg_cmd_feed:   .asciiz "Command recognized: Feed "
    msg_cmd_enter:  .asciiz "Command recognized: Entertain "
    msg_cmd_pet:    .asciiz "Command recognized: Pet "
    msg_cmd_ignore: .asciiz "Command recognized: Ignore "
    msg_cmd_reset:  .asciiz "Command recognized: Reset "
    msg_cmd_quit:   .asciiz "Command recognized: Quit "
    msg_cmd_cure:   .asciiz "Command recognized: Cure "
    msg_cmd_invalid: .asciiz "Invalid command! Please try again."
    msg_sleep:      .asciiz "Your pet is sleeping\n"
    msg_wake:       .asciiz "Your pet woke up\n"
    msg_cmd_dating: .asciiz "Command recognized: Dating\n"
    msg_dating_locked:.asciiz "Your pet is too young to date! Dating is locked. Reach level 2 first.\n"
    msg_sleep_block: .asciiz "Your pet is sleeping. Wake it up first.\n"
    msg_happy: .asciiz "Your pet is happyly in love!\n"
    msg_calm:  .asciiz "Your pet feels calm today.\n"
    msg_sad:   .asciiz "Your pet feels a bit sad.\n"
    msg_level:      .asciiz "Level: "
    msg_level_up:   .asciiz "Level up! Current level: "

    # Reset and Ignore messages
    msg_reset_done:     .asciiz "Digital Pet has been reset to its initial state!\n"
    
    # Time depletion messages
    msg_time_tick:      .asciiz "Time +1s... Natural energy depletion!\n"
    msg_curr_energy:    .asciiz "Current energy: "
 
    # Quit messages
    # Quit messages
    msg_saving:     .asciiz "Saving session... goodbye!\nSave Code: "
    msg_terminated: .asciiz "\n--- simulation terminated ---\n"

    # Session Management
    msg_ask_load:     .asciiz "Do you want to restore a previous game? (Y/N) > "
    msg_load_instr:   .asciiz "Enter your Save Code:\n"
    msg_load_example: .asciiz "Example: 17829342\n"
    msg_load_prompt:  .asciiz "> "
    msg_load_success: .asciiz "Game state restored successfully!\n"
    msg_load_invalid: .asciiz "Invalid Save Code! Starting new game.\n\n"

    # Strings for displaying the energy bar

    energy_bar_start: .asciiz "["
    energy_bar_fill: .asciiz "#"
    energy_bar_empty: .asciiz "-"
    energy_bar_end: .asciiz "] Energy: "

    # String for slash
    str_slash: .asciiz "/"

    # Messages for energy changes
    msg_dec_by: .asciiz "Energy decreased by: "    
    msg_inc_by: .asciiz "Energy increased by: "
    msg_lparen: .asciiz " ("
    msg_x: .asciiz "x"
    msg_rparen: .asciiz ")\n"

.text
.globl main

# MAIN PROGRAM

# ========================================
# main
#   Get startup config and call main loop
# ========================================

main:
    # Print startup messages
    li $v0, 4
    la $a0, msg_title
    syscall
    la $a0, msg_init
    syscall

    
    # Ask to load session
    li $v0, 4
    la $a0, msg_ask_load
    syscall
    
    # Read input (Y/N)
    li $v0, 8
    la $a0, input_buffer
    li $a1, 12
    syscall
    
    lb $t0, input_buffer
    li $t1, 'Y'
    beq $t0, $t1, try_load
    li $t1, 'y'
    beq $t0, $t1, try_load
    
    j start_new_game

try_load:
    jal load_session
    # If load failed ($v0=0), fall through to start_new_game
    # If load success ($v0=1), jump to game_start_skip_config
    bnez $v0, game_start_skip_config

start_new_game:
    li $v0, 4
    la $a0, msg_params
    syscall

    # Get EDR config
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

game_start_skip_config:
    li $v0, 4
    la $a0, msg_alive
    # Get Random Values
    li $v0, 30      # syscall 30 for system time
    syscall

    move $a1, $a0
    li $v0, 40
    li $a0, 0       # syscall 40 for seed
    syscall

    # Echo Parameters
    # Print EDR
    li $v0, 4
    la $a0, msg_edr_info
    syscall
    
    li $v0, 1
    lw $a0, EDR
    syscall
    
    li $v0, 4
    la $a0, msg_units_sec
    syscall

    # Print MEL
    li $v0, 4
    la $a0, msg_mel_info
    syscall
    
    li $v0, 1
    lw $a0, MEL
    syscall
    
    li $v0, 4
    la $a0, msg_units
    syscall

    # Print IEL
    li $v0, 4
    la $a0, msg_iel_info
    syscall
    
    li $v0, 1
    lw $a0, IEL
    syscall
    
    li $v0, 4
    la $a0, msg_units
    syscall

    # Print Current Energy
    li $v0, 4
    la $a0, msg_curr_energy
    syscall
    
    lw $a0, current_energy
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall

    # Initialise last_tick with current time (ms)
    li  $v0, 30
    syscall
    sw  $a0, last_tick
    
    
# Main game loop

# ========================================
# main_loop
#   Get user input and call parse_command
#   Calculate elapsed time
#   Deplete energy
# ========================================

main_loop:

    # (A) if pet is dead, skip depletion
    lw   $t0, pet_alive
    beq  $t0, $zero, after_depletion

    # (A.1) if pet is sleeping, skip depletion
    lw   $t0, pet_sleeping
    beq  $t0, $zero, do_depletion   # if awake → do normal depletion
    j    sleep_skip_depletion       # if sleeping → skip

sleep_skip_depletion:
    # reset last_tick so time doesn't accumulate
    li  $v0, 30
    syscall
    sw  $a0, last_tick
    j after_depletion

do_depletion:
    # (B) check how many seconds passed since last_tick
    li   $v0, 30          # get current time (ms)
    syscall
    move $t1, $a0         # t1 = current_time (low 32 bits)

    lw   $t2, last_tick   # t2 = last_tick
    sub  $t3, $t1, $t2    # t3 = elapsed time

    li   $t4, 1000
    div  $t3, $t4         # elapsed / 1000
    mflo $t7              # t7 = num_ticks (seconds passed)

    blez $t7, after_depletion # if less than 1 second passed, skip

    # (C) subtract EDR * num_ticks and update last_tick
    lw   $t5, current_energy
    lw   $t6, EDR

    # Double EDR if pet is sick
    lw $t9, pet_sick
    beq $t9, $zero, main_loop_skip_sickness

    mul $t6, $t6, 2

main_loop_skip_sickness:
    
    mul  $t8, $t7, $t6    # t8 = total_damage = num_ticks * EDR
    sub  $t5, $t5, $t8    # current_energy -= total_damage
    bge $t5, $0, skip_clamp_natural
    li $t5, 0

skip_clamp_natural:
    sw   $t5, current_energy
    # Update last_tick by adding (num_ticks * 1000)
    # This keeps the remainder milliseconds for the next loop (accuracy)
    mul  $t9, $t7, $t4    # t9 = time_accounted (ms)
    add  $t2, $t2, $t9    # last_tick += time_accounted
    sw   $t2, last_tick

    # Print natural depletion message loop
    move $t9, $t7        # t9 = num_ticks counter

print_tick_loop:
    blez $t9, print_tick_done

    li   $v0, 4
    la   $a0, msg_time_tick
    syscall

    # check for sickness
    addi $sp, $sp, -4
    sw $t9, 0($sp)

    jal do_check_sickness

    lw $t9, 0($sp)
    addi $sp, $sp, 4

    # end check for sickness

    sub  $t9, $t9, 1
    j    print_tick_loop

print_tick_done:
    jal print_status_bar

    # (D) if energy <= 0, clamp to 0, set pet_alive=0, print death messages
    blez $t5, handle_death
    j    after_depletion

after_depletion:

    # Print command prompt
    li $v0, 4
    la $a0, msg_prompt
    syscall

    # Read command input
    li $v0, 8
    la $a0, input_buffer
    li $a1, 12
    syscall

    # Block commands if pet is dead (only allow R or Q)
    lw  $t0, pet_alive
    bne $t0, $zero, allow_command

    la  $t1, input_buffer
    lb  $t2, 0($t1)

    li  $t3, 'R'
    beq $t2, $t3, allow_command

    li  $t3, 'Q'
    beq $t2, $t3, allow_command

    # Otherwise reject
    li  $v0, 4
    la  $a0, msg_dead_block
    syscall
    j   main_loop

allow_command:

    jal parse_command
    
    jal print_status_bar

    j main_loop # --- END OF WHILE LOOP ---

handle_death:
    li   $t7, 0
    sw   $t7, current_energy
    sw   $t7, pet_alive

    li   $v0, 4
    la   $a0, msg_died1
    syscall

    li   $v0, 4
    la   $a0, msg_died2
    syscall
    j after_depletion

# INITIALIZE SYSTEM

# ========================================
# read_config
#   $a0: prompt address, $a1: variable address, $t9: default value
# ========================================

read_config:
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s1, 0($sp)

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
    lw $s1, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8
    jr $ra

# COMMAND PARSING

# ========================================
# parse_command
#   parse the command entered by the user
# ========================================

parse_command:
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp) # command char
    sw $s1, 0($sp) # argument value

    la $t0, input_buffer
    lb $s0, 0($t0)
    
    # move pointer
    addi $t0, $t0, 1    

skip_spaces:
    lb $t1, 0($t0)
    li $t2, 32 # 32 is space
    bne $t1, $t2, parse_arg
    addi $t0, $t0, 1 # move pointer
    j skip_spaces

parse_arg:
    # Check empty argument
    lb $t1, 0($t0)
    li $t2, 10 # \n
    beq $t1, $t2, use_default_arg
    li $t2, 0 # null
    beq $t1, $t2, use_default_arg

    move $a0, $t0
    jal str_to_int
    
    # Check for invalid input (-1)
    li $t2, -1
    beq $v0, $t2, check_cmd_type_invalid
    
    move $s1, $v0 # save integer to $s1
    j check_cmd_type

use_default_arg:
    li $s1, 1 # n=1

check_cmd_type:
    li $t2, 'F'
    beq $s0, $t2, do_feed

    li $t2, 'E'
    beq $s0, $t2, do_entertain

    li $t2, 'P'
    beq $s0, $t2, do_pet

    li $t2, 'I'
    beq $s0, $t2, do_ignore

    li $t2, 'R'
    beq $s0, $t2, do_reset

    li $t2, 'Q'
    beq $s0, $t2, do_quit

    li $t2, 'S'
    beq $s0, $t2, do_sleep
    
    li $t2, 'D'
    beq $s0, $t2, do_dating

    li $t2, 'C'
    bne $s0, $t2, check_cmd_type_invalid

    lw $t3, pet_sick
    beq $t3, $zero, check_cmd_type_invalid

    jal do_cure_sickness
    j parse_done

check_cmd_type_invalid:
    # Invalid command
    li $v0, 4
    la $a0, msg_cmd_invalid
    syscall
    la $a0, newline
    syscall
    j parse_done

do_feed:
    move $a1, $s1
    la $a0, msg_cmd_feed
    jal print_cmd_success

    move $a0, $s1
    li $a1, 1

    jal update_energy
    
    jal increase_positive

    j parse_done

do_entertain:
    move $a1, $s1
    la $a0, msg_cmd_enter
    jal print_cmd_success

    move $a0, $s1
    li $a1, 2

    jal update_energy
    
    jal increase_positive

    j parse_done

do_pet:
    move $a1, $s1
    la $a0, msg_cmd_pet
    jal print_cmd_success

    move $a0, $s1
    li $a1, 2

    jal update_energy
    
    jal increase_positive

    j parse_done

do_ignore:
    move $a1, $s1
    la $a0, msg_cmd_ignore
    jal print_cmd_success

    move $a0, $s1
    li $a1, -3

    jal update_energy

    j parse_done

do_reset:
    move $a0, $s1
    jal reset
    j parse_done

do_quit:
    move $a0, $s1
    jal quit
    j parse_done

do_sleep:
    lw  $t0, pet_sleeping
    xori $t0, $t0, 1      # toggle sleep state
    sw  $t0, pet_sleeping

    beq  $t0, $zero, woke_up

    # now sleeping
    li  $v0, 4
    la  $a0, msg_sleep
    syscall
    j parse_done

woke_up:
    li  $v0, 4
    la  $a0, msg_wake
    syscall

    # reset last_tick on wake
    li  $v0, 30
    syscall
    sw  $a0, last_tick

    j parse_done


parse_done:
    lw $s1, 0($sp)
    lw $s0, 4($sp)
    lw $ra, 8($sp)
    addi $sp, $sp, 12
    jr $ra

# EXECUTE COMMANDS

# ========================================
# do_check_sickness
# ========================================

do_check_sickness:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Store random number in a0
    li $v0, 42
    li $a0, 0
    li $a1, 100
    syscall

    # 1/100 chance of pet to get sick
    li $t0, 1
    bge $a0, $t0, do_check_sickness_return

    li $t1, 1
    sw $t1, pet_sick

    li $v0, 4
    la $a0, msg_pet_sick
    syscall

do_check_sickness_return:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# ========================================
# do_cure_sickness
# ========================================

do_cure_sickness:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    li $v0, 4
    la $a0, msg_cmd_cure
    syscall

    li $t0, 0
    sw $t0, pet_sick

    li $v0, 4
    la $a0, msg_cured
    syscall

    lw $ra, 0($sp)
    addi $sp, $sp, 4

    jr $ra

# ========================================
# reset
# ========================================

reset:
    li $v0, 4
    la $a0, msg_cmd_reset
    syscall

    li $v0, 4
    la $a0, newline
    syscall
    
    # current_energy = IEL
    lw $t0, IEL
    sw $t0, current_energy

    li  $t1, 1
    sw  $t1, pet_alive

    li  $v0, 30
    syscall
    sw  $a0, last_tick

    li $v0, 4
    la $a0, msg_reset_done
    syscall
    
    li  $t0, 0
    sw  $t0, pet_sleeping
    sw  $t0, pet_sick
    sw  $t0, positive_actions

    li  $t1, 1
    sw  $t1, level
    
    jr $ra

# ========================================
# level up
# ========================================

increase_positive:
    lw  $t0, positive_actions
    addi $t0, $t0, 1
    sw  $t0, positive_actions

    li  $t1, 5
    blt $t0, $t1, inc_done

    # level up
    li  $t0, 0
    sw  $t0, positive_actions

    lw  $t2, level
    addi $t2, $t2, 1
    sw  $t2, level

    li  $v0, 4
    la  $a0, msg_level_up
    syscall
    
    
    lw  $a0, level
    li  $v0, 1
    syscall
    
    la  $a0, newline
    li  $v0, 4
    syscall

inc_done:
    jr $ra

# ========================================
# datiing
# ========================================

do_dating:
    # block if sleeping
    lw  $t2, pet_sleeping
    bne $t2, $zero, dating_sleep_block

    # block if level < 2
    lw  $t0, level
    li  $t1, 2
    blt $t0, $t1, dating_level_block

    # command recognized
    la  $a0, msg_cmd_dating
    li  $v0, 4
    syscall

    # random mood: 0 / 1 / 2
    li  $v0, 42
    li  $a0, 0
    li  $a1, 2
    syscall
    move $t3, $a0

    beq $t3, $zero, dating_happy
    li  $t4, 1
    beq $t3, $t4, dating_calm

dating_sad:
    li  $v0, 4
    la  $a0, msg_sad
    syscall
    j parse_done

dating_calm:
    li  $v0, 4
    la  $a0, msg_calm
    syscall
    j parse_done

dating_happy:
    li  $v0, 4
    la  $a0, msg_happy
    syscall

    # happy, positive interaction, can help up the level
    jal increase_positive
    j parse_done

dating_sleep_block:
    li  $v0, 4
    la  $a0, msg_sleep_block
    syscall
    j parse_done

dating_level_block:
    li  $v0, 4
    la  $a0, msg_dating_locked
    syscall
    
    j parse_done

# ========================================
# quit
# ========================================

quit:
    li $v0, 4
    la $a0, msg_saving
    syscall

    # Save session
    jal save_session

    li $v0, 4
    la $a0, msg_terminated
    syscall
    li $v0, 10 # exit program
    syscall

# SESSION FUNCTIONS

save_session:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Pack variables into one 32-bit integer
    # Structure: [EDR (8)] [MEL (8)] [IEL (8)] [ENERGY (8)], since this ensures the number is positive (MSB=0) as long as EDR < 128
    
    lw $t0, EDR
    sll $t0, $t0, 8 # Shift left 8
    
    lw $t1, MEL
    or $t0, $t0, $t1 # combine
    sll $t0, $t0, 8
    
    lw $t1, IEL
    or $t0, $t0, $t1
    sll $t0, $t0, 8
    
    lw $t1, current_energy
    or $t0, $t0, $t1
    
    # Obfuscate with XOR Key (0x12345678)
    xori $t0, $t0, 0x12345678
    
    # Print save code
    li $v0, 36 # syscall 36: print unsigned integer
    move $a0, $t0
    syscall
    
    li $v0, 11
    li $a0, 10 # newline
    syscall
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

load_session:
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s0, 0($sp)

    li $v0, 4
    la $a0, msg_load_instr
    syscall
    la $a0, msg_load_example
    syscall
    la $a0, msg_load_prompt
    syscall

    # Read input line
    li $v0, 8
    la $a0, input_buffer
    li $a1, 64
    syscall

    # Check for empty input
    lb $t0, input_buffer
    li $t1, 10 # newline
    beq $t0, $t1, load_fail
    li $t1, 0  # null
    beq $t0, $t1, load_fail

    # Parse save code
    la $a0, input_buffer
    jal str_to_int
    li $t0, -1
    beq $v0, $t0, load_fail
    
    # Decrypt: XOR with Key
    xori $t0, $v0, 0x12345678
    
    # Unpack EDR MEL IEL ENERGY

    # Extract Energy
    andi $t1, $t0, 0xFF
    sw $t1, current_energy
    srl $t0, $t0, 8

    # Extract IEL
    andi $t1, $t0, 0xFF
    sw $t1, IEL
    srl $t0, $t0, 8

    # Extract MEL
    andi $t1, $t0, 0xFF
    sw $t1, MEL
    srl $t0, $t0, 8
    
    # Extract EDR
    andi $t1, $t0, 0xFF
    sw $t1, EDR
    
    # Restore alive status
    lw $t1, current_energy
    li $t2, 0
    sgt $t2, $t1, $zero # if energy > 0, alive=1
    sw $t2, pet_alive

    li $v0, 4
    la $a0, msg_load_success
    syscall
    li $v0, 1
    j load_done

load_fail:
    li $v0, 4
    la $a0, msg_load_invalid
    syscall
    li $v0, 0

load_done:
    lw $s0, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8
    jr $ra

# DATA LAYER

# ========================================
# update_energy
#   Increments energy by $a0 (n) * $a1
#   Handles if energy <= 0
# ========================================

update_energy:
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp) # to save n
    sw $s1, 0($sp) # will save scale

    move $s0, $a0
    move $s1, $a1

    # print_update_energy
    move $a0, $s0
    move $a1, $s1
    jal print_update_energy

    # Calculate delta + update energy
    mul  $t0, $s0, $s1


    lw $t1, current_energy
    add $t1, $t1, $t0

    lw $t2, MEL
    ble $t1, $t2, update_energy__check_min

    move $t1, $t2
    li $v0, 4
    la $a0, msg_max_energy
    syscall
    j update_energy__save

update_energy__check_min:
    bge $t1, $zero, update_energy__save
    li $t1, 0
    li $v0, 4
    la $a0, msg_died1
    syscall

update_energy__save:
    sw $t1, current_energy

    # Restore and return
    lw $s1, 0($sp)
    lw $s0, 4($sp)
    lw $ra, 8($sp)
    addi $sp, $sp, 12
    jr $ra

# ========================================
# print_update_energy
#   prints update energy text
# ========================================

print_update_energy:
    move $t0, $a0
    move $t1, $a1
    mul $t2, $t0, $t1
    
    # determine increase or decrease
    bltz $t2, print_update_energy__print_decrease

    li $v0, 4
    la $a0, msg_inc_by
    syscall
    j print_update_energy__val

print_update_energy__print_decrease:
    li $v0, 4
    la $a0, msg_dec_by
    syscall

print_update_energy__val:
    li $v0, 1
    abs $a0, $t2
    syscall

    li $v0, 4
    la $a0, msg_units2
    syscall

    li $t3, 1
    beq $t1, $t3, print_update_energy__done

    li $v0, 4
    la $a0, msg_lparen
    syscall

    li $v0, 1
    abs $a0, $t1
    syscall

    li $v0, 4
    la $a0, msg_x
    syscall

    li $v0, 1
    move $a0, $t0
    syscall

    li $v0, 4
    la $a0, msg_rparen
    syscall

print_update_energy__done:
    li $v0, 4
    la $a0, newline
    syscall

    jr $ra
    
# DISPLAY FUNCTIONS
# ========================================
# print_status_bar
#   Output: [########----]
#   Converts the energy fraction into a display bar
# ========================================

print_status_bar:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    lw $t0, current_energy
    lw $t1, MEL
    li $t2, 20 # Keeping the bar width to be 20 characters

    bge $t0, $zero, calc_bar_ratio # Turns negative input into 0
    li $t0, 0
        
    li  $v0, 4
    la  $a0, newline
    syscall

calc_bar_ratio: 
    # implementing the formula: (current energy * width of the bar) / MEL
    mul $t3, $t0, $t2
    div $t3, $t1
    mflo $t3

    ble $t3, $t2, draw_bar_start
    li $t3, 20

draw_bar_start:
    li $v0, 4
    la $a0, energy_bar_start
    syscall

    move $t4, $t3

print_fill_loop:
    blez $t4, print_empty_start
    li   $v0, 4
    la   $a0, energy_bar_fill
    syscall
    sub  $t4, $t4, 1
    j    print_fill_loop

print_empty_start:
    sub $t4, $t2, $t3 # empty bars = bar width - no of filled bars
    
print_empty_loop:
    blez $t4, print_bar_end
    li $v0, 4
    la $a0, energy_bar_empty
    syscall
    sub $t4, $t4, 1
    j print_empty_loop

print_bar_end:
    li $v0, 4
    la $a0, energy_bar_end
    syscall

    lw $a0, current_energy
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, str_slash
    syscall
    
    lw $a0, MEL
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, newline
    syscall
    
    li  $v0, 4
    la  $a0, msg_level
    syscall
    
    lw  $a0, level
    li  $v0, 1
    syscall
    
    li  $v0, 4
    la  $a0, newline
    syscall

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# UTILITY FUNCTIONS

# ========================================
# print_cmd_success
#   print "Command recognized: [Name] [Arg]."
#   $a0: Address of command name string
#   $a1: Integer argument value
# ========================================

print_cmd_success:
    li $v0, 4
    syscall

    move $a0, $a1
    li $v0, 1 # print n
    syscall
    
    li $a0, 46 # 46 is '.'
    li $v0, 11 # print .
    syscall
    
    la $a0, newline
    li $v0, 4
    syscall
    
    jr $ra

# ========================================
# str_to_int
#   converts ascii strings to integers
#   gracefully catches invalid inputs (returns -1)
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

    li $t3, 32  # space
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