# EZOcamsens

EZOcamsens is a beta addon for The Elder Scrolls Online focused on controller camera sensitivity in third person.

Current scope: third-person horizontal camera sensitivity for gamepad play.

## Beta Status

This addon is in public beta. It is intentionally small and conservative:

- It only manages third-person horizontal sensitivity for controller use.
- It does not manage first-person camera sensitivity.
- It does not manage vertical sensitivity. A vertical prototype was tested and discarded for now because the useful range is small and reliable behaviour would add too much complexity for the current goal.
- It does not modify ESO input, keybind navigation, vanilla menus or combat actions.

## Requirements

- The Elder Scrolls Online.
- LibAddonMenu-2.0.
- LibChatMessage.
- Optional: LibDebugLogger and DebugLogViewer for debug output.

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
- No real Discord webhook URLs, tokens or secrets are stored in this repository.

## Testing Notes

Recommended beta checks:

- Change the normal third-person horizontal value and confirm it applies in gamepad mode.
- Use `Apply setting` and confirm the value is restored in the ESO camera feel.
- Use `Restore defaults` and confirm the value returns to `0.85`.
- Test dynamic horizontal mode in combat and out of combat.
- If debug mode is enabled, use `/ezocamsens debug` and inspect DebugLogViewer.

## Known Limits

- First-person support was removed because ESO did not behave consistently enough for this addon scope.
- Vertical camera management is documented as intentionally out of scope for now.
- The addon targets controller/gamepad play.

## License

MIT. See [LICENSE](LICENSE).
