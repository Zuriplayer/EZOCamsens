# EZOcamsens

EZOcamsens es un addon en beta pública para The Elder Scrolls Online centrado en la sensibilidad de cámara con mando en tercera persona.

Prefer English? Read the [README in English](README.md).
Soporte, errores y sugerencias: https://discord.gg/ekw8zUAcRm

Alcance actual: sensibilidad horizontal de cámara en tercera persona para juego con mando, incluyendo un modo experimental opcional de giro dinámico.

## Estado Beta

Este addon está en beta pública. Es pequeño y conservador de forma intencionada:

- Solo gestiona la sensibilidad horizontal en tercera persona para uso con mando.
- No gestiona la sensibilidad de cámara en primera persona.
- No gestiona la sensibilidad vertical. Se probó un prototipo vertical y se descartó por ahora porque el rango útil es pequeño y hacerlo fiable añadiría demasiada complejidad para el objetivo actual.
- No modifica input de ESO, navegación de keybinds, menús vanilla ni acciones de combate.
- Mantiene la salida de debug detrás de la opción de debug del addon y DebugLogViewer/LibDebugLogger.

## Requisitos

- The Elder Scrolls Online.
- LibAddonMenu-2.0.
- LibChatMessage.
- Opcional: LibDebugLogger y DebugLogViewer para la salida de debug.
- Opcional: EZOCore para mostrar las opciones del addon bajo el menú central `Settings > EZO`.

## Instalación

1. Descarga el ZIP beta.
2. Extrae el contenido en la carpeta de AddOns de ESO.
3. La carpeta final debe quedar así:

```text
Elder Scrolls Online/live/AddOns/EZOcamsens/
```

4. Activa `EZOcamsens` desde el menú de complementos de ESO.
5. Recarga la interfaz si ESO lo solicita.

## Funciones Principales

- Ajusta la sensibilidad horizontal de cámara con mando en tercera persona.
- Aplica las dos rutas CVar usadas por ESO para este ajuste:
  - `GamepadSensitivityThirdPerson.2`
  - `GamepadSensitivityThirdPersonX`
- Guarda los ajustes separados por servidor.
- Permite elegir si los ajustes se guardan por personaje o se comparten por cuenta.
- Incluye un modo experimental de giro dinámico horizontal:
  - Sensibilidad horizontal rápida al comenzar el giro.
  - Sensibilidad normal/lenta después del ángulo configurado.
  - Opción de usarlo solo en combate.
  - Opción de usarlo solo si el rol marcado es tanque.
- Incluye textos de interfaz en español e inglés.

## Opciones Del Addon

Cuando EZOCore está instalado, EZOcamsens se configura directamente dentro de `Settings > EZO` y no añade una entrada duplicada a la lista estándar de configuración. Su panel independiente de LibAddonMenu solo se registra como fallback de compatibilidad cuando EZOCore no está disponible.

El panel de configuración sigue el estilo de la familia EZO: cada cabecera de sección tiene un icono informativo morado con ayuda general en su tooltip, y cada campo mantiene su ayuda concreta en el tooltip del propio campo. Los párrafos explicativos largos no quedan visibles de forma permanente en el panel.

- Guardado de ajustes:
  - Por personaje.
  - Por cuenta dentro del mismo servidor.
- Sensibilidad base:
  - Sensibilidad horizontal en tercera persona.
  - Botón Aplicar ajuste para volver a aplicar el valor guardado.
- Giro dinámico experimental:
  - Activar giro dinámico.
  - Aplicar solo en combate.
  - Solo si tengo rol de tanque.
  - Sensibilidad rápida.
  - Sensibilidad lenta.
  - Ángulo para cambiar a lento.
  - Reposo para reiniciar en milisegundos.
  - Movimiento mínimo para contar giro.
- Comportamiento:
  - Aplicar solo en modo gamepad.
  - Mostrar mensajes en chat.
- Soporte y debug:
  - Activar modo debug.
  - Mostrar valores actuales en DebugLogViewer.
- Idioma y restauración:
  - Automático, español o inglés.
  - Restaurar valores por defecto.

## Comandos

```text
/ezocamsens
/ezocamsens status
/ezocamsens apply
/ezocamsens debug
```

`/ezocamsens debug` requiere activar el modo debug en la configuración del addon y tener DebugLogViewer/LibDebugLogger.

## Límites De Seguridad

- El addon solo escribe las CVars de sensibilidad de cámara indicadas arriba.
- Restaurar valores por defecto devuelve la sensibilidad horizontal gestionada de tercera persona al valor por defecto tomado de un perfil PTS limpio: `0.85`.
- La salida de debug se envía a DebugLogViewer cuando el modo debug está activo.
- `/ezocamsens debug` se bloquea si el modo debug no está activado.
- El modo dinámico solo cambia la misma sensibilidad horizontal de tercera persona; no gira la cámara, no mueve al personaje ni automatiza combate.
- La opción de rol tanque solo comprueba el rol de grupo seleccionado en ESO; no cambia rol, cola ni estado del grupo.
- Este repositorio no guarda URLs reales de webhooks de Discord, tokens ni secretos.

## Pruebas Recomendadas

Comprobaciones recomendadas para beta:

- Cambiar el valor normal de tercera persona horizontal y confirmar que se aplica en modo gamepad.
- Usar `Aplicar ajuste` y confirmar que se restaura la sensación de cámara esperada en ESO.
- Usar `Restaurar valores por defecto` y confirmar que el valor vuelve a `0.85`.
- Probar el modo dinámico horizontal dentro y fuera de combate.
- Probar la opción `Aplicar solo en modo gamepad` con el modo preferente de gamepad activado y desactivado.
- Probar el guardado por personaje y por cuenta en el mismo servidor después de recargar la interfaz.
- Probar la selección de idioma en español, inglés y automático.
- Abrir el panel de configuración y confirmar que cada cabecera de sección muestra el icono informativo morado y su ayuda en tooltip.
- Si el modo debug está activo, usar `/ezocamsens debug` y revisar DebugLogViewer.

## Límites Conocidos

- El soporte de primera persona se eliminó porque ESO no se comportaba de forma suficientemente consistente para el alcance de este addon.
- La gestión vertical de cámara queda intencionadamente fuera del alcance actual.
- El addon está orientado al uso con mando/gamepad.
- El modo dinámico experimental depende de que la lectura de dirección de cámara de ESO esté disponible en la sesión actual del juego.

## Licencia

MIT. Consulta [LICENSE](LICENSE).
