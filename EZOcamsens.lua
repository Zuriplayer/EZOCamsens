local ADDON = {}
EZOcamsens = ADDON

ADDON.name    = "EZOcamsens"
ADDON.version = "1.7.17"
ADDON.savedVarsVersion = 9
ADDON.savedVarsNamespace = "settings"
ADDON.savedVarsMetaNamespace = "meta"

-- Dejo aquí los valores normales del addon para tenerlos a mano.
-- Así es más fácil revisar qué cambiamos y qué dejamos como viene.
local defaults = {
  applyOnlyInGamepad = true,
  debugMode = false,
  tpH = 0.85,
  dynamicEnabled = false,
  dynamicOnlyInCombat = true,
  dynamicOnlyTankRole = false,
  dynamicFastTpH = 5.00,
  dynamicSlowTpH = 1.60,
  dynamicAngleThreshold = 180,
  dynamicIdleResetMs = 300,
  dynamicMovementThreshold = 0.25,
  chatEnabled  = true,
  language = "auto", -- auto, español o inglés
}
ADDON.defaults = defaults

local metaDefaults = {
  settingsScope = "character",
}
ADDON.metaDefaults = metaDefaults

-- Valor que traía el juego en un perfil PTS limpio.
-- Por ahora solo tocamos este ajuste.
local gameDefaults = {
  sensitivity = {
    TP_H = 0.85,
  },
}
ADDON.gameDefaults = gameDefaults

local MANAGED_SV_KEYS = {
  TP_H = "tpH",
}

local SETTINGS_COPY_KEYS = {
  applyOnlyInGamepad = true,
  debugMode = true,
  verbose = true,
  tp = true,
  tpH = true,
  dynamicEnabled = true,
  dynamicOnlyInCombat = true,
  dynamicOnlyTankRole = true,
  dynamicFastTpH = true,
  dynamicSlowTpH = true,
  dynamicAngleThreshold = true,
  dynamicIdleResetMs = true,
  dynamicMovementThreshold = true,
  chatEnabled = true,
  language = true,
}

local function getServerProfile()
  local ok, value = pcall(GetCVar, "LastPlatform")
  if ok and type(value) == "string" and value ~= "" then
    return value
  end

  ok, value = pcall(GetCVar, "SelectedServer")
  if ok and type(value) == "string" and value ~= "" then
    return value
  end

  return "Default"
end

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

local function copySavedSettings(dst, src)
  if type(dst) ~= "table" or type(src) ~= "table" then return end

  for k in pairs(SETTINGS_COPY_KEYS) do
    local v = src[k]
    if v ~= nil then
      dst[k] = v
    end
  end
end

local function normalizeSettingsScope(scope)
  if scope == "account" then
    return "account"
  end
  return "character"
end

function ADDON:LoadSettingsForScope(scope)
  scope = normalizeSettingsScope(scope)
  if scope == "account" then
    return ZO_SavedVars:NewAccountWide("EZOcamsens_SV", self.savedVarsVersion, self.savedVarsNamespace, defaults, self.serverProfile)
  end
  return ZO_SavedVars:NewCharacterIdSettings("EZOcamsens_SV", self.savedVarsVersion, self.savedVarsNamespace, defaults, self.serverProfile)
end

function ADDON:InitSavedVariables()
  local profile = getServerProfile()
  self.serverProfile = profile

  self.meta = ZO_SavedVars:NewAccountWide("EZOcamsens_SV", self.savedVarsVersion, self.savedVarsMetaNamespace, metaDefaults, profile)
  self.settingsScope = normalizeSettingsScope(self.meta.settingsScope)
  self.meta.settingsScope = self.settingsScope

  self.sv = self:LoadSettingsForScope(self.settingsScope)

  if self.sv.migratedLegacySettings ~= true then
    local oldServerAccount = ZO_SavedVars:NewAccountWide("EZOcamsens_SV", self.savedVarsVersion, nil, nil, profile)
    local oldDefaultAccount = ZO_SavedVars:NewAccountWide("EZOcamsens_SV", self.savedVarsVersion, nil, nil)

    copySavedSettings(self.sv, oldDefaultAccount)
    copySavedSettings(self.sv, oldServerAccount)
    self.sv.migratedLegacySettings = true
  end
end

function ADDON:GetSettingsScope()
  return self.settingsScope or "character"
end

function ADDON:SetSettingsScope(scope)
  scope = normalizeSettingsScope(scope)
  if not self.meta then return end
  if scope == self:GetSettingsScope() then return end

  local target = self:LoadSettingsForScope(scope)
  copySavedSettings(target, self.sv)
  target.migratedLegacySettings = true
  self.meta.settingsScope = scope
  self.settingsScope = scope

  if self.PrintUserMessage and self.Text then
    self:PrintUserMessage(self:Text("SCOPE_RELOAD_NOTICE"), { forceChat = true })
  end
  zo_callLater(function() ReloadUI() end, 50)
end

function ADDON:ResetToDefaults()
  if not self.sv then return end
  copyDefaults(self.sv, defaults)
  self.sv.applyFirstPerson = nil
  self.sv.fpH = nil
  self.sv.fp = nil
  self.sv.fpV = nil
  applyManagedGameDefaultsToSavedVars(self.sv)
  if self.chat then self.chat:SetEnabled(self.sv.chatEnabled) end
  if self.InitLocale then self:InitLocale() end
  if self.ApplyPresets then
    self:ApplyPresets({ bypassGamepadGuard = true, suppressFeedback = true })
  end
  if self.PrintUserMessage then
    self:PrintUserMessage(self:Text("DEFAULTS_RESTORED"), { forceChat = true })
  elseif self.chat then
    self.chat:Print(self:Text("DEFAULTS_RESTORED"))
  end
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
  if self.sv.dynamicOnlyTankRole == nil then self.sv.dynamicOnlyTankRole = defaults.dynamicOnlyTankRole end
  if self.sv.dynamicFastTpH == nil then self.sv.dynamicFastTpH = self.sv.tpH or defaults.dynamicFastTpH end
  if self.sv.dynamicSlowTpH == nil then self.sv.dynamicSlowTpH = defaults.dynamicSlowTpH end
  if self.sv.dynamicAngleThreshold == nil then self.sv.dynamicAngleThreshold = defaults.dynamicAngleThreshold end
  if self.sv.dynamicIdleResetMs == nil then self.sv.dynamicIdleResetMs = defaults.dynamicIdleResetMs end
  if self.sv.dynamicMovementThreshold == nil then self.sv.dynamicMovementThreshold = defaults.dynamicMovementThreshold end
  self.sv.tp = nil
  self.sv.applyFirstPerson = nil
  self.sv.fpH = nil
  self.sv.fp = nil
  self.sv.fpV = nil
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

  self:InitSavedVariables()
  self:MigrateSavedVariables()

  self:InitLogger()
  if self.RefreshDebugLoggerState then self:RefreshDebugLoggerState() end
  self:InitChat()
  self:InitLocale()
  if self.RegisterEZOCoreLanguageCallback then self:RegisterEZOCoreLanguageCallback() end
  if self.RegisterWithEZOCore then self:RegisterWithEZOCore() end
  self:SetupMenu()
  if self.RefreshDynamicTurnAssist then self:RefreshDynamicTurnAssist(true) end

  SLASH_COMMANDS["/ezocamsens"] = function(txt)
    txt = zo_strtrim(txt or "")
    local lower = zo_strlower(txt)
    local a1 = zo_strsplit(" ", lower)

    if lower == "" or lower == "help" or lower == "ayuda" or lower == "?" then
      EZOcamsens:ShowCommandHelp()
    elseif lower == "status" or lower == "estado" then
      EZOcamsens:PrintStatus({ forceChat = true })
    elseif lower == "apply" or lower == "aplicar" then
      EZOcamsens:ApplyPresets({ bypassGamepadGuard = true, forceChat = true })
    elseif a1 == "debug" then
      EZOcamsens:ExecuteDebugCommand()
    else
      EZOcamsens:ShowCommandHelp()
    end
  end
end

EVENT_MANAGER:RegisterForEvent("EZOcamsens_Loaded", EVENT_ADD_ON_LOADED, function(e, n) EZOcamsens:OnLoaded(e, n) end)
