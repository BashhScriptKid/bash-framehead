# `binary::u32le`

**Signature:** `binary::u32le(<value>)`

**Module:** [`binary`](../binary.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Emit a 32-bit unsigned integer in little-endian byte order.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<value>` | string | Yes | |

## Source

```bash
binary::u32le() { _binary::pack 4 "$1" le; }
```

