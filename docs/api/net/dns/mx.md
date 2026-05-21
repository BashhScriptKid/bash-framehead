# `net::dns::mx`

**Signature:** `net::dns::mx(arg1)`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get MX records for a domain

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
net::dns::mx() {
    net::dns::records "$1" MX
}
```

