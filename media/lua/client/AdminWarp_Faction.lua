
--client/AdminWarp_Faction.lua
AdminWarp = AdminWarp or {}

function AdminWarp.isPlayerInFaction(user, name)
    local fact = AdminWarp.getFactionFromName(name)
    if not fact then return false end
    return fact:isMember(user) 
end



function AdminWarp.getPlayerFaction(targ)
    targ = targ or getPlayer() 
    local fact = Faction.getPlayerFaction(targ) 
    return fact or nil
end

function AdminWarp.isMember(targ, name)
    targ = targ or getPlayer() 

    local fact =  AdminWarp.getPlayerFaction(targ)
    local factName
    if fact then
        factName = fact:getName()
    end
    if factName then
        return factName == name
    end
    return false
end


function AdminWarp.getFactionFromTag(tag)
    if not tag then return nil end
    local factions = Faction.getFactions()
    for i = 0, factions:size() - 1 do
        local fact = factions:get(i)
        if fact and fact:getTag() == tag then
            return fact
        end
    end
    return nil
end

function AdminWarp.getFactionFromName(name)
    if not name then return nil end
    local factions = Faction.getFactions()
    for i = 0, factions:size() - 1 do
        local fact = factions:get(i)
        if fact and fact:getName() == name then
            return fact
        end
    end
    return nil
end

-----------------------            ---------------------------

function AdminWarp.getAllFactionNames()
    local names = {}
    local factions = Faction.getFactions()
    if not factions then return names end

    for i = 0, factions:size() - 1 do
        local f = factions:get(i)
        if f then
            local name = f:getName()
            if name and name ~= "" then
                table.insert(names, name)
            end
        end
    end

    return names
end

function AdminWarp.getAllFactionTags()
    local tags = {}
    
    local factions = Faction.getFactions()
    if not factions then return tags end
    
    for i = 0, factions:size() - 1 do
        local f = factions:get(i)
        if f then
            local tag = f:getTag()
            if tag and tag ~= "" then
                table.insert(tags, tag)
            end
        end
    end
    return tags
end

function AdminWarp.getPortal(title)
    if not AdminWarpData or not AdminWarpData.portals then return nil end
    for i, portal in ipairs(AdminWarpData.portals) do
        if portal.title == title then
            return portal
        end
    end
    return nil
end