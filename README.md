# EZOcamsens

EZOcamsens is a public beta addon for The Elder Scrolls Online focused on controller camera sensitivity in third person.

¿Prefieres español? Lee el [README en español](README.es.md).
Support, bug reports and suggestions: https://discord.gg/ekw8zUAcRm

Current scope: third-person horizontal camera sensitivity for gamepad play, including an optional experimental dynamic turn mode.

## Beta Status

This addon is in public beta. It is intentionally small and conservative:

- It only manages third-person horizontal sensitivity for controller use.
- It does not manage first-person camera sensitivity.
- It does not manage vertical sensitivity. A vertical prototype was tested and discarded for now because the useful range is small and reliable behaviour would add too much complexity for the current goal.
- It does not modify ESO input, keybind navigation, vanilla menus or combat actions.
- It keeps debug output behind the addon debug option and DebugLogViewer/LibDebugLogger.

## Requirements

- The Elder Scrolls Online.
- LibAddonMenu-2.0.
- LibChatMessage.
- Optional: LibDebugLogger and DebugLogViewer for debug output.
- Optional: EZOCore to place the addon options under the central `Settings > EZO` menu.

## Installation

1. Download the beta ZIP.
2. Extract it into your ESO AddOns folder.
3. The final folder should look like:

```text
Elder Scrolls Online/live/AddOns/EZOcamsens/
```

4. Enable `EZOcamsens` from the ESO Add-Ons menu.
5. Reload the UI if ESO asks for it.

## Main Features

- Adjusts third-person horizontal controller camera sensitivity.
- Applies both supported CVar paths used by ESO for this setting:
  - `GamepadSensitivityThirdPerson.2`
  - `GamepadSensitivityThirdPersonX`
- Stores settings separated by server.
- Lets you choose whether settings are saved per character or account-wide.
- Includes an experimental horizontal dynamic mode:
  - Fast horizontal sensitivity at the start of a turn.
  - Normal/slower horizontal sensitivity after the configured angle.
  - Optional combat-only mode.
  - Optional tank-role-only mode.
- Supports English and Spanish UI text.

## Addon Options

When EZOCore is installed, `Settings > EZO` opens the central EZO hub and links to this addon panel. The normal LibAddonMenu panel remains available as a compatibility fallback.

- Settings storage:
  - Per character.
  - Account-wide within the same server.
- Base sensitivity:
  - Third-person horizontal sensitivity.
  - Apply setting button to reapply the saved value.
- Experimental dynamic turn:
  - Enable dynamic turn.
  - Apply only in combat.
  - Only if my role is tank.
  - Fast sensitivity.
  - Slow sensitivity.
  - Angle before slow mode.
  - Idle reset in milliseconds.
  - Minimum movement to count a turn.
- Behaviour:
  - Apply only in gamepad mode.
  - Show feedback in chat.
- Support and debug:
  - Enable debug mode.
  - Show current values in DebugLogViewer.
- Language and reset:
  - Automatic, Spanish or English.
  - Restore defaults.

## Commands

```text
/ezocamsens
/ezocamsens status
/ezocamsens apply
/ezocamsens debug
```

`/ezocamsens debug` requires debug mode in the addon settings and DebugLogViewer/LibDebugLogger.

## Safety Limits

- The addon only writes the camera sensitivity CVars listed above.
- Restore defaults returns the managed third-person horizontal sensitivity to the game default value from a clean PTS profile: `0.85`.
- Debug output is sent to DebugLogViewer when debug mode is enabled.
- `/ezocamsens debug` is blocked unless debug mode is enabled.
- The dynamic mode only changes the same third-person horizontal sensitivity value; it does not turn the camera, move the character or automate combat.
- The tank-role option only checks the selected ESO group role; it does not change role, queue status or group state.
- No real Discord webhook URLs, tokens or secrets are stored in this repository.

## Testing Notes

Recommended beta checks:

- Change the normal third-person horizontal value and confirm it applies in gamepad mode.
- Use `Apply setting` and confirm the value is restored in the ESO camera feel.
- Use `Restore defaults` and confirm the value returns to `0.85`.
- Test dynamic horizontal mode in combat and out of combat.
- Test the `Apply only in gamepad mode` option with gamepad preferred mode enabled and disabled.
- Test per-character and account-wide storage on the same server after a UI reload.
- Test Spanish, English and automatic language selection.
- If debug mode is enabled, use `/ezocamsens debug` and inspect DebugLogViewer.

## Known Limits

- First-person support was removed because ESO did not behave consistently enough for this addon scope.
- Vertical camera management is documented as intentionally out of scope for now.
- The addon targets controller/gamepad play.
- The experimental dynamic mode depends on ESO camera heading readback being available in the current game session.

## License

MIT. See [LICENSE](LICENSE).
