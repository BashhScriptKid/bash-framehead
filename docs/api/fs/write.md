# `fs::write`

**Signature:** `fs::write(path, content)`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Write content to file (overwrites)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `path` | path | Yes | |
| `content` | string | Yes | |

## Source

```bash
fs::write() {
    printf '%s' "$2" > "$1"
}
```

