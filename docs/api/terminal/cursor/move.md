# `terminal::cursor::move`

**Signature:** `terminal::cursor::move(row, col)`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Move cursor to row, col (1-indexed)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `row` | string | Yes | |
| `col` | string | Yes | |

## Source

```bash
terminal::cursor::move() {
		printf '\033[%s;%sH' "$1" "$2"
}
```

