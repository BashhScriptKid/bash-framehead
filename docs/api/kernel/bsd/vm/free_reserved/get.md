# `kernel::bsd::vm::free_reserved::get`

**Signature:** `kernel::bsd::vm::free_reserved::get()`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::bsd::vm::free_reserved::get() {
	sysctl -n vm.v_free_reserved 2>/dev/null || echo "unknown"
}
```

