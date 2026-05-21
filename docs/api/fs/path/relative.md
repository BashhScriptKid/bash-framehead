# `fs::path::relative`

**Signature:** `fs::path::relative(/a/b/c, /a, →, b/c)`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Get path relative to a base

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `/a/b/c` | string | Yes | |
| `/a` | string | Yes | |
| `→` | string | Yes | |
| `b/c` | string | Yes | |

## Source

```bash
fs::path::relative() {
    local target="$1" base="$2"
    # Strip common prefix
    while [[ "$target" == "$base"* && "$base" != "/" ]]; do
        target="${target#$base}"
        target="${target#/}"
        break
    done
    echo "$target"
}
```

