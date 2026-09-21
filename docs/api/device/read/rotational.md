# `device::read::rotational`

**Signature:** `device::read::rotational(arg1)`

**Module:** [`device`](../../device.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::read::rotational() {
		local _dev="$1" _base="${1##*/}"
		local _val
		_val=$(cat "/sys/block/${_base}/queue/rotational" 2>/dev/null) || { echo "unknown"; return 1; }
		[[ "$_val" == "1" ]] && echo "1" || echo "0"
}
```

