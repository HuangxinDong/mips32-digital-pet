# MIPS32 Digital Pet Simulator

A Digital Pet Simulator written in MIPS32 Assembly Language. This project simulates a virtual pet that requires care, attention, and energy management.

## Features

### Core Mechanics
*   **Energy System**: Manage your pet's energy. It depletes over time (Natural Depletion) and changes based on your interactions.
*   **Leveling System**: Perform positive actions (Feed, Entertain, Pet) to level up your pet. Higher levels unlock new features.
*   **Status Bar**: Real-time visual representation of energy: `[######----] Energy: 6/10`.

### Advanced Features
*   **Sleep Mode (`S`)**: Put your pet to sleep to pause energy depletion.
*   **Sickness & Cure (`C`)**: Your pet has a random chance to get sick. You must cure it before interacting further.
*   **Dating (`D`)**: Once your pet reaches **Level 2**, it can go on dates! Outcomes vary.
*   **Save & Load System**: 
    *   Save your progress at any time by Quitting (`Q`).
    *   Generates a secure, 3-part encrypted **Save Code**.
    *   Restore your session exactly where you left off.

### Game Analytics
Upon death or quitting, receive a detailed performance report:
*   **Total Time Alive**: How long your pet survived.
*   **Final Level**: The level achieved.
*   **Positive Actions**: Total number of caring interactions.
*   **Times Sick**: How often your pet fell ill.
*   **Final Score**: Calculated based on survival time, level, and interactions.
*   **Performance Analysis**: Get a comment on your overall behavior&score.

## Commands

| Command | Description | Example |
| :--- | :--- | :--- |
| `F n` | **Feed**: Increase Energy by `1 * n` | `F 2` |
| `E n` | **Entertain**: Increase Energy by `2 * n` | `E 2` |
| `P n` | **Pet**: Increase Energy by `2 * n` | `P 3` |
| `I n` | **Ignore**: Decrease Energy by `3 * n` | `I 2` |
| `S` | **Sleep**: Toggle Sleep Mode (Pauses depletion) | `S` |
| `C` | **Cure**: Cure sickness (if sick) | `C` |
| `D` | **Date**: Go on a date (Requires Level 2+) | `D` |
| `R` | **Reset**: Restart the game | `R` |
| `Q` | **Quit**: Save game and Exit | `Q` |

## How to Run

1.  **Prerequisites**: You need a MIPS simulator.
    *   [MARS (MIPS Assembler and Runtime Simulator)](https://computerscience.missouristate.edu/mars-mips-simulator.htm) is recommended.

2.  **Steps**:
    *   Open `main.asm` in your simulator.
    *   Assemble the code (Run -> Assemble).
    *   Run the simulation (Run -> Go).
    *   Follow the prompts to set initial parameters (EDR, MEL, IEL) or press Enter for defaults.
    *   Use commands to interact with your digital pet.

## Save Code Format
The save system uses a 4-part integer code which encodes:
1.  **Game Config**: EDR, MEL, IEL, Current Energy.
2.  **State**: Sickness, Sleep, Level, Positive Actions.
3.  **Statistics**: Total Time Alive.

*Note: Codes are obfuscated to prevent simple tampering.*
