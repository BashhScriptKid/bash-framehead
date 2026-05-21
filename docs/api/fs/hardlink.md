# `fs::hardlink`

**Signature:** `fs::hardlink(arg1, arg2)`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Create a hard link

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
fs::hardlink() {
    ln "$1" "$2"
}
```

