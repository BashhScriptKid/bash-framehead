# `hardware::battery::health`

**Signature:** `hardware::battery::health(arg2)`

**Module:** [`hardware`](../../hardware.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg2` | string | Yes | |

## Source

```bash
hardware::battery::health() {
    case "$(runtime::os)" in
    linux|wsl)
        local bat full design
        bat=$(_hardware::battery::find_bat)
        [[ -z "$bat" ]] && echo "unknown" && return
        full=$(cat "${bat}/charge_full" 2>/dev/null || cat "${bat}/energy_full" 2>/dev/null)
        design=$(cat "${bat}/charge_full_design" 2>/dev/null || cat "${bat}/energy_full_design" 2>/dev/null)
        [[ -z "$full" || -z "$design" ]] && echo "unknown" && return
        awk "BEGIN { printf \"%.1f\n\", ($full / $design) * 100 }"
        ;;
    darwin)
        system_profiler SPPowerDataType 2>/dev/null \
            | awk -F': ' '/Condition/ { print $2 }' || echo "unknown"
        ;;
    *)
        echo "unknown"
        ;;
    esac
}
```

