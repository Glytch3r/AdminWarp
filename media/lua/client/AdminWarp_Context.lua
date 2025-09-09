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
--AdminWarp_Context.lua
AdminWarp = AdminWarp or {}

-----------------------            ---------------------------
function AdminWarp.isAdm(pl)
    pl = pl or getPlayer()
    if not pl then return false end
    return isClient() and string.lower(pl:getAccessLevel()) == "admin"
end

function AdminWarp.context(player, context, worldobjects, test)
    local pl = getSpecificPlayer(player)
    local sq = clickedSquare
    if not pl or not sq then return end

    local x, y = round(pl:getX()), round(pl:getY())
    if not x or not y then return end

    if not getCore():getDebug() then
        if sq:DistTo(x, y) > 3 and sq ~= pl:getCurrentSquare() then return end
    end

    local blocked = getActivatedMods():contains("AdminFence") or getActivatedMods():contains("MiniToolKit")
	
    if AdminWarp.isAdm(pl) and not blocked then
        local mainOption = context:addOptionOnTop("Warp Panel", worldobjects, nil)
        mainOption.iconTexture = getTexture("media/ui/LootableMaps/map_asterisk.png")

        local subMenu = ISContextMenu:getNew(context)
        context:addSubMenu(mainOption, subMenu)

        subMenu:addOption("Admin Warp Panel", worldobjects, function()
            AdminWarpPanel.TogglePanel()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)

        subMenu:addOption("User Warp Panel", worldobjects, function()
            UserWarpPanel.TogglePanel()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
    else
        local onlyOption = context:addOptionOnTop("User Warp Panel", worldobjects, function()
            UserWarpPanel.TogglePanel()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        onlyOption.iconTexture = getTexture("media/ui/LootableMaps/map_asterisk.png")
    end
end

Events.OnFillWorldObjectContextMenu.Add(AdminWarp.context)
