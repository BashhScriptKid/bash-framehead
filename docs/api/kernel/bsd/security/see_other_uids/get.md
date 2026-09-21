# `kernel::bsd::security::see_other_uids::get`

**Signature:** `kernel::bsd::security::see_other_uids::get()`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::bsd::security::see_other_uids::get() {
	sysctl -n security.bsd.see_other_uids 2>/dev/null || echo "unknown"
}
```

