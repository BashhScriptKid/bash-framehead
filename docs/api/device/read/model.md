# `device::read::model`

**Signature:** `device::read::model(arg1)`

**Module:** [`device`](../../device.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- BLOCK METADATA ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::read::model() {
		local _dev="$1" _base="${1##*/}"
		cat "/sys/block/${_base}/device/model" 2>/dev/null | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}
```

