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
    EZOcamsens.chat:Print(tostring(msg))
  else
    d("|cAFC7E8[EZOcamsens]|r " .. tostring(msg))
  end
end

local function warnRed(msg)
  if EZOcamsens and EZOcamsens.chat then
    EZOcamsens.chat:Print("|cD89B3C" .. tostring(msg) .. "|r")
  else
    d("|cD89B3C[EZOcamsens]|r " .. tostring(msg))
  end
end

function ADDON:InitLogger()
  self:InitializeDebug()
end

function ADDON:EnsureDebugLogger()
  self.runtime = self.runtime or {}
  if self.runtime.debugLogger then
    self.logger = self.runtime.debugLogger
    return self.runtime.debugLogger
  end

  local ok, logger = pcall(function()
    if not LibDebugLogger then
      return nil
    end

    local created = LibDebugLogger(self.name)
    if created and type(created.SetMinLevelOverride) == "function" and LibDebugLogger.LOG_LEVEL_DEBUG ~= nil then
      created:SetMinLevelOverride(LibDebugLogger.LOG_LEVEL_DEBUG)
    end
    if created and type(created.SetLogTracesOverride) == "function" then
      created:SetLogTracesOverride(false)
    end
    return created
  end)

  if ok and logger then
    self.runtime.debugLogger = logger
    self.logger = logger
    return logger
  end

  return nil
end

function ADDON:InitializeDebug()
  self.runtime = self.runtime or {}
  self:EnsureDebugLogger()
end

function ADDON:RefreshDebugLoggerState()
  local logger = self:EnsureDebugLogger()
  if not logger then return end
  if logger.SetEnabled then
    logger:SetEnabled(true)
  end
end

local function isDebugEnabled()
  return EZOcamsens and EZOcamsens.IsDebugModeEnabled and EZOcamsens:IsDebugModeEnabled()
end

local function dbg(fmt, ...)
  if EZOcamsens and isDebugEnabled() then
    local logger = EZOcamsens:EnsureDebugLogger()
    if logger and logger.Debug then
      logger:Debug(string.format(fmt, ...))
    end
  end
end

function ADDON:SafeDebugViewer(msg, subTag)
  local logger = self:EnsureDebugLogger()
  if not logger then
    return false
  end

  local ok = pcall(function()
    if type(logger.SetSubTag) == "function" then
      logger:SetSubTag(subTag)
    end

    if type(logger.Debug) == "function" then
      logger:Debug(tostring(msg))
    elseif type(logger.Info) == "function" then
      logger:Info(tostring(msg))
    else
      error("LibDebugLogger logger has no Debug/Info method")
    end

    if type(logger.SetSubTag) == "function" then
      logger:SetSubTag(nil)
    end
  end)

  return ok
end

function ADDON:DebugPrint(msg, subTag)
  if isDebugEnabled() then
    self:SafeDebugViewer(msg, subTag or "Debug")
  end
end

function ADDON:CreateDebugBatch(subTag)
  return {
    subTag = subTag or "Debug",
    lines = {},
  }
end

function ADDON:DebugBatchAdd(batch, msg)
  if type(batch) ~= "table" then
    self:DebugPrint(msg, "Debug")
    return
  end

  msg = tostring(msg)
  batch.lines[#batch.lines + 1] = msg
end

function ADDON:DebugBatchFlush(batch)
  if not isDebugEnabled() then return end
  if type(batch) ~= "table" or type(batch.lines) ~= "table" or #batch.lines == 0 then
    return
  end

  self:SafeDebugViewer(table.concat(batch.lines, "\n"), batch.subTag or "Debug")
end

local STR = {
  es = {
    DESC = "Controla la sensibilidad horizontal de camara con mando en tercera persona.",
    AUTHOR = "Por: @Zuriplayer",
    PRESETS_HEADER = "Tercera persona horizontal",
    TP_HEADER = "Tercera persona",
    TP_H = "Sensibilidad horizontal",
    APPLY_NOW = "Aplicar ajuste",
    APPLY_HINT = "Mueve el valor para aplicarlo. El boton Aplicar ajuste fuerza de nuevo el valor guardado. El addon intenta usar primero el control nativo del juego y recurre a la CVar solo si hace falta.",
    DYNAMIC_HEADER = "Giro dinamico experimental",
    DYNAMIC_ENABLED = "Activar giro dinamico",
    DYNAMIC_ENABLED_TT = "Aplica una sensibilidad rapida al empezar el giro y cambia a sensibilidad lenta tras superar el angulo configurado.",
    DYNAMIC_ONLY_COMBAT = "Aplicar solo en combate",
    DYNAMIC_ONLY_COMBAT_TT = "Si esta activo, el giro dinamico espera a que entres en combate y restaura el ajuste normal al salir.",
    DYNAMIC_FAST = "Sensibilidad rapida",
    DYNAMIC_SLOW = "Sensibilidad lenta",
    DYNAMIC_ANGLE = "Angulo para cambiar a lento",
    DYNAMIC_IDLE = "Reposo para reiniciar (ms)",
    DYNAMIC_MOVEMENT = "Movimiento minimo por muestra",
    BEHAVIOR = "Comportamiento",
    ONLY_GP = "Aplicar sólo en modo gamepad",
    ONLY_GP_TT = "Evita cambios si no estás jugando con mando.",
    CHAT_MSG = "Mostrar mensajes en chat",
    SUPPORT = "Soporte y debug",
    DEBUG_MODE = "Activar modo debug",
    DEBUG_MODE_TT = "Habilita de forma persistente las funciones de debug del addon y envía trazas de nivel debug a LibDebugLogger para verlas en DebugLogViewer.",
    SHOW_STATUS = "Mostrar valores actuales",
    MAINTENANCE = "Idioma y restauracion",
    RESTORE_DEFAULTS = "Restaurar valores por defecto",
    RESTORE_WARN = "Se restaurará la sensibilidad horizontal de tercera persona al valor por defecto del juego y también las opciones del addon.",
    LANG_DD = "Selecciona idioma",
    LANG_AUTO = "Automático (cliente)",
    LANG_ES = "Español",
    LANG_EN = "English",
    CMD_HELP = "uso: /ezocamsens status || /ezocamsens apply || /ezocamsens debug [dump||heading||turnstart||turnstop||turnreport]",
    LANG_NOTICE = "Para aplicar el cambio de idioma se recargará la interfaz.",
    DEBUG_MODE_DISABLED = "El modo debug está desactivado. Actívalo en la configuración del addon para usar /ezocamsens debug.",
    DEBUG_TITLE = "Comandos de diagnóstico:",
    DEBUG_CMD_DUMP = "  /ezocamsens debug dump        - volcado técnico de cámara a DebugLogViewer",
    DEBUG_CMD_HEADING = "  /ezocamsens debug heading     - muestra el heading horizontal actual de la cámara",
    DEBUG_CMD_TURNSTART = "  /ezocamsens debug turnstart   - inicia la medición de giro horizontal",
    DEBUG_CMD_TURNSTOP = "  /ezocamsens debug turnstop    - detiene la medición y muestra el resumen",
    DEBUG_CMD_TURNREPORT = "  /ezocamsens debug turnreport  - muestra el último resumen de giro",
    EXTERNAL_DIFF = "Se detectaron valores de sensibilidad distintos a los guardados. Otro addon o el usuario pudo haberlos cambiado.",
    DEFAULTS_RESTORED = "Sensibilidad horizontal de tercera persona restaurada al valor por defecto del juego.",
    APPLY_DONE = "Ajuste aplicado.",
    APPLY_FMT = "Aplicado 3ª horizontal=%s [%s]",
    APPLY_SUMMARY = "Objetivo 3ª horizontal=%s | Real=%s",
    APPLY_METHODS = "Metodo 3ª horizontal=%s",
    APPLY_SOURCE = "Fuente de lectura 3ª horizontal=%s",
    CLAMP_WARN = "Algunos objetivos se ajustaron al maximo disponible en el juego: %s",
    STATUS_SAVED = "Guardado 3ª horizontal=%s",
    STATUS_REAL = "Actual   3ª horizontal=%s",
    STATUS_NATIVE = "Nativo   3ª horizontal=%s",
    STATUS_CVAR = "CVar     3ª horizontal=%s",
    STATUS_SOURCE = "Fuente efectiva 3ª horizontal=%s",
    STATUS_DIVERGED = "El valor nativo y la CVar no coinciden; el juego o la UI pueden estar usando rutas distintas.",
    GAMEPAD_ONLY_WARN = "Accion bloqueada: activa el modo gamepad o desmarca la opcion de aplicar solo en gamepad.",
    METHOD_NATIVE = "nativo",
    METHOD_FALLBACK = "alternativo",
    METHOD_UNCHANGED = "sin cambio",
    SOURCE_SETTING = "setting",
    SOURCE_CVAR = "cvar",
    SOURCE_NONE = "sin fuente",
    NATIVE_ID_MISSING = "No se detecto el control nativo de 3ª horizontal; se intentará aplicar por CVar.",
    NATIVE_ID_FALLBACK_INFO = "No se detectó el control nativo de 3ª horizontal. Se ha aplicado la CVar como respaldo.",
    BUILD_NO_SLIDERS = "No pude acceder a los controles nativos de sensibilidad en esta version del juego.",
    IDS_FMT = "Clave detectada: 3ª(H)=%s",
    DUMP_BUTTON = "Volcar diagnostico de camara",
    DUMP_NEEDS_DEBUG = "Activa primero el modo debug para generar el diagnostico.",
    HEADING_UNAVAILABLE = "No se pudo leer el heading actual de la cámara en esta sesión.",
    HEADING_NOW = "Heading horizontal actual=%.2f grados",
    TURN_START = "Medición de giro iniciada en %.2f grados.",
    TURN_RUNNING = "Ya hay una medición de giro en marcha.",
    TURN_IDLE = "No hay una medición de giro activa.",
    TURN_NO_DATA = "Todavía no hay una medición de giro disponible.",
    TURN_STOP = "Medición de giro detenida.",
    TURN_REPORT = "Giro horizontal: inicio=%.2f actual=%.2f directo=%.2f acumulado=%.2f abs=%.2f tiempo=%.3fs velocidadMedia=%.2f grados/s muestras=%d",
    DYNAMIC_STARTED = "Giro dinamico iniciado: rapido=%.2f lento=%.2f angulo=%.2f",
    DYNAMIC_STOPPED = "Giro dinamico detenido.",
    DYNAMIC_FAST_APPLIED = "Giro dinamico: sensibilidad rapida aplicada %.2f (%s)",
    DYNAMIC_SLOW_APPLIED = "Giro dinamico: sensibilidad lenta aplicada %.2f tras %.2f grados (%s)",
    DYNAMIC_RESET = "Giro dinamico: reposo detectado, reinicio a rapido.",
    DYNAMIC_READBACK = "Lectura dinamica: actual=%s metodo=%s",
    DYNAMIC_REASON_START = "inicio",
    DYNAMIC_REASON_COMBAT = "combate",
    DYNAMIC_REASON_IDLE = "reposo",
    DYNAMIC_REASON_ANGLE = "angulo",
  },
  en = {
    DESC = "Controls third-person horizontal camera sensitivity for controller play.",
    AUTHOR = "By: @Zuriplayer",
    PRESETS_HEADER = "Third-person horizontal",
    TP_HEADER = "Third-person",
    TP_H = "Horizontal sensitivity",
    APPLY_NOW = "Apply setting",
    APPLY_HINT = "Move the value to apply it. The Apply setting button forces the saved value again. The addon first tries the native in-game control and only falls back to the CVar if needed.",
    DYNAMIC_HEADER = "Experimental dynamic turn",
    DYNAMIC_ENABLED = "Enable dynamic turn",
    DYNAMIC_ENABLED_TT = "Applies fast sensitivity when turning starts and switches to slow sensitivity after the configured angle.",
    DYNAMIC_ONLY_COMBAT = "Apply only in combat",
    DYNAMIC_ONLY_COMBAT_TT = "When enabled, dynamic turn waits until combat starts and restores the normal setting after combat ends.",
    DYNAMIC_FAST = "Fast sensitivity",
    DYNAMIC_SLOW = "Slow sensitivity",
    DYNAMIC_ANGLE = "Angle before slow mode",
    DYNAMIC_IDLE = "Idle reset (ms)",
    DYNAMIC_MOVEMENT = "Minimum movement per sample",
    BEHAVIOR = "Behavior",
    ONLY_GP = "Apply only in gamepad mode",
    ONLY_GP_TT = "Prevents changes if you are not playing with a controller.",
    CHAT_MSG = "Show feedback in chat",
    SUPPORT = "Support & debug",
    DEBUG_MODE = "Enable debug mode",
    DEBUG_MODE_TT = "Persistently enables the addon's debug features and sends debug-level traces to LibDebugLogger so they are visible in DebugLogViewer.",
    SHOW_STATUS = "Show current values",
    MAINTENANCE = "Language & reset",
    RESTORE_DEFAULTS = "Restore defaults",
    RESTORE_WARN = "Third-person horizontal sensitivity will be restored to the game's default value, along with the addon options.",
    LANG_DD = "Select language",
    LANG_AUTO = "Automatic (client)",
    LANG_ES = "Spanish",
    LANG_EN = "English",
    CMD_HELP = "usage: /ezocamsens status || /ezocamsens apply || /ezocamsens debug [dump||heading||turnstart||turnstop||turnreport]",
    LANG_NOTICE = "The UI will reload to apply the language change.",
    DEBUG_MODE_DISABLED = "Debug mode is disabled. Enable it in the addon settings to use /ezocamsens debug.",
    DEBUG_TITLE = "Diagnostic commands:",
    DEBUG_CMD_DUMP = "  /ezocamsens debug dump        - camera technical dump to DebugLogViewer",
    DEBUG_CMD_HEADING = "  /ezocamsens debug heading     - show the current horizontal camera heading",
    DEBUG_CMD_TURNSTART = "  /ezocamsens debug turnstart   - start horizontal turn measurement",
    DEBUG_CMD_TURNSTOP = "  /ezocamsens debug turnstop    - stop measurement and show the summary",
    DEBUG_CMD_TURNREPORT = "  /ezocamsens debug turnreport  - show the latest turn summary",
    EXTERNAL_DIFF = "Sensitivity values differ from saved presets. Another addon or the user may have changed them.",
    DEFAULTS_RESTORED = "Third-person horizontal sensitivity restored to the game's default value.",
    APPLY_DONE = "Setting applied.",
    APPLY_FMT = "Applied 3rd horizontal=%s [%s]",
    APPLY_SUMMARY = "Target 3rd horizontal=%s | Actual=%s",
    APPLY_METHODS = "Method 3rd horizontal=%s",
    APPLY_SOURCE = "Readback source 3rd horizontal=%s",
    CLAMP_WARN = "Some targets were limited to the current in-game maximum: %s",
    STATUS_SAVED = "Saved   3rd horizontal=%s",
    STATUS_REAL = "Current 3rd horizontal=%s",
    STATUS_NATIVE = "Native  3rd horizontal=%s",
    STATUS_CVAR = "CVar    3rd horizontal=%s",
    STATUS_SOURCE = "Effective source 3rd horizontal=%s",
    STATUS_DIVERGED = "The native setting and the CVar differ; the game or UI may be using different paths.",
    GAMEPAD_ONLY_WARN = "Action blocked: enable gamepad mode or disable the gamepad-only option.",
    METHOD_NATIVE = "native",
    METHOD_FALLBACK = "fallback",
    METHOD_UNCHANGED = "unchanged",
    SOURCE_SETTING = "setting",
    SOURCE_CVAR = "cvar",
    SOURCE_NONE = "no source",
    NATIVE_ID_MISSING = "The native 3rd-person horizontal control was not detected; the addon will try to apply via CVar.",
    NATIVE_ID_FALLBACK_INFO = "The native 3rd-person horizontal control was not detected. The CVar fallback was applied.",
    BUILD_NO_SLIDERS = "Native sensitivity controls are not available in this game build.",
    IDS_FMT = "Detected key: 3rd(H)=%s",
    DUMP_BUTTON = "Dump camera diagnostics",
    DUMP_NEEDS_DEBUG = "Enable debug mode first to generate diagnostics.",
    HEADING_UNAVAILABLE = "Could not read the current camera heading in this session.",
    HEADING_NOW = "Current horizontal heading=%.2f degrees",
    TURN_START = "Turn measurement started at %.2f degrees.",
    TURN_RUNNING = "A turn measurement is already running.",
    TURN_IDLE = "There is no active turn measurement.",
    TURN_NO_DATA = "There is no turn measurement data yet.",
    TURN_STOP = "Turn measurement stopped.",
    TURN_REPORT = "Horizontal turn: start=%.2f current=%.2f direct=%.2f accumulated=%.2f abs=%.2f time=%.3fs avgSpeed=%.2f deg/s samples=%d",
    DYNAMIC_STARTED = "Dynamic turn started: fast=%.2f slow=%.2f angle=%.2f",
    DYNAMIC_STOPPED = "Dynamic turn stopped.",
    DYNAMIC_FAST_APPLIED = "Dynamic turn: fast sensitivity applied %.2f (%s)",
    DYNAMIC_SLOW_APPLIED = "Dynamic turn: slow sensitivity applied %.2f after %.2f degrees (%s)",
    DYNAMIC_RESET = "Dynamic turn: idle detected, reset to fast.",
    DYNAMIC_READBACK = "Dynamic readback: actual=%s method=%s",
    DYNAMIC_REASON_START = "start",
    DYNAMIC_REASON_COMBAT = "combat",
    DYNAMIC_REASON_IDLE = "idle",
    DYNAMIC_REASON_ANGLE = "angle",
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

function ADDON:ShowDebugCommandHelp()
  local batch = self:CreateDebugBatch("DebugHelp")
  self:DebugBatchAdd(batch, self:Text("DEBUG_TITLE"))
  self:DebugBatchAdd(batch, self:Text("DEBUG_CMD_DUMP"))
  self:DebugBatchAdd(batch, self:Text("DEBUG_CMD_HEADING"))
  self:DebugBatchAdd(batch, self:Text("DEBUG_CMD_TURNSTART"))
  self:DebugBatchAdd(batch, self:Text("DEBUG_CMD_TURNSTOP"))
  self:DebugBatchAdd(batch, self:Text("DEBUG_CMD_TURNREPORT"))
  self:DebugBatchFlush(batch)
end

function ADDON:ExecuteDebugCommand(sub)
  if not isDebugEnabled() then
    warnRed(self:Text("DEBUG_MODE_DISABLED"))
    return true
  end

  sub = zo_strlower(sub or "")
  if sub == "" or sub == "help" or sub == "?" then
    self:ShowDebugCommandHelp()
    return true
  end

  if sub == "dump" or sub == "diag" then
    self:DumpCameraDiagnostics()
    return true
  end
  if sub == "heading" then
    self:PrintCurrentCameraHeading()
    return true
  end
  if sub == "turnstart" then
    self:StartTurnMeasurement()
    return true
  end
  if sub == "turnstop" then
    self:StopTurnMeasurement()
    return true
  end
  if sub == "turnreport" then
    self:PrintTurnMeasurementReport()
    return true
  end
  self:ShowDebugCommandHelp()
  return true
end

local function isGamepad()
  local ok, res = pcall(IsInGamepadPreferredMode)
  if ok then return res end
  return false
end

local function guardGamepad()
  return not (ADDON.sv and ADDON.sv.applyOnlyInGamepad and not isGamepad())
end

ADDON.ids = { TP_H = nil }
local TARGET_MIN = 0.10
local TARGET_MAX = 5.00
local NATIVE_RANGE_MAX = 5.00

local function tolowerLocal(s)
  if type(s) == "number" then s = GetString(s) end
  if type(s) ~= "string" then return "" end
  return zo_strlower(zo_strformat("<<Z:1>>", s))
end

local function buildSearchText(entry)
  if type(entry) ~= "table" then return "" end
  local parts = {
    tolowerLocal(entry.name),
    tolowerLocal(entry.text),
    tolowerLocal(entry.gamepadTextOverride),
    tolowerLocal(entry.tooltipText),
  }
  return table.concat(parts, " ")
end

local function isThirdHorizontalCameraSlider(entry)
  if type(entry) ~= "table" or entry.controlType ~= OPTIONS_SLIDER then
    return false
  end

  local text = buildSearchText(entry)
  if text == "" then return false end
  return (text:find("third", 1, true) or text:find("tercera", 1, true))
     and text:find("horizontal", 1, true)
end

function ADDON:DiscoverCameraSliders()
  local CCD = ZO_OptionsPanel_Camera_ControlData
  if not (CCD and CCD[SETTING_TYPE_GAMEPAD]) then
    warnRed(self:Text("BUILD_NO_SLIDERS"))
    return
  end

  for id, data in pairs(CCD[SETTING_TYPE_GAMEPAD]) do
    if isThirdHorizontalCameraSlider(data) then
      ADDON.ids.TP_H = id
      break
    end
  end

  dbg(self:Text("IDS_FMT"), tostring(self.ids.TP_H or "n/a"))
  self:EnsureNativeSliderRange()
end

function ADDON:EnsureNativeSliderRange()
  local CCD = ZO_OptionsPanel_Camera_ControlData
  local list = CCD and CCD[SETTING_TYPE_GAMEPAD]
  local entry = list and self.ids.TP_H and list[self.ids.TP_H]
  if type(entry) ~= "table" then
    return false
  end

  local changed = false
  local currentMin = tonumber(entry.minValue) or TARGET_MIN
  local currentMax = tonumber(entry.maxValue) or NATIVE_RANGE_MAX
  if currentMin ~= TARGET_MIN then
    entry.minValue = TARGET_MIN
    changed = true
  end
  if currentMax < NATIVE_RANGE_MAX then
    entry.maxValue = NATIVE_RANGE_MAX
    changed = true
  end
  if entry.valueFormat ~= "%.2f" then
    entry.valueFormat = "%.2f"
    changed = true
  end
  if changed and ZO_Options_UpdateOption then
    ZO_Options_UpdateOption(entry)
  end
  return changed
end

local CVAR = {
  TP_H = "GamepadSensitivityThirdPersonX",
}

local AXIS_ORDER = { "TP_H" }

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
  if v < TARGET_MIN then v = TARGET_MIN end
  return v
end

local function readAxisSettingValue(axisKey)
  local settingValue = safeGet(SETTING_TYPE_GAMEPAD, ADDON.ids[axisKey])
  local settingNumber = tonumber(settingValue)
  if settingNumber then
    return settingNumber, string.format("%.2f", settingNumber)
  end
  return nil, "n/a"
end

local function readAxisCVarValue(axisKey)
  local cvarValue = getCVarValue(CVAR[axisKey])
  local cvarNumber = tonumber(cvarValue)
  if cvarNumber then
    return cvarNumber, string.format("%.2f", cvarNumber)
  end
  return nil, "n/a"
end

local function readAxisValue(axisKey)
  local settingNumber, settingValue = readAxisSettingValue(axisKey)
  if settingNumber then
    return settingNumber, settingValue, "setting"
  end

  local cvarNumber, cvarValue = readAxisCVarValue(axisKey)
  if cvarNumber then
    return cvarNumber, cvarValue, "cvar"
  end

  return nil, "n/a", nil
end

local function getAxisBounds(axisKey)
  return TARGET_MIN, TARGET_MAX
end

local function normalizeTarget(axisKey, value)
  local num = clamp(value)
  local minValue, maxValue = getAxisBounds(axisKey)
  local wasClamped = false

  if num < minValue then
    num = minValue
  end

  if maxValue and num > maxValue then
    num = maxValue
    wasClamped = true
  end

  return string.format("%.2f", num), wasClamped
end

local function buildTargetValues()
  local rawValues = {
    TP_H = ADDON.sv.tpH,
  }
  local targets = {}
  local clampedAxes = {}

  for _, axisKey in ipairs(AXIS_ORDER) do
    local target, wasClamped = normalizeTarget(axisKey, rawValues[axisKey])
    targets[axisKey] = target
    if wasClamped then
      clampedAxes[#clampedAxes + 1] = axisKey
    end
  end

  return targets, clampedAxes
end

local function valuesMatch(actualValue, targetValue)
  local actualNumber = tonumber(actualValue)
  local targetNumber = tonumber(targetValue)
  return actualNumber ~= nil and targetNumber ~= nil and math.abs(actualNumber - targetNumber) <= 0.009
end

local function describeReadSource(source)
  if source == "setting" then
    return ADDON:Text("SOURCE_SETTING")
  elseif source == "cvar" then
    return ADDON:Text("SOURCE_CVAR")
  end
  return ADDON:Text("SOURCE_NONE")
end

local function applyAxisValue(axisKey, target, allowFallback)
  local nativeId = ADDON.ids[axisKey]
  local forceFallback = nativeId == nil
  local allowFallbackEffective = allowFallback or forceFallback
  local settingBefore = safeGet(SETTING_TYPE_GAMEPAD, ADDON.ids[axisKey])
  local cvarBefore = getCVarValue(CVAR[axisKey])
  local applied = safeSet(SETTING_TYPE_GAMEPAD, nativeId, target)
  local _, actualValue = readAxisValue(axisKey)
  local settingAfterNative = safeGet(SETTING_TYPE_GAMEPAD, nativeId)
  local cvarAfterNative = getCVarValue(CVAR[axisKey])

  dbg(
    "ApplyAxis axis=%s id=%s target=%s allowFallback=%s forceFallback=%s allowFallbackEffective=%s setSettingOk=%s settingBefore=%s cvarBefore=%s settingAfterNative=%s cvarAfterNative=%s readback=%s",
    tostring(axisKey),
    tostring(nativeId),
    tostring(target),
    tostring(allowFallback),
    tostring(forceFallback),
    tostring(allowFallbackEffective),
    tostring(applied),
    tostring(settingBefore),
    tostring(cvarBefore),
    tostring(settingAfterNative),
    tostring(cvarAfterNative),
    tostring(actualValue)
  )

  if applied and valuesMatch(actualValue, target) then
    return actualValue, ADDON:Text("METHOD_NATIVE")
  end

  if allowFallbackEffective and setCVarValue(CVAR[axisKey], target) then
    local _, cvarValue = readAxisCVarValue(axisKey)
    local settingAfterFallback = safeGet(SETTING_TYPE_GAMEPAD, nativeId)
    local cvarAfterFallback = getCVarValue(CVAR[axisKey])
    dbg(
      "ApplyAxisFallback axis=%s target=%s forced=%s settingAfterFallback=%s cvarAfterFallback=%s readback=%s",
      tostring(axisKey),
      tostring(target),
      tostring(forceFallback),
      tostring(settingAfterFallback),
      tostring(cvarAfterFallback),
      tostring(cvarValue)
    )
    if valuesMatch(cvarValue, target) then
      return cvarValue, ADDON:Text("METHOD_FALLBACK")
    end
    local _, fallbackValue = readAxisValue(axisKey)
    actualValue = fallbackValue
  end

  return actualValue or "n/a", ADDON:Text("METHOD_UNCHANGED")
end

function ADDON:ApplyPresets(options)
  options = options or {}

  if (not options.bypassGamepadGuard) and (not guardGamepad()) then
    if not options.suppressFeedback then
      warnRed(self:Text("GAMEPAD_ONLY_WARN"))
    end
    return
  end

  self:EnsureNativeSliderRange()

  local targets, clampedAxes = buildTargetValues()
  local actualTpH, methodTpH = applyAxisValue("TP_H", targets.TP_H, true)
  local _, _, sourceTpH = readAxisValue("TP_H")

  dbg(self:Text("APPLY_FMT"), targets.TP_H, tostring(actualTpH))

  if not options.suppressFeedback then
    if #clampedAxes > 0 then
      warnRed(string.format(self:Text("CLAMP_WARN"), table.concat(clampedAxes, ", ")))
    end

    info(self:Text("APPLY_DONE"))
    info(string.format(self:Text("APPLY_SUMMARY"), targets.TP_H, tostring(actualTpH)))
    info(string.format(self:Text("APPLY_METHODS"), methodTpH))
    info(string.format(self:Text("APPLY_SOURCE"), describeReadSource(sourceTpH)))

    if not self.ids.TP_H then
      if methodTpH == self:Text("METHOD_FALLBACK") and valuesMatch(actualTpH, targets.TP_H) then
        info(self:Text("NATIVE_ID_FALLBACK_INFO"))
      else
        warnRed(self:Text("NATIVE_ID_MISSING"))
      end
    end
  end
end

function ADDON:ApplyTpHValue(value, options)
  options = options or {}
  if (not options.bypassGamepadGuard) and (not guardGamepad()) then
    return nil, self:Text("METHOD_UNCHANGED"), nil
  end

  self:EnsureNativeSliderRange()
  local target = normalizeTarget("TP_H", value)
  local actualTpH, methodTpH = applyAxisValue("TP_H", target, true)
  local _, _, sourceTpH = readAxisValue("TP_H")
  return actualTpH, methodTpH, sourceTpH
end

function ADDON:PrintStatus()
  local _, tpH, sourceTpH = readAxisValue("TP_H")
  local nativeNumber, nativeTpH = readAxisSettingValue("TP_H")
  local cvarNumber, cvarTpH = readAxisCVarValue("TP_H")

  info(string.format(self:Text("STATUS_SAVED"), string.format("%.2f", clamp(self.sv.tpH))))
  info(string.format(self:Text("STATUS_REAL"), tostring(tpH)))
  info(string.format(self:Text("STATUS_NATIVE"), tostring(nativeTpH)))
  info(string.format(self:Text("STATUS_CVAR"), tostring(cvarTpH)))
  info(string.format(self:Text("STATUS_SOURCE"), describeReadSource(sourceTpH)))

  if nativeNumber ~= nil and cvarNumber ~= nil and math.abs(nativeNumber - cvarNumber) > 0.009 then
    warnRed(self:Text("STATUS_DIVERGED"))
  end
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

local function getNowMs()
  local ok, value = pcall(GetGameTimeMilliseconds)
  if ok and type(value) == "number" then
    return value
  end
  return nil
end

local function normalizeHeadingDegrees(angle)
  angle = tonumber(angle) or 0
  angle = angle % 360
  if angle < 0 then
    angle = angle + 360
  end
  return angle
end

local function normalizeHeadingDeltaDegrees(delta)
  delta = tonumber(delta) or 0
  while delta > 180 do
    delta = delta - 360
  end
  while delta < -180 do
    delta = delta + 360
  end
  return delta
end

function ADDON:GetCurrentCameraHeadingDegrees()
  local ok, headingRadians = pcall(GetPlayerCameraHeading)
  if not ok or type(headingRadians) ~= "number" then
    return nil
  end

  return normalizeHeadingDegrees(math.deg(headingRadians))
end

function ADDON:PrintCurrentCameraHeading()
  if not self:IsDebugModeEnabled() then
    warnRed(self:Text("DUMP_NEEDS_DEBUG"))
    return
  end

  local heading = self:GetCurrentCameraHeadingDegrees()
  if heading == nil then
    warnRed(self:Text("HEADING_UNAVAILABLE"))
    return
  end

  self:DebugPrint(string.format(self:Text("HEADING_NOW"), heading), "CameraHeading")
end

local TURN_MEASUREMENT_UPDATE_MS = 16
local TURN_MEASUREMENT_UPDATE_KEY = "EZOcamsens_TurnMeasurement"

function ADDON:PollTurnMeasurement()
  local probe = self.turnMeasurement
  if not (probe and probe.active) then
    return
  end

  local heading = self:GetCurrentCameraHeadingDegrees()
  local nowMs = getNowMs()
  if heading == nil or nowMs == nil then
    return
  end

  local stepDelta = normalizeHeadingDeltaDegrees(heading - probe.lastHeadingDeg)
  probe.lastHeadingDeg = heading
  probe.lastSampleAtMs = nowMs
  probe.samples = probe.samples + 1
  probe.totalSignedDeltaDeg = probe.totalSignedDeltaDeg + stepDelta
  probe.totalAbsDeltaDeg = probe.totalAbsDeltaDeg + math.abs(stepDelta)
end

function ADDON:StartTurnMeasurement()
  if not self:IsDebugModeEnabled() then
    warnRed(self:Text("DUMP_NEEDS_DEBUG"))
    return
  end

  if self.turnMeasurement and self.turnMeasurement.active then
    warnRed(self:Text("TURN_RUNNING"))
    return
  end

  local heading = self:GetCurrentCameraHeadingDegrees()
  local nowMs = getNowMs()
  if heading == nil or nowMs == nil then
    warnRed(self:Text("HEADING_UNAVAILABLE"))
    return
  end

  self.turnMeasurement = {
    active = true,
    startHeadingDeg = heading,
    lastHeadingDeg = heading,
    startedAtMs = nowMs,
    lastSampleAtMs = nowMs,
    samples = 0,
    totalSignedDeltaDeg = 0,
    totalAbsDeltaDeg = 0,
  }

  EVENT_MANAGER:RegisterForUpdate(TURN_MEASUREMENT_UPDATE_KEY, TURN_MEASUREMENT_UPDATE_MS, function()
    ADDON:PollTurnMeasurement()
  end)

  self:DebugPrint(string.format(self:Text("TURN_START"), heading), "TurnMeasurement")
end

function ADDON:BuildTurnMeasurementSummary(probe)
  if type(probe) ~= "table" then
    return nil
  end

  local elapsedMs = math.max(0, (probe.lastSampleAtMs or probe.startedAtMs or 0) - (probe.startedAtMs or 0))
  local elapsedSeconds = elapsedMs / 1000
  local averageSpeed = 0
  if elapsedSeconds > 0 then
    averageSpeed = (probe.totalAbsDeltaDeg or 0) / elapsedSeconds
  end
  local directDelta = normalizeHeadingDeltaDegrees((probe.lastHeadingDeg or 0) - (probe.startHeadingDeg or 0))

  return string.format(
    self:Text("TURN_REPORT"),
    tonumber(probe.startHeadingDeg) or 0,
    tonumber(probe.lastHeadingDeg) or 0,
    directDelta,
    tonumber(probe.totalSignedDeltaDeg) or 0,
    tonumber(probe.totalAbsDeltaDeg) or 0,
    elapsedSeconds,
    averageSpeed,
    tonumber(probe.samples) or 0
  )
end

function ADDON:StopTurnMeasurement()
  if not self:IsDebugModeEnabled() then
    warnRed(self:Text("DUMP_NEEDS_DEBUG"))
    return
  end

  local probe = self.turnMeasurement
  if not (probe and probe.active) then
    warnRed(self:Text("TURN_IDLE"))
    return
  end

  EVENT_MANAGER:UnregisterForUpdate(TURN_MEASUREMENT_UPDATE_KEY)
  probe.active = false

  local heading = self:GetCurrentCameraHeadingDegrees()
  local nowMs = getNowMs()
  if heading ~= nil then
    probe.totalSignedDeltaDeg = (probe.totalSignedDeltaDeg or 0) + normalizeHeadingDeltaDegrees(heading - probe.lastHeadingDeg)
    probe.totalAbsDeltaDeg = (probe.totalAbsDeltaDeg or 0) + math.abs(normalizeHeadingDeltaDegrees(heading - probe.lastHeadingDeg))
    probe.lastHeadingDeg = heading
  end
  if nowMs ~= nil then
    probe.lastSampleAtMs = nowMs
  end

  self.lastTurnMeasurement = probe
  self.turnMeasurement = nil

  local summary = self:BuildTurnMeasurementSummary(probe)
  if not summary then
    warnRed(self:Text("TURN_NO_DATA"))
    return
  end

  local batch = self:CreateDebugBatch("TurnMeasurement")
  self:DebugBatchAdd(batch, self:Text("TURN_STOP"))
  self:DebugBatchAdd(batch, summary)
  self:DebugBatchFlush(batch)
end

function ADDON:PrintTurnMeasurementReport()
  if not self:IsDebugModeEnabled() then
    warnRed(self:Text("DUMP_NEEDS_DEBUG"))
    return
  end

  local probe = self.turnMeasurement or self.lastTurnMeasurement
  if not probe then
    warnRed(self:Text("TURN_NO_DATA"))
    return
  end

  local summary = self:BuildTurnMeasurementSummary(probe)
  if not summary then
    warnRed(self:Text("TURN_NO_DATA"))
    return
  end

  self:DebugPrint(summary, "TurnMeasurement")
end

local DYNAMIC_TURN_UPDATE_MS = 16
local DYNAMIC_TURN_UPDATE_KEY = "EZOcamsens_DynamicTurn"

local function getDynamicNumber(key, fallback)
  local value = ADDON.sv and tonumber(ADDON.sv[key])
  if value == nil then
    return fallback
  end
  return value
end

function ADDON:IsPlayerInCombat()
  local ok, inCombat = pcall(IsUnitInCombat, "player")
  return ok and inCombat == true
end

function ADDON:IsDynamicTurnAllowedByCombat()
  return not (self.sv and self.sv.dynamicOnlyInCombat) or self:IsPlayerInCombat()
end

function ADDON:ApplyDynamicSensitivity(value, textKey, ...)
  local actualTpH, methodTpH = self:ApplyTpHValue(value, { suppressFeedback = true })
  if isDebugEnabled() and actualTpH ~= nil then
    local lines = {
      string.format(self:Text(textKey), tonumber(value) or 0, ...),
      string.format(self:Text("DYNAMIC_READBACK"), tostring(actualTpH), tostring(methodTpH)),
    }
    self:SafeDebugViewer(table.concat(lines, "\n"), "DynamicTurn")
  end
  return actualTpH, methodTpH
end

function ADDON:ResetDynamicTurnCycle(heading, nowMs, reason)
  local state = self.dynamicTurn
  if not state then return end

  state.combatActive = true
  state.phase = "fast"
  state.startHeadingDeg = heading
  state.lastHeadingDeg = heading
  state.lastMovementAtMs = nowMs
  state.accumulatedAbsDeg = 0
  self:ApplyDynamicSensitivity(
    getDynamicNumber("dynamicFastTpH", self.defaults.dynamicFastTpH),
    "DYNAMIC_FAST_APPLIED",
    reason or self:Text("DYNAMIC_REASON_IDLE")
  )
end

function ADDON:SetDynamicTurnWaiting()
  local state = self.dynamicTurn
  if state then
    state.combatActive = false
    state.phase = "waiting"
    state.accumulatedAbsDeg = 0
  end
  self:ApplyPresets({ bypassGamepadGuard = true, suppressFeedback = true })
end

function ADDON:StartDynamicTurnAssist()
  if not (self.sv and self.sv.dynamicEnabled) then
    return false
  end
  if self.dynamicTurn and self.dynamicTurn.active then
    if not self:IsDynamicTurnAllowedByCombat() then
      self:SetDynamicTurnWaiting()
    end
    return true
  end

  local nowMs = getNowMs()
  if nowMs == nil then
    warnRed(self:Text("HEADING_UNAVAILABLE"))
    return false
  end

  self.dynamicTurn = {
    active = true,
    combatActive = false,
    phase = "fast",
    startHeadingDeg = 0,
    lastHeadingDeg = 0,
    startedAtMs = nowMs,
    lastMovementAtMs = nowMs,
    accumulatedAbsDeg = 0,
  }

  if self:IsDynamicTurnAllowedByCombat() then
    local heading = self:GetCurrentCameraHeadingDegrees()
    if heading == nil then
      warnRed(self:Text("HEADING_UNAVAILABLE"))
      self.dynamicTurn = nil
      return false
    end
    self:ResetDynamicTurnCycle(heading, nowMs, self:Text("DYNAMIC_REASON_START"))
  else
    self:SetDynamicTurnWaiting()
  end

  EVENT_MANAGER:RegisterForUpdate(DYNAMIC_TURN_UPDATE_KEY, DYNAMIC_TURN_UPDATE_MS, function()
    ADDON:PollDynamicTurnAssist()
  end)

  if isDebugEnabled() then
    self:SafeDebugViewer(
      string.format(
        self:Text("DYNAMIC_STARTED"),
        getDynamicNumber("dynamicFastTpH", self.defaults.dynamicFastTpH),
        getDynamicNumber("dynamicSlowTpH", self.defaults.dynamicSlowTpH),
        getDynamicNumber("dynamicAngleThreshold", self.defaults.dynamicAngleThreshold)
      ),
      "DynamicTurn"
    )
  end
  return true
end

function ADDON:StopDynamicTurnAssist(restoreSaved)
  local wasActive = self.dynamicTurn and self.dynamicTurn.active
  if self.dynamicTurn and self.dynamicTurn.active then
    EVENT_MANAGER:UnregisterForUpdate(DYNAMIC_TURN_UPDATE_KEY)
  end
  self.dynamicTurn = nil

  if restoreSaved then
    self:ApplyPresets({ bypassGamepadGuard = true, suppressFeedback = true })
  end

  if isDebugEnabled() and wasActive then
    self:SafeDebugViewer(self:Text("DYNAMIC_STOPPED"), "DynamicTurn")
  end
end

function ADDON:RefreshDynamicTurnAssist(restoreSaved)
  if self.sv and self.sv.dynamicEnabled then
    self:StartDynamicTurnAssist()
  else
    self:StopDynamicTurnAssist(restoreSaved == true)
  end
end

function ADDON:PollDynamicTurnAssist()
  local state = self.dynamicTurn
  if not (state and state.active and self.sv and self.sv.dynamicEnabled) then
    return
  end
  local nowMs = getNowMs()
  if nowMs == nil then
    return
  end

  if not self:IsDynamicTurnAllowedByCombat() then
    if state.combatActive or state.phase ~= "waiting" then
      self:SetDynamicTurnWaiting()
    end
    return
  end

  if not guardGamepad() then
    return
  end

  local heading = self:GetCurrentCameraHeadingDegrees()
  if heading == nil then
    return
  end

  if not state.combatActive then
    self:ResetDynamicTurnCycle(heading, nowMs, self:Text("DYNAMIC_REASON_COMBAT"))
    return
  end

  local stepDelta = normalizeHeadingDeltaDegrees(heading - state.lastHeadingDeg)
  local stepAbs = math.abs(stepDelta)
  local movementThreshold = getDynamicNumber("dynamicMovementThreshold", self.defaults.dynamicMovementThreshold)
  local idleResetMs = getDynamicNumber("dynamicIdleResetMs", self.defaults.dynamicIdleResetMs)
  local angleThreshold = getDynamicNumber("dynamicAngleThreshold", self.defaults.dynamicAngleThreshold)

  if stepAbs >= movementThreshold then
    state.accumulatedAbsDeg = (state.accumulatedAbsDeg or 0) + stepAbs
    state.lastMovementAtMs = nowMs

    if state.phase == "fast" and state.accumulatedAbsDeg >= angleThreshold then
      state.phase = "slow"
      self:ApplyDynamicSensitivity(
        getDynamicNumber("dynamicSlowTpH", self.defaults.dynamicSlowTpH),
        "DYNAMIC_SLOW_APPLIED",
        state.accumulatedAbsDeg,
        self:Text("DYNAMIC_REASON_ANGLE")
      )
    end
  elseif state.phase ~= "fast" and (nowMs - (state.lastMovementAtMs or nowMs)) >= idleResetMs then
    self:ResetDynamicTurnCycle(heading, nowMs, self:Text("DYNAMIC_REASON_IDLE"))
    if isDebugEnabled() then
      self:SafeDebugViewer(self:Text("DYNAMIC_RESET"), "DynamicTurn")
    end
  elseif state.phase == "fast" and state.accumulatedAbsDeg > 0 and (nowMs - (state.lastMovementAtMs or nowMs)) >= idleResetMs then
    self:ResetDynamicTurnCycle(heading, nowMs, self:Text("DYNAMIC_REASON_IDLE"))
    if isDebugEnabled() then
      self:SafeDebugViewer(self:Text("DYNAMIC_RESET"), "DynamicTurn")
    end
  end

  state.lastHeadingDeg = heading
end

local function dumpControlGroup(batch, label, settingType)
  local data = ZO_OptionsPanel_Camera_ControlData
  if not (data and data[settingType]) then
    ADDON:DebugBatchAdd(batch, string.format("[%s] no data for settingType=%s", label, tostring(settingType)))
    return
  end

  ADDON:DebugBatchAdd(batch, string.format("==== %s settingType=%s ====", label, tostring(settingType)))
  for id, entry in pairs(data[settingType]) do
    if type(entry) == "table" then
      ADDON:DebugBatchAdd(
        batch,
        string.format(
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
      )
    else
      ADDON:DebugBatchAdd(batch, string.format("id=%s entry=%s", tostring(id), tostring(entry)))
    end
  end
end

function ADDON:DumpCameraDiagnostics()
  if not (self:IsDebugModeEnabled() and self:EnsureDebugLogger()) then
    warnRed(self:Text("DUMP_NEEDS_DEBUG"))
    return
  end

  local batch = self:CreateDebugBatch("DumpCameraDiagnostics")
  self:DebugBatchAdd(batch, "==== EZOcamsens camera diagnostic dump start ====")
  self:DebugBatchAdd(batch, string.format("Detected key TP_H=%s", tostring(self.ids.TP_H)))
  local _, tpH = readAxisValue("TP_H")
  self:DebugBatchAdd(batch, string.format("Current readback TP_H=%s", tostring(tpH)))
  dumpControlGroup(batch, "CAMERA", SETTING_TYPE_CAMERA)
  if SETTING_TYPE_GAMEPAD then
    dumpControlGroup(batch, "GAMEPAD", SETTING_TYPE_GAMEPAD)
  end
  self:DebugBatchAdd(batch, "==== EZOcamsens camera diagnostic dump end ====")
  self:DebugBatchFlush(batch)
end
