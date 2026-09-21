# `kernel::coredump::sort_vma::get`

**Signature:** `kernel::coredump::sort_vma::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::coredump::sort_vma::get() {
	cat /proc/sys/kernel/core_sort_vma 2>/dev/null || echo "unknown"
}
```

