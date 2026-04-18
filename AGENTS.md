# EZOcamsens — Reglas de desarrollo

Este proyecto es un addon independiente para The Elder Scrolls Online.

## Reglas

- No integrar este addon con otros proyectos `EZO*` salvo petición expresa.
- No asumir APIs de ESO que no existan o no estén verificadas en el propio código.
- Mantener cambios pequeños y fáciles de revisar.
- Si se añade un archivo nuevo al addon, incluirlo en `EZOcamsens.txt`.
- Evitar globals innecesarias; usar `EZOcamsens = EZOcamsens or {}` si aplica.
- No usar `os.*`, `io.*`, `require()` ni librerías estándar no soportadas por ESO.

## Convenciones

- Inicialización en `EVENT_ADD_ON_LOADED`.
- Respetar la separación entre lógica, UI y persistencia.
- No cambiar XML o keybinds sin necesidad clara.
- Mantener compatibilidad con teclado y gamepad cuando corresponda.

## Checklist mínima

- El addon carga sin errores Lua.
- `ReloadUI()` no rompe el estado.
- El manifest `EZOcamsens.txt` referencia todos los archivos necesarios.
