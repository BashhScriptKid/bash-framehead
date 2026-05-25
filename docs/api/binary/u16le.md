# `binary::u16le`

**Signature:** `binary::u16le(<value>)`

**Module:** [`binary`](../binary.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- LITTLE-ENDIAN (LSB first) ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<value>` | string | Yes | |

## Source

```bash
binary::u16le() { _binary::pack 2 "$1" le; }
```

