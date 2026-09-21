# `kernel::xnu::vm::pagefreeable`

**Signature:** `kernel::xnu::vm::pagefreeable()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::xnu::vm::pagefreeable() {
	sysctl -n vm.page_freeable 2>/dev/null || echo "unknown"
}
```

