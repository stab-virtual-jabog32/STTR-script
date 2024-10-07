## VJaBoG32 Bombing Feedback

### Overview
The **VJaBoG32 Bombing Feedback** module provides real-time feedback for bomb impacts within specific target circles in a flight simulation environment. Designed by the JaBoG32 Team, this code allows players to track bomb drops, evaluate their accuracy, and receive detailed feedback on the impact results.


### Author
**JaBoG32 Team**

### Purpose
This module aims to:
- Track bomb impacts on predefined target circles.
- Provide feedback regarding the accuracy of bomb drops.
- Enhance player experience by offering real-time evaluations.

### Getting Started
To use the bombing feedback feature, you'll need to toggle it on during your flight mission. The functionality is built around a simple command that you can activate via the radio menu.

## Key Classes & Functions
1. **Bomb Class**:
   - `Bomb:new(ordnance, bombInit, playerGroupID, releaseAlpha, releaseData)`: Constructor to create new Bomb objects with relevant data.
   - `Bomb:startTracking()`: Initiates movement tracking for the bomb.
   - `Bomb:evaluateBomb(bombPos)`: Evaluates bomb impact and provides feedback based on its position relative to target circles.

2. **togglevJaBoG32bombingfeedback()**: 
   - Toggles the bombing feedback system on or off.

3. **BombEventHandler:onEvent(event)**: 
   - Listens for bomb shot events and initializes tracking for each bomb dropped.

## Usage
Place in a folder and load the script into your main script with.

```lua
trainingFunctions = missionCommands.addSubMenu("Trainingfunctions", generalOptions);
dofile(basedir .. "modules/bombFeedbackHook.lua")   -- initializes the Bomb Feedback Module (hook)
```

Note that a custom submenu with the name generalOptions needs to be present.
To enable or disable bombing feedback, use the command in the radio menu:
