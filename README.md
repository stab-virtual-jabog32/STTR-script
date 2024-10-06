# Table of Contents

- [STTR Script - VJaBoG32](#sttr-script---vjabog32)
- [VJaBoG32 Range Management Module](#vjabog32-range-management-module)
  - [Features](#features)
  - [How to use](#how-to-use)
  - [Detailed Algorithm Design & Naming Convention](#detailed-algorithm-design--naming-convention)
- [VJaBoG32 Bombing Feedback](#vjabog32-bombing-feedback)
  - [Overview](#overview)
  - [Author](#author)
  - [Purpose](#purpose)
  - [Getting Started](#getting-started)
- [Key Classes & Functions](#key-classes--functions)
  - [Bomb Class](#bomb-class)
  - [togglevJaBoG32bombingfeedback()](#togglevjabog32bombingfeedback)
  - [BombEventHandler:onEvent(event)](#bombeventhandleroneventevent)
- [Usage](#usage)


# STTR Script - VJaBoG32

This is the Script for our Training TEmplate
Copyright (C) 2024  JaBoG32 Team
MIST is not included in this Repository but a prerequisite to use the script
- See: https://github.com/mrSkortch/MissionScriptingTools

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

## VJaBoG32 Range Management Module

This module provides tools for managing **range units**, **LATN areas**, and **Rules of Engagement (ROE)** in DCS missions. It is designed to offer dynamic control of AI units on ranges, allowing them to be spawned, despawned, activated, and deactivated, as well as have their ROE modified.

### Features

- **Spawn and Despawn Metagroups**: Dynamically spawn and despawn groups on ranges.
- **ROE Control**: Set the ROE of units to `Weapons Free` or `Return Fire`.
- **Dynamic Range Management**: Activate or deactivate groups on a range based on mission requirements.
- **LATN Area Control**: Spawn and manage AI threats within LATN areas.

Dynamic Radio Menu and Spawn Logic based on Naming Convention

### How to use
Open a new miz file and create your ranges and stick to the naming rule.
Load a top level script (like the main lua here) that loads the `misc` and `utils` modules and create a top level Radio Menu
that is called `generalOptions` (must be present for the `rangeManagement` module).
Then execute the `rangeManagement.lua` via do file and the script should do everything automatically.

### Detailed Algorithm Design & Naming Convention
You can place Units and categorize them into
- `Country`: The country helps to subdivide Training ranges in their country to not clutter the F10 Menu with more entries than F keys. Three letter keys (SWE)
- `RangeID`: The range corresponds to the range areas in which the Metagroup is inside. Restricted to up to 5 capital letters or Numbers (ESR01, R92A)
- `Metagroup`: A Metagroup can consist of one or more `DCS Groups`. This is the atomic spawn entity that will be spawned. A string like (Artillery Group)
- `ID`: An incremental number to have unique DCS group names (01)

´country´-´rangeID´-´metagroup´-´id´

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

-NOR
    -- NOR
        --- Two F16s
```

and provide
`spawn`, `despawn`, `ROE free`, `ROE hold` for each Metagroup

The corresponding logic can be found in `rangeManagement.lua` from line 243 on.
```lua
for groupName, group in pairs(_DATABASE.GROUPS) do
    -- Match the pattern and extract the four parts (Country, RangeID, MetaGroup, ID)
    local country, rangeID, metagroup, id = string.match(groupName, "^(%u%u%u)%-(%w+)%-(.-)%-(%d%d?)$")
    
    if country and rangeID and metagroup and id then
        -- Ensure that the country exists in the ranges table
        if ranges[country] == nil then
            ranges[country] = {}
        end
        
        -- Ensure that the rangeID exists under the country
        if ranges[country][rangeID] == nil then
            ranges[country][rangeID] = {}
        end
        
        -- Ensure that the metagroup exists under the rangeID
        if ranges[country][rangeID][metagroup] == nil then
            ranges[country][rangeID][metagroup] = {}
        end
        
        -- Store the group under the metagroup
        ranges[country][rangeID][metagroup][groupName] = group
        
	end
end
```
Here we loop through all groups in the miz file and search for the string pattern that matches the described notation.
We then assign the group into a table that categorizes them fully into country, ranges and metagroups.

From line `269` on we loop through this table again top->down and create the radio menu in the same order at each for loop level
```lua
-- Creating the radio menu based on the hierarchical structure (Country -> RangeIDs -> metaGroups -> ID)
local rangeControlMenu = missionCommands.addSubMenu("Range Control ...", generalOptions)

-- Iterate through countries
for country, rangesInCountry in pairs(ranges) do
    -- Create a submenu for each country
    local countryMenu = missionCommands.addSubMenu(country, rangeControlMenu)
    
    -- Iterate through ranges within the country
    for rangeID, metagroupsInRange in pairs(rangesInCountry) do
        -- Create a submenu for each range within the country
        local rangeMenu = missionCommands.addSubMenu("Range " .. rangeID, countryMenu)
        
        -- Iterate through metagroups within the range
        for metagroup, metagroups in pairs(metagroupsInRange) do
            -- Create a submenu for each metagroup within the range
            local metagroupMenu = missionCommands.addSubMenu(metagroup, rangeMenu)
            
            -- Add a command to spawn the metagroup (e.g., send the metagroup to the spawn function)
            missionCommands.addCommand("Spawn " .. metagroup, metagroupMenu, spawnMetagroup, {country = country, rangeID = rangeID, metagroup = metagroup})
			missionCommands.addCommand("Despawn " .. metagroup, metagroupMenu, despawnMetagroup, {country = country, rangeID = rangeID, metagroup = metagroup})
			missionCommands.addCommand(metagroup .. " Weapons Free", metagroupMenu, weaponsFreeRange, {country = country, rangeID = rangeID, metagroup = metagroup})
			missionCommands.addCommand(metagroup .. " Weapons Hold", metagroupMenu, returnFireRange, {country = country, rangeID = rangeID, metagroup = metagroup})
        end
    end
end
```

We then parse the metagroup to the corresponding functions, but we parse it as a table containing also explicitly the country and rangeIDs as metadata
in order not to have to search for it again in the functions on deconstruction and avoid naming conflicts, as we want to have the country and the rangeID
in the spawn message.

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
