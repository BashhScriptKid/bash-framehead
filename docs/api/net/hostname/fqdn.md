# `net::hostname::fqdn`

**Signature:** `net::hostname::fqdn()`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get the fully qualified domain name


## Source

```bash
net::hostname::fqdn() {
    hostname -f 2>/dev/null
}
```

