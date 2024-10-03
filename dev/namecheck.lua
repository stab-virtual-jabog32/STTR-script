-- Define the table with group names
local groupNames = {
    "SWE-ESR01-Artillery Group-01",
    "SWE-ESR01-SA10-07",
    "NOR-R92A-Two F16s-05"
}

-- Iterate over the table using ipairs
for _, groupName in ipairs(groupNames) do
    -- Match the pattern and extract the four parts (Country, Prefix, Middle, Number)
    local country, prefix, middle, number = string.match(groupName, "^(%u%u%u)%-(%w+)%-(.-)%-(%d%d?)$")
    
    if country and prefix and middle and number then
        print(groupName)
        print("COUNTRY: " .. country)
        print("RANGEID: " .. prefix)
        print("SPAWN GROUP: " .. middle)
        print("NUMBER: " .. number)
        print("\n")
    else
        print("No match found for " .. groupName)
    end
end
