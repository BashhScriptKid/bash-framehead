# `binary::buffer::insert::int`

**Signature:** `binary::buffer::insert::int(<name>, <value>, <width>, [endian=le])`

**Module:** [`binary`](../../../binary.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Append a signed integer (two's complement, fixed-width).

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<name>` | string | Yes | |
| `<value>` | string | Yes | |
| `<width>` | string | Yes | |
| `endian=le` | string | No | |

## Source

```bash
binary::buffer::insert::int() {
	binary::buffer::insert::uint "$@"
}
```

