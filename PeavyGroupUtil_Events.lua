local addonName = ...

PeavyGroupUtil = PeavyGroupUtil or {}
PeavyGroupUtil.addonName = PeavyGroupUtil.addonName or addonName

local addon = PeavyGroupUtil

local dbFrame = CreateFrame("Frame")
dbFrame:RegisterEvent("ADDON_LOADED")

dbFrame:SetScript("OnEvent", function(self, event, name)
    if event == "ADDON_LOADED" then
        if name ~= addon.addonName then return end
        self:UnregisterEvent("ADDON_LOADED")

        local db = addon.GetDB()
        if db.panelHidden == nil then
            db.panelHidden = false
        end

        -- Apply saved settings into runtime state first.
        if db.pullTimerDuration then
            addon.state.pullTimerDuration = db.pullTimerDuration
            if addon.OptionsPanel and addon.OptionsPanel.durationBox then
                addon.OptionsPanel.durationBox:SetText(tostring(addon.state.pullTimerDuration))
            end
        end

        if db.frameLocked ~= nil then
            addon.state.frameLocked = db.frameLocked
            if addon.OptionsPanel and addon.OptionsPanel.UpdateLockState then
                addon.OptionsPanel.UpdateLockState()
            end
        end

        if db.borderHidden ~= nil then
            addon.state.borderHidden = db.borderHidden
            if addon.OptionsPanel and addon.OptionsPanel.UpdateBorderState then
                addon.OptionsPanel.UpdateBorderState()
            end
        end

        if db.panelOpacity then
            addon.state.panelOpacity = db.panelOpacity
            local frame = addon.MainPanel and addon.MainPanel.frame
            if frame then
                frame:SetBackdropColor(0, 0, 0, addon.state.panelOpacity)
            end
            if addon.OptionsPanel and addon.OptionsPanel.opacitySlider then
                addon.OptionsPanel.opacitySlider:SetValue(addon.state.panelOpacity)
            end
        end

        -- Position persistence.
        if db.framePosPct then
            -- Restore deferred to PLAYER_LOGIN.
        elseif db.framePos then
            -- Legacy best-effort conversion from stored top/left coords.
            local x = tonumber(db.framePos.x)
            local y = tonumber(db.framePos.y)
            if x and y and addon.MainPanel and addon.MainPanel.frame then
                local frame = addon.MainPanel.frame
                local w, h = frame:GetWidth(), frame:GetHeight()
                local pw, ph = UIParent:GetWidth(), UIParent:GetHeight()
                if w and h and pw and ph and pw > 0 and ph > 0 then
                    local cx = x + (w / 2)
                    local cy = y - (h / 2)
                    db.framePosPct = { x = addon.Clamp01(cx / pw), y = addon.Clamp01(cy / ph) }
                end
            end
        end

        self:RegisterEvent("PLAYER_LOGIN")
        self:RegisterEvent("GROUP_ROSTER_UPDATE")
        self:RegisterEvent("PLAYER_ROLES_ASSIGNED")
        self:RegisterEvent("PLAYER_ENTERING_WORLD")

        addon.MainPanel.UpdatePanelVisibility()
        addon.MainPanel.UpdateButtonEnabledState()

    elseif event == "PLAYER_LOGIN" then
        local db = addon.GetDB()
        if db.framePosPct then
            addon.RestoreFramePosPct(db.framePosPct)
        elseif db.framePos then
            local x = tonumber(db.framePos.x)
            local y = tonumber(db.framePos.y)
            if x and y and addon.MainPanel and addon.MainPanel.frame then
                local frame = addon.MainPanel.frame
                local w, h = frame:GetWidth(), frame:GetHeight()
                local pw, ph = UIParent:GetWidth(), UIParent:GetHeight()
                if w and h and pw and ph and pw > 0 and ph > 0 then
                    local cx = x + (w / 2)
                    local cy = y - (h / 2)
                    db.framePosPct = { x = addon.Clamp01(cx / pw), y = addon.Clamp01(cy / ph) }
                    addon.RestoreFramePosPct(db.framePosPct)
                end
            end
        end

        self:UnregisterEvent("PLAYER_LOGIN")
        addon.MainPanel.UpdatePanelVisibility()

    elseif event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ROLES_ASSIGNED" or event == "PLAYER_ENTERING_WORLD" then
        addon.MainPanel.UpdatePanelVisibility()
    end
end)

