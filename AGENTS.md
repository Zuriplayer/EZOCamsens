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

## Versionado y APIVersion

- Para cualquier cambio visible del addon, actualizar version con `.\tools\bump-version.ps1 -Patch` o `.\tools\bump-version.ps1 -Version x.y.z`.
- Si el cambio se prepara para release o hay parche de ESO, comprobar la API actual con `/script d(GetAPIVersion())` o fuente fiable ESOUI/UESP.
- `## APIVersion` controla si ESO muestra el addon como desactualizado en la pantalla de complementos/addons.
- No adivinar `## APIVersion`; solo cambiarlo si el valor actual esta verificado.
- Usar `.\tools\bump-version.ps1 -Patch -ApiVersion <api_actual>` para actualizar version y API.
- Mantener como maximo dos valores en `## APIVersion`; ESO ignora entradas adicionales.
- Antes de commit/release ejecutar `.\tools\bump-version.ps1 -Check -ApiVersion <api_actual>` y `git diff --check`.

## Checklist mínima

- El addon carga sin errores Lua.
- `ReloadUI()` no rompe el estado.
- El manifest `EZOcamsens.txt` referencia todos los archivos necesarios.
## Publicacion en Discord

- La publicacion en Discord es un paso separado de commit/push.
- No lanzar workflows de Discord automaticamente tras cada cambio.
- Proponer publicacion solo para cambios funcionales reales, correcciones importantes o versiones suficientemente estables para jugadores.
- Antes de lanzar un workflow de Discord, pedir confirmacion explicita indicando la opcion: `status`, `beta`, `release + download` o `no publicar`.
- Los workflows de Discord tienen `confirm_publish` con valor por defecto `DRY_RUN`; solo publicar si el usuario ha autorizado explicitamente y se escribe exactamente `PUBLISH`.
- No activar `publish_download` ni `publish_announcement` salvo autorizacion expresa del usuario.
- Para detalles operativos, usar `docs/ezo-discord-automation.md`.
