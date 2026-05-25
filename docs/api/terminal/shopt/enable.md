# `terminal::shopt::enable`

**Signature:** `terminal::shopt::enable(arg1)`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

SHOPT WRAPPERS

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
terminal::shopt::enable() {
		shopt -s "$1" 2>/dev/null
}
```

