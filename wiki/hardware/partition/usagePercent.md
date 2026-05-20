# `hardware::partition::usagePercent`

_No description available._

## Source

```bash
hardware::partition::usagePercent() {
    local device="${1:-/}"
    df "$device" 2>/dev/null | awk 'NR==2 { gsub(/%/,"",$5); print $5 }'
}
```

## Module

[`hardware`](../hardware.md)
