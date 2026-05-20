# `hardware::partition::totalSpaceMB`

_No description available._

## Source

```bash
hardware::partition::totalSpaceMB() {
    local device="${1:-/}"
    df -BM "$device" 2>/dev/null | awk 'NR==2 { gsub(/M/,"",$2); print $2 }'
}
```

## Module

[`hardware`](../hardware.md)
