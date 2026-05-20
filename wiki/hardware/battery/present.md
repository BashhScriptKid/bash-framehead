# `hardware::battery::present`

_No description available._

## Source

```bash
hardware::battery::present() {
    case "$(runtime::os)" in
    linux|wsl)
        [[ -n "$(_hardware::battery::find_bat)" ]]
        ;;
    darwin)
        system_profiler SPPowerDataType 2>/dev/null | grep -q 'Battery'
        ;;
    freebsd|dragonfly)
        sysctl -n hw.acpi.battery.life 2>/dev/null | grep -qv '^$'
        ;;
    cygwin|mingw)
        wmic Path Win32_Battery get EstimatedChargeRemaining 2>/dev/null \
            | grep -qv '^EstimatedChargeRemaining'
        ;;
    *)
        return 1
        ;;
    esac
}
```

## Module

[`hardware`](../hardware.md)
