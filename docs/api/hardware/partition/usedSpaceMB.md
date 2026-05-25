# `hardware::partition::usedSpaceMB`

**Signature:** `hardware::partition::usedSpaceMB(arg3)`

**Module:** [`hardware`](../../hardware.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg3` | string | Yes | |

## Source

```bash
hardware::partition::usedSpaceMB() {
		local device="${1:-/}"
		df -BM "$device" 2>/dev/null | awk 'NR==2 { gsub(/M/,"",$3); print $3 }'
}
```

