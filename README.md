# EZOcamsens

Addon independiente para The Elder Scrolls Online.

## Desarrollo local

- Repositorio local: `\\RZRNAS\Zuriplayer\Dev\EZOcamsens`
- Carpeta de addons de ESO: `C:\Users\zurip\Documents\Elder Scrolls Online\live\AddOns`
- Enlace esperado: `C:\Users\zurip\Documents\Elder Scrolls Online\live\AddOns\EZOcamsens -> \\RZRNAS\Zuriplayer\Dev\EZOcamsens`

## Alcance actual

El addon gestiona un valor horizontal para mando:

- `GamepadSensitivityThirdPerson.2` y `GamepadSensitivityThirdPersonX`

El menú queda centrado en tercera persona horizontal. Primera persona queda fuera
del alcance del addon.

## Valor base del juego

Valor base tomado del perfil PTS limpio usado como referencia:

- `GamepadSensitivityThirdPersonX = 0.85`
- `GamepadSensitivityThirdPerson.2 = 0.85`

## Conclusión tras comparar con el addon original

Al comparar este proyecto con el ZIP original de ChatGPT, la diferencia importante
no estaba en qué variables existen en `UserSettings.txt`, sino en cómo se aplicaban
los cambios dentro de ESO.

Decisión de proyecto:

- No usar `SetSetting(...)` para la sensibilidad base de mando: los controles
  nativos publicados son sensibilidad general de cámara, no horizontal de mando.
- Aplicar las CVar `.2` y `X` de tercera persona, porque el juego puede leer una
  u otra ruta según versión y modo.
- Restaurar valores por defecto a los valores base reales del juego, no a un
  snapshot del usuario.
- Mantener el panel pequeño y centrado en sensibilidad horizontal con mando.

Para recrear el entorno local:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\setup-dev.ps1
```

En esta máquina la política actual de PowerShell ya permite ejecutar scripts locales con `RemoteSigned`, pero la creación del `symlink` requiere abrir PowerShell como administrador.
