# `kernel::vm::overcommit::memory::get`

**Signature:** `kernel::vm::overcommit::memory::get()`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::vm::overcommit::memory::get() {
	cat /proc/sys/vm/overcommit_memory 2>/dev/null || echo "unknown"
}
```

