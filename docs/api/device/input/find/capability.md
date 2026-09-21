# `device::input::find::capability`

**Signature:** `device::input::find::capability(arg1, arg2)`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
device::input::find::capability() {
		local _cap="$1"
		local _bit
		case "$_cap" in
				key) _bit=1 ;;   # EV_KEY = bit 1
				rel) _bit=2 ;;   # EV_REL = bit 2
				abs) _bit=3 ;;   # EV_ABS = bit 3
				*)   echo ""; return 1 ;;
		esac
		awk -v bit="$_bit" '
		/^H:/{handlers=$0}
		/^B: EV/{
			ev_hex=$2
			# Parse hex bitmask
			ev_val = 0
			for (i=1; i<=length(ev_hex); i++) {
				c = substr(ev_hex, i, 1)
				if (c >= "0" && c <= "9") v = c + 0
				else if (c >= "a" && c <= "f") v = 10 + (index("abcdef", c) - 1)
				else if (c >= "A" && c <= "F") v = 10 + (index("ABCDEF", c) - 1)
				else v = 0
				ev_val = ev_val * 16 + v
			}
			# Check if bit is set
			mask = 2 ^ bit
			if (and(ev_val, mask)) {
				match(handlers, /event[0-9]+/)
				if (RSTART > 0) print substr(handlers, RSTART, RLENGTH)
			}
		}
		' /proc/bus/input/devices 2>/dev/null | head -1
}
```

