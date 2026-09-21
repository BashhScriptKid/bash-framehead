# `kernel::bsd::hw::physmem`

**Signature:** `kernel::bsd::hw::physmem()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::bsd::hw::physmem() {
	sysctl -n hw.physmem 2>/dev/null || echo "unknown"
}
```

