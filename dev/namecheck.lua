-- Define the table with group names
local ranges = {};
local groupNames = {
    "SWE-ESR01-Artillery Group-2",
    "SWE-ESR01-SA10-1",
    "NOR-R92A-Two F16s-05"
}

-- Iterate over the table using ipairs
for _, groupName in ipairs(groupNames) do
    -- Match the pattern and extract the four parts (Country, Prefix, Middle, Number)
    local country, rangeID, metagroup, number = string.match(groupName, "^(%u%u%u)%-(%w+)%-(.-)%-(%d%d?)$")
    
    if country and rangeID and metagroup and number then
        --print(groupName)
        --print("COUNTRY: " .. country)
        --print("RANGEID: " .. rangeID)
        --print("META GROUP: " .. metagroup)
        --print("NUMBER: " .. number)
        --print("\n")

        -- Ensure that the country exists in the ranges table
        if ranges[country] == nil then
            ranges[country] = {}
        end

        -- Ensure that the rangeID exists under the country
        if ranges[country][rangeID] == nil then
            ranges[country][rangeID] = {}
        end

        -- Ensure that the metagroup exists under the rangeID
        if ranges[country][rangeID][metagroup] == nil then
            ranges[country][rangeID][metagroup] = {}
        end

        -- Store the group under the metagroup
        ranges[country][rangeID][metagroup][groupName] = group
    else
        print("No match found for " .. groupName)
    end
end


-- Iterate through countries
for country, rangesInCountry in pairs(ranges) do
    -- Create a submenu for each country
    print("\n")
    print("Country: " .. country);
    
    -- Iterate through ranges within the country
    for rangeID, metagroupsInRange in pairs(rangesInCountry) do
        print("Range ID: " .. rangeID);
        
        -- Iterate through metagroups within the range
        for metagroup, groups in pairs(metagroupsInRange) do
            print("Metagroup: " .. metagroup)
            print(groups);
        end
    end
end