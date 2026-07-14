# Changelog

## Unreleased

- Registers the settings panel with EZOCore when available, so EZOcamsens appears under the central `Settings > EZO` menu.
- Keeps the existing LibAddonMenu panel available as a compatibility fallback.

## 1.7.16 - Public beta

- Stabilized the addon around third-person horizontal controller sensitivity.
- Applies the managed setting through `GamepadSensitivityThirdPerson.2` and `GamepadSensitivityThirdPersonX`.
- Keeps first-person and vertical camera management out of scope.
- Includes experimental horizontal dynamic turn mode.
- Supports per-server storage, with per-character or account-wide settings.
- Keeps debug output behind the addon debug setting and DebugLogViewer/LibDebugLogger.
- Documents why the vertical prototype was discarded for now.
- Prepares repository metadata, ignore rules, changelog and MIT license for public beta publication.
