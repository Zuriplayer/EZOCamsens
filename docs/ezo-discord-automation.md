# EZO Discord automation

Este repositorio usa una configuracion local por addon en `ezo-addon.json`. No depende de un catalogo global para publicar builds.

## Objetivo

- Generar un ZIP limpio en `dist/`.
- Mantener fuera del ZIP los archivos internos de desarrollo.
- Publicar estado, beta builds, releases, downloads, announcements y codex-log en Discord mediante GitHub Actions.
- No guardar URLs reales de webhooks en el repositorio.

## Configuracion local

`ezo-addon.json` define el nombre real del addon, version visible, manifest runtime, carpeta raiz dentro del ZIP, reglas de inclusion/exclusion y nombres de secretos esperados.

Para EZOcamsens, el ZIP se genera como:

```text
dist/EZOcamsens_v1.7.16.zip
```

Dentro del ZIP siempre debe existir una carpeta raiz:

```text
EZOcamsens/
```

## Uso recomendado de canales

- `#addon-status`: estado tecnico corto del addon. No adjunta ZIP.
- `#beta-builds`: builds para testers. Adjunta ZIP limpio.
- `#releases`: nota tecnica de release. No adjunta ZIP por defecto.
- `#downloads`: canal limpio de descarga. Adjunta ZIP limpio.
- `#announcements`: aviso humano para jugadores/testers. No adjunta ZIP por defecto.
- `#codex-log`: log interno de automatizacion. No adjunta ZIP.

El ZIP va en `#beta-builds` para pruebas y en `#downloads` para descargas finales. No se duplican binarios en canales informativos.

## Procedimiento de publicacion

La publicacion en Discord no forma parte de cada commit o push. Se trata como un paso separado de release.

Flujo normal de trabajo:

```text
editar -> probar -> commit -> push
```

Flujo de publicacion cuando el cambio ya es util para jugadores:

```text
validar ZIP limpio -> pedir confirmacion -> lanzar workflow Discord
```

Codex debe proponer una publicacion en Discord solo cuando el cambio aporta una mejora funcional real, una correccion importante o una version suficientemente estable para jugadores.

Antes de lanzar cualquier workflow que publique en Discord, Codex debe pedir confirmacion explicita:

```text
Este cambio parece publicable. Que quieres hacer?
- status
- beta
- release + download
- no publicar
```

Los workflows tienen una barrera tecnica:

```text
confirm_publish = DRY_RUN
```

Con el valor por defecto no se envia nada a Discord. Para publicar de verdad, el campo debe escribirse exactamente como:

```text
PUBLISH
```

En el workflow de release, `publish_download` y `publish_announcement` estan desactivados por defecto. Activarlos requiere autorizacion expresa.

## Workflows

- `EZO addon status`: publica estado en `#addon-status` y log interno.
- `EZO beta build`: genera ZIP limpio, artifact y publicacion en `#beta-builds`.
- `EZO release`: genera ZIP limpio, publica release, descarga, announcement opcional y log interno.

## Pruebas locales seguras

Estos comandos no publican nada a Discord:

```powershell
Get-Content .\ezo-addon.json -Raw | ConvertFrom-Json
.\scripts\ezo\publish-status.ps1 -DryRun
.\scripts\ezo\build-addon-package.ps1 -Force
```

Para revisar el contenido del ZIP:

```powershell
Expand-Archive .\dist\EZOcamsens_v1.7.16.zip -DestinationPath .\dist\check -Force
Get-ChildItem .\dist\check -Recurse -File
```
