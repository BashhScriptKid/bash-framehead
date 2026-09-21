# `kernel::xnu::vm::compressor_pages`

**Signature:** `kernel::xnu::vm::compressor_pages()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::xnu::vm::compressor_pages() {
	sysctl -n vm.compressor_pages_used 2>/dev/null || echo "unknown"
}
```

