local ADDON = EZOcamsens
local debugControllerRegistered = false

function ADDON:InitChat()
  local ok, LCM = pcall(function() return LibChatMessage end)
  if ok and LCM then
    self.chat = LCM("EZOcamsens", "EZO")
    self.chat:SetEnabled(self.sv and self.sv.chatEnabled or true)
  end
end

local function chatPrint(msg, color, force)
  local text = tostring(msg)
  if color then
    text = "|c" .. color .. text .. "|r"
  end

  local chatSettingEnabled = not (EZOcamsens and EZOcamsens.sv and EZOcamsens.sv.chatEnabled == false)
  if EZOcamsens and EZOcamsens.chat and ((not force) or chatSettingEnabled) then
    EZOcamsens.chat:Print(text)
  else
    d("|cAFC7E8[EZOcamsens]|r " .. text)
  end
end

local function info(msg, force)
  chatPrint(msg, nil, force == true)
end

local function warnRed(msg, force)
  chatPrint(msg, "D89B3C", force == true)
end

function ADDON:PrintUserMessage(msg, options)
  options = options or {}
  info(msg, options.forceChat == true)
end

function ADDON:PrintUserWarning(msg, options)
  options = options or {}
  warnRed(msg, options.forceChat == true)
end

function ADDON:PrintUserLines(lines, options)
  options = options or {}
  if type(lines) ~= "table" then
    info(lines, options.forceChat == true)
    return
  end

  for _, line in ipairs(lines) do
    info(line, options.forceChat == true)
  end
end

function ADDON:InitLogger()
  self:InitializeDebug()
end

function ADDON.GetDefaultLanguage()
  return "auto"
end

function ADDON.GetClientLanguage()
  local ok, v = pcall(GetCVar, "Language.2")
  if ok and type(v) == "string" and string.sub(string.lower(v), 1, 2) == "es" then
    return "es"
  end
  return "en"
end

function ADDON:GetEffectiveLanguage(language)
  local sel = tostring(language or self:GetDefaultLanguage())
  if self.IsLanguageManagedByEZOCore and self:IsLanguageManagedByEZOCore() then
    local ok, inherited = pcall(function()
      return EZOCore:GetLanguage()
    end)
    if ok and (inherited == "es" or inherited == "en") then
      return inherited
    end
  end
  if sel == "inherit" then
    sel = "auto"
  end
  if sel == "es" or sel == "en" then
    return sel
  end
  return self:GetClientLanguage()
end

function ADDON.IsLanguageManagedByEZOCore()
  if not (EZOCore and type(EZOCore.IsLanguageGloballyManaged) == "function") then
    return false
  end
  local ok, managed = pcall(function()
    return EZOCore:IsLanguageGloballyManaged()
  end)
  return ok and managed == true
end

function ADDON:RegisterEZOCoreLanguageCallback()
  if self._ezoCoreLanguageCallbackRegistered
      or not (EZOCore and type(EZOCore.RegisterCallback) == "function") then
    return false
  end

  local eventName = EZOCore.EVENT_LANGUAGE_CHANGED or "EZO_CORE_LANGUAGE_CHANGED"
  local ok, result = pcall(function()
    return EZOCore:RegisterCallback(eventName, function()
      if self.sv then
        self:InitLocale()
        self:RefreshLAM()
      end
    end)
  end)
  self._ezoCoreLanguageCallbackRegistered = ok and result == true
  return self._ezoCoreLanguageCallbackRegistered
end

function ADDON:RegisterWithEZOCore()
  if self._ezoCoreRegistered
      or not (EZOCore and type(EZOCore.RegisterAddon) == "function") then
    return false
  end

  local ok, result = pcall(function()
    return EZOCore:RegisterAddon({
      id = "ezocamsens",
      name = self.name or "EZOcamsens",
      version = self.version or "0.0.0",
      addOnVersion = 10718,
      apiVersion = 1,
      capabilities = {
        "camera.sensitivity",
        "family.debug.controller",
        "family.language.consumer",
        "family.settings.consumer",
      },
    })
  end)

  self._ezoCoreRegistered = ok and result == true
  return self._ezoCoreRegistered
end

function ADDON:RegisterDebugWithEZOCore()
  if debugControllerRegistered
      or not (EZOCore and type(EZOCore.GetService) == "function") then
    return false
  end

  local service = EZOCore:GetService("family.debug", 1)
  if not service or type(service.RegisterController) ~= "function" then
    return false
  end

  local ok, result = pcall(function()
    return service:RegisterController({
      id = "ezocamsens.debug",
      addonId = "ezocamsens",
      addonName = self.name or "EZOcamsens",
      name = function() return self:Text("DEBUG_MODE") end,
      isEnabled = function()
        return self:IsDebugModeEnabled()
      end,
      setEnabled = function(enabled)
        self:SetDebugModeEnabled(enabled == true)
        return self:IsDebugModeEnabled() == (enabled == true)
      end,
    })
  end)

  debugControllerRegistered = ok and result == true
  return debugControllerRegistered
end

function ADDON:EnsureDebugLogger()
  self.runtime = self.runtime or {}
  if self.runtime.debugLogger then
    self.logger = self.runtime.debugLogger
    return self.runtime.debugLogger
  end
  if self.runtime.debugLoggerUnavailable == true then
    return nil
  end

  local lib = _G.LibDebugLogger
  if type(lib) ~= "function" and type(lib) ~= "table" then
    self.runtime.debugLoggerUnavailable = true
    return nil
  end

  local ok, logger = pcall(function()
    local created = nil
    if type(lib) == "function" then
      created = lib(self.name)
    elseif type(lib.Create) == "function" then
      created = lib:Create(self.name)
    end
    if created and type(created.SetMinLevelOverride) == "function" and type(lib) == "table" and lib.LOG_LEVEL_DEBUG ~= nil then
      created:SetMinLevelOverride(lib.LOG_LEVEL_DEBUG)
    end
    if created and type(created.SetLogTracesOverride) == "function" then
      created:SetLogTracesOverride(false)
    end
    return created
  end)

  if ok and logger then
    self.runtime.debugLogger = logger
    self.runtime.debugLoggerUnavailable = false
    self.logger = logger
    return logger
  end

  self.runtime.debugLoggerUnavailable = true
  return nil
end

function ADDON:InitializeDebug()
  self.runtime = self.runtime or {}
  if self:IsDebugModeEnabled() then
    self:EnsureDebugLogger()
  end
end

function ADDON:RefreshDebugLoggerState()
  if not self:IsDebugModeEnabled() then return end
  local logger = self:EnsureDebugLogger()
  if not logger then return end
  if logger.SetEnabled then
    logger:SetEnabled(true)
  end
end

function ADDON:HasDebugViewer()
  return self:EnsureDebugLogger() ~= nil
end

function ADDON:RequireDebugViewer()
  if not self:IsDebugModeEnabled() then
    warnRed(self:Text("DEBUG_MODE_DISABLED"), true)
    return false
  end
  if not self:HasDebugViewer() then
    warnRed(self:Text("DEBUG_VIEWER_MISSING"), true)
    return false
  end
  return true
end

local function isDebugEnabled()
  return EZOcamsens and EZOcamsens.IsDebugModeEnabled and EZOcamsens:IsDebugModeEnabled()
end

function ADDON:SafeDebugViewer(msg, subTag)
  local logger = self:EnsureDebugLogger()
  if not logger then
    return false
  end

  local hasSubTag = type(logger.SetSubTag) == "function"
  if hasSubTag then
    pcall(logger.SetSubTag, logger, subTag)
  end

  local ok = pcall(function()
    if type(logger.Debug) == "function" then
      logger:Debug(tostring(msg))
    elseif type(logger.Info) == "function" then
      logger:Info(tostring(msg))
    end
  end)

  if hasSubTag then
    pcall(logger.SetSubTag, logger, nil)
  end

  return ok
end

function ADDON:DebugPrint(msg, subTag)
  if isDebugEnabled() then
    return self:SafeDebugViewer(msg, subTag or "Debug")
  end
  return false
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
  if not isDebugEnabled() then return false end
  if type(batch) ~= "table" or type(batch.lines) ~= "table" or #batch.lines == 0 then
    return false
  end

  return self:SafeDebugViewer(table.concat(batch.lines, "\n"), batch.subTag or "Debug")
end

local STR = {
  es = {
    STORAGE_HEADER = "Guardado de ajustes",
    STORAGE_HEADER_TT = "Los ajustes se separan por servidor. Puedes guardarlos por personaje o compartirlos por cuenta dentro del mismo servidor.",
    STORAGE_SCOPE = "Guardar ajustes",
    STORAGE_SCOPE_TT = "Por personaje cada personaje tiene sus valores. Por cuenta se comparten dentro del mismo servidor.",
    STORAGE_SCOPE_CHARACTER = "Por personaje",
    STORAGE_SCOPE_ACCOUNT = "Por cuenta",
    SCOPE_RELOAD_NOTICE = "Se recargará la interfaz para cambiar el tipo de guardado.",
    AUTHOR = "Por: @Zuriplayer",
    PRESETS_HEADER = "Sensibilidad base",
    PRESETS_HEADER_TT = "Ajuste principal del addon: sensibilidad horizontal de cámara en tercera persona usando mando.",
    TP_HEADER = "Tercera persona",
    TP_HEADER_TT = "Valores aplicados a la cámara en tercera persona.",
    TP_H = "Sensibilidad horizontal",
    TP_H_TT = "Valor horizontal guardado por el addon. Al moverlo se aplica al momento salvo que el giro dinámico esté gestionando el valor.",
    APPLY_NOW = "Aplicar ajuste",
    APPLY_NOW_TT = "Vuelve a aplicar el valor horizontal guardado, útil después de cambiar opciones o tras una recarga.",
    DYNAMIC_HEADER = "Giro dinámico experimental",
    DYNAMIC_HEADER_TT = "Modo experimental que empieza con sensibilidad rápida y cambia a lenta tras superar el ángulo configurado. Solo modifica la sensibilidad horizontal de tercera persona.",
    DYNAMIC_ENABLED = "Activar giro dinámico",
    DYNAMIC_ENABLED_TT = "Empieza girando rápido y cambia a lento cuando superas el ángulo elegido.",
    DYNAMIC_ONLY_COMBAT = "Aplicar solo en combate",
    DYNAMIC_ONLY_COMBAT_TT = "Si está activo, el giro dinámico espera a que entres en combate y restaura el ajuste normal al salir.",
    DYNAMIC_ONLY_TANK = "Solo si tengo rol de tanque",
    DYNAMIC_ONLY_TANK_TT = "Si está activo, el giro dinámico solo funciona cuando tu rol marcado es tanque.",
    DYNAMIC_FAST = "Sensibilidad rápida",
    DYNAMIC_FAST_TT = "Valor usado al comenzar un ciclo de giro dinámico.",
    DYNAMIC_SLOW = "Sensibilidad lenta",
    DYNAMIC_SLOW_TT = "Valor usado cuando el giro acumulado supera el ángulo configurado.",
    DYNAMIC_ANGLE = "Ángulo para cambiar a lento",
    DYNAMIC_ANGLE_TT = "Grados acumulados de giro horizontal necesarios para pasar de sensibilidad rápida a lenta.",
    DYNAMIC_IDLE = "Reposo para reiniciar (ms)",
    DYNAMIC_IDLE_TT = "Tiempo sin giro suficiente para reiniciar el ciclo dinámico y volver a sensibilidad rápida.",
    DYNAMIC_MOVEMENT = "Movimiento mínimo para contar giro",
    DYNAMIC_MOVEMENT_TT = "Movimiento horizontal mínimo por muestra para que el addon lo cuente como giro real.",
    BEHAVIOR = "Comportamiento",
    BEHAVIOR_TT = "Opciones generales de aplicación y mensajes visibles del addon.",
    ONLY_GP = "Aplicar solo en modo gamepad",
    ONLY_GP_TT = "Evita cambios si no estás jugando con mando.",
    CHAT_MSG = "Mostrar mensajes en chat",
    CHAT_MSG_TT = "Muestra avisos cortos del addon en el chat. El debug detallado sigue usando DebugLogViewer.",
    SUPPORT = "Soporte y debug",
    SUPPORT_TT = "Herramientas de diagnóstico. El volcado técnico solo se envía a DebugLogViewer cuando el modo debug está activo.",
    DEBUG_MODE = "Activar modo debug",
    DEBUG_MODE_TT = "Activa el modo debug del addon y manda la información a DebugLogViewer.",
    SHOW_STATUS = "Mostrar valores actuales",
    MAINTENANCE = "Idioma y restauración",
    MAINTENANCE_TT = "Opciones de idioma del panel y restauración segura de los valores gestionados por el addon.",
    RESTORE_DEFAULTS = "Restaurar valores por defecto",
    RESTORE_DEFAULTS_TT = "Restaura opciones del addon y devuelve la sensibilidad horizontal de tercera persona al valor base del juego.",
    RESTORE_WARN = "Se restaurará la sensibilidad horizontal de tercera persona al valor por defecto del juego y también las opciones del addon.",
    LANG_DD = "Selecciona idioma",
    LANG_DD_TT = "Idioma local usado cuando EZOCore no está instalado o su modo de idioma es 'dejar que cada addon elija'. Los idiomas centrales de EZOCore desactivan este selector.",
    LANG_AUTO = "Automático (cliente)",
    LANG_ES = "Español",
    LANG_EN = "English",
    CMD_TITLE = "Comandos disponibles:",
    CMD_STATUS = "  /ezocamsens status       - muestra valores guardados y aplicados",
    CMD_APPLY = "  /ezocamsens apply        - fuerza el valor guardado",
    CMD_DEBUG = "  /ezocamsens debug        - vuelca el estado técnico en DebugLogViewer",
    LANG_NOTICE = "Para aplicar el cambio de idioma se recargará la interfaz.",
    DEBUG_MODE_DISABLED = "El modo debug está desactivado. Actívalo en la configuración del addon para usar /ezocamsens debug.",
    DEBUG_VIEWER_MISSING = "LibDebugLogger no está disponible. Activa DebugLogViewer/LibDebugLogger para ver el modo debug.",
    DEFAULTS_RESTORED = "Sensibilidad horizontal de tercera persona restaurada al valor por defecto del juego.",
    APPLY_DONE = "Ajuste aplicado.",
    APPLY_FMT = "Aplicado 3ª horizontal=%s [%s]",
    APPLY_SUMMARY = "Objetivo 3ª horizontal=%s | Real=%s",
    APPLY_METHODS = "Modo de aplicación 3ª horizontal=%s",
    APPLY_SOURCE = "Lectura 3ª horizontal=%s",
    APPLY_VIEWER_START = "==== EZOcamsens aplicacion inicio ====",
    APPLY_VIEWER_END = "==== EZOcamsens aplicacion fin ====",
    APPLY_CVARS = "CVars %s: %s",
    AXIS_TP_H = "tercera horizontal",
    CLAMP_WARN = "Algunos objetivos se ajustaron al máximo disponible en el juego: %s",
    STATUS_SAVED = "Guardado 3ª horizontal=%s",
    STATUS_REAL = "Actual   3ª horizontal=%s",
    STATUS_CVAR = "CVar     3ª horizontal=%s",
    STATUS_SOURCE = "Lectura efectiva 3ª horizontal=%s",
    GAMEPAD_ONLY_WARN = "Acción bloqueada: activa el modo gamepad o desmarca la opción de aplicar solo en gamepad.",
    METHOD_FALLBACK = "CVar",
    METHOD_UNCHANGED = "sin cambio",
    SOURCE_CVAR = "CVar",
    SOURCE_NONE = "sin fuente",
    SHOW_STATUS_TT = "Envía los valores actuales a DebugLogViewer. Requiere modo debug activo.",
    STATUS_VIEWER_START = "==== EZOcamsens valores actuales inicio ====",
    STATUS_VIEWER_END = "==== EZOcamsens valores actuales fin ====",
    HEADING_UNAVAILABLE = "No se pudo leer la dirección actual de la cámara en esta sesión.",
    DYNAMIC_STARTED = "Giro dinámico iniciado: rápido=%.2f lento=%.2f ángulo=%.2f",
    DYNAMIC_STOPPED = "Giro dinámico detenido.",
    DYNAMIC_FAST_APPLIED = "Giro dinámico: sensibilidad rápida aplicada %.2f (%s)",
    DYNAMIC_SLOW_APPLIED = "Giro dinámico: sensibilidad lenta aplicada %.2f tras %.2f grados (%s)",
    DYNAMIC_RESET = "Giro dinámico: reposo detectado, reinicio a rápido.",
    DYNAMIC_READBACK = "Lectura dinámica: actual=%s método=%s",
    DYNAMIC_REASON_START = "inicio",
    DYNAMIC_REASON_COMBAT = "combate",
    DYNAMIC_REASON_IDLE = "reposo",
    DYNAMIC_REASON_ANGLE = "ángulo",
    DEBUG_SNAPSHOT_START = "==== EZOcamsens volcado debug inicio ====",
    DEBUG_SNAPSHOT_VERSION = "versión addon=%s",
    DEBUG_SNAPSHOT_LOCALE = "idioma activo=%s guardado=%s",
    DEBUG_SNAPSHOT_PROFILE = "servidor=%s guardado=%s personaje=%s",
    DEBUG_SNAPSHOT_DEBUG = "debug activo=%s viewer=%s",
    DEBUG_SNAPSHOT_CHAT_GAMEPAD = "chat activo=%s soloGamepad=%s gamepadPreferido=%s",
    DEBUG_SNAPSHOT_COMBAT = "combate jugador=%s rolTanque=%s soloTanque=%s",
    DEBUG_SNAPSHOT_TPH = "tpH guardado=%s actual=%s cvar=%s fuente=%s",
    DEBUG_SNAPSHOT_DYNAMIC = "dinámico activo=%s soloCombate=%s soloTanque=%s rápido=%s lento=%s ángulo=%s reposoMs=%s movimiento=%s",
    DEBUG_SNAPSHOT_DYNAMIC_STATE = "estado dinámico activo=%s combate=%s fase=%s ánguloAcumulado=%s últimoHeading=%s",
    DEBUG_SNAPSHOT_DYNAMIC_STATE_NONE = "estado dinámico=nil",
    DEBUG_SNAPSHOT_HEADING = "dirección actual=%s",
    DEBUG_SNAPSHOT_END = "==== EZOcamsens volcado debug fin ====",
  },
  en = {
    STORAGE_HEADER = "Settings storage",
    STORAGE_HEADER_TT = "Settings are separated per server. You can save them per character or share them account-wide on the same server.",
    STORAGE_SCOPE = "Save settings",
    STORAGE_SCOPE_TT = "Per character keeps each character separate. Account-wide shares values on the same server.",
    STORAGE_SCOPE_CHARACTER = "Per character",
    STORAGE_SCOPE_ACCOUNT = "Account-wide",
    SCOPE_RELOAD_NOTICE = "The UI will reload to change the settings storage mode.",
    AUTHOR = "By: @Zuriplayer",
    PRESETS_HEADER = "Base sensitivity",
    PRESETS_HEADER_TT = "Main addon setting: third-person horizontal camera sensitivity for controller play.",
    TP_HEADER = "Third-person",
    TP_HEADER_TT = "Values applied to the third-person camera.",
    TP_H = "Horizontal sensitivity",
    TP_H_TT = "Horizontal value saved by the addon. Moving it applies immediately unless dynamic turn is managing the value.",
    APPLY_NOW = "Apply setting",
    APPLY_NOW_TT = "Reapplies the saved horizontal value, useful after changing options or after a reload.",
    DYNAMIC_HEADER = "Experimental dynamic turn",
    DYNAMIC_HEADER_TT = "Experimental mode that starts with fast sensitivity and switches to slow after the configured angle. It only changes third-person horizontal sensitivity.",
    DYNAMIC_ENABLED = "Enable dynamic turn",
    DYNAMIC_ENABLED_TT = "Starts turning fast and switches to slow after the chosen angle.",
    DYNAMIC_ONLY_COMBAT = "Apply only in combat",
    DYNAMIC_ONLY_COMBAT_TT = "When enabled, dynamic turn waits until combat starts and restores the normal setting after combat ends.",
    DYNAMIC_ONLY_TANK = "Only if my role is tank",
    DYNAMIC_ONLY_TANK_TT = "When enabled, dynamic turn only runs while your selected role is tank.",
    DYNAMIC_FAST = "Fast sensitivity",
    DYNAMIC_FAST_TT = "Value used at the start of a dynamic turn cycle.",
    DYNAMIC_SLOW = "Slow sensitivity",
    DYNAMIC_SLOW_TT = "Value used after the accumulated turn passes the configured angle.",
    DYNAMIC_ANGLE = "Angle before slow mode",
    DYNAMIC_ANGLE_TT = "Accumulated horizontal turn degrees required to switch from fast to slow sensitivity.",
    DYNAMIC_IDLE = "Idle reset (ms)",
    DYNAMIC_IDLE_TT = "Time without turning required to reset the dynamic cycle back to fast sensitivity.",
    DYNAMIC_MOVEMENT = "Minimum movement to count a turn",
    DYNAMIC_MOVEMENT_TT = "Minimum horizontal movement per sample before the addon counts it as real turning.",
    BEHAVIOR = "Behavior",
    BEHAVIOR_TT = "General application and visible message options for the addon.",
    ONLY_GP = "Apply only in gamepad mode",
    ONLY_GP_TT = "Prevents changes if you are not playing with a controller.",
    CHAT_MSG = "Show feedback in chat",
    CHAT_MSG_TT = "Shows short addon notices in chat. Detailed debug still uses DebugLogViewer.",
    SUPPORT = "Support & debug",
    SUPPORT_TT = "Diagnostic tools. Technical dumps are only sent to DebugLogViewer when debug mode is enabled.",
    DEBUG_MODE = "Enable debug mode",
    DEBUG_MODE_TT = "Enables addon debug mode and sends information to DebugLogViewer.",
    SHOW_STATUS = "Show current values",
    MAINTENANCE = "Language & reset",
    MAINTENANCE_TT = "Panel language options and safe reset for values managed by the addon.",
    RESTORE_DEFAULTS = "Restore defaults",
    RESTORE_DEFAULTS_TT = "Restores addon options and returns third-person horizontal sensitivity to the game's base value.",
    RESTORE_WARN = "Third-person horizontal sensitivity will be restored to the game's default value, along with the addon options.",
    LANG_DD = "Select language",
    LANG_DD_TT = "Local language used when EZOCore is not installed or its language mode is 'Let each addon choose'. Central EZOCore language choices disable this selector.",
    LANG_AUTO = "Automatic (client)",
    LANG_ES = "Spanish",
    LANG_EN = "English",
    CMD_TITLE = "Available commands:",
    CMD_STATUS = "  /ezocamsens status       - show saved and applied values",
    CMD_APPLY = "  /ezocamsens apply        - force the saved value",
    CMD_DEBUG = "  /ezocamsens debug        - dump the technical state to DebugLogViewer",
    LANG_NOTICE = "The UI will reload to apply the language change.",
    DEBUG_MODE_DISABLED = "Debug mode is disabled. Enable it in the addon settings to use /ezocamsens debug.",
    DEBUG_VIEWER_MISSING = "LibDebugLogger is not available. Enable DebugLogViewer/LibDebugLogger to view debug output.",
    DEFAULTS_RESTORED = "Third-person horizontal sensitivity restored to the game's default value.",
    APPLY_DONE = "Setting applied.",
    APPLY_FMT = "Applied 3rd horizontal=%s [%s]",
    APPLY_SUMMARY = "Target 3rd horizontal=%s | Actual=%s",
    APPLY_METHODS = "Apply method 3rd horizontal=%s",
    APPLY_SOURCE = "Readback 3rd horizontal=%s",
    APPLY_VIEWER_START = "==== EZOcamsens apply start ====",
    APPLY_VIEWER_END = "==== EZOcamsens apply end ====",
    APPLY_CVARS = "CVars %s: %s",
    AXIS_TP_H = "third horizontal",
    CLAMP_WARN = "Some targets were limited to the current in-game maximum: %s",
    STATUS_SAVED = "Saved   3rd horizontal=%s",
    STATUS_REAL = "Current 3rd horizontal=%s",
    STATUS_CVAR = "CVar    3rd horizontal=%s",
    STATUS_SOURCE = "Effective readback 3rd horizontal=%s",
    GAMEPAD_ONLY_WARN = "Action blocked: enable gamepad mode or disable the gamepad-only option.",
    METHOD_FALLBACK = "CVar",
    METHOD_UNCHANGED = "unchanged",
    SOURCE_CVAR = "cvar",
    SOURCE_NONE = "no source",
    SHOW_STATUS_TT = "Sends current values to DebugLogViewer. Requires debug mode.",
    STATUS_VIEWER_START = "==== EZOcamsens current values start ====",
    STATUS_VIEWER_END = "==== EZOcamsens current values end ====",
    HEADING_UNAVAILABLE = "Could not read the current camera direction in this session.",
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
    DEBUG_SNAPSHOT_START = "==== EZOcamsens debug snapshot start ====",
    DEBUG_SNAPSHOT_VERSION = "addon version=%s",
    DEBUG_SNAPSHOT_LOCALE = "locale active=%s saved=%s",
    DEBUG_SNAPSHOT_PROFILE = "server=%s storage=%s character=%s",
    DEBUG_SNAPSHOT_DEBUG = "debug enabled=%s viewer=%s",
    DEBUG_SNAPSHOT_CHAT_GAMEPAD = "chat enabled=%s applyOnlyInGamepad=%s gamepadPreferred=%s",
    DEBUG_SNAPSHOT_COMBAT = "combat player=%s tankRole=%s onlyTank=%s",
    DEBUG_SNAPSHOT_TPH = "tpH saved=%s current=%s cvar=%s source=%s",
    DEBUG_SNAPSHOT_DYNAMIC = "dynamic enabled=%s onlyCombat=%s onlyTank=%s fast=%s slow=%s angle=%s idleMs=%s movement=%s",
    DEBUG_SNAPSHOT_DYNAMIC_STATE = "dynamic state active=%s combatActive=%s phase=%s accumulatedAbs=%s lastHeading=%s",
    DEBUG_SNAPSHOT_DYNAMIC_STATE_NONE = "dynamic state=nil",
    DEBUG_SNAPSHOT_HEADING = "direction current=%s",
    DEBUG_SNAPSHOT_END = "==== EZOcamsens debug snapshot end ====",
  }
}

function ADDON:InitLocale()
  local sel = (self.sv and self.sv.language) or self:GetDefaultLanguage()
  local lang = self:GetEffectiveLanguage(sel)
  self.lang = lang
  self.str = STR[lang] or STR.en
end

function ADDON:Text(key)
  return (self.str and self.str[key]) or (STR.en[key]) or key
end

function ADDON:RefreshLAM()
  if self.ezoSettingsRegistered
      and EZOCore
      and type(EZOCore.RefreshSettingsPanel) == "function" then
    EZOCore:RefreshSettingsPanel()
  end

  if self.lamPanel then
    CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", self.lamPanel)
  end
end

function ADDON:ShowCommandHelp()
  self:PrintUserLines({
    self:Text("CMD_TITLE"),
    self:Text("CMD_STATUS"),
    self:Text("CMD_APPLY"),
    self:Text("CMD_DEBUG"),
  }, { forceChat = true })
end

function ADDON:ExecuteDebugCommand()
  if not self:RequireDebugViewer() then return true end
  self:DumpDebugSnapshot()
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

local TARGET_MIN = 0.10
local TARGET_MAX = 5.00

local CVARS = {
  TP_H = { "GamepadSensitivityThirdPerson.2", "GamepadSensitivityThirdPersonX" },
}

local BASE_AXIS_ORDER = { "TP_H" }

local function getCVarValue(name)
  local ok, v = pcall(GetCVar, name)
  if ok then return v end
  return nil
end

local function setCVarValue(name, value)
  local ok = pcall(SetCVar, name, value)
  return ok
end

local function getAxisCVarNames(axisKey)
  return CVARS[axisKey] or {}
end

local function setAxisCVarValues(axisKey, value)
  local okAny = false
  for _, name in ipairs(getAxisCVarNames(axisKey)) do
    if setCVarValue(name, value) then
      okAny = true
    end
  end
  return okAny
end

local function clamp(v)
  v = tonumber(v) or 1.00
  if v < TARGET_MIN then v = TARGET_MIN end
  return v
end

local function readAxisCVarValue(axisKey)
  for _, name in ipairs(getAxisCVarNames(axisKey)) do
    local cvarValue = getCVarValue(name)
    local cvarNumber = tonumber(cvarValue)
    if cvarNumber then
      return cvarNumber, string.format("%.2f", cvarNumber)
    end
  end
  return nil, "n/a"
end

local function describeAxisCVarValues(axisKey)
  local values = {}
  for _, name in ipairs(getAxisCVarNames(axisKey)) do
    local value = getCVarValue(name)
    values[#values + 1] = string.format("%s=%s", name, tostring(value or "n/a"))
  end
  return table.concat(values, ", ")
end

local function readAxisValue(axisKey)
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

  for _, axisKey in ipairs(BASE_AXIS_ORDER) do
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
  if source == "cvar" then
    return ADDON:Text("SOURCE_CVAR")
  end
  return ADDON:Text("SOURCE_NONE")
end

local function describeAxis(axisKey)
  return ADDON:Text("AXIS_TP_H")
end

local function applyAxisValue(axisKey, target)
  if setAxisCVarValues(axisKey, target) then
    local _, cvarValue = readAxisCVarValue(axisKey)
    if valuesMatch(cvarValue, target) then
      return cvarValue, ADDON:Text("METHOD_FALLBACK")
    end
    local _, fallbackValue = readAxisValue(axisKey)
    return fallbackValue or "n/a", ADDON:Text("METHOD_UNCHANGED")
  end

  local _, actualValue = readAxisValue(axisKey)
  return actualValue or "n/a", ADDON:Text("METHOD_UNCHANGED")
end

function ADDON:ApplyPresets(options)
  options = options or {}
  local forceChat = options.forceChat == true

  if (not options.bypassGamepadGuard) and (not guardGamepad()) then
    if not options.suppressFeedback then
      warnRed(self:Text("GAMEPAD_ONLY_WARN"), forceChat)
    end
    return
  end

  local targets, clampedAxes = buildTargetValues()
  local actualValues = {}
  local methods = {}
  for _, axisKey in ipairs(BASE_AXIS_ORDER) do
    if targets[axisKey] then
      actualValues[axisKey], methods[axisKey] = applyAxisValue(axisKey, targets[axisKey])
    end
  end
  local _, _, sourceTpH = readAxisValue("TP_H")
  local applyLines = {
    self:Text("APPLY_VIEWER_START"),
    self:Text("APPLY_DONE"),
    string.format(self:Text("APPLY_SUMMARY"), tostring(targets.TP_H), tostring(actualValues.TP_H)),
    string.format(self:Text("APPLY_METHODS"), tostring(methods.TP_H)),
    string.format(self:Text("APPLY_SOURCE"), describeReadSource(sourceTpH)),
    string.format(self:Text("APPLY_CVARS"), describeAxis("TP_H"), describeAxisCVarValues("TP_H")),
  }

  if #clampedAxes > 0 then
    applyLines[#applyLines + 1] = string.format(self:Text("CLAMP_WARN"), table.concat(clampedAxes, ", "))
  end

  applyLines[#applyLines + 1] = self:Text("APPLY_VIEWER_END")

  if not options.suppressFeedback then
    if #clampedAxes > 0 then
      warnRed(string.format(self:Text("CLAMP_WARN"), table.concat(clampedAxes, ", ")), forceChat)
    end

    info(self:Text("APPLY_DONE"), forceChat)
  end

  if isDebugEnabled() then
    self:SafeDebugViewer(table.concat(applyLines, "\n"), "Info")
  end
end

function ADDON:ApplyDynamicCameraValue(value, options)
  options = options or {}
  if (not options.bypassGamepadGuard) and (not guardGamepad()) then
    return nil, self:Text("METHOD_UNCHANGED"), nil
  end

  local target = normalizeTarget("TP_H", value)
  local actualTpH, methodTpH = applyAxisValue("TP_H", target)
  local _, _, sourceTpH = readAxisValue("TP_H")
  return actualTpH, methodTpH, sourceTpH
end

local function buildStatusLines()
  local _, tpH, sourceTpH = readAxisValue("TP_H")
  local _, cvarTpH = readAxisCVarValue("TP_H")
  local lines = {
    string.format(ADDON:Text("STATUS_SAVED"), string.format("%.2f", clamp(ADDON.sv.tpH))),
    string.format(ADDON:Text("STATUS_REAL"), tostring(tpH)),
    string.format(ADDON:Text("STATUS_CVAR"), tostring(cvarTpH)),
    string.format(ADDON:Text("STATUS_SOURCE"), describeReadSource(sourceTpH)),
  }

  return lines
end

function ADDON:PrintStatus(options)
  options = options or {}
  local forceChat = options.forceChat ~= false
  local lines = buildStatusLines()

  for _, line in ipairs(lines) do
    info(line, forceChat)
  end
end

function ADDON:SendStatusToDebugViewer()
  if not self:RequireDebugViewer() then return end

  local lines = buildStatusLines()
  local batch = self:CreateDebugBatch("Info")
  self:DebugBatchAdd(batch, self:Text("STATUS_VIEWER_START"))
  for _, line in ipairs(lines) do
    self:DebugBatchAdd(batch, line)
  end
  self:DebugBatchAdd(batch, self:Text("STATUS_VIEWER_END"))
  self:DebugBatchFlush(batch)
end

local function debugValue(value)
  if value == nil then
    return "nil"
  end
  return tostring(value)
end

local function debugBool(value)
  return value and "true" or "false"
end

local function debugNumber(value)
  local num = tonumber(value)
  if num == nil then
    return debugValue(value)
  end
  return string.format("%.2f", num)
end

local function getPlayerNameForDebug()
  local ok, name = pcall(GetUnitName, "player")
  if ok and type(name) == "string" and name ~= "" then
    return name
  end
  return "n/a"
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

function ADDON:IsPlayerTankRole()
  if LFG_ROLE_TANK == nil then return false end
  local ok, role = pcall(GetSelectedLFGRole)
  return ok and role == LFG_ROLE_TANK
end

function ADDON:IsDynamicTurnAllowed()
  if self.sv and self.sv.dynamicOnlyInCombat and not self:IsPlayerInCombat() then
    return false
  end
  if self.sv and self.sv.dynamicOnlyTankRole and not self:IsPlayerTankRole() then
    return false
  end
  return true
end

function ADDON:ApplyDynamicSensitivity(value, textKey, ...)
  local actualTpH, methodTpH = self:ApplyDynamicCameraValue(value, { suppressFeedback = true })
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
    if not self:IsDynamicTurnAllowed() then
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

  if self:IsDynamicTurnAllowed() then
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

  if not self:IsDynamicTurnAllowed() then
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

function ADDON:DumpDebugSnapshot()
  if not self:RequireDebugViewer() then return end

  local sv = self.sv or {}
  local _, currentTpH, sourceTpH = readAxisValue("TP_H")
  local _, cvarTpH = readAxisCVarValue("TP_H")
  local heading = self:GetCurrentCameraHeadingDegrees()
  local state = self.dynamicTurn
  local batch = self:CreateDebugBatch("DebugSnapshot")

  self:DebugBatchAdd(batch, self:Text("DEBUG_SNAPSHOT_START"))
  self:DebugBatchAdd(batch, string.format(self:Text("DEBUG_SNAPSHOT_VERSION"), debugValue(self.version)))
  self:DebugBatchAdd(batch, string.format(self:Text("DEBUG_SNAPSHOT_LOCALE"), debugValue(self.lang), debugValue(sv.language)))
  self:DebugBatchAdd(batch, string.format(self:Text("DEBUG_SNAPSHOT_PROFILE"), debugValue(self.serverProfile), debugValue(self:GetSettingsScope()), debugValue(getPlayerNameForDebug())))
  self:DebugBatchAdd(batch, string.format(self:Text("DEBUG_SNAPSHOT_DEBUG"), debugBool(self:IsDebugModeEnabled()), debugBool(self:HasDebugViewer())))
  self:DebugBatchAdd(batch, string.format(self:Text("DEBUG_SNAPSHOT_CHAT_GAMEPAD"), debugBool(sv.chatEnabled), debugBool(sv.applyOnlyInGamepad), debugBool(isGamepad())))
  self:DebugBatchAdd(batch, string.format(self:Text("DEBUG_SNAPSHOT_COMBAT"), debugBool(self:IsPlayerInCombat()), debugBool(self:IsPlayerTankRole()), debugBool(sv.dynamicOnlyTankRole)))
  self:DebugBatchAdd(batch, string.format(self:Text("DEBUG_SNAPSHOT_TPH"), debugNumber(sv.tpH), debugValue(currentTpH), debugValue(cvarTpH), describeReadSource(sourceTpH)))
  self:DebugBatchAdd(batch, string.format(self:Text("DEBUG_SNAPSHOT_DYNAMIC"), debugBool(sv.dynamicEnabled), debugBool(sv.dynamicOnlyInCombat), debugBool(sv.dynamicOnlyTankRole), debugNumber(sv.dynamicFastTpH), debugNumber(sv.dynamicSlowTpH), debugNumber(sv.dynamicAngleThreshold), debugNumber(sv.dynamicIdleResetMs), debugNumber(sv.dynamicMovementThreshold)))

  if state then
    self:DebugBatchAdd(batch, string.format(self:Text("DEBUG_SNAPSHOT_DYNAMIC_STATE"), debugBool(state.active), debugBool(state.combatActive), debugValue(state.phase), debugNumber(state.accumulatedAbsDeg), debugNumber(state.lastHeadingDeg)))
  else
    self:DebugBatchAdd(batch, self:Text("DEBUG_SNAPSHOT_DYNAMIC_STATE_NONE"))
  end

  self:DebugBatchAdd(batch, string.format(self:Text("DEBUG_SNAPSHOT_HEADING"), debugNumber(heading)))
  self:DebugBatchAdd(batch, self:Text("DEBUG_SNAPSHOT_END"))
  self:DebugBatchFlush(batch)
end
