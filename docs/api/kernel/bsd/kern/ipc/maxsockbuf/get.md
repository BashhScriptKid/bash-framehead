# `kernel::bsd::kern::ipc::maxsockbuf::get`

**Signature:** `kernel::bsd::kern::ipc::maxsockbuf::get()`

**Module:** [`kernel`](../../../../../kernel.md) — [Guide](../../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::bsd::kern::ipc::maxsockbuf::get() {
	sysctl -n kern.ipc.maxsockbuf 2>/dev/null || echo "unknown"
}
```

