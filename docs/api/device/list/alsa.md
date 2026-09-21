# `device::list::alsa`

**Signature:** `device::list::alsa(arg1)`

**Module:** [`device`](../../device.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::list::alsa() {
		if [[ -f /proc/asound/cards ]]; then
				awk '/^[[:space:]]*[0-9]+/ {print $1}' /proc/asound/cards
		else
				echo ""
		fi
}
```

