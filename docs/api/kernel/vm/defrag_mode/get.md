# `kernel::vm::defrag_mode::get`

**Signature:** `kernel::vm::defrag_mode::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::vm::defrag_mode::get() {
	cat /proc/sys/vm/defrag_mode 2>/dev/null || echo "unknown"
}
```

