# `hardware::partition::freeSpaceMB`

_No description available._

## Source

```bash
hardware::partition::freeSpaceMB() {
    local device="${1:-/}"
    df -BM "$device" 2>/dev/null | awk 'NR==2 { gsub(/M/,"",$4); print $4 }'
}
```

## Module

[`hardware`](../hardware.md)
