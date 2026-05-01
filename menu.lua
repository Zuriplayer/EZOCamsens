local ADDON = EZOcamsens

function ADDON:SetupMenu()
  local LAM = LibAddonMenu2
  if not LAM then return end

  local panelData = {
    type = "panel",
    name = "E|cB040FFZ|rOcamsens",
    author = ADDON:Text("AUTHOR"),
    version = ADDON.version,
    registerForRefresh = true,
    registerForDefaults = false,
  }
  if not ADDON.lamPanel then
    ADDON.lamPanel = LAM:RegisterAddonPanel("EZOcamsensPanel", panelData)
  end

  local options = {
    { type="description", text=ADDON:Text("DESC") },

    { type="header", name=ADDON:Text("PRESETS_HEADER") },
    { type="description", text=ADDON:Text("APPLY_HINT") },
    { type="submenu", name=ADDON:Text("TP_HEADER"), controls = {
      { type="slider", name=ADDON:Text("TP_H"), min=0.10, max=5.0, step=0.01, decimals=2,
      getFunc=function() return ADDON.sv.tpH end, setFunc=function(v) ADDON.sv.tpH=v end, default=1.60 },
    }},
    { type="button", name=ADDON:Text("APPLY_NOW"), func=function() ADDON:ApplyPresets() end },

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

    { type="button", name=ADDON:Text("SHOW_STATUS"), func=function() ADDON:PrintStatus() end },
    { type="button", name=ADDON:Text("DUMP_BUTTON"),
      func=function() ADDON:DumpCameraDiagnostics() end,
      disabled=function() return not ADDON:IsDebugModeEnabled() end },

    { type="header", name=ADDON:Text("MAINTENANCE") },
    { type="dropdown", name=ADDON:Text("LANG_DD"),
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

  LAM:RegisterOptionControls("EZOcamsensPanel", options)
end
