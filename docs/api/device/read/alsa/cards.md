# `device::read::alsa::cards`

**Signature:** `device::read::alsa::cards(arg1, arg2)`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

--- AUDIO / ALSA ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
device::read::alsa::cards() {
		if [[ -f /proc/asound/cards ]]; then
				awk '/^[[:space:]]*[0-9]+/ {printf "%s %s\n", $1, $2}' /proc/asound/cards
		else
				echo "unknown"
		fi
}
```

