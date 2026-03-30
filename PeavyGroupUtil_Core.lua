local addonName = ...

PeavyGroupUtil = PeavyGroupUtil or {}
PeavyGroupUtil.addonName = PeavyGroupUtil.addonName or addonName

local addon = PeavyGroupUtil

-- Constants/layout. Exposed on `addon` so other modules stay decoupled.
addon.BUTTON_WIDTH = 80
addon.BUTTON_HEIGHT = 22
addon.PADDING = 10
addon.GAP = 4
addon.CHECKBOX_SIZE = 14
addon.OPT_TITLE_HEIGHT = 16

addon.FRAME_WIDTH = addon.BUTTON_WIDTH + (addon.PADDING * 2)
addon.FRAME_HEIGHT = (addon.PADDING * 2) + (addon.BUTTON_HEIGHT * 3) + (addon.GAP * 2)

addon.SIMPLE_BACKDROP = {
    bgFile   = "Interface/Buttons/WHITE8x8",
    edgeFile = "Interface/Buttons/WHITE8x8",
    edgeSize = 1,
}

-- Shared runtime state (mirrors SavedVariables).
addon.state = addon.state or {
    pullTimerDuration = 10,
    frameLocked = false,
    panelOpacity = 0.75,
    borderHidden = false,
}

function addon.GetDB()
    PeavyGroupUtilDB = PeavyGroupUtilDB or {}
    return PeavyGroupUtilDB
end

function addon.Notify(msg)
    if UIErrorsFrame and UIErrorsFrame.AddMessage then
        UIErrorsFrame:AddMessage(msg, 1, 0.6, 0)
    else
        print(msg)
    end
end

function addon.Clamp01(v)
    if v < 0 then return 0 end
    if v > 1 then return 1 end
    return v
end

function addon.SaveFramePosPct()
    local frame = addon.MainPanel and addon.MainPanel.frame
    if not frame then return end

    local db = addon.GetDB()
    local cx, cy = frame:GetCenter()
    if not cx or not cy then return end

    local pw, ph = UIParent:GetWidth(), UIParent:GetHeight()
    if not pw or not ph or pw <= 0 or ph <= 0 then return end

    db.framePosPct = {
        x = addon.Clamp01(cx / pw),
        y = addon.Clamp01(cy / ph),
    }
end

function addon.RestoreFramePosPct(posPct)
    local frame = addon.MainPanel and addon.MainPanel.frame
    if not frame then return false end
    if not posPct then return false end

    local pw, ph = UIParent:GetWidth(), UIParent:GetHeight()
    if not pw or not ph or pw <= 0 or ph <= 0 then return false end

    local xPct = addon.Clamp01(tonumber(posPct.x) or 0.5)
    local yPct = addon.Clamp01(tonumber(posPct.y) or 0.5)

    local xOfs = (xPct - 0.5) * pw
    local yOfs = (yPct - 0.5) * ph

    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER", xOfs, yOfs)
    return true
end

