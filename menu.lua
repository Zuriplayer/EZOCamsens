local ADDON = EZOcamsens
local PANEL_ID = "EZOcamsensPanel"
local INFO_HEADER_TEXTURE = "EsoUI/Art/Miscellaneous/help_icon.dds"

local function CreateInfoHeader(name, tooltip)
  return {
    type = "header",
    name = zo_strformat(
      "<<1>> |cB040FF|t26:26:<<2>>:inheritcolor|t|r",
      tostring(name or ""),
      INFO_HEADER_TEXTURE
    ),
    tooltip = tooltip,
  }
end

function ADDON:SetupMenu()
  local LAM = LibAddonMenu2
  if not LAM then return end

  local panelData = {
    type = "panel",
    name = "E|cB040FFZ|rOcamsens",
    author = ADDON:Text("AUTHOR"),
    version = ADDON.version,
    ezoStage = "archived",
    feedback = "https://discord.gg/ekw8zUAcRm",
    registerForRefresh = true,
    registerForDefaults = false,
  }

  local function applyBaseIfNeeded()
    if ADDON.sv.dynamicEnabled then
      if ADDON.IsDynamicTurnAllowed
          and ADDON:IsDynamicTurnAllowed()
          and ADDON.StopDynamicTurnAssist
          and ADDON.StartDynamicTurnAssist then
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
    CreateInfoHeader(ADDON:Text("STORAGE_HEADER"), ADDON:Text("STORAGE_HEADER_TT")),
    { type="dropdown", name=ADDON:Text("STORAGE_SCOPE"),
      tooltip=ADDON:Text("STORAGE_SCOPE_TT"),
      choices={ADDON:Text("STORAGE_SCOPE_CHARACTER"), ADDON:Text("STORAGE_SCOPE_ACCOUNT")},
      choicesValues={"character","account"},
      getFunc=function() return ADDON:GetSettingsScope() end,
      setFunc=function(val) ADDON:SetSettingsScope(val) end,
      warning=ADDON:Text("SCOPE_RELOAD_NOTICE"),
    },

    CreateInfoHeader(ADDON:Text("PRESETS_HEADER"), ADDON:Text("PRESETS_HEADER_TT")),
    { type="submenu", name=ADDON:Text("TP_HEADER"), tooltip=ADDON:Text("TP_HEADER_TT"), controls = {
      { type="slider", name=ADDON:Text("TP_H"), min=0.10, max=5.0, step=0.01, decimals=2,
      tooltip=ADDON:Text("TP_H_TT"),
      getFunc=function() return ADDON.sv.tpH end,
      setFunc=function(v)
        ADDON.sv.tpH = v
        applyBaseIfNeeded()
      end, default=0.85 },
    }},
    { type="button", name=ADDON:Text("APPLY_NOW"), tooltip=ADDON:Text("APPLY_NOW_TT"),
      func=function() ADDON:ApplyPresets({ bypassGamepadGuard = true, forceChat = true }) end },

    CreateInfoHeader(ADDON:Text("DYNAMIC_HEADER"), ADDON:Text("DYNAMIC_HEADER_TT")),
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
      tooltip=ADDON:Text("DYNAMIC_FAST_TT"),
      getFunc=function() return ADDON.sv.dynamicFastTpH end,
      setFunc=function(v)
        ADDON.sv.dynamicFastTpH = v
        if ADDON.sv.dynamicEnabled and ADDON.StopDynamicTurnAssist and ADDON.StartDynamicTurnAssist then
          ADDON:StopDynamicTurnAssist(false)
          ADDON:StartDynamicTurnAssist()
        end
      end, default=5.00 },
    { type="slider", name=ADDON:Text("DYNAMIC_SLOW"), min=0.10, max=5.0, step=0.01, decimals=2,
      tooltip=ADDON:Text("DYNAMIC_SLOW_TT"),
      getFunc=function() return ADDON.sv.dynamicSlowTpH end,
      setFunc=function(v) ADDON.sv.dynamicSlowTpH = v end, default=1.60 },
    { type="slider", name=ADDON:Text("DYNAMIC_ANGLE"), min=5, max=360, step=1, decimals=0,
      tooltip=ADDON:Text("DYNAMIC_ANGLE_TT"),
      getFunc=function() return ADDON.sv.dynamicAngleThreshold end,
      setFunc=function(v) ADDON.sv.dynamicAngleThreshold = v end, default=180 },
    { type="slider", name=ADDON:Text("DYNAMIC_IDLE"), min=100, max=2000, step=50, decimals=0,
      tooltip=ADDON:Text("DYNAMIC_IDLE_TT"),
      getFunc=function() return ADDON.sv.dynamicIdleResetMs end,
      setFunc=function(v) ADDON.sv.dynamicIdleResetMs = v end, default=300 },
    { type="slider", name=ADDON:Text("DYNAMIC_MOVEMENT"), min=0.05, max=5.0, step=0.05, decimals=2,
      tooltip=ADDON:Text("DYNAMIC_MOVEMENT_TT"),
      getFunc=function() return ADDON.sv.dynamicMovementThreshold end,
      setFunc=function(v) ADDON.sv.dynamicMovementThreshold = v end, default=0.25 },

    CreateInfoHeader(ADDON:Text("BEHAVIOR"), ADDON:Text("BEHAVIOR_TT")),
    { type="checkbox", name=ADDON:Text("ONLY_GP"),
      tooltip=ADDON:Text("ONLY_GP_TT"),
      getFunc=function() return ADDON.sv.applyOnlyInGamepad end,
      setFunc=function(v) ADDON.sv.applyOnlyInGamepad=v end, default=true },

    { type="checkbox", name=ADDON:Text("CHAT_MSG"),
      tooltip=ADDON:Text("CHAT_MSG_TT"),
      getFunc=function() return ADDON.sv.chatEnabled end,
      setFunc=function(v) ADDON.sv.chatEnabled=v; if (ADDON.chat) then ADDON.chat:SetEnabled(v) end end, default=true },

    CreateInfoHeader(ADDON:Text("SUPPORT"), ADDON:Text("SUPPORT_TT")),
    { type="checkbox", name=ADDON:Text("DEBUG_MODE"),
      tooltip=ADDON:Text("DEBUG_MODE_TT"),
      getFunc=function() return ADDON:IsDebugModeEnabled() end,
      setFunc=function(v) ADDON:SetDebugModeEnabled(v) end, default=false },

    { type="button", name=ADDON:Text("SHOW_STATUS"),
      tooltip=ADDON:Text("SHOW_STATUS_TT"),
      disabled=function() return not ADDON:IsDebugModeEnabled() end,
      func=function() ADDON:SendStatusToDebugViewer() end },

    CreateInfoHeader(ADDON:Text("MAINTENANCE"), ADDON:Text("MAINTENANCE_TT")),
    { type="dropdown", name=ADDON:Text("LANG_DD"),
      tooltip=ADDON:Text("LANG_DD_TT"),
      choices={ADDON:Text("LANG_AUTO"), ADDON:Text("LANG_ES"), ADDON:Text("LANG_EN")},
      choicesValues={"auto","es","en"},
      sort="name-up",
      getFunc=function()
        local value = ADDON.sv.language or ADDON:GetDefaultLanguage()
        if value == "inherit" then value = "auto" end
        return value
      end,
      setFunc=function(val)
        if val == "inherit" then val = "auto" end
        ADDON.sv.language = val or ADDON:GetDefaultLanguage()
        ADDON:InitLocale()
        if ADDON.chat then ADDON.chat:Print(ADDON:Text("LANG_NOTICE")) end
        zo_callLater(function() ReloadUI() end, 50)
      end,
      disabled=function() return ADDON:IsLanguageManagedByEZOCore() end,
      warning=ADDON:Text("LANG_NOTICE"),
    },

    { type="button", name=ADDON:Text("RESTORE_DEFAULTS"),
      tooltip=ADDON:Text("RESTORE_DEFAULTS_TT"),
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
