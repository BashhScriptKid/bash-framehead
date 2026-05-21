# `fs::mkdir`

**Signature:** `fs::mkdir(arg1)`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Create directory (including parents)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
fs::mkdir() {
    mkdir -p "$1"
}
```

