# `fs::symlink`

**Signature:** `fs::symlink(target, link_name)`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Create a symlink

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `target` | path | Yes | |
| `link_name` | variable | Yes | |

## Source

```bash
fs::symlink() {
    ln -s "$1" "$2"
}
```

