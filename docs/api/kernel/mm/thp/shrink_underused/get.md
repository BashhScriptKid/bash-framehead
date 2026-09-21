# `kernel::mm::thp::shrink_underused::get`

**Signature:** `kernel::mm::thp::shrink_underused::get()`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::mm::thp::shrink_underused::get() {
	cat /sys/kernel/mm/transparent_hugepage/shrink_underused 2>/dev/null || echo "unknown"
}
```

