# `hardware::ram::percentage`

**Signature:** `hardware::ram::percentage()`

**Module:** [`hardware`](../../hardware.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

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

