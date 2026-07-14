local ADDON = EZOcamsens
local PANEL_ID = "EZOcamsensPanel"

function ADDON:SetupMenu()
  local LAM = LibAddonMenu2
  if not LAM then return end

  local panelData = {
    type = "panel",
    name = "E|cB040FFZ|rOcamsens",
    author = ADDON:Text("AUTHOR"),
    version = ADDON.version,
    feedback = "https://discord.gg/ekw8zUAcRm",
    registerForRefresh = true,
    registerForDefaults = false,
  }

  local function applyBaseIfNeeded()
    if ADDON.sv.dynamicEnabled then
      if ADDON.IsDynamicTurnAllowed and ADDON:IsDynamicTurnAllowed() and ADDON.StopDynamicTurnAssist and ADDON.StartDynamicTurnAssist then
        ADDON:StopDynamicTurnAssist(false)
        ADDON:StartDynamicTurnAssist()
      elseif ADDON.SetDynamicTurnWaiting then
        ADDON:SetDynamicTurnWaiting()
      end
    elseif ADDON.ApplyPresets then
      ADDON:ApplyPresets({ bypassGamepadGuard = true, suppressFeedback = true })
    end
  end

  local options = {
    { type="description", text=ADDON:Text("DESC") },
    { type="description", text=ADDON:Text("SCOPE_NOTE") },

    { type="header", name=ADDON:Text("STORAGE_HEADER") },
    { type="dropdown", name=ADDON:Text("STORAGE_SCOPE"),
      tooltip=ADDON:Text("STORAGE_SCOPE_TT"),
      choices={ADDON:Text("STORAGE_SCOPE_CHARACTER"), ADDON:Text("STORAGE_SCOPE_ACCOUNT")},
      choicesValues={"character","account"},
      getFunc=function() return ADDON:GetSettingsScope() end,
      setFunc=function(val) ADDON:SetSettingsScope(val) end,
      warning=ADDON:Text("SCOPE_RELOAD_NOTICE"),
    },

    { type="header", name=ADDON:Text("PRESETS_HEADER") },
    { type="description", text=ADDON:Text("APPLY_HINT") },
    { type="submenu", name=ADDON:Text("TP_HEADER"), controls = {
      { type="slider", name=ADDON:Text("TP_H"), min=0.10, max=5.0, step=0.01, decimals=2,
      getFunc=function() return ADDON.sv.tpH end,
      setFunc=function(v)
        ADDON.sv.tpH = v
        applyBaseIfNeeded()
      end, default=0.85 },
    }},
    { type="button", name=ADDON:Text("APPLY_NOW"), func=function() ADDON:ApplyPresets({ bypassGamepadGuard = true, forceChat = true }) end },

    { type="header", name=ADDON:Text("DYNAMIC_HEADER") },
    { type="checkbox", name=ADDON:Text("DYNAMIC_ENABLED"),
      tooltip=ADDON:Text("DYNAMIC_ENABLED_TT"),
      getFunc=function() return ADDON.sv.dynamicEnabled end,
      setFunc=function(v)
        ADDON.sv.dynamicEnabled = v
        if ADDON.RefreshDynamicTurnAssist then ADDON:RefreshDynamicTurnAssist(true) end
      end, default=false },
    { type="checkbox", name=ADDON:Text("DYNAMIC_ONLY_COMBAT"),
      tooltip=ADDON:Text("DYNAMIC_ONLY_COMBAT_TT"),
      getFunc=function() return ADDON.sv.dynamicOnlyInCombat end,
      setFunc=function(v)
        ADDON.sv.dynamicOnlyInCombat = v
        if ADDON.RefreshDynamicTurnAssist then
          ADDON:StopDynamicTurnAssist(true)
          ADDON:RefreshDynamicTurnAssist(false)
        end
      end, default=true },
    { type="checkbox", name=ADDON:Text("DYNAMIC_ONLY_TANK"),
      tooltip=ADDON:Text("DYNAMIC_ONLY_TANK_TT"),
      getFunc=function() return ADDON.sv.dynamicOnlyTankRole end,
      setFunc=function(v)
        ADDON.sv.dynamicOnlyTankRole = v
        if ADDON.RefreshDynamicTurnAssist then
          ADDON:StopDynamicTurnAssist(true)
          ADDON:RefreshDynamicTurnAssist(false)
        end
      end, default=false },
    { type="slider", name=ADDON:Text("DYNAMIC_FAST"), min=0.10, max=5.0, step=0.01, decimals=2,
      getFunc=function() return ADDON.sv.dynamicFastTpH end,
      setFunc=function(v)
        ADDON.sv.dynamicFastTpH = v
        if ADDON.sv.dynamicEnabled and ADDON.StopDynamicTurnAssist and ADDON.StartDynamicTurnAssist then
          ADDON:StopDynamicTurnAssist(false)
          ADDON:StartDynamicTurnAssist()
        end
      end, default=5.00 },
    { type="slider", name=ADDON:Text("DYNAMIC_SLOW"), min=0.10, max=5.0, step=0.01, decimals=2,
      getFunc=function() return ADDON.sv.dynamicSlowTpH end,
      setFunc=function(v) ADDON.sv.dynamicSlowTpH = v end, default=1.60 },
    { type="slider", name=ADDON:Text("DYNAMIC_ANGLE"), min=5, max=360, step=1, decimals=0,
      getFunc=function() return ADDON.sv.dynamicAngleThreshold end,
      setFunc=function(v) ADDON.sv.dynamicAngleThreshold = v end, default=180 },
    { type="slider", name=ADDON:Text("DYNAMIC_IDLE"), min=100, max=2000, step=50, decimals=0,
      getFunc=function() return ADDON.sv.dynamicIdleResetMs end,
      setFunc=function(v) ADDON.sv.dynamicIdleResetMs = v end, default=300 },
    { type="slider", name=ADDON:Text("DYNAMIC_MOVEMENT"), min=0.05, max=5.0, step=0.05, decimals=2,
      getFunc=function() return ADDON.sv.dynamicMovementThreshold end,
      setFunc=function(v) ADDON.sv.dynamicMovementThreshold = v end, default=0.25 },

    { type="header", name=ADDON:Text("BEHAVIOR") },
    { type="checkbox", name=ADDON:Text("ONLY_GP"),
      tooltip=ADDON:Text("ONLY_GP_TT"),
      getFunc=function() return ADDON.sv.applyOnlyInGamepad end,
      setFunc=function(v) ADDON.sv.applyOnlyInGamepad=v end, default=true },

    { type="checkbox", name=ADDON:Text("CHAT_MSG"),
      getFunc=function() return ADDON.sv.chatEnabled end,
      setFunc=function(v) ADDON.sv.chatEnabled=v; if (ADDON.chat) then ADDON.chat:SetEnabled(v) end end, default=true },

    { type="header", name=ADDON:Text("SUPPORT") },
    { type="checkbox", name=ADDON:Text("DEBUG_MODE"),
      tooltip=ADDON:Text("DEBUG_MODE_TT"),
      getFunc=function() return ADDON:IsDebugModeEnabled() end,
      setFunc=function(v) ADDON:SetDebugModeEnabled(v) end, default=false },

    { type="button", name=ADDON:Text("SHOW_STATUS"),
      tooltip=ADDON:Text("SHOW_STATUS_TT"),
      disabled=function() return not ADDON:IsDebugModeEnabled() end,
      func=function() ADDON:SendStatusToDebugViewer() end },

    { type="header", name=ADDON:Text("MAINTENANCE") },
    { type="dropdown", name=ADDON:Text("LANG_DD"),
      tooltip=ADDON:Text("LANG_DD_TT"),
      choices={ADDON:Text("LANG_AUTO"), ADDON:Text("LANG_ES"), ADDON:Text("LANG_EN")},
      choicesValues={"auto","es","en"},
      sort="name-up",
      getFunc=function() return ADDON.sv.language or "auto" end,
      setFunc=function(val)
        ADDON.sv.language = val
        ADDON:InitLocale()
        if ADDON.chat then ADDON.chat:Print(ADDON:Text("LANG_NOTICE")) end
        zo_callLater(function() ReloadUI() end, 50)
      end,
      warning=ADDON:Text("LANG_NOTICE"),
    },

    { type="button", name=ADDON:Text("RESTORE_DEFAULTS"),
      warning=ADDON:Text("RESTORE_WARN"),
      func=function() ADDON:ResetToDefaults() end },
  }

  if EZOCore and type(EZOCore.RegisterSettingsPanel) == "function" then
    local registered = EZOCore:RegisterSettingsPanel(ADDON.name, PANEL_ID, panelData, options)
    if registered then
      ADDON.ezoSettingsRegistered = true
      return
    end
  end

  if not ADDON.lamPanel then
    ADDON.lamPanel = LAM:RegisterAddonPanel(PANEL_ID, panelData)
  end
  LAM:RegisterOptionControls(PANEL_ID, options)
end
