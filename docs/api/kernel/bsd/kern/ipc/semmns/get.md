# `kernel::bsd::kern::ipc::semmns::get`

**Signature:** `kernel::bsd::kern::ipc::semmns::get()`

**Module:** [`kernel`](../../../../../kernel.md) — [Guide](../../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::bsd::kern::ipc::semmns::get() {
	sysctl -n kern.ipc.semmns 2>/dev/null || echo "unknown"
}
```

