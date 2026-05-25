# `binary::u32be`

**Signature:** `binary::u32be(<value>)`

**Module:** [`binary`](../binary.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Emit a 32-bit unsigned integer in big-endian byte order.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<value>` | string | Yes | |

## Source

```bash
binary::u32be() { _binary::pack 4 "$1" be; }
```

