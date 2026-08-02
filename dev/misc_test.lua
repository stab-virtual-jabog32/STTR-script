local group = { name = "Test Group" }
local unit = { group = group }
local deactivatedGroups = {}
local messages = {}

Group = {
    getByName = function(name)
        if name == group.name then
            return group
        end
    end,
    getName = function(groupObject)
        return groupObject.name
    end
}

Unit = {
    getByName = function(name)
        if name == "Test Unit" then
            return unit
        end
    end,
    getGroup = function(unitObject)
        return unitObject.group
    end
}

trigger = {
    action = {
        deactivateGroup = function(groupObject)
            assert(type(groupObject) == "table", "deactivateGroup expected a group object")
            deactivatedGroups[#deactivatedGroups + 1] = groupObject
        end,
        outText = function(message)
            messages[#messages + 1] = message
        end,
        setUserFlag = function()
        end
    }
}

dofile("sttr-modules/misc.lua")

deactivateGroup("Test Group")
assert(deactivatedGroups[1] == group, "group name was not resolved")

deactivateGroup("Test Unit")
assert(deactivatedGroups[2] == group, "unit name was not resolved to its parent group")

deactivateGroup("Missing Object")
assert(#deactivatedGroups == 2, "missing object was passed to the DCS API")
assert(messages[#messages] == "Missing Object does not exist", "missing object feedback is incorrect")

print("misc_test: OK")
