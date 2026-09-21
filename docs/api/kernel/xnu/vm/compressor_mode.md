# `kernel::xnu::vm::compressor_mode`

**Signature:** `kernel::xnu::vm::compressor_mode()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::xnu::vm::compressor_mode() {
	sysctl -n vm.compressor_mode 2>/dev/null || echo "unknown"
}
```

