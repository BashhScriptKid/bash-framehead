# `fs::path::dirname`

**Signature:** `fs::path::dirname(arg1)`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get directory from path (like dirname)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
fs::path::dirname() {
    local p="${1%/*}"
    [[ "$p" == "$1" ]] && echo "." || echo "$p"
}
```

