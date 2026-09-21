# `kernel::xnu::sip::status`

**Signature:** `kernel::xnu::sip::status()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- XNU: SIP ---


## Source

```bash
kernel::xnu::sip::status() {
	csrutil status 2>&1 || echo "unknown"
}
```

