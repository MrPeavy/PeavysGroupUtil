local addonName = ...

PeavyGroupUtil = PeavyGroupUtil or {}
PeavyGroupUtil.addonName = PeavyGroupUtil.addonName or addonName

local addon = PeavyGroupUtil

addon.Widgets = addon.Widgets or {}

local SIMPLE_BACKDROP = addon.SIMPLE_BACKDROP
local PADDING = addon.PADDING
local CHECKBOX_SIZE = addon.CHECKBOX_SIZE

function addon.Widgets.CreateButton(parent, width, height, text)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width, height)
    btn:SetBackdrop(SIMPLE_BACKDROP)
    btn:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    btn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    btn:SetScript("OnEnter", function(self) self:SetBackdropColor(0.25, 0.25, 0.25, 0.9) end)
    btn:SetScript("OnLeave", function(self) self:SetBackdropColor(0.1, 0.1, 0.1, 0.9) end)
    -- Ensure right-click reaches OnMouseUp for the pull timer button.
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    local lbl = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lbl:SetPoint("CENTER")
    lbl:SetText(text)
    btn.lbl = lbl

    btn.SetText = function(self, t) self.lbl:SetText(t) end
    btn.GetText = function(self) return self.lbl:GetText() end
    return btn
end

function addon.Widgets.CreateCheckbox(parent, anchorTo)
    local check = CreateFrame("Button", nil, parent, "BackdropTemplate")
    check:SetSize(CHECKBOX_SIZE, CHECKBOX_SIZE)
    check:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", 0, -PADDING)
    check:SetBackdrop(SIMPLE_BACKDROP)
    check:SetBackdropColor(0.05, 0.05, 0.05, 1)
    check:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

    local tick = check:CreateTexture(nil, "OVERLAY")
    tick:SetSize(CHECKBOX_SIZE + 4, CHECKBOX_SIZE + 4)
    tick:SetPoint("CENTER")
    tick:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    tick:Hide()
    return check, tick
end

