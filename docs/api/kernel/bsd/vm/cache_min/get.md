# `kernel::bsd::vm::cache_min::get`

**Signature:** `kernel::bsd::vm::cache_min::get()`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::bsd::vm::cache_min::get() {
	sysctl -n vm.v_cache_min 2>/dev/null || echo "unknown"
}
```

