# `kernel::bsd::kern::ipc::shmmax::get`

**Signature:** `kernel::bsd::kern::ipc::shmmax::get()`

**Module:** [`kernel`](../../../../../kernel.md) — [Guide](../../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::bsd::kern::ipc::shmmax::get() {
	sysctl -n kern.ipc.shmmax 2>/dev/null || echo "unknown"
}
```

