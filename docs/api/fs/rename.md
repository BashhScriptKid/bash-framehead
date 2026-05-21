# `fs::rename`

**Signature:** `fs::rename(old_path, new_name)`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Rename just the filename, keeping directory

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `old_path` | path | Yes | |
| `new_name` | variable | Yes | |

## Source

```bash
fs::rename() {
    local dir
    dir="$(fs::path::dirname "$1")"
    mv "$1" "$dir/$2"
}
```

