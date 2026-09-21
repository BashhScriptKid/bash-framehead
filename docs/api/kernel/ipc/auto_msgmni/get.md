# `kernel::ipc::auto_msgmni::get`

**Signature:** `kernel::ipc::auto_msgmni::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::ipc::auto_msgmni::get() {
	cat /proc/sys/kernel/auto_msgmni 2>/dev/null || echo "unknown"
}
```

