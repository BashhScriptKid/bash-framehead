# `kernel::mm::hugepages::overcommit::get`

**Signature:** `kernel::mm::hugepages::overcommit::get()`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::mm::hugepages::overcommit::get() {
	cat /proc/sys/vm/nr_overcommit_hugepages 2>/dev/null || echo "unknown"
}
```

