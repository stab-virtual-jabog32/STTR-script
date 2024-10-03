--__      __       _           ____             _____   ____    ___  
--\ \    / /      | |         |  _ \           / ____| |___ \  |__ \ 
-- \ \  / /       | |   __ _  | |_) |   ___   | |  __    __) |    ) |
--  \ \/ /    _   | |  / _` | |  _ <   / _ \  | | |_ |  |__ <    / / 
--   \  /    | |__| | | (_| | | |_) | | (_) | | |__| |  ___) |  / /_ 
--    \/      \____/   \__,_| |____/   \___/   \_____| |____/  |____|
--
-- ================================================================================================
-- ==                     VJaBoG32 RANGE MANAGEMENT MODULE                                       ==
-- ================================================================================================
-- ==  Author: JaBoG32 Team                                                                      ==
-- ==  Date: 2024                                                                                ==
-- ==  Purpose: Management of range spawning, LATN areas, and ROE for DCS missions               ==
-- ================================================================================================
-- ==                                What is this?                                               ==
-- ================================================================================================
-- This script handles the management of ranges for DCS missions. It includes:
--  - Spawning and despawning AI units for training ranges.
--  - Management of LATN areas, including spawning threats.
--  - Control of Rules of Engagement (ROE) for range units.
-- 
-- The script enables dynamic training scenarios by allowing the activation and deactivation of 
-- ranges, LATN areas, and AI units via triggers and radio commands.
--
-- ================================================================================================
-- ==                           Functions included in this module:                               ==
-- ================================================================================================
--  1. **spawnRange(range)**: Spawns all units associated with a range.
--  2. **despawnRange(range)**: Despawns all units associated with a range.
--  3. **activateRange(range)**: Activates AI units within a range with defined ROE.
--  4. **deactivateRange(range)**: Deactivates AI units within a range.
--  5. **weaponsFreeRange(range)**: Sets the ROE for a range to weapons free.
--  6. **returnFireRange(range)**: Sets the ROE for a range to return fire.
--  7. **spawnLatn(area)**: Spawns AI units for LATN areas.
--  8. **despawnLatn(area)**: Despawns AI units for LATN areas.
--  9. **activateLatn(area)**: Activates AI units in LATN areas with combat ROE.
-- 10. **deactivateLatn(area)**: Deactivates AI units in LATN areas and sets ROE to weapon hold.
-- 
-- ================================================================================================
-- ==                  How to use these functions in your mission:                               ==
-- ================================================================================================
-- To use these range management functions, simply load this file in your main mission script 
-- using the `dofile()` function:
--
--   dofile("C:/path/to/modules/rangeManagement.lua")
--
-- After loading, you can call the functions directly, like this:
--
--   spawnRange("RangeName")
--   activateLatn("LATNArea")
-- 
-- These functions allow you to dynamically control the AI and range management for your mission.
--
-- ================================================================================================
-- ==                              Happy Training and Mission Planning!                         ==
-- ================================================================================================	

-- ############################################################################
-- ###                            RANGE SPAWNING                            ###
-- ############################################################################
function spawnRange(range)
	for groupName, group in pairs(ranges[range]) do
		trigger.action.activateGroup(Group.getByName(groupName))
	end

	trigger.action.outText("Range " .. range .. " spawned", 10)
end


function despawnRange(range)
	for groupName, group in pairs(ranges[range]) do
		trigger.action.deactivateGroup(Group.getByName(groupName))
	end

	trigger.action.outText("Range " .. range .. " despawned", 10)
end


function activateRange(range)
	for groupName, group in pairs(ranges[range]) do
		local controller = Group.getByName(groupName):getController()
		controller:setOnOff(true)

		-- see https://wiki.hoggitworld.com/view/DCS_enum_AI
		controller:setOption(0, 3) -- ROE = RETURN FIRE
		controller:setOption(9, 2) -- ALARM_STATE = RED
	end

	trigger.action.outText("Range " .. range .. " activated", 10)
end


function deactivateRange(range)
	for groupName, group in pairs(ranges[range]) do
		local controller = Group.getByName(groupName):getController()
		controller:setOption(0, 4) -- ROE = WEAPON HOLD
		controller:setOnOff(false)
	end

	trigger.action.outText("Range " .. range .. " deactivated", 10)
end


-- ############################################################################
-- ###                            LATN AREAS MANAGEMENT                     ###
-- ############################################################################
function spawnLatn(area)
	for groupName, group in pairs(latn_areas[area]) do
		trigger.action.activateGroup(Group.getByName(groupName))
	end

	trigger.action.outText("AAA/SAM threats in " .. area .. " spawned.", 10)
end

function despawnLatn(range)
	for groupName, group in pairs(ranges[range]) do
		local grp = Group.getByName(groupName)
		local controller = grp:getController()
		controller:setOption(0, 4) -- ROE = WEAPON HOLD
		controller:setOnOff(false)
		trigger.action.deactivateGroup(grp)
	end

	trigger.action.outText("AAA/SAM threats in " .. area .. " despawned.", 10)
end



function activateLatn(area)
	for groupName, group in pairs(latn_areas[area]) do
		local controller = Group.getByName(groupName):getController()
		controller:setOnOff(true)

		-- see https://wiki.hoggitworld.com/view/DCS_enum_AI
		controller:setOption(0, 2) -- ROE = OPEN FIRE
		controller:setOption(9, 2) -- ALARM_STATE = RED
	end

	trigger.action.outText("AAA/SAM threats in " .. area .. " activated!", 10)
end

function deactivateLatn(area)
	for groupName, group in pairs(latn_areas[area]) do
		local controller = Group.getByName(groupName):getController()
		controller:setOption(0, 4) -- ROE = WEAPON HOLD
		controller:setOnOff(false)
	end

	trigger.action.outText("AAA/SAM threats in " .. area .. " deactivated.", 10)
end

-- ############################################################################
-- ###                        RULES OF ENGAGEMENT (ROE)                     ###
-- ############################################################################
function weaponsFreeRange(range)
	for groupName, group in pairs(ranges[range]) do
		local controller = Group.getByName(groupName):getController()
		controller:setOption(0, 2) -- ROE = OPEN FIRE
	end

	trigger.action.outText("Range " .. range .. " ROE Weapons FREE set!", 10)
end


function returnFireRange(range)
	for groupName, group in pairs(ranges[range]) do
		local controller = Group.getByName(groupName):getController()
		controller:setOption(0, 3)
	end

	trigger.action.outText("Range " .. range .. " ROE return fire set", 10)
end

-- add range options to menu
--Range Control
ranges = {}
latn_areas = {}
latn_names = {
	["LATNW"] = "LATN West",
	["LATNC"] = "LATN Central",
	["LATNE"] = "LATN East",
	["LATNV"] = "LATN Village",
	["LATNG"] = "LATN Ground",
	["LATNA"] = "LATN Airport",
}

-- Categorizes groups from the mission database into 'ranges' and 'latn_areas' based on their names (set in the Mission Editor)
-- For example, a group named "64A-10" is categorized under 'ranges' (e.g., "64A"), while "LATN-East" goes into 'latn_areas'
-- Dynamically organizes mission entities based on their naming conventions for efficient activation/deactivation control

-- Define the _DATABASE structure similar to MOOSE (substitute for MOOSE)
_DATABASE = {
    GROUPS = {}
}

-- Call the function to build the database
buildDatabase()

for groupName, group in pairs(_DATABASE.GROUPS) do
	if string.match(groupName, "^%d%dM?G?T?%-%d%d$") then
		range, id = string.match(groupName, "^(%d%dM?G?T?)%-(%d%d)$")
		if ranges[range] == nil then
			ranges[range] = {}
		end
		ranges[range][groupName] = group
	end
	if string.match(groupName, "^LATN.%-.+$") then
		area, id = string.match(groupName, "^(LATN.)%-(.+)$")
		if latn_areas[area] == nil then
			latn_areas[area] = {}
		end
		latn_areas[area][groupName] = group
	end
end
 
-- Creates the menu
local rangeControlMenu = missionCommands.addSubMenu("Range Control ...", generalOptions)
local currentRangeFirstDigit = "0"
local rangeGroupControlMenu
for range, groups in pairsByKeys(ranges)
do
	local rangeFirstDigit = string.sub(range, 1, 1)
	if rangeFirstDigit ~= currentRangeFirstDigit
	then
		rangeGroupControlMenu = missionCommands.addSubMenu("Ranges " .. rangeFirstDigit .. "X", rangeControlMenu)
		currentRangeFirstDigit = rangeFirstDigit
	end
	local rangeMenu = missionCommands.addSubMenu("Range " .. range, rangeGroupControlMenu)
	missionCommands.addCommand("Spawn", rangeMenu, spawnRange, range)
	missionCommands.addCommand("Despawn", rangeMenu, despawnRange, range)
	missionCommands.addCommand("Activate", rangeMenu, activateRange, range)
	missionCommands.addCommand("Deactivate", rangeMenu, deactivateRange, range)
	missionCommands.addCommand("ROE Weapons free", rangeMenu, weaponsFreeRange, range)
	missionCommands.addCommand("ROE Return fire", rangeMenu, returnFireRange, range)
end

for area, groups in pairsByKeys(latn_areas)
do
	local rangeMenu = missionCommands.addSubMenu(latn_names[area], rangeControlMenu)
	missionCommands.addCommand("Spawn threats", rangeMenu, spawnLatn, area)
	missionCommands.addCommand("Despawn threats", rangeMenu, despawnLatn, area)
	missionCommands.addCommand("Activate threats", rangeMenu, activateLatn, area)
	missionCommands.addCommand("Deactivate threats", rangeMenu, deactivateLatn, area)
end
trigger.action.outText("Range Management Module initialized", 20)