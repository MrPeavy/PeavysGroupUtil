local addonName = ...

PeavyGroupUtil = PeavyGroupUtil or {}
PeavyGroupUtil.addonName = PeavyGroupUtil.addonName or addonName

local addon = PeavyGroupUtil

addon.PartyActions = addon.PartyActions or {}

local function CanDoReadyCheck()
    if not IsInGroup() then return false end
    -- Ready checks are generally restricted to leaders/assistants.
    return UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")
end

local function CanStartCountdown()
    if not IsInGroup() then return false end
    if C_PartyInfo and C_PartyInfo.CanStartCountdown then
        return C_PartyInfo.CanStartCountdown()
    end
    -- Fallback heuristic if the API isn't available.
    return UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")
end

function addon.PartyActions.CanDoReadyCheck()
    return CanDoReadyCheck()
end

function addon.PartyActions.CanStartCountdown()
    return CanStartCountdown()
end

function addon.PartyActions.DoReadyCheckSafe()
    if not CanDoReadyCheck() then
        addon.Notify("Ready check not available (need lead/assist).")
        return
    end
    if C_PartyInfo and C_PartyInfo.DoReadyCheck then
        C_PartyInfo.DoReadyCheck()
    else
        -- Legacy wrapper exists on some builds.
        DoReadyCheck()
    end
end

function addon.PartyActions.DoCountdownSafe(seconds)
    if not CanStartCountdown() then
        addon.Notify("Pull timer not available (need lead/assist).")
        return
    end
    if C_PartyInfo and C_PartyInfo.DoCountdown then
        C_PartyInfo.DoCountdown(seconds)
    end
end

