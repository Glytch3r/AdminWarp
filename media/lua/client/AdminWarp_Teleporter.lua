UserWarp = UserWarp or {}
UserWarp.teleportCountdowns = {}

function UserWarp:startTeleportCountdown(player, portal, seconds)
    if not portal or not portal.active then return end
    if not player then return end

    UserWarp.teleportCountdowns[player:getUsername()] = {
        portal = portal,
        player = player,
        secondsLeft = seconds,
        secondCounter = 0,
        markerCounter = 0,
        marker = nil
    }

    if not UserWarp.tickHandlerAdded then
        Events.OnTick.Add(UserWarp.teleportTickHandler)
        UserWarp.tickHandlerAdded = true
    end
end

function UserWarp.teleportTickHandler()
    for _, cd in pairs(UserWarp.teleportCountdowns) do
        if cd and cd.player then
            UserWarp.teleportTick(cd)
        end
    end
end

function UserWarp.teleportTick(cd)
    local pl = cd.player

    cd.secondCounter = cd.secondCounter + 1
    cd.markerCounter = cd.markerCounter + 1

    if cd.markerCounter >= 20 then
        cd.markerCounter = 0
        if cd.marker then cd.marker:remove(); cd.marker = nil end
        cd.marker = getWorldMarkers():addGridSquareMarker("warp", "warp", pl:getCurrentSquare(), 1, 1, 1, true, ZombRand(1,10)/10)
    end

    if cd.secondCounter >= 60 then
        cd.secondCounter = 0
        cd.secondsLeft = cd.secondsLeft - 1
        if cd.secondsLeft > 0 then
            pl:addLineChatElement("Teleporting to " .. cd.portal.title .. " in " .. cd.secondsLeft .. " seconds...")
        else
            if cd.marker then cd.marker:remove(); cd.marker = nil end
            local portal = cd.portal
            pl:setX(portal.x)
            pl:setLx(portal.x)
            pl:setY(portal.y)
            pl:setLy(portal.y)
            pl:setZ(portal.z)
            UserWarp.teleportCountdowns[pl:getUsername()] = nil
        end
    end
end
