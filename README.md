# EZOcamsens

Addon independiente para The Elder Scrolls Online.

## Desarrollo local

- Repositorio local: `Z:\Dev\EZOcamsens`
- Carpeta de addons de ESO: `C:\Users\zurip\Documents\Elder Scrolls Online\live\AddOns`
- Enlace esperado: `C:\Users\zurip\Documents\Elder Scrolls Online\live\AddOns\EZOcamsens -> Z:\Dev\EZOcamsens`

## Alcance actual

El addon solo gestiona una variable de juego:

- `GamepadSensitivityThirdPersonX`

Todo el codigo, menu y restauracion por defecto se han simplificado para dejar
estable el ajuste de sensibilidad horizontal de tercera persona antes de crecer
hacia otros ejes o perspectivas.

## Valor base del juego

Valor base tomado del perfil PTS limpio usado como referencia:

- `GamepadSensitivityThirdPersonX = 0.85`

## Conclusión tras comparar con el addon original

Al comparar este proyecto con el ZIP original de ChatGPT, la diferencia importante
no estaba en qué variables existen en `UserSettings.txt`, sino en cómo se aplicaban
los cambios dentro de ESO.

Decision de proyecto:

- Detectar primero el control nativo de tercera persona horizontal en
  `ZO_OptionsPanel_Camera_ControlData[SETTING_TYPE_GAMEPAD]`.
- Aplicar por `SetSetting(...)` cuando ese control exista.
- Mantener `SetCVar("GamepadSensitivityThirdPersonX", ...)` como fallback.
- Restaurar valores por defecto al valor base real del juego (`0.85`), no a un
  snapshot del usuario.
- Mantener el panel del addon pequeño y centrado en `third-person horizontal`.

Para recrear el entorno local:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\setup-dev.ps1
```

En esta máquina la política actual de PowerShell ya permite ejecutar scripts locales con `RemoteSigned`, pero la creación del `symlink` requiere abrir PowerShell como administrador.
