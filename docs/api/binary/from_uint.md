# `binary::from_uint`

**Signature:** `binary::from_uint(<n>)`

**Module:** [`binary`](../binary.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Emit raw bytes from an unsigned decimal integer (minimal-width LE).

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<n>` | string | Yes | |

## Source

```bash
binary::from_uint() {
		_binary::from_uint "$1"
}
```

