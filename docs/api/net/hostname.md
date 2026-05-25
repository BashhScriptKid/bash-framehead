# `net::hostname`

**Signature:** `net::hostname()`

**Module:** [`net`](../net.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- HOSTNAME / DNS ---


## Source

```bash
net::hostname() {
		hostname 2>/dev/null || cat /etc/hostname 2>/dev/null
}
```

