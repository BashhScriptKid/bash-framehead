# `kernel::coredump::note_size_limit::get`

**Signature:** `kernel::coredump::note_size_limit::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::coredump::note_size_limit::get() {
	cat /proc/sys/kernel/core_file_note_size_limit 2>/dev/null || echo "unknown"
}
```

