# `terminal::shopt::disable`

**Signature:** `terminal::shopt::disable(arg1)`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Disable a shopt option

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
terminal::shopt::disable() {
    shopt -u "$1" 2>/dev/null
}
```

