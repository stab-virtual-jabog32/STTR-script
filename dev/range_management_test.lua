local commands = {}
local messages = {}
local spawnCalls = {}
local groups = {}

local function newGroup(name, exists, size)
    local group = {
        name = name,
        exists = exists,
        size = size
    }

    function group:isExist()
        return self.exists
    end

    function group:getSize()
        return self.size
    end

    return group
end

groups["A2A-ESR02-F16-Fox2X2"] = newGroup("A2A-ESR02-F16-Fox2X2", false, 0)
groups["A2A-ESR02-F14-GunsX1"] = newGroup("A2A-ESR02-F14-GunsX1", false, 0)

missionCommands = {
    addSubMenu = function(title)
        return title
    end,
    addCommand = function(title, menu, callback)
        commands[title] = callback
    end
}

trigger = {
    action = {
        outText = function(message)
            messages[#messages + 1] = message
        end,
        deactivateGroup = function(group)
            assert(group, "deactivateGroup must never receive nil")
            group.exists = false
            group.size = 0
        end
    }
}

Group = {
    getByName = function(name)
        return groups[name]
    end,
    getName = function(group)
        return group.name
    end
}

coalition = {
    getGroups = function(coalitionId)
        if coalitionId == 1 then
            return {
                groups["A2A-ESR02-F16-Fox2X2"],
                groups["A2A-ESR02-F14-GunsX1"]
            }
        end

        return {}
    end
}

mist = {
    failSpawn = {},
    respawnGroup = function(name)
        spawnCalls[name] = (spawnCalls[name] or 0) + 1

        if mist.failSpawn[name] then
            return nil
        end

        local group = groups[name]
        group.exists = true
        group.size = 2
        return group
    end
}

function buildDatabase()
    for coalitionId = 1, 2 do
        for _, group in ipairs(coalition.getGroups(coalitionId)) do
            _DATABASE.GROUPS[Group.getName(group)] = group
        end
    end
end

dofile("sttr-modules/rangeManagement.lua")

local f16Spawn = commands["Spawn F16 Fox2X2"]
local f14Spawn = commands["Spawn F14 GunsX1"]
local clearRange = commands["Clear all spawns in ESR02"]

assert(f16Spawn, "F16 spawn command was not registered")
assert(f14Spawn, "F14 spawn command was not registered")
assert(clearRange, "Clear-all command was not registered")

-- An active group must not be spawned twice.
f16Spawn()
f16Spawn()
assert(spawnCalls["A2A-ESR02-F16-Fox2X2"] == 1, "active group spawned twice")

-- Simulate complete destruction outside the RangeManager. The next command
-- must detect the stale state and respawn the group.
groups["A2A-ESR02-F16-Fox2X2"].exists = false
groups["A2A-ESR02-F16-Fox2X2"].size = 0
f16Spawn()
assert(spawnCalls["A2A-ESR02-F16-Fox2X2"] == 2, "destroyed group did not respawn")

-- Clear-all must handle both the active F16 group and the never-spawned F14
-- group without indexing nil or passing nil to deactivateGroup.
clearRange()
assert(not groups["A2A-ESR02-F16-Fox2X2"].exists, "clear-all left F16 active")

-- A failed MIST spawn must remain retryable.
mist.failSpawn["A2A-ESR02-F14-GunsX1"] = true
f14Spawn()
f14Spawn()
assert(spawnCalls["A2A-ESR02-F14-GunsX1"] == 2, "failed spawn was incorrectly marked active")

print("range_management_test: OK")
