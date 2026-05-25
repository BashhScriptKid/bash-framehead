# `binary::u16be`

**Signature:** `binary::u16be(<value>)`

**Module:** [`binary`](../binary.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- BIG-ENDIAN (MSB first) ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<value>` | string | Yes | |

## Source

```bash
binary::u16be() { _binary::pack 2 "$1" be; }
```

