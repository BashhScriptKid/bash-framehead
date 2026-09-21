# `device::read::scheduler`

**Signature:** `device::read::scheduler(arg1)`

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
device::read::scheduler() {
		local _dev="$1" _base="${1##*/}"
		local _sched
		_sched=$(cat "/sys/block/${_base}/queue/scheduler" 2>/dev/null) || { echo "unknown"; return 1; }
		echo "$_sched" | grep -oP '\[.*?\]' | tr -d '[]'
}
```

