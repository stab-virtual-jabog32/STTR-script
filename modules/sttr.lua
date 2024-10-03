--__      __       _           ____             _____   ____    ___  
--\ \    / /      | |         |  _ \           / ____| |___ \  |__ \ 
-- \ \  / /       | |   __ _  | |_) |   ___   | |  __    __) |    ) |
--  \ \/ /    _   | |  / _` | |  _ <   / _ \  | | |_ |  |__ <    / / 
--   \  /    | |__| | | (_| | | |_) | | (_) | | |__| |  ___) |  / /_ 
--    \/      \____/   \__,_| |____/   \___/   \_____| |____/  |____|
--	
-- ================================================
-- ==          VJaBoG32 NTTR TEMPLATE MODULE      ==
-- ================================================
-- ==  Author: JaBoG32 Team                       ==
-- ==  Date: 2024                                 ==
-- ==  Purpose: Template-specific unit names      ==
-- ==           and radio commands for NTTR       ==
-- ================================================
-- ==                 What is this?              ==
-- ================================================
-- This file contains template-specific data and functions 
-- for handling unit names, radio commands, and other settings 
-- required for the NTTR mission template in DCS.

-- Functions and variables in this module include:
--  1. **Unit names for SAMs and Support**: A list of unit names specific 
--     to the NTTR template that are activated via F-10 radio options.
--  2. **A2A Ranges Setup**: Various A2A ranges (X, Y, Z) along with 
--     aircraft spawns and random flight generation.
--  3. **Radio Menu Setup**: Functions for creating the radio menu structure 
--     in the DCS mission, allowing the player to request support units, 
--     activate SAMs, and spawn air targets.

-- ================================================
-- ==          How to use these functions:       ==
-- ================================================
-- To use this module, simply load it in your main mission 
-- script using the `dofile()` function:
--
--   dofile("C:/path/to/modules/nttrTemplateModule.lua")
--
-- After loading, you'll be able to call the predefined functions 
-- and interact with the unit names and radio options specific to 
-- the NTTR mission template.
--
-- Happy scripting and fly safe! :)
-- ================================================

-- Helper Function to merge groups for Clear All function
function mergeTable(table1, table2)
	for _, value in ipairs(table2) do
		table1[#table1+1] = value
	end
	return table1
end


-- Add direct spawn unit names here (e.g. support?)
-- Unitnames of groups in template to activated via F-10 Options
local groomSa10Group = "TrainingSAM GROOM SA10"


 -- SAM Training Pages
 -- create sub menus and append unit to spawn here
local samTrainingPage1 = missionCommands.addSubMenu("SAM Training Page 1", generalOptions);
missionCommands.addCommand("SA-10 Grumble ON", samTrainingPage1, activateGroup, groomSa10Group)


trigger.action.outText("NTTR Module loaded", 20)