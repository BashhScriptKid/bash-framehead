# `hardware::partition::usagePercent`

**Signature:** `hardware::partition::usagePercent(arg5)`

**Module:** [`hardware`](../../hardware.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg5` | string | Yes | |

## Source

```bash
hardware::partition::usagePercent() {
		local device="${1:-/}"
		df "$device" 2>/dev/null | awk 'NR==2 { gsub(/%/,"",$5); print $5 }'
}
```

