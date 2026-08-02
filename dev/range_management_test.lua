local commands = {}
local messages = {}
local spawnCalls = {}
local activationCalls = {}
local groups = {}

local function newGroup(name, exists, size, initialSize)
    local group = {
        name = name,
        exists = exists,
        size = size,
        initialSize = initialSize or size
    }

    function group:isExist()
        return self.exists
    end

    function group:getSize()
        return self.size
    end

    return group
end

groups["A2A-ESR02-F16-Fox2X2"] = newGroup("A2A-ESR02-F16-Fox2X2", false, 0, 2)
groups["A2A-ESR02-F14-GunsX1"] = newGroup("A2A-ESR02-F14-GunsX1", false, 0, 1)
groups["SWE-ESR01-SA10-01"] = newGroup("SWE-ESR01-SA10-01", true, 1, 1)
groups["SWE-ESR01-SA10-02"] = newGroup("SWE-ESR01-SA10-02", true, 1, 1)

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
        activateGroup = function(group)
            activationCalls[group.name] = (activationCalls[group.name] or 0) + 1
            group.exists = true
            group.size = group.initialSize
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
                groups["A2A-ESR02-F14-GunsX1"],
                groups["SWE-ESR01-SA10-01"],
                groups["SWE-ESR01-SA10-02"]
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
        group.size = group.initialSize
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
local sa10Spawn = commands["Spawn SA10"]
local sa10Despawn = commands["Despawn SA10"]

assert(f16Spawn, "F16 spawn command was not registered")
assert(f14Spawn, "F14 spawn command was not registered")
assert(clearRange, "Clear-all command was not registered")
assert(sa10Spawn, "SA10 spawn command was not registered")
assert(sa10Despawn, "SA10 despawn command was not registered")

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

-- A regular metagroup initially activates all of its late-activation groups.
sa10Spawn()
assert(activationCalls["SWE-ESR01-SA10-01"] == 1, "first SA10 group was not activated")
assert(activationCalls["SWE-ESR01-SA10-02"] == 1, "second SA10 group was not activated")

-- If one constituent group is completely destroyed, spawning the metagroup
-- again must restore only that group and preserve the surviving group.
groups["SWE-ESR01-SA10-01"].exists = false
groups["SWE-ESR01-SA10-01"].size = 0
sa10Spawn()
assert(spawnCalls["SWE-ESR01-SA10-01"] == 1, "destroyed SA10 group did not respawn")
assert(activationCalls["SWE-ESR01-SA10-02"] == 1, "surviving SA10 group was reset")

-- Despawn after combat must clear stale state for destroyed groups so the
-- complete metagroup can be spawned again later.
groups["SWE-ESR01-SA10-01"].exists = false
groups["SWE-ESR01-SA10-01"].size = 0
sa10Despawn()
sa10Spawn()
assert(spawnCalls["SWE-ESR01-SA10-01"] == 2, "destroyed SA10 group stayed blocked after despawn")
assert(spawnCalls["SWE-ESR01-SA10-02"] == 1, "despawned SA10 group did not respawn")

print("range_management_test: OK")
