# `terminal::title`

**Signature:** `terminal::title(My, Script)`

**Module:** [`terminal`](../terminal.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Set terminal title (works in most modern terminal emulators)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `My` | string | Yes | |
| `Script` | string | Yes | |

## Source

```bash
terminal::title() {
    printf '\033]0;%s\007' "$1"
}
```

