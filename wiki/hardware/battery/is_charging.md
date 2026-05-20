# `hardware::battery::is_charging`

_No description available._

## Source

```bash
hardware::battery::is_charging() {
    case "$(runtime::os)" in
    linux|wsl)
        local bat
        bat=$(_hardware::battery::find_bat)
        [[ -z "$bat" ]] && return 1
        [[ "$(cat "${bat}/status" 2>/dev/null)" == "Charging" ]]
        ;;
    darwin)
        pmset -g batt 2>/dev/null | grep -q 'AC Power'
        ;;
    freebsd|dragonfly)
        sysctl -n hw.acpi.acline 2>/dev/null | grep -q '^1$'
        ;;
    openbsd)
        local state
        state="$(sysctl -n hw.sensors.acpibat0.raw0 2>/dev/null)"
        state="${state##? (battery }"
        state="${state%)*}"
        [[ "$state" == "charging" ]]
        ;;
    cygwin|mingw)
        local state
        state="$(wmic /NameSpace:'\\root\WMI' Path BatteryStatus get Charging 2>/dev/null)"
        [[ "$state" == *TRUE* ]]
        ;;
    *)
        return 1
        ;;
    esac
}
```

## Module

[`hardware`](../hardware.md)
