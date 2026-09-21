# `kernel::bsd::security::hardlink_uid_match::get`

**Signature:** `kernel::bsd::security::hardlink_uid_match::get()`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::bsd::security::hardlink_uid_match::get() {
	sysctl -n security.bsd.hardlink_check_uid 2>/dev/null || echo "unknown"
}
```

