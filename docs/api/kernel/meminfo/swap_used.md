# `kernel::meminfo::swap_used`

**Signature:** `kernel::meminfo::swap_used(arg1, arg2)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
kernel::meminfo::swap_used() {
	local _total _free
	_total=$(awk '/^SwapTotal:/{print $2}' /proc/meminfo 2>/dev/null) || { echo "unknown"; return 1; }
	_free=$(awk '/^SwapFree:/{print $2}' /proc/meminfo 2>/dev/null) || { echo "unknown"; return 1; }
	echo $((_total - _free)) | awk '{printf "%.0f", $1/1024}'
}
```

