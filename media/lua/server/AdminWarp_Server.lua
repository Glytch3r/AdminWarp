
--server/AdminWarp_Server.lua
if isClient() then return end
AdminWarp = AdminWarp or {}

function AdminWarp.initServer()
    AdminWarpData = ModData.getOrCreate("AdminWarpData")

end
Events.OnInitGlobalModData.Add(AdminWarp.initServer)

function AdminWarp.OnReceiveGlobalModData(key, data)
    if key == "AdminWarpData" then
        AdminWarpData = data or {portals = {}}
        sendServerCommand(nil, "AdminWarp", "Msg", {msg = "Server: AdminWarpData received"})
    end
end
Events.OnReceiveGlobalModData.Add(AdminWarp.OnReceiveGlobalModData)

function AdminWarp.clientSync(module, command, player, args)
    if module == "AdminWarp" then 
        if command == "Update" and args.data then
            AdminWarpData = args.data
            ModData.add('AdminWarpData', AdminWarpData)
            ModData.transmit("AdminWarpData")
            sendServerCommand(nil, "AdminWarp", "Update", {data = AdminWarpData})
        elseif command == "RequestSync" then
            sendServerCommand(player, "AdminWarp", "Update", {data = AdminWarpData})
        elseif command == "Check" then
            sendServerCommand(player, "AdminWarp", "Check", {data = AdminWarpData})
        end
    end
end
Events.OnClientCommand.Add(AdminWarp.clientSync)