# `fs::lines`

**Signature:** `fs::lines(path, start, end)`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Read a range of lines

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `path` | path | Yes | |
| `start` | string | Yes | |
| `end` | string | Yes | |

## Source

```bash
fs::lines() {
    sed -n "${2},${3}p" "$1"
}
```

