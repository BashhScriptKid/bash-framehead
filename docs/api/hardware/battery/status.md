# `hardware::battery::status`

**Signature:** `hardware::battery::status(arg4)`

**Module:** [`hardware`](../../hardware.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg4` | string | Yes | |

## Source

```bash
hardware::battery::status() {
    case "$(runtime::os)" in
    linux|wsl)
        local bat
        bat=$(_hardware::battery::find_bat)
        [[ -z "$bat" ]] && echo "unknown" && return
        cat "${bat}/status" 2>/dev/null || echo "unknown"
        ;;
    darwin)
        local state
        state="$(pmset -g batt 2>/dev/null | awk '/;/ {print $4}')"
        [[ "$state" == "charging;" ]] && echo "Charging" || echo "Discharging"
        ;;
    freebsd|dragonfly)
        local acline state
        acline=$(sysctl -n hw.acpi.acline 2>/dev/null)
        state=$(sysctl -n hw.acpi.battery.state 2>/dev/null)
        if [[ "$acline" == "1" && "$state" == "0" ]]; then echo "Full"
        elif [[ "$acline" == "1" ]]; then echo "Charging"
        else echo "Discharging"
        fi
        ;;
    openbsd)
        local state
        state="$(sysctl -n hw.sensors.acpibat0.raw0 2>/dev/null)"
        state="${state##? (battery }"
        state="${state%)*}"
        echo "${state^}"  # capitalise first letter
        ;;
    cygwin|mingw)
        hardware::battery::is_charging && echo "Charging" || echo "Discharging"
        ;;
    *)
        echo "unknown"
        ;;
    esac
}
```

