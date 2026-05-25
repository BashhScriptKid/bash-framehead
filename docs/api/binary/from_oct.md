# `binary::from_oct`

**Signature:** `binary::from_oct(<octal>)`

**Module:** [`binary`](../binary.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Emit raw bytes from an octal number string (minimal-width unsigned LE).

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<octal>` | string | Yes | |

## Source

```bash
binary::from_oct() {
		local val=$((8#$1))
		_binary::from_uint "$val"
}
```

