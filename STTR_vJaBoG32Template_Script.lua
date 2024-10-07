-- ############################################################################
-- ###                         General Initialization                       ###
-- ############################################################################
if type(trigger) == "nil" then
    dofile("dev/dcs_mock.lua")
    basedir = "./"
else
    basedir = "C:/JaBoG32_Skripte/"
end

do
env.info("JaBoG32 STTR Main Script Started")
trigger.action.outText("JaBoG32 STTR Main Script Anfang Line "..string.format(debug.getinfo(1).currentline).." passed", 20)--debugging hilfe

-- ############################################################################
-- ###                         Parameter initialization                     ###
-- ############################################################################
local jabog = jabog or {}
vJaBoG32bombingfeedback = false -- Start Toggle Bombing Range Feedback


-- ############################################################################
-- ###                Module Load and Radio Menu construction               ###
-- ############################################################################

-- 1.) Load Misc. Modul first, as radio entities rely on their function definitions
dofile(basedir .. "sttr-modules/misc.lua")               -- initializes a module that defines misc. functions

-- 2.) Init the basic radio menu tree at root, all other modules will fill up the radio menue on their own
generalOptions = missionCommands.addSubMenu("JaBoG32 General Options");

-- 3.) Load the STTR module (the only module that is specifically related
-- to the .miz template as concrete unit/group names must be defined here)


-- 4.) Load all the modules that contain hooks, consider specifically them when assessing performance
-- Initialize the Training Functions Sub Menu for Hook Modules
trainingFunctions = missionCommands.addSubMenu("Trainingfunctions", generalOptions);
dofile(basedir .. "sttr-modules/bombFeedbackHook.lua")   -- initializes the Bomb Feedback Module (hook)


-- 5.) Load all the remaining modules
dofile(basedir .. "sttr-modules/utils.lua")              -- initializes utility module
dofile(basedir .. "sttr-modules/rangeManagement.lua")    -- initializes Range Management Module


-- ############################################################################
-- ###                       Successful load Message                        ###
-- ############################################################################
env.info("JaBoG32 STTR Main Script Ended")
trigger.action.outText("Main - Line "..string.format(debug.getinfo(1).currentline).." passed", 20)--debugging hilfe
end