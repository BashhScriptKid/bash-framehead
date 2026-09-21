# `kernel::mm::thp::shmem_enabled::get`

**Signature:** `kernel::mm::thp::shmem_enabled::get()`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::mm::thp::shmem_enabled::get() {
	cat /sys/kernel/mm/transparent_hugepage/shmem_enabled 2>/dev/null || echo "unknown"
}
```

