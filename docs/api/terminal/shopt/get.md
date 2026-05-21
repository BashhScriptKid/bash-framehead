# `terminal::shopt::get`

**Signature:** `terminal::shopt::get(arg1, arg2)`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get current value of a shopt option ("on" or "off")

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
terminal::shopt::get() {
    shopt "$1" 2>/dev/null | awk '{print $2}'
}
```

