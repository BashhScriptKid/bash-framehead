# `terminal::shopt::is_enabled`

**Signature:** `terminal::shopt::is_enabled(arg1)`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if a shopt option is enabled

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
terminal::shopt::is_enabled() {
    shopt -q "$1" 2>/dev/null
}
```

