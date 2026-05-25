# `binary::u64be`

**Signature:** `binary::u64be(<value>)`

**Module:** [`binary`](../binary.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Emit a 64-bit unsigned integer in big-endian byte order.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<value>` | string | Yes | |

## Source

```bash
binary::u64be() { _binary::pack 8 "$1" be; }
```

