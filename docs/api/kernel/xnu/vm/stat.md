# `kernel::xnu::vm::stat`

**Signature:** `kernel::xnu::vm::stat()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- XNU: VM ---


## Source

```bash
kernel::xnu::vm::stat() {
	vm_stat 2>/dev/null || echo "unknown"
}
```

