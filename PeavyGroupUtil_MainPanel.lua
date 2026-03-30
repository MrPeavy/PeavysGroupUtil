local addonName = ...

PeavyGroupUtil = PeavyGroupUtil or {}
PeavyGroupUtil.addonName = PeavyGroupUtil.addonName or addonName

local addon = PeavyGroupUtil

addon.MainPanel = addon.MainPanel or {}

local frame = CreateFrame("Frame", addon.addonName .. "Frame", UIParent, "BackdropTemplate")
addon.MainPanel.frame = frame

frame:SetSize(addon.FRAME_WIDTH, addon.FRAME_HEIGHT)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetClampedToScreen(true)

frame:SetScript("OnDragStart", function(self)
    -- Only prevent dragging; keep mouse enabled so buttons remain clickable.
    if addon.state and addon.state.frameLocked then return end
    self:StartMoving()
end)

frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    addon.SaveFramePosPct()
end)

frame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
frame:SetBackdropColor(0, 0, 0, addon.state.panelOpacity or 0.75)
frame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

local readyCheckBtn = addon.Widgets.CreateButton(frame, addon.BUTTON_WIDTH, addon.BUTTON_HEIGHT, "Ready Check")
addon.MainPanel.readyCheckBtn = readyCheckBtn
readyCheckBtn:SetPoint("TOP", frame, "TOP", 0, -addon.PADDING)
readyCheckBtn:SetScript("OnClick", function()
    addon.PartyActions.DoReadyCheckSafe()
end)

local pullTimerBtn = addon.Widgets.CreateButton(frame, addon.BUTTON_WIDTH, addon.BUTTON_HEIGHT, "Pull Timer")
addon.MainPanel.pullTimerBtn = pullTimerBtn
pullTimerBtn:SetPoint("TOP", readyCheckBtn, "BOTTOM", 0, -(addon.GAP))
pullTimerBtn:SetScript("OnMouseUp", function(self, button)
    if button == "RightButton" then
        addon.PartyActions.DoCountdownSafe(10)
    else
        addon.PartyActions.DoCountdownSafe(addon.state.pullTimerDuration or 10)
    end
end)

local cancelBtn = addon.Widgets.CreateButton(frame, addon.BUTTON_WIDTH, addon.BUTTON_HEIGHT, "Cancel Pull")
addon.MainPanel.cancelBtn = cancelBtn
cancelBtn:SetPoint("TOP", pullTimerBtn, "BOTTOM", 0, -(addon.GAP))
cancelBtn:SetBackdropColor(0.25, 0.05, 0.05, 0.9)
cancelBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(0.4, 0.1, 0.1, 0.9) end)
cancelBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(0.25, 0.05, 0.05, 0.9) end)
cancelBtn:SetScript("OnClick", function()
    addon.PartyActions.DoCountdownSafe(0)
end)

-- Auto-size all main buttons to the longest label.
C_Timer.After(0, function()
    local mainBtns = { readyCheckBtn, pullTimerBtn, cancelBtn }
    local maxW = 0
    for _, btn in ipairs(mainBtns) do
        local w = btn.lbl:GetStringWidth()
        if w > maxW then maxW = w end
    end
    local btnW = math.ceil(maxW) + 4 -- 2px each side
    for _, btn in ipairs(mainBtns) do
        btn:SetWidth(btnW)
    end
    frame:SetWidth(btnW + addon.PADDING * 2)
end)

function addon.MainPanel.UpdateButtonEnabledState()
    readyCheckBtn:SetEnabled(addon.PartyActions.CanDoReadyCheck())
    local countdownAllowed = addon.PartyActions.CanStartCountdown()
    pullTimerBtn:SetEnabled(countdownAllowed)
    cancelBtn:SetEnabled(countdownAllowed)
end

function addon.MainPanel.UpdatePanelVisibility()
    local inGroup = IsInGroup() or IsInRaid()
    local db = addon.GetDB()

    if inGroup and not db.panelHidden then
        frame:Show()
    else
        frame:Hide()
    end

    -- Options toggle text lives in OptionsPanel; update if created.
    if addon.OptionsPanel and addon.OptionsPanel.toggleBtn then
        addon.OptionsPanel.toggleBtn:SetText(db.panelHidden and "Show Panel" or "Hide Panel")
    end

    addon.MainPanel.UpdateButtonEnabledState()
end

