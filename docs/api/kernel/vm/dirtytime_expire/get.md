# `kernel::vm::dirtytime_expire::get`

**Signature:** `kernel::vm::dirtytime_expire::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::vm::dirtytime_expire::get() {
	cat /proc/sys/vm/dirtytime_expire_seconds 2>/dev/null || echo "unknown"
}
```

