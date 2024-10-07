--__      __       _           ____             _____   ____    ___  
--\ \    / /      | |         |  _ \           / ____| |___ \  |__ \ 
-- \ \  / /       | |   __ _  | |_) |   ___   | |  __    __) |    ) |
--  \ \/ /    _   | |  / _` | |  _ <   / _ \  | | |_ |  |__ <    / / 
--   \  /    | |__| | | (_| | | |_) | | (_) | | |__| |  ___) |  / /_ 
--    \/      \____/   \__,_| |____/   \___/   \_____| |____/  |____|
--	
-- ================================================
-- ==          VJaBoG32 BOMBING FEEDBACK          ==
-- ================================================
-- ==  Author: JaBoG32 Team                       ==
-- ==  Date: 2024                                 ==
-- ==  Purpose: Provides feedback for bomb        ==
-- ==           impact positions within specific  ==
-- ==           target circles on the range.      ==
-- ================================================
-- ==                 What is this?              ==
-- ================================================
-- This file contains an object-oriented approach 
-- to track and evaluate bomb impacts on predefined 
-- target circles. Each bomb drop is tracked individually 
-- using a `Bomb` class, which calculates the miss distance
-- and provides feedback to players in real-time.
-- Important: This includes a hook, e.g. a callback from
-- DCS Server on every Game Event. Consider Performance
-- Impact
-- 
-- **Key Classes & Functions:**
--  1. **Bomb Class**:
--     - `Bomb:new(ordnance, bombInit, playerGroupID, releaseAlpha, releaseData)`: 
--       Constructor for creating new `Bomb` objects, 
--       storing ordnance, player info, and bomb release data.
--     - `Bomb:startTracking()`: 
--       Tracks the bomb's movement and schedules periodic 
--       checks to update the bomb's position.
--     - `Bomb:evaluateBomb(bombPos)`: 
--       Calculates the offset of the bomb from the nearest 
--       target circle and provides feedback to the player 
--       upon bomb landing or destruction.
--  
--  2. **togglevJaBoG32bombingfeedback()**: 
--     Toggles the bombing feedback on or off. It adds or removes 
--     the event handler responsible for tracking bomb drops.
-- 
--  3. **BombEventHandler:onEvent(event)**: 
--     Listens for bomb shot events (`S_EVENT_SHOT`) and initializes 
--     a `Bomb` object for tracking and evaluation.
-- ================================================
-- ==          How to use these functions:       ==
-- ================================================
-- To enable or disable bombing feedback during 
-- a mission, use the `togglevJaBoG32bombingfeedback()`
-- function. Bomb feedback is automatically tracked 
-- and evaluated for each bomb individually.
--
-- Example:
--   togglevJaBoG32bombingfeedback() -- Toggles feedback
--
-- The bombing feedback will calculate and display
-- the miss distance and whether the bomb was too short, 
-- too long, or off to the sides. Feedback is provided 
-- via the radio menu system.
--
-- **Performance Consideration:**
-- As this feature relies on hooks for game events and 
-- continuous tracking of bombs, it is important to monitor 
-- performance, especially when multiple players are 
-- dropping bombs simultaneously.
-- 
-- Happy bombing! :)
-- ================================================

-- ############################################################################
-- ###                          Parameter settings                          ###
-- ############################################################################
trainingmode = true
bombcircles = {'bombcircler63w', 'bombcircler63e', 'bombcircler64w', 'bombcircler64e'}
Rangetable = {}
for i, zone in ipairs(bombcircles) do
	aimpoint = trigger.misc.getZone(zone)
	if aimpoint ~= nil then
		y = land.getHeight({ x = aimpoint.point.x, y = aimpoint.point.z})
		Rangetable[#Rangetable + 1] = {
			px = aimpoint.point.x,
			pz = aimpoint.point.z,
			py = y
		}
	end
end

-- ############################################################################
-- ###          Function that registers the event listener (hook)           ###
-- ############################################################################
--Funktion zum An/Abschalten der Auswertefunktion bei den Zielkreisen
function togglevJaBoG32bombingfeedback()

	if vJaBoG32bombingfeedback == false
	then
		world.addEventHandler(BombEventHandler)
		vJaBoG32bombingfeedback = true
		trigger.action.outText("Bombing feedback for Range Circles activated!", 30)
	return
	elseif vJaBoG32bombingfeedback == true
	then
		world.removeEventHandler(BombEventHandler)
		vJaBoG32bombingfeedback = false
		trigger.action.outText("Bombing feedback for Range Circles deactivated!", 30)
	return
	end
return vJaBoG32bombingfeedback
end	

-- ############################################################################
-- ###                        Bomb class Definition                         ###
-- ############################################################################

Bomb = {}
Bomb.__index = Bomb

-- Bomb Constructor
function Bomb:new(ordnance, bombInit, playerGroupID, releaseAlpha, releaseData)
    local self = setmetatable({}, Bomb)
    self.ordnance = ordnance
    self.bombInit = bombInit
    self.playerGroupID = playerGroupID
    self.releaseAlpha = releaseAlpha
    self.releaseData = releaseData
    self.bombPos = nil  -- This will hold the bomb's last known position
    return self
end

-- Function to start tracking the bomb
function Bomb:startTracking()
    function trackBomb(self)
        -- Check if the ordnance still exists
        if not self.ordnance:isExist() then
            self:evaluateBomb(self.bombPos)  -- Use the last known position for evaluation
            return nil  -- End the scheduler
        end

        -- Update the bomb's last known position
        self.bombPos = self.ordnance:getPoint()

        -- Continue tracking every 0.005 seconds
        return timer.getTime() + 0.005
    end

    -- Schedule the bomb tracking to run every 0.1 seconds
    timer.scheduleFunction(trackBomb, self, timer.getTime() + 0.1)
end

-- Function to evaluate bomb performance after landing or destruction
function Bomb:evaluateBomb(bombPos)
    -- Find the nearest bomb circle to the last known position of the bomb
    local bombCirclePosition = getPositionOfNearestBombCircle(bombPos)
    local bombOffset = mist.utils.get2DDist(bombCirclePosition, bombPos)

    -- Calculate offsets and provide feedback if within 300m of the circle
    if bombOffset <= 300 then
        local xBombOffset = bombPos.x - bombCirclePosition.x
        local zBombOffset = bombPos.z - bombCirclePosition.z

        local bombOffsetInt = math.floor(bombOffset)
        local beta = math.atan2(zBombOffset, xBombOffset)
        local gamma = self.releaseAlpha - beta
        local xOffsetRel = bombOffset * math.sin(gamma * (-1))
        local zOffsetRel = bombOffset * math.cos(gamma)
        local xOffsetRelAbs = math.floor(math.abs(xOffsetRel))
        local zOffsetRelAbs = math.floor(math.abs(zOffsetRel))

        -- Provide feedback based on offsets
        if (xOffsetRel > 0 and zOffsetRel > 0) then
            trigger.action.outTextForGroup(self.playerGroupID, self.bombInit:getName().." missed by "..string.format(bombOffsetInt).."m / Off right "..string.format(xOffsetRelAbs).."m / Too long by "..string.format(zOffsetRelAbs).."m\n\n"..self.releaseData, 30)
        elseif (xOffsetRel > 0 and zOffsetRel < 0) then
            trigger.action.outTextForGroup(self.playerGroupID, self.bombInit:getName().." missed by "..string.format(bombOffsetInt).."m / Off right "..string.format(xOffsetRelAbs).."m / Too short by "..string.format(zOffsetRelAbs).."m\n\n"..self.releaseData, 30)
        elseif (xOffsetRel < 0 and zOffsetRel > 0) then
            trigger.action.outTextForGroup(self.playerGroupID, self.bombInit:getName().." missed by "..string.format(bombOffsetInt).."m / Off left "..string.format(xOffsetRelAbs).."m / Too long by "..string.format(zOffsetRelAbs).."m\n\n"..self.releaseData, 30)
        elseif (xOffsetRel < 0 and zOffsetRel < 0) then
            trigger.action.outTextForGroup(self.playerGroupID, self.bombInit:getName().." missed by "..string.format(bombOffsetInt).."m / Off left "..string.format(xOffsetRelAbs).."m / Too short by "..string.format(zOffsetRelAbs).."m\n\n"..self.releaseData, 30)
        end
    else
        trigger.action.outTextForGroup(self.playerGroupID, "Bomb missed target area.", 30)
    end
end


-- ############################################################################
-- ###                          onEvent listener                            ###
-- ############################################################################
--Funktion welche onEvent S_EVENT_SHOT prüft ob ein Spieler in der Vicinity eines Range Circles ist und dann die Bomben trackt und in der Naehe zu den Zielkreisen auswertet
BombEventHandler = {}												
function BombEventHandler:onEvent(event)
    if event.id == world.event.S_EVENT_SHOT and event.weapon then
        -- Bomb details
        local bombInit = event.initiator
        local ordnance = event.weapon

        -- Ensure it's a valid player
        if Unit.getPlayerName(bombInit) == nil then
            return  -- Not a player-controlled unit, exit
        end

        local position = event.initiator:getPoint()
        local playerGroupID = funcgetGroupID(bombInit)
        local releaseAlpha = mist.getHeading(bombInit)
        local releaseData = "Release altitude (AGL): " .. string.format(math.floor((position.y - land.getHeight({x = position.x, y = position.z})) / 0.3048)) .. "ft\n"

        -- Only track bombs near target circles
        if isNearBombCircles(position) then
            local bomb = Bomb:new(ordnance, bombInit, playerGroupID, releaseAlpha, releaseData)
            bomb:startTracking()
        else
            trigger.action.outText("Bomb is NOT near bomb circle", 5)
        end
    end
end


-- ############################################################################
-- ###                         Radio Menu Appender                          ###
-- ############################################################################
-- Add bombing feedback hook to radio sub menu "trainingFunctions" and confirm module load
missionCommands.addCommand("Toggle Bombing Feedback", trainingFunctions,togglevJaBoG32bombingfeedback, nil)
trigger.action.outText("Bomb Feedback Module initialized (hook toggled through F10)", 20)
