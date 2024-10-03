--__      __       _           ____             _____   ____    ___  
--\ \    / /      | |         |  _ \           / ____| |___ \  |__ \ 
-- \ \  / /       | |   __ _  | |_) |   ___   | |  __    __) |    ) |
--  \ \/ /    _   | |  / _` | |  _ <   / _ \  | | |_ |  |__ <    / / 
--   \  /    | |__| | | (_| | | |_) | | (_) | | |__| |  ___) |  / /_ 
--    \/      \____/   \__,_| |____/   \___/   \_____| |____/  |____|
--                
-- ================================================
-- ==                VJaBoG32 UTILS              ==
-- ================================================
-- ==  Author: JaBoG32 Team (Gerrit Addiks)      ==
-- ==  Date: 2024                                ==
-- ==  Purpose: General utility functions        ==
-- ================================================
-- ==                 What is this?              ==
-- ================================================
--
-- This file provides a DCS-compatible API that can be used
-- to execute DCS-specific lua files in a non-DCS environment.
-- 
-- This file can also be used to get a quick overview of the part
-- of the DCS-API that is used by this script.

if type(missionCommands) == "nil" then
    missionCommands = {
        ["addSubMenu"] = function (title)
            print("Sub Menu " .. title .. " added");
        end,
        ["addCommand"] = function (title)
            print("Radio Command " .. title .. " added");
        end
    }
end

if type(env) == "nil" then
    env = {
        ["info"] = print
    }
end

if type(Group) == "nil" then
    Group = {
        ["getByName"] = function (groupName)
            return {}
        end
    }
end

if type(mist) == "nil" then
    mist = {
        ["getGroupData"] = function (groupName)
            return {
                ["units"] = {
                    [1] = {
                        ["type"] = "foo",
                        ["livery_id"] = "foo",
                        ["skill"] = "foo"
                    }
                }
            }
        end,
        ["getPayload"] = function (groupName)
        end
    }
end

if type(coalition) == "nil" then
    coalition = {
        ["getGroups"] = function (coalitionId)
            return {}
        end
    }
end

if type(trigger) == "nil" then
    trigger = {
        ["action"] = {
            ["outText"] = print,
            ["activateGroup"] = function (group)
                -- TODO
            end,
            ["setUserFlag"] = function (group)
                -- TODO
            end
        },
        ["misc"] = {
            ["getZone"] = function (zoneName)
                -- TODO: zone.point
            end
        }
    }
end

