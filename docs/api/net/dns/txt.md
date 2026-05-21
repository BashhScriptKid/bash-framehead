# `net::dns::txt`

**Signature:** `net::dns::txt(arg1)`

**Module:** [`net`](../../net.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get TXT records (useful for SPF, DKIM etc.)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
net::dns::txt() {
    net::dns::records "$1" TXT
}
```

