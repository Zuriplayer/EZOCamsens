# EZOcamsens

Addon independiente para The Elder Scrolls Online.

## Desarrollo local

- Repositorio local: `Z:\Dev\EZOcamsens`
- Carpeta de addons de ESO: `C:\Users\zurip\Documents\Elder Scrolls Online\live\AddOns`
- Enlace esperado: `C:\Users\zurip\Documents\Elder Scrolls Online\live\AddOns\EZOcamsens -> Z:\Dev\EZOcamsens`

## Variables relevantes detectadas

Tras analizar `UserSettings.txt`, las variables importantes para este addon son las
cuatro CVars de sensibilidad de mando por eje y perspectiva:

- `GamepadSensitivityFirstPersonX`
- `GamepadSensitivityFirstPersonY`
- `GamepadSensitivityThirdPersonX`
- `GamepadSensitivityThirdPersonY`

Estas son las que usa el addon para ajustar sensibilidad horizontal/vertical en
primera y tercera persona. Las entradas `MouseSensitivity*` no forman parte del
objetivo del addon, y `GamepadSensitivityFirstPerson.2` / `GamepadSensitivityThirdPerson.2`
quedan fuera hasta que se verifique en el propio juego que afectan al comportamiento
que queremos controlar.

## Conclusión tras comparar con el addon original

Al comparar este proyecto con el ZIP original de ChatGPT, la diferencia importante
no estaba en qué variables existen en `UserSettings.txt`, sino en cómo se aplicaban
los cambios dentro de ESO.

Estrategia del addon original:

- Detectar primero los sliders reales del panel de opciones de mando en
  `ZO_OptionsPanel_Camera_ControlData[SETTING_TYPE_GAMEPAD]`.
- Aplicar los cambios por `SetSetting(SETTING_TYPE_GAMEPAD, id, value)`.
- Usar `SetCVar(...)` solo como metodo alternativo si el ajuste nativo fallaba.
- Si no se estaba en modo gamepad y estaba activa la opcion correspondiente,
  bloquear la aplicacion en lugar de forzar valores.

Estrategia introducida despues:

- Usar directamente las CVars `GamepadSensitivityFirstPersonX/Y` y
  `GamepadSensitivityThirdPersonX/Y` como via principal.
- Dejar de depender de `SetSetting/GetSetting` y de la deteccion dinamica de sliders.
- Añadir una capa de "modo seguro" que fuerza valores por defecto fuera de ciertas
  condiciones.

Decision de proyecto:

- La aplicacion principal de sensibilidad debe seguir la estrategia del addon
  original.
- Las CVars deducidas desde `UserSettings.txt` son utiles como referencia y como
  fallback, pero no deben sustituir por defecto la via nativa del juego.
- Antes de añadir capas de seguridad o automatismos, hay que preservar primero
  el camino de aplicacion que ya habia demostrado funcionar mejor en juego.

Para recrear el entorno local:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\setup-dev.ps1
```

En esta máquina la política actual de PowerShell ya permite ejecutar scripts locales con `RemoteSigned`, pero la creación del `symlink` requiere abrir PowerShell como administrador.
