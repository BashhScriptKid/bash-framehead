# `fs::dir::size::human`

**Signature:** `fs::dir::size::human(arg1)`

**Module:** [`fs`](../../../fs.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get total size of directory, human readable

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
fs::dir::size::human() {
    du -sh "${1:-.}" 2>/dev/null | awk '{print $1}'
}
```

