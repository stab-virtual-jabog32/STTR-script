--__      __       _           ____             _____   ____    ___  
--\ \    / /      | |         |  _ \           / ____| |___ \  |__ \ 
-- \ \  / /       | |   __ _  | |_) |   ___   | |  __    __) |    ) |
--  \ \/ /    _   | |  / _` | |  _ <   / _ \  | | |_ |  |__ <    / / 
--   \  /    | |__| | | (_| | | |_) | | (_) | | |__| |  ___) |  / /_ 
--    \/      \____/   \__,_| |____/   \___/   \_____| |____/  |____|
--																
-- ================================================
-- ==                VJaBoG32 UTILS               ==
-- ================================================
-- ==  Author: JaBoG32 Team                       ==
-- ==  Date: 2024                                 ==
-- ==  Purpose: General utility functions         ==
-- ================================================
-- ==                 What is this?              ==
-- ================================================
-- This file contains general-purpose utility 
-- functions that can be reused throughout your 
-- Lua scripts to make your life easier!
-- 
-- Functions in this file include:
--  1. **pairsByKeys(t, f)**: Sorts a table by its keys.
--  2. **getallplayers()**: Returns a list of all active players.
--  3. **funcgetGroupID(_unit)**: Workaroundfunction to get access to "group" of clients in MP
--  4. **isInRange(pos1, pos2, range)**: Checks if two points are within a certain range.
--  5. **isInNondeadlyZone(point)**: Determines if a point is in a non-deadly zone.
--  6. **getPositionOfNearestBombCircle(point)**: Finds the nearest bomb circle to a point.
--  7. **getNearestDistanceToBombCircles(point)**: Finds the nearest distance to bomb circles.
--  8. **isNearBombCircles(point)**: Checks if a point is near bomb circles.
--  9. **bearingToClockPosition(bearing)**: Converts a bearing into a clock position.
-- 
-- ================================================
-- ==          How to use these functions:       ==
-- ================================================
-- To use these utility functions in your main script, 
-- simply load this file using the `dofile()` function:
--
--   dofile("C:/path/to/modules/utils.lua")
--
-- After loading, you'll be able to call these functions 
-- directly, like so:
--
--   local sortedTable = pairsByKeys(someTable)
-- 
-- Happy scripting and fly safe! :)
-- ================================================


local utils = {}

-- pairsByKeys(t, f)**: Sorts a table by its keys.
function pairsByKeys (t, f)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
	table.sort(a, f)
	local i = 0      -- iterator variable
	local iter = function ()   -- iterator function
		i = i + 1
		if a[i] == nil then return nil
		else return a[i], t[a[i]]
		end
	end
	return iter
end


-- Workaroundfunction to get access to "group" of clients in MP
function funcgetGroupID(_unit)
    local _unitDB =  mist.DBs.unitsById[tonumber(_unit:getID())]
    if _unitDB ~= nil and _unitDB.groupId 
	then
        return _unitDB.groupId
    end
    return nil
end


-- Finds the nearest bomb circle to a point.
function getPositionOfNearestBombCircle(point)
	local nearestDistance = -1
	local position = {}
	for i, zoneName in ipairs(bombcircles) do
		local zone = trigger.misc.getZone(zoneName)
		local distance = mist.utils.get2DDist(point, zone.point)
		if nearestDistance < 0 or nearestDistance > distance then
			nearestDistance = distance
			position = zone.point
		end
	end
	return position
end


-- Finds the nearest distance to bomb circles.
function getNearestDistanceToBombCircles(point)
	local nearestPosition = getPositionOfNearestBombCircle(point)
	return mist.utils.get2DDist(point, nearestPosition)
end


-- Checks if a point is near bomb circles.
function isNearBombCircles(point)
	local distance = getNearestDistanceToBombCircles(point)
	return mist.utils.metersToNM(distance) < 10
end


-- Returns a list of all active players.
function getallplayers()
	local players = {}

	for name, unitInfo in pairs(mist.DBs.humansByName) do
		local unit = Unit.getByName(name)
		if unit ~= nil then
			players[#players + 1] = {
				playername = unit:getPlayerName(),
				unitname = name,
				unit = unit
			}
		end
	end
	return players
end


-- Checks if two points are within a certain range.
function isInRange(pos1, pos2, range)
	local distance = mist.utils.get2DDist(pos1, pos2)
	return mist.utils.metersToNM(distance) <= range
end


-- Determines if a point is in a non-deadly zone.
function isInNondeadlyZone(point)
	for i, zoneName in ipairs(nondeadlyZones) do
		local zone = trigger.misc.getZone(zoneName)
		local distance = mist.utils.get2DDist(point, zone.point)
		local altitude = point.y - land.getHeight(point)
		if distance <= zone.radius and altitude < 50 then return true end
	end
	return false
end


-- Converts a bearing into a clock position.
function bearingToClockPosition(bearing)
	local hour = mist.utils.round(bearing * 12 / 360)
	if hour == 0 then hour = 12 end
	return hour
end


-- Function to populate the _DATABASE with all groups from both coalitions (Red and Blue) (MOOSE Substitute)
function buildDatabase()
    -- Loop through coalitions (1 = Red, 2 = Blue)
    for coalitionId = 1, 2 do
        local groups = coalition.getGroups(coalitionId)

        -- Iterate through all groups in the coalition
        for _, group in ipairs(groups) do
            local groupName = Group.getName(group)
            if groupName then
                _DATABASE.GROUPS[groupName] = group
            end
        end
    end
end

trigger.action.outText("Utility Module initialized", 20)
