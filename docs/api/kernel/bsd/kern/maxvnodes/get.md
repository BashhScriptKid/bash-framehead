# `kernel::bsd::kern::maxvnodes::get`

**Signature:** `kernel::bsd::kern::maxvnodes::get()`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::bsd::kern::maxvnodes::get() {
	sysctl -n kern.maxvnodes 2>/dev/null || echo "unknown"
}
```

