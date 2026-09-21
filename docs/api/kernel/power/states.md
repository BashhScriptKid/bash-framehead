# `kernel::power::states`

**Signature:** `kernel::power::states()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- POWER MANAGEMENT ---


## Source

```bash
kernel::power::states() {
	cat /sys/power/state 2>/dev/null || echo "unknown"
}
```

