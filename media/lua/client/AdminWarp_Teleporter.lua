UserWarp = UserWarp or {}
UserWarp.teleportCountdowns = {}
UserWarp.tickHandlerAdded = false

function UserWarp:sendBeacon(portal)
    if not portal then return end
    local portalData = {
        x = portal.x,
        y = portal.y,
        z = portal.z,
        title = portal.title,
        faction = portal.faction,
        seconds = SandboxVars.AdminWarp.TPdelay or 10
    }
    sendServerCommand("AdminWarp", "Beacon", {portal = portalData})
end

function UserWarp:startTeleportCountdown(player, portalData, seconds, isBeacon)
    if not portalData or not player or not portalData.active then return end

    self.teleportCountdowns[player:getUsername()] = {
        player = player,
        portal = portalData,
        secondsLeft = seconds,
        tickCounter = 0,
        marker = nil,
        isBeacon = isBeacon
    }

    if not self.tickHandlerAdded then
        Events.OnTick.Add(self.teleportTickHandler)
        self.tickHandlerAdded = true
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
    cd.tickCounter = cd.tickCounter + 1

    if cd.tickCounter % 20 == 0 then
        if cd.marker then cd.marker:remove() end
        local r, g, b = 1, 1, 1
        if cd.isBeacon then
            r, g, b = 0.6, 1, 0.2 
        end
        cd.marker = getWorldMarkers():addGridSquareMarker("warp", "warp", pl:getCurrentSquare(), r, g, b, true, ZombRand(1,10)/10)
    end
    if cd.tickCounter % 60 == 0 then
        cd.secondsLeft = cd.secondsLeft - 1
        if cd.secondsLeft > 0 then
            if cd.isBeacon then
                pl:addLineChatElement("Being summoned to " .. cd.portal.title .. " in " .. cd.secondsLeft .. " seconds...")
            else
                pl:addLineChatElement("Teleporting to " .. cd.portal.title .. " in " .. cd.secondsLeft .. " seconds...")
            end
        else
            if cd.marker then cd.marker:remove() end
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
