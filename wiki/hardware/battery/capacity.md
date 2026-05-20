# `hardware::battery::capacity`

_No description available._

## Source

```bash
hardware::battery::capacity() {
    case "$(runtime::os)" in
    linux|wsl)
        local bat
        bat=$(_hardware::battery::find_bat)
        [[ -z "$bat" ]] && echo "unknown" && return
        cat "${bat}/charge_full_design" 2>/dev/null \
            || cat "${bat}/energy_full_design" 2>/dev/null \
            || echo "unknown"
        ;;
    darwin)
        system_profiler SPPowerDataType 2>/dev/null \
            | awk -F': ' '/Full Charge Capacity/ { print $2 }' || echo "unknown"
        ;;
    freebsd|dragonfly)
        sysctl -n hw.acpi.battery.capacity 2>/dev/null || echo "unknown"
        ;;
    *)
        echo "unknown"
        ;;
    esac
}
```

## Module

[`hardware`](../hardware.md)
