# `fs::find`

**Signature:** `fs::find(path, pattern)`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Recursive find by name pattern

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `path` | path | Yes | |
| `pattern` | regex | Yes | |

## Source

```bash
fs::find() {
    find "${1:-.}" -name "$2" 2>/dev/null
}
```

