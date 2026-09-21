# `kernel::bsd::kern::ipc::somaxconn::get`

**Signature:** `kernel::bsd::kern::ipc::somaxconn::get()`

**Module:** [`kernel`](../../../../../kernel.md) — [Guide](../../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::bsd::kern::ipc::somaxconn::get() {
	sysctl -n kern.ipc.somaxconn 2>/dev/null || echo "unknown"
}
```

