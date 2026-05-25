# `hardware::battery::percentage`

**Signature:** `hardware::battery::percentage(arg2)`

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
hardware::battery::percentage() {
		case "$(runtime::os)" in
		linux|wsl)
				local bat
				bat=$(_hardware::battery::find_bat)
				[[ -z "$bat" ]] && echo "unknown" && return
				cat "${bat}/capacity" 2>/dev/null || echo "unknown"
				;;
		darwin)
				pmset -g batt 2>/dev/null | grep -oE '[0-9]+%' | tr -d '%' | head -1 || echo "unknown"
				;;
		freebsd|dragonfly)
				acpiconf -i 0 2>/dev/null \
						| awk -F ':\t' '/Remaining capacity/ {print $2}' \
						| tr -d '%' || echo "unknown"
				;;
		netbsd)
				envstat 2>/dev/null | awk '/charge:/ {print $2}' | cut -d. -f1 || echo "unknown"
				;;
		openbsd)
				local full now
				full="$(sysctl -n hw.sensors.acpibat0.watthour0 hw.sensors.acpibat0.amphour0 2>/dev/null)"
				full="${full%% *}"
				now="$(sysctl -n hw.sensors.acpibat0.watthour3 hw.sensors.acpibat0.amphour3 2>/dev/null)"
				now="${now%% *}"
				[[ -z "$full" || -z "$now" ]] && echo "unknown" && return
				echo "$(( 100 * ${now/\.} / ${full/\.} ))"
				;;
		cygwin|mingw)
				local val
				val="$(wmic Path Win32_Battery get EstimatedChargeRemaining 2>/dev/null \
						| grep -v 'EstimatedChargeRemaining' | tr -d '[:space:]')"
				[[ -n "$val" ]] && echo "$val" || echo "unknown"
				;;
		*)
				echo "unknown"
				;;
		esac
}
```

