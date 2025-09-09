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
if not isClient() then return end
AdminWarp = AdminWarp or {}
UserWarp = UserWarp or {}

local Commands = {};
Commands.AdminWarp = {};

Commands.AdminWarp.Msg = function(args)
    if args.msg then
        print(tostring(args.msg))
    end
end

Commands.AdminWarp.Update = function(args)
    if args.data then
        local oldCount = AdminWarpData and #AdminWarpData or 0
        AdminWarpData = args.data
        if AdminWarpPanel and AdminWarpPanel.instance and AdminWarpPanel.instance:isVisible() then
            local currentCount = #AdminWarpPanel.instance.portals
            if currentCount ~= #AdminWarpData then
                AdminWarpPanel.instance:loadPortals()
                AdminWarpPanel.instance:refreshListDisplay()
            end
        end
        if UserWarpPanel and UserWarpPanel.instance and UserWarpPanel.instance:isVisible() then
            UserWarpPanel.instance:loadPortals()
            UserWarpPanel.instance:refreshList()
        end
    end
end

--[[ 
Commands.AdminWarp.Beacon = function(args)
    local targ = getPlayer() 
    local player = getPlayerByOnlineID(args.id)
    if targ ~= player then

        if args.data then
            local Beacon = args.data
            if AdminWarp.isMember(targ, args.title) then
                
            end
        end
    end
end
 ]]

Commands.AdminWarp.Check = function(args)
    if args.data then
        AdminWarpData = args.data
    end
end

function AdminWarp.initClient()
    AdminWarpData = ModData.getOrCreate("AdminWarpData")
end
Events.OnInitGlobalModData.Add(AdminWarp.initClient)

function AdminWarp.onModDataReceive(key, data)
    if key == "AdminWarpData" then
        if data and type(data) == "table" then
            AdminWarpData = data
            if AdminWarpPanel and AdminWarpPanel.instance and AdminWarpPanel.instance:isVisible() then
                AdminWarpPanel.instance:loadPortals()
                AdminWarpPanel.instance:refreshListDisplay()
            end
            if UserWarpPanel and UserWarpPanel.instance and UserWarpPanel.instance:isVisible() then
                UserWarpPanel.instance:loadPortals()
                UserWarpPanel.instance:refreshList()
            end
 
        end
    end
end
Events.OnReceiveGlobalModData.Add(AdminWarp.onModDataReceive)
-----------------------            ---------------------------

Commands.AdminWarp.Summon = function(args)
    local pl = getPlayer()
    if not pl or not args.portal then return end

    local portal = args.portal
    local factName = portal.faction
    local isTp = false

    if not factName or factName == "" or factName == "Everyone" then
        if not AdminWarp.isAdm(pl) then
            isTp = true
        end
    else
        if AdminWarp.isMember(pl, factName) then
            isTp = true
        end
    end
    if not isTp then return end

    local delay = SandboxVars.AdminWarp.SummonDelay or 10
    UserWarp.startTeleportCountdown(pl, portal, delay, true)
end

Events.OnServerCommand.Add(function(module, command, args)
	if Commands[module] and Commands[module][command] then
		Commands[module][command](args)
	end
end)

