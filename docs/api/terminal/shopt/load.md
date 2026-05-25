# `terminal::shopt::load`

**Signature:** `terminal::shopt::load(varname)`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Restore state from a variable

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `varname` | variable | Yes | |

## Source

```bash
terminal::shopt::load() {
		local _var="${1:-_SHOPT_STATE}"
		eval "${!_var}"
}
```

