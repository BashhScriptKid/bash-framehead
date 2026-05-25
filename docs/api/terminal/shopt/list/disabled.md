# `terminal::shopt::list::disabled`

**Signature:** `terminal::shopt::list::disabled(arg1, arg2)`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

List all disabled shopt options

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
terminal::shopt::list::disabled() {
		shopt | awk '$2 == "off" {print $1}'
}
```

