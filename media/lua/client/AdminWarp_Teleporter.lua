----------------------------------------------------------------
-----  ▄▄▄   ▄    ▄   ▄  ▄▄▄▄▄   ▄▄▄   ▄   ▄   ▄▄▄    ▄▄▄  -----
----- █   ▀  █    █▄▄▄█    █    █   ▀  █▄▄▄█  ▀  ▄█  █ ▄▄▀ -----
----- █  ▀█  █      █      █    █   ▄  █   █  ▄   █  █   █ -----
-----  ▀▀▀▀  ▀▀▀▀   ▀      ▀     ▀▀▀   ▀   ▀   ▀▀▀   ▀   ▀ -----
----------------------------------------------------------------
--                                                            --
--   Project Zomboid Modding Commissions                      --
--   https://steamcommunity.com/id/glytch3r/myworkshopfiles   --
--                                                            --
--   ▫ Discord  ꞉   glytch3r                                  --
--   ▫ Support  ꞉   https://ko-fi.com/glytch3r                --
--   ▫ Youtube  ꞉   https://www.youtube.com/@glytch3r         --
--   ▫ Github   ꞉   https://github.com/Glytch3r               --
--                                                            --
----------------------------------------------------------------
----- ▄   ▄   ▄▄▄   ▄   ▄   ▄▄▄     ▄      ▄   ▄▄▄▄  ▄▄▄▄  -----
----- █   █  █   ▀  █   █  ▀   █    █      █      █  █▄  █ -----
----- ▄▀▀ █  █▀  ▄  █▀▀▀█  ▄   █    █    █▀▀▀█    █  ▄   █ -----
-----  ▀▀▀    ▀▀▀   ▀   ▀   ▀▀▀   ▀▀▀▀▀  ▀   ▀    ▀   ▀▀▀  -----
----------------------------------------------------------------
UserWarp = UserWarp or {}
AdminWarp = AdminWarp or {}
UserWarp.teleportCountdowns = {}
UserWarp.tickHandlerAdded = false

function AdminWarp.getPortalCoordsFromName(name)
    if not name or not AdminWarpData then return nil end
    for i = 1, #AdminWarpData do
        local portal = AdminWarpData[i]
        if portal and portal.title == name then
            return portal
        end
    end
    return nil
end


function AdminWarp.getPortalFromName(name)
    if not name or not AdminWarpData then return nil end
    for i = 1, #AdminWarpData do
        local portal = AdminWarpData[i]
        if portal and portal.faction == name then
            return AdminWarpData[i]
        end
    end
    return nil
end


function UserWarp.startTeleportCountdown(pl, portalData, seconds, isBeacon)
    pl = pl or getPlayer() 
    if not portalData or not pl then return end
    if not isBeacon and not portalData.active then return end
    local  isForAll = false
     if portalData.faction == nil then isForAll = true end
    UserWarp.teleportCountdowns[pl:getUsername()] = {
        player = pl,
        portal = portalData,
        secondsLeft = seconds,
        tickCounter = 0,
        marker = nil,
        isBeacon = isBeacon,
        isForAll = isForAll
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
    cd.tickCounter = cd.tickCounter + 1

    if cd.tickCounter % 20 == 0 then

        if cd.marker then cd.marker:remove() end
        local r, g, b = 1, 1, 1

        if cd.isForAll then
            r, g, b = 1, 0, 0

        elseif cd.isBeacon then
            r, g, b = 0.6, 1, 0.2 
        end
        local csq = pl:getCurrentSquare()
        if csq then
            cd.marker = getWorldMarkers():addGridSquareMarker("warp", "warp", csq, r, g, b, true, ZombRand(1,10)/10)
        end
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
            pl:playSoundLocal("AdminWarp")

            pl:setX(portal.x)
            pl:setLx(portal.x)
            pl:setY(portal.y)
            pl:setLy(portal.y)
            pl:setZ(portal.z)
            UserWarp.teleportCountdowns[pl:getUsername()] = nil
        end
    end
end