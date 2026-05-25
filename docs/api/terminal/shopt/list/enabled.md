# `terminal::shopt::list::enabled`

**Signature:** `terminal::shopt::list::enabled(arg1, arg2)`

**Module:** [`terminal`](../../../terminal.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

List all enabled shopt options

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
terminal::shopt::list::enabled() {
		shopt | awk '$2 == "on" {print $1}'
}
```

