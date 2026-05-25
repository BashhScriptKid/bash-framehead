# `hardware::battery::time_remaining`

**Signature:** `hardware::battery::time_remaining(arg4, arg5)`

**Module:** [`hardware`](../../hardware.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg4` | string | Yes | |
| `arg5` | string | Yes | |

## Source

```bash
hardware::battery::time_remaining() {
		case "$(runtime::os)" in
		linux|wsl)
				local bat
				bat=$(_hardware::battery::find_bat)
				[[ -z "$bat" ]] && echo "unknown" && return
				if runtime::has_command upower; then
						upower -i "$(upower -e 2>/dev/null | grep battery | head -1)" 2>/dev/null \
								| awk '/time to empty/ { print $4, $5 }' || echo "unknown"
				else
						cat "${bat}/time_to_empty_now" 2>/dev/null || echo "unknown"
				fi
				;;
		darwin)
				pmset -g batt 2>/dev/null | grep -oE '[0-9]+:[0-9]+ remaining' | head -1 || echo "unknown"
				;;
		freebsd|dragonfly)
				sysctl -n hw.acpi.battery.time 2>/dev/null || echo "unknown"
				;;
		*)
				echo "unknown"
				;;
		esac
}
```

