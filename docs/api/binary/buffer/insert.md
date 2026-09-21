# `binary::buffer::insert`

**Signature:** `binary::buffer::insert(<name>, <value>, <width>, [endian=le])`

**Module:** [`binary`](../../binary.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Compatibility alias.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<name>` | string | Yes | |
| `<value>` | string | Yes | |
| `<width>` | string | Yes | |
| `endian=le` | string | No | |

## Source

```bash
binary::buffer::insert() {
	binary::buffer::insert::uint "$@"
}
```

