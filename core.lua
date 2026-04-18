local ADDON = EZOcamsens

function ADDON:InitChat()
  local ok, LCM = pcall(function() return LibChatMessage end)
  if ok and LCM then
    self.chat = LCM("EZOcamsens", "EZO")
    self.chat:SetEnabled(self.sv and self.sv.chatEnabled or true)
  end
end

local function info(msg)
  if EZOcamsens and EZOcamsens.chat then
    EZOcamsens.chat:Print("|cAFC7E8[EZOcamsens]|r " .. msg)
  end
end

local function warnRed(msg)
  if EZOcamsens and EZOcamsens.chat then
    EZOcamsens.chat:Print("|cD89B3C[EZOcamsens]|r " .. msg)
  else
    d("|cD89B3C[EZOcamsens]|r " .. msg)
  end
end

function ADDON:InitLogger()
  local ok, LDL = pcall(function() return LibDebugLogger end)
  if ok and LDL then self.logger = LDL(self.name) end
end

local function dbg(fmt, ...)
  if EZOcamsens and EZOcamsens.logger and EZOcamsens.sv and EZOcamsens.sv.verbose then
    EZOcamsens.logger:Debug(string.format(fmt, ...))
  end
end

local STR = {
  es = {
    DESC = "Presets de sensibilidad de camara con mando para primera y tercera persona.",
    AUTHOR = "Por: @Zuriplayer",
    PRESETS_HEADER = "Presets de camara",
    FP_HEADER = "Primera persona",
    TP_HEADER = "Tercera persona",
    FP_H = "Horizontal",
    FP_V = "Vertical",
    TP_H = "Horizontal",
    TP_V = "Vertical",
    APPLY_NOW = "Aplicar presets",
    APPLY_HINT = "Los cambios se aplican al pulsar este boton. EZOcamsens intenta usar primero los controles nativos de gamepad del juego y recurre a las CVars solo como respaldo.",
    BEHAVIOR = "Comportamiento",
    ADVANCED = "Avanzado",
    CAP_SLIDER = "Limite maximo de sensibilidad (mando)",
    CAP_TT = "Amplia el maximo disponible en los controles nativos de mando para permitir sensibilidades mas altas.",
    CAP_AUTO = "Aplicar limite ampliado al cargar",
    CAP_AUTO_TT = "Activalo solo si quieres que el addon ajuste ese limite automaticamente al iniciar.",
    CAP_APPLY_NOW = "Refrescar limite ampliado",
    ONLY_GP = "Aplicar sólo en modo gamepad",
    ONLY_GP_TT = "Evita cambios si no estás jugando con mando.",
    FALLBACK = "Metodo alternativo de aplicacion",
    FALLBACK_TT = "Usa una via alternativa si el ajuste normal no entra bien en tu version del juego.",
    CHAT_MSG = "Mostrar mensajes en chat",
    VERBOSE = "Modo debug",
    VERBOSE_TT = "Guarda trazas tecnicas en LibDebugLogger. Para uso normal, mejor dejarlo apagado.",
    SHOW_STATUS = "Mostrar valores actuales",
    MAINTENANCE = "Idioma y restauracion",
    RESTORE_DEFAULTS = "Restaurar valores por defecto",
    RESTORE_WARN = "Se restaurarán los valores de sensibilidad y opciones.",
    LANG_DD = "Selecciona idioma",
    LANG_AUTO = "Automático (cliente)",
    LANG_ES = "Español",
    LANG_EN = "English",
    CMD_HELP = "uso: /ezocamsens status  |  /ezocamsens apply",
    LANG_NOTICE = "Para aplicar el cambio de idioma se recargará la interfaz.",
    EXTERNAL_DIFF = "Se detectaron valores de sensibilidad distintos a los guardados. Otro addon o el usuario pudo haberlos cambiado.",
    DEFAULTS_RESTORED = "Valores por defecto restaurados.",
    APPLY_DONE = "Presets aplicados.",
    APPLY_FMT = "Aplicado 1ª(H/V)=%s/%s [%s/%s]  3ª(H/V)=%s/%s [%s/%s]",
    APPLY_SUMMARY = "Objetivo 1ª=%s/%s 3ª=%s/%s | Real 1ª=%s/%s 3ª=%s/%s",
    APPLY_METHODS = "Metodo: 1ªH=%s 1ªV=%s 3ªH=%s 3ªV=%s",
    STATUS_SAVED = "Guardado 1ª(H/V)=%s/%s   3ª(H/V)=%s/%s",
    STATUS_REAL = "Actual   1ª(H/V)=%s/%s   3ª(H/V)=%s/%s",
    GAMEPAD_ONLY_WARN = "Accion bloqueada: activa el modo gamepad o desmarca la opcion de aplicar solo en gamepad.",
    METHOD_FALLBACK = "alternativo",
    METHOD_UNCHANGED = "sin cambio",
    BUILD_NO_SLIDERS = "No pude acceder a los controles nativos de sensibilidad en esta version del juego.",
    IDS_FMT = "Claves detectadas: 1ª(H)=%s 1ª(V)=%s 3ª(H)=%s 3ª(V)=%s",
    CAPS_FMT = "Topes aplicados en %d sliders de sensibilidad (max. aprox. %.2f).",
    DUMP_BUTTON = "Volcar diagnostico de camara",
    DUMP_DONE = "Diagnostico de camara enviado a LibDebugLogger.",
    DUMP_NEEDS_DEBUG = "Activa primero el modo debug para generar el diagnostico.",
    PROBE_BUTTON = "Sondear controles de camara",
    PROBE_DONE = "Sondeo de camara enviado al chat.",
  },
  en = {
    DESC = "Controller camera sensitivity presets for first-person and third-person view.",
    AUTHOR = "By: @Zuriplayer",
    PRESETS_HEADER = "Camera presets",
    FP_HEADER = "First-person",
    TP_HEADER = "Third-person",
    FP_H = "Horizontal",
    FP_V = "Vertical",
    TP_H = "Horizontal",
    TP_V = "Vertical",
    APPLY_NOW = "Apply presets",
    APPLY_HINT = "Changes are applied when you press this button. EZOcamsens first tries the native gamepad controls and only falls back to CVars if needed.",
    BEHAVIOR = "Behavior",
    ADVANCED = "Advanced",
    CAP_SLIDER = "Maximum sensitivity limit (gamepad)",
    CAP_TT = "Extends the native gamepad limit so higher sensitivity values are available when needed.",
    CAP_AUTO = "Apply extended limit on load",
    CAP_AUTO_TT = "Enable only if you want the addon to adjust that limit automatically at startup.",
    CAP_APPLY_NOW = "Refresh extended limit",
    ONLY_GP = "Apply only in gamepad mode",
    ONLY_GP_TT = "Prevents changes if you are not playing with a controller.",
    FALLBACK = "Alternative apply method",
    FALLBACK_TT = "Uses an alternative path if the normal in-game adjustment does not work reliably on your build.",
    CHAT_MSG = "Show feedback in chat",
    VERBOSE = "Debug mode",
    VERBOSE_TT = "Stores technical traces in LibDebugLogger. Best left off during normal play.",
    SHOW_STATUS = "Show current values",
    MAINTENANCE = "Language & reset",
    RESTORE_DEFAULTS = "Restore defaults",
    RESTORE_WARN = "Sensitivity and options will be restored.",
    LANG_DD = "Select language",
    LANG_AUTO = "Automatic (client)",
    LANG_ES = "Spanish",
    LANG_EN = "English",
    CMD_HELP = "usage: /ezocamsens status  |  /ezocamsens apply",
    LANG_NOTICE = "The UI will reload to apply the language change.",
    EXTERNAL_DIFF = "Sensitivity values differ from saved presets. Another addon or the user may have changed them.",
    DEFAULTS_RESTORED = "Default values restored.",
    APPLY_DONE = "Presets applied.",
    APPLY_FMT = "Applied 1st(H/V)=%s/%s [%s/%s]  3rd(H/V)=%s/%s [%s/%s]",
    APPLY_SUMMARY = "Target 1st=%s/%s 3rd=%s/%s | Actual 1st=%s/%s 3rd=%s/%s",
    APPLY_METHODS = "Method: 1stH=%s 1stV=%s 3rdH=%s 3rdV=%s",
    STATUS_SAVED = "Saved   1st(H/V)=%s/%s   3rd(H/V)=%s/%s",
    STATUS_REAL = "Current 1st(H/V)=%s/%s   3rd(H/V)=%s/%s",
    GAMEPAD_ONLY_WARN = "Action blocked: enable gamepad mode or disable the gamepad-only option.",
    METHOD_FALLBACK = "fallback",
    METHOD_UNCHANGED = "unchanged",
    BUILD_NO_SLIDERS = "Native sensitivity controls are not available in this game build.",
    IDS_FMT = "Detected keys: 1st(H)=%s 1st(V)=%s 3rd(H)=%s 3rd(V)=%s",
    CAPS_FMT = "Applied caps to %d sensitivity sliders (approx. max %.2f).",
    DUMP_BUTTON = "Dump camera diagnostics",
    DUMP_DONE = "Camera diagnostics sent to LibDebugLogger.",
    DUMP_NEEDS_DEBUG = "Enable debug mode first to generate diagnostics.",
    PROBE_BUTTON = "Probe camera controls",
    PROBE_DONE = "Camera probe sent to chat.",
  }
}

function ADDON:InitLocale()
  local sel = (self.sv and self.sv.language) or "auto"
  local lang = "en"
  if sel == "auto" then
    local ok, v = pcall(GetCVar, "Language.2")
    if ok and type(v) == "string" then
      v = string.lower(v)
      if string.sub(v, 1, 2) == "es" then lang = "es" end
    end
  elseif sel == "es" then
    lang = "es"
  end
  self.lang = lang
  self.str = STR[lang] or STR.en
end

function ADDON:Text(key)
  return (self.str and self.str[key]) or (STR.en[key]) or key
end

function ADDON:RefreshLAM()
  if self.lamPanel then
    CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", self.lamPanel)
  end
end

local function isGamepad()
  local ok, res = pcall(IsInGamepadPreferredMode)
  if ok then return res end
  return false
end

local function guardGamepad()
  return not (ADDON.sv and ADDON.sv.applyOnlyInGamepad and not isGamepad())
end

ADDON.ids = { FP_H = nil, FP_V = nil, TP_H = nil, TP_V = nil }

local function tolowerLocal(s)
  if type(s) == "number" then s = GetString(s) end
  if type(s) ~= "string" then return "" end
  return zo_strlower(zo_strformat("<<Z:1>>", s))
end

function ADDON:DiscoverCameraSliders()
  local CCD = ZO_OptionsPanel_Camera_ControlData
  if not (CCD and CCD[SETTING_TYPE_GAMEPAD]) then
    warnRed(self:Text("BUILD_NO_SLIDERS"))
    return
  end

  for id, data in pairs(CCD[SETTING_TYPE_GAMEPAD]) do
    if type(data) == "table" and data.controlType == OPTIONS_SLIDER then
      local name = tolowerLocal(data.name or data.text)
      if name ~= "" then
        if (name:find("first") or name:find("primera")) then
          if name:find("horizontal") then ADDON.ids.FP_H = id end
          if name:find("vertical") then ADDON.ids.FP_V = id end
        elseif (name:find("third") or name:find("tercera")) then
          if name:find("horizontal") then ADDON.ids.TP_H = id end
          if name:find("vertical") then ADDON.ids.TP_V = id end
        end
      end
    end
  end

  dbg(self:Text("IDS_FMT"),
    tostring(self.ids.FP_H or "n/a"),
    tostring(self.ids.FP_V or "n/a"),
    tostring(self.ids.TP_H or "n/a"),
    tostring(self.ids.TP_V or "n/a"))
end

local function setMax(controlData, newMax)
  if controlData then
    controlData.maxValue = newMax
    controlData.valueFormat = "%.2f"
    if ZO_Options_UpdateOption then ZO_Options_UpdateOption(controlData) end
    return true
  end
  return false
end

function ADDON:ApplyCaps()
  local CCD = ZO_OptionsPanel_Camera_ControlData
  if not (CCD and CCD[SETTING_TYPE_GAMEPAD]) then return end

  local mult = tonumber(self.sv and self.sv.capMultiplier) or 1.0
  local base = 1.60
  local newMax = base * mult

  local raised = 0
  local list = CCD[SETTING_TYPE_GAMEPAD]
  for _, key in ipairs({ self.ids.FP_H, self.ids.FP_V, self.ids.TP_H, self.ids.TP_V }) do
    if key and setMax(list[key], newMax) then raised = raised + 1 end
  end

  dbg(self:Text("CAPS_FMT"), raised, newMax)
  self:RefreshLAM()
end

function ADDON:MaybeApplyCapsOnLoad()
  if self.sv and self.sv.autoApplyCapsOnLoad then
    self:ApplyCaps()
  end
end

local CVAR = {
  FP_H = "GamepadSensitivityFirstPersonX",
  FP_V = "GamepadSensitivityFirstPersonY",
  TP_H = "GamepadSensitivityThirdPersonX",
  TP_V = "GamepadSensitivityThirdPersonY",
}

local function safeSet(settingType, id, value)
  if id then
    local ok = pcall(SetSetting, settingType, id, value)
    if ok then return true end
  end
  return false
end

local function safeGet(settingType, id)
  if id then
    local ok, v = pcall(GetSetting, settingType, id)
    if ok and v and v ~= "" then return v end
  end
  return nil
end

local function getCVarValue(name)
  local ok, v = pcall(GetCVar, name)
  if ok then return v end
  return nil
end

local function setCVarValue(name, value)
  local ok = pcall(SetCVar, name, value)
  return ok
end

local function clamp(v)
  v = tonumber(v) or 1.00
  if v < 0.10 then v = 0.10 end
  return v
end

local function buildTargetValues()
  return {
    FP_H = string.format("%.2f", clamp(ADDON.sv.fpH)),
    FP_V = string.format("%.2f", clamp(ADDON.sv.fpV)),
    TP_H = string.format("%.2f", clamp(ADDON.sv.tpH)),
    TP_V = string.format("%.2f", clamp(ADDON.sv.tpV)),
  }
end

local function readCurrentValue(cvarName)
  return getCVarValue(cvarName) or "n/a"
end

function ADDON:ApplyPresets()
  if not guardGamepad() then
    warnRed(self:Text("GAMEPAD_ONLY_WARN"))
    return
  end

  local targets = buildTargetValues()

  local ok
  ok = safeSet(SETTING_TYPE_GAMEPAD, self.ids.FP_H, targets.FP_H)
  if (not ok) and self.sv.useCVarsFallback then setCVarValue(CVAR.FP_H, targets.FP_H) end

  ok = safeSet(SETTING_TYPE_GAMEPAD, self.ids.FP_V, targets.FP_V)
  if (not ok) and self.sv.useCVarsFallback then setCVarValue(CVAR.FP_V, targets.FP_V) end

  ok = safeSet(SETTING_TYPE_GAMEPAD, self.ids.TP_H, targets.TP_H)
  if (not ok) and self.sv.useCVarsFallback then setCVarValue(CVAR.TP_H, targets.TP_H) end

  ok = safeSet(SETTING_TYPE_GAMEPAD, self.ids.TP_V, targets.TP_V)
  if (not ok) and self.sv.useCVarsFallback then setCVarValue(CVAR.TP_V, targets.TP_V) end

  local r1 = safeGet(SETTING_TYPE_GAMEPAD, self.ids.FP_H) or readCurrentValue(CVAR.FP_H)
  local r2 = safeGet(SETTING_TYPE_GAMEPAD, self.ids.FP_V) or readCurrentValue(CVAR.FP_V)
  local r3 = safeGet(SETTING_TYPE_GAMEPAD, self.ids.TP_H) or readCurrentValue(CVAR.TP_H)
  local r4 = safeGet(SETTING_TYPE_GAMEPAD, self.ids.TP_V) or readCurrentValue(CVAR.TP_V)

  dbg(self:Text("APPLY_FMT"),
    targets.FP_H, targets.FP_V, tostring(r1), tostring(r2),
    targets.TP_H, targets.TP_V, tostring(r3), tostring(r4))

  info(self:Text("APPLY_DONE"))
  info(string.format(self:Text("APPLY_SUMMARY"),
    targets.FP_H, targets.FP_V, targets.TP_H, targets.TP_V,
    tostring(r1), tostring(r2), tostring(r3), tostring(r4)))
end

function ADDON:PrintStatus()
  local fpH = safeGet(SETTING_TYPE_GAMEPAD, self.ids.FP_H) or readCurrentValue(CVAR.FP_H)
  local fpV = safeGet(SETTING_TYPE_GAMEPAD, self.ids.FP_V) or readCurrentValue(CVAR.FP_V)
  local tpH = safeGet(SETTING_TYPE_GAMEPAD, self.ids.TP_H) or readCurrentValue(CVAR.TP_H)
  local tpV = safeGet(SETTING_TYPE_GAMEPAD, self.ids.TP_V) or readCurrentValue(CVAR.TP_V)

  info(string.format(self:Text("STATUS_SAVED"),
    string.format("%.2f", clamp(self.sv.fpH)),
    string.format("%.2f", clamp(self.sv.fpV)),
    string.format("%.2f", clamp(self.sv.tpH)),
    string.format("%.2f", clamp(self.sv.tpV))))
  info(string.format(self:Text("STATUS_REAL"), tostring(fpH), tostring(fpV), tostring(tpH), tostring(tpV)))
end

local function describeValue(value)
  local valueType = type(value)
  if valueType == "number" then
    local ok, str = pcall(GetString, value)
    if ok and type(str) == "string" and str ~= "" then
      return string.format("%s (%s)", tostring(value), str)
    end
  elseif valueType == "string" then
    return value
  elseif value == nil then
    return "nil"
  end
  return tostring(value)
end

local function containsCameraHint(text)
  if type(text) ~= "string" then return false end
  local lower = zo_strlower(text)
  return lower:find("sensitivity", 1, true)
      or lower:find("look speed", 1, true)
      or lower:find("horizontal", 1, true)
      or lower:find("vertical", 1, true)
      or lower:find("first", 1, true)
      or lower:find("third", 1, true)
      or lower:find("primera", 1, true)
      or lower:find("tercera", 1, true)
end

local function dumpControlGroup(label, settingType)
  local data = ZO_OptionsPanel_Camera_ControlData
  if not (data and data[settingType]) then
    dbg("[%s] no data for settingType=%s", label, tostring(settingType))
    return
  end

  dbg("==== %s settingType=%s ====", label, tostring(settingType))
  for id, entry in pairs(data[settingType]) do
    if type(entry) == "table" then
      dbg(
        "id=%s controlType=%s system=%s settingId=%s panel=%s text=%s name=%s gamepadTextOverride=%s tooltip=%s min=%s max=%s format=%s",
        tostring(id),
        tostring(entry.controlType),
        tostring(entry.system),
        tostring(entry.settingId),
        tostring(entry.panel),
        describeValue(entry.text),
        describeValue(entry.name),
        describeValue(entry.gamepadTextOverride),
        describeValue(entry.tooltipText),
        tostring(entry.minValue),
        tostring(entry.maxValue),
        tostring(entry.valueFormat)
      )
    else
      dbg("id=%s entry=%s", tostring(id), tostring(entry))
    end
  end
end

function ADDON:DumpCameraDiagnostics()
  if not (self.sv and self.sv.verbose and self.logger) then
    warnRed(self:Text("DUMP_NEEDS_DEBUG"))
    return
  end

  dbg("==== EZOcamsens camera diagnostic dump start ====")
  dbg("Detected keys FP_H=%s FP_V=%s TP_H=%s TP_V=%s",
    tostring(self.ids.FP_H), tostring(self.ids.FP_V), tostring(self.ids.TP_H), tostring(self.ids.TP_V))
  dbg("Current readback FP_H=%s FP_V=%s TP_H=%s TP_V=%s",
    tostring(readCurrentValue(self.ids.FP_H)), tostring(readCurrentValue(self.ids.FP_V)),
    tostring(readCurrentValue(self.ids.TP_H)), tostring(readCurrentValue(self.ids.TP_V)))
  dumpControlGroup("CAMERA", SETTING_TYPE_CAMERA)
  if SETTING_TYPE_GAMEPAD then
    dumpControlGroup("GAMEPAD", SETTING_TYPE_GAMEPAD)
  end
  dbg("==== EZOcamsens camera diagnostic dump end ====")
  info(self:Text("DUMP_DONE"))
end

function ADDON:ProbeCameraControls()
  local data = ZO_OptionsPanel_Camera_ControlData
  if not data then
    warnRed(self:Text("BUILD_NO_SLIDERS"))
    return
  end

  local function emitGroup(label, settingType)
    if not data[settingType] then
      info(string.format("[Probe] %s: no data", label))
      return
    end

    info(string.format("[Probe] %s", label))
    for id, entry in pairs(data[settingType]) do
      if type(entry) == "table" then
        local text = describeValue(entry.text)
        local name = describeValue(entry.name)
        local override = describeValue(entry.gamepadTextOverride)
        local tooltip = describeValue(entry.tooltipText)
        if containsCameraHint(text) or containsCameraHint(name) or containsCameraHint(override) or containsCameraHint(tooltip) then
          info(string.format(
            "id=%s sys=%s settingId=%s type=%s text=%s name=%s override=%s tooltip=%s",
            tostring(id),
            tostring(entry.system),
            tostring(entry.settingId),
            tostring(entry.controlType),
            text,
            name,
            override,
            tooltip
          ))
        end
      end
    end
  end

  emitGroup("CAMERA", SETTING_TYPE_CAMERA)
  if SETTING_TYPE_GAMEPAD then
    emitGroup("GAMEPAD", SETTING_TYPE_GAMEPAD)
  end
  info(self:Text("PROBE_DONE"))
end
