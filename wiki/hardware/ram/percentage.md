# `hardware::ram::percentage`

_No description available._

## Source

```bash
hardware::ram::percentage() {
    local used total
    used=$(hardware::ram::usedSpaceMB)
    total=$(hardware::ram::totalSpaceMB)
    [[ "$used" == "unknown" || "$total" == "unknown" ]] && echo "unknown" && return
    awk "BEGIN { printf \"%.1f\n\", ($used / $total) * 100 }"
}
```

## Module

[`hardware`](../hardware.md)
