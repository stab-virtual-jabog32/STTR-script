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
--  1. **spawnMetagroup(data)**: Spawns all units associated with a metagroup.
--  2. **despawnMetagroup(data)**: Despawns all units associated with a metagroup.
--  3. **activateRange(metagroup)**: Activates AI units within a metagroup with defined ROE.
--  4. **deactivateRange(metagroup)**: Deactivates AI units within a metagroup.
--  5. **weaponsFreeRange(data)**: Sets the ROE for a metagroup to weapons free.
--  6. **returnFireRange(data)**: Sets the ROE for a metagroup to return fire.
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
--   spawnMetagroup({country = "USA", rangeID = "01", metagroup = "SA10"})
--   weaponsFreeRange({country = "USA", rangeID = "01", metagroup = "SA10"})
-- 
-- These functions allow you to dynamically control the AI and range management for your mission.
--
-- ================================================================================================
-- ==                              Happy Training and Mission Planning!                         ==
-- ================================================================================================

-- ############################################################################
-- ###                            RANGE SPAWNING                            ###
-- ############################################################################
local groupStatus = {}
function spawnMetagroup(data)
    -- recover country and range ID
    local country = data.country
    local rangeID = data.rangeID
    local metagroup = data.metagroup
    
    -- Check if the metagroup exists under the correct country and rangeID
    if ranges[country] and ranges[country][rangeID] and ranges[country][rangeID][metagroup] then
        
        -- Retrieve the groups associated with this metagroup
        local groups = ranges[country][rangeID][metagroup]
        
        -- Use pairs() to iterate through groups (since groups are stored as key-value pairs)
        for groupName, group in pairs(groups) do
            -- Check the group's status before respawning
            if groupStatus[groupName] == nil or not groupStatus[groupName].active then
                -- Try to activate or respawn the group
                local groupObject = Group.getByName(groupName)
                if groupObject then
                    trigger.action.activateGroup(groupObject)
                    groupStatus[groupName] = { active = true }
                else
                    mist.respawnGroup(groupName, true)
                    groupStatus[groupName] = { active = true }
                end
            else
                trigger.action.outText("Group " .. groupName .. " is already active.", 10)
            end
        end
        
        -- Output text for feedback after spawning the groups
        trigger.action.outText("Spawning Range Group: " .. metagroup .. " in " .. rangeID .. " (" .. country .. ")", 10)
    else
        -- If no metagroup was found
        trigger.action.outText("Range Group " .. metagroup .. " not found in Range " .. rangeID .. " (" .. country .. ")", 10)
    end
end



function despawnMetagroup(data)
    local country = data.country
    local rangeID = data.rangeID
    local metagroup = data.metagroup

    -- Check if the metagroup exists under the correct country and rangeID
    if ranges[country] and ranges[country][rangeID] and ranges[country][rangeID][metagroup] then
        -- Retrieve the groups associated with this metagroup
        local groups = ranges[country][rangeID][metagroup]
        
        -- Use pairs() to iterate through groups (since groups are stored as key-value pairs)
        for groupName, group in pairs(groups) do
            -- Check the group's status before deactivating
            if groupStatus[groupName] and groupStatus[groupName].active then
                -- Deactivate the group
                local groupObject = Group.getByName(groupName)
                if groupObject then
                    trigger.action.deactivateGroup(groupObject)
                    groupStatus[groupName].active = false
                else
                    trigger.action.outText("Group not found: " .. groupName, 10)
                end
            else
                trigger.action.outText("Group " .. groupName .. " is already inactive or not found.", 10)
            end
        end

        -- Output text for feedback after despawning the groups
        trigger.action.outText("Despawning Range Group: " .. metagroup .. " in " .. rangeID .. " (" .. country .. ")", 10)
    else
        -- If no metagroup was found
        trigger.action.outText("Range Group " .. metagroup .. " not found in Range " .. rangeID .. " (" .. country .. ")", 10)
    end
end




function activateRange(metagroup)
	for groupName, group in pairs(ranges[metagroup]) do
		local controller = Group.getByName(groupName):getController()
		controller:setOnOff(true)

		-- see https://wiki.hoggitworld.com/view/DCS_enum_AI
		controller:setOption(0, 3) -- ROE = RETURN FIRE
		controller:setOption(9, 2) -- ALARM_STATE = RED
	end

	trigger.action.outText("Range Group " .. metagroup .. " activated", 10)
end


function deactivateRange(metagroup)
	for groupName, group in pairs(ranges[metagroup]) do
		local controller = Group.getByName(groupName):getController()
		controller:setOption(0, 4) -- ROE = WEAPON HOLD
		controller:setOnOff(false)
	end

	trigger.action.outText("Range Group " .. metagroup .. " deactivated", 10)
end


-- ############################################################################
-- ###                        RULES OF ENGAGEMENT (ROE)                     ###
-- ############################################################################
function weaponsFreeRange(data)
    local country = data.country
    local rangeID = data.rangeID
    local metagroup = data.metagroup

    -- Check if the metagroup exists under the correct country and rangeID
    if ranges[country] and ranges[country][rangeID] and ranges[country][rangeID][metagroup] then
        -- Retrieve the groups associated with this metagroup
        local groups = ranges[country][rangeID][metagroup]
        
        -- Use pairs() to iterate through groups
        for groupName, group in pairs(groups) do
            -- Check if the group exists in the mission
            local groupObject = Group.getByName(groupName)
            if groupObject then
                local controller = groupObject:getController()
                controller:setOption(0, 2) -- ROE = OPEN FIRE (Weapons Free)
            else
                trigger.action.outText("Group not found: " .. groupName, 10)
            end
        end

        -- Output text for feedback after setting ROE to Weapons Free
        trigger.action.outText("Range Group " .. metagroup .. " in " .. rangeID .. " (" .. country .. ") set to Weapons Free", 10)
    else
        -- If no metagroup was found
        trigger.action.outText("Range Group " .. metagroup .. " not found in Range " .. rangeID .. " (" .. country .. ")", 10)
    end
end




function returnFireRange(data)
    local country = data.country
    local rangeID = data.rangeID
    local metagroup = data.metagroup

    -- Check if the metagroup exists under the correct country and rangeID
    if ranges[country] and ranges[country][rangeID] and ranges[country][rangeID][metagroup] then
        -- Retrieve the groups associated with this metagroup
        local groups = ranges[country][rangeID][metagroup]
        
        -- Use pairs() to iterate through groups
        for groupName, group in pairs(groups) do
            -- Check if the group exists in the mission
            local groupObject = Group.getByName(groupName)
            if groupObject then
                local controller = groupObject:getController()
                controller:setOption(0, 3) -- ROE = RETURN FIRE
            else
                trigger.action.outText("Group not found: " .. groupName, 10)
            end
        end

        -- Output text for feedback after setting ROE to Return Fire
        trigger.action.outText("Range Group " .. metagroup .. " in " .. rangeID .. " (" .. country .. ") set to Return Fire", 10)
    else
        -- If no metagroup was found
        trigger.action.outText("Range Group " .. metagroup .. " not found in Range " .. rangeID .. " (" .. country .. ")", 10)
    end
end

-- add range options to menu
--Range Control
ranges = {}
_DATABASE = {
    GROUPS = {}
}
buildDatabase()




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

trigger.action.outText("Range Management Module initialized", 20)