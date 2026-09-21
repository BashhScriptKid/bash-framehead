# `kernel::bsd::vm::free_target::get`

**Signature:** `kernel::bsd::vm::free_target::get()`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- BSD: VM ---


## Source

```bash
kernel::bsd::vm::free_target::get() {
	sysctl -n vm.v_free_target 2>/dev/null || echo "unknown"
}
```

