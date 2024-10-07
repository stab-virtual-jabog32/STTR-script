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
--  1. **RangeManager:spawnMetagroup(data)**: Spawns all units associated with a metagroup.
--  2. **RangeManager:despawnMetagroup(data)**: Despawns all units associated with a metagroup.
--  3. **RangeManager:weaponsFreeRange(data)**: Sets the ROE for a metagroup to weapons free.
--  4. **RangeManager:returnFireRange(data)**: Sets the ROE for a metagroup to weapons hold.
-- 
-- ================================================================================================
-- ==                  How to use these functions in your mission:                               ==
-- ================================================================================================
-- To use these range management functions, simply load this file in your main mission script 
-- using the `dofile()` function:
--
--   dofile("C:/path/to/modules/rangeManagement.lua")
--
-- After loading, create a RangeManager object and call its methods like this:
--
--   local rm = RangeManager:new()
--   rm:spawnMetagroup({country = "USA", rangeID = "01", metagroup = "SA10"})
--   rm:weaponsFreeRange({country = "USA", rangeID = "01", metagroup = "SA10"})
--
-- ================================================================================================

-- =====================================
--  Main Range Management Logic and Algo
-- =====================================

-- Forward declare the RangeManager class and aaRanges
local RangeManager
local aaRanges = {}

-- Main Script (Runs after all methods are defined)
local function main()
    local rm = RangeManager:new()

    _DATABASE = { GROUPS = {} }
    buildDatabase()

    -- Populate the ranges data structure from mission group names
    for groupName, group in pairs(_DATABASE.GROUPS) do
        -- Check for the A2A range pattern first
        local prefix, rangeID, airframe, sizeOfFlight = string.match(groupName, "^(A2A)%-(%w+)%-(%w+)%-(.+)$")
        
        if prefix and rangeID and airframe and sizeOfFlight then
            -- Ensure that the aaRanges table is constructed properly
            if not aaRanges[rangeID] then aaRanges[rangeID] = {} end
            if not aaRanges[rangeID][airframe] then aaRanges[rangeID][airframe] = {} end
            aaRanges[rangeID][airframe][sizeOfFlight] = groupName
        else
            -- Fall back to the regular range pattern
            local country, rangeID, metagroup, id = string.match(groupName, "^(%u%u%u)%-(%w+)%-(.-)%-(%d%d?)$")
            
            if country and rangeID and metagroup and id then
                if not rm.ranges[country] then rm.ranges[country] = {} end
                if not rm.ranges[country][rangeID] then rm.ranges[country][rangeID] = {} end
                if not rm.ranges[country][rangeID][metagroup] then rm.ranges[country][rangeID][metagroup] = {} end
                
                rm.ranges[country][rangeID][metagroup][groupName] = groupName
            end
        end
    end

    -- Create radio menu for regular range control
    local rangeControlMenu = missionCommands.addSubMenu("A2G Range Control")

    for country, rangesInCountry in pairs(rm.ranges) do
        local countryMenu = missionCommands.addSubMenu(country, rangeControlMenu)
        
        for rangeID, metagroupsInRange in pairs(rangesInCountry) do
            local rangeMenu = missionCommands.addSubMenu("Range " .. rangeID, countryMenu)
            
            for metagroup, _ in pairs(metagroupsInRange) do
                local metagroupMenu = missionCommands.addSubMenu(metagroup, rangeMenu)
                
                -- Wrap the function reference in an anonymous function to pass arguments correctly
                missionCommands.addCommand("Spawn " .. metagroup, metagroupMenu, function()
                    rm:spawn({rangeType = "regular", country = country, rangeID = rangeID, metagroup = metagroup})
                end)
                missionCommands.addCommand("Despawn " .. metagroup, metagroupMenu, function()
                    rm:despawn({rangeType = "regular", country = country, rangeID = rangeID, metagroup = metagroup})
                end)
                missionCommands.addCommand(metagroup .. " Weapons Free", metagroupMenu, function()
                    rm:weaponsFree({rangeType = "regular", country = country, rangeID = rangeID, metagroup = metagroup})
                end)
                missionCommands.addCommand(metagroup .. " Weapons Hold", metagroupMenu, function()
                    rm:returnFire({rangeType = "regular", country = country, rangeID = rangeID, metagroup = metagroup})
                end)
            end
        end
    end

    -- Create radio menu for A2A range control
    local aaRangeControlMenu = missionCommands.addSubMenu("A2A Range Control")

    for rangeID, airframesInRange in pairs(aaRanges) do
        local rangeMenu = missionCommands.addSubMenu("Range " .. rangeID, aaRangeControlMenu)
        
        for airframe, sizesInAirframe in pairs(airframesInRange) do
            local airframeMenu = missionCommands.addSubMenu(airframe, rangeMenu)
            
            for sizeOfFlight, _ in pairs(sizesInAirframe) do
                local spawnMenu = missionCommands.addSubMenu(sizeOfFlight, airframeMenu)
                missionCommands.addCommand("Spawn " .. airframe .. " ".. sizeOfFlight, spawnMenu, function() 
                    rm:spawn({rangeType = "a2a", rangeID = rangeID, airframe = airframe, sizeOfFlight = sizeOfFlight})
                end)
                missionCommands.addCommand("Despawn " .. airframe .. " ".. sizeOfFlight, spawnMenu, function()
                    rm:despawn({rangeType = "a2a", rangeID = rangeID, airframe = airframe, sizeOfFlight = sizeOfFlight})
                end)
            end
        end
    end

    trigger.action.outText("Range Management Module initialized", 20)
end


-- ==========================
--  RangeManager Class Definition
-- ==========================

RangeManager = {}
RangeManager.__index = RangeManager

function RangeManager:new()
    local self = setmetatable({}, RangeManager)
    self.groupStatus = {}
    self.ranges = {}
    return self
end

-- Spawns all units associated with a metagroup
function RangeManager:spawnMetagroup(data)
    local country = data.country
    local rangeID = data.rangeID
    local metagroup = data.metagroup

    if self.ranges[country] and self.ranges[country][rangeID] and self.ranges[country][rangeID][metagroup] then
        local groups = self.ranges[country][rangeID][metagroup]

        for groupName, _ in pairs(groups) do
            if self.groupStatus[groupName] == nil or not self.groupStatus[groupName].active then
                local groupObject = Group.getByName(groupName)
                if groupObject then
                    trigger.action.activateGroup(groupObject)
                else
                    mist.respawnGroup(groupName, true)
                end
                self.groupStatus[groupName] = { active = true }
            else
                trigger.action.outText("Group " .. groupName .. " is already active.", 10)
            end
        end

        trigger.action.outText("Spawning Range Group: " .. metagroup .. " in " .. rangeID .. " (" .. country .. ")", 10)
    else
        trigger.action.outText("Range Group " .. metagroup .. " not found in Range " .. rangeID .. " (" .. country .. ")", 10)
    end
end

-- Despawns all units associated with a metagroup
function RangeManager:despawnMetagroup(data)
    local country = data.country
    local rangeID = data.rangeID
    local metagroup = data.metagroup

    if self.ranges[country] and self.ranges[country][rangeID] and self.ranges[country][rangeID][metagroup] then
        local groups = self.ranges[country][rangeID][metagroup]

        for groupName, _ in pairs(groups) do
            if self.groupStatus[groupName] and self.groupStatus[groupName].active then
                local groupObject = Group.getByName(groupName)
                if groupObject then
                    trigger.action.deactivateGroup(groupObject)
                    self.groupStatus[groupName].active = false
                else
                    trigger.action.outText("Group not found: " .. groupName, 10)
                end
            else
                trigger.action.outText("Group " .. groupName .. " is already inactive or not found.", 10)
            end
        end

        trigger.action.outText("Despawning Range Group: " .. metagroup .. " in " .. rangeID .. " (" .. country .. ")", 10)
    else
        trigger.action.outText("Range Group " .. metagroup .. " not found in Range " .. rangeID .. " (" .. country .. ")", 10)
    end
end

-- Sets ROE to Weapons Free for a metagroup
function RangeManager:weaponsFreeRange(data)
    local country = data.country
    local rangeID = data.rangeID
    local metagroup = data.metagroup

    if self.ranges[country] and self.ranges[country][rangeID] and self.ranges[country][rangeID][metagroup] then
        local groups = self.ranges[country][rangeID][metagroup]

        for groupName, _ in pairs(groups) do
            local groupObject = Group.getByName(groupName)
            if groupObject then
                local controller = groupObject:getController()
                controller:setOption(0, 2) -- ROE = OPEN FIRE (Weapons Free)
            else
                trigger.action.outText("Group not found: " .. groupName, 10)
            end
        end

        trigger.action.outText("Range Group " .. metagroup .. " in " .. rangeID .. " (" .. country .. ") set to Weapons Free", 10)
    else
        trigger.action.outText("Range Group " .. metagroup .. " not found in Range " .. rangeID .. " (" .. country .. ")", 10)
    end
end

-- Sets ROE to Weapons Hold for a metagroup
function RangeManager:returnFireRange(data)
    local country = data.country
    local rangeID = data.rangeID
    local metagroup = data.metagroup

    if self.ranges[country] and self.ranges[country][rangeID] and self.ranges[country][rangeID][metagroup] then
        local groups = self.ranges[country][rangeID][metagroup]

        for groupName, _ in pairs(groups) do
            local groupObject = Group.getByName(groupName)
            if groupObject then
                local controller = groupObject:getController()
                controller:setOption(0, 4) -- ROE = WEAPON HOLD
            else
                trigger.action.outText("Group not found: " .. groupName, 10)
            end
        end

        trigger.action.outText("Range Group " .. metagroup .. " in " .. rangeID .. " (" .. country .. ") set to Weapons Hold", 10)
    else
        trigger.action.outText("Range Group " .. metagroup .. " not found in Range " .. rangeID .. " (" .. country .. ")", 10)
    end
end

-- Generic spawn function
function RangeManager:spawn(data)
    -- if it is a regular group, call spawnMetagroup directly
    if data.rangeType == "regular" then
        self:spawnMetagroup(data)
    -- if it is an a2a range, handle it a bit differently for a proper spawn message
    elseif data.rangeType == "a2a" then
        local rangeID = data.rangeID
        local airframe = data.airframe
        local sizeOfFlight = data.sizeOfFlight
        
        if aaRanges[rangeID] and aaRanges[rangeID][airframe] and aaRanges[rangeID][airframe][sizeOfFlight] then
            local groupName = aaRanges[rangeID][airframe][sizeOfFlight]
            if self.groupStatus[groupName] == nil or not self.groupStatus[groupName].active then
                mist.respawnGroup(groupName, true)
                self.groupStatus[groupName] = { active = true }
                trigger.action.outText("Spawning A2A Group: " .. airframe .. " " .. sizeOfFlight .. " in " .. rangeID, 10)
            else
                trigger.action.outText("Group " .. groupName .. " is already active.", 10)
            end
        else
            trigger.action.outText("A2A Range Group not found for spawning: " .. airframe .. " " .. sizeOfFlight .. " in " .. rangeID, 10)
        end
    else
        trigger.action.outText("Error: Invalid rangeType provided - " .. tostring(data.rangeType), 10)
    end
end

-- Generic despawn function
function RangeManager:despawn(data)
    if data.rangeType == "regular" then
        self:despawnMetagroup(data)
    elseif data.rangeType == "a2a" then
        local rangeID = data.rangeID
        local airframe = data.airframe
        local sizeOfFlight = data.sizeOfFlight

        if aaRanges[rangeID] and aaRanges[rangeID][airframe] and aaRanges[rangeID][airframe][sizeOfFlight] then
            local groupName = aaRanges[rangeID][airframe][sizeOfFlight]
            local groupObject = Group.getByName(groupName)
            if groupObject then
                trigger.action.deactivateGroup(groupObject)
                self.groupStatus[groupName].active = false
                trigger.action.outText("Despawning A2A Group: " .. airframe .. " " .. sizeOfFlight .. " in " .. rangeID, 10)
            else
                trigger.action.outText("A2A Group not found for despawning: " .. airframe .. " " .. sizeOfFlight .. " in " .. rangeID, 10)
            end
        else
            trigger.action.outText("A2A Range Group not found for despawning: " .. airframe .. " " .. sizeOfFlight .. " in " .. rangeID, 10)
        end
    end
end

-- Generic ROE Weapons Free function
function RangeManager:weaponsFree(data)
    if data.rangeType == "regular" then
        self:weaponsFreeRange(data)
    elseif data.rangeType == "a2a" then
        local rangeID = data.rangeID
        local airframe = data.airframe
        local sizeOfFlight = data.sizeOfFlight

        if aaRanges[rangeID] and aaRanges[rangeID][airframe] and aaRanges[rangeID][airframe][sizeOfFlight] then
            local groupName = aaRanges[rangeID][airframe][sizeOfFlight]
            local groupObject = Group.getByName(groupName)
            if groupObject then
                local controller = groupObject:getController()
                controller:setOption(0, 2) -- ROE = OPEN FIRE (Weapons Free)
                trigger.action.outText("Setting A2A Group to Weapons Free: " .. airframe .. " " .. sizeOfFlight .. " in " .. rangeID, 10)
            else
                trigger.action.outText("A2A Group not found for Weapons Free: " .. airframe .. " " .. sizeOfFlight .. " in " .. rangeID, 10)
            end
        else
            trigger.action.outText("A2A Range Group not found for Weapons Free: " .. airframe .. " " .. sizeOfFlight .. " in " .. rangeID, 10)
        end
    end
end

-- Generic ROE Return Fire function
function RangeManager:returnFire(data)
    if data.rangeType == "regular" then
        self:returnFireRange(data)
    elseif data.rangeType == "a2a" then
        local rangeID = data.rangeID
        local airframe = data.airframe
        local sizeOfFlight = data.sizeOfFlight

        if aaRanges[rangeID] and aaRanges[rangeID][airframe] and aaRanges[rangeID][airframe][sizeOfFlight] then
            local groupName = aaRanges[rangeID][airframe][sizeOfFlight]
            local groupObject = Group.getByName(groupName)
            if groupObject then
                local controller = groupObject:getController()
                controller:setOption(0, 4) -- ROE = Weapons Hold
                trigger.action.outText("Setting A2A Group to Weapons Hold: " .. airframe .. " " .. sizeOfFlight .. " in " .. rangeID, 10)
            else
                trigger.action.outText("A2A Group not found for Weapons Hold: " .. airframe .. " " .. sizeOfFlight .. " in " .. rangeID, 10)
            end
        else
            trigger.action.outText("A2A Range Group not found for Weapons Hold: " .. airframe .. " " .. sizeOfFlight .. " in " .. rangeID, 10)
        end
    end
end

-- Call the main function
main()
