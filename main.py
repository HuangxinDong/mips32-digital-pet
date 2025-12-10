import time
import sys
import select
import os

def display_energy_bar(current, maximum):
    bar_length = 20
    display_current = max(0, min(current, maximum))
    filled_length = int(round(bar_length * display_current / float(maximum)))
    bar = '█' * filled_length + '-' * (bar_length - filled_length)
    return f"[{bar}] Energy: {current}/{maximum}"

# --- Command Functions ---

def handle_feed(current_energy, n, mel):
    increase = n
    new_energy = current_energy + increase
    messages = [f"Command recognized: Feed {n}."]
    
    if new_energy > mel:
        new_energy = mel
        messages.append("Error, maximum energy level reached! Capped to the Max.\n")
    else:
        messages.append(f"Energy increased by {n} units.")
    
    return new_energy, messages

def handle_entertain(current_energy, n, mel):
    increase = 2 * n
    new_energy = current_energy + increase
    messages = [f"Command recognized: Entertain {n}.", f"Energy increased by {increase} units (2x{n})."]
    
    if new_energy > mel:
        new_energy = mel
        messages.append("Error, maximum energy level reached! Capped to the Max.")
        
    return new_energy, messages

def handle_pet(current_energy, n, mel):
    increase = 2 * n
    new_energy = current_energy + increase
    messages = [f"Command recognized: Pet {n}.", f"Energy increased by {increase} units (2x{n})."]
    
    if new_energy > mel:
        new_energy = mel
        messages.append("Error, maximum energy level reached! Capped to the Max.")
        
    return new_energy, messages

def handle_ignore(current_energy, n, mel):
    decrease = 3 * n
    new_energy = current_energy - decrease
    messages = [f"Command recognized: Ignore {n}.", f"Energy decreased by {decrease} units (3x{n})."]
    
    if new_energy <= 0:
        new_energy = 0
        messages.append("Error, energy level equal or less than 0. DP is dead!")
        
    return new_energy, messages

def handle_sick(current_energy, n, mel):
    decrease = 4 * n
    new_energy = current_energy - decrease
    messages = [f"Command recognized: Sick {n}.", f"Energy decreased by {decrease} units (4x{n})."]
    
    if new_energy <= 0:
        new_energy = 0
        messages.append("Error, energy level equal or less than 0. DP is dead!")
        
    return new_energy, messages

def handle_cure(current_energy, n, mel):
    increase = 3 * n
    new_energy = current_energy + increase
    messages = [f"Command recognized: Medicine {n}.", f"Energy increased by {increase} units (3x{n})."]
    
    if new_energy > mel:
        new_energy = mel
        messages.append("Error, maximum energy level reached! Capped to the Max.")
        
    return new_energy, messages

def handle_learn(current_energy, n, mel):
    increase = 2 * n
    new_energy = current_energy + increase
    messages = [f"Command recognized: Learn {n}.", f"Energy increased by {increase} units (2x{n})."]
    
    if new_energy > mel:
        new_energy = mel
        messages.append("Error, maximum energy level reached! Capped to the Max.")
        
    return new_energy, messages

def handle_reset(iel):
    messages = ["Command recognized: Reset.", "Digital Pet has been reset to its initial state!"]
    return iel, messages


# --- Main Loop ---

def main():
    print("=== Digital Pet Simulator (MIPS32) ===")
    print("Initializing system...\n")

    # Configuration
    print("Please set parameters (press Enter for default):")

    # Helper for blocking input with prompt
    def get_config(prompt, default):
        sys.stdout.write(prompt)
        sys.stdout.flush()
        # Use select to allow simple blocking read
        rlist, _, _ = select.select([sys.stdin], [], [], 60) # 60s timeout for setup
        if rlist:
            val = sys.stdin.readline().strip()
            if val:
                try:
                    return int(val)
                except ValueError:
                    pass
        return default

    EDR = get_config("Enter Natural Energy Depletion Rate (EDR) [Default: 1]: ", 1)
    MEL = get_config("Enter Maximum Energy Level (MEL) [Default: 15]: ", 15)
    IEL = get_config("Enter Initial Energy Level (IEL) [Default: 10]: ", 10) # Increased default to 10

    print("Parameters set successfully!")
    print(f"- EDR: {EDR} units/sec")
    print(f"- MEL: {MEL} units")
    print(f"- IEL: {IEL} units")

    current_energy = IEL

    print("\nYour Digital Pet is alive! Current status:")
    print(display_energy_bar(current_energy, MEL))
    print("")
    
    last_tick_time = time.time()
    TICK_DURATION = 5.0 # Slow down simulation: 5 real seconds = 1 simulation tick
    
    while True:
        # Calculate time remaining until next tick
        if current_energy > 0:
            now = time.time()
            time_since_tick = now - last_tick_time
            time_to_wait = TICK_DURATION - time_since_tick
            if time_to_wait < 0:
                time_to_wait = 0
        else:
            # If dead, wait indefinitely for input (no natural depletion)
            time_to_wait = None

        # Print prompt before waiting
        sys.stdout.write("\nEnter a command (F, E, P, I, R, Q) > ")
        sys.stdout.flush()

        # Wait for input OR for the timeout (next tick)
        rlist, _, _ = select.select([sys.stdin], [], [], time_to_wait)

        if rlist:
            # --- Handle User Input ---
            user_input = sys.stdin.readline().strip()
            if not user_input:
                continue

            parts = user_input.split()
            command = parts[0].upper()
            try:
                n = int(parts[1]) if len(parts) > 1 else 1
            except ValueError:
                n = 1

            output_messages = []
            
            if command == 'Q':
                print("Command recognized: Quit.")
                print("Saving session... goodbye!")
                print("--- simulation terminated ---")
                break
            
            elif command == 'R':
                current_energy, output_messages = handle_reset(IEL)
            
            elif current_energy <= 0:
                print("Your pet is dead! You must Reset (R) or Quit (Q).")
                continue

            elif command == 'F':
                current_energy, output_messages = handle_feed(current_energy, n, MEL)
            elif command == 'E':
                current_energy, output_messages = handle_entertain(current_energy, n, MEL)
            elif command == 'P':
                current_energy, output_messages = handle_pet(current_energy, n, MEL)
            elif command == 'I':
                current_energy, output_messages = handle_ignore(current_energy, n, MEL)
            elif command == 'S':
                current_energy, output_messages = handle_sick(current_energy, n, MEL)
            elif command == 'C':
                current_energy, output_messages = handle_cure(current_energy, n, MEL)
            elif command == 'L':
                current_energy, output_messages = handle_learn(current_energy, n, MEL)
            else:
                print("Invalid command! Please try again.")
                continue

            # Print the result of the command
            if output_messages:
                # Print all but last message
                for msg in output_messages[:-1]:
                    print(msg)
                # Print last message with bar
                print(f"{output_messages[-1]} {display_energy_bar(current_energy, MEL)}")
                
                if current_energy <= 0 and command != 'R':
                     print("*** Your Digital Pet has died! ***")

        else:
            # --- Handle Timeout (Natural Depletion) ---
            # Update the tick time
            last_tick_time = time.time()
            
            # Move to new line because prompt was printed
            sys.stdout.write("\n")
            
            if current_energy > 0:
                current_energy -= EDR
                
                if current_energy <= 0:
                    current_energy = 0
                    print(f"Time +1s... Natural energy depletion!\nError, energy level equal or less than 0. DP is dead! {display_energy_bar(current_energy, MEL)}")
                    print("*** Your Digital Pet has died! ***")
                else:
                    print(f"Time +1s... Natural energy depletion!\n{display_energy_bar(current_energy, MEL)}")
            else:
                # Already dead
                pass

if __name__ == "__main__":
    main()
