# `kernel::bsd::vm::swapusage`

**Signature:** `kernel::bsd::vm::swapusage()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::bsd::vm::swapusage() {
	sysctl -n vm.swapusage 2>/dev/null || echo "unknown"
}
```

