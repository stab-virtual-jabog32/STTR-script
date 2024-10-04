# STTR Script - VJaBoG32

## VJaBoG32 Range Management Module

This module provides tools for managing **range units**, **LATN areas**, and **Rules of Engagement (ROE)** in DCS missions. It is designed to offer dynamic control of AI units on ranges, allowing them to be spawned, despawned, activated, and deactivated, as well as have their ROE modified.

### Features

- **Spawn and Despawn Metagroups**: Dynamically spawn and despawn groups on ranges.
- **ROE Control**: Set the ROE of units to `Weapons Free` or `Return Fire`.
- **Dynamic Range Management**: Activate or deactivate groups on a range based on mission requirements.
- **LATN Area Control**: Spawn and manage AI threats within LATN areas.

Dynamic Radio Menu and Spawn Logic based on Naming Convention

You can place Units and categorize them into
- `Country`: The country helps to subdivide Training ranges in their country to not clutter the F10 Menu with more entries than F keys. Three letter keys (SWE)
- `RangeID`: The range corresponds to the range areas in which the Metagroup is inside. Restricted to up to 5 capital letters or Numbers (ESR01, R92A)
- `Metagroup`: A Metagroup can consist of one or more `DCS Groups`. This is the atomic spawn entity that will be spawned. A string like (Artillery Group)
- `ID`: An incremental number to have unique DCS group names (01)

Full examples are:
`SWE-ESR01-Artillery Group-2`
`SWE-ESR01-SA10-1`
`NOR-R92A-Two F16s-05`

The Dynamic Range Loader will construct a radio Menu for this like

```
Range Control
- SWE
    -- ESR01
        --- Artillery Group
        --- SA10
```

and provide
`spawn`, `despawn`, `ROE free`, `ROE hold` for each Metagroup


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
