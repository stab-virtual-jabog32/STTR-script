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
--  3. **RangeManager:activateRange(metagroup)**: Activates AI units within a metagroup with defined ROE.
--  4. **RangeManager:deactivateRange(metagroup)**: Deactivates AI units within a metagroup.
--  5. **RangeManager:weaponsFreeRange(data)**: Sets the ROE for a metagroup to weapons free.
--  6. **RangeManager:returnFireRange(data)**: Sets the ROE for a metagroup to return fire.
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

-- Main Script starts here
local RangeManager

-- Main Script (Runs after all methods are defined)
local function main()
    local rm = RangeManager:new()

    _DATABASE = { GROUPS = {} }
    buildDatabase()

    -- Populate the ranges data structure from mission group names
    for groupName, group in pairs(_DATABASE.GROUPS) do
        local country, rangeID, metagroup, id = string.match(groupName, "^(%u%u%u)%-(%w+)%-(.-)%-(%d%d?)$")
        
        if country and rangeID and metagroup and id then
            if not rm.ranges[country] then rm.ranges[country] = {} end
            if not rm.ranges[country][rangeID] then rm.ranges[country][rangeID] = {} end
            if not rm.ranges[country][rangeID][metagroup] then rm.ranges[country][rangeID][metagroup] = {} end
            
            rm.ranges[country][rangeID][metagroup][groupName] = group
        end
    end

    -- Create radio menu for range control
    local rangeControlMenu = missionCommands.addSubMenu("Range Control")

    for country, rangesInCountry in pairs(rm.ranges) do
        local countryMenu = missionCommands.addSubMenu(country, rangeControlMenu)
        
        for rangeID, metagroupsInRange in pairs(rangesInCountry) do
            local rangeMenu = missionCommands.addSubMenu("Range " .. rangeID, countryMenu)
            
            for metagroup, _ in pairs(metagroupsInRange) do
                local metagroupMenu = missionCommands.addSubMenu(metagroup, rangeMenu)
                
                missionCommands.addCommand("Spawn " .. metagroup, metagroupMenu, function() rm:spawnMetagroup({country = country, rangeID = rangeID, metagroup = metagroup}) end)
                missionCommands.addCommand("Despawn " .. metagroup, metagroupMenu, function() rm:despawnMetagroup({country = country, rangeID = rangeID, metagroup = metagroup}) end)
                missionCommands.addCommand(metagroup .. " Weapons Free", metagroupMenu, function() rm:weaponsFreeRange({country = country, rangeID = rangeID, metagroup = metagroup}) end)
                missionCommands.addCommand(metagroup .. " Weapons Hold", metagroupMenu, function() rm:returnFireRange({country = country, rangeID = rangeID, metagroup = metagroup}) end)
            end
        end
    end

    trigger.action.outText("Range Management Module initialized", 20)
end


-- ==============================
--  RangeManager Class Definition
-- ==============================
RangeManager = {}
RangeManager.__index = RangeManager

function RangeManager:new()
    local self = setmetatable({}, RangeManager)
    
    -- Class-level variables (could be replaced with more sophisticated data tracking if needed)
    self.groupStatus = {}
    self.ranges = {}
    
    return self
end

-- ==============================
--           Methods()
-- ==============================
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

-- Activates the AI units in a metagroup with Return Fire ROE
function RangeManager:activateRange(metagroup)
    for groupName, _ in pairs(self.ranges[metagroup]) do
        local controller = Group.getByName(groupName):getController()
        controller:setOnOff(true)
        controller:setOption(0, 3) -- ROE = RETURN FIRE
        controller:setOption(9, 2) -- ALARM_STATE = RED
    end
    
    trigger.action.outText("Range Group " .. metagroup .. " activated", 10)
end

-- Deactivates the AI units in a metagroup
function RangeManager:deactivateRange(metagroup)
    for groupName, _ in pairs(self.ranges[metagroup]) do
        local controller = Group.getByName(groupName):getController()
        controller:setOption(0, 4) -- ROE = WEAPON HOLD
        controller:setOnOff(false)
    end
    
    trigger.action.outText("Range Group " .. metagroup .. " deactivated", 10)
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

-- Sets ROE to Return Fire for a metagroup
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
                controller:setOption(0, 4) -- ROE = Weapons Hold
            else
                trigger.action.outText("Group not found: " .. groupName, 10)
            end
        end
        
        trigger.action.outText("Range Group " .. metagroup .. " in " .. rangeID .. " (" .. country .. ") set to Weapons Hold", 10)
    else
        trigger.action.outText("Range Group " .. metagroup .. " not found in Range " .. rangeID .. " (" .. country .. ")", 10)
    end
end

-- Call the main function
main()