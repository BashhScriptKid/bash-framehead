# `kernel::security::lsm`

**Signature:** `kernel::security::lsm()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- SECURITY (LINUX-ONLY) ---


## Source

```bash
kernel::security::lsm() {
	cat /sys/kernel/security/lsm 2>/dev/null || echo "unknown"
}
```

