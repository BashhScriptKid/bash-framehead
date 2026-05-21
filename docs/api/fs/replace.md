# `fs::replace`

**Signature:** `fs::replace(path, old, new)`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Replace string in file (in-place)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `path` | path | Yes | |
| `old` | string | Yes | |
| `new` | string | Yes | |

## Source

```bash
fs::replace() {
    sed -i "s|${2}|${3}|g" "$1"
}
```

