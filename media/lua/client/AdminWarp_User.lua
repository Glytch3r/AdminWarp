require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISScrollingListBox"
require "ISUI/ISCollapsableWindow"

UserWarp = UserWarp or {}
UserWarpPanel = ISCollapsableWindow:derive("UserWarpPanel")
UserWarpPanel.instance = nil

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

function UserWarpPanel:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o:setResizable(false)
    o.moveWithMouse = true
    o.title = "Warp Panel"
    o.portals = {}
    return o
end

function UserWarpPanel:initialise()
    ISCollapsableWindow.initialise(self)
    local btnWidth, btnHeight, margin = 80, 25, 10
    local listY, listHeight = 40, self.height - 100

    self.scrollPanel = ISScrollingListBox:new(margin, listY, self.width - margin * 2, listHeight)
    self.scrollPanel:initialise()
    self.scrollPanel.backgroundColor = {r=0.1, g=0.1, b=0.1, a=1}
    self.scrollPanel.borderColor = {r=0.3, g=0.3, b=0.3, a=1}
    self.scrollPanel.drawBorder = true
    self.scrollPanel.itemheight = 25
    self:addChild(self.scrollPanel)

    local btnY = self.height - 45
    self.teleportBtn = ISButton:new(margin, btnY, btnWidth + 20, btnHeight, "Teleport", self, UserWarpPanel.onTeleportPortal)
    self.teleportBtn.backgroundColor = {r=0.4, g=0.4, b=0.2, a=1}
    self.teleportBtn.enable = false
    self:addChild(self.teleportBtn)

    self.refreshBtn = ISButton:new(margin + btnWidth + 30, btnY, btnWidth, btnHeight, "Refresh", self, UserWarpPanel.onRefresh)
    self.refreshBtn.backgroundColor = {r=0.2, g=0.4, b=0.6, a=1}
    self:addChild(self.refreshBtn)

    self:loadPortals()
    self:refreshList()
end

function UserWarpPanel:update()
    ISCollapsableWindow.update(self)
    
    local selectedItem = self.scrollPanel.items[self.scrollPanel.selected]
    local canTeleport = false
    
    if selectedItem and selectedItem.item then
        canTeleport = selectedItem.item.active == true
    end
    
    self.teleportBtn.enable = canTeleport

    if AdminWarpData and type(AdminWarpData) == "table" then
        local changed = (#AdminWarpData ~= #self.portals)
        
        if not changed and #AdminWarpData > 0 then
            for i, portal in ipairs(AdminWarpData) do
                local p = self.portals[i]
                if not p
                or p.title ~= portal.title
                or p.x ~= portal.x
                or p.y ~= portal.y
                or p.z ~= portal.z
                or p.active ~= portal.active
                or (p.faction or "") ~= (portal.faction or "") then
                    changed = true
                    break
                end
            end
        end
        
        if changed then
            self:loadPortals()
            self:refreshList()
        end
    end
end

function UserWarpPanel:loadPortals()
    self.portals = {}
    local player = getPlayer()
    
    if AdminWarpData and type(AdminWarpData) == "table" then
        if AdminWarpData.portals and type(AdminWarpData.portals) == "table" then
            for i, portal in ipairs(AdminWarpData.portals) do
                if self:canPlayerSeePortal(player, portal) then
                    table.insert(self.portals, {
                        title = portal.title,
                        x = portal.x,
                        y = portal.y,
                        z = portal.z,
                        active = portal.active,
                        faction = portal.faction or ""
                    })
                end
            end
        elseif AdminWarpData[1] and AdminWarpData[1].title then
            for i, portal in ipairs(AdminWarpData) do
                if self:canPlayerSeePortal(player, portal) then
                    table.insert(self.portals, {
                        title = portal.title,
                        x = portal.x,
                        y = portal.y,
                        z = portal.z,
                        active = portal.active,
                        faction = portal.faction or ""
                    })
                end
            end
        end
    end
end

function UserWarpPanel:canPlayerSeePortal(player, portal)
    if not portal.faction or portal.faction == "" then
        return true
    end
    
    if AdminWarp and AdminWarp.isMember then
        return AdminWarp.isMember(player, portal.faction)
    end
    
    return false
end
function UserWarpPanel:refreshList()
    local prevSelected = self.scrollPanel.selected
    self.scrollPanel:clear()
    for i, portal in ipairs(self.portals) do
        local factionDisplay = portal.faction or "Everyone"
        local statusColor = portal.active and "Active" or "Inactive"
        local displayText = string.format("%-25s %-20s %-12s %-15s",
            portal.title,
            portal.x .. "," .. portal.y .. "," .. portal.z,
            statusColor,
            factionDisplay
        )
        self.scrollPanel:addItem(displayText, portal)
    end
    if prevSelected and prevSelected <= #self.scrollPanel.items then
        self.scrollPanel.selected = prevSelected
    else
        self.scrollPanel.selected = 0
    end
end

function UserWarpPanel:onTeleportPortal()
    local pl = getPlayer()
    local selected = self.scrollPanel.selected
    if selected > 0 then
        local selectedItem = self.scrollPanel.items[selected]
        if selectedItem and selectedItem.item then
            local portal = selectedItem.item
            if portal.active then
                if pl then
                    local delay =  SandboxVars.AdminWarp.TPdelay or 10

                    UserWarp:startTeleportCountdown(pl, portal, delay)
                end
            else
                if pl then
                    pl:addLineChatElement("Portal is inactive: " .. portal.title)
                end
            end
        end
    end
end

function UserWarpPanel:onRefresh()
    sendClientCommand(getPlayer(), "AdminWarp", "RequestSync", {})
    self:loadPortals()
    self:refreshList()
end


function UserWarpPanel:ClosePanel()
    if UserWarpPanel.instance then
        UserWarpPanel.instance:removeHooks()
        UserWarpPanel.instance:close()
        UserWarpPanel.instance = nil
    end
end

function UserWarpPanel.OpenPanel()
    if not UserWarpPanel.instance then
        local x = getCore():getScreenWidth() / 3
        local y = getCore():getScreenHeight() / 2 - 150
        local w, h = 550, 300
        UserWarpPanel.instance = UserWarpPanel:new(x, y, w, h)
        UserWarpPanel.instance:initialise()
    end
    UserWarpPanel.instance:addToUIManager()
    UserWarpPanel.instance:setVisible(true)
end

function UserWarpPanel.TogglePanel()
    if UserWarpPanel.instance then
        UserWarpPanel.instance:setVisible(not UserWarpPanel.instance:isVisible())
    else
        UserWarpPanel.OpenPanel()
    end
end