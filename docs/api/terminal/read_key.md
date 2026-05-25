# `terminal::read_key`

**Signature:** `terminal::read_key(varname)`

**Module:** [`terminal`](../terminal.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

--- INPUT ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `varname` | variable | Yes | |

## Source

```bash
terminal::read_key() {
		local _var="${1:-_TERMINAL_KEY}"
		local _key
		IFS= read -r -s -n1 _key
		printf -v "$_var" '%s' "$_key"
}
```

