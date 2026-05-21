# `net::dns::ns`

**Signature:** `net::dns::ns(arg1)`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get nameservers for a domain

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
net::dns::ns() {
    net::dns::records "$1" NS
}
```

