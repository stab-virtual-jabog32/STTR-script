# VJaBoG32 Range Management Module
## Overview
The **VJaBoG32 Range Management Module** provides a set of tools for managing range units, and Rules of Engagement (ROE) in DCS missions. This module allows mission designers to dynamically spawn, despawn, activate, and manage AI units on ranges, as well as control ROE settings through a radio menu based on a naming convention.

**Features**
- **Dynamic Spawning and Despawning:** Spawn or despawn metagroups dynamically through a radio menu.
- **Rules of Engagement Control:** Set units to Weapons Free or Weapons Hold (Return Fire).
- **Hierarchical Range Management:** Organize ranges into countries and subranges for easier management.
- **Support for Air-to-Air (A2A) Ranges:** Handle specific Air-to-Air engagements with distinct rules.

## For Mission Designers
### Prerequisites
- You need to create a top-level radio menu named `generalOptions` in your mission.
- Load the range management module in your DCS mission script using:

```lua
dofile("path/to/rangeManagement.lua")
```

### How to Use
1. **Create Units in the Mission Editor:** Use the following naming convention to define the groups that should be managed by this module:

`Country`-`RangeID`-`Metagroup`-`ID`

Examples:
- `SWE-ESR01-SA10-1`
- `NOR-R92A-Artillery-02`
- `USA-ESR01-F16-Flight1`

2. **Add the `rangeManagement.lua` Script:** Load the script as part of your mission initialization. Once the mission starts, the script will automatically:
- Parse group names based on the defined naming convention.
- Create a hierarchical radio menu for spawning, despawning, and ROE control for each metagroup.

3. **Radio Menu:** The script will automatically create a menu structure under the "Range Control" top-level menu, organized by Country -> RangeID -> Metagroup. You will be able to:

- Spawn and despawn groups.
- Set their ROE to Weapons Free or Weapons Hold.

4. **Air-to-Air Ranges:** To define Air-to-Air (A2A) ranges we need to use another naming convention as we have less units but more options.
Use the following naming convention:

`A2A`-`RangeID`-`Airframe`-`SizeAndOrdnanceOfFlight`

Examples:
- `A2A-ESR02-F14-GunsX1`
- `A2A-ENR01-F16-X4`
A separate "A2A Ranges" menu will be created for handling A2A-specific ranges.

## For Developers
The module has been refactored to an object oriented structure.
This ensures that we:
- can have variables that are instanced in their scope
- can have the top level `main()` function at the top of the code and the support functions below
- can easily reuse the code for duplicating logics (like we did for A2A)

### Module Overview
This module revolves around the `RangeManager` class, which manages range entities, their spawning, despawning, and ROE control. The module parses groups from the mission database, builds a hierarchical radio menu, and allows the user to manage these groups dynamically.

### Naming Conventions
The following naming convention is used to parse groups from the mission:

`Country`-`RangeID`-`Metagroup`-`ID`

See the following regular expression:
```lua
"^(%u%u%u)%-(%w+)%-(.-)%-(%d%d?)$"
```
Where:
- Country: A 3-letter country code (e.g., USA, SWE).
- RangeID: Identifies the range (e.g., ESR01, R92A).
- Metagroup: A logical grouping of one or more DCS groups (e.g., Artillery, SA10).
- ID: An incremental number to ensure uniqueness and allow combination of groups into a metagroup(e.g., 01, 02).

For Air-to-Air ranges, the naming convention is:

`A2A`-`RangeID`-`Airframe`-`SizeAndOrdnanceOfFlight`
See the following regular expression:

```lua
"^(A2A)%-(%w+)%-(%w+)%-(.+)$"
```

This structure allows the module to categorize the units in a mission and build a radio menu for each country, range, and metagroup.

### Parsing logic
The module automatically builds its structure by scanning all groups in the mission file that match these patterns:
```lua
local country, rangeID, metagroup, id = string.match(groupName, "^(%u%u%u)%-(%w+)%-(.-)%-(%d%d?)$")
local prefix, rangeID, airframe, sizeOfFlight = string.match(groupName, "^(A2A)%-(%w+)%-(%w+)%-(.+)$")
```

### Radio Menu Construction
The script constructs a hierarchical radio menu that mimics the parsed data structure. For regular ranges, it creates the following structure:

```lua
Range Control
- Country (e.g., SWE)
  - RangeID (e.g., ESR01)
    - Metagroup (e.g., SA10)
      - Spawn
      - Despawn
      - Weapons Free
      - Weapons Hold
```

For Air-to-Air ranges, it creates a separate **"A2A Ranges"** menu:
```lua
A2A Ranges
- RangeID (e.g., ESR02)
  - Airframe (e.g., F14)
    - Spawn
    - Despawn
    - Weapons Free
    - Weapons Hold
```

### Input Parsing for Functions
The module's functions are structured to accept input as tables containing metadata (country, rangeID, metagroup), which avoids having to reconstruct this data inside each function. This makes the interface clean and avoids searching through the parsed data again for the necessary fields.
We use these inside anonymous function blocks in the missionCommands.addCommand menu.

Du to the unified interface and having opted for an object oriented design with a class and its methods we cannot parse the arguments as the fourth field like it is regularily done.

Example:
```lua
rm:spawn({rangeType = "regular", country = country, rangeID = rangeID, metagroup = metagroup})
rm:weaponsFree({rangeType = "a2a", rangeID = rangeID, airframe = airframe, sizeOfFlight = sizeOfFlight})
```

By passing this table of arguments, the function has all the necessary metadata to:
- Display meaningful messages to the user.
- Manage potential naming conflicts between similarly named groups.

### Key Functions
`RangeManager:spawn(data)`
Spawns the groups associated with the specified metagroup or A2A group. Uses the following logic:
- For regular ranges, it calls spawnMetagroup.
- For A2A ranges, it spawns the groups using mist.respawnGroup and updates the group's status.

`RangeManager:despawn(data)`
Despawns the groups in the specified metagroup or A2A group.

`RangeManager:weaponsFree(data)`
Sets the ROE of the specified groups to `Weapons Free`. This applies to both regular and A2A ranges.

`RangeManager:returnFire(data)`
Sets the ROE of the specified groups to `Weapons Hold`, meaning the units will hold their weapons no matter what.

### Prerequisites
- `generalOptions`: The script relies on a top-level radio menu named `generalOptions`. This must be created in the mission editor before loading the script.
- `MIST`: The script uses `mist.respawnGroup()` for spawning A2A groups. Ensure that the MIST script is loaded in your mission before running the range management module.