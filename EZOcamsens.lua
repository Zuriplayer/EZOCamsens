local ADDON = {}
EZOcamsens = ADDON

ADDON.name    = "EZOcamsens"
ADDON.version = "1.6.2"

-- Ajustes por defecto. Mantengo todo junto para que sea facil revisar cambios
-- de balance sin tener que perseguir valores por varios archivos.
local defaults = {
  applyOnlyInGamepad = true,
  verbose = false,
  capMultiplier = 2.0,
  autoApplyCapsOnLoad = false,
  fpH = 1.20,
  fpV = 1.20,
  tpH = 1.60,
  tpV = 1.60,
  chatEnabled  = true,
  useCVarsFallback = true,
  language = "auto", -- "auto" | "es" | "en"
}
ADDON.defaults = defaults

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
  if self.chat then self.chat:SetEnabled(self.sv.chatEnabled) end
  if self.InitLocale then self:InitLocale() end
  if self.ApplyCaps then self:ApplyCaps() end
  if self.chat and self.sv.chatEnabled then self.chat:Print("|cAFC7E8[EZOcamsens]|r " .. self:Text("DEFAULTS_RESTORED")) end
  self:RefreshLAM()
end

function ADDON:MigrateSavedVariables()
  if not self.sv then return end

  if self.sv.fpH == nil then
    local fp = tonumber(self.sv.fp) or defaults.fpH
    self.sv.fpH = fp
    self.sv.fpV = fp
  end

  if self.sv.tpH == nil then
    local tp = tonumber(self.sv.tp) or defaults.tpH
    self.sv.tpH = tp
    self.sv.tpV = tp
  end
end

function ADDON:OnLoaded(event, addonName)
  if addonName ~= self.name then return end
  EVENT_MANAGER:UnregisterForEvent(self.name .. "_Loaded", EVENT_ADD_ON_LOADED)

  self.sv = ZO_SavedVars:NewAccountWide("EZOcamsens_SV", 9, nil, defaults)
  self:MigrateSavedVariables()

  self:InitLogger()
  self:InitChat()
  self:InitLocale()
  self:DiscoverCameraSliders()
  if self.MaybeApplyCapsOnLoad then self:MaybeApplyCapsOnLoad() end
  self:SetupMenu()

  SLASH_COMMANDS["/ezocamsens"] = function(txt)
    txt = (txt or ""):lower()
    if txt == "status" or txt == "estado" then
      EZOcamsens:PrintStatus()
    elseif txt == "apply" or txt == "aplicar" then
      EZOcamsens:ApplyPresets()
    elseif txt == "dump" or txt == "diag" or txt == "debug" then
      EZOcamsens:DumpCameraDiagnostics()
    elseif txt == "probe" or txt == "sonda" then
      EZOcamsens:ProbeCameraControls()
    else
      if EZOcamsens.chat and EZOcamsens.sv and EZOcamsens.sv.chatEnabled then
        EZOcamsens.chat:Print("|cAFC7E8[EZOcamsens]|r " .. EZOcamsens:Text("CMD_HELP"))
      end
    end
  end
end

EVENT_MANAGER:RegisterForEvent("EZOcamsens_Loaded", EVENT_ADD_ON_LOADED, function(e, n) EZOcamsens:OnLoaded(e, n) end)
