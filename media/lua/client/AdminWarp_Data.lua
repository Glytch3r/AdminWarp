if not isClient() then return end
AdminWarp = AdminWarp or {}

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
        --print('AdminWarpData: checked from server')
    end
end
Commands.AdminWarp.Beacon = function(args)
    local pl = getPlayer()
    if not args.portal then return end
    local portalData = args.portal
    local isMember = AdminWarp.isMember(pl, portalData.faction)
    print(isMember)
    if  isMember then
        UserWarp:startTeleportCountdown(pl, portalData, portalData.seconds, true)
    end
end



Events.OnServerCommand.Add(function(module, command, args)
	if Commands[module] and Commands[module][command] then
		Commands[module][command](args)
	end
end)

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



Commands.AdminWarp.Beacon = function(args)
    local pl = getPlayer()
    if not args.portal then return end
    local portalData = args.portal

    if AdminWarp.isMember(pl, portalData.faction) then
        UserWarp:startTeleportCountdown(pl, portalData, portalData.seconds, true)
    end
end

Events.OnServerCommand.Add(function(module, command, args)
    if Commands[module] and Commands[module][command] then
        Commands[module][command](args)
    end
end)
