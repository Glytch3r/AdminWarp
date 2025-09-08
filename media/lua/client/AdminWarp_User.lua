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
    o.title = "Player Warp Panel"
    o.portals = {}
    return o
end

function UserWarpPanel:initialise()
    ISCollapsableWindow.initialise(self)
    local btnWidth, btnHeight, margin = 80, 25, 10
    local listY, listHeight = 70, self.height - 120
    local labelY = listY - FONT_HGT_SMALL - 10      

    local titleX = 50
    local coordsX = 200
    local statusX = 330
    local factionX = 460

    self.labelTitle = ISLabel:new(titleX+35, labelY, FONT_HGT_SMALL, "Title", 1, 1, 1, 1, UIFont.Medium)
    self:addChild(self.labelTitle)
    self.labelCoords = ISLabel:new(coordsX+55, labelY, FONT_HGT_SMALL, "Coords", 1, 1, 1, 1, UIFont.Medium)
    self:addChild(self.labelCoords)
    self.labelStatus = ISLabel:new(statusX+35, labelY, FONT_HGT_SMALL, "Status", 1, 1, 1, 1, UIFont.Medium)
    self:addChild(self.labelStatus)


    self.scrollPanel = ISScrollingListBox:new(margin, listY, self.width - margin * 2, listHeight)
    self.scrollPanel:initialise()
    self.scrollPanel.backgroundColor = {r=0.1, g=0.1, b=0.1, a=0} 
    self.scrollPanel.borderColor = {r=0.3, g=0.3, b=0.3, a=1}
    self.scrollPanel.drawBorder = true
    self.scrollPanel.itemheight = 25

    self.scrollPanel.doDrawItem = function(panel, y, item, alt)
        local rectY = y + 1
        local rectH = panel.itemheight - 2

        if panel.selected == item.index then
            panel:drawRect(0, rectY, panel.width, rectH, 0.4, 0.6, 0.4, 0.8)
        elseif item.item.active then
            panel:drawRect(0, rectY, panel.width, rectH, 0.4, 0.2, 0.2, 0.25)
        else
            panel:drawRect(0, rectY, panel.width, rectH, 0.2, 0.2, 0.2, 0.25)
        end

        local textY = y + (panel.itemheight - FONT_HGT_SMALL) / 2
        panel:drawText(item.item.title or "", titleX, textY, 1,1,1,1, UIFont.Small)
        panel:drawText(item.item.coords or "", coordsX, textY, 1,1,1,1, UIFont.Small)
        panel:drawText(item.item.active and "Active" or "Inactive", statusX, textY, 1,1,1,1, UIFont.Small)

        return y + panel.itemheight
    end

    self:addChild(self.scrollPanel)

    local btnY = self.height - 50
    self.teleportBtn = ISButton:new(margin, btnY, btnWidth + 20, btnHeight, "Teleport", self,  UserWarpPanel.onTeleportPortal)
    --self.teleportBtn.backgroundColor = {r=0.2, g=0.5, b=0.2, a=1}
    self.teleportBtn.backgroundColor = {r=0.2, g=0.2, b=0.2, a=1}

    self.teleportBtn:setEnable(false)
    self:addChild(self.teleportBtn)
    self.sendBeaconBtn = ISButton:new(margin + btnWidth + 30, btnY, btnWidth, btnHeight, "Beacon", self, UserWarpPanel.onBeacon)
    self.sendBeaconBtn.backgroundColor = {r=0.2, g=0.6, b=0.2, a=1}
    self:addChild(self.sendBeaconBtn)

    local pl = getPlayer()
    if self.selectedPortal and AdminWarp.isOwner(pl, self.selectedPortal) then
        self.sendBeaconBtn:setEnable(true)
    else
        self.sendBeaconBtn:setEnable(false)
    end

    self:loadPortals()
    self:refreshList()
end

-----------------------            ---------------------------
function UserWarpPanel:onBeacon()
    local selected = self.scrollPanel.selected
    if selected <= 0 then return end

    local portal = self.portals[selected]
    if not portal then return end

    if AdminWarp.isOwner(getPlayer(), portal) then
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
end

-----------------------            ---------------------------
function UserWarpPanel:update()
    ISCollapsableWindow.update(self)

    local selectedItem = self.scrollPanel.items[self.scrollPanel.selected]
    local selectedPortal = self.portals[self.scrollPanel.selected]
    local pl = getPlayer()
    local canTeleport = false
    local canBeacon = false

    if selectedPortal then
        canTeleport = selectedPortal.active and self:canPlayerSeePortal(pl, selectedPortal)
        canBeacon = selectedPortal.active and AdminWarp.isOwner(pl, selectedPortal)
    end

    self.teleportBtn:setEnable(canTeleport)
    self.sendBeaconBtn:setEnable(canBeacon)

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
        local source = AdminWarpData.portals or AdminWarpData
        for i, portal in ipairs(source) do
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
        local coords = portal.x .. "," .. portal.y .. "," .. portal.z

        self.scrollPanel:addItem(portal.title, {
            title = portal.title,
            coords = coords,
            active = portal.active,
            faction = factionDisplay
        })
    end

    if prevSelected and prevSelected <= #self.scrollPanel.items then
        self.scrollPanel.selected = prevSelected
    else
        self.scrollPanel.selected = 0
    end
    if self.teleportBtn.isEnabled then
        self.teleportBtn.backgroundColor = {r=0.2, g=0.6, b=0.2, a=1}
    else
        self.teleportBtn.backgroundColor = {r=0.2, g=0.2, b=0.2, a=0.5}
    end

    self.teleportBtn.backgroundColor = {r=0.2, g=0.5, b=0.2, a=1}
end

function UserWarpPanel:onTeleportPortal()
    local pl = getPlayer()
    local selected = self.scrollPanel.selected
    if selected > 0 then
        local selectedItem = self.scrollPanel.items[selected]
        if selectedItem and selectedItem.item and selectedItem.item.active then
            local portal = selectedItem.item
            if pl then
                local delay = SandboxVars.AdminWarp.TPdelay or 10
                UserWarp:startTeleportCountdown(pl, portal, delay, isBeacon)
            end
        else
            if pl then
                pl:addLineChatElement("Portal is inactive: " .. (selectedItem.item.title or "Unknown"))
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
        local w, h = 450, 300
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
