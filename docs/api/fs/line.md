# `fs::line`

**Signature:** `fs::line(path, line_number)`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Read a specific line number (1-indexed)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `path` | path | Yes | |
| `line_number` | string | Yes | |

## Source

```bash
fs::line() {
    sed -n "${2}p" "$1"
}
```

