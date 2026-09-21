# `kernel::vm::overcommit::ratio::get`

**Signature:** `kernel::vm::overcommit::ratio::get()`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::vm::overcommit::ratio::get() {
	cat /proc/sys/vm/overcommit_ratio 2>/dev/null || echo "unknown"
}
```

