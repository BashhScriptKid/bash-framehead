# `hardware::partition::totalSpaceMB`

**Signature:** `hardware::partition::totalSpaceMB(arg2)`

**Module:** [`hardware`](../../hardware.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg2` | string | Yes | |

## Source

```bash
hardware::partition::totalSpaceMB() {
    local device="${1:-/}"
    df -BM "$device" 2>/dev/null | awk 'NR==2 { gsub(/M/,"",$2); print $2 }'
}
```

