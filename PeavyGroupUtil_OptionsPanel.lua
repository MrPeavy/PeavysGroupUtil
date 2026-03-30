local addonName = ...

PeavyGroupUtil = PeavyGroupUtil or {}
PeavyGroupUtil.addonName = PeavyGroupUtil.addonName or addonName

local addon = PeavyGroupUtil

addon.OptionsPanel = addon.OptionsPanel or {}

local OPT_WIDTH = 220
local OPT_HEIGHT = 245

local optFrame = CreateFrame("Frame", addon.addonName .. "OptionsFrame", UIParent, "BackdropTemplate")
addon.OptionsPanel.optFrame = optFrame

optFrame:SetSize(OPT_WIDTH, OPT_HEIGHT)
optFrame:SetPoint("CENTER")
optFrame:SetMovable(true)
optFrame:EnableMouse(true)
optFrame:RegisterForDrag("LeftButton")
optFrame:SetClampedToScreen(true)
optFrame:SetScript("OnDragStart", optFrame.StartMoving)
optFrame:SetScript("OnDragStop", optFrame.StopMovingOrSizing)
optFrame:Hide()

optFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
optFrame:SetBackdropColor(0, 0, 0, 0.85)
optFrame:SetBackdropBorderColor(0.6, 0.5, 0.1, 1)

local optTitle = optFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
optTitle:SetPoint("TOP", optFrame, "TOP", 0, -addon.PADDING)
optTitle:SetText("Peavy Group Util")

local optClose = addon.Widgets.CreateButton(optFrame, 20, 20, "X")
optClose:SetPoint("TOPRIGHT", optFrame, "TOPRIGHT", -4, -4)
optClose:SetScript("OnClick", function() optFrame:Hide() end)

local toggleBtn = addon.Widgets.CreateButton(optFrame, OPT_WIDTH - (addon.PADDING * 2), addon.BUTTON_HEIGHT, "Hide Panel")
addon.OptionsPanel.toggleBtn = toggleBtn
toggleBtn:SetPoint("TOPLEFT", optFrame, "TOPLEFT", addon.PADDING, -(addon.PADDING + addon.OPT_TITLE_HEIGHT))

toggleBtn:SetScript("OnClick", function()
    local db = addon.GetDB()
    -- Store preference; do not derive it from current visibility (which depends on being in-group).
    db.panelHidden = not db.panelHidden
    addon.MainPanel.UpdatePanelVisibility()
end)

local durationLabel = optFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
durationLabel:SetPoint("TOPLEFT", toggleBtn, "BOTTOMLEFT", 0, -addon.PADDING)
durationLabel:SetText("Pull Timer (sec):")
local durationBox = CreateFrame("EditBox", addon.addonName .. "_DurationBox", optFrame, "BackdropTemplate")
addon.OptionsPanel.durationBox = durationBox

durationBox:SetSize(44, addon.BUTTON_HEIGHT)
durationBox:SetPoint("LEFT", durationLabel, "RIGHT", 6, 0)
durationBox:SetBackdrop(addon.SIMPLE_BACKDROP)
durationBox:SetBackdropColor(0.05, 0.05, 0.05, 1)
durationBox:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
durationBox:SetFontObject(GameFontNormal)
durationBox:SetTextInsets(4, 4, 0, 0)
durationBox:SetAutoFocus(false)
durationBox:SetNumeric(true)
durationBox:SetMaxLetters(2)
durationBox:SetText(tostring(addon.state.pullTimerDuration))

durationBox:SetScript("OnEnterPressed", function(self)
    local val = tonumber(self:GetText())
    if val and val >= 1 and val <= 60 then
        addon.state.pullTimerDuration = val
        addon.GetDB().pullTimerDuration = val
    else
        self:SetText(tostring(addon.state.pullTimerDuration))
    end
    self:ClearFocus()
end)
durationBox:SetScript("OnEscapePressed", function(self)
    self:SetText(tostring(addon.state.pullTimerDuration))
    self:ClearFocus()
end)

-- Lock frame checkbox
local lockCheck, lockTick = addon.Widgets.CreateCheckbox(optFrame, durationLabel)
addon.OptionsPanel.lockCheck = lockCheck
addon.OptionsPanel.lockTick = lockTick

local function UpdateLockState()
    local frame = addon.MainPanel.frame
    if addon.state.frameLocked then
        lockTick:Show()
        frame:SetMovable(false)
        -- Keep mouse enabled so child buttons still receive clicks.
        frame:EnableMouse(true)
    else
        lockTick:Hide()
        frame:SetMovable(true)
        frame:EnableMouse(true)
    end
end

addon.OptionsPanel.UpdateLockState = UpdateLockState

lockCheck:SetScript("OnClick", function()
    addon.state.frameLocked = not addon.state.frameLocked
    addon.GetDB().frameLocked = addon.state.frameLocked
    UpdateLockState()
end)

local lockLabel = optFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
lockLabel:SetPoint("LEFT", lockCheck, "RIGHT", 6, 0)
lockLabel:SetText("Lock panel position")

-- Opacity slider
local opacityLabel = optFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
opacityLabel:SetPoint("TOPLEFT", lockCheck, "BOTTOMLEFT", 0, -addon.PADDING)
opacityLabel:SetText("Panel Opacity:")

local opacitySlider = CreateFrame("Slider", addon.addonName .. "_OpacitySlider", optFrame)
addon.OptionsPanel.opacitySlider = opacitySlider
opacitySlider:SetOrientation("HORIZONTAL")
opacitySlider:SetSize(OPT_WIDTH - (addon.PADDING * 2), 16)
opacitySlider:SetPoint("TOPLEFT", opacityLabel, "BOTTOMLEFT", 0, -4)
opacitySlider:SetMinMaxValues(0.1, 1.0)
opacitySlider:SetValueStep(0.05)
opacitySlider:SetObeyStepOnDrag(true)
opacitySlider:SetValue(addon.state.panelOpacity)

-- Track
local sliderBg = opacitySlider:CreateTexture(nil, "BACKGROUND")
sliderBg:SetTexture("Interface/Buttons/WHITE8x8")
sliderBg:SetVertexColor(0.3, 0.3, 0.3, 1)
sliderBg:SetHeight(4)
sliderBg:SetPoint("LEFT", opacitySlider, "LEFT", 4, 0)
sliderBg:SetPoint("RIGHT", opacitySlider, "RIGHT", -4, 0)

-- Thumb
local thumb = opacitySlider:CreateTexture(nil, "OVERLAY")
thumb:SetTexture("Interface/Buttons/WHITE8x8")
thumb:SetVertexColor(0.8, 0.8, 0.8, 1)
thumb:SetSize(8, 16)
opacitySlider:SetThumbTexture(thumb)

opacitySlider:SetScript("OnValueChanged", function(self, val)
    addon.state.panelOpacity = val
    local frame = addon.MainPanel.frame
    frame:SetBackdropColor(0, 0, 0, addon.state.panelOpacity)
    addon.GetDB().panelOpacity = addon.state.panelOpacity
end)

-- Hide border checkbox
local borderCheck, borderTick = addon.Widgets.CreateCheckbox(optFrame, opacitySlider)
addon.OptionsPanel.borderCheck = borderCheck
addon.OptionsPanel.borderTick = borderTick

local function UpdateBorderState()
    local frame = addon.MainPanel.frame
    if addon.state.borderHidden then
        borderTick:Show()
        frame:SetBackdropBorderColor(0, 0, 0, 0)
    else
        borderTick:Hide()
        frame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    end
end

addon.OptionsPanel.UpdateBorderState = UpdateBorderState

borderCheck:SetScript("OnClick", function()
    addon.state.borderHidden = not addon.state.borderHidden
    addon.GetDB().borderHidden = addon.state.borderHidden
    UpdateBorderState()
end)

local borderLabel = optFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
borderLabel:SetPoint("LEFT", borderCheck, "RIGHT", 6, 0)
borderLabel:SetText("Hide panel border")

-- Sync initial visuals from defaults.
UpdateLockState()
UpdateBorderState()

-- Slash command
SLASH_PEAVYGROUPUTIL1 = "/pgu"
SlashCmdList["PEAVYGROUPUTIL"] = function()
    if optFrame:IsShown() then
        optFrame:Hide()
    else
        addon.MainPanel.UpdatePanelVisibility()
        durationBox:SetText(tostring(addon.state.pullTimerDuration))
        optFrame:Show()
    end
end

