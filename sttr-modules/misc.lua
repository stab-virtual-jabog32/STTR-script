--__      __       _           ____             _____   ____    ___  
--\ \    / /      | |         |  _ \           / ____| |___ \  |__ \ 
-- \ \  / /       | |   __ _  | |_) |   ___   | |  __    __) |    ) |
--  \ \/ /    _   | |  / _` | |  _ <   / _ \  | | |_ |  |__ <    / / 
--   \  /    | |__| | | (_| | | |_) | | (_) | | |__| |  ___) |  / /_ 
--    \/      \____/   \__,_| |____/   \___/   \_____| |____/  |____|
--	
-- ================================================
-- ==        VJaBoG32 MISCELLANEOUS FUNCTIONS     ==
-- ================================================
-- ==  Author: JaBoG32 Team                       ==
-- ==  Date: 2024                                 ==
-- ==  Purpose: Various utility and management    ==
-- ==           functions for mission scripting   ==
-- ================================================
-- ==                 What is this?              ==
-- ================================================
-- This file contains utility and management functions
-- related to radio options, group management, ROZ 
-- monitoring, and flight management. These functions 
-- are designed for use in DCS Lua scripts to manage 
-- player interactions, mission groups, restricted 
-- operating zones (ROZ), and spawning or clearing flights.
-- 
-- Functions in this file include:
-- 
--
--  **Group Activation:**
--  1. **activateGroup(actualunitname)**: Activates a specific group by name.
--  2. **deactivateGroup(actualunitname)**: Deactivates a specific group by name.
--  3. **respawntanker(actualunitname)**: Respawns a tanker group.
--  4. **activatesmartSAMs()**: activates the smart SAM Flag
--
--  **ROZ Monitoring:**
--  4. **ROZ_CONTAINERclearance(unitname)**: Grants clearance for a unit to enter the ROZ.
--  5. **checkROZ()**: Monitors whether units are violating ROZ restrictions.
--
--  **Flight Management:**
--  6. **spawnFlight(flight)**: Spawns a specific flight.
--  7. **spawnRandomFlight(flights)**: Spawns a random flight from a given list.
--  8. **clearFlights(flights)**: Clears flights by destroying them.
-- 
-- ================================================
-- ==          How to use these functions:       ==
-- ================================================
-- To use these functions in your mission script, 
-- simply load this file using the `dofile()` function:
--
--   dofile("C:/path/to/modules/miscFunctions.lua")
--
-- After loading, you'll be able to call these functions 
-- directly, like so:
--
--   activateGroup("SomeGroupName")
--   spawnFlight("FlightName")
--   clearFlights(flightList)
--
-- Happy scripting and fly safe! :)
-- ================================================

function spawnFlight(flight)
	mist.respawnGroup(flight, true)	
	trigger.action.outText("Flight " .. flight .. " spawned", 10)
end


function spawnRandomFlight(flights)
	rnd = math.random(1, #flights)
	mist.respawnGroup(flights[rnd], true)	
	trigger.action.outText("Flight " .. flights[rnd] .. " spawned", 10)
end


function activateGroup(actualunitname)
	if Unit.getByName(actualunitname) == nil
	then
		if Group.getByName(actualunitname) ~= nil
		then
			trigger.action.activateGroup(Group.getByName(actualunitname))
			trigger.action.outText(actualunitname.. " activated",10)
		else
			trigger.action.outText(actualunitname.. " does not exist",10)
			return
		end
	else
		local actualunittoactivate = Unit.getByName(actualunitname)
		local grouptoactivate = Unit.getGroup(actualunittoactivate)
		local groupnametoactivate = Group.getName(grouptoactivate)
		trigger.action.outText(groupnametoactivate.. " activated",10)
		trigger.action.activateGroup(grouptoactivate)
		return
	end
end


function deactivateGroup(actualunitname)
	if Unit.getByName(actualunitname) == nil
	then
		if Group.getByName(Group.getByName(actualunitname)) ~= nil
		then
			trigger.action.deactivateGroup(actualunitname)
			trigger.action.outText(actualunitname.. " deactivated",10)
		else
			trigger.action.outText(actualunitname.. " does not exist",10)
			return
		end
	else
		local actualunittoactivate = Unit.getByName(actualunitname)
		local grouptoactivate = Unit.getGroup(actualunittoactivate)
		local groupnametoactivate = Group.getName(grouptoactivate)
		trigger.action.outText(groupnametoactivate.. " deactivated",10)
		trigger.action.deactivateGroup(grouptoactivate)
	end
end


function respawntanker(actualunitname)
	if Unit.getByName(actualunitname) == nil
	then
		mist.respawnGroup(actualunitname, true)
		if Group.getByName(actualunitname) ~= nil
		then
			mist.respawnGroup(actualunitname, true)
			trigger.action.outText(actualunitname.. " respawned",10)
		else
			trigger.action.outText(actualunitname.. " does not exist",10)
		end
	else
		local actualunittoactivate = Unit.getByName(actualunitname)
		local grouptoactivate = Unit.getGroup(actualunittoactivate)
		local groupnametoactivate = Group.getName(grouptoactivate)
		trigger.action.outText(groupnametoactivate.. " respawned",10)
		mist.respawnGroup(groupnametoactivate, true)
	end
end

function clearFlights(flights)
	
	for a = 1, #flights do		
		local grp = Group.getByName( flights[a] )

		if grp and grp:isExist() then		
			Group.destroy(grp)
			--trigger.action.outText("Flight despawned: " .. flights[a], 10)
		else 
			--trigger.action.outText('Not Found: ' .. flights[a], 10)
		end
	end		
	
	trigger.action.outText("Flight despawned", 10)
end

function activatesmartSAMs()
	trigger.action.setUserFlag("155", true)
end

trigger.action.outText("Misc. Module initialized", 20)