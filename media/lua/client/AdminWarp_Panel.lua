
require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISScrollingListBox"
require "ISUI/ISCollapsableWindow"
require "ISUI/ISComboBox"

AdminWarp = AdminWarp or {}
AdminWarpPanel = ISCollapsableWindow:derive("AdminWarpPanel")
AdminWarpPanel.instance = nil

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

function AdminWarpPanel:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o:setResizable(false)
    o.moveWithMouse = true
    o.title = "Admin Warp Panel"
    o.portals = {}
    return o
end

function AdminWarpPanel:initialise()
    ISCollapsableWindow.initialise(self)
    local btnWidth, btnHeight, margin = 60, 25, 10
    local listY, listHeight = 70, self.height - 180
    local labelY = listY - FONT_HGT_SMALL - 10      

    local titleX = 50
    local coordsX = 200
    local statusX = 330
    local factionX = 460

    self.labelTitle = ISLabel:new(titleX+35, labelY, FONT_HGT_SMALL, "Title", 1, 1, 1, 1, UIFont.Medium)
    self:addChild(self.labelTitle)
    self.labelCoords = ISLabel:new(coordsX+52, labelY, FONT_HGT_SMALL, "Coords", 1, 1, 1, 1, UIFont.Medium)
    self:addChild(self.labelCoords)
    self.labelStatus = ISLabel:new(statusX+50, labelY, FONT_HGT_SMALL, "Status", 1, 1, 1, 1, UIFont.Medium)
    self:addChild(self.labelStatus)
    self.labelFaction = ISLabel:new(factionX+50, labelY, FONT_HGT_SMALL, "Faction", 1, 1, 1, 1, UIFont.Medium)
    self:addChild(self.labelFaction)

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
            panel:drawRect(0, rectY, panel.width, rectH, 0.4, 0.8, 0.4, 0.8)
        elseif item.item.active then
            panel:drawRect(0, rectY, panel.width, rectH, 0.2, 0.2, 0.5, 0.25)
        else
            panel:drawRect(0, rectY, panel.width, rectH, 0.2, 0.2, 0.2, 0.25)
        end

        local textY = y + (panel.itemheight - FONT_HGT_SMALL) / 2


        panel:drawText(item.item.title or "", titleX, textY, 1,1,1,1, UIFont.Small)
        panel:drawText(item.item.coords or "", coordsX, textY, 1,1,1,1, UIFont.Small)
        panel:drawText(item.item.status or "", statusX, textY, 1,1,1,1, UIFont.Small)
        panel:drawText(item.item.faction or "", factionX, textY, 1,1,1,1, UIFont.Small)

        return y + panel.itemheight
    end


    self:addChild(self.scrollPanel)

    local textboxY = self.height - 90
    self.titleEntry = ISTextEntryBox:new("", 10, textboxY, 160, 25)
    self.titleEntry:initialise()
    self:addChild(self.titleEntry)

    self.factionCombo = ISComboBox:new(180, textboxY, 160, 25, self, nil) 
    self.factionCombo:initialise()
    self.factionCombo.backgroundColor = {r=0.2,g=0.2,b=0.2,a=1}
    self.factionCombo.borderColor = {r=0.4,g=0.4,b=0.4,a=1}
    self.factionCombo:clear()
    self.factionCombo:addOption("Everyone")
    for _, tag in ipairs(AdminWarp.getAllFactionNames()) do
        self.factionCombo:addOption(tag)
    end
    self.factionCombo.selected = 1
    self:addChild(self.factionCombo)

    local btnY = self.height - 50
    self.addBtn = ISButton:new(margin, btnY, btnWidth, btnHeight, "Add", self, AdminWarpPanel.onAddPortal)
    self.addBtn.backgroundColor = {r=0.2, g=0.6, b=0.2, a=1}
    self:addChild(self.addBtn)

    self.deleteBtn = ISButton:new(margin + btnWidth + 10, btnY, btnWidth, btnHeight, "Delete", self, AdminWarpPanel.onDeletePortal)
    self.deleteBtn.backgroundColor = {r=0.6, g=0.2, b=0.2, a=1}
    self:addChild(self.deleteBtn)

    self.toggleBtn = ISButton:new(margin + (btnWidth + 10) * 2, btnY, btnWidth, btnHeight, "Toggle", self, AdminWarpPanel.onTogglePortal)
    self.toggleBtn.backgroundColor = {r=0.2, g=0.6, b=0.2, a=1}
    self:addChild(self.toggleBtn)

    self.teleportBtn = ISButton:new(margin + (btnWidth + 10) * 3, btnY, btnWidth + 20, btnHeight, "Teleport", self, AdminWarpPanel.onTeleportPortal)
    self.teleportBtn.backgroundColor = {r=0.2, g=0.6, b=0.2, a=1}
    self.teleportBtn.enable = false
    self:addChild(self.teleportBtn)

    self:loadPortals()
    self:refreshList()
end

function AdminWarpPanel:update()
    ISCollapsableWindow.update(self)
    self.teleportBtn.enable = (self.scrollPanel.selected > 0)
    if AdminWarpData then
        local changed = (#AdminWarpData ~= #self.portals)
        if not changed then
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
function AdminWarpPanel:loadPortals()
    self.portals = {}
    if AdminWarpData then
        for i, portal in ipairs(AdminWarpData) do
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
function AdminWarpPanel:refreshList()
    AdminWarpData = self.portals
    ModData.add("AdminWarpData", AdminWarpData)
    self:refreshListDisplay()--[[  ]]
    self:sendUpdateToServer()
end

function AdminWarpPanel:refreshListDisplay()
    self.scrollPanel:clear()
    print("Refreshing display with " .. #self.portals .. " portals")
    
    for i, portal in ipairs(self.portals) do
        local factionDisplay = portal.faction or "Everyone"
        local coords = portal.x .. "," .. portal.y .. "," .. portal.z
        local status = portal.active and "Active" or "Inactive"
        
        self.scrollPanel:addItem(portal.title, {
            title = portal.title,
            coords = coords,
            status = status,
            faction = factionDisplay
        })
    end
end

function AdminWarpPanel:sendUpdateToServer()
    if isClient() then
        sendClientCommand(getPlayer(), "AdminWarp", "Update", {data = self.portals})
    end
end
function AdminWarpPanel:onAddPortal()
    local text = self.titleEntry:getText()
    if text and text ~= "" then
        local player = getPlayer()
        local existingIndex
        for i, portal in ipairs(self.portals) do
            if portal.title == text then
                existingIndex = i
                break
            end
        end
        local selectedFaction = self.factionCombo:getOptionText(self.factionCombo.selected)
        local factionValue = (selectedFaction ~= "Everyone") and selectedFaction or nil
        local newPortal = {
            title = text,
            x = math.floor(player:getX()),
            y = math.floor(player:getY()),
            z = math.floor(player:getZ()),
            active = false,
            faction = factionValue
        }
        if existingIndex then
            self.portals[existingIndex] = newPortal
        else
            table.insert(self.portals, newPortal)
        end
        self.titleEntry:setText("")
        self:refreshList()
    end
end
function AdminWarpPanel:onDeletePortal()
    local selected = self.scrollPanel.selected
    if selected > 0 then
        table.remove(self.portals, selected)
        self:refreshList()
    end
end
function AdminWarpPanel:onTogglePortal()
    local selected = self.scrollPanel.selected
    if selected > 0 then
        local portal = self.portals[selected]
        portal.active = not portal.active
        self:refreshList()
    end
end
function AdminWarpPanel:onTeleportPortal()
    local selected = self.scrollPanel.selected
    if selected > 0 then
        local portal = self.portals[selected]
        local player = getPlayer()
        if player and portal then
            player:setX(portal.x)
            player:setLx(portal.x)
            player:setY(portal.y)
            player:setLy(portal.y)
            player:setZ(portal.z)
        end
    end
end
function AdminWarpPanel:ClosePanel()
    if AdminWarpPanel.instance then
        AdminWarpPanel.instance:removeHooks()
        AdminWarpPanel.instance:close()
        AdminWarpPanel.instance = nil
    end
end
function AdminWarpPanel.OpenPanel()
    if not AdminWarpPanel.instance then
        local x = getCore():getScreenWidth() / 3
        local y = getCore():getScreenHeight() / 2 - 200
        local w, h = 650, 350
        AdminWarpPanel.instance = AdminWarpPanel:new(x, y, w, h)
        AdminWarpPanel.instance:initialise()
    end
    AdminWarpPanel.instance:addToUIManager()
    AdminWarpPanel.instance:setVisible(true)
end
function AdminWarpPanel.TogglePanel()
    if AdminWarpPanel.instance then
        AdminWarpPanel.instance:setVisible(not AdminWarpPanel.instance:isVisible())
    else
        AdminWarpPanel.OpenPanel()
    end
end