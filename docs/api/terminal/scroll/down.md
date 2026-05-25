# `terminal::scroll::down`

**Signature:** `terminal::scroll::down()`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Scroll down n lines


## Source

```bash
terminal::scroll::down() {
		printf '\033[%sT' "${1:-1}"
}
```

