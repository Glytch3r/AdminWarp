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
	if not pl then return end 

	
	if getActivatedMods():contains("AdminFence") and not getCore():getDebug() and  AdminWarp.isAdm(pl) then
		return
    end
	local x, y = round(pl:getX()), round(pl:getY())
	if not x or not y then return end
	if getCore():getDebug() or sq:DistTo(x, y) <= 3 or sq == pl:getCurrentSquare() then
        local tip = ISWorldObjectContextMenu.addToolTip()
		local mainMenu = "Warp Panel"
		local Main = context:addOptionOnTop(tostring(mainMenu), worldobjects, function()
      
            if  AdminWarp.isAdm(pl) then    
                AdminWarpPanel.TogglePanel()
            else
                UserWarpPanel.OpenPanel()
            end
			getSoundManager():playUISound("UIActivateMainMenuItem")
			context:hideAndChildren()
		end)
		Main.iconTexture = getTexture("media/ui/LootableMaps/map_asterisk.png")
        

	end
end
Events.OnFillWorldObjectContextMenu.Add(AdminWarp.context)
