# `binary::u64le`

**Signature:** `binary::u64le(<value>)`

**Module:** [`binary`](../binary.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Emit a 64-bit unsigned integer in little-endian byte order.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<value>` | string | Yes | |

## Source

```bash
binary::u64le() { _binary::pack 8 "$1" le; }
```

