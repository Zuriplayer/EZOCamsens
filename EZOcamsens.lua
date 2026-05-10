local ADDON = {}
EZOcamsens = ADDON

ADDON.name    = "EZOcamsens"
ADDON.version = "1.7.2"

-- Ajustes por defecto. Mantengo todo junto para que sea facil revisar cambios
-- de balance sin tener que perseguir valores por varios archivos.
local defaults = {
  applyOnlyInGamepad = true,
  debugMode = false,
  tpH = 1.60,
  dynamicEnabled = false,
  dynamicOnlyInCombat = true,
  dynamicFastTpH = 5.00,
  dynamicSlowTpH = 1.60,
  dynamicAngleThreshold = 180,
  dynamicIdleResetMs = 300,
  dynamicMovementThreshold = 0.25,
  chatEnabled  = true,
  language = "auto", -- "auto" | "es" | "en"
}
ADDON.defaults = defaults

-- Valores base del juego tomados de un perfil PTS limpio. Solo se incluyen
-- ajustes que este addon toca o puede tocar en el futuro cercano.
local gameDefaults = {
  sensitivity = {
    TP_H = 0.85,
  },
}
ADDON.gameDefaults = gameDefaults

local MANAGED_SV_KEYS = {
  TP_H = "tpH",
}

local function applyManagedGameDefaultsToSavedVars(sv)
  if type(sv) ~= "table" then return end

  for axisKey, svKey in pairs(MANAGED_SV_KEYS) do
    local value = tonumber(gameDefaults.sensitivity[axisKey])
    if value then
      sv[svKey] = value
    end
  end
end

local function copyDefaults(dst, src)
  for k, v in pairs(src) do
    if type(v) == "table" then
      dst[k] = dst[k] or {}
      copyDefaults(dst[k], v)
    else
      dst[k] = v
    end
  end
end

function ADDON:ResetToDefaults()
  if not self.sv then return end
  copyDefaults(self.sv, defaults)
  applyManagedGameDefaultsToSavedVars(self.sv)
  if self.chat then self.chat:SetEnabled(self.sv.chatEnabled) end
  if self.InitLocale then self:InitLocale() end
  if self.ApplyPresets then
    self:ApplyPresets({ bypassGamepadGuard = true, suppressFeedback = true })
  end
  if self.chat and self.sv.chatEnabled then self.chat:Print(self:Text("DEFAULTS_RESTORED")) end
  self:RefreshLAM()
end

function ADDON:IsDebugModeEnabled()
  return self.sv and self.sv.debugMode == true
end

function ADDON:SetDebugModeEnabled(enabled)
  if not self.sv then return end
  self.sv.debugMode = enabled == true
  if self.RefreshDebugLoggerState then
    self:RefreshDebugLoggerState()
  end
  self:RefreshLAM()
end

function ADDON:MigrateSavedVariables()
  if not self.sv then return end

  if self.sv.debugMode == nil then
    self.sv.debugMode = self.sv.verbose == true
  end
  self.sv.verbose = nil

  if self.sv.tpH == nil then
    local tp = tonumber(self.sv.tp) or defaults.tpH
    self.sv.tpH = tp
  end
  if self.sv.dynamicEnabled == nil then self.sv.dynamicEnabled = defaults.dynamicEnabled end
  if self.sv.dynamicOnlyInCombat == nil then self.sv.dynamicOnlyInCombat = defaults.dynamicOnlyInCombat end
  if self.sv.dynamicFastTpH == nil then self.sv.dynamicFastTpH = self.sv.tpH or defaults.dynamicFastTpH end
  if self.sv.dynamicSlowTpH == nil then self.sv.dynamicSlowTpH = defaults.dynamicSlowTpH end
  if self.sv.dynamicAngleThreshold == nil then self.sv.dynamicAngleThreshold = defaults.dynamicAngleThreshold end
  if self.sv.dynamicIdleResetMs == nil then self.sv.dynamicIdleResetMs = defaults.dynamicIdleResetMs end
  if self.sv.dynamicMovementThreshold == nil then self.sv.dynamicMovementThreshold = defaults.dynamicMovementThreshold end
  self.sv.tp = nil
  self.sv.capMultiplier = nil
  self.sv.autoApplyCapsOnLoad = nil
  self.sv.useCVarsFallback = nil
  self.sv.diagThreshold = nil
  self.sv.diagAutoStopMs = nil
  self.sv.originalSensitivity = nil
end

function ADDON:OnLoaded(event, addonName)
  if addonName ~= self.name then return end
  EVENT_MANAGER:UnregisterForEvent(self.name .. "_Loaded", EVENT_ADD_ON_LOADED)

  self.sv = ZO_SavedVars:NewAccountWide("EZOcamsens_SV", 9, nil, defaults)
  self:MigrateSavedVariables()

  self:InitLogger()
  if self.RefreshDebugLoggerState then self:RefreshDebugLoggerState() end
  self:InitChat()
  self:InitLocale()
  self:DiscoverCameraSliders()
  self:SetupMenu()
  if self.RefreshDynamicTurnAssist then self:RefreshDynamicTurnAssist(true) end

  SLASH_COMMANDS["/ezocamsens"] = function(txt)
    txt = zo_strtrim(txt or "")
    local lower = zo_strlower(txt)
    local a1, a2 = zo_strsplit(" ", lower)

    if lower == "status" or lower == "estado" then
      EZOcamsens:PrintStatus()
    elseif lower == "apply" or lower == "aplicar" then
      EZOcamsens:ApplyPresets()
    elseif a1 == "debug" or lower == "dump" or lower == "diag" then
      if a1 == "debug" then
        EZOcamsens:ExecuteDebugCommand(a2)
      elseif lower == "dump" or lower == "diag" then
        EZOcamsens:ExecuteDebugCommand("dump")
      end
    else
      if EZOcamsens.chat and EZOcamsens.sv and EZOcamsens.sv.chatEnabled then
        EZOcamsens.chat:Print(EZOcamsens:Text("CMD_HELP"))
        end
      end
  end
end

EVENT_MANAGER:RegisterForEvent("EZOcamsens_Loaded", EVENT_ADD_ON_LOADED, function(e, n) EZOcamsens:OnLoaded(e, n) end)
